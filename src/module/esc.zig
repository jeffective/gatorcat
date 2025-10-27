const std = @import("std");
const assert = std.debug.assert;

const stdx = @import("stdx.zig");

const pdi = @import("pdi.zig");

const esc = @This();

/// Register addresses in the ethercat subdevice controller (ESC)
/// physical memory.
///
/// Ref: IEC 61158-4-12:2019
/// Ref: IEC 61158-6-12:2019
pub const Register = enum(u16) {
    dl_information = 0x0000,
    configured_station_address = 0x0010,
    configured_station_alias = 0x0012,
    dl_control = 0x0100,
    dl_control_enable_alias_address = 0x0103,
    dl_status = 0x0110,
    al_control = 0x0120,
    al_status = 0x0130,
    pdi_control = 0x0140,
    sync_configuration = 0x0150,
    external_event_mask = 0x0200,
    dl_user_event_mask = 0x0204,
    external_event = 0x0210,
    dl_user_event = 0x0220,
    rx_error_counter = 0x0300,
    addtional_counter = 0x0308,
    lost_link_counter = 0x0310,
    watchdog_divider = 0x0400,
    dls_user_watchdog = 0x0410,
    sm_watchdog = 0x420,
    sm_watchdog_status = 0x0440,
    watchdog_counter = 0x0442,
    sii_access = 0x0500,
    sii_control_status = 0x0502,
    sii_address = 0x0504,
    sii_data = 0x0508,
    mii_control_status = 0x0510,
    mii_address = 0x0512,
    mii_data = 0x0514,
    mii_access = 0x0516,
    fmmu0 = 0x0600,
    fmmu1 = 0x0610,
    fmmu2 = 0x0620,
    fmmu3 = 0x0630,
    fmmu4 = 0x0640,
    fmmu5 = 0x0650,
    fmmu6 = 0x0660,
    fmmu7 = 0x0670,
    fmmu8 = 0x0680,
    fmmu9 = 0x0690,
    fmmu10 = 0x06a0,
    fmmu11 = 0x06b0,
    fmmu12 = 0x06c0,
    fmmu13 = 0x06d0,
    fmmu14 = 0x06e0,
    fmmu15 = 0x06f0,
    sm0 = 0x0800,
    sm1 = 0x0808,
    sm2 = 0x0810,
    sm3 = 0x0818,
    sm4 = 0x0820,
    sm5 = 0x0828,
    sm6 = 0x0830,
    sm7 = 0x0838,
    sm8 = 0x0840,
    sm9 = 0x0848,
    sm10 = 0x0850,
    sm11 = 0x0858,
    sm12 = 0x0860,
    sm13 = 0x0868,
    sm14 = 0x0870,
    sm15 = 0x0878,
    dc_local_time = 0x0900,
    dc_system_time = 0x0910,
    dc_system_time_offset = 0x0920,
    dc_system_time_transmission_delay = 0x0928,
    dc_system_time_difference = 0x092c,
    dc_dls_user_parameter = 0x0980,
    dc_sync_activation = 0x0981,
    dc_sync_pulse = 0x0982,
    dc_interrupt_status = 0x098e,
    dc_cyclic_operation_start_time = 0x0990,
    dc_cycle_time = 0x09a0,
    dc_latch_trigger = 0x09a8,
    dc_latch_event = 0x09ae,
    dc_latch_value = 0x09b0,
};

pub fn getSMAddr(sm: u4) u16 {
    return @as(u16, @intFromEnum(Register.sm0)) + 8 * @as(u16, sm);
}

pub const PortDescriptor = enum(u2) {
    not_implemented = 0x00,
    not_configured,
    EBUS,
    MII_RMII,
};

/// Subdevice Information (DL Info)
///
/// The DL information registers contain type, version, and supported resources of the subdevice controller (ESC).
///
/// Ref: IEC 61158-4-12:2019 6.1.1
pub const DLInformation = packed struct {
    type: u8,
    revision: u8,
    build: u16,
    /// number of supported FMMU entities
    /// 0x01-0x10
    n_fmmu: u8,
    /// number of supported sync manager channels
    /// 0x01-0x10
    n_sm: u8,
    /// ram size in KiB, KiB= 1024B (1-60)
    ram_size_KiB: u8,
    port0: PortDescriptor,
    port1: PortDescriptor,
    port2: PortDescriptor,
    port3: PortDescriptor,
    /// this feature does not effect mappability of
    /// sm.write_event flag (mailbox_in)
    fmmu_bit_op_not_supported: bool,
    no_support_reserved_register: bool,
    dc_supported: bool,
    dc_range_64bit: bool, // true when 64 bit, else 32 bit
    low_jitter_ebus: bool,
    enhanced_link_detection_ebus: bool,
    enhanced_link_detection_mii: bool,
    fcs_errors_counted_separately: bool,
    /// refers to registers 0x0981[7:3], 0x0984
    enhanced_dc_sync_activation: bool,
    lrw_not_supported: bool,
    brw_aprw_fprw_not_supported: bool,
    /// when true:
    /// fmmu0: rxpdo, no bit mapping
    /// fmmu1: txpdo, no bit mapping
    /// fmmu2: mbx write event bit of sm1
    /// sm0: write mbx
    /// sm1: read mbx
    /// sm2: buffer for incoming data
    /// sm3: buffer for outgoing data
    special_fmmu_sm_configuration: bool,
    reserved: u4 = 0,
};

/// Station Address Register
///
/// Contains the station address of the subdevice which will be
/// set to active the FPRD, FPRW, FRMW, FPWR service in the subdevice.
///
/// Ref: IEC 61158-4-12:2019 6.1.2
pub const StationAddress = packed struct {
    /// Configured station address to be initialized
    /// by the maindevice at start up.
    configured_station_address: u16,
    /// initialized with SII word 4
    configured_station_alias: u16,
};

