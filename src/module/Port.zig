//! The port is a thread-safe interface for interacting with an ethernet port.
//! The port performs transactions (ethercat datagrams).
//! A transaction is a single ethercat datagram that travels in the ethercat ring.
//! It is sent, travels through the network (potentially modified by the subdevices), and is received.
//!
//! Callers are expected to follow the life cycle of a transaction:
//!
//! 1. `sendTransaction()`: immediately send a transaction, using a full ethernet frame. Callers may use sendTransactions() to allow multiple transactions to be packed into individual ethernet frames (recommended).
//! 2. `continueTransaction()`: callers must call this repeatedly until the transaction is received.
//! 3. `releaseTransaction()`: callers must call this if sendTransaction() is successful.
//!
//! This interface is necessary because frames (and thus transactions) may be returned out of order
//! by the ethernet interface. So the port must have access to the full list of transactions that are currently
//! pending.
//!
//! The `continueTransaction()` concept also allows single-threaded operation without an event loop.
//!
//! Multiple callers are expected to cooperate to provide uniquely identifiable frames, through the datagram header
//! idx field or other means. See compareDatagramIdentity() for how frame identity is determined. If multiple transactions are pending with the same identity, a single datagram will be applied to all of them.

const std = @import("std");
const assert = std.debug.assert;

const logger = @import("root.zig").logger;
const nic = @import("nic.zig");
const telegram = @import("telegram.zig");
const wire = @import("wire.zig");

const Port = @This();

link_layer: nic.LinkLayer,
settings: Settings,
transactions: std.DoublyLinkedList,
transactions_mutex: std.Thread.Mutex = .{},

pub const Settings = struct {
    source_mac_address: u48 = 0xffff_ffff_ffff,
    dest_mac_address: u48 = 0xABCD_EF12_3456,
};

pub const Transaction = struct {
    data: TransactionDatagram,
    node: std.DoublyLinkedList.Node = .{},
};

pub const TransactionDatagram = struct {
    send_datagram: telegram.Datagram,
    recv_datagram: telegram.Datagram,
    done: bool = false,
    check_wkc: ?u16 = null,
    released: bool = true,

    /// The datagram to send is send_datagram.
    /// If recv_region is provided, the returned datagram.data payload will be placed there.
    /// If recv_region is null, the returned datagram payload will be placed back in the send_datagram.data.
    /// The recv_region, when provided, must be same length as send_datagram.data.
    ///
    /// If check_wkc is non-null, the returned wkc will be checked to be equal before copying the data to
    /// the recv region.
    pub fn init(send_datagram: telegram.Datagram, recv_region: ?[]u8, check_wkc: ?u16) TransactionDatagram {
        if (recv_region) |region| {
            assert(send_datagram.data.len == region.len);
        }
        return TransactionDatagram{
            .send_datagram = send_datagram,
            .recv_datagram = telegram.Datagram{
                .header = send_datagram.header,
                .wkc = 0,
                .data = recv_region orelse send_datagram.data,
            },
            .check_wkc = check_wkc,
        };
    }
};

pub fn init(link_layer: nic.LinkLayer, settings: Settings) Port {
    return Port{
        .link_layer = link_layer,
        .settings = settings,
        .transactions = .{},
    };
}

pub fn deinit(self: *Port) void {
    assert(self.transactions.len() == 0); // leaked transaction;
}

/// Caller owns responsibilty to release transactions after successful return from this function.
pub fn sendTransactions(self: *Port, transactions: []Transaction) error{LinkError}!void {
    // TODO: optimize to pack frames
    var n_sent: usize = 0;
    errdefer self.releaseTransactions(transactions[0..n_sent]);
    for (transactions) |*transaction| {
        try self.sendTransaction(transaction);
        n_sent += 1;
    }
}

/// Send a transaction with the ethercat bus.
/// Caller owns responsibilty to release transaction after successful return from this function.
/// Callers must take care to provide uniquely identifiable transactions, through idx or other means.
/// See fn compareDatagramIdentity.
fn sendTransaction(self: *Port, transaction: *Transaction) error{LinkError}!void {
    assert(transaction.data.done == false); // forget to release transaction?
    assert(transaction.data.released == true);
    assert(transaction.data.send_datagram.data.len == transaction.data.recv_datagram.data.len);
    // one datagram will always fit
    const ethercat_frame = telegram.EtherCATFrame.init((&transaction.data.send_datagram)[0..1]);
    var frame = telegram.EthernetFrame.init(
        .{
            .dest_mac = self.settings.dest_mac_address,
            .src_mac = self.settings.source_mac_address,
            .ether_type = .ETHERCAT,
        },
        ethercat_frame,
    );
    var out_buf: [telegram.max_frame_length]u8 = undefined;

    // one datagram will always fit
    const n_bytes = frame.serialize(null, &out_buf) catch |err| switch (err) {
        error.WriteFailed => unreachable,
    };
    const out = out_buf[0..n_bytes];

    // We need to append the transaction before we send.
    // Because we may recv from any thread.
    {
        self.transactions_mutex.lock();
        defer self.transactions_mutex.unlock();
        self.transactions.append(&transaction.node);
        transaction.data.released = false;
    }
    errdefer self.releaseTransactions(transaction[0..1]);
    // TODO: handle partial send error
    _ = self.link_layer.send(out) catch return error.LinkError;
}

