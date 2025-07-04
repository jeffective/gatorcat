const std = @import("std");
const assert = std.debug.assert;

const pdi = @import("pdi.zig");

const esc = @This();

pub const RegisterMap = enum(u16) {
    DL_information = 0x0000,
    station_address = 0x0010,
    DL_control = 0x0100,
    DL_control_enable_alias_address = 0x0103,
    DL_status = 0x0110,
    AL_control = 0x0120,
    AL_status = 0x0130,
    PDI_control = 0x0140,
    // sync_configuration = 0x0150, where is this in R8?
    external_event_mask = 0x0200,
    DL_user_event_mask = 0x0204,
    external_event = 0x0210,
    DL_user_event = 0x0220,
    rx_error_counter = 0x0300,
    addtional_counter = 0x0308,
    lost_link_counter = 0x0310,
    watchdog_divider = 0x0400,
    DLS_user_watchdog = 0x0410,
    SM_watchdog = 0x420,
    SM_watchdog_status = 0x0440,
    watchdog_counter = 0x0442,
    SII_access = 0x0500,
    SII_control_status = 0x0502,
    SII_address = 0x0504,
    SII_data = 0x0508,
    MII_control_status = 0x0510,
    MII_address = 0x0512,
    MII_data = 0x0514,
    MII_access = 0x0516,
    FMMU0 = 0x0600,
    SM0 = 0x0800,
    SM1 = 0x0800 + 8 * 1,
    SM2 = 0x0800 + 8 * 2,
    SM3 = 0x0800 + 8 * 3,
    SM4 = 0x0800 + 8 * 4,
    SM5 = 0x0800 + 8 * 5,
    SM6 = 0x0800 + 8 * 6,
    SM7 = 0x0800 + 8 * 7,
    SM8 = 0x0800 + 8 * 8,
    SM9 = 0x0800 + 8 * 9,
    SM10 = 0x0800 + 8 * 10,
    SM11 = 0x0800 + 8 * 11,
    SM12 = 0x0800 + 8 * 12,
    SM13 = 0x0800 + 8 * 13,
    SM14 = 0x0800 + 8 * 14,
    SM15 = 0x0800 + 8 * 15,
    DC = 0x0900,
    DC_user = 0x0980,
    DC_sync_activation = 0x0981,
};

