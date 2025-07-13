//! Deterministic Simulator for EtherCAT Networks

const std = @import("std");
const assert = std.debug.assert;

const ENI = @import("ENI.zig");
const esc = @import("esc.zig");
const logger = @import("root.zig").logger;
const nic = @import("nic.zig");
pub const ESM = @import("sim/ESM.zig");
pub const SII = @import("sim/SII.zig");
const telegram = @import("telegram.zig");
const wire = @import("wire.zig");

/// Provides a link layer that will simulate an ethercat network
/// specified using an ethercat network information struct.
///
/// Simulator advances one tick during recv() and returns frames
/// like a raw socket.
/// Simulator injests frames from application using send().
pub const Simulator = struct {
    eni: ENI,
    arena: *std.heap.ArenaAllocator,
    /// Frames waiting to be processed during tick().
    /// Appended by send().
    in_frames: *std.ArrayList(Frame),
    /// frames waiting to be returned by recv().
    /// Appended by tick().
    out_frames: *std.ArrayList(Frame),
    /// simulated subdevices
    subdevices: []Subdevice,

    const Frame = std.BoundedArray(u8, telegram.max_frame_length);

    pub const Options = struct {
        max_simultaneous_frames_in_flight: usize = 256,
    };

    /// Allocates once. Never allocates again.
    /// Call deinit to free resources.
    pub fn init(eni: ENI, allocator: std.mem.Allocator, options: Options) !Simulator {
        const arena = try allocator.create(std.heap.ArenaAllocator);
        errdefer allocator.destroy(arena);
        arena.* = std.heap.ArenaAllocator.init(allocator);
        errdefer arena.deinit();

        const in_frames_slice = try arena.allocator().alloc(Frame, options.max_simultaneous_frames_in_flight);
        const in_frames = try arena.allocator().create(std.ArrayList(Frame));
        in_frames.* = std.ArrayList(Frame).fromOwnedSlice(std.testing.failing_allocator, in_frames_slice);
        in_frames.shrinkRetainingCapacity(0);

        const out_frames_slice = try arena.allocator().alloc(Frame, options.max_simultaneous_frames_in_flight);
        const out_frames = try arena.allocator().create(std.ArrayList(Frame));
        out_frames.* = std.ArrayList(Frame).fromOwnedSlice(std.testing.failing_allocator, out_frames_slice);
        out_frames.shrinkRetainingCapacity(0);

        const subdevices = try arena.allocator().alloc(Subdevice, eni.subdevices.len);
        for (subdevices, eni.subdevices) |*subdevice, config| {
            subdevice.* = Subdevice.init(config);
        }

        return Simulator{
            .eni = eni,
            .arena = arena,
            .in_frames = in_frames,
            .out_frames = out_frames,
            .subdevices = subdevices,
        };
    }
    pub fn deinit(self: *Simulator, allocator: std.mem.Allocator) void {
        self.arena.deinit();
        allocator.destroy(self.arena);
    }

    // add a frame to the processing queue
    pub fn send(ctx: *anyopaque, bytes: []const u8) std.posix.SendError!void {
        const self: *Simulator = @ptrCast(@alignCast(ctx));
        const frame = Frame.fromSlice(bytes) catch return error.MessageTooBig;
        self.in_frames.append(frame) catch return error.SystemResources;
    }

    // execute one tick in the simulator, return a frame if available
    pub fn recv(ctx: *anyopaque, out: []u8) std.posix.RecvFromError!usize {
        const self: *Simulator = @ptrCast(@alignCast(ctx));
        self.tick();
        // TODO: re-order frames randomly
        var out_stream = std.io.fixedBufferStream(out);
        if (self.out_frames.pop()) |frame| {
            return out_stream.write(frame.slice()) catch |err| switch (err) {
                error.NoSpaceLeft => return 0,
            };
        } else return 0;
        unreachable;
    }

    pub fn linkLayer(self: *Simulator) nic.LinkLayer {
        return nic.LinkLayer{
            .ptr = self,
            .vtable = &.{ .send = send, .recv = recv },
        };
    }

    pub fn tick(self: *Simulator) void {
        while (self.in_frames.pop()) |frame| {
            var mut_frame = frame;
            for (self.subdevices) |*subdevice| {
                subdevice.processFrame(&mut_frame);
            }
            self.out_frames.appendAssumeCapacity(mut_frame);
        }
    }
};

