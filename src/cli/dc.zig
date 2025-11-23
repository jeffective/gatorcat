//! NOTE: Extremely Experimental
//!
//! Experiment with distributed clocks.

const std = @import("std");
const gcat = @import("gatorcat");

pub const Args = struct {
    ifname: [:0]const u8,

    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 10_000,
    init_timeout_us: u32 = 5_000_000,
    preop_timeout_us: u32 = 3_000_000,
    safeop_timeout_us: u32 = 10_000_000,
    op_timeout_us: u32 = 10_000_000,
    mbx_timeout_us: u32 = 50_000,

    cycle_time_us: ?u32 = null,

    max_recv_timeouts_before_rescan: u32 = 3,

    rt_prio: ?i32 = null,
    verbose: bool = false,
    mlockall: bool = false,

    pub const descriptions = .{
        .ifname = "Network interface to use for the bus scan. Example: eth0",
        .recv_timeout_us = "Frame receive timeout in microseconds. Example: 10000",
        .eeprom_timeout_us = "SII EEPROM timeout in microseconds. Example: 10000",
        .init_timeout_us = "State transition to init timeout in microseconds. Example: 100000",
        .preop_timeout_us = "State transition to preop timeout in microseconds. Example: 100000",
        .safeop_timeout_us = "State transition to safeop timeout in microseconds. Example: 100000",
        .op_timeout_us = "State transition to op timeout in microseconds. Example: 100000",
        .mbx_timeout_us = "Mailbox timeout in microseconds. Example: 100000",
        .cycle_time_us = "Cycle time in microseconds. Example: 10000",
        .rt_prio = "Set a real-time priority for this process. Does nothing on windows.",
        .verbose = "Enable verbose logs.",
        .mlockall = "Do mlockall syscall to prevent this process' memory from being swapped. Improves real-time performance. Only applicable to linux.",
    };
};

pub fn dc(args: Args) !void {
    _ = args;
}
