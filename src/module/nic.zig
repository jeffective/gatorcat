const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const npcap = @import("npcap");

const logger = @import("root.zig").logger;
const telegram = @import("telegram.zig");

/// Interface for networking hardware
pub const LinkLayer = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        send: *const fn (ctx: *anyopaque, data: []const u8) anyerror!void,
        recv: *const fn (ctx: *anyopaque, out: []u8) anyerror!usize,
    };

    /// Send data on the wire.
    /// Sent data must include the ethernet header and not the FCS.
    /// Sent data must be 1 frame and less than maximum allowable frame length.
    /// Must not partially send data, if the data cannot be transmitted atomically,
    /// an error must be returned.
    ///
    /// Returns error on failure, else void.
    ///
    /// This is similar to the behavior of send() in linux on a raw
    /// socket.
    ///
    /// warning: implementation must be thread-safe.
    pub fn send(self: LinkLayer, data: []const u8) anyerror!void {
        assert(data.len <= telegram.max_frame_length);
        return try self.vtable.send(self.ptr, data);
    }

    /// Receive data from the wire.
    /// Received data must include ethernet header and not the FCS.
    /// Receive up to 1 frame of data to the out buffer.
    /// Returns the size of the frame or zero when there is no data,
    /// regardless of the size of the out buffer.
    /// Data in the frame beyond the size of the out buffer is discarded.
    ///
    /// This is similar to the behavior of recv() in linux on a raw
    /// socket with MSG_TRUNC enabled.
    ///
    /// warning: implementation must be thread-safe.
    pub fn recv(self: LinkLayer, out: []u8) anyerror!usize {
        return try self.vtable.recv(self.ptr, out);
    }
};

/// Raw socket based link layer. Supports Linux and Windows.
/// Windows is NOT recommended for real-time applications.
pub const RawSocket = switch (builtin.os.tag) {
    .linux => LinuxRawSocket,
    .windows => WindowsRawSocket,
    else => unreachable,
};

/// Raw socket implementation for LinkLayer
pub const LinuxRawSocket = struct {
    send_mutex: std.Thread.Mutex = .{},
    recv_mutex: std.Thread.Mutex = .{},
    socket: std.posix.socket_t,

    pub const InitError = error{
        /// The ifname argument provided is too long.
        InterfaceNameTooLong,
        /// Non-descriptive error. OS returned an error.
        NicError,
    } || std.posix.SocketError || std.posix.SetSockOptError || std.posix.IoCtl_SIOCGIFINDEX_Error || std.posix.BindError;
    pub fn init(
        ifname: [:0]const u8,
    ) InitError!LinuxRawSocket {
        if (ifname.len > std.posix.IFNAMESIZE - 1) return error.InterfaceNameTooLong;
        assert(ifname.len <= std.posix.IFNAMESIZE - 1); // ifname too long
        const ETH_P_ETHERCAT = @intFromEnum(telegram.EtherType.ETHERCAT);
        const socket: std.posix.socket_t = try std.posix.socket(
            std.posix.AF.PACKET,
            std.posix.SOCK.RAW,
            std.mem.nativeToBig(u32, ETH_P_ETHERCAT),
        );
        var timeout_rcv = std.posix.timeval{
            .sec = 0,
            .usec = 1,
        };
        try std.posix.setsockopt(
            socket,
            std.posix.SOL.SOCKET,
            std.posix.SO.RCVTIMEO,
            std.mem.asBytes(&timeout_rcv),
        );

        var timeout_snd = std.posix.timeval{
            .sec = 0,
            .usec = 1,
        };
        try std.posix.setsockopt(
            socket,
            std.posix.SOL.SOCKET,
            std.posix.SO.SNDTIMEO,
            std.mem.asBytes(&timeout_snd),
        );
        const dontroute_enable: c_int = 1;
        try std.posix.setsockopt(
            socket,
            std.posix.SOL.SOCKET,
            std.posix.SO.DONTROUTE,
            std.mem.asBytes(&dontroute_enable),
        );
        var ifr: std.posix.ifreq = std.mem.zeroInit(std.posix.ifreq, .{});
        @memcpy(ifr.ifrn.name[0..ifname.len], ifname);
        ifr.ifrn.name[ifname.len] = 0;
        try std.posix.ioctl_SIOCGIFINDEX(socket, &ifr);
        const ifindex: i32 = ifr.ifru.ivalue;

        var rval = std.posix.errno(std.os.linux.ioctl(socket, std.os.linux.SIOCGIFFLAGS, @intFromPtr(&ifr)));
        switch (rval) {
            .SUCCESS => {},
            else => {
                return error.NicError;
            },
        }
        ifr.ifru.flags.BROADCAST = true;
        ifr.ifru.flags.PROMISC = true;
        rval = std.posix.errno(std.os.linux.ioctl(socket, std.os.linux.SIOCSIFFLAGS, @intFromPtr(&ifr)));
        switch (rval) {
            .SUCCESS => {},
            else => {
                return error.NicError;
            },
        }
        const sockaddr_ll = std.posix.sockaddr.ll{
            .family = std.posix.AF.PACKET,
            .ifindex = ifindex,
            .protocol = std.mem.nativeToBig(u16, @as(u16, ETH_P_ETHERCAT)),
            .halen = 0, //not used
            .addr = .{ 0, 0, 0, 0, 0, 0, 0, 0 }, //not used
            .pkttype = 0, //not used
            .hatype = 0, //not used
        };
        try std.posix.bind(socket, @ptrCast(&sockaddr_ll), @sizeOf(@TypeOf(sockaddr_ll)));
        return LinuxRawSocket{
            .socket = socket,
        };
    }

    pub fn deinit(self: *LinuxRawSocket) void {
        std.posix.close(self.socket);
    }

    pub fn send(ctx: *anyopaque, bytes: []const u8) std.posix.SendError!void {
        const self: *LinuxRawSocket = @ptrCast(@alignCast(ctx));
        self.send_mutex.lock();
        defer self.send_mutex.unlock();
        _ = try std.posix.send(self.socket, bytes, 0);
    }

    pub fn recv(ctx: *anyopaque, out: []u8) std.posix.RecvFromError!usize {
        const self: *LinuxRawSocket = @ptrCast(@alignCast(ctx));
        self.recv_mutex.lock();
        defer self.recv_mutex.unlock();
        return try std.posix.recv(self.socket, out, std.posix.MSG.TRUNC);
    }

    pub fn linkLayer(self: *LinuxRawSocket) LinkLayer {
        return LinkLayer{
            .ptr = self,
            .vtable = &.{ .send = send, .recv = recv },
        };
    }
};

