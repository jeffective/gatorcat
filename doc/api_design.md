# EtherCAT Implementation Guide

EtherCAT implementations typically operate on cyclic control loops. We are no different.


## Top-level API Design

The user application shall have the following phases:


1. obtain ethercat network information (ENI)
    * may be compile-time or run-time known
    * may be obtained from a network scan
1. use ENI to initialize a main device
1. main device operates
1. secondary user application manipulates the state of the main device

## Timing

If the library is to provide the simplest user interface possible, the library must control the timing.

The library must control the timing because of distributed clocks (DC). When DC functionality is desired, the application running on the maindevice must sync its events to an external clock: the DC Reference Clock (typically the first DC-enabled subdevice in the ring).

When DC is active, the subdevices expect to recieve frames at intervals defined in terms of the DC Reference Clock. Frames must arrive at the subdevices inside of the window defined between the SYNC0 event and a configured time offset from SYNC0 in the subdevice.

The also means the expected cycle time part of the EtherCAT Network Information, becuase DC-enabled subdevices must be configured with the expected cycle time before operation.

Therefore, a static configuration that defines the TIMING, and the expected network contents, is required to provide the simplest possible API.

Summary of the proposed API:

```zig
const eni: gcat.ENI = gcat.ENI.fromFile("eni.zon");

var md = gcat.MainDevice(eni);

while (true) {
    md.recvFrames();
    md.sendFrames();
    md.sleepUntilNextCycle();
}
```

## Operating without ESI Files

It is possible, for simpler and well-behaving subdevices, to obtain the information necessary to operate them from the devices themselves,
and to not rely on ESI XML files (EtherCAT Subdevice Information).

Subdevices have the following sources of on-board information:

- EEPROM, also called the Subdevice Information Interface (SII)
- CoE (CAN over EtherCAT)

However, practically, subdevice manufacturers seem to often load the on-board information incorrectly and/or provide self-contradictory information.
Subdevice manufactureres seem hesitant to issue firmware updates and often only issue new ESI files, which commerical MainDevice implementations (CODESYS, TwinCAT) can ingest to work around the faulty information present on the subdevices. So it seems that commerical implementations prefer ESI files.

Problems with the on-board information (EEPROM, CoE), have been observed even on (older) Beckhoff devices, and are relatively common on esoteric devices from other manufacturers.

Nevertheless, we shall describe how the on-board information can be used to operate the devices:

The devices expect certain configurations to be accomplished before certain state transitions of the EtherCAT State Machine.

TODO: NOTE: this section is missing information regarding distributed clocks.

Occurring before INIT -> PREOP (IP):

- the identity of the subdevice (vendor, product code, revision, serial number) is read from the EEPROM
    - Beckhoff normally leaves serial number as zero.
    - it is sometimes desirable (from the user's perspective) for the maindevice to ignore revision number (to facilitate module replacements without code-changes). It is also sometimes desireable to be strict about revision numbers (subdevice manufacturers issue upgrades in newer version of their modules that contain backwards incompatabilities)
    - the subdevice identity is used to lookup appropriate configuration from an ESI file library for most commercial MainDevice implementations. (note the above caveat about revision number)
- the mailbox sync managers are configured using information from the EEPROM
    - NOTE: you do NOT configure the process data sync managers during this transition!
    - mailbox communication is not possible until mailbox sync managers are configured. Therefore, this step can only be accomplished with the EEPROM, and CoE information cannot be used.
    - this is only done if the subdevice is determined to support mailbox protocols
        - a subdevice is deemded to support mailbox protocols if:
            - the EEPROM sync managers catagory contains a mailbox_in sync manager AND a mailbox_out syncmanager
            - OR the eeprom INFO section has a valid (non-zero) configuration for the "std" mailbox recv/send size/offsets and "supported mailbox protcols" field is non-zero.
    - configuring the mailbox sync managers requires obtaining the following information:
        - mailbox out offset (physical memory byte address)
        - mailbox out size (bytes)
        - mailbox in offset (physical memory byte address)
        - mailbox in size (bytes)
    - there are 2 locations in the EEPROM we could reference:
        - the "info" section of the EEPROM (the beginning of the EEPROM)
        - the sync managers catagory of the EEPROM (preferred)
    - the sync managers catagory of the EEPROM is the preferred source of information (I don't have any evidence or reasoning for this claim).
    - the "info" section of the EEPROM, which contains information about default bootstrap and std mailbox configurations.
        - the bootstrap mailbox configuration is the suggested mailbox configuration for FoE firmware updates in the bootstrap state (rare)
        - the std mailbox configuration is what we would use for CoE
            ```
            std_recv_mbx_offset: u16,
            std_recv_mbx_size: u16,
            std_send_mbx_offset: u16,
            std_send_mbx_size: u16,
            ```
        - NOTE: "mailbox out" referres to a mailbox transfer of data from the maindevice to the subdevice. "Mailbox In" is data transfer from subdevice to maindevice.
        - NOTE: "std_recv_mbx_offset" is the location in physical memory on the subdevice used to store mailbox transfers from the maindevice, and therfore corresponds to "mailbox out". "std_send_mbx_offset" is for "mailbox in".
    - whether the subdevice supports CoE Complete Access (CA) is determined from the EEPROM General catagory general.coe_details.enable_SDO_complete_access

Occuring before PREOP -> SAFEOP (PS):

- the process data sync managers are configured
    - the length parameter of each sync manager and number of sync managers is determined by the PDO assignment.
        - the PDO assignment is in the CoE and the EEPROM. If CoE is enabled, CoE takes precedence over the EEPROM (the PDO assignment stored in the EEPROM is ignored).
        - reading the PDO assignment must be done AFTER startup parameters are applied, as CoE startup parameters may adjust the PDO assignment.
        - add up the bitlengths of the PDOs assigned to each sync manager, this determines the length (bytes) of each sync manager.
        - the PDO indices assigned to each sync manager determines if it is an input or output sync manager (see PDO index ranges in the spec.)
            - in practice, use the EEPROM sync managers catagory to determine if a sync manager is input or output and validate the PDOs are assigned to an appropriate type of sync manager when you iterate over them and reject invalid assignments as "error.MisbehavingSubdevice".
        - the length parameter of each sync manager configuration stored in the EEPROM Sync Managers Catagory cannot be trusted, and must be determined by adding up the bitlengths of PDOs described in the EEPROM / CoE.
            - example: the Beckhoff EL2008 has 8 output bits but the EEPROM sync manager catagory has a zero length outputs sync manager, when it should be 1.
    - the physical memory offset parameter of the sync manager configuration can only be obtained from the EEPROM Sync Manager Catagory.
- the FMMUs are configured
    - the lengths are offsets of the FMMUs can be entirely user-application defined (a user by wish to place any bits from any input/output anywhere in the process data). Practically, the FMMUs should be the same length as the sync managers. One FMMU by encompase multiple sync managers, if the sync managers are next to one another and are the same direction (input / output). So it is neccesary to iterate over the sync manager and "assign" them to FMMUs such that neighboring same-direction sync managers receive the same FMMU.
    - the number of available FMMUs is determined from the EEPROM FMMU catagory.