pub const ConfiguredStationAddress = packed struct(u16) {
    configured_station_address: u16,
};

/// Loop Control Settings
///
/// Loop control settings for the ports of a
/// subdevice as part of the DL Control register.
///
/// Ref: IEC 61158-4-12:2019 6.1.3
pub const LoopControlSettings = enum(u2) {
    /// closed at link down, open at link up
    auto = 0,
    /// loop closed at link down, open when writing 101 after link up,
    /// or after receiving a valid ethernet frame at closed port
    auto_close,
    always_open,
    always_closed,
};

/// DL Control Register
///
/// The DL control register is used to control the operation of the DP ports of the subdevice controller by
/// the maindevice.
///
/// Ref: IEC 61158-4-12:2019 6.1.3
pub const DLControl = packed struct {
    /// false:
    /// - ethercat farmes are processed.
    /// - non-ethercat frames are forwarded unmodified.
    ///
    /// true:
    /// - non-ethercat frames are destroyed.
    forwarding_rule: bool,
    /// false:
    /// - loop control settings are permanent
    /// true:
    /// - loop contorl settings are temporary (approx. 1 second)
    temporary_loop_control: bool,
    reserved: u6 = 0,
    loop_control_port0: LoopControlSettings,
    loop_control_port1: LoopControlSettings,
    loop_control_port2: LoopControlSettings,
    loop_control_port3: LoopControlSettings,
    transmit_buffer_size: u3,
    low_jitter_ebus_active: bool,
    _reserved2: u4 = 0,
    enable_alias_address: bool,
    _reserved3: u7 = 0,
};

/// See DLControlRegister.
///
/// Smaller version of the DL Control Register with fewer settings.
///
/// Ref: IEC 61158-4-12:2019 6.1.3
pub const DLControlCompact = packed struct {
    forwarding_rule: bool,
    temporary_loop_control: bool,
    _reserved: u6 = 0,
    loop_control_port0: LoopControlSettings,
    loop_control_port1: LoopControlSettings,
    loop_control_port2: LoopControlSettings,
    loop_control_port3: LoopControlSettings,
};

/// Just the enable alias address bit of the DL Control Register.
///
/// Ref: IEC 61158-4-12:2019 6.1.3
pub const DLControlEnableAliasAddress = packed struct(u8) {
    enable_alias_address: bool,
    _reserved: u7 = 0,
};

/// DL Status Register
///
/// The DL Status register is used to indicate the state of the DL ports and state
/// of the interface between the DL-user and the DL.
///
/// Ref: IEC 61158-4-12:2019 6.1.4
pub const DLStatus = packed struct {
    dls_user_operational: bool,
    dls_user_watchdog_ok: bool,
    extended_link_detection: bool,
    _reserved: u1 = 0,

    port0_physical_link: bool,
    port1_physical_link: bool,
    port2_physical_link: bool,
    port3_physical_link: bool,

    port0_loop_active: bool,
    port0_rx_signal_detected: bool,

    port1_loop_active: bool,
    port1_rx_signal_detected: bool,

    port2_loop_active: bool,
    port2_rx_signal_detected: bool,

    port3_loop_active: bool,
    port3_rx_signal_detected: bool,
};

pub const ALStateControl = enum(u4) {
    INIT = 1,
    PREOP = 2,
    BOOT = 3,
    SAFEOP = 4,
    OP = 8,
};

/// AL Control Register
///
/// Also called DLS-user R1, R2
///
/// Ref: IEC 61158-4-12:2019 6.1.5.4
/// Ref: IEC 61158-6-12:2019 5.3.1
pub const ALControl = packed struct(u16) {
    state: ALStateControl,
    ack: bool,
    request_id: bool,
    _reserved: u10 = 0,
};

/// AL Status Codes
///
/// Ref: IEC 61158-6-12:2019 5.3.2
pub const ALStatusCode = enum(u16) {
    no_error = 0x0000,
    unspecified_error = 0x0001,
    no_memory = 0x0002,
    invalid_device_setup = 0x0003,
    _reserved = 0x0005,
    invalid_requested_state_change = 0x0011,
    unknown_requested_state = 0x0012,
    bootstrap_not_supported = 0x0013,
    no_valid_firmware = 0x0014,
    invalid_mailbox_configuration_BOOT = 0x0015,
    invalid_mailbox_configuration_PREOP = 0x0016,
    invalid_sync_manager_configuration = 0x0017,
    no_valid_inputs_available = 0x0018,
    no_valid_outputs = 0x0019,
    synchronization_error = 0x001A,
    sync_mandager_watchdog = 0x001B,
    invalid_sync_manager_types = 0x001C,
    invalid_output_configiration = 0x001D,
    invalid_input_configuration = 0x001E,
    invalid_watchdog_configuration = 0x001F,
    need_cold_start = 0x0020,
    need_INIT = 0x0021,
    need_PREOP = 0x0022,
    need_SAFEOP = 0x0023,
    invalid_input_mapping = 0x0024,
    invalid_output_mapping = 0x0025,
    inconsistent_settings = 0x0026,
    freerun_not_supported = 0x0027,
    syncmode_not_support = 0x0028,
    freerun_needs_3buffer_bode = 0x0029,
    background_watchdog = 0x002A,
    no_valid_inputs_and_outputs = 0x002B,
    fatal_sync_error = 0x002C,
    no_sync_error = 0x002D,
    invalid_DC_SYNC_configuration = 0x0030,
    invalid_DC_latch_configuration = 0x0031,
    PLL_error = 0x0032,
    DC_sync_IO_error = 0x0033,
    DC_sync_timeout = 0x0034,
    DC_invalid_sync_cycle_time = 0x0035,
    DC_sync0_cycle_time = 0x0036,
    DC_sync1_cycle_time = 0x0037,
    MBX_AOE = 0x0041,
    MBX_EOE = 0x0042,
    MBX_COE = 0x0043,
    MBX_FOE = 0x0044,
    MBX_SOE = 0x0045,
    MBX_VOE = 0x004F,
    EEPROM_no_access = 0x0050,
    restarted_locally = 0x0060,
    device_identification_value_updated = 0x0061,
    // 0x0062..0x00EF reserved
    application_controller_available = 0x00F0,
    // < 0x8000 other codes
    // 0x8000..0xFFFF vendor sepcific
    _,
};

