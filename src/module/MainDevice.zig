const std = @import("std");
const assert = std.debug.assert;

const ENI = @import("ENI.zig");
const esc = @import("esc.zig");
const gcat = @import("root.zig");
const logger = @import("root.zig").logger;
const nic = @import("nic.zig");
const pdi = @import("pdi.zig");
const Port = @import("Port.zig");
const sii = @import("sii.zig");
const Subdevice = @import("Subdevice.zig");
const telegram = @import("telegram.zig");
const wire = @import("wire.zig");

const MainDevice = @This();

port: *Port,
settings: Settings,
subdevices: []Subdevice,
process_image: []u8,
transactions: Transactions,
first_cycle_time: ?std.time.Instant = null,

pub const Transactions = struct {
    state_check_res: *[wire.packedSize(esc.ALStatus)]u8,
    /// 0: state_check
    /// 1..: process data
    all: []Port.Transaction,
    idx: u8,
};

pub const Settings = struct {
    recv_timeout_us: u32 = 2000,
    eeprom_timeout_us: u32 = 10000,
    mbx_timeout_us: u32 = 50000,
};

pub fn init(
    allocator: std.mem.Allocator,
    port: *Port,
    settings: Settings,
    eni: ENI,
) !MainDevice {
    const process_image = try allocator.alloc(u8, eni.processImageSize());
    errdefer allocator.free(process_image);
    @memset(process_image, 0);

    const n_datagrams = 1 + (std.math.divCeil(
        u32,
        eni.processImageSize(),
        telegram.Datagram.max_data_length,
    ) catch unreachable); // TODO: is this actually unreachable?
    const transactions = try allocator.alloc(Port.Transaction, n_datagrams);
    errdefer allocator.free(transactions);
    initProcessDataTransactions(transactions[1..], process_image);

    const state_check_result = try allocator.create([wire.packedSize(esc.ALStatus)]u8);
    errdefer allocator.destroy(state_check_result);
    @memset(state_check_result.*[0..], 0);

    transactions[0] = .{
        .data = .init(
            telegram.Datagram.init(
                .BRD,
                @bitCast(telegram.PositionAddress{
                    .autoinc_address = 0,
                    .offset = @intFromEnum(esc.Register.al_status),
                }),
                false,
                state_check_result.*[0..],
            ),
            null,
            null,
        ),
    };

    const subdevices = try allocator.alloc(Subdevice, eni.subdevices.len);
    errdefer allocator.free(subdevices);
    eni.initSubdevicesFromENI(subdevices, process_image);

    return MainDevice{
        .port = port,
        .settings = settings,
        .subdevices = subdevices,
        .process_image = process_image,
        .transactions = .{
            .state_check_res = state_check_result,
            .all = transactions,
            .idx = 0,
        },
    };
}

/// initialize uninitialized process data transaction memory
fn initProcessDataTransactions(transactions: []Port.Transaction, process_image: []u8) void {
    const len: u32 = @intCast(process_image.len);
    var bytes_remaining: u32 = @intCast(process_image.len);
    for (transactions) |*transaction| {
        const bytes_used = telegram.Datagram.max_data_length - (telegram.Datagram.max_data_length -| bytes_remaining);
        assert(bytes_used > 0);
        const start_addr = len - bytes_remaining;
        const end_addr = start_addr + bytes_used;
        assert(end_addr > start_addr);
        const datagram: telegram.Datagram = .init(.LRW, start_addr, false, process_image[start_addr..end_addr]);
        transaction.* = .{
            // TODO: implement check_wkc
            .data = .init(datagram, null, null),
        };
        bytes_remaining -= (end_addr - start_addr);
    }
    assert(bytes_remaining == 0);
}

pub fn deinit(self: *MainDevice, allocator: std.mem.Allocator) void {
    self.port.releaseTransactions(self.transactions.all);
    allocator.free(self.process_image);
    allocator.free(self.subdevices);
    allocator.free(self.transactions.all);
    allocator.destroy(self.transactions.state_check_res);
}

pub fn getProcessImage(
    self: *MainDevice,
    comptime eni: ENI,
) eni.ProcessImageType() {
    return wire.packFromECatSlice(eni.ProcessImageType(), self.process_image);
}