var pcap_errbuf: [npcap.c.PCAP_ERRBUF_SIZE]u8 = [_]u8{0} ** npcap.c.PCAP_ERRBUF_SIZE;
pub const WindowsRawSocket = struct {
    send_mutex: std.Thread.Mutex = .{},
    recv_mutex: std.Thread.Mutex = .{},
    socket: *npcap.c.struct_pcap,

    pub fn init(ifname: [:0]const u8) !WindowsRawSocket {
        const socket = npcap.c.pcap_open(ifname, 65536, npcap.c.PCAP_OPENFLAG_PROMISCUOUS |
            npcap.c.PCAP_OPENFLAG_MAX_RESPONSIVENESS |
            npcap.c.PCAP_OPENFLAG_NOCAPTURE_LOCAL, -1, null, &pcap_errbuf) orelse {
            logger.err("Failed to open interface {s}, npcap error: {s}", .{ ifname, pcap_errbuf });
            return error.FailedToOpenInterface;
        };

        return WindowsRawSocket{
            .socket = socket,
        };
    }

    pub fn send(ctx: *anyopaque, bytes: []const u8) std.posix.SendError!void {
        const self: *WindowsRawSocket = @ptrCast(@alignCast(ctx));
        self.send_mutex.lock();
        defer self.send_mutex.unlock();
        const result = npcap.c.pcap_sendpacket(self.socket, bytes.ptr, @intCast(bytes.len));
        if (result == npcap.c.PCAP_ERROR) return error.NetworkSubsystemFailed;
    }

    pub fn recv(ctx: *anyopaque, out: []u8) std.posix.RecvFromError!usize {
        const self: *WindowsRawSocket = @ptrCast(@alignCast(ctx));
        self.recv_mutex.lock();
        defer self.recv_mutex.unlock();
        var packet_header_ptr: [*c]npcap.c.pcap_pkthdr = undefined;
        var packet_data_ptr: [*c]const u8 = undefined;
        const result = npcap.c.pcap_next_ex(self.socket, &packet_header_ptr, &packet_data_ptr);
        if (result == 0) return 0;
        if (result != 1) return error.NetworkSubsystemFailed;
        var writer = std.Io.Writer.fixed(out);

        const bytes_received = packet_header_ptr.*.len;
        if (bytes_received == 0) return 0;
        writer.writeAll(packet_data_ptr[0..bytes_received]) catch |err| switch (err) {
            // TODO: this doesnt seem right...
            error.WriteFailed => return @intCast(bytes_received),
        };
        return @intCast(bytes_received);
    }

    pub fn linkLayer(self: *WindowsRawSocket) LinkLayer {
        return LinkLayer{
            .ptr = self,
            .vtable = &.{ .send = send, .recv = recv },
        };
    }

    pub fn deinit(self: WindowsRawSocket) void {
        npcap.c.pcap_close(self.socket);
    }
};