pub const ALStateStatus = enum(u4) {
    INIT = 1,
    PREOP = 2,
    BOOT = 3,
    SAFEOP = 4,
    OP = 8,
    _,
};

/// AL Status Register
///
/// Also called DLS-user R3, R4, R5, R6
///
/// Ref: IEC 61158-4-12:2019 6.1.5.4
/// Ref: IEC 61158-6-12:2019 5.3.2
pub const ALStatus = packed struct(u48) {
    state: ALStateStatus, // R3
    err: bool,
    id_loaded: bool,
    _reserved: u2 = 0,
    _reserved2: u8 = 0, // R4
    _reserved3: u16 = 0, // R5,
    status_code: ALStatusCode, // R6
};

/// PDI Control Register
///
/// Also called DLS-user R7, Copy, R9
///
/// RefL IEC 61158-4-12:2019 6.1.5.4
/// Ref: IEC 61158-6-12:2019 5.3.4
pub const PDIControl = packed struct(u16) {
    PDI_type: u8,
    emulated: bool,
    _reserved: u7 = 0,
};

/// Sync Configuration Register
///
/// Also called DLS-user R8
///
/// NOTE: spec is ambiguous as to where in R8 this is.
/// R8 has size u32 but only u8 is defined.
/// Assuming u8 is at beginning of register.
///
/// Ref: IEC 61158-4-12:2019 6.1.5.4
/// Ref: IEC 61158-6-12:2019 5.3.4
pub const SyncConfiguration = packed struct(u8) {
    signal_conditioning_sync0: u2,
    enable_sync0: bool,
    enable_interrupt_sync0: bool,
    signal_conditioning_sync1: u2,
    enable_sync1: bool,
    enable_interrupt_sync1: bool,
};

/// DL-User Event Register
///
/// The event registers are used to indicate and event to the DL-user.
/// The event shall be acknoledged of the corresponding event source is read.
/// The events can be masked.
///
/// Ref: IEC 61158-4-12:2019 6.1.6
pub const DLUserEvent = packed struct(u32) {
    /// event active R1 was written
    /// true on write by maindevice
    /// reset on read by subdevice
    al_control_change: bool,
    dc0: bool,
    dc1: bool,
    dc2: bool,
    sm_channel_change: bool,
    eeprom_emulation_command_pending: bool,
    dle_specific: u2,
    sm0: bool,
    sm1: bool,
    sm2: bool,
    sm3: bool,
    sm4: bool,
    sm5: bool,
    sm6: bool,
    sm7: bool,
    sm8: bool,
    sm9: bool,
    sm10: bool,
    sm11: bool,
    sm12: bool,
    sm13: bool,
    sm14: bool,
    sm15: bool,
    dle_specific2: u8,
};

/// DL User Event Mask
///
/// Ref: IEC 61158-4-12:2019 6.1.6
pub const DLUserEventMask = packed struct(u32) {
    event_mask: u32,
};

/// External Event Register
///
/// The External Event register is mapped to IRQ parameters of all EtherCAT PDUs
/// accessing this subdevice. If an event is set and the associated mask is set
/// the corresponding bit in the IRQ parameter of a PDU is set.
///
/// Ref: IEC 61158-4-12:2019 6.1.6
pub const ExternalEvent = packed struct {
    dc0: bool,
    _reserved: u1 = 0,
    dl_status_change: bool,
    al_status_change: bool,
    sm0: bool,
    sm1: bool,
    sm2: bool,
    sm3: bool,
    sm4: bool,
    sm5: bool,
    sm6: bool,
    sm7: bool,
    _reserved2: u4 = 0,
};

/// External Event Mask Register
///
/// The event mask determines what events are placed in the IRQ
/// portion of all datagrams that pass through the subdevice.
///
/// Ref: IEC 61158-4-12:2019 6.1.6
pub const ExternalEventMask = packed struct {
    event_mask: u16,
};

/// RX Error Counter Register
///
/// The RX error counter registers contain information about the physical layer
/// errors, like length or FCS. All counters are cleared if one is written.
/// The counting is stopped for each counter once the counter reaches the maximum
/// value of 255.
///
/// Ref: IEC 61158-4-12:2019 6.2.1
pub const RXErrorCounter = packed struct {
    port0_frame_errors: u8,
    port0_physical_errors: u8,
    port1_frame_errors: u8,
    port1_physical_errors: u8,
    port2_frame_errors: u8,
    port2_physical_errors: u8,
    port3_frame_errors: u8,
    port3_physical_errors: u8,
};

/// Lost Link Counter Register
///
/// The lost link counter register is an optional register to record the occurances
/// of link down. Writing to a single counter will clear all counters.
/// Each counter is stopped if the counter reaches the maximum of 255.
///
/// Ref: IEC 61158-4-12:2019 6.2.2
pub const LostLinkCounter = packed struct {
    port0: u8,
    port1: u8,
    port2: u8,
    port3: u8,
};