/// Initialize the ethercat bus.
///
/// Sets all subdevices to the INIT state.
/// Puts the bus in a known good starting configuration.
pub fn busInit(self: *MainDevice, change_timeout_us: u32) !void {

    // open all ports
    var wkc = try self.port.bwrPack(
        esc.DLControlCompact{
            .forwarding_rule = true, // destroy non-ecat frames
            .temporary_loop_control = false, // permanent settings
            .loop_control_port0 = .auto,
            .loop_control_port1 = .auto,
            .loop_control_port2 = .auto,
            .loop_control_port3 = .auto,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.dl_control),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe open all ports wkc: {}", .{wkc});

    // TODO: set IRQ mask

    // reset CRC counters
    wkc = try self.port.bwrPack(

        // a write to any one of these counters will reset them all,
        // but I am too lazt to do it any differently.
        esc.RXErrorCounter{
            .port0_frame_errors = 0,
            .port0_physical_errors = 0,
            .port1_frame_errors = 0,
            .port1_physical_errors = 0,
            .port2_frame_errors = 0,
            .port2_physical_errors = 0,
            .port3_frame_errors = 0,
            .port3_physical_errors = 0,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(
                esc.Register.rx_error_counter,
            ),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe reset crc counters wkc: {}", .{wkc});

    // reset FMMUs
    wkc = try self.port.bwrPack(
        std.mem.zeroes(esc.AllFMMUAttributes),
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(
                esc.Register.fmmu0,
            ),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe zero fmmus wkc: {}", .{wkc});

    // reset SMs
    wkc = try self.port.bwrPack(
        std.mem.zeroes(esc.AllSMAttributes),
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(
                esc.Register.sm0,
            ),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe zero sms wkc: {}", .{wkc});

    // TODO: reset DC activation
    // TODO: reset system time offsets
    // TODO: DC speedstart
    // TODO: DC filter

    // disable alias address
    wkc = try self.port.bwrPack(
        esc.DLControlEnableAliasAddress{
            .enable_alias_address = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.dl_control_enable_alias_address),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe disable alias wkc: {}", .{wkc});

    // request INIT
    wkc = try self.port.bwrPack(
        esc.ALControl{
            .state = .INIT,

            // Ack errors not required for init transition.
            // Simple subdevices will copy the ack flag directly to the
            // error flag in the AL Status register.
            // Complex devices will not.
            //
            // Ref: IEC 61158-6-12:2019 6.4.1.1
            .ack = false,
            .request_id = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.al_control),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe INIT wkc: {}", .{wkc});

    // Force take away EEPROM from PDI
    wkc = try self.port.bwrPack(
        esc.SIIAccessCompact{
            .owner = .ethercat_dl,
            .lock = true,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.sii_access),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe force eeprom wkc: {}", .{wkc});

    // Maindevice controls EEPROM
    wkc = try self.port.bwrPack(
        esc.SIIAccessCompact{
            .owner = .ethercat_dl,
            .lock = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.sii_access),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("bus wipe eeprom control to maindevice wkc: {}", .{wkc});

    // count subdevices
    const res = try self.port.brdPack(
        esc.ALStatus,
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.al_status),
        },
        self.settings.recv_timeout_us,
    );
    logger.info("detected {} subdevices", .{res.wkc});
    if (res.wkc != self.subdevices.len) {
        logger.info("Found {} subdevices, expected {}.", .{ res.wkc, self.subdevices.len });
        return error.BusConfigurationMismatch;
    }
    try self.broadcastStateChange(.INIT, change_timeout_us);
}

pub fn busPreop(self: *MainDevice, change_timeout_us: u32) !void {

    // perform IP tasks for each subdevice
    for (self.subdevices) |*subdevice| {
        try assignStationAddress(
            self.port,
            Subdevice.stationAddressFromRingPos(subdevice.runtime_info.ring_position),
            subdevice.runtime_info.ring_position,
            self.settings.recv_timeout_us,
        );
        try subdevice.transitionIP(
            self.port,
            self.settings.recv_timeout_us,
            self.settings.eeprom_timeout_us,
        );
    }

    try self.broadcastStateChange(.PREOP, change_timeout_us);
}

pub fn busSafeop(self: *MainDevice, change_timeout_us: u32) !void {
    // perform PS tasks for each subdevice
    for (self.subdevices) |*subdevice| {

        // TODO: assert non-overlapping FMMU configuration
        try subdevice.transitionPS(
            self.port,
            self.settings.recv_timeout_us,
            self.settings.eeprom_timeout_us,
            self.settings.mbx_timeout_us,
            subdevice.runtime_info.pi.inputs_area.start_addr,
            subdevice.runtime_info.pi.outputs_area.start_addr,
        );
    }

    const state_change_wkc = try self.port.bwrPack(
        esc.ALControl{
            .state = .SAFEOP,
            .ack = false,
            .request_id = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.al_control),
        },
        self.settings.recv_timeout_us,
    );
    if (state_change_wkc != self.subdevices.len) return error.Wkc;
    var timer = std.time.Timer.start() catch @panic("timer not supported");
    var result: ?CyclicResult = null;
    while (timer.read() < @as(u64, change_timeout_us) * std.time.ns_per_us) {
        result = try self.sendRecvCyclicFramesDiag();
        if (result.?.brd_status_wkc != self.subdevices.len) return error.Wkc;
        if (result.?.brd_status.state == .SAFEOP and result.?.brd_status_wkc == self.subdevices.len) break;
    } else {
        for (self.subdevices) |subdevice| {
            const status = try subdevice.getALStatus(self.port, self.settings.recv_timeout_us);
            if (status.err or status.state != .SAFEOP) {
                logger.err("station address: 0x{x} failed state transition, status: {}", .{ Subdevice.stationAddressFromRingPos(subdevice.runtime_info.ring_position), status });
            }
        }
        logger.err("Failed state transition to SAFEOP. Result: {?}", .{result});
        return error.StateChangeTimeout;
    }
    logger.warn("successful state change to SAFEOP. Result: {?}", .{result});
}

pub fn busOp(self: *MainDevice, change_timeout_us: u32) !void {
    for (self.subdevices) |*subdevice| {
        try subdevice.transitionSO(
            self.port,
            self.settings.recv_timeout_us,
        );
    }

    const state_change_wkc = try self.port.bwrPack(
        esc.ALControl{
            .state = .OP,
            .ack = false,
            .request_id = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.al_control),
        },
        self.settings.recv_timeout_us,
    );
    if (state_change_wkc != self.subdevices.len) return error.Wkc;

    var timer = std.time.Timer.start() catch @panic("timer not supported");
    var result: ?CyclicResult = null;
    while (timer.read() < @as(u64, change_timeout_us) * std.time.ns_per_us) {
        result = try self.sendRecvCyclicFramesDiag();
        // logger.info("diag: {}", .{result});
        if (result.?.brd_status_wkc != self.subdevices.len) return error.Wkc;
        if (result.?.brd_status.state == .OP and result.?.brd_status_wkc == self.subdevices.len) {
            logger.warn("successfull state change to {}, status code: {}", .{ result.?.brd_status.state, result.?.brd_status.status_code });
            break;
        }
    } else {
        for (self.subdevices) |subdevice| {
            const status = try subdevice.getALStatus(self.port, self.settings.recv_timeout_us);
            if (status.err or status.state != .OP) {
                logger.err("station address: 0x{x} failed state transition to OP, status: {}", .{ Subdevice.stationAddressFromRingPos(subdevice.runtime_info.ring_position), status });
            }
        }
        logger.err("Failed state transition to OP. Result: {?}", .{result});
        return error.StateChangeTimeout;
    }
    logger.warn("successful state change to OP. Result: {?}", .{result});
}

pub const CyclicError = error{
    RecvTimeout,
    LinkError,
    NotAllSubdevicesInOP,
    TopologyChanged,
    Wkc,
};

/// Send and attempt to receive cyclic frames, blocking up to the recv timeout.
pub fn sendRecvCyclicFrames(self: *MainDevice) CyclicError!void {
    const result = try self.sendRecvCyclicFramesDiag();
    if (result.brd_status_wkc != self.subdevices.len) return error.TopologyChanged;
    if (result.brd_status.state != .OP) return error.NotAllSubdevicesInOP;
    if (result.process_data_wkc != self.expectedProcessDataWkc()) return error.Wkc;
}

/// Send and attempt to receive cyclic frames, blocking up to the recv timeout.
/// Returnes addtional diagnostic information instead of error codes.
pub fn sendRecvCyclicFramesDiag(self: *MainDevice) error{ LinkError, RecvTimeout }!CyclicResult {
    try self.sendCyclicFrames();
    var timer = std.time.Timer.start() catch @panic("timer not supported");
    while (timer.read() < @as(u64, self.settings.recv_timeout_us) * std.time.ns_per_us) {
        return self.recvCyclicFrames() catch |err| switch (err) {
            error.RecvTimeout => continue,
            error.LinkError => return error.LinkError,
        };
    } else {
        return error.RecvTimeout;
    }
}

/// Send the cyclic frames (after OP is obtained).
pub fn sendCyclicFrames(self: *MainDevice) error{LinkError}!void {
    @memset(self.transactions.state_check_res.*[0..], 0); // TODO: figure out how to get rid of this
    self.port.releaseTransactions(self.transactions.all);
    self.transactions.idx +%= 1;
    for (self.transactions.all) |*transaction| {
        transaction.data.send_datagram.header.idx = self.transactions.idx;
        transaction.data.done = false;
    }
    try self.port.sendTransactions(self.transactions.all);
    errdefer comptime unreachable; // release transactions
    if (self.first_cycle_time == null) {
        self.first_cycle_time = std.time.Instant.now() catch @panic("Timer unsupported.");
    }
}

pub const CyclicResult = struct {
    brd_status: esc.ALStatus,
    brd_status_wkc: u16,
    process_data_wkc: u16,
};

/// Receive the cyclic frames (after OP is obtained).
/// Non-blocking.
/// You may call this more than once.
pub fn recvCyclicFrames(self: *MainDevice) error{ RecvTimeout, LinkError }!CyclicResult {
    for (0..self.transactions.all.len) |_| {
        const done = try self.port.continueTransactions(self.transactions.all);
        if (done) break;
    } else {
        return error.RecvTimeout;
    }
    return self.resultFromTransactions();
}

fn resultFromTransactions(self: *MainDevice) CyclicResult {
    for (self.transactions.all) |transaction| {
        assert(transaction.data.done);
    }

    // TODO: use individual datagram WKC's
    var process_data_wkc: u16 = 0;
    for (self.transactions.all[1..]) |*transaction| {
        process_data_wkc +%= transaction.data.recv_datagram.wkc;
    }

    const brd_status_wkc = self.transactions.all[0].data.recv_datagram.wkc;
    const al_status = wire.packFromECat(
        esc.ALStatus,
        self.transactions.state_check_res.*,
    );

    return CyclicResult{
        .brd_status = al_status,
        .brd_status_wkc = brd_status_wkc,
        .process_data_wkc = process_data_wkc,
    };
}

pub fn broadcastStateChange(self: *MainDevice, state: esc.ALStateControl, change_timeout_us: u32) !void {
    const wkc = try self.port.bwrPack(
        esc.ALControl{
            .state = state,
            // simple subdevices will copy the ack bit
            // into the AL status error bit.
            //
            // Ref: IEC 61158-6-12:2019 6.4.1.1
            .ack = false,
            .request_id = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.Register.al_control),
        },
        self.settings.recv_timeout_us,
    );
    if (wkc != self.subdevices.len) return error.Wkc;

    var timer = std.time.Timer.start() catch @panic("timer not supported");
    while (timer.read() < @as(u64, change_timeout_us) * std.time.ns_per_us) {
        const res = try self.port.brdPack(
            esc.ALStatus,
            .{
                .autoinc_address = 0,
                .offset = @intFromEnum(esc.Register.al_status),
            },
            self.settings.recv_timeout_us,
        );
        const brd_wkc = res.wkc;
        const status = res.ps;
        if (brd_wkc != self.subdevices.len) return error.Wkc;

        // we check if the actual state matches the requested
        // state before checking the error bit becuase simple subdevices
        // will just copy the ack bit to the error bit.
        //
        // Ref: IEC 61158-6-12:2019 6.4.1.1

        const requested_int: u4 = @intFromEnum(state);
        const actual_int: u4 = @intFromEnum(status.state);
        if (actual_int == requested_int) {
            logger.warn(
                "successful broadcast state change to {}, Status Code: {}.",
                .{ status.state, status.status_code },
            );
            break;
        }
        if (status.err) {
            logger.err(
                "broadcast state change refused to {}. Actual state: {}, Status Code: {}.",
                .{ state, status.state, status.status_code },
            );
            return error.StateChangeRefused;
        }
    } else {
        return error.StateChangeTimeout;
    }
}

pub fn expectedProcessDataWkc(self: *const MainDevice) u16 {
    var wkc: u16 = 0;
    for (self.subdevices) |subdevice| {
        if (subdevice.config.outputsBitLength() > 0) wkc += 2;
        if (subdevice.config.inputsBitLength() > 0) wkc += 1;
    }
    return wkc;
}

/// Assign configured station address.
pub fn assignStationAddress(port: *Port, station_address: u16, ring_position: u16, recv_timeout_us: u32) Port.SendDatagramWkcError!void {
    const autoinc_address = Subdevice.autoincAddressFromRingPos(ring_position);
    try port.apwrPackWkc(
        esc.ConfiguredStationAddress{
            .configured_station_address = station_address,
        },
        telegram.PositionAddress{
            .autoinc_address = autoinc_address,
            .offset = @intFromEnum(esc.Register.configured_station_address),
        },
        recv_timeout_us,
        1,
    );
}

test {
    std.testing.refAllDecls(@This());
}