pub fn getSMAddr(sm: u4) u16 {
    return @as(u16, @intFromEnum(RegisterMap.SM0)) + 8 * @as(u16, sm);
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
pub const DLInformationRegister = packed struct {
    type: u8,
    revision: u8,
    build: u16,
    /// number of supported FMMU entities
    /// 0x01-0x10
    nFMMU: u8,
    /// number of supported sync manager channels
    /// 0x01-0x10
    nSM: u8,
    /// ram size in kB, kB= 1024B (1-60)
    ram_size_kB: u8,
    port0: PortDescriptor,
    port1: PortDescriptor,
    port2: PortDescriptor,
    port3: PortDescriptor,
    FMMUBitOpNotSupported: bool,
    NoSupportReservedRegister: bool,
    DCSupported: bool,
    DCRange64Bit: bool, // true when 64 bit, else 32 bit
    LowJitterEBUS: bool,
    EnhancedLinkDetectionEBUS: bool,
    EnhancedLinkDetectionMII: bool,
    FCSErrorHandlingSeparate: bool,
    EnhancedDCSyncActivation: bool,
    LRWNotSupported: bool,
    BRW_APRW_FPRW_NotSupported: bool,
    SpecialFMMU_SM_Configuration: bool,
    reserved: u4 = 0,
};

/// Station Address Register
///
/// Contains the station address of the subdevice which will be
/// set to active the FPRD, FPRW, FRMW, FPWR service in the subdevice.
///
/// Ref: IEC 61158-4-12:2019 6.1.2
pub const StationAddressRegister = packed struct {
    /// Configured station address to be initialized by the maindevice at start up.
    configured_station_address: u16,
    configured_station_alias: u16, // initialized with SII word 4
};

pub const ConfiguredStationAddressRegister = packed struct(u16) {
    configured_station_address: u16,
};

/// Loop Control Settings
///
/// Loop control settings for the ports of a subdevice as part of the DL Control register.
///
/// Ref: IEC 61158-4-12:2019 6.1.3
pub const LoopControlSettings = enum(u2) {
    /// closed at link down, open at link up
    auto = 0,
    /// loop closed at link down, open when writing 101 after link up,
    /// or after receiving a valud ethernet frame at closed port
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
pub const DLControlRegister = packed struct {
    /// false: Non-ethercat frames are forwarded unmodified. true: non-ethercat frames are destroyed.
    forwarding_rule: bool,
    /// false: loop control settings are permanent, true: loop contorl settings are temporary (approx. 1 second)
    temporary_loop_control: bool,
    reserved: u6 = 0,
    loop_control_port0: LoopControlSettings,
    loop_control_port1: LoopControlSettings,
    loop_control_port2: LoopControlSettings,
    loop_control_port3: LoopControlSettings,
    transmit_buffer_size: u3,
    low_jitter_EBUS_active: bool,
    reserved2: u4 = 0,
    enable_alias_address: bool,
    reserved3: u7 = 0,
};

/// Smaller version of the DLControlRegister with fewer settings.
pub const DLControlRegisterCompact = packed struct {
    /// false: Non-ethercat frames are forwarded unmodified. true: non-ethercat frames are destroyed.
    forwarding_rule: bool,
    /// false: loop control settings are permanent, true: loop contorl settings are temporary (approx. 1 second)
    temporary_loop_control: bool,
    reserved: u6 = 0,
    loop_control_port0: LoopControlSettings,
    loop_control_port1: LoopControlSettings,
    loop_control_port2: LoopControlSettings,
    loop_control_port3: LoopControlSettings,
};

pub const DLControlEnableAliasAddressRegister = packed struct(u8) {
    enable_alias_address: bool,
    reserved: u7 = 0,
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
/// Ref: IEC 61158-6-12:2019 5.3.1
pub const ALControlRegister = packed struct(u16) {
    state: ALStateControl,
    ack: bool,
    request_id: bool,
    reserved: u10 = 0,
};

/// AL Status Codes
///
/// Ref: IEC 61158-6-12:2019 5.3.2
pub const ALStatusCode = enum(u16) {
    no_error = 0x0000,
    unspecified_error = 0x0001,
    no_memory = 0x0002,
    invalid_device_setup = 0x0003,
    reserved = 0x0005,
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
/// Ref: IEC 61158-6-12:2019 5.3.2
pub const ALStatusRegister = packed struct(u48) {
    state: ALStateStatus,
    err: bool,
    id_loaded: bool,
    reserved: u26 = 0,
    status_code: ALStatusCode,
};

/// PDI Control Register
///
/// Ref: IEC 61158-6-12:2019 5.3.4
pub const PDIControlRegister = packed struct(u16) {
    PDI_type: u8,
    emulated: bool,
    reserved: u7 = 0,
};

/// Sync Configuration Register
///
/// Ref: IEC 61158-6-12:2019 5.3.4
pub const SyncConfigurationRegister = packed struct(u8) {
    signal_conditioning_sync0: u2,
    enable_sync0: bool,
    enable_interrupt_sync0: bool,
    signal_conditioning_sync1: u2,
    enable_sync1: bool,
    enable_interrupt_sync1: bool,
};

/// DL Status Register
///
/// The DL Status register is used to indicate the state of the DL ports and state
/// of the interface between the DL-user and the DL.
///
/// Ref: IEC 61158-4-12:2019 6.1.4
pub const DLStatusRegister = packed struct {
    pdi_operational: bool,
    watchdog_ok: bool,
    exteded_link_detection: bool,
    reserved: u1 = 0,
    /// true when physical link on port0
    port0_link_status: bool,
    /// true when physical link on port1
    port1_link_status: bool,
    /// true when physical link on port2
    port2_link_status: bool,
    /// true when physical link on port3
    port3_link_status: bool,
    port0_loop_active: bool,
    /// true when rx-signal detected on port0
    port0_rx_signal_det: bool,
    port1_loop_active: bool,
    /// true when rx-signal detected on port1
    port1_rx_signal_det: bool,
    port2_loop_active: bool,
    /// true when rx-signal detected on port2
    port2_rx_signal_det: bool,
    port3_loop_active: bool,
    /// true when rx-signal detected on port3
    port3_rx_signal_det: bool,
};

// TODO: DL User Specific Registers, Ref: IEC 61158-4-12:2019 6.1.5.4

// TODO: fix these?
/// DL-User Event Register
///
/// The event registers are used to indicate and event to the DL-user.
/// The event shall be acknoledged of the corresponding event source is read.
/// The events can be masked.
///
/// Ref: IEC 61158-4-12:2019 6.1.6
// pub const DLUserEventRegister = packed struct {
//     /// event active R1 was written
//     DL_user_R1_change: bool,
//     DC_event_0: bool,
//     DC_event_1: bool,
//     DC_event_2: bool,
//     SM_change_event: bool,
//     EEPROM_emulation_command_pending: bool,
//     DLE_specific: u2,
//     SM_ch_events: [16]bool,
//     DLE_specific2: u8,
// };

/// DL User Event Mask
///
/// Ref: IEC 61158-4-12:2019 6.1.6
// pub const DLUserEventMaskRegister = packed struct {
//     event_mask: [32]bool,
// };

/// External Event Register
///
/// The External Event register is mapped to IRQ parameters of all EtherCAT PDUs
/// accessing this subdevice. If an event is set and the associated mask is set
/// the corresponding bit in the IRQ parameter of a PDU is set.
///
/// Ref: IEC 61158-4-12:2019 6.1.6
// pub const ExternalEventRegister = packed struct {
//     DC_event_0: bool,
//     reserved: u1 = 0,
//     DL_status_change: bool,
//     R3_or_R4_change: bool,
//     SM_ch_events: [8]bool,
//     reserved2: u4 = 0,
// };

/// External Event Mask Register
///
/// Ref: IEC 61158-4-12:2019 6.1.6
// pub const ExternalEventMaskRegister = packed struct {
//     event_mask: [16]bool,
// };

/// RX Error Counter Register
///
/// The RX error counter registers contain information about the physical layer
/// errors, like length or FCS. All counters are cleared if one is written.
/// The counting is stopped for each counter once the counter reaches the maximum
/// value of 255.
///
/// Ref: IEC 61158-4-12:2019 6.2.1
pub const RXErrorCounterRegister = packed struct {
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
pub const LostLinkCounterRegister = packed struct {
    port0_lost_link_count: u8,
    port1_lost_link_count: u8,
    port2_lost_link_count: u8,
    port3_lost_link_count: u8,
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
pub const AdditionalCounterRegister = packed struct {
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
/// The parameter shall contianer the number of 40 ns intervals (minus 2)
/// that represents the basic watchdog increment (default value is 100 us = 2498).
///
/// Ref: IEC 61158-4-12:2019 6.3.1
pub const WatchdogDividerRegister = packed struct {
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
pub const DLSUserWatchdogRegister = packed struct {
    DLS_user_watchdog: u16,
};

/// Sync Manager Watchdog Register
///
/// Each write access of the DL-user memory area configured
/// in the Sync manager shall reset the watchdog if the watchdog
/// option is enabled by this sync manager.
///
/// Ref: IEC 61158-4-12:2019 6.3.3
pub const SyncMangagerWatchdogRegister = packed struct {
    SyncManagerWatchdog: u16,
};

/// Sync Manager Watchdog Status Register
///
/// The status of the sync manager watchdog.
///
/// Ref: IEC 61158-4-12:2019 6.3.3
pub const SyncManagerWatchDogStatus = packed struct {
    watchdog_ok: bool,
    reserved: u15 = 0,
};

/// Watchdog Counter Register
///
/// Optional register to count the occurances of expirations of watchdogs.
///
/// Writes will reset all watchdog counters.
///
/// Ref: IEC 61158-4-12:2019 6.3.5
pub const WatchdogCounterRegister = packed struct {
    SM_watchdog_counter: u8,
    DL_user_watchdog_counter: u8,
};

pub const SIIAccessOwner = enum(u1) {
    ethercat_DL = 0,
    PDI = 1,
};

/// Subdevice Information Interface (SII) Access Register
///
/// Ref: IEC 61158-4-12:2019 6.4.2
pub const SIIAccessRegister = packed struct {
    owner: SIIAccessOwner,
    lock: bool,
    reserved: u6 = 0,
    access_PDI: bool,
    reserved2: u7 = 0,
};

pub const SIIAccessRegisterCompact = packed struct(u8) {
    owner: SIIAccessOwner,
    lock: bool,
    reserved: u6 = 0,
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
pub const SIIControlStatusRegister = packed struct {
    write_access: bool,
    reserved: u4 = 0,
    EEPROM_emulation: bool,
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

pub const SIIControlStatusAddressRegister = packed struct {
    write_access: bool,
    reserved: u4 = 0,
    EEPROM_emulation: bool,
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
pub const SIIAddressRegister = packed struct {
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
pub const MIIControlStatusRegister = packed struct {
    write_access: bool,
    access_PDI: bool,
    MII_link_det: bool,
    PHY_offset: u5 = 0x00,
    read_operation: bool,
    write_operation: bool,
    reserved: u3 = 0x00,
    read_error: bool,
    write_error: bool,
    busy: bool,
};

/// MII Address Register
///
/// Ref: IEC 61158-4-12:2019 6.5.2
pub const MIIAddressRegister = packed struct {
    /// address of the PHY (0-63)
    PHY_address: u8,
    /// PHY register address
    PHY_register_address: u8,
};

/// MII Data Register
///
/// The MII data register contains the data to be written for the next
/// write operation or the read data from the MII from the last
/// read operation.
///
/// Ref: IEC 61158-4-12:2019 6.5.3
pub const MIIDataRegister = packed struct {
    data: u16,
};

pub const MIIAccessState = enum(u1) {
    ECAT_access_active = 0,
    PDI_access_active = 1,
};

/// MII Access Register
///
/// The MII Access register manages the MII access.
///
/// Ref: IEC 61158-4-12:2019 6.5.4
pub const MIIAccessRegister = packed struct {
    MII_access: bool,
    reserved: u7 = 0,
    access_state: MIIAccessState,
    access_reset: bool,
    reserved2: u6 = 0,
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

pub const FMMUArray = std.BoundedArray(FMMUAttributes, max_fmmu);

/// FMMU Register
///
/// The FMMU register contains the settings for the FMMU entities.
///
/// Ref: IEC 61158-4-12:2019 6.6.2
pub const FMMURegister = packed struct {
    FMMU0: FMMUAttributes,
    FMMU1: FMMUAttributes,
    FMMU2: FMMUAttributes,
    FMMU3: FMMUAttributes,
    FMMU4: FMMUAttributes,
    FMMU5: FMMUAttributes,
    FMMU6: FMMUAttributes,
    FMMU7: FMMUAttributes,
    FMMU8: FMMUAttributes,
    FMMU9: FMMUAttributes,
    FMMU10: FMMUAttributes,
    FMMU11: FMMUAttributes,
    FMMU12: FMMUAttributes,
    FMMU13: FMMUAttributes,
    FMMU14: FMMUAttributes,
    FMMU15: FMMUAttributes,

    pub fn writeFMMUConfig(self: *FMMURegister, config: FMMUAttributes, fmmu_idx: u4) void {
        switch (fmmu_idx) {
            0 => self.FMMU0 = config,
            1 => self.FMMU1 = config,
            2 => self.FMMU2 = config,
            3 => self.FMMU3 = config,
            4 => self.FMMU4 = config,
            5 => self.FMMU5 = config,
            6 => self.FMMU6 = config,
            7 => self.FMMU7 = config,
            8 => self.FMMU8 = config,
            9 => self.FMMU9 = config,
            10 => self.FMMU10 = config,
            11 => self.FMMU11 = config,
            12 => self.FMMU12 = config,
            13 => self.FMMU13 = config,
            14 => self.FMMU14 = config,
            15 => self.FMMU15 = config,
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

pub const SyncManagerControlRegister = packed struct(u8) {
    buffer_type: SyncManagerBufferType,
    direction: SyncManagerDirection,
    ECAT_event_enable: bool,
    DLS_user_event_enable: bool,
    watchdog_enable: bool,
    reserved: u1 = 0,
};

pub const SyncManagerStatusRegister = packed struct(u8) {
    write_event: bool,
    read_event: bool,
    reserved2: u1 = 0,
    mailbox_full: bool,
    buffered_state: SyncMangagerBufferedState,
    read_buffer_open: bool,
    write_buffer_open: bool,
};
pub const SyncManagerActivateRegister = packed struct(u8) {
    channel_enable: bool,
    repeat: bool,
    reserved3: u4 = 0,
    DC_event_0_bus_access: bool,
    DC_event_0_local_access: bool,
};

/// Sync Manager Attributes (Channels)
///
/// Configuration of a single sync manager.
///
/// Ref: IEC 61158-4-12:2019 6.7.2
pub const SyncManagerAttributes = packed struct(u64) {
    physical_start_address: u16,
    length: u16,
    control: SyncManagerControlRegister,
    status: SyncManagerStatusRegister,
    activate: SyncManagerActivateRegister,
    channel_enable_PDI: bool,
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
                .ECAT_event_enable = false,
                .DLS_user_event_enable = true,
                .watchdog_enable = false,
            },
            // SOEM uses 0x00 for the status byte
            .status = @bitCast(@as(u8, 0)),
            // SOEM uses 0x01 for the activate byte
            .activate = .{
                .channel_enable = true,
                .repeat = false,
                .DC_event_0_bus_access = false,
                .DC_event_0_local_access = false,
            },
            // SOEM uses 0x00 for the remaining
            .channel_enable_PDI = false,
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
                .ECAT_event_enable = false,
                .DLS_user_event_enable = true,
                .watchdog_enable = false,
            },
            .status = @bitCast(@as(u8, 0)),
            .activate = .{
                .channel_enable = true,
                .repeat = false,
                .DC_event_0_bus_access = false,
                .DC_event_0_local_access = false,
            },
            .channel_enable_PDI = false,
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
pub const SMRegister = packed struct(u2048) {
    SM0: SyncManagerAttributes,
    SM1: SyncManagerAttributes,
    SM2: SyncManagerAttributes,
    SM3: SyncManagerAttributes,
    SM4: SyncManagerAttributes,
    SM5: SyncManagerAttributes,
    SM6: SyncManagerAttributes,
    SM7: SyncManagerAttributes,
    SM8: SyncManagerAttributes,
    SM9: SyncManagerAttributes,
    SM10: SyncManagerAttributes,
    SM11: SyncManagerAttributes,
    SM12: SyncManagerAttributes,
    SM13: SyncManagerAttributes,
    SM14: SyncManagerAttributes,
    SM15: SyncManagerAttributes,
    SM16: SyncManagerAttributes,
    SM17: SyncManagerAttributes,
    SM18: SyncManagerAttributes,
    SM19: SyncManagerAttributes,
    SM20: SyncManagerAttributes,
    SM21: SyncManagerAttributes,
    SM22: SyncManagerAttributes,
    SM23: SyncManagerAttributes,
    SM24: SyncManagerAttributes,
    SM25: SyncManagerAttributes,
    SM26: SyncManagerAttributes,
    SM27: SyncManagerAttributes,
    SM28: SyncManagerAttributes,
    SM29: SyncManagerAttributes,
    SM30: SyncManagerAttributes,
    SM31: SyncManagerAttributes,

    pub fn asArray(self: SMRegister) [32]SyncManagerAttributes {
        var res: [32]SyncManagerAttributes = undefined;
        res[0] = self.SM0;
        res[1] = self.SM1;
        res[2] = self.SM2;
        res[3] = self.SM3;
        res[4] = self.SM4;
        res[5] = self.SM5;
        res[6] = self.SM6;
        res[7] = self.SM7;
        res[8] = self.SM8;
        res[9] = self.SM9;
        res[10] = self.SM10;
        res[11] = self.SM11;
        res[12] = self.SM12;
        res[13] = self.SM13;
        res[14] = self.SM14;
        res[15] = self.SM15;
        res[16] = self.SM16;
        res[17] = self.SM17;
        res[18] = self.SM18;
        res[19] = self.SM19;
        res[20] = self.SM20;
        res[21] = self.SM21;
        res[22] = self.SM22;
        res[23] = self.SM23;
        res[24] = self.SM24;
        res[25] = self.SM25;
        res[26] = self.SM26;
        res[27] = self.SM27;
        res[28] = self.SM28;
        res[29] = self.SM29;
        res[30] = self.SM30;
        res[31] = self.SM31;
        return res;
    }

    pub fn set(self: SMRegister, i: usize, sm: SyncManagerAttributes) void {
        assert(i < 32);
        if (i == 0) self.SM0 = sm;
        if (i == 1) self.SM1 = sm;
        if (i == 2) self.SM2 = sm;
        if (i == 3) self.SM3 = sm;
        if (i == 4) self.SM4 = sm;
        if (i == 5) self.SM5 = sm;
        if (i == 6) self.SM6 = sm;
        if (i == 7) self.SM7 = sm;
        if (i == 8) self.SM8 = sm;
        if (i == 9) self.SM9 = sm;
        if (i == 10) self.SM10 = sm;
        if (i == 11) self.SM11 = sm;
        if (i == 12) self.SM12 = sm;
        if (i == 13) self.SM13 = sm;
        if (i == 14) self.SM14 = sm;
        if (i == 15) self.SM15 = sm;
        if (i == 16) self.SM16 = sm;
        if (i == 17) self.SM17 = sm;
        if (i == 18) self.SM18 = sm;
        if (i == 19) self.SM19 = sm;
        if (i == 20) self.SM20 = sm;
        if (i == 21) self.SM21 = sm;
        if (i == 22) self.SM22 = sm;
        if (i == 23) self.SM23 = sm;
        if (i == 24) self.SM24 = sm;
        if (i == 25) self.SM25 = sm;
        if (i == 26) self.SM26 = sm;
        if (i == 27) self.SM27 = sm;
        if (i == 28) self.SM28 = sm;
        if (i == 29) self.SM29 = sm;
        if (i == 30) self.SM30 = sm;
        if (i == 31) self.SM31 = sm;
    }
};

// TODO: verify representation of sys time difference

/// DC Settings Register
///
/// Ref: IEC 61158-4-12:2019 6.8.5
pub const DCRegister = packed struct {
    port0_recv_time_ns: u32,
    port1_recv_time_ns: u32,
    port2_recv_time_ns: u32,
    port3_recv_time_ns: u32,
    sys_time_ns: u64,
    proc_unit_recv_time_ns: u64,
    sys_time_offset_ns: u64,
    sys_time_transmission_delay_ns: u32,
    sys_time_diff_ns: i32,
    ctrl_loop_P1: u16,
    ctrl_loop_P2: u16,
    ctrl_loop_P3: u16,
};

/// DC User Settings Register
///
/// Ref: IEC 61158-4-12:2019 6.8.5
pub const DCUserRegister = packed struct {
    reserved: u8 = 0,
    DC_user_P1: u8,
    DC_user_P2: u16,
    DC_user_P13: u8,
    DC_user_P14: u8,
    reserved2: u64 = 0,
    DC_user_P3: u16,
    DC_user_P4: u32,
    reserved3: u96 = 0,
    DC_user_P5: u32,
    DC_user_P6: u32,
    DC_user_P7: u16,
    reserved4: u32 = 0,
    DC_user_P8: u16,
    DC_user_P9: u16,
    reserved5: u32 = 0,
    DC_user_P10: u32,
    reserved6: u32 = 0,
    DC_user_P11: u32,
    reserved7: u32 = 0,
    DC_user_P12: u32,
    reserved8: u32 = 0,
};

/// DC Sync Activation Register
///
/// Mapped to DC User P1
///
/// Ref: IEC 61158-6-12:2019 5.5
const DCSyncActivationRegister = packed struct(u8) {
    enable_cylic_operation: bool,
    generate_sync0: bool,
    generate_sync1: bool,
    reserved: u5 = 0,
};

test {
    std.testing.refAllDecls(@This());
}