/// Additional Counter Register
///
/// The optional previous counter registers indicate a problem in the predecessor links.
/// Writing to one of the previous error counters will reset all the previous error counters.
/// Each previous error counter is stopped once it reaches the maximum value of 255.
///
/// The optional malformed EtherCAT frame counter counts malformed EtherCAT frames,
/// i.e. wrong datagram structure. The counter will be cleared when written. The counting is
/// stopped when the maximum value of 255 is reached.
///
/// The optional local counter counts occurances of local problems (problems within the subdevice). The counter is cleared when written.
/// The counter stops when the maximum value of 255 is reached.
pub const AdditionalCounter = packed struct {
    port0_prev_errors: u8,
    port1_prev_errors: u8,
    port2_prev_errors: u8,
    port3_prev_errors: u8,
    malformed_frames: u8,
    local_problems: u8,
};

/// Watchdog Divider Register
///
/// The system clock of the subdevice is divided by the watchdog divider.
///
/// The parameter shall contain the number of 40 ns intervals (minus 2)
/// that represents the basic watchdog increment (default value is 100 us = 2498).
///
/// Ref: IEC 61158-4-12:2019 6.3.1
pub const WatchdogDivider = packed struct {
    watchdog_divider: u16,
};

/// DLS User Watchdog Register
///
/// Also called the PDI watchdog.
///
/// Each access of the DLS-user to the subdevice controller shall reset this watchdog.
///
/// This parameter shall contain the watchdog to monitor the DLS-user.
/// Default value 1000 with watchdog divider 100 us means 100 ms watchdog.
///
/// Ref: IEC 61158-4-12:2019 6.3.2
pub const DLSUserWatchdog = packed struct {
    dls_user_watchdog: u16,
};

/// Sync Manager Watchdog Register
///
/// Each write access of the DL-user memory area configured
/// in the Sync manager shall reset the watchdog if the watchdog
/// option is enabled by this sync manager.
///
/// Ref: IEC 61158-4-12:2019 6.3.3
pub const SyncMangagerWatchdog = packed struct {
    sync_manager_watchdog: u16,
};

/// Sync Manager Watchdog Status Register
///
/// The status of the sync manager watchdog.
///
/// Ref: IEC 61158-4-12:2019 6.3.3
pub const SyncManagerWatchDogStatus = packed struct {
    watchdog_ok: bool,
    _reserved: u15 = 0,
};

/// Watchdog Counter Register
///
/// Optional register to count the occurances of expirations of watchdogs.
///
/// Writes will reset all watchdog counters.
///
/// Ref: IEC 61158-4-12:2019 6.3.5
pub const WatchdogCounter = packed struct {
    sm_watchdog_counter: u8,
    dl_user_watchdog_counter: u8,
};

pub const SIIAccessOwner = enum(u1) {
    ethercat_dl = 0,
    pdi = 1,
};

/// Subdevice Information Interface (SII) Access Register
///
/// Ref: IEC 61158-4-12:2019 6.4.2
pub const SIIAccess = packed struct {
    owner: SIIAccessOwner,
    lock: bool,
    _reserved: u6 = 0,
    access_pdi: bool,
    _reserved2: u7 = 0,
};

pub const SIIAccessCompact = packed struct(u8) {
    owner: SIIAccessOwner,
    lock: bool,
    _reserved: u6 = 0,
};

pub const SIIReadSize = enum(u1) {
    four_bytes = 0,
    eight_bytes = 1,
};

pub const SIIAddressAlgorithm = enum(u1) {
    one_byte_address = 0,
    two_byte_address = 1,
};

/// SII Control / Status Register
///
/// Read and write operations to the SII is controlled via this register.
///
/// Ref: IEC 61158-4-12:2019 6.4.3
pub const SIIControlStatus = packed struct {
    write_access: bool,
    _reserved: u4 = 0,
    eeprom_emulation: bool,
    read_size: SIIReadSize,
    address_algorithm: SIIAddressAlgorithm,
    read_operation: bool,
    write_operation: bool,
    reload_operation: bool,
    checksum_error: bool,
    device_info_error: bool,
    command_error: bool,
    write_error: bool,
    busy: bool,
};

pub const SIIControlStatusAddress = packed struct {
    write_access: bool,
    _reserved: u4 = 0,
    eeprom_emulation: bool,
    read_size: SIIReadSize,
    address_algorithm: SIIAddressAlgorithm,
    read_operation: bool,
    write_operation: bool,
    reload_operation: bool,
    checksum_error: bool,
    device_info_error: bool,
    command_error: bool,
    write_error: bool,
    busy: bool,
    sii_address: u16,
};

/// SII Address Register
///
/// The SII Address register contains the address for the
/// next read / write operation triggered by the SII control status
/// register.
///
/// The register is 32 bits wide but only the lower
/// 16 bits (address 0x0504-0x0505) will be used.
///
/// Ref: IEC 61158-4-12:2019 6.4.4
pub const SIIAddress = packed struct {
    sii_address: u16,
    unused: u16 = 0,
};

// TODO: figure out how SII data register accesses 64 bit data?

/// SII Data Register
///
/// The SII Data register contains the data (16 bit) to be written
/// in the SII for the next write operation or the read data 32 bit/64 bit
/// for the last read operation.
///
/// For the write operation, only the lower 16 bits
/// is used.
///
/// Ref: IEC 61158-4-12:2019 6.4.5
pub const SIIDataRegister4Byte = packed struct {
    data: u32,
};

pub const SIIDataRegister8Byte = packed struct {
    data: u64,
};

/// MII Control / Status Register
///
/// Ref: IEC 61158-4-12 6.5.1
pub const MIIControlStatus = packed struct {
    write_access: bool,
    access_pdi: bool,
    mii_link_det: bool,
    phy_offset: u5 = 0x00,
    read_operation: bool,
    write_operation: bool,
    _reserved: u3 = 0x00,
    read_error: bool,
    write_error: bool,
    busy: bool,
};