/// Returns true when transaction is done.
/// Early returns when transaction is already done, without performing a recv.
/// If transaction is not already done, performs recv, which may recv any pending transaction.
pub fn continueTransactions(self: *Port, transactions: []Transaction) error{LinkError}!bool {
    if (self.done(transactions)) return true;
    self.recvFrame() catch |err| switch (err) {
        error.LinkError => {
            return error.LinkError;
        },
        error.InvalidFrame => {},
    };
    return self.done(transactions);
}

/// Returns true when all transactions are done, else false.
fn done(self: *Port, transactions: []Transaction) bool {
    self.transactions_mutex.lock();
    defer self.transactions_mutex.unlock();
    for (transactions) |transaction| {
        if (transaction.data.done) continue else return false;
    }
    return true;
}

fn recvFrame(self: *Port) !void {
    var buf: [telegram.max_frame_length]u8 = undefined;
    var frame_size: usize = 0;

    frame_size = self.link_layer.recv(&buf) catch |err| switch (err) {
        error.WouldBlock => return,
        else => {
            logger.err("Socket error: {}", .{err});
            return error.LinkError;
        },
    };
    if (frame_size == 0) return;
    if (frame_size > telegram.max_frame_length) return error.InvalidFrame;

    assert(frame_size <= telegram.max_frame_length);
    const bytes_recv: []u8 = buf[0..frame_size];

    var scratch_datagrams: [15]telegram.Datagram = undefined;
    const frame = telegram.EthernetFrame.deserialize(bytes_recv, &scratch_datagrams) catch |err| {
        logger.info("Failed to deserialize frame: {}", .{err});
        return;
    };
    for (frame.ethercat_frame.datagrams) |datagram| {
        self.findPutDatagramLocked(datagram);
    }
}

fn findPutDatagramLocked(self: *Port, datagram: telegram.Datagram) void {
    self.transactions_mutex.lock();
    defer self.transactions_mutex.unlock();

    var current: ?*Transaction = if (self.transactions.first) |first| @alignCast(@fieldParentPtr("node", first)) else null;
    while (current) |node| : (current = if (node.node.next) |next| @alignCast(@fieldParentPtr("node", next)) else null) {
        if (node.data.done) continue;
        if (compareDatagramIdentity(datagram, node.data.send_datagram)) {
            defer self.transactions.remove(&node.node);
            defer node.data.released = true;
            defer node.data.done = true;
            node.data.recv_datagram.header = datagram.header;
            node.data.recv_datagram.wkc = datagram.wkc;
            // memcpy can be skipped for non-read commands
            switch (datagram.header.command) {
                .APRD,
                .APRW,
                .ARMW,
                .BRD,
                .BRW,
                .FPRD,
                .FPRW,
                .FRMW,
                .LRD,
                .LRW,
                => {
                    if (node.data.check_wkc == null or node.data.check_wkc.? == datagram.wkc) {
                        @memcpy(node.data.recv_datagram.data, datagram.data);
                    }
                },
                .APWR, .BWR, .FPWR, .LWR, .NOP => {},
                _ => {},
            }
        }
        // we intentionally do not break here since we want to
        // handle idx collisions gracefully by just writing to all of them
    }
}

/// returns true when the datagrams are the same
fn compareDatagramIdentity(first: telegram.Datagram, second: telegram.Datagram) bool {
    if (first.header.command != second.header.command) return false;
    if (first.header.idx != second.header.idx) return false;
    switch (first.header.command) {
        .APRD,
        .APRW,
        .APWR,
        .ARMW,
        .BRD,
        .BRW,
        .BWR,
        => if (first.header.address.position.offset != second.header.address.position.offset) return false,
        .FPRD,
        .FPRW,
        .FPWR,
        .FRMW,
        .LRD,
        .LRW,
        .LWR,
        .NOP,
        => if (first.header.address.logical != second.header.address.logical) return false,
        _ => return false,
    }
    if (first.header.length != second.data.len) return false;
    if (first.data.len != second.data.len) return false;
    return true;
}