pub const Subdevice = struct {
    config: ENI.SubdeviceConfiguration,
    physical_memory: PhysMem,
    eeprom: []const u8,
    esm: ESM,
    sii: SII,

    pub const PhysMem = [4096]u8;

    pub fn init(config: ENI.SubdeviceConfiguration) Subdevice {
        var physical_memory: [4096]u8 = @splat(0);
        var eeprom: []const u8 = &.{};
        if (config.sim) |sim| {
            if (sim.physical_memory.len == physical_memory.len) {
                @memcpy(&physical_memory, sim.physical_memory);
            } else {
                logger.err("Invalid physical memory length in eni.", .{});
            }
            eeprom = sim.eeprom;
        }
        var sub = Subdevice{
            .config = config,
            .physical_memory = physical_memory,
            .eeprom = eeprom,
            .esm = .{},
            .sii = .{},
        };
        sub.initTick();
        return sub;
    }

    fn writeDatagramToPhysicalMemory(self: *Subdevice, datagram: *const telegram.Datagram) void {
        assert(datagram.data.len == datagram.header.length);
        const start_addr = @as(usize, datagram.header.address.position.offset);
        const end_exclusive: usize = start_addr + datagram.header.length;
        const write_region = self.physical_memory[start_addr..end_exclusive];
        for (datagram.data, write_region) |source, *dest| {
            dest.* = source;
        }
    }
    fn readPhysicalMemoryToDatagram(self: *const Subdevice, datagram: *const telegram.Datagram) void {
        assert(datagram.data.len == datagram.header.length);
        const start_addr = @as(usize, datagram.header.address.position.offset);
        const end_exclusive: usize = start_addr + datagram.header.length;
        const read_region = self.physical_memory[start_addr..end_exclusive];
        for (datagram.data, read_region) |*dest, source| {
            dest.* = source;
        }
    }
    fn readPhysicalMemoryToDatagramBitwiseOr(self: *const Subdevice, datagram: *const telegram.Datagram) void {
        assert(datagram.data.len == datagram.header.length);
        const start_addr = @as(usize, datagram.header.address.position.offset);
        const end_exclusive: usize = start_addr + datagram.header.length;
        const read_region = self.physical_memory[start_addr..end_exclusive];
        for (datagram.data, read_region) |*dest, source| {
            dest.* |= source;
        }
    }

    pub fn processFrame(self: *Subdevice, frame: *Simulator.Frame) void {
        var scratch_datagrams: [15]telegram.Datagram = undefined;
        const ethernet_frame = telegram.EthernetFrame.deserialize(frame.slice(), &scratch_datagrams) catch return;
        const datagrams = ethernet_frame.ethercat_frame.datagrams;
        skip_datagram: for (datagrams) |*datagram| {
            // TODO: operate if address zero
            // increment address field
            const station_address = readRegister(esc.StationAddressRegister, .station_address, &self.physical_memory);
            const alias_enabled = readRegister(esc.DLControlRegister, .DL_control, &self.physical_memory).enable_alias_address;
            switch (datagram.header.command) {
                .NOP => continue :skip_datagram,
                .BRD, .BWR => |command| {
                    if (!validOffsetLen(datagram.header.address.position.offset, datagram.header.length)) {
                        continue :skip_datagram;
                    }
                    switch (command) {
                        .BWR => self.writeDatagramToPhysicalMemory(datagram),
                        .BRD => self.readPhysicalMemoryToDatagramBitwiseOr(datagram),
                        else => unreachable,
                    }
                    datagram.wkc +%= 1;
                    // subdevice shall increment the address on confirmation
                    // Ref: IEC 61158-3-12:2019 5.2.4, 5.3.4
                    datagram.header.address.position.autoinc_address +%= 1;
                },
                .APWR, .APRD => |command| {
                    if (!validOffsetLen(datagram.header.address.position.offset, datagram.header.length)) {
                        continue :skip_datagram;
                    }
                    if (datagram.header.address.position.autoinc_address == 0) {
                        switch (command) {
                            .APWR => self.writeDatagramToPhysicalMemory(datagram),
                            .APRD => self.readPhysicalMemoryToDatagram(datagram),
                            else => unreachable,
                        }
                        datagram.wkc +%= 1;
                    }
                    // subdevice shall always increment the address
                    // Ref: IEC 61158-3-12:2019 5.2.4
                    datagram.header.address.position.autoinc_address +%= 1;
                },
                .FPWR, .FPRD => |command| {
                    if (!validOffsetLen(datagram.header.address.station.offset, datagram.header.length)) {
                        continue :skip_datagram;
                    }
                    if (datagram.header.address.station.station_address == station_address.configured_station_address or
                        (alias_enabled and datagram.header.address.station.station_address == station_address.configured_station_alias))
                    {
                        switch (command) {
                            .FPWR => self.writeDatagramToPhysicalMemory(datagram),
                            .FPRD => self.readPhysicalMemoryToDatagram(datagram),
                            else => unreachable,
                        }
                        datagram.wkc +%= 1;
                    }
                },
                .FPRW,
                .ARMW,
                .LWR,
                .LRD,
                .LRW,
                .APRW,
                .BRW,
                .FRMW,
                => |non_implemented| {
                    std.log.err("TODO: implement datagram header command: {s}", .{@tagName(non_implemented)});
                    continue :skip_datagram;
                },
                _ => |value| {
                    std.log.err("Invalid datagram header command: {}", .{@intFromEnum(value)});
                    continue :skip_datagram;
                },
            }
        }
        var new_frame = Simulator.Frame{};
        new_frame.len = frame.len;
        var new_eth_frame = telegram.EthernetFrame.init(ethernet_frame.header, telegram.EtherCATFrame.init(datagrams));
        const num_written = new_eth_frame.serialize(null, new_frame.slice()) catch unreachable;
        assert(num_written == frame.len);
        frame.* = new_frame;

        self.tick();
    }

    pub fn validOffsetLen(offset: u16, len: u11) bool {
        const end: u16, const overflowed = @addWithOverflow(offset, len);
        return (overflowed == 0 and end <= 4095);
    }

    pub fn initTick(self: *Subdevice) void {
        self.esm.initTick(&self.physical_memory);
        self.sii.initTick(&self.physical_memory);
    }

    pub fn tick(self: *Subdevice) void {
        self.esm.tick(&self.physical_memory);
        self.sii.tick(&self.physical_memory, self.eeprom);
    }
};

pub fn readRegister(comptime T: type, offset: esc.RegisterMap, phys_mem: *const Subdevice.PhysMem) T {
    const byte_size = wire.packedSize(T);
    const start: usize = @intFromEnum(offset);
    const end: usize = start + byte_size;
    return wire.packFromECatSlice(T, phys_mem[start..end]);
}
pub fn writeRegister(pack: anytype, offset: esc.RegisterMap, phys_mem: *Subdevice.PhysMem) void {
    const byte_size = wire.packedSize(@TypeOf(pack));
    const start: usize = @intFromEnum(offset);
    const end: usize = start + byte_size;
    const bytes = wire.eCatFromPack(pack);
    @memcpy(phys_mem[start..end], &bytes);
}

test {
    std.testing.refAllDecls(@This());
}