/// MII Address Register
///
/// Ref: IEC 61158-4-12:2019 6.5.2
pub const MIIAddress = packed struct {
    /// address of the PHY (0-63)
    phy_address: u8,
    /// PHY register address
    phy_register_address: u8,
};

/// MII Data Register
///
/// The MII data register contains the data to be written for the next
/// write operation or the read data from the MII from the last
/// read operation.
///
/// Ref: IEC 61158-4-12:2019 6.5.3
pub const MIIData = packed struct {
    data: u16,
};

pub const MIIAccessState = enum(u1) {
    ecat_access_active = 0,
    pdi_access_active = 1,
};

/// MII Access Register
///
/// The MII Access register manages the MII access.
///
/// Ref: IEC 61158-4-12:2019 6.5.4
pub const MIIAccess = packed struct {
    mii_access: bool,
    _reserved: u7 = 0,
    access_state: MIIAccessState,
    access_reset: bool,
    _reserved2: u6 = 0,
};

/// FMMU Attributes
///
/// Ref: IEC 61158-4-12:2019 6.6.2
pub const FMMUAttributes = packed struct(u128) {
    logical_start_address: u32,
    length: u16,
    logical_start_bit: u3,
    _reserved: u5 = 0,
    logical_end_bit: u3,
    _reserved2: u5 = 0,
    physical_start_address: u16,
    physical_start_bit: u3,
    _reserved3: u5 = 0,
    /// process data inputs (physical memory is source, logical is destination)
    read_enable: bool,
    /// process data outputs (physical memory is destination, logical is source)
    write_enable: bool,
    _reserved4: u6 = 0,
    enable: bool,
    _reserved5: u7 = 0,
    _reserved6: u24 = 0,

    pub fn init(
        direction: esc.SyncManagerDirection,
        logical_start_address: u32,
        logical_start_bit: u3,
        bit_length: u32,
        physical_start_address: u16,
        physical_start_bit: u3,
    ) FMMUAttributes {
        assert(bit_length > 0);
        var res = FMMUAttributes{
            .logical_start_address = logical_start_address,
            .length = 1,
            .logical_start_bit = logical_start_bit,
            .physical_start_address = physical_start_address,
            .physical_start_bit = physical_start_bit,
            .logical_end_bit = logical_start_bit,
            .write_enable = switch (direction) {
                .input => false,
                .output => true,
            },
            .read_enable = switch (direction) {
                .input => true,
                .output => false,
            },
            .enable = true,
        };
        res.addBits(bit_length - 1); // first bit already specified
        assert(res.isValid());
        return res;
    }

    /// given an FMMU, init an FMMU next to it.
    pub fn initNeighbor(
        self: *const FMMUAttributes,
        direction: esc.SyncManagerDirection,
        physical_start_address: u16,
        physical_start_bit: u3,
        bit_length: u32,
    ) FMMUAttributes {
        assert(bit_length != 0);
        var res = FMMUAttributes.init(
            direction,
            self.logical_start_address,
            self.logical_start_bit,
            1,
            physical_start_address,
            physical_start_bit,
        );
        res.shiftLogicalBits(self.bitLength());
        res.addBits(bit_length - 1);
        return res;
    }

    /// move the FMMU to the right the given number of bits
    pub fn shiftLogicalBits(self: *FMMUAttributes, n_bits: u32) void {
        assert(self.isValid());
        const old_bit_length = self.bitLength();
        var n_bits_remaining = n_bits;
        // TODO: optimize!!!
        while (n_bits_remaining > 0) {
            if (self.logical_start_bit != 7) {
                self.logical_start_bit += 1;
                n_bits_remaining -= 1;
                continue;
            } else {
                self.logical_start_bit = 0;
                n_bits_remaining -= 1;
                self.logical_start_address += 1;
                continue;
            }
        }
        self.logical_end_bit = self.logical_start_bit;
        self.addBits(old_bit_length - 1);
        assert(self.bitLength() == old_bit_length);
        assert(self.isValid());
    }

    pub fn bitLength(self: FMMUAttributes) u32 {
        return esc.bitLength(self.length, self.logical_start_bit, self.logical_end_bit);
    }

    pub fn addBits(self: *FMMUAttributes, n_bits: u32) void {
        const old_bit_length = self.bitLength();
        var n_bits_remaining = n_bits;
        // TODO: optimize!!!
        while (n_bits_remaining > 0) {
            if (self.logical_end_bit != 7) {
                self.logical_end_bit += 1;
                n_bits_remaining -= 1;
                continue;
            } else {
                self.logical_end_bit = 0;
                n_bits_remaining -= 1;
                self.length += 1;
                continue;
            }
        }
        assert(self.bitLength() == old_bit_length + n_bits);
        assert(self.isValid());
    }

    pub fn isValid(self: *const FMMUAttributes) bool {
        if (self.length == 0) return false;
        if (self.length == 1 and self.logical_start_bit > self.logical_end_bit) return false;
        if (self.read_enable and self.write_enable) return false;
        if (!self.enable) return false;
        if (self.bitLength() == 0) return false;
        return true;
    }
};

/// bit length (primarily for FMMUs)
///
/// Ref: IEC 61158-4-12 6.6.1
pub fn bitLength(octets: u16, start_bit: u3, end_bit: u3) u32 {
    assert(octets != 0);
    if (octets == 1) {
        assert(start_bit <= end_bit);
    }
    return 8 * @as(u32, octets) - start_bit - (@as(u32, 7) - end_bit);
}