pub fn releaseTransactions(self: *Port, transactions: []Transaction) void {
    self.transactions_mutex.lock();
    defer self.transactions_mutex.unlock();
    for (transactions) |*transaction| {
        if (!transaction.data.released) {
            self.transactions.remove(&transaction.node);
            transaction.data.released = true;
        }
        assert(transaction.data.released == true);
    }
}

/// send and recv a no-op to quickly check if port works and are connected
pub fn ping(self: *Port, timeout_us: u32) !void {
    try self.nop(1, timeout_us);
}

pub const SendDatagramError = error{
    RecvTimeout,
    LinkError,
};
pub fn sendRecvDatagram(
    self: *Port,
    command: telegram.Command,
    address: u32,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    assert(data.len <= telegram.Datagram.max_data_length);

    var timer = std.time.Timer.start() catch @panic("timer unsupported");
    const datagram: telegram.Datagram = .init(command, address, false, data);
    var transaction: Transaction = .{ .data = .init(datagram, null, null) };

    try self.sendTransactions((&transaction)[0..1]);
    defer self.releaseTransactions((&transaction)[0..1]);

    while (timer.read() < @as(u64, timeout_us) * 1000) {
        if (try self.continueTransactions((&transaction)[0..1])) {
            break;
        }
    } else {
        return error.RecvTimeout;
    }
    return transaction.data.recv_datagram.wkc;
}

/// No operation.
/// The subdevice ignores the command.
pub fn nop(self: *Port, data_size: u16, timeout_us: u32) SendDatagramError!void {
    assert(data_size <= telegram.Datagram.max_data_length);
    assert(data_size > 0);
    var zeros = std.mem.zeroes([telegram.Datagram.max_data_length]u8);
    // wkc can be ignored on NOP, it is always zero
    _ = try sendRecvDatagram(
        self,
        telegram.Command.NOP,
        0,
        zeros[0..data_size],
        timeout_us,
    );
}

/// Auto increment physical read.
/// A subdevice increments the address.
/// A subdevice writes the data it has read to the EtherCAT datagram
/// if the address received is zero.
pub fn aprd(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.APRD,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Auto-increment physical read a packable type
pub fn aprdPack(
    self: *Port,
    comptime packed_type: type,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: packed_type, wkc: u16 } {
    var data = wire.zerosFromPack(packed_type);
    const wkc = try aprd(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(packed_type, data), .wkc = wkc };
}

/// Auto increment physical write.
/// A subdevice increments the address.
/// A subdevice writes data to a memory area if the address received is zero.
pub fn apwr(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.APWR,
        @bitCast(address),
        data,
        timeout_us,
    );
}

pub const SendDatagramWkcError = error{Wkc} || SendDatagramError;
pub fn apwrPackWkc(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!void {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try apwr(self, address, &data, timeout_us);
    if (wkc != expected_wkc) return error.Wkc;
}

/// Auto-increment physical write a packable type
pub fn apwrPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!u16 {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try apwr(self, address, &data, timeout_us);
    return wkc;
}

/// Auto increment physical read write.
/// A subdevice increments the address.
/// A subdevice writes the data it has read to the EtherCAT datagram and writes
/// the newly acquired data to the same memory area if the received address is zero.
pub fn aprw(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.APRW,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Auto-increment physical read-write a packable type
pub fn aprwPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: @TypeOf(packed_type), wkc: u16 } {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try aprw(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(@TypeOf(packed_type), data), .wkc = wkc };
}

/// Configured address physical read.
/// A subdevice writes the data it has read to the EtherCAT datagram if its subdevice
/// address matches one of the addresses configured in the datagram.
pub fn fprd(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.FPRD,
        @bitCast(address),
        data,
        timeout_us,
    );
}

