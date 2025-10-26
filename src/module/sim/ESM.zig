//! The EtherCAT State Machine (ESM).
//!
//! Ref: IEC 61158-6-12:2019 6.4.1.4

const std = @import("std");
const assert = std.debug.assert;

const esc = @import("../esc.zig");
const gcat = @import("../root.zig");
const logger = @import("../root.zig").logger;
const sim = @import("../sim.zig");
const Subdevice = @import("Subdevice.zig");

pub const ESM = @This();

status: esc.ALStatusRegister = .{
    .err = false,
    .id_loaded = false,
    .state = .INIT,
    .status_code = .no_error,
},
// TODO: init from ram
boot_supported: bool = false,
dc_not_accepted: bool = false,
dc_running: bool = false,
dc_supported: bool = false,
id_supported: bool = false,
local_error_code: u32 = 0,
local_error_flag: u32 = 0,
pll_running: bool = false,
safe_op_to_op_timeout_timer: u32 = 0, // TODO
dc_event_received: bool = false,
wait_for_pll_running: u32 = 0, // TODO
wd_enabled: bool = false,
ready_for_op: bool = false,
sm_event_received: bool = false,
id: u16 = 0, // TODO: this actually comes from EEPROM?

pub fn initTick(self: *ESM, phys_mem: *sim.Subdevice.PhysMem) void {
    Subdevice.writeRegister(self.status, .al_status, phys_mem);
    Subdevice.writeRegister(LocalALControlRegister{
        .ack = false,
        .request_id = false,
        .state = .INIT,
    }, .al_control, phys_mem);
}

const LocalALControlRegister = packed struct(u16) {
    state: gcat.NonExhaustive(esc.ALStateControl),
    ack: bool,
    request_id: bool,
    reserved: u10 = 0,
    comptime {
        assert(@bitSizeOf(LocalALControlRegister) == @bitSizeOf(esc.ALControlRegister));
    }

    fn state_unknown(self: LocalALControlRegister) bool {
        return switch (self.state) {
            .BOOT, .INIT, .PREOP, .SAFEOP, .OP => false,
            _ => true,
        };
    }
};

pub fn tick(self: *ESM, phys_mem: *sim.Subdevice.PhysMem) void {
    const control = Subdevice.readRegister(LocalALControlRegister, .al_control, phys_mem);
    self.status = Subdevice.readRegister(esc.ALStatusRegister, .al_status, phys_mem);
    defer Subdevice.writeRegister(self.status, .al_status, phys_mem);

    // TODO: implement ethercat state machine
    done: switch (self.status.state) {
        .INIT => {
            // 1.1
            if (self.status.err == true and control.ack == false and control.state == .INIT) {
                self.status.err = false;
                self.status.status_code = .no_error;
                self.status.state = .INIT;
                self.idInfo(control.request_id);
                break :done;
            }
            // 1.2
            if (self.status.err == true and control.ack == false and control.state != .INIT) {
                break :done;
            }
            // 2
            if ((self.status.err == false or control.ack == true) and control.state == .INIT) {
                self.status.err = false;
                self.status.status_code = .no_error;
                self.idInfo(control.request_id);
                break :done;
            }
            // 3
            if ((self.status.err == false or control.ack == true) and control.state == .PREOP and self.sm_settings_0_and_1_match()) {
                self.status.err = false;
                self.status.status_code = .no_error;
                self.status.state = .PREOP;
                self.start_mbx_handler();
                self.idInfo(control.request_id);
                break :done;
            }
            // 4
            if ((self.status.err == false or control.ack == true) and control.state == .PREOP and !self.sm_settings_0_and_1_match()) {
                self.status.id_loaded = false;
                self.status.state = .INIT;
                self.status.status_code = .invalid_mailbox_configuration_PREOP;
                self.status.err = true;
                break :done;
            }
            // 5
            if ((self.status.err == false or control.ack == true) and control.state == .BOOT and self.boot_supported and self.sm_settings_0_and_1_match()) {
                self.status.err = false;
                self.status.state = .BOOT;
                self.status.status_code = .no_error;
                self.start_mbx_handler();
                break :done;
            }
            // 6
            if ((self.status.err == false or control.ack == true) and control.state == .BOOT and self.boot_supported and !self.sm_settings_0_and_1_match()) {
                self.status.id_loaded = false;
                self.status.status_code = .invalid_mailbox_configuration_BOOT;
                self.status.err = true;
                break :done;
            }
            // 7
            if ((self.status.err == false or control.ack == true) and control.state == .BOOT and !self.boot_supported) {
                self.status.id_loaded = false;
                self.status.state = .INIT;
                self.status.status_code = .bootstrap_not_supported;
                self.status.err = true;
                break :done;
            }
            // 8
            if ((self.status.err == false or control.ack == true) and (control.state == .SAFEOP or control.state == .OP)) {
                self.status.id_loaded = false;
                self.status.state = .INIT;
                self.status.status_code = .invalid_requested_state_change;
                self.status.err = true;
                break :done;
            }
            // 9
            if ((self.status.err == false or control.ack == true) and control.state_unknown()) {
                self.status.id_loaded = false;
                self.status.state = .INIT;
                self.status.status_code = .unknown_requested_state;
                self.status.err = true;
                logger.err("unknown requested state: {}", .{control.state});
                break :done;
            }
            // 10
            // TODO: sm_chg
            break :done;
        },
        .PREOP => {},
        .SAFEOP => {},
        .OP => {},
        .BOOT => {},
        _ => unreachable, // TODO, make get rid of non-exhaustive
    }
}

// The ID Info primitive from the ethercat state machine.
// Ref: IEC 61158-6-12:2019 6.4.1.3.2
pub fn idInfo(self: *ESM, idRequested: bool) void {
    if (idRequested and self.id_supported) {
        std.log.err("TODO: implement idInfo", .{});
        self.status.status_code = @enumFromInt(self.id);
        self.status.id_loaded = true;
    } else {
        self.status.id_loaded = false;
    }
}

pub fn sm_settings_0_and_1_match(self: *ESM) bool {
    _ = self;
    std.log.warn("TODO: implement sm settings 0 and 1 match", .{});
    return true;
}

pub fn start_mbx_handler(self: *ESM) void {
    _ = self;
    std.log.warn("TODO: implement start mbx handler", .{});
}

test {
    std.testing.refAllDecls(@This());
}