test "FMMUAttributes bitLength" {
    // Ref: IEC 61158-4-12 6.6.1
    try std.testing.expectEqual(@as(u32, 6), bitLength(2, 3, 0));
    try std.testing.expectEqual(@as(u32, 6), bitLength(1, 1, 6));
    // ours
    try std.testing.expectEqual(@as(u32, 1), bitLength(1, 0, 0));
    try std.testing.expectEqual(@as(u32, 2), bitLength(1, 0, 1));
    try std.testing.expectEqual(@as(u32, 3), bitLength(1, 0, 2));
    try std.testing.expectEqual(@as(u32, 4), bitLength(1, 0, 3));
    try std.testing.expectEqual(@as(u32, 5), bitLength(1, 0, 4));
    try std.testing.expectEqual(@as(u32, 6), bitLength(1, 0, 5));
    try std.testing.expectEqual(@as(u32, 7), bitLength(1, 0, 6));
    try std.testing.expectEqual(@as(u32, 8), bitLength(1, 0, 7));

    try std.testing.expectEqual(@as(u32, 9), bitLength(2, 0, 0));
    try std.testing.expectEqual(@as(u32, 10), bitLength(2, 0, 1));
    try std.testing.expectEqual(@as(u32, 11), bitLength(2, 0, 2));
    try std.testing.expectEqual(@as(u32, 12), bitLength(2, 0, 3));
    try std.testing.expectEqual(@as(u32, 13), bitLength(2, 0, 4));
    try std.testing.expectEqual(@as(u32, 14), bitLength(2, 0, 5));
    try std.testing.expectEqual(@as(u32, 15), bitLength(2, 0, 6));
    try std.testing.expectEqual(@as(u32, 16), bitLength(2, 0, 7));

    try std.testing.expectEqual(@as(u32, 9), bitLength(2, 1, 1));
    try std.testing.expectEqual(@as(u32, 9), bitLength(2, 2, 2));
    try std.testing.expectEqual(@as(u32, 9), bitLength(2, 7, 7));

    try std.testing.expectEqual(@as(u32, 13), bitLength(2, 1, 5));
    try std.testing.expectEqual(@as(u32, 13), bitLength(2, 0, 4));
    try std.testing.expectEqual(@as(u32, 13), bitLength(3, 7, 3));
}

test "FMMUAttributes addBits" {
    var attr = FMMUAttributes{
        .logical_start_address = 0,
        .physical_start_bit = 2,
        .logical_start_bit = 2,
        .length = 2,
        .read_enable = true,
        .write_enable = false,
        .enable = true,
        .physical_start_address = 12,
        .logical_end_bit = 1,
    };
    try std.testing.expectEqual(@as(u32, 8), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 9), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 10), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 11), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 12), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 13), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 14), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 15), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 16), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 17), attr.bitLength());
    attr.addBits(1);
    try std.testing.expectEqual(@as(u32, 18), attr.bitLength());
    attr.addBits(35);
    try std.testing.expectEqual(@as(u32, 18 + 35), attr.bitLength());
    attr.addBits(64);
    try std.testing.expectEqual(@as(u32, 18 + 35 + 64), attr.bitLength());
    attr.addBits(13);
    try std.testing.expectEqual(@as(u32, 18 + 35 + 64 + 13), attr.bitLength());
}

/// The maximum number of FMMUs is 16.
///
/// Ref: IEC 61158-4-12:2019 6.6.2
pub const max_fmmu = 16;

pub const FMMUArray = stdx.BoundedArray(FMMUAttributes, max_fmmu);

/// FMMU Register
///
/// The FMMU register contains the settings for the FMMU entities.
///
/// Ref: IEC 61158-4-12:2019 6.6.2
pub const AllFMMUAttributes = packed struct {
    fmmu0: FMMUAttributes,
    fmmu1: FMMUAttributes,
    fmmu2: FMMUAttributes,
    fmmu3: FMMUAttributes,
    fmmu4: FMMUAttributes,
    fmmu5: FMMUAttributes,
    fmmu6: FMMUAttributes,
    fmmu7: FMMUAttributes,
    fmmu8: FMMUAttributes,
    fmmu9: FMMUAttributes,
    fmmu10: FMMUAttributes,
    fmmu11: FMMUAttributes,
    fmmu12: FMMUAttributes,
    fmmu13: FMMUAttributes,
    fmmu14: FMMUAttributes,
    fmmu15: FMMUAttributes,

    pub fn writeFMMUConfig(self: *AllFMMUAttributes, config: FMMUAttributes, fmmu_idx: u4) void {
        switch (fmmu_idx) {
            0 => self.fmmu0 = config,
            1 => self.fmmu1 = config,
            2 => self.fmmu2 = config,
            3 => self.fmmu3 = config,
            4 => self.fmmu4 = config,
            5 => self.fmmu5 = config,
            6 => self.fmmu6 = config,
            7 => self.fmmu7 = config,
            8 => self.fmmu8 = config,
            9 => self.fmmu9 = config,
            10 => self.fmmu10 = config,
            11 => self.fmmu11 = config,
            12 => self.fmmu12 = config,
            13 => self.fmmu13 = config,
            14 => self.fmmu14 = config,
            15 => self.fmmu15 = config,
        }
    }
};

pub const SyncManagerBufferType = enum(u2) {
    buffered = 0x00,
    mailbox = 0x02,
};

/// Ref: IEC 61158-4-12:2019 6.7.2
pub const SyncManagerDirection = enum(u2) {
    /// read by maindevice
    input = 0x00,
    /// written by maindevice
    output = 0x01,
};

pub const SyncMangagerBufferedState = enum(u2) {
    first_buffer = 0x00,
    second_buffer = 0x01,
    third_buffer = 0x02,
    buffer_locked = 0x03,
};