pub fn fprdWkc(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!void {
    const wkc = try fprd(self, address, data, timeout_us);
    if (wkc != expected_wkc) return error.Wkc;
}

/// Configured address physical read a packable type
pub fn fprdPack(
    self: *Port,
    comptime packed_type: type,
    address: telegram.StationAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: packed_type, wkc: u16 } {
    var data = wire.zerosFromPack(packed_type);
    const wkc = try fprd(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(packed_type, data), .wkc = wkc };
}

/// Configured address physical read a packable type, expect wkc
pub fn fprdPackWkc(
    self: *Port,
    comptime packed_type: type,
    address: telegram.StationAddress,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!packed_type {
    const res = try fprdPack(
        self,
        packed_type,
        address,
        timeout_us,
    );
    if (res.wkc != expected_wkc) {
        return error.Wkc;
    }
    return res.ps;
}

/// Configured address physical write.
/// A subdevice writes data to a memory area if its subdevice address matches one
/// of the addresses configured in the datagram.
pub fn fpwr(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.FPWR,
        @bitCast(address),
        data,
        timeout_us,
    );
}

pub fn fpwrWkc(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!void {
    const wkc = try fpwr(self, address, data, timeout_us);
    if (wkc != expected_wkc) return error.Wkc;
}

/// Configured address physical write a packable type
pub fn fpwrPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.StationAddress,
    timeout_us: u32,
) SendDatagramError!u16 {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try fpwr(self, address, &data, timeout_us);
    return wkc;
}

pub fn fpwrPackWkc(
    self: *Port,
    packed_type: anytype,
    address: telegram.StationAddress,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!void {
    const wkc = try fpwrPack(self, packed_type, address, timeout_us);
    if (wkc != expected_wkc) return error.Wkc;
}

/// Configured address physical read write.
/// A subdevice writes the data it has read to the EtherCAT datagram and writes
/// the newly acquired data to the same memory area if its subdevice address matches
/// one of the addresses configured in the datagram.
pub fn fprw(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.FPRW,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Configured address physical read-write a packable type
pub fn fprwPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.StationAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: @TypeOf(packed_type), wkc: u16 } {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try fprw(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(@TypeOf(packed_type), data), .wkc = wkc };
}

/// Broadcast read.
/// All subdevices write a logical OR of the data from the memory area and the data
/// from the EtherCAT datagram to the EtherCAT datagram. All subdevices increment the
/// position field.
pub fn brd(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.BRD,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Broadcast read a packable type
pub fn brdPack(
    self: *Port,
    comptime packed_type: type,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: packed_type, wkc: u16 } {
    var data = wire.zerosFromPack(packed_type);
    const wkc = try brd(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(packed_type, data), .wkc = wkc };
}

/// Broadcast write.
/// All subdevices write data to a memory area. All subdevices increment the position field.
pub fn bwr(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.BWR,
        @bitCast(address),
        data,
        timeout_us,
    );
}

pub fn bwrPackWkc(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
    expected_wkc: u16,
) SendDatagramWkcError!void {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try bwr(self, address, &data, timeout_us);
    if (wkc != expected_wkc) return error.Wkc;
}

/// Broadcast write a packable type
pub fn bwrPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!u16 {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try bwr(self, address, &data, timeout_us);
    return wkc;
}

/// Broadcast read write.
/// All subdevices write a logical OR of the data from the memory area and the data from the
/// EtherCAT datagram to the EtherCAT datagram; all subdevices write data to the memory area.
/// BRW is typically not used. All subdevices increment the position field.
pub fn brw(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.BRW,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Broadcast read-write a packable type
pub fn brwPack(
    self: *Port,
    packed_type: anytype,
    address: telegram.PositionAddress,
    timeout_us: u32,
) SendDatagramError!struct { ps: @TypeOf(packed_type), wkc: u16 } {
    var data = wire.eCatFromPack(packed_type);
    const wkc = try brw(self, address, &data, timeout_us);
    return .{ .ps = wire.packFromECat(@TypeOf(packed_type), data), .wkc = wkc };
}

/// Logical memory read.
/// A subdevice writes data it has read to the EtherCAT datagram if the address received
/// matches one of the FMMU areas configured for reading.
pub fn lrd(
    self: *Port,
    address: telegram.LogicalAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.LRD,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Logical memory write.
/// Subdevices write data to their memory area if the address received matches one of
/// the FMMU areas configured for writing.
pub fn lwr(
    self: *Port,
    address: telegram.LogicalAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.LWR,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Logical memory read write.
/// A subdevice writes data it has read to the EtherCAT datagram if the address received
/// matches one of the FMMU areas configured for reading. Subdevices write data to their memory area
/// if the address received matches one of the FMMU areas configured for writing.
pub fn lrw(
    self: *Port,
    address: telegram.LogicalAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.LRW,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Auto increment physical read multiple write.
/// A subdevice increments the address field. A subdevice writes data it has read to the EtherCAT
/// datagram when the address received is zero, otherwise it writes data to the memory area.
pub fn armw(
    self: *Port,
    address: telegram.PositionAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.ARMW,
        @bitCast(address),
        data,
        timeout_us,
    );
}

/// Configured address physical read multiple write.
pub fn frmw(
    self: *Port,
    address: telegram.StationAddress,
    data: []u8,
    timeout_us: u32,
) SendDatagramError!u16 {
    return sendRecvDatagram(
        self,
        telegram.Command.FRMW,
        @bitCast(address),
        data,
        timeout_us,
    );
}