pub const SyncManagerControl = packed struct(u8) {
    buffer_type: SyncManagerBufferType,
    direction: SyncManagerDirection,
    ecat_event_enable: bool,
    dls_user_event_enable: bool,
    watchdog_enable: bool,
    reserved: u1 = 0,
};

pub const SyncManagerStatus = packed struct(u8) {
    write_event: bool,
    read_event: bool,
    reserved2: u1 = 0,
    mailbox_full: bool,
    buffered_state: SyncMangagerBufferedState,
    read_buffer_open: bool,
    write_buffer_open: bool,
};
pub const SyncManagerActivate = packed struct(u8) {
    channel_enable: bool,
    repeat: bool,
    reserved3: u4 = 0,
    dc_event_0_bus_access: bool,
    dc_event_0_local_access: bool,
};

/// Sync Manager Attributes (Channels)
///
/// Configuration of a single sync manager.
///
/// Ref: IEC 61158-4-12:2019 6.7.2
pub const SyncManagerAttributes = packed struct(u64) {
    physical_start_address: u16,
    length: u16,
    control: SyncManagerControl,
    status: SyncManagerStatus,
    activate: SyncManagerActivate,
    channel_enable_pdi: bool,
    repeat_ack: bool,
    reserved: u6 = 0,

    /// SM0 should be used for mailbox out.
    ///
    /// Ref: Ethercat Device Protocol Poster
    ///
    /// SOEM uses 0x00010026 for the
    pub fn mbxOutDefaults(
        physical_start_address: u16,
        length: u16,
    ) SyncManagerAttributes {
        return SyncManagerAttributes{
            .physical_start_address = physical_start_address,
            .length = length,
            // SOEM uses 0x26 (0b00100110) for the control byte
            .control = .{
                .buffer_type = .mailbox,
                .direction = .output,
                .ecat_event_enable = false,
                .dls_user_event_enable = true,
                .watchdog_enable = false,
            },
            // SOEM uses 0x00 for the status byte
            .status = @bitCast(@as(u8, 0)),
            // SOEM uses 0x01 for the activate byte
            .activate = .{
                .channel_enable = true,
                .repeat = false,
                .dc_event_0_bus_access = false,
                .dc_event_0_local_access = false,
            },
            // SOEM uses 0x00 for the remaining
            .channel_enable_pdi = false,
            .repeat_ack = false,
        };
    }

    /// SM1 should be used for mailbox in.
    ///
    /// Ref: EtherCAT Device Protocol Poster.
    pub fn mbxInDefaults(
        physical_start_address: u16,
        length: u16,
    ) SyncManagerAttributes {
        return SyncManagerAttributes{
            .physical_start_address = physical_start_address,
            .length = length,
            .control = .{
                .buffer_type = .mailbox,
                .direction = .input,
                .ecat_event_enable = false,
                .dls_user_event_enable = true,
                .watchdog_enable = false,
            },
            .status = @bitCast(@as(u8, 0)),
            .activate = .{
                .channel_enable = true,
                .repeat = false,
                .dc_event_0_bus_access = false,
                .dc_event_0_local_access = false,
            },
            .channel_enable_pdi = false,
            .repeat_ack = false,
        };
    }
};

/// Sync Manager Register
///
/// Configuration of the sync manager channels.
///
/// The sync managers shall be used the following way:
/// SM0: mailbox write
/// SM1: mailbox read
/// SM2: process data write (may be used for read if write not supported)
/// SM3: process data read
///
/// If mailbox is not supported:
/// SM0: process data write (may be used for read if write not supported)
/// SM1: process data read
///
/// Ref: 61158-4-12:2019 6.7.2
/// The specification only mentions the first 16 sync managers.
/// But the CoE specification shows up to 32.
/// TODO: how many sync managers are there???
pub const AllSMAttributes = packed struct(u2048) {
    sm0: SyncManagerAttributes,
    sm1: SyncManagerAttributes,
    sm2: SyncManagerAttributes,
    sm3: SyncManagerAttributes,
    sm4: SyncManagerAttributes,
    sm5: SyncManagerAttributes,
    sm6: SyncManagerAttributes,
    sm7: SyncManagerAttributes,
    sm8: SyncManagerAttributes,
    sm9: SyncManagerAttributes,
    sm10: SyncManagerAttributes,
    sm11: SyncManagerAttributes,
    sm12: SyncManagerAttributes,
    sm13: SyncManagerAttributes,
    sm14: SyncManagerAttributes,
    sm15: SyncManagerAttributes,
    sm16: SyncManagerAttributes,
    sm17: SyncManagerAttributes,
    sm18: SyncManagerAttributes,
    sm19: SyncManagerAttributes,
    sm20: SyncManagerAttributes,
    sm21: SyncManagerAttributes,
    sm22: SyncManagerAttributes,
    sm23: SyncManagerAttributes,
    sm24: SyncManagerAttributes,
    sm25: SyncManagerAttributes,
    sm26: SyncManagerAttributes,
    sm27: SyncManagerAttributes,
    sm28: SyncManagerAttributes,
    sm29: SyncManagerAttributes,
    sm30: SyncManagerAttributes,
    sm31: SyncManagerAttributes,

    pub fn asArray(self: AllSMAttributes) [32]SyncManagerAttributes {
        var res: [32]SyncManagerAttributes = undefined;
        res[0] = self.sm0;
        res[1] = self.sm1;
        res[2] = self.sm2;
        res[3] = self.sm3;
        res[4] = self.sm4;
        res[5] = self.sm5;
        res[6] = self.sm6;
        res[7] = self.sm7;
        res[8] = self.sm8;
        res[9] = self.sm9;
        res[10] = self.sm10;
        res[11] = self.sm11;
        res[12] = self.sm12;
        res[13] = self.sm13;
        res[14] = self.sm14;
        res[15] = self.sm15;
        res[16] = self.sm16;
        res[17] = self.sm17;
        res[18] = self.sm18;
        res[19] = self.sm19;
        res[20] = self.sm20;
        res[21] = self.sm21;
        res[22] = self.sm22;
        res[23] = self.sm23;
        res[24] = self.sm24;
        res[25] = self.sm25;
        res[26] = self.sm26;
        res[27] = self.sm27;
        res[28] = self.sm28;
        res[29] = self.sm29;
        res[30] = self.sm30;
        res[31] = self.sm31;
        return res;
    }

    pub fn set(self: AllSMAttributes, i: usize, sm: SyncManagerAttributes) void {
        assert(i < 32);
        if (i == 0) self.sm0 = sm;
        if (i == 1) self.sm1 = sm;
        if (i == 2) self.sm2 = sm;
        if (i == 3) self.sm3 = sm;
        if (i == 4) self.sm4 = sm;
        if (i == 5) self.sm5 = sm;
        if (i == 6) self.sm6 = sm;
        if (i == 7) self.sm7 = sm;
        if (i == 8) self.sm8 = sm;
        if (i == 9) self.sm9 = sm;
        if (i == 10) self.sm10 = sm;
        if (i == 11) self.sm11 = sm;
        if (i == 12) self.sm12 = sm;
        if (i == 13) self.sm13 = sm;
        if (i == 14) self.sm14 = sm;
        if (i == 15) self.sm15 = sm;
        if (i == 16) self.sm16 = sm;
        if (i == 17) self.sm17 = sm;
        if (i == 18) self.sm18 = sm;
        if (i == 19) self.sm19 = sm;
        if (i == 20) self.sm20 = sm;
        if (i == 21) self.sm21 = sm;
        if (i == 22) self.sm22 = sm;
        if (i == 23) self.sm23 = sm;
        if (i == 24) self.sm24 = sm;
        if (i == 25) self.sm25 = sm;
        if (i == 26) self.sm26 = sm;
        if (i == 27) self.sm27 = sm;
        if (i == 28) self.sm28 = sm;
        if (i == 29) self.sm29 = sm;
        if (i == 30) self.sm30 = sm;
        if (i == 31) self.sm31 = sm;
    }
};

// TODO: verify representation of sys time difference

/// DC Local Time Parameters
///
/// Delay measurement required single-frame time-stamping.
/// The subdevice provides a means of timestamping the arrival time
/// at its various ports for a single frame.
///
/// The maindevice is expected to assemble this time-stamping
/// information and the known topology of the network
/// to measure propagation delays.
///
/// A write access to the port0_recv_time_ns field triggers
/// the subdevice timestamping.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
pub const DCLocalTime = packed struct {
    port0_recv_time_ns: u32,
    port1_recv_time_ns: u32,
    port2_recv_time_ns: u32,
    port3_recv_time_ns: u32,
    sys_time_ns: u64,
    proc_unit_recv_time_ns: u64,
    sys_time_offset_ns: u64,
    sys_time_transmission_delay_ns: u32,
    sys_time_diff_ns: i32,
    ctrl_loop_p1: u16,
    ctrl_loop_p2: u16,
    ctrl_loop_p3: u16,
};

/// DC Sync Activation Register
///
/// Also called DC User P1.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCSyncActivation = packed struct(u8) {
    enable_cylic_operation: bool,
    sync0_generate: bool,
    sync1_generate: bool,
    reserved: u5 = 0,
};

/// DC Sync Pulse Register
///
/// Taken from SII.
///
/// Also called DC User P2.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCSyncPulse = packed struct(u16) {
    sync_pulse: u16,
};

/// DC Interrupt Status Register
///
/// Also called DC User P3.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCInterrupt = packed struct(u16) {
    interrupt0_active: bool,
    _reserved: u7 = 0,
    interrupt1_active: bool,
    _reserved2: u7 = 0,
};

/// DC Cyclic Operation Start Time Register
///
/// Also called DC user P4.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCCyclicOperationStartTime = packed struct(u32) {
    cyclic_operation_start_time_ns: u32,
};

/// DC Cycle Time Register
///
/// Also called DC user P5, P6.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCCycleTime = packed struct(u64) {
    sync0: u32, // P5
    sync1: u32, // P6
};

pub const TriggerMode = enum(u1) {
    continuous = 0,
    single = 1,
};

/// DC Latch Trigger Register
///
/// Also called DC User P7.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCLatchTrigger = packed struct(u16) {
    latch0_positive_edge: TriggerMode, // P7
    latch0_negative_edge: TriggerMode,
    _reserved: u6 = 0,
    latch1_positive_edge: TriggerMode,
    latch1_negative_edge: TriggerMode,
    _reserved2: u6 = 0,
};

/// DC Latch Event Register
///
/// Also called DC User P8.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCLatchEvent = packed struct(u16) {
    latch0_positive_event_stored: bool,
    latch0_negative_event_stored: bool,
    _reserved: u6 = 0,
    latch1_positive_event_stored: bool,
    latch1_negative_event_stored: bool,
    _reserved2: u6 = 0,
};

/// DC Latch Value Register
///
/// Also called DC User P9, P10, P11, P12.
///
/// Ref: IEC 61158-4-12:2019 6.8.5
/// Ref: IEC 61158-6-12:2019 5.5
pub const DCLatchValue = packed struct(u256) {
    latch0_positive_edge: u32, // P9
    _reserved: u32 = 0,
    latch0_negative_edge: u32, // P10
    _reserved2: u32 = 0,
    latch1_positive_edge: u32, // P11
    _reserved3: u32 = 0,
    latch1_negative_edge: u32, // P12
    _reserved4: u32 = 0,
};

test {
    std.testing.refAllDecls(@This());
}
