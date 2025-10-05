# Bus Info

```zon
.{
    .ifname = "enx00e04c68191a",
    .ring_position = null,
    .recv_timeout_us = 10000,
    .eeprom_timeout_us = 100000,
    .INIT_timeout_us = 5000000,
    .PREOP_timeout_us = 10000000,
    .mbx_timeout_us = 50000,
}
```
## Bus Summary

| Ring Pos.| Order ID| Auto-incr. Addr.| Station Addr.| Vendor ID| Product Code| Revision Number |
|---|---|---|---|---|---|---|
| 0     | EK1100           | 0x0000 | 0x1000 | 0x00000002 | 0x044c2c52 | 0x00110000 |
| 1     | EL2008           | 0xffff | 0x1001 | 0x00000002 | 0x07d83052 | 0x00100000 |
| 2     | EL3314           | 0xfffe | 0x1002 | 0x00000002 | 0x0cf23052 | 0x00120000 |
| 3     | EL7031-0030      | 0xfffd | 0x1003 | 0x00000002 | 0x1b773052 | 0x0010001e |
| 4     | EL3062           | 0xfffc | 0x1004 | 0x00000002 | 0x0bf63052 | 0x00100000 |
| 5     | EL7041           | 0xfffb | 0x1005 | 0x00000002 | 0x1b813052 | 0x00190000 |
| 6     | EL3048           | 0xfffa | 0x1006 | 0x00000002 | 0x0be83052 | 0x00130000 |

### Subdevice 0(0x1000): EK1100 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     0  |
| Auto-increment address | 0x0000 |
| Station address        | 0x1000 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EK1100 |
| Name             | EK1100 EtherCAT-Koppler (2A E-Bus) |
| Group            | SystemBk |
| Vendor ID        | 0x00000002 |
| Product code     | 0x044c2c52 |
| Revision number  | 0x00110000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = false,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: None




#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          | false |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

No sync managers.



#### SII Catagory: TxPDOs

No TxPDOs catagory.

#### SII Catagory: RxPDOs

No RxPDOs catagory.

### Subdevice 1(0x1001): EL2008 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     1  |
| Auto-increment address | 0xffff |
| Station address        | 0x1001 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL2008 |
| Name             | EL2008 8K. Dig. Ausgang 24V, 0.5A |
| Group            | DigOut |
| Vendor ID        | 0x00000002 |
| Product code     | 0x07d83052 |
| Revision number  | 0x00100000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: None




#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          | false |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: process_data_outputs
    physical start addr: 0xf00
    length: 0
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       false
        watchdog_enable             true
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     true



#### SII Catagory: TxPDOs

No TxPDOs catagory.

#### SII Catagory: RxPDOs

    Outputs bit length: 8    
| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1600 |   0 |           |   1 |                  | Channel 1                  |
|        |     | 0x7000:01 |   1 | BOOLEAN          | Output                     |
| 0x1601 |   0 |           |   1 |                  | Channel 2                  |
|        |     | 0x7010:01 |   1 | BOOLEAN          | Output                     |
| 0x1602 |   0 |           |   1 |                  | Channel 3                  |
|        |     | 0x7020:01 |   1 | BOOLEAN          | Output                     |
| 0x1603 |   0 |           |   1 |                  | Channel 4                  |
|        |     | 0x7030:01 |   1 | BOOLEAN          | Output                     |
| 0x1604 |   0 |           |   1 |                  | Channel 5                  |
|        |     | 0x7040:01 |   1 | BOOLEAN          | Output                     |
| 0x1605 |   0 |           |   1 |                  | Channel 6                  |
|        |     | 0x7050:01 |   1 | BOOLEAN          | Output                     |
| 0x1606 |   0 |           |   1 |                  | Channel 7                  |
|        |     | 0x7060:01 |   1 | BOOLEAN          | Output                     |
| 0x1607 |   0 |           |   1 |                  | Channel 8                  |
|        |     | 0x7070:01 |   1 | BOOLEAN          | Output                     |

### Subdevice 2(0x1002): EL3314 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     2  |
| Auto-increment address | 0xfffe |
| Station address        | 0x1002 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL3314 |
| Name             | EL3314 4K. Ana. Eingang Thermoelement (TC) |
| Group            | AnaIn |
| Vendor ID        | 0x00000002 |
| Product code     | 0x0cf23052 |
| Revision number  | 0x00120000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: CoE FoE 

Default mailbox configuration:

    Mailbox out: offset: 0x1000 size: 128
    Mailbox in:  offset: 0x1080 size: 128

Bootstrap mailbox configuration:

    Mailbox out: offset: 0x1000 size: 244
    Mailbox in:  offset: 0x10f4 size: 244

#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| coe_details.enable_SDO                 |  true |
| coe_details.enable_SDO_info            |  true |
| coe_details.enable_PDO_assign          |  true |
| coe_details.enable_PDO_configuration   | false |
| coe_details.enable_upload_at_startup   | false |
| coe_details.enable_SDO_complete_access | false |
| foe_details.enable_foe                 |  true |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          |  true |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: mailbox_out
    physical start addr: 0x1000
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM1

    type: mailbox_in
    physical start addr: 0x1080
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM2

    type: process_data_outputs
    physical start addr: 0x1100
    length: 0
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      false
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM3

    type: process_data_inputs
    physical start addr: 0x1180
    length: 16
    control:
        buffer_type                 .buffered
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false



#### SII Catagory: TxPDOs

    Inputs bit length: 128  
| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |                  | TC Inputs Channel 1        |
|        |     | 0x6000:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6000:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6000:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6000:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6000:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   7 | UNKNOWN          | Status__                   |
|        |     | 0x6000:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x1800:09 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6000:11 |  16 | INTEGER16        | Value                      |
| 0x1a01 |   3 |           |  32 |                  | TC Inputs Channel 2        |
|        |     | 0x6010:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6010:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6010:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6010:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6010:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   7 | UNKNOWN          | Status__                   |
|        |     | 0x6010:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x1801:09 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6010:11 |  16 | INTEGER16        | Value                      |
| 0x1a02 |   3 |           |  32 |                  | TC Inputs Channel 3        |
|        |     | 0x6020:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6020:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6020:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6020:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6020:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   7 | UNKNOWN          | Status__                   |
|        |     | 0x6020:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x1802:09 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6020:11 |  16 | INTEGER16        | Value                      |
| 0x1a03 |   3 |           |  32 |                  | TC Inputs Channel 4        |
|        |     | 0x6030:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6030:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6030:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6030:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6030:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   7 | UNKNOWN          | Status__                   |
|        |     | 0x6030:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x1803:09 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6030:11 |  16 | INTEGER16        | Value                      |

#### SII Catagory: RxPDOs

    Outputs bit length: 0    
| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1600 | 255 |           |  16 |                  | TC Outputs Channel 1       |
|        |     | 0x7000:11 |  16 | INTEGER16        | CJCompensation             |
| 0x1601 | 255 |           |  16 |                  | TC Outputs Channel 2       |
|        |     | 0x7010:11 |  16 | INTEGER16        | CJCompensation             |
| 0x1602 | 255 |           |  16 |                  | TC Outputs Channel 3       |
|        |     | 0x7020:11 |  16 | INTEGER16        | CJCompensation             |
| 0x1603 | 255 |           |  16 |                  | TC Outputs Channel 4       |
|        |     | 0x7030:11 |  16 | INTEGER16        | CJCompensation             |

#### CoE: Sync Manager Communication Types

| SM  | Purpose          |
|---  |---               |
| 0   | mailbox_out      |
| 1   | mailbox_in       |
| 2   | output           |
| 3   | input            |

#### CoE: PDO Assignment

| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6000:01 |   1 |         | Underrange                                                      |
|        |     | 0x6000:02 |   1 |         | Overrange                                                       |
|        |     | 0x6000:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6000:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6000:07 |   1 |         | Error                                                           |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6000:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x1800:09 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6000:11 |  16 |         | Value                                                           |
| 0x1a01 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6010:01 |   1 |         | Underrange                                                      |
|        |     | 0x6010:02 |   1 |         | Overrange                                                       |
|        |     | 0x6010:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6010:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6010:07 |   1 |         | Error                                                           |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6010:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x1801:09 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6010:11 |  16 |         | Value                                                           |
| 0x1a02 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6020:01 |   1 |         | Underrange                                                      |
|        |     | 0x6020:02 |   1 |         | Overrange                                                       |
|        |     | 0x6020:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6020:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6020:07 |   1 |         | Error                                                           |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6020:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x1802:09 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6020:11 |  16 |         | Value                                                           |
| 0x1a03 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6030:01 |   1 |         | Underrange                                                      |
|        |     | 0x6030:02 |   1 |         | Overrange                                                       |
|        |     | 0x6030:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6030:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6030:07 |   1 |         | Error                                                           |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6030:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x1803:09 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6030:11 |  16 |         | Value                                                           |


#### CoE: Object Description Lists

| List                             | Length |
|---                               |---     |
| all_objects                      |     43 |
| rx_pdo_mappable                  |      4 |
| tx_pdo_mappable                  |      4 |
| stored_for_device_replacement    |      4 |
| startup_parameters               |      4 |

#### CoE: Object Description List: All Objects

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x1000    | 00 | Device type                                      | UNSIGNED32       |     |
| 0x1008    | 00 | Device name                                      | VISIBLE_STRING   |     |
| 0x1009    | 00 | Hardware version                                 | VISIBLE_STRING   |     |
| 0x100a    | 00 | Software version                                 | VISIBLE_STRING   |     |
| 0x1011    | 01 | Restore default parameters                       | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1018    | 04 | Identity                                         | IDENTITY         |     |
|           | 01 | Vendor ID                                        | UNSIGNED32       | 32  |
|           | 02 | Product code                                     | UNSIGNED32       | 32  |
|           | 03 | Revision                                         | UNSIGNED32       | 32  |
|           | 04 | Serial number                                    | UNSIGNED32       | 32  |
| 0x10f0    | 01 | Backup parameter handling                        | INVALID          |     |
|           | 01 | Checksum                                         | UNSIGNED32       | 32  |
| 0x1600    | 01 | TC RxPDO-Map Ch.1                                | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1601    | 01 | TC RxPDO-Map Ch.2                                | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1602    | 01 | TC RxPDO-Map Ch.3                                | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1603    | 01 | TC RxPDO-Map Ch.4                                | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a00    | 09 | TC TxPDO-MapCh.1                                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1a01    | 09 | TC TxPDO-MapCh.2                                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1a02    | 09 | TC TxPDO-MapCh.3                                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1a03    | 09 | TC TxPDO-MapCh.4                                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1c00    | 04 | Sync manager type                                | UNSIGNED8        |     |
|           | 01 | SubIndex 001                                     | UNSIGNED8        | 8   |
|           | 02 | SubIndex 002                                     | UNSIGNED8        | 8   |
|           | 03 | SubIndex 003                                     | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNSIGNED8        | 8   |
| 0x1c12    | 04 | RxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
| 0x1c13    | 04 | TxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
| 0x1c32    | 20 | SM output parameter                              | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum Delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | Minimum Cycle Distance                           | UNKNOWN          | 0   |
|           | 10 | Maximum Cycle Distance                           | UNKNOWN          | 0   |
|           | 11 | Minimum SM SYNC Distance                         | UNKNOWN          | 0   |
|           | 12 | Maximum SM SYNC Distance                         | UNKNOWN          | 0   |
|           | 13 | Application Cycle Exceeded Counter               | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x1c33    | 20 | SM input parameter                               | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum Delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | Minimum Cycle Distance                           | UNKNOWN          | 0   |
|           | 10 | Maximum Cycle Distance                           | UNKNOWN          | 0   |
|           | 11 | Minimum SM SYNC Distance                         | UNKNOWN          | 0   |
|           | 12 | Maximum SM SYNC Distance                         | UNKNOWN          | 0   |
|           | 13 | Application Cycle Exceeded Counter               | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x6000    | 11 | TC Inputs Ch.1                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | TC Inputs Ch.2                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6020    | 11 | TC Inputs Ch.3                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6030    | 11 | TC Inputs Ch.4                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x7000    | 11 | TC Outputs Ch.1                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7010    | 11 | TC Outputs Ch.2                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7020    | 11 | TC Outputs Ch.3                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7030    | 11 | TC Outputs Ch.4                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x8000    | 19 | TC Settings Ch.1                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x800e    | 05 | TC Internal data Ch.1                            | INTEGER16        |     |
|           | 01 | ADC raw value TC                                 | UNSIGNED32       | 32  |
|           | 02 | ADC raw value PT1000                             | UNSIGNED32       | 32  |
|           | 03 | CJ temperature                                   | INTEGER16        | 16  |
|           | 04 | CJ voltage                                       | INTEGER16        | 16  |
|           | 05 | CJ resistor                                      | UNSIGNED16       | 16  |
| 0x800f    | 04 | TC Vendor data Ch.1                              | INTEGER32        |     |
|           | 01 | Calibration offset TC                            | INTEGER16        | 16  |
|           | 02 | Calibration gain TC                              | UNSIGNED16       | 16  |
|           | 03 | Calibration offset CJ                            | INTEGER16        | 16  |
|           | 04 | Calibration gain CJ                              | UNSIGNED16       | 16  |
| 0x8010    | 19 | TC Settings Ch.2                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x801e    | 05 | TC Internal data Ch.2                            | INTEGER16        |     |
|           | 01 | ADC raw value TC                                 | UNSIGNED32       | 32  |
|           | 02 | ADC raw value PT1000                             | UNSIGNED32       | 32  |
|           | 03 | CJ temperature                                   | INTEGER16        | 16  |
|           | 04 | CJ voltage                                       | INTEGER16        | 16  |
|           | 05 | CJ resistor                                      | UNSIGNED16       | 16  |
| 0x801f    | 04 | TC Vendor data Ch.2                              | INTEGER32        |     |
|           | 01 | Calibration offset TC                            | INTEGER16        | 16  |
|           | 02 | Calibration gain TC                              | UNSIGNED16       | 16  |
|           | 03 | Calibration offset CJ                            | INTEGER16        | 16  |
|           | 04 | Calibration gain CJ                              | UNSIGNED16       | 16  |
| 0x8020    | 19 | TC Settings Ch.3                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x802e    | 05 | TC Internal data Ch.3                            | INTEGER16        |     |
|           | 01 | ADC raw value TC                                 | UNSIGNED32       | 32  |
|           | 02 | ADC raw value PT1000                             | UNSIGNED32       | 32  |
|           | 03 | CJ temperature                                   | INTEGER16        | 16  |
|           | 04 | CJ voltage                                       | INTEGER16        | 16  |
|           | 05 | CJ resistor                                      | UNSIGNED16       | 16  |
| 0x802f    | 04 | TC Vendor data Ch.3                              | INTEGER32        |     |
|           | 01 | Calibration offset TC                            | INTEGER16        | 16  |
|           | 02 | Calibration gain TC                              | UNSIGNED16       | 16  |
|           | 03 | Calibration offset CJ                            | INTEGER16        | 16  |
|           | 04 | Calibration gain CJ                              | UNSIGNED16       | 16  |
| 0x8030    | 19 | TC Settings Ch.4                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x803e    | 05 | TC Internal data Ch.4                            | INTEGER16        |     |
|           | 01 | ADC raw value TC                                 | UNSIGNED32       | 32  |
|           | 02 | ADC raw value PT1000                             | UNSIGNED32       | 32  |
|           | 03 | CJ temperature                                   | INTEGER16        | 16  |
|           | 04 | CJ voltage                                       | INTEGER16        | 16  |
|           | 05 | CJ resistor                                      | UNSIGNED16       | 16  |
| 0x803f    | 04 | TC Vendor data Ch.4                              | INTEGER32        |     |
|           | 01 | Calibration offset TC                            | INTEGER16        | 16  |
|           | 02 | Calibration gain TC                              | UNSIGNED16       | 16  |
|           | 03 | Calibration offset CJ                            | INTEGER16        | 16  |
|           | 04 | Calibration gain CJ                              | UNSIGNED16       | 16  |
| 0xf000    | 02 | Modular device profile                           | INVALID          |     |
|           | 01 | Module index distance                            | UNSIGNED16       | 16  |
|           | 02 | Maximum number of modules                        | UNSIGNED16       | 16  |
| 0xf008    | 00 | Code word                                        | UNSIGNED32       |     |
| 0xf010    | 04 | Module list                                      | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |

#### CoE: Object Description List: RxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x7000    | 11 | TC Outputs Ch.1                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7010    | 11 | TC Outputs Ch.2                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7020    | 11 | TC Outputs Ch.3                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |
| 0x7030    | 11 | TC Outputs Ch.4                                  | BOOLEAN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | CJCompensation                                   | INTEGER16        | 16  |

#### CoE: Object Description List: TxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x6000    | 11 | TC Inputs Ch.1                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | TC Inputs Ch.2                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6020    | 11 | TC Inputs Ch.3                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6030    | 11 | TC Inputs Ch.4                                   | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |

#### CoE: Object Description List: Stored for Device Replacement

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 19 | TC Settings Ch.1                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8010    | 19 | TC Settings Ch.2                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8020    | 19 | TC Settings Ch.3                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8030    | 19 | TC Settings Ch.4                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |

#### CoE: Object Description List: Startup Parameters

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 19 | TC Settings Ch.1                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8010    | 19 | TC Settings Ch.2                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8020    | 19 | TC Settings Ch.3                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |
| 0x8030    | 19 | TC Settings Ch.4                                 | INTEGER8         |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | Coldjunction compensation                        | INVALID          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | user calibration gain                            | UNSIGNED16       | 16  |
|           | 19 | TC Element                                       | INVALID          | 16  |

### Subdevice 3(0x1003): EL7031-0030 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     3  |
| Auto-increment address | 0xfffd |
| Station address        | 0x1003 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL7031-0030 |
| Name             | EL7031-0030 1Ch. Stepper motor output stage (24V, 2.8A) |
| Group            | DriveAxisTerminals |
| Vendor ID        | 0x00000002 |
| Product code     | 0x1b773052 |
| Revision number  | 0x0010001e |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: CoE FoE 

Default mailbox configuration:

    Mailbox out: offset: 0x1000 size: 128
    Mailbox in:  offset: 0x1080 size: 128

Bootstrap mailbox configuration:

    Mailbox out: offset: 0x1000 size: 244
    Mailbox in:  offset: 0x10f4 size: 244

#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| coe_details.enable_SDO                 |  true |
| coe_details.enable_SDO_info            |  true |
| coe_details.enable_PDO_assign          |  true |
| coe_details.enable_PDO_configuration   | false |
| coe_details.enable_upload_at_startup   | false |
| coe_details.enable_SDO_complete_access |  true |
| foe_details.enable_foe                 |  true |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          |  true |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: mailbox_out
    physical start addr: 0x1000
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM1

    type: mailbox_in
    physical start addr: 0x1080
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM2

    type: process_data_outputs
    physical start addr: 0x1100
    length: 8
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM3

    type: process_data_inputs
    physical start addr: 0x1180
    length: 16
    control:
        buffer_type                 .buffered
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false



#### SII Catagory: TxPDOs

No TxPDOs catagory.

#### SII Catagory: RxPDOs

No RxPDOs catagory.

#### CoE: Sync Manager Communication Types

| SM  | Purpose          |
|---  |---               |
| 0   | mailbox_out      |
| 1   | mailbox_in       |
| 2   | output           |
| 3   | input            |

#### CoE: PDO Assignment

| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1600 |   2 |           |  32 |         |                                                                 |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x7000:02 |   1 |         | Enable latch extern on positive edge                            |
|        |     | 0x7000:03 |   1 |         | Set counter                                                     |
|        |     | 0x7000:04 |   1 |         | Enable latch extern on negative edge                            |
|        |     |           |   4 | PADDING |                                                                 |
|        |     |           |   8 | PADDING |                                                                 |
|        |     | 0x7000:11 |  16 |         | Set counter value                                               |
| 0x1602 |   2 |           |  16 |         |                                                                 |
|        |     | 0x7010:01 |   1 |         | Enable                                                          |
|        |     | 0x7010:02 |   1 |         | Reset                                                           |
|        |     | 0x7010:03 |   1 |         | Reduce torque                                                   |
|        |     |           |   5 | PADDING |                                                                 |
|        |     |           |   8 | PADDING |                                                                 |
| 0x1604 |   2 |           |  16 |         |                                                                 |
|        |     | 0x7010:21 |  16 |         | Velocity                                                        |
| 0x1a00 |   3 |           |  48 |         |                                                                 |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6000:02 |   1 |         | Latch extern valid                                              |
|        |     | 0x6000:03 |   1 |         | Set counter done                                                |
|        |     | 0x6000:04 |   1 |         | Counter underflow                                               |
|        |     | 0x6000:05 |   1 |         | Counter overflow                                                |
|        |     |           |   3 | PADDING |                                                                 |
|        |     |           |   4 | PADDING |                                                                 |
|        |     | 0x6000:0d |   1 |         | Status of extern latch                                          |
|        |     | 0x6000:0e |   1 |         | Sync error                                                      |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6000:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6000:11 |  16 |         | Counter value                                                   |
|        |     | 0x6000:12 |  16 |         | Latch value                                                     |
| 0x1a03 |   3 |           |  16 |         |                                                                 |
|        |     | 0x6010:01 |   1 |         | Ready to enable                                                 |
|        |     | 0x6010:02 |   1 |         | Ready                                                           |
|        |     | 0x6010:03 |   1 |         | Warning                                                         |
|        |     | 0x6010:04 |   1 |         | Error                                                           |
|        |     | 0x6010:05 |   1 |         | Moving positive                                                 |
|        |     | 0x6010:06 |   1 |         | Moving negative                                                 |
|        |     | 0x6010:07 |   1 |         | Torque reduced                                                  |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   3 | PADDING |                                                                 |
|        |     | 0x6010:0c |   1 |         | Digital input 1                                                 |
|        |     | 0x6010:0d |   1 |         | Digital input 2                                                 |
|        |     | 0x6010:0e |   1 |         | Sync error                                                      |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6010:10 |   1 |         | TxPDO Toggle                                                    |
| 0x1a0a |   3 |           |  32 |         |                                                                 |
|        |     | 0x6030:01 |   1 |         | Underrange                                                      |
|        |     | 0x6030:02 |   1 |         | Overrange                                                       |
|        |     | 0x6030:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6030:05 |   2 |         | Limit 2                                                         |
|        |     |           |   2 | PADDING |                                                                 |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6030:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6030:11 |  16 |         | Value                                                           |
| 0x1a0c |   3 |           |  32 |         |                                                                 |
|        |     | 0x6040:01 |   1 |         | Underrange                                                      |
|        |     | 0x6040:02 |   1 |         | Overrange                                                       |
|        |     | 0x6040:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6040:05 |   2 |         | Limit 2                                                         |
|        |     |           |   2 | PADDING |                                                                 |
|        |     |           |   7 | PADDING |                                                                 |
|        |     | 0x6040:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6040:11 |  16 |         | Value                                                           |


#### CoE: Object Description Lists

| List                             | Length |
|---                               |---     |
| all_objects                      |     84 |
| rx_pdo_mappable                  |      4 |
| tx_pdo_mappable                  |      5 |
| stored_for_device_replacement    |      9 |
| startup_parameters               |      9 |

#### CoE: Object Description List: All Objects

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x1000    | 00 | Device type                                      | UNSIGNED32       |     |
| 0x1008    | 00 | Device name                                      | VISIBLE_STRING   |     |
| 0x1009    | 00 | Hardware version                                 | VISIBLE_STRING   |     |
| 0x100a    | 00 | Software version                                 | VISIBLE_STRING   |     |
| 0x1011    | 01 | Restore default parameters                       | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1018    | 04 | Identity                                         | IDENTITY         |     |
|           | 01 | Vendor ID                                        | UNSIGNED32       | 32  |
|           | 02 | Product code                                     | UNSIGNED32       | 32  |
|           | 03 | Revision                                         | UNSIGNED32       | 32  |
|           | 04 | Serial number                                    | UNSIGNED32       | 32  |
| 0x10f0    | 01 | Backup parameter handling                        | INVALID          |     |
|           | 01 | Checksum                                         | UNSIGNED32       | 32  |
| 0x10f3    | 37 | Diagnosis History                                | INVALID          |     |
|           | 01 | Maximum Messages                                 | UNSIGNED8        | 8   |
|           | 02 | Newest Message                                   | UNSIGNED8        | 8   |
|           | 03 | Newest Acknowledged Message                      | UNSIGNED8        | 8   |
|           | 04 | New Messages Available                           | BOOLEAN          | 1   |
|           | 05 | Flags                                            | UNSIGNED16       | 16  |
|           | 06 | Diagnosis Message 001                            | OCTET_STRING     | 224 |
|           | 07 | Diagnosis Message 002                            | OCTET_STRING     | 224 |
|           | 08 | Diagnosis Message 003                            | OCTET_STRING     | 224 |
|           | 09 | Diagnosis Message 004                            | OCTET_STRING     | 224 |
|           | 0a | Diagnosis Message 005                            | OCTET_STRING     | 224 |
|           | 0b | Diagnosis Message 006                            | OCTET_STRING     | 224 |
|           | 0c | Diagnosis Message 007                            | OCTET_STRING     | 224 |
|           | 0d | Diagnosis Message 008                            | OCTET_STRING     | 224 |
|           | 0e | Diagnosis Message 009                            | OCTET_STRING     | 224 |
|           | 0f | Diagnosis Message 010                            | OCTET_STRING     | 224 |
|           | 10 | Diagnosis Message 011                            | OCTET_STRING     | 224 |
|           | 11 | Diagnosis Message 012                            | OCTET_STRING     | 224 |
|           | 12 | Diagnosis Message 013                            | OCTET_STRING     | 224 |
|           | 13 | Diagnosis Message 014                            | OCTET_STRING     | 224 |
|           | 14 | Diagnosis Message 015                            | OCTET_STRING     | 224 |
|           | 15 | Diagnosis Message 016                            | OCTET_STRING     | 224 |
|           | 16 | Diagnosis Message 017                            | OCTET_STRING     | 224 |
|           | 17 | Diagnosis Message 018                            | OCTET_STRING     | 224 |
|           | 18 | Diagnosis Message 019                            | OCTET_STRING     | 224 |
|           | 19 | Diagnosis Message 020                            | OCTET_STRING     | 224 |
|           | 1a | Diagnosis Message 021                            | OCTET_STRING     | 224 |
|           | 1b | Diagnosis Message 022                            | OCTET_STRING     | 224 |
|           | 1c | Diagnosis Message 023                            | OCTET_STRING     | 224 |
|           | 1d | Diagnosis Message 024                            | OCTET_STRING     | 224 |
|           | 1e | Diagnosis Message 025                            | OCTET_STRING     | 224 |
|           | 1f | Diagnosis Message 026                            | OCTET_STRING     | 224 |
|           | 20 | Diagnosis Message 027                            | OCTET_STRING     | 224 |
|           | 21 | Diagnosis Message 028                            | OCTET_STRING     | 224 |
|           | 22 | Diagnosis Message 029                            | OCTET_STRING     | 224 |
|           | 23 | Diagnosis Message 030                            | OCTET_STRING     | 224 |
|           | 24 | Diagnosis Message 031                            | OCTET_STRING     | 224 |
|           | 25 | Diagnosis Message 032                            | OCTET_STRING     | 224 |
|           | 26 | Diagnosis Message 033                            | OCTET_STRING     | 224 |
|           | 27 | Diagnosis Message 034                            | OCTET_STRING     | 224 |
|           | 28 | Diagnosis Message 035                            | OCTET_STRING     | 224 |
|           | 29 | Diagnosis Message 036                            | OCTET_STRING     | 224 |
|           | 2a | Diagnosis Message 037                            | OCTET_STRING     | 224 |
|           | 2b | Diagnosis Message 038                            | OCTET_STRING     | 224 |
|           | 2c | Diagnosis Message 039                            | OCTET_STRING     | 224 |
|           | 2d | Diagnosis Message 040                            | OCTET_STRING     | 224 |
|           | 2e | Diagnosis Message 041                            | OCTET_STRING     | 224 |
|           | 2f | Diagnosis Message 042                            | OCTET_STRING     | 224 |
|           | 30 | Diagnosis Message 043                            | OCTET_STRING     | 224 |
|           | 31 | Diagnosis Message 044                            | OCTET_STRING     | 224 |
|           | 32 | Diagnosis Message 045                            | OCTET_STRING     | 224 |
|           | 33 | Diagnosis Message 046                            | OCTET_STRING     | 224 |
|           | 34 | Diagnosis Message 047                            | OCTET_STRING     | 224 |
|           | 35 | Diagnosis Message 048                            | OCTET_STRING     | 224 |
|           | 36 | Diagnosis Message 049                            | OCTET_STRING     | 224 |
|           | 37 | Diagnosis Message 050                            | OCTET_STRING     | 224 |
| 0x10f8    | 00 | Actual Time Stamp                                | UNSIGNED64       |     |
| 0x1400    | 06 | ENC RxPDO-Par Control compact                    | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1401    | 06 | ENC RxPDO-Par Control                            | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1403    | 06 | STM RxPDO-Par Position                           | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1404    | 06 | STM RxPDO-Par Velocity                           | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1405    | 06 | POS RxPDO-Par Control compact                    | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1406    | 06 | POS RxPDO-Par Control                            | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1407    | 06 | POS RxPDO-Par Control 2                          | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1600    | 07 | ENC RxPDO-Map Control compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
| 0x1601    | 07 | ENC RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
| 0x1602    | 05 | STM RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
| 0x1603    | 01 | STM RxPDO-Map Position                           | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1604    | 01 | STM RxPDO-Map Velocity                           | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1605    | 05 | POS RxPDO-Map Control compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
| 0x1606    | 09 | POS RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1607    | 09 | POS RxPDO-Map Control 2                          | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1800    | 06 | ENC TxPDO-Par Status compact                     | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1801    | 06 | ENC TxPDO-Par Status                             | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1805    | 06 | POS TxPDO-Par Status compact                     | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1806    | 06 | POS TxPDO-Par Status                             | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180a    | 06 | AI TxPDO-Par Standard Ch.1                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180b    | 06 | AI TxPDO-Par Compact Ch.1                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180c    | 06 | AI TxPDO-Par Standard Ch.2                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180d    | 06 | AI TxPDO-Par Compact Ch.2                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1a00    | 0d | ENC TxPDO-Map Status compact                     | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
| 0x1a01    | 0d | ENC TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
| 0x1a02    | 01 | ENC TxPDO-Map Timest. compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a03    | 0e | STM TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
|           | 0e | SubIndex 014                                     | UNSIGNED32       | 32  |
| 0x1a04    | 02 | STM TxPDO-Map Synchron info data                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
| 0x1a05    | 09 | POS TxPDO-Map Status compact                     | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1a06    | 0c | POS TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
| 0x1a07    | 01 | STM TxPDO-Map Internal position                  | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a08    | 01 | STM TxPDO-Map External position                  | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a09    | 01 | POS TxPDO-Map Actual position lag                | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a0a    | 08 | AI TxPDO-Map Standard Ch.1                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
| 0x1a0b    | 01 | AI TxPDO-Map Compact Ch.1                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a0c    | 08 | AI TxPDO-Map Standard Ch.2                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
| 0x1a0d    | 01 | AI TxPDO-Map Compact Ch.2                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1c00    | 04 | Sync manager type                                | UNSIGNED8        |     |
|           | 01 | SubIndex 001                                     | UNSIGNED8        | 8   |
|           | 02 | SubIndex 002                                     | UNSIGNED8        | 8   |
|           | 03 | SubIndex 003                                     | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNSIGNED8        | 8   |
| 0x1c12    | 04 | RxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
| 0x1c13    | 0a | TxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
|           | 05 | SubIndex 005                                     | UNSIGNED16       | 16  |
|           | 06 | SubIndex 006                                     | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNSIGNED16       | 16  |
|           | 08 | SubIndex 008                                     | UNSIGNED16       | 16  |
|           | 09 | SubIndex 009                                     | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNSIGNED16       | 16  |
| 0x1c32    | 20 | SM output parameter                              | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x1c33    | 20 | SM input parameter                               | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x6000    | 16 | ENC Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | Latch extern valid                               | BOOLEAN          | 1   |
|           | 03 | Set counter done                                 | BOOLEAN          | 1   |
|           | 04 | Counter underflow                                | BOOLEAN          | 1   |
|           | 05 | Counter overflow                                 | BOOLEAN          | 1   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | Status of extern latch                           | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Counter value                                    | UNSIGNED32       | 32  |
|           | 12 | Latch value                                      | UNSIGNED32       | 32  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 32  |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 32  |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | Timestamp                                        | UNSIGNED32       | 32  |
| 0x6010    | 15 | STM Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Ready to enable                                  | BOOLEAN          | 1   |
|           | 02 | Ready                                            | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Moving positive                                  | BOOLEAN          | 1   |
|           | 06 | Moving negative                                  | BOOLEAN          | 1   |
|           | 07 | Torque reduced                                   | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | Digital input 1                                  | BOOLEAN          | 1   |
|           | 0d | Digital input 2                                  | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Info data 1                                      | UNSIGNED16       | 16  |
|           | 12 | Info data 2                                      | UNSIGNED16       | 16  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 16  |
|           | 14 | Internal position                                | UNSIGNED32       | 32  |
|           | 15 | External position                                | UNSIGNED32       | 32  |
| 0x6020    | 23 | POS Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Busy                                             | BOOLEAN          | 1   |
|           | 02 | In-Target                                        | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Calibrated                                       | BOOLEAN          | 1   |
|           | 06 | Accelerate                                       | BOOLEAN          | 1   |
|           | 07 | Decelerate                                       | BOOLEAN          | 1   |
|           | 08 | Ready to execute                                 | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Actual velocity                                  | INTEGER16        | 16  |
|           | 22 | Actual drive time                                | UNSIGNED32       | 32  |
|           | 23 | Actual position lag                              | INTEGER32        | 32  |
| 0x6030    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 7   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6040    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 7   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x7000    | 11 | ENC Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | Enable latch extern on positive edge             | BOOLEAN          | 1   |
|           | 03 | Set counter                                      | BOOLEAN          | 1   |
|           | 04 | Enable latch extern on negative edge             | BOOLEAN          | 1   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 4   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Set counter value                                | UNSIGNED32       | 32  |
| 0x7010    | 21 | STM Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable                                           | BOOLEAN          | 1   |
|           | 02 | Reset                                            | BOOLEAN          | 1   |
|           | 03 | Reduce torque                                    | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Position                                         | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
| 0x7020    | 24 | POS Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Execute                                          | BOOLEAN          | 1   |
|           | 02 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x7021    | 24 | POS Outputs 2 Ch.1                               | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | Enable auto start                                | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 4a | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 0   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 0   |
|           | 44 | SubIndex 068                                     | UNKNOWN          | 0   |
|           | 45 | Digital input emulation 1                        | INVALID          | 4   |
|           | 46 | SubIndex 070                                     | UNKNOWN          | 0   |
|           | 47 | SubIndex 071                                     | UNKNOWN          | 0   |
|           | 48 | SubIndex 072                                     | UNKNOWN          | 0   |
|           | 49 | Digital input emulation 2                        | INVALID          | 4   |
|           | 4a | SubIndex 074                                     | UNKNOWN          | 4   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |
| 0x8030    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
| 0x803e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | UNSIGNED16       | 16  |
| 0x803f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8040    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
| 0x804e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | UNSIGNED16       | 16  |
| 0x804f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x9010    | 13 | STM Info data Ch.1                               | UNKNOWN          |     |
|           | 01 | Status word                                      | UNSIGNED16       | 16  |
|           | 02 | Motor coil voltage A                             | UNSIGNED16       | 16  |
|           | 03 | Motor coil voltage B                             | UNSIGNED16       | 16  |
|           | 04 | Motor coil current A                             | INTEGER16        | 16  |
|           | 05 | Motor coil current B                             | INTEGER16        | 16  |
|           | 06 | Duty cycle A                                     | INTEGER8         | 8   |
|           | 07 | Duty cycle B                                     | INTEGER8         | 8   |
|           | 08 | Motor velocity                                   | INTEGER16        | 16  |
|           | 09 | Internal position                                | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | External position                                | UNSIGNED32       | 32  |
| 0x9020    | 04 | POS Info data Ch.1                               | UNKNOWN          |     |
|           | 01 | Status word                                      | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | State (drive controller)                         | INVALID          | 16  |
|           | 04 | Actual position lag                              | INTEGER32        | 32  |
| 0xa010    | 13 | STM Diag data Ch.1                               | UNKNOWN          |     |
|           | 01 | Saturated                                        | BOOLEAN          | 1   |
|           | 02 | Over temperature                                 | BOOLEAN          | 1   |
|           | 03 | Torque overload                                  | BOOLEAN          | 1   |
|           | 04 | Under voltage                                    | BOOLEAN          | 1   |
|           | 05 | Over voltage                                     | BOOLEAN          | 1   |
|           | 06 | Short circuit A                                  | BOOLEAN          | 1   |
|           | 07 | Short circuit B                                  | BOOLEAN          | 1   |
|           | 08 | No control power                                 | BOOLEAN          | 1   |
|           | 09 | Misc error                                       | BOOLEAN          | 1   |
|           | 0a | Configuration                                    | BOOLEAN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 6   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual operation mode                            | INVALID          | 4   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 4   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 8   |
| 0xa020    | 08 | POS Diag data Ch.1                               | UNKNOWN          |     |
|           | 01 | Command rejected                                 | BOOLEAN          | 1   |
|           | 02 | Command aborted                                  | BOOLEAN          | 1   |
|           | 03 | Target overrun                                   | BOOLEAN          | 1   |
|           | 04 | Target timeout                                   | BOOLEAN          | 1   |
|           | 05 | Position lag                                     | BOOLEAN          | 1   |
|           | 06 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 8   |
| 0xf000    | 02 | Modular device profile                           | INVALID          |     |
|           | 01 | Module index distance                            | UNSIGNED16       | 16  |
|           | 02 | Maximum number of modules                        | UNSIGNED16       | 16  |
| 0xf008    | 00 | Code word                                        | UNSIGNED32       |     |
| 0xf010    | 05 | Module list                                      | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
| 0xf081    | 01 | Download revision                                | UNKNOWN          |     |
|           | 01 | Revision number                                  | UNSIGNED32       | 32  |
| 0xf80f    | 08 | STM Vendor data                                  | UNKNOWN          |     |
|           | 01 | PWM Frequency                                    | UNSIGNED16       | 16  |
|           | 02 | Deadtime                                         | UNSIGNED16       | 16  |
|           | 03 | Deadtime space                                   | UNSIGNED16       | 16  |
|           | 04 | Warning temperature                              | INTEGER8         | 8   |
|           | 05 | Switch off temperature                           | INTEGER8         | 8   |
|           | 06 | Analog trigger point                             | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
| 0xf900    | 06 | STM Info data                                    | UNKNOWN          |     |
|           | 01 | Software version (driver)                        | VISIBLE_STRING   | 16  |
|           | 02 | Internal temperature                             | INTEGER8         | 8   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 8   |
|           | 04 | Control voltage                                  | UNSIGNED16       | 16  |
|           | 05 | Motor supply voltage                             | UNSIGNED16       | 16  |
|           | 06 | Cycle time                                       | UNSIGNED16       | 16  |
| 0xfb00    | 04 | STM Command                                      | UNKNOWN          |     |
|           | 01 | Request                                          | OCTET_STRING     | 16  |
|           | 02 | Status                                           | UNSIGNED8        | 8   |
|           | 03 | Response                                         | OCTET_STRING     | 32  |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 8   |

#### CoE: Object Description List: RxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x7000    | 11 | ENC Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | Enable latch extern on positive edge             | BOOLEAN          | 1   |
|           | 03 | Set counter                                      | BOOLEAN          | 1   |
|           | 04 | Enable latch extern on negative edge             | BOOLEAN          | 1   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 4   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Set counter value                                | UNSIGNED32       | 32  |
| 0x7010    | 21 | STM Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable                                           | BOOLEAN          | 1   |
|           | 02 | Reset                                            | BOOLEAN          | 1   |
|           | 03 | Reduce torque                                    | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Position                                         | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
| 0x7020    | 24 | POS Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Execute                                          | BOOLEAN          | 1   |
|           | 02 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x7021    | 24 | POS Outputs 2 Ch.1                               | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | Enable auto start                                | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |

#### CoE: Object Description List: TxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x6000    | 16 | ENC Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | Latch extern valid                               | BOOLEAN          | 1   |
|           | 03 | Set counter done                                 | BOOLEAN          | 1   |
|           | 04 | Counter underflow                                | BOOLEAN          | 1   |
|           | 05 | Counter overflow                                 | BOOLEAN          | 1   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | Status of extern latch                           | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Counter value                                    | UNSIGNED32       | 32  |
|           | 12 | Latch value                                      | UNSIGNED32       | 32  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 32  |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 32  |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | Timestamp                                        | UNSIGNED32       | 32  |
| 0x6010    | 15 | STM Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Ready to enable                                  | BOOLEAN          | 1   |
|           | 02 | Ready                                            | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Moving positive                                  | BOOLEAN          | 1   |
|           | 06 | Moving negative                                  | BOOLEAN          | 1   |
|           | 07 | Torque reduced                                   | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | Digital input 1                                  | BOOLEAN          | 1   |
|           | 0d | Digital input 2                                  | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Info data 1                                      | UNSIGNED16       | 16  |
|           | 12 | Info data 2                                      | UNSIGNED16       | 16  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 16  |
|           | 14 | Internal position                                | UNSIGNED32       | 32  |
|           | 15 | External position                                | UNSIGNED32       | 32  |
| 0x6020    | 23 | POS Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Busy                                             | BOOLEAN          | 1   |
|           | 02 | In-Target                                        | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Calibrated                                       | BOOLEAN          | 1   |
|           | 06 | Accelerate                                       | BOOLEAN          | 1   |
|           | 07 | Decelerate                                       | BOOLEAN          | 1   |
|           | 08 | Ready to execute                                 | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Actual velocity                                  | INTEGER16        | 16  |
|           | 22 | Actual drive time                                | UNSIGNED32       | 32  |
|           | 23 | Actual position lag                              | INTEGER32        | 32  |
| 0x6030    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 7   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6040    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 7   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |

#### CoE: Object Description List: Stored for Device Replacement

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 4a | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 0   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 0   |
|           | 44 | SubIndex 068                                     | UNKNOWN          | 0   |
|           | 45 | Digital input emulation 1                        | INVALID          | 4   |
|           | 46 | SubIndex 070                                     | UNKNOWN          | 0   |
|           | 47 | SubIndex 071                                     | UNKNOWN          | 0   |
|           | 48 | SubIndex 072                                     | UNKNOWN          | 0   |
|           | 49 | Digital input emulation 2                        | INVALID          | 4   |
|           | 4a | SubIndex 074                                     | UNKNOWN          | 4   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |
| 0x8030    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
| 0x8040    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |

#### CoE: Object Description List: Startup Parameters

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 4a | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 0   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 0   |
|           | 44 | SubIndex 068                                     | UNKNOWN          | 0   |
|           | 45 | Digital input emulation 1                        | INVALID          | 4   |
|           | 46 | SubIndex 070                                     | UNKNOWN          | 0   |
|           | 47 | SubIndex 071                                     | UNKNOWN          | 0   |
|           | 48 | SubIndex 072                                     | UNKNOWN          | 0   |
|           | 49 | Digital input emulation 2                        | INVALID          | 4   |
|           | 4a | SubIndex 074                                     | UNKNOWN          | 4   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |
| 0x8030    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
| 0x8040    | 15 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 4   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |

### Subdevice 4(0x1004): EL3062 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     4  |
| Auto-increment address | 0xfffc |
| Station address        | 0x1004 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL3062 |
| Name             | EL3062 2K.Ana. Eingang 0-10V |
| Group            | AnaIn |
| Vendor ID        | 0x00000002 |
| Product code     | 0x0bf63052 |
| Revision number  | 0x00100000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: CoE FoE 

Default mailbox configuration:

    Mailbox out: offset: 0x1000 size: 128
    Mailbox in:  offset: 0x1080 size: 128

Bootstrap mailbox configuration:

    Mailbox out: offset: 0x1000 size: 244
    Mailbox in:  offset: 0x10f4 size: 244

#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| coe_details.enable_SDO                 |  true |
| coe_details.enable_SDO_info            |  true |
| coe_details.enable_PDO_assign          |  true |
| coe_details.enable_PDO_configuration   | false |
| coe_details.enable_upload_at_startup   | false |
| coe_details.enable_SDO_complete_access | false |
| foe_details.enable_foe                 |  true |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          |  true |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: mailbox_out
    physical start addr: 0x1000
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM1

    type: mailbox_in
    physical start addr: 0x1080
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM2

    type: process_data_outputs
    physical start addr: 0x1100
    length: 0
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       false
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      false
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM3

    type: process_data_inputs
    physical start addr: 0x1180
    length: 8
    control:
        buffer_type                 .buffered
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false



#### SII Catagory: TxPDOs

    Inputs bit length: 64   
| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |                  | AI Standard Channel 1      |
|        |     | 0x6000:01 |   1 | BOOLEAN          | Underrange                 |
|        |     | 0x6000:02 |   1 | BOOLEAN          | Overrange                  |
|        |     | 0x6000:03 |   2 | BIT2             | Limit 1                    |
|        |     | 0x6000:05 |   2 | BIT2             | Limit 2                    |
|        |     | 0x6000:07 |   1 | BOOLEAN          | Error                      |
|        |     | 0x0000:00 |   7 | UNKNOWN          |                            |
|        |     | 0x1800:07 |   1 | BOOLEAN          | TxPDO State                |
|        |     | 0x1800:09 |   1 | BOOLEAN          | TxPDO Toggle               |
|        |     | 0x6000:11 |  16 | INTEGER16        | Value                      |
| 0x1a01 | 255 |           |  16 |                  | AI Compact Channel 1       |
|        |     | 0x6000:11 |  16 | INTEGER16        | Value                      |
| 0x1a02 |   3 |           |  32 |                  | AI Standard Channel 2      |
|        |     | 0x6010:01 |   1 | BOOLEAN          | Underrange                 |
|        |     | 0x6010:02 |   1 | BOOLEAN          | Overrange                  |
|        |     | 0x6010:03 |   2 | BIT2             | Limit 1                    |
|        |     | 0x6010:05 |   2 | BIT2             | Limit 2                    |
|        |     | 0x6010:07 |   1 | BOOLEAN          | Error                      |
|        |     | 0x0000:00 |   7 | UNKNOWN          |                            |
|        |     | 0x1802:07 |   1 | BOOLEAN          | TxPDO State                |
|        |     | 0x1802:09 |   1 | BOOLEAN          | TxPDO Toggle               |
|        |     | 0x6010:11 |  16 | INTEGER16        | Value                      |
| 0x1a03 | 255 |           |  16 |                  | AI Compact Channel 2       |
|        |     | 0x6010:11 |  16 | INTEGER16        | Value                      |

#### SII Catagory: RxPDOs

No RxPDOs catagory.

#### CoE: Sync Manager Communication Types

| SM  | Purpose          |
|---  |---               |
| 0   | mailbox_out      |
| 1   | mailbox_in       |
| 2   | output           |
| 3   | input            |

#### CoE: PDO Assignment

| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6000:01 |   1 |         | Underrange                                                      |
|        |     | 0x6000:02 |   1 |         | Overrange                                                       |
|        |     | 0x6000:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6000:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6000:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   5 | PADDING |                                                                 |
|        |     | 0x1800:07 |   1 |         | TxPDO State                                                     |
|        |     | 0x1800:09 |   1 |         | TxPDO Toggle                                                    |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6000:11 |  16 |         | Value                                                           |
| 0x1a02 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6010:01 |   1 |         | Underrange                                                      |
|        |     | 0x6010:02 |   1 |         | Overrange                                                       |
|        |     | 0x6010:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6010:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6010:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   5 | PADDING |                                                                 |
|        |     | 0x1802:07 |   1 |         | TxPDO State                                                     |
|        |     | 0x1802:09 |   1 |         | TxPDO Toggle                                                    |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6010:11 |  16 |         | Value                                                           |


#### CoE: Object Description Lists

| List                             | Length |
|---                               |---     |
| all_objects                      |     42 |
| rx_pdo_mappable                  |      0 |
| tx_pdo_mappable                  |      2 |
| stored_for_device_replacement    |      2 |
| startup_parameters               |      2 |

#### CoE: Object Description List: All Objects

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x1000    | 00 | Device type                                      | UNSIGNED32       |     |
| 0x1008    | 00 | Device name                                      | VISIBLE_STRING   |     |
| 0x1009    | 00 | Hardware version                                 | VISIBLE_STRING   |     |
| 0x100a    | 00 | Software version                                 | VISIBLE_STRING   |     |
| 0x1011    | 01 | Restore default parameters                       | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1018    | 04 | Identity                                         | IDENTITY         |     |
|           | 01 | Vendor ID                                        | UNSIGNED32       | 32  |
|           | 02 | Product code                                     | UNSIGNED32       | 32  |
|           | 03 | Revision                                         | UNSIGNED32       | 32  |
|           | 04 | Serial number                                    | UNSIGNED32       | 32  |
| 0x10f0    | 01 | Backup parameter handling                        | INVALID          |     |
|           | 01 | Checksum                                         | UNSIGNED32       | 32  |
| 0x1800    | 09 | üAI TxPDO-Par Standard Ch.1                      | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
|           | 07 | TxPDO State                                      | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | TxPDO Toggle                                     | BOOLEAN          | 1   |
| 0x1801    | 09 | AI TxPDO-Par Compact Ch.1                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
| 0x1802    | 09 | AI TxPDO-Par Standard Ch.2                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
|           | 07 | TxPDO State                                      | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | TxPDO Toggle                                     | BOOLEAN          | 1   |
| 0x1803    | 09 | AI TxPDO-Par Compact Ch.2                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
| 0x1a00    | 0b | üAI TxPDO-Map Standard Ch.1                      | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
| 0x1a01    | 0b | AI TxPDO-Map Compact Ch.1                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
| 0x1a02    | 0b | AI TxPDO-Map Standard Ch.2                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
| 0x1a03    | 0b | AI TxPDO-Map Compact Ch.2                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
| 0x1c00    | 04 | Sync manager type                                | UNSIGNED8        |     |
|           | 01 | SubIndex 001                                     | UNSIGNED8        | 8   |
|           | 02 | SubIndex 002                                     | UNSIGNED8        | 8   |
|           | 03 | SubIndex 003                                     | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNSIGNED8        | 8   |
| 0x1c12    | 00 | RxPDO assign                                     | UNSIGNED16       |     |
| 0x1c13    | 02 | TxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
| 0x1c33    | 20 | SM input parameter                               | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum fast cycle time                          | UNKNOWN          | 0   |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Delay time                                       | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x6000    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x8000    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x800e    | 01 | AI Internal data                                 | INTEGER8         |     |
|           | 01 | ADC raw value 1                                  | INTEGER16        | 16  |
| 0x800f    | 02 | AI Vendor data                                   | INTEGER16        |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x801e    | 01 | AI Internal data                                 | INTEGER8         |     |
|           | 01 | ADC raw value 1                                  | INTEGER16        | 16  |
| 0x801f    | 02 | AI Vendor data                                   | INTEGER16        |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0xf000    | 02 | Modular device profile                           | INVALID          |     |
|           | 01 | Module index distance                            | UNSIGNED16       | 16  |
|           | 02 | Maximum number of modules                        | UNSIGNED16       | 16  |
| 0xf008    | 00 | Code word                                        | UNSIGNED32       |     |
| 0xf010    | 02 | Module list                                      | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
| 0x6000    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x8000    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8000    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | BOOLEAN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 5   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |

#### CoE: Object Description List: RxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|

#### CoE: Object Description List: TxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|

#### CoE: Object Description List: Stored for Device Replacement

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|

#### CoE: Object Description List: Startup Parameters

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|

### Subdevice 5(0x1005): EL7041 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     5  |
| Auto-increment address | 0xfffb |
| Station address        | 0x1005 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL7041 |
| Name             | EL7041 1K. Schrittmotor-Endstufe (50V, 5A) |
| Group            | DriveAxisTerminals |
| Vendor ID        | 0x00000002 |
| Product code     | 0x1b813052 |
| Revision number  | 0x00190000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = true,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = false,
    .port1_rx_signal_det = true,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: CoE FoE 

Default mailbox configuration:

    Mailbox out: offset: 0x1000 size: 128
    Mailbox in:  offset: 0x1080 size: 128

Bootstrap mailbox configuration:

    Mailbox out: offset: 0x1000 size: 244
    Mailbox in:  offset: 0x10f4 size: 244

#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| coe_details.enable_SDO                 |  true |
| coe_details.enable_SDO_info            |  true |
| coe_details.enable_PDO_assign          |  true |
| coe_details.enable_PDO_configuration   | false |
| coe_details.enable_upload_at_startup   | false |
| coe_details.enable_SDO_complete_access |  true |
| foe_details.enable_foe                 |  true |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          |  true |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: mailbox_out
    physical start addr: 0x1000
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM1

    type: mailbox_in
    physical start addr: 0x1080
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM2

    type: process_data_outputs
    physical start addr: 0x1100
    length: 8
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM3

    type: process_data_inputs
    physical start addr: 0x1180
    length: 8
    control:
        buffer_type                 .buffered
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false



#### SII Catagory: TxPDOs

No TxPDOs catagory.

#### SII Catagory: RxPDOs

No RxPDOs catagory.

#### CoE: Sync Manager Communication Types

| SM  | Purpose          |
|---  |---               |
| 0   | mailbox_out      |
| 1   | mailbox_in       |
| 2   | output           |
| 3   | input            |

#### CoE: PDO Assignment

| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1600 |   2 |           |  32 |         |                                                                 |
|        |     | 0x7000:01 |   1 |         | Enable latch C                                                  |
|        |     | 0x7000:02 |   1 |         | Enable latch extern on positive edge                            |
|        |     | 0x7000:03 |   1 |         | Set counter                                                     |
|        |     | 0x7000:04 |   1 |         | Enable latch extern on negative edge                            |
|        |     |           |   4 | PADDING |                                                                 |
|        |     |           |   8 | PADDING |                                                                 |
|        |     | 0x7000:11 |  16 |         | Set counter value                                               |
| 0x1602 |   2 |           |  16 |         |                                                                 |
|        |     | 0x7010:01 |   1 |         | Enable                                                          |
|        |     | 0x7010:02 |   1 |         | Reset                                                           |
|        |     | 0x7010:03 |   1 |         | Reduce torque                                                   |
|        |     |           |   5 | PADDING |                                                                 |
|        |     |           |   8 | PADDING |                                                                 |
| 0x1604 |   2 |           |  16 |         |                                                                 |
|        |     | 0x7010:21 |  16 |         | Velocity                                                        |
| 0x1a00 |   3 |           |  48 |         |                                                                 |
|        |     | 0x6000:01 |   1 |         | Latch C valid                                                   |
|        |     | 0x6000:02 |   1 |         | Latch extern valid                                              |
|        |     | 0x6000:03 |   1 |         | Set counter done                                                |
|        |     | 0x6000:04 |   1 |         | Counter underflow                                               |
|        |     | 0x6000:05 |   1 |         | Counter overflow                                                |
|        |     |           |   2 | PADDING |                                                                 |
|        |     | 0x6000:08 |   1 |         | Extrapolation stall                                             |
|        |     | 0x6000:09 |   1 |         | Status of input A                                               |
|        |     | 0x6000:0a |   1 |         | Status of input B                                               |
|        |     | 0x6000:0b |   1 |         | Status of input C                                               |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6000:0d |   1 |         | Status of extern latch                                          |
|        |     | 0x6000:0e |   1 |         | Sync error                                                      |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6000:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6000:11 |  16 |         | Counter value                                                   |
|        |     | 0x6000:12 |  16 |         | Latch value                                                     |
| 0x1a03 |   3 |           |  16 |         |                                                                 |
|        |     | 0x6010:01 |   1 |         | Ready to enable                                                 |
|        |     | 0x6010:02 |   1 |         | Ready                                                           |
|        |     | 0x6010:03 |   1 |         | Warning                                                         |
|        |     | 0x6010:04 |   1 |         | Error                                                           |
|        |     | 0x6010:05 |   1 |         | Moving positive                                                 |
|        |     | 0x6010:06 |   1 |         | Moving negative                                                 |
|        |     | 0x6010:07 |   1 |         | Torque reduced                                                  |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   3 | PADDING |                                                                 |
|        |     | 0x6010:0c |   1 |         | Digital input 1                                                 |
|        |     | 0x6010:0d |   1 |         | Digital input 2                                                 |
|        |     | 0x6010:0e |   1 |         | Sync error                                                      |
|        |     |           |   1 | PADDING |                                                                 |
|        |     | 0x6010:10 |   1 |         | TxPDO Toggle                                                    |


#### CoE: Object Description Lists

| List                             | Length |
|---                               |---     |
| all_objects                      |     67 |
| rx_pdo_mappable                  |      4 |
| tx_pdo_mappable                  |      3 |
| stored_for_device_replacement    |      7 |
| startup_parameters               |      7 |

#### CoE: Object Description List: All Objects

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x1000    | 00 | Device type                                      | UNSIGNED32       |     |
| 0x1008    | 00 | Device name                                      | VISIBLE_STRING   |     |
| 0x1009    | 00 | Hardware version                                 | VISIBLE_STRING   |     |
| 0x100a    | 00 | Software version                                 | VISIBLE_STRING   |     |
| 0x1011    | 01 | Restore default parameters                       | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1018    | 04 | Identity                                         | IDENTITY         |     |
|           | 01 | Vendor ID                                        | UNSIGNED32       | 32  |
|           | 02 | Product code                                     | UNSIGNED32       | 32  |
|           | 03 | Revision                                         | UNSIGNED32       | 32  |
|           | 04 | Serial number                                    | UNSIGNED32       | 32  |
| 0x10f0    | 01 | Backup parameter handling                        | INVALID          |     |
|           | 01 | Checksum                                         | UNSIGNED32       | 32  |
| 0x10f3    | 37 | Diagnosis History                                | INVALID          |     |
|           | 01 | Maximum Messages                                 | UNSIGNED8        | 8   |
|           | 02 | Newest Message                                   | UNSIGNED8        | 8   |
|           | 03 | Newest Acknowledged Message                      | UNSIGNED8        | 8   |
|           | 04 | New Messages Available                           | BOOLEAN          | 1   |
|           | 05 | Flags                                            | UNSIGNED16       | 16  |
|           | 06 | Diagnosis Message 001                            | OCTET_STRING     | 224 |
|           | 07 | Diagnosis Message 002                            | OCTET_STRING     | 224 |
|           | 08 | Diagnosis Message 003                            | OCTET_STRING     | 224 |
|           | 09 | Diagnosis Message 004                            | OCTET_STRING     | 224 |
|           | 0a | Diagnosis Message 005                            | OCTET_STRING     | 224 |
|           | 0b | Diagnosis Message 006                            | OCTET_STRING     | 224 |
|           | 0c | Diagnosis Message 007                            | OCTET_STRING     | 224 |
|           | 0d | Diagnosis Message 008                            | OCTET_STRING     | 224 |
|           | 0e | Diagnosis Message 009                            | OCTET_STRING     | 224 |
|           | 0f | Diagnosis Message 010                            | OCTET_STRING     | 224 |
|           | 10 | Diagnosis Message 011                            | OCTET_STRING     | 224 |
|           | 11 | Diagnosis Message 012                            | OCTET_STRING     | 224 |
|           | 12 | Diagnosis Message 013                            | OCTET_STRING     | 224 |
|           | 13 | Diagnosis Message 014                            | OCTET_STRING     | 224 |
|           | 14 | Diagnosis Message 015                            | OCTET_STRING     | 224 |
|           | 15 | Diagnosis Message 016                            | OCTET_STRING     | 224 |
|           | 16 | Diagnosis Message 017                            | OCTET_STRING     | 224 |
|           | 17 | Diagnosis Message 018                            | OCTET_STRING     | 224 |
|           | 18 | Diagnosis Message 019                            | OCTET_STRING     | 224 |
|           | 19 | Diagnosis Message 020                            | OCTET_STRING     | 224 |
|           | 1a | Diagnosis Message 021                            | OCTET_STRING     | 224 |
|           | 1b | Diagnosis Message 022                            | OCTET_STRING     | 224 |
|           | 1c | Diagnosis Message 023                            | OCTET_STRING     | 224 |
|           | 1d | Diagnosis Message 024                            | OCTET_STRING     | 224 |
|           | 1e | Diagnosis Message 025                            | OCTET_STRING     | 224 |
|           | 1f | Diagnosis Message 026                            | OCTET_STRING     | 224 |
|           | 20 | Diagnosis Message 027                            | OCTET_STRING     | 224 |
|           | 21 | Diagnosis Message 028                            | OCTET_STRING     | 224 |
|           | 22 | Diagnosis Message 029                            | OCTET_STRING     | 224 |
|           | 23 | Diagnosis Message 030                            | OCTET_STRING     | 224 |
|           | 24 | Diagnosis Message 031                            | OCTET_STRING     | 224 |
|           | 25 | Diagnosis Message 032                            | OCTET_STRING     | 224 |
|           | 26 | Diagnosis Message 033                            | OCTET_STRING     | 224 |
|           | 27 | Diagnosis Message 034                            | OCTET_STRING     | 224 |
|           | 28 | Diagnosis Message 035                            | OCTET_STRING     | 224 |
|           | 29 | Diagnosis Message 036                            | OCTET_STRING     | 224 |
|           | 2a | Diagnosis Message 037                            | OCTET_STRING     | 224 |
|           | 2b | Diagnosis Message 038                            | OCTET_STRING     | 224 |
|           | 2c | Diagnosis Message 039                            | OCTET_STRING     | 224 |
|           | 2d | Diagnosis Message 040                            | OCTET_STRING     | 224 |
|           | 2e | Diagnosis Message 041                            | OCTET_STRING     | 224 |
|           | 2f | Diagnosis Message 042                            | OCTET_STRING     | 224 |
|           | 30 | Diagnosis Message 043                            | OCTET_STRING     | 224 |
|           | 31 | Diagnosis Message 044                            | OCTET_STRING     | 224 |
|           | 32 | Diagnosis Message 045                            | OCTET_STRING     | 224 |
|           | 33 | Diagnosis Message 046                            | OCTET_STRING     | 224 |
|           | 34 | Diagnosis Message 047                            | OCTET_STRING     | 224 |
|           | 35 | Diagnosis Message 048                            | OCTET_STRING     | 224 |
|           | 36 | Diagnosis Message 049                            | OCTET_STRING     | 224 |
|           | 37 | Diagnosis Message 050                            | OCTET_STRING     | 224 |
| 0x10f8    | 00 | Actual Time Stamp                                | UNSIGNED64       |     |
| 0x1400    | 06 | ENC RxPDO-Par Control compact                    | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1401    | 06 | ENC RxPDO-Par Control                            | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1403    | 06 | STM RxPDO-Par Position                           | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1404    | 06 | STM RxPDO-Par Velocity                           | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1405    | 06 | POS RxPDO-Par Control compact                    | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1406    | 06 | POS RxPDO-Par Control                            | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1407    | 06 | POS RxPDO-Par Control 2                          | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude RxPDOs                                   | OCTET_STRING     | 48  |
| 0x1600    | 07 | ENC RxPDO-Map Control compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
| 0x1601    | 07 | ENC RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
| 0x1602    | 05 | STM RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
| 0x1603    | 01 | STM RxPDO-Map Position                           | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1604    | 01 | STM RxPDO-Map Velocity                           | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1605    | 05 | POS RxPDO-Map Control compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
| 0x1606    | 09 | POS RxPDO-Map Control                            | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1607    | 08 | POS RxPDO-Map Control 2                          | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
| 0x1800    | 06 | ENC TxPDO-Par Status compact                     | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1801    | 06 | ENC TxPDO-Par Status                             | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1805    | 06 | POS TxPDO-Par Status compact                     | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1806    | 06 | POS TxPDO-Par Status                             | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1a00    | 11 | ENC TxPDO-Map Status compact                     | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
|           | 0e | SubIndex 014                                     | UNSIGNED32       | 32  |
|           | 0f | SubIndex 015                                     | UNSIGNED32       | 32  |
|           | 10 | SubIndex 016                                     | UNSIGNED32       | 32  |
|           | 11 | SubIndex 017                                     | UNSIGNED32       | 32  |
| 0x1a01    | 11 | ENC TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
|           | 0e | SubIndex 014                                     | UNSIGNED32       | 32  |
|           | 0f | SubIndex 015                                     | UNSIGNED32       | 32  |
|           | 10 | SubIndex 016                                     | UNSIGNED32       | 32  |
|           | 11 | SubIndex 017                                     | UNSIGNED32       | 32  |
| 0x1a02    | 01 | ENC TxPDO-Map Timest. compact                    | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a03    | 0e | STM TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
|           | 0d | SubIndex 013                                     | UNSIGNED32       | 32  |
|           | 0e | SubIndex 014                                     | UNSIGNED32       | 32  |
| 0x1a04    | 02 | STM TxPDO-Map Synchron info data                 | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
| 0x1a05    | 09 | POS TxPDO-Map Status compact                     | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
| 0x1a06    | 0c | POS TxPDO-Map Status                             | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
|           | 0b | SubIndex 011                                     | UNSIGNED32       | 32  |
|           | 0c | SubIndex 012                                     | UNSIGNED32       | 32  |
| 0x1a07    | 01 | STM TxPDO-Map Internal position                  | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a08    | 01 | STM TxPDO-Map External position                  | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1c00    | 04 | Sync manager type                                | UNSIGNED8        |     |
|           | 01 | SubIndex 001                                     | UNSIGNED8        | 8   |
|           | 02 | SubIndex 002                                     | UNSIGNED8        | 8   |
|           | 03 | SubIndex 003                                     | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNSIGNED8        | 8   |
| 0x1c12    | 04 | RxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
| 0x1c13    | 07 | TxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
|           | 05 | SubIndex 005                                     | UNSIGNED16       | 16  |
|           | 06 | SubIndex 006                                     | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNSIGNED16       | 16  |
| 0x1c32    | 20 | SM output parameter                              | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x1c33    | 20 | SM input parameter                               | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x6000    | 16 | ENC Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Latch C valid                                    | BOOLEAN          | 1   |
|           | 02 | Latch extern valid                               | BOOLEAN          | 1   |
|           | 03 | Set counter done                                 | BOOLEAN          | 1   |
|           | 04 | Counter underflow                                | BOOLEAN          | 1   |
|           | 05 | Counter overflow                                 | BOOLEAN          | 1   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 1   |
|           | 08 | Extrapolation stall                              | BOOLEAN          | 1   |
|           | 09 | Status of input A                                | BOOLEAN          | 1   |
|           | 0a | Status of input B                                | BOOLEAN          | 1   |
|           | 0b | Status of input C                                | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | Status of extern latch                           | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Counter value                                    | UNSIGNED32       | 32  |
|           | 12 | Latch value                                      | UNSIGNED32       | 32  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 32  |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 32  |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | Timestamp                                        | UNSIGNED32       | 32  |
| 0x6010    | 15 | STM Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Ready to enable                                  | BOOLEAN          | 1   |
|           | 02 | Ready                                            | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Moving positive                                  | BOOLEAN          | 1   |
|           | 06 | Moving negative                                  | BOOLEAN          | 1   |
|           | 07 | Torque reduced                                   | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | Digital input 1                                  | BOOLEAN          | 1   |
|           | 0d | Digital input 2                                  | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Info data 1                                      | UNSIGNED16       | 16  |
|           | 12 | Info data 2                                      | UNSIGNED16       | 16  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 16  |
|           | 14 | Internal position                                | UNSIGNED32       | 32  |
|           | 15 | External position                                | UNSIGNED32       | 32  |
| 0x6020    | 22 | POS Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Busy                                             | BOOLEAN          | 1   |
|           | 02 | In-Target                                        | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Calibrated                                       | BOOLEAN          | 1   |
|           | 06 | Accelerate                                       | BOOLEAN          | 1   |
|           | 07 | Decelerate                                       | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Actual velocity                                  | INTEGER16        | 16  |
|           | 22 | Actual drive time                                | UNSIGNED32       | 32  |
| 0x7000    | 11 | ENC Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable latch C                                   | BOOLEAN          | 1   |
|           | 02 | Enable latch extern on positive edge             | BOOLEAN          | 1   |
|           | 03 | Set counter                                      | BOOLEAN          | 1   |
|           | 04 | Enable latch extern on negative edge             | BOOLEAN          | 1   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 4   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Set counter value                                | UNSIGNED32       | 32  |
| 0x7010    | 21 | STM Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable                                           | BOOLEAN          | 1   |
|           | 02 | Reset                                            | BOOLEAN          | 1   |
|           | 03 | Reduce torque                                    | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Position                                         | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
| 0x7020    | 24 | POS Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Execute                                          | BOOLEAN          | 1   |
|           | 02 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x7021    | 24 | POS Outputs 2 Ch.1                               | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | Enable auto start                                | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Disable filter                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable micro increments                          | BOOLEAN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | Encoder increments (4-fold)                      | UNSIGNED16       | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 43 | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Feedback type                                    | INVALID          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 4   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 8   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |
| 0x9010    | 13 | STM Info data Ch.1                               | UNKNOWN          |     |
|           | 01 | Status word                                      | UNSIGNED16       | 16  |
|           | 02 | Motor coil voltage A                             | UNSIGNED16       | 16  |
|           | 03 | Motor coil voltage B                             | UNSIGNED16       | 16  |
|           | 04 | Motor coil current A                             | INTEGER16        | 16  |
|           | 05 | Motor coil current B                             | INTEGER16        | 16  |
|           | 06 | Duty cycle A                                     | INTEGER8         | 8   |
|           | 07 | Duty cycle B                                     | INTEGER8         | 8   |
|           | 08 | Motor velocity                                   | INTEGER16        | 16  |
|           | 09 | Internal position                                | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | External position                                | UNSIGNED32       | 32  |
| 0x9020    | 04 | POS Info data Ch.1                               | UNKNOWN          |     |
|           | 01 | Status word                                      | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | State (drive controller)                         | INVALID          | 16  |
|           | 04 | Actual position lag                              | INTEGER32        | 32  |
| 0xa010    | 13 | STM Diag data Ch.1                               | UNKNOWN          |     |
|           | 01 | Saturated                                        | BOOLEAN          | 1   |
|           | 02 | Over temperature                                 | BOOLEAN          | 1   |
|           | 03 | Torque overload                                  | BOOLEAN          | 1   |
|           | 04 | Under voltage                                    | BOOLEAN          | 1   |
|           | 05 | Over voltage                                     | BOOLEAN          | 1   |
|           | 06 | Short circuit A                                  | BOOLEAN          | 1   |
|           | 07 | Short circuit B                                  | BOOLEAN          | 1   |
|           | 08 | No control power                                 | BOOLEAN          | 1   |
|           | 09 | Misc error                                       | BOOLEAN          | 1   |
|           | 0a | Configuration                                    | BOOLEAN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 6   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual operation mode                            | INVALID          | 4   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 4   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 8   |
| 0xa020    | 08 | POS Diag data Ch.1                               | UNKNOWN          |     |
|           | 01 | Command rejected                                 | BOOLEAN          | 1   |
|           | 02 | Command aborted                                  | BOOLEAN          | 1   |
|           | 03 | Target overrun                                   | BOOLEAN          | 1   |
|           | 04 | Target timeout                                   | BOOLEAN          | 1   |
|           | 05 | Position lag                                     | BOOLEAN          | 1   |
|           | 06 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 2   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 8   |
| 0xf000    | 02 | Modular device profile                           | INVALID          |     |
|           | 01 | Module index distance                            | UNSIGNED16       | 16  |
|           | 02 | Maximum number of modules                        | UNSIGNED16       | 16  |
| 0xf008    | 00 | Code word                                        | UNSIGNED32       |     |
| 0xf010    | 03 | Module list                                      | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
| 0xf081    | 01 | Download revision                                | UNKNOWN          |     |
|           | 01 | Revision number                                  | UNSIGNED32       | 32  |
| 0xf80f    | 08 | STM Vendor data                                  | UNKNOWN          |     |
|           | 01 | PWM Frequency                                    | UNSIGNED16       | 16  |
|           | 02 | Deadtime                                         | UNSIGNED16       | 16  |
|           | 03 | Deadtime space                                   | UNSIGNED16       | 16  |
|           | 04 | Warning temperature                              | INTEGER8         | 8   |
|           | 05 | Switch off temperature                           | INTEGER8         | 8   |
|           | 06 | Analog trigger point                             | UNSIGNED16       | 16  |
|           | 07 | Calibration offset A                             | INTEGER16        | 16  |
|           | 08 | Calibration offset B                             | INTEGER16        | 16  |
| 0xf900    | 06 | STM Info data                                    | UNKNOWN          |     |
|           | 01 | Software version (driver)                        | VISIBLE_STRING   | 16  |
|           | 02 | Internal temperature                             | INTEGER8         | 8   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 8   |
|           | 04 | Control voltage                                  | UNSIGNED16       | 16  |
|           | 05 | Motor supply voltage                             | UNSIGNED16       | 16  |
|           | 06 | Cycle time                                       | UNSIGNED16       | 16  |
| 0xfb00    | 04 | STM Command                                      | UNKNOWN          |     |
|           | 01 | Request                                          | OCTET_STRING     | 16  |
|           | 02 | Status                                           | UNSIGNED8        | 8   |
|           | 03 | Response                                         | OCTET_STRING     | 32  |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 8   |

#### CoE: Object Description List: RxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x7000    | 11 | ENC Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable latch C                                   | BOOLEAN          | 1   |
|           | 02 | Enable latch extern on positive edge             | BOOLEAN          | 1   |
|           | 03 | Set counter                                      | BOOLEAN          | 1   |
|           | 04 | Enable latch extern on negative edge             | BOOLEAN          | 1   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 4   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Set counter value                                | UNSIGNED32       | 32  |
| 0x7010    | 21 | STM Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Enable                                           | BOOLEAN          | 1   |
|           | 02 | Reset                                            | BOOLEAN          | 1   |
|           | 03 | Reduce torque                                    | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 3   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Position                                         | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
| 0x7020    | 24 | POS Outputs Ch.1                                 | UNKNOWN          |     |
|           | 01 | Execute                                          | BOOLEAN          | 1   |
|           | 02 | Emergency stop                                   | BOOLEAN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |
| 0x7021    | 24 | POS Outputs 2 Ch.1                               | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | Enable auto start                                | BOOLEAN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 5   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Target position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Velocity                                         | INTEGER16        | 16  |
|           | 22 | Start type                                       | UNSIGNED16       | 16  |
|           | 23 | Acceleration                                     | UNSIGNED16       | 16  |
|           | 24 | Deceleration                                     | UNSIGNED16       | 16  |

#### CoE: Object Description List: TxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x6000    | 16 | ENC Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Latch C valid                                    | BOOLEAN          | 1   |
|           | 02 | Latch extern valid                               | BOOLEAN          | 1   |
|           | 03 | Set counter done                                 | BOOLEAN          | 1   |
|           | 04 | Counter underflow                                | BOOLEAN          | 1   |
|           | 05 | Counter overflow                                 | BOOLEAN          | 1   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 1   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 1   |
|           | 08 | Extrapolation stall                              | BOOLEAN          | 1   |
|           | 09 | Status of input A                                | BOOLEAN          | 1   |
|           | 0a | Status of input B                                | BOOLEAN          | 1   |
|           | 0b | Status of input C                                | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | Status of extern latch                           | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Counter value                                    | UNSIGNED32       | 32  |
|           | 12 | Latch value                                      | UNSIGNED32       | 32  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 32  |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 32  |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | Timestamp                                        | UNSIGNED32       | 32  |
| 0x6010    | 15 | STM Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Ready to enable                                  | BOOLEAN          | 1   |
|           | 02 | Ready                                            | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Moving positive                                  | BOOLEAN          | 1   |
|           | 06 | Moving negative                                  | BOOLEAN          | 1   |
|           | 07 | Torque reduced                                   | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 3   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | Digital input 1                                  | BOOLEAN          | 1   |
|           | 0d | Digital input 2                                  | BOOLEAN          | 1   |
|           | 0e | Sync error                                       | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Info data 1                                      | UNSIGNED16       | 16  |
|           | 12 | Info data 2                                      | UNSIGNED16       | 16  |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 16  |
|           | 14 | Internal position                                | UNSIGNED32       | 32  |
|           | 15 | External position                                | UNSIGNED32       | 32  |
| 0x6020    | 22 | POS Inputs Ch.1                                  | UNKNOWN          |     |
|           | 01 | Busy                                             | BOOLEAN          | 1   |
|           | 02 | In-Target                                        | BOOLEAN          | 1   |
|           | 03 | Warning                                          | BOOLEAN          | 1   |
|           | 04 | Error                                            | BOOLEAN          | 1   |
|           | 05 | Calibrated                                       | BOOLEAN          | 1   |
|           | 06 | Accelerate                                       | BOOLEAN          | 1   |
|           | 07 | Decelerate                                       | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 8   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Actual position                                  | UNSIGNED32       | 32  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | Actual velocity                                  | INTEGER16        | 16  |
|           | 22 | Actual drive time                                | UNSIGNED32       | 32  |

#### CoE: Object Description List: Stored for Device Replacement

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Disable filter                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable micro increments                          | BOOLEAN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | Encoder increments (4-fold)                      | UNSIGNED16       | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 43 | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Feedback type                                    | INVALID          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 4   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 8   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |

#### CoE: Object Description List: Startup Parameters

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 12 | ENC Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 1   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 1   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 1   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 2   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 2   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Disable filter                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable micro increments                          | BOOLEAN          | 1   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 1   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 1   |
|           | 0e | Reversion of rotation                            | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 1   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 1   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 16  |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 32  |
| 0x8010    | 11 | STM Motor Settings Ch.1                          | UNKNOWN          |     |
|           | 01 | Maximal current                                  | UNSIGNED16       | 16  |
|           | 02 | Reduced current                                  | UNSIGNED16       | 16  |
|           | 03 | Nominal voltage                                  | UNSIGNED16       | 16  |
|           | 04 | Motor coil resistance                            | UNSIGNED16       | 16  |
|           | 05 | Motor EMF                                        | UNSIGNED16       | 16  |
|           | 06 | Motor fullsteps                                  | UNSIGNED16       | 16  |
|           | 07 | Encoder increments (4-fold)                      | UNSIGNED16       | 16  |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 16  |
|           | 09 | Start velocity                                   | UNSIGNED16       | 16  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | Drive on delay time                              | UNSIGNED16       | 16  |
|           | 11 | Drive off delay time                             | UNSIGNED16       | 16  |
| 0x8011    | 08 | STM Controller Settings Ch.1                     | UNKNOWN          |     |
|           | 01 | Kp factor (curr.)                                | UNSIGNED16       | 16  |
|           | 02 | Ki factor (curr.)                                | UNSIGNED16       | 16  |
|           | 03 | Inner window (curr.)                             | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (curr.)                             | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (curr.)                 | UNSIGNED16       | 16  |
|           | 07 | Ka factor (curr.)                                | UNSIGNED16       | 16  |
|           | 08 | Kd factor (curr.)                                | UNSIGNED16       | 16  |
| 0x8012    | 43 | STM Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Operation mode                                   | INVALID          | 4   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Speed range                                      | INVALID          | 3   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | Feedback type                                    | INVALID          | 1   |
|           | 09 | Invert motor polarity                            | BOOLEAN          | 1   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 7   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Select info data 1                               | INVALID          | 8   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | Select info data 2                               | INVALID          | 8   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | SubIndex 032                                     | UNKNOWN          | 0   |
|           | 21 | SubIndex 033                                     | UNKNOWN          | 8   |
|           | 22 | SubIndex 034                                     | UNKNOWN          | 0   |
|           | 23 | SubIndex 035                                     | UNKNOWN          | 0   |
|           | 24 | SubIndex 036                                     | UNKNOWN          | 0   |
|           | 25 | SubIndex 037                                     | UNKNOWN          | 0   |
|           | 26 | SubIndex 038                                     | UNKNOWN          | 0   |
|           | 27 | SubIndex 039                                     | UNKNOWN          | 0   |
|           | 28 | SubIndex 040                                     | UNKNOWN          | 0   |
|           | 29 | SubIndex 041                                     | UNKNOWN          | 7   |
|           | 2a | SubIndex 042                                     | UNKNOWN          | 0   |
|           | 2b | SubIndex 043                                     | UNKNOWN          | 0   |
|           | 2c | SubIndex 044                                     | UNKNOWN          | 0   |
|           | 2d | SubIndex 045                                     | UNKNOWN          | 0   |
|           | 2e | SubIndex 046                                     | UNKNOWN          | 0   |
|           | 2f | SubIndex 047                                     | UNKNOWN          | 0   |
|           | 30 | Invert digital input 1                           | BOOLEAN          | 1   |
|           | 31 | Invert digital input 2                           | BOOLEAN          | 1   |
|           | 32 | Function for input 1                             | INVALID          | 4   |
|           | 33 | SubIndex 051                                     | UNKNOWN          | 0   |
|           | 34 | SubIndex 052                                     | UNKNOWN          | 0   |
|           | 35 | SubIndex 053                                     | UNKNOWN          | 0   |
|           | 36 | Function for input 2                             | INVALID          | 4   |
|           | 37 | SubIndex 055                                     | UNKNOWN          | 0   |
|           | 38 | SubIndex 056                                     | UNKNOWN          | 0   |
|           | 39 | SubIndex 057                                     | UNKNOWN          | 0   |
|           | 3a | SubIndex 058                                     | UNKNOWN          | 4   |
|           | 3b | SubIndex 059                                     | UNKNOWN          | 0   |
|           | 3c | SubIndex 060                                     | UNKNOWN          | 0   |
|           | 3d | SubIndex 061                                     | UNKNOWN          | 0   |
|           | 3e | SubIndex 062                                     | UNKNOWN          | 3   |
|           | 3f | SubIndex 063                                     | UNKNOWN          | 0   |
|           | 40 | SubIndex 064                                     | UNKNOWN          | 0   |
|           | 41 | SubIndex 065                                     | UNKNOWN          | 4   |
|           | 42 | SubIndex 066                                     | UNKNOWN          | 4   |
|           | 43 | SubIndex 067                                     | UNKNOWN          | 8   |
| 0x8013    | 08 | STM Controller Settings 2 Ch.1                   | UNKNOWN          |     |
|           | 01 | Kp factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 02 | Ki factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 03 | Inner window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Outer window (velo./pos.)                        | UNSIGNED8        | 8   |
|           | 06 | Filter cut off frequency (velo./pos.)            | UNSIGNED16       | 16  |
|           | 07 | Ka factor (velo./pos.)                           | UNSIGNED16       | 16  |
|           | 08 | Kd factor (velo./pos.)                           | UNSIGNED16       | 16  |
| 0x8020    | 10 | POS Settings Ch.1                                | UNKNOWN          |     |
|           | 01 | Velocity min.                                    | INTEGER16        | 16  |
|           | 02 | Velocity max.                                    | INTEGER16        | 16  |
|           | 03 | Acceleration pos.                                | UNSIGNED16       | 16  |
|           | 04 | Acceleration neg.                                | UNSIGNED16       | 16  |
|           | 05 | Deceleration pos.                                | UNSIGNED16       | 16  |
|           | 06 | Deceleration neg.                                | UNSIGNED16       | 16  |
|           | 07 | Emergency deceleration                           | UNSIGNED16       | 16  |
|           | 08 | Calibration position                             | UNSIGNED32       | 32  |
|           | 09 | Calibration velocity (towards plc cam)           | INTEGER16        | 16  |
|           | 0a | Calibration Velocity (off plc cam)               | INTEGER16        | 16  |
|           | 0b | Target window                                    | UNSIGNED16       | 16  |
|           | 0c | In-Target timeout                                | UNSIGNED16       | 16  |
|           | 0d | Dead time compensation                           | INTEGER16        | 16  |
|           | 0e | Modulo factor                                    | UNSIGNED32       | 32  |
|           | 0f | Modulo tolerance window                          | UNSIGNED32       | 32  |
|           | 10 | Position lag max.                                | UNSIGNED16       | 16  |
| 0x8021    | 18 | POS Features Ch.1                                | UNKNOWN          |     |
|           | 01 | Start type                                       | INVALID          | 16  |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | SubIndex 007                                     | UNKNOWN          | 0   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 0   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 0   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | Time information                                 | INVALID          | 2   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | Invert calibration cam search direction          | BOOLEAN          | 1   |
|           | 14 | Invert sync impulse search direction             | BOOLEAN          | 1   |
|           | 15 | Emergency stop on position lag error             | BOOLEAN          | 1   |
|           | 16 | Enhanced diag history                            | BOOLEAN          | 1   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 2   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 8   |

### Subdevice 6(0x1006): EL3048 

#### Addressing

| Property               | Value  |
|---                     |---     |
| Ring position          |     6  |
| Auto-increment address | 0xfffa |
| Station address        | 0x1006 |

#### Identity

| Property         | Value |
|---               |---    |
| Order ID         | EL3048 |
| Name             | EL3048 8K. Ana. Eingang 0-20mA |
| Group            | AnaIn |
| Vendor ID        | 0x00000002 |
| Product code     | 0x0be83052 |
| Revision number  | 0x00130000 |
| Serial number    | 0x00000000 |

#### Physical Memory

DL Status Register: 

```
.{
    .pdi_operational = true,
    .watchdog_ok = true,
    .exteded_link_detection = false,
    .reserved = 0,
    .port0_link_status = true,
    .port1_link_status = false,
    .port2_link_status = false,
    .port3_link_status = false,
    .port0_loop_active = false,
    .port0_rx_signal_det = true,
    .port1_loop_active = true,
    .port1_rx_signal_det = false,
    .port2_loop_active = true,
    .port2_rx_signal_det = false,
    .port3_loop_active = true,
    .port3_rx_signal_det = false,
}
```
#### SII Mailbox Info

Supported mailbox protocols: CoE FoE 

Default mailbox configuration:

    Mailbox out: offset: 0x1000 size: 128
    Mailbox in:  offset: 0x1080 size: 128

Bootstrap mailbox configuration:

    Mailbox out: offset: 0x1000 size: 244
    Mailbox in:  offset: 0x10f4 size: 244

#### SII Catagory: General

| Property                               | Value |
|---                                     |---    |
| coe_details.enable_SDO                 |  true |
| coe_details.enable_SDO_info            |  true |
| coe_details.enable_PDO_assign          |  true |
| coe_details.enable_PDO_configuration   | false |
| coe_details.enable_upload_at_startup   | false |
| coe_details.enable_SDO_complete_access | false |
| foe_details.enable_foe                 |  true |
| flags.enable_SAFEOP                    | false |
| flags.enable_not_LRW                   | false |
| flags.mailbox_data_link_layer          |  true |
| flags.identity_AL_status_code          | false |
| flags.identity_physical_memory         | false |

#### SII Catagory: Sync Managers

##### SM0

    type: mailbox_out
    physical start addr: 0x1000
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM1

    type: mailbox_in
    physical start addr: 0x1080
    length: 128
    control:
        buffer_type                 .mailbox
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM2

    type: process_data_outputs
    physical start addr: 0x1100
    length: 0
    control:
        buffer_type                 .buffered
        direction                   .output
        ECAT_event_enable           false
        DLS_user_event_enable       false
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      false
        fixed_content               false
        virtual                     false
        OP_only                     false

##### SM3

    type: process_data_inputs
    physical start addr: 0x1180
    length: 32
    control:
        buffer_type                 .buffered
        direction                   .input
        ECAT_event_enable           false
        DLS_user_event_enable       true
        watchdog_enable             false
    status:
        channel_enable              false
        repeat                      false
        reserved3                   0
        DC_event_0_bus_access       false
        DC_event_0_local_access     false
    enable:
        enable                      true
        fixed_content               false
        virtual                     false
        OP_only                     false



#### SII Catagory: TxPDOs

    Inputs bit length: 256  
| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |                  | AI Standard Channel 1      |
|        |     | 0x6000:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6000:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6000:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6000:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6000:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6000:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6000:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6000:11 |  16 | INTEGER16        | Value                      |
| 0x1a01 | 255 |           |  16 |                  | AI Compact Channel 1       |
|        |     | 0x6000:11 |  16 | INTEGER16        | Value                      |
| 0x1a02 |   3 |           |  32 |                  | AI Standard Channel 2      |
|        |     | 0x6010:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6010:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6010:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6010:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6010:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6010:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6010:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6010:11 |  16 | INTEGER16        | Value                      |
| 0x1a03 | 255 |           |  16 |                  | AI Compact Channel 2       |
|        |     | 0x6010:11 |  16 | INTEGER16        | Value                      |
| 0x1a04 |   3 |           |  32 |                  | AI Standard Channel 3      |
|        |     | 0x6020:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6020:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6020:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6020:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6020:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6020:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6020:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6020:11 |  16 | INTEGER16        | Value                      |
| 0x1a05 | 255 |           |  16 |                  | AI Compact Channel 3       |
|        |     | 0x6020:11 |  16 | INTEGER16        | Value                      |
| 0x1a06 |   3 |           |  32 |                  | AI Standard Channel 4      |
|        |     | 0x6030:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6030:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6030:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6030:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6030:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6030:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6030:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6030:11 |  16 | INTEGER16        | Value                      |
| 0x1a07 | 255 |           |  16 |                  | AI Compact Channel 4       |
|        |     | 0x6030:11 |  16 | INTEGER16        | Value                      |
| 0x1a08 |   3 |           |  32 |                  | AI Standard Channel 5      |
|        |     | 0x6040:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6040:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6040:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6040:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6040:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6040:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6040:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6040:11 |  16 | INTEGER16        | Value                      |
| 0x1a09 | 255 |           |  16 |                  | AI Compact Channel 5       |
|        |     | 0x6040:11 |  16 | INTEGER16        | Value                      |
| 0x1a0a |   3 |           |  32 |                  | AI Standard Channel 6      |
|        |     | 0x6050:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6050:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6050:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6050:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6050:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6050:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6050:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6050:11 |  16 | INTEGER16        | Value                      |
| 0x1a0b | 255 |           |  16 |                  | AI Compact Channel 6       |
|        |     | 0x6050:11 |  16 | INTEGER16        | Value                      |
| 0x1a0c |   3 |           |  32 |                  | AI Standard Channel 7      |
|        |     | 0x6060:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6060:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6060:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6060:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6060:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6060:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6060:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6060:11 |  16 | INTEGER16        | Value                      |
| 0x1a0d | 255 |           |  16 |                  | AI Compact Channel 7       |
|        |     | 0x6060:11 |  16 | INTEGER16        | Value                      |
| 0x1a0e |   3 |           |  32 |                  | AI Standard Channel 8      |
|        |     | 0x6070:01 |   1 | BOOLEAN          | Status__Underrange         |
|        |     | 0x6070:02 |   1 | BOOLEAN          | Status__Overrange          |
|        |     | 0x6070:03 |   2 | BIT2             | Status__Limit 1            |
|        |     | 0x6070:05 |   2 | BIT2             | Status__Limit 2            |
|        |     | 0x6070:07 |   1 | BOOLEAN          | Status__Error              |
|        |     | 0x0000:00 |   1 | UNKNOWN          | Status__                   |
|        |     | 0x0000:00 |   6 | UNKNOWN          | Status__                   |
|        |     | 0x6070:0f |   1 | BOOLEAN          | Status__TxPDO State        |
|        |     | 0x6070:10 |   1 | BOOLEAN          | Status__TxPDO Toggle       |
|        |     | 0x6070:11 |  16 | INTEGER16        | Value                      |
| 0x1a0f | 255 |           |  16 |                  | AI Compact Channel 8       |
|        |     | 0x6070:11 |  16 | INTEGER16        | Value                      |

#### SII Catagory: RxPDOs

No RxPDOs catagory.

#### CoE: Sync Manager Communication Types

| SM  | Purpose          |
|---  |---               |
| 0   | mailbox_out      |
| 1   | mailbox_in       |
| 2   | output           |
| 3   | input            |

#### CoE: PDO Assignment

| PDO Index| SM| Mapped Index| Bits| Type| Name |
|---|---|---|---|---|---|
| 0x1a00 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6000:01 |   1 |         | Underrange                                                      |
|        |     | 0x6000:02 |   1 |         | Overrange                                                       |
|        |     | 0x6000:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6000:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6000:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6000:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6000:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6000:11 |  16 |         | Value                                                           |
| 0x1a02 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6010:01 |   1 |         | Underrange                                                      |
|        |     | 0x6010:02 |   1 |         | Overrange                                                       |
|        |     | 0x6010:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6010:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6010:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6010:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6010:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6010:11 |  16 |         | Value                                                           |
| 0x1a04 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6020:01 |   1 |         | Underrange                                                      |
|        |     | 0x6020:02 |   1 |         | Overrange                                                       |
|        |     | 0x6020:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6020:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6020:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6020:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6020:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6020:11 |  16 |         | Value                                                           |
| 0x1a06 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6030:01 |   1 |         | Underrange                                                      |
|        |     | 0x6030:02 |   1 |         | Overrange                                                       |
|        |     | 0x6030:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6030:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6030:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6030:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6030:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6030:11 |  16 |         | Value                                                           |
| 0x1a08 |   3 |           |  32 |         |                                                                 |
|        |     | 0x6040:01 |   1 |         | Underrange                                                      |
|        |     | 0x6040:02 |   1 |         | Overrange                                                       |
|        |     | 0x6040:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6040:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6040:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6040:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6040:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6040:11 |  16 |         | Value                                                           |
| 0x1a0a |   3 |           |  32 |         |                                                                 |
|        |     | 0x6050:01 |   1 |         | Underrange                                                      |
|        |     | 0x6050:02 |   1 |         | Overrange                                                       |
|        |     | 0x6050:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6050:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6050:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6050:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6050:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6050:11 |  16 |         | Value                                                           |
| 0x1a0c |   3 |           |  32 |         |                                                                 |
|        |     | 0x6060:01 |   1 |         | Underrange                                                      |
|        |     | 0x6060:02 |   1 |         | Overrange                                                       |
|        |     | 0x6060:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6060:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6060:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6060:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6060:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6060:11 |  16 |         | Value                                                           |
| 0x1a0e |   3 |           |  32 |         |                                                                 |
|        |     | 0x6070:01 |   1 |         | Underrange                                                      |
|        |     | 0x6070:02 |   1 |         | Overrange                                                       |
|        |     | 0x6070:03 |   2 |         | Limit 1                                                         |
|        |     | 0x6070:05 |   2 |         | Limit 2                                                         |
|        |     | 0x6070:07 |   1 |         | Error                                                           |
|        |     |           |   1 | PADDING |                                                                 |
|        |     |           |   6 | PADDING |                                                                 |
|        |     | 0x6070:0f |   1 |         | TxPDO State                                                     |
|        |     | 0x6070:10 |   1 |         | TxPDO Toggle                                                    |
|        |     | 0x6070:11 |  16 |         | Value                                                           |


#### CoE: Object Description Lists

| List                             | Length |
|---                               |---     |
| all_objects                      |     79 |
| rx_pdo_mappable                  |      0 |
| tx_pdo_mappable                  |      8 |
| stored_for_device_replacement    |      8 |
| startup_parameters               |      8 |

#### CoE: Object Description List: All Objects

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x1000    | 00 | Device type                                      | UNSIGNED32       |     |
| 0x1008    | 00 | Device name                                      | VISIBLE_STRING   |     |
| 0x1009    | 00 | Hardware version                                 | VISIBLE_STRING   |     |
| 0x100a    | 00 | Software version                                 | VISIBLE_STRING   |     |
| 0x1011    | 01 | Restore default parameters                       | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1018    | 04 | Identity                                         | IDENTITY         |     |
|           | 01 | Vendor ID                                        | UNSIGNED32       | 32  |
|           | 02 | Product code                                     | UNSIGNED32       | 32  |
|           | 03 | Revision                                         | UNSIGNED32       | 32  |
|           | 04 | Serial number                                    | UNSIGNED32       | 32  |
| 0x10f0    | 01 | Backup parameter handling                        | INVALID          |     |
|           | 01 | Checksum                                         | UNSIGNED32       | 32  |
| 0x1800    | 06 | AI TxPDO-Par Standard Ch.1                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1801    | 06 | AI TxPDO-Par Compact Ch.1                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1802    | 06 | AI TxPDO-Par Standard Ch.2                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1803    | 06 | AI TxPDO-Par Compact Ch.2                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1804    | 06 | AI TxPDO-Par Standard Ch.3                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1805    | 06 | AI TxPDO-Par Compact Ch.3                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1806    | 06 | AI TxPDO-Par Standard Ch.4                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1807    | 06 | AI TxPDO-Par Compact Ch.4                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1808    | 06 | AI TxPDO-Par Standard Ch.5                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1809    | 06 | AI TxPDO-Par Compact Ch.5                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180a    | 06 | AI TxPDO-Par Standard Ch.6                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180b    | 06 | AI TxPDO-Par Compact Ch.6                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180c    | 06 | AI TxPDO-Par Standard Ch.7                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180d    | 06 | AI TxPDO-Par Compact Ch.7                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180e    | 06 | AI TxPDO-Par Standard Ch.8                       | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x180f    | 06 | AI TxPDO-Par Compact Ch.8                        | INVALID          |     |
|           | 01 | SubIndex 001                                     | UNKNOWN          | 0   |
|           | 02 | SubIndex 002                                     | UNKNOWN          | 0   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | SubIndex 005                                     | UNKNOWN          | 0   |
|           | 06 | Exclude TxPDOs                                   | OCTET_STRING     | 16  |
| 0x1a00    | 0a | AI TxPDO-Map Standard Ch.1                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a01    | 01 | AI TxPDO-Map Compact Ch.1                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a02    | 0a | AI TxPDO-Map Standard Ch.2                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a03    | 01 | AI TxPDO-Map Compact Ch.2                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a04    | 0a | AI TxPDO-Map Standard Ch.3                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a05    | 01 | AI TxPDO-Map Compact Ch.3                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a06    | 0a | AI TxPDO-Map Standard Ch.4                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a07    | 01 | AI TxPDO-Map Compact Ch.4                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a08    | 0a | AI TxPDO-Map Standard Ch.5                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a09    | 01 | AI TxPDO-Map Compact Ch.5                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a0a    | 0a | AI TxPDO-Map Standard Ch.6                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a0b    | 01 | AI TxPDO-Map Compact Ch.6                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a0c    | 0a | AI TxPDO-Map Standard Ch.7                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a0d    | 01 | AI TxPDO-Map Compact Ch.7                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1a0e    | 0a | AI TxPDO-Map Standard Ch.8                       | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |
|           | 09 | SubIndex 009                                     | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNSIGNED32       | 32  |
| 0x1a0f    | 01 | AI TxPDO-Map Compact Ch.8                        | PDO_MAPPING      |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
| 0x1c00    | 04 | Sync manager type                                | UNSIGNED8        |     |
|           | 01 | SubIndex 001                                     | UNSIGNED8        | 8   |
|           | 02 | SubIndex 002                                     | UNSIGNED8        | 8   |
|           | 03 | SubIndex 003                                     | UNSIGNED8        | 8   |
|           | 04 | SubIndex 004                                     | UNSIGNED8        | 8   |
| 0x1c12    | 00 | RxPDO assign                                     | UNSIGNED16       |     |
| 0x1c13    | 08 | TxPDO assign                                     | UNSIGNED16       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED16       | 16  |
|           | 02 | SubIndex 002                                     | UNSIGNED16       | 16  |
|           | 03 | SubIndex 003                                     | UNSIGNED16       | 16  |
|           | 04 | SubIndex 004                                     | UNSIGNED16       | 16  |
|           | 05 | SubIndex 005                                     | UNSIGNED16       | 16  |
|           | 06 | SubIndex 006                                     | UNSIGNED16       | 16  |
|           | 07 | SubIndex 007                                     | UNSIGNED16       | 16  |
|           | 08 | SubIndex 008                                     | UNSIGNED16       | 16  |
| 0x1c33    | 20 | SM input parameter                               | SYNC_PAR         |     |
|           | 01 | Sync mode                                        | UNSIGNED16       | 16  |
|           | 02 | Cycle time                                       | UNSIGNED32       | 32  |
|           | 03 | Shift time                                       | UNSIGNED32       | 32  |
|           | 04 | Sync modes supported                             | UNSIGNED16       | 16  |
|           | 05 | Minimum cycle time                               | UNSIGNED32       | 32  |
|           | 06 | Calc and copy time                               | UNSIGNED32       | 32  |
|           | 07 | Minimum delay time                               | UNSIGNED32       | 32  |
|           | 08 | Command                                          | UNSIGNED16       | 16  |
|           | 09 | Maximum delay time                               | UNSIGNED32       | 32  |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 32  |
|           | 0b | SM event missed counter                          | UNSIGNED16       | 16  |
|           | 0c | Cycle exceeded counter                           | UNSIGNED16       | 16  |
|           | 0d | Shift too short counter                          | UNSIGNED16       | 16  |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 16  |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 0   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | SubIndex 017                                     | UNKNOWN          | 0   |
|           | 12 | SubIndex 018                                     | UNKNOWN          | 0   |
|           | 13 | SubIndex 019                                     | UNKNOWN          | 0   |
|           | 14 | SubIndex 020                                     | UNKNOWN          | 0   |
|           | 15 | SubIndex 021                                     | UNKNOWN          | 0   |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | SubIndex 023                                     | UNKNOWN          | 0   |
|           | 18 | SubIndex 024                                     | UNKNOWN          | 0   |
|           | 19 | SubIndex 025                                     | UNKNOWN          | 0   |
|           | 1a | SubIndex 026                                     | UNKNOWN          | 0   |
|           | 1b | SubIndex 027                                     | UNKNOWN          | 0   |
|           | 1c | SubIndex 028                                     | UNKNOWN          | 0   |
|           | 1d | SubIndex 029                                     | UNKNOWN          | 0   |
|           | 1e | SubIndex 030                                     | UNKNOWN          | 0   |
|           | 1f | SubIndex 031                                     | UNKNOWN          | 0   |
|           | 20 | Sync error                                       | BOOLEAN          | 1   |
| 0x6000    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6020    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6030    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6040    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6050    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6060    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6070    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x8000    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x800e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x800f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x801e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x801f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8020    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x802e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x802f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8030    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x803e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x803f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8040    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x804e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x804f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8050    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x805e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x805f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8060    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x806e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x806f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0x8070    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x807e    | 01 | AI Internal data                                 | UNKNOWN          |     |
|           | 01 | ADC raw value                                    | INTEGER16        | 16  |
| 0x807f    | 02 | AI Vendor data                                   | UNKNOWN          |     |
|           | 01 | Calibration offset                               | INTEGER16        | 16  |
|           | 02 | Calibration gain                                 | INTEGER16        | 16  |
| 0xf000    | 02 | Modular device profile                           | INVALID          |     |
|           | 01 | Module index distance                            | UNSIGNED16       | 16  |
|           | 02 | Maximum number of modules                        | UNSIGNED16       | 16  |
| 0xf008    | 00 | Code word                                        | UNSIGNED32       |     |
| 0xf009    | 00 | Password protection                              | UNSIGNED32       |     |
| 0xf010    | 08 | Module list                                      | UNSIGNED32       |     |
|           | 01 | SubIndex 001                                     | UNSIGNED32       | 32  |
|           | 02 | SubIndex 002                                     | UNSIGNED32       | 32  |
|           | 03 | SubIndex 003                                     | UNSIGNED32       | 32  |
|           | 04 | SubIndex 004                                     | UNSIGNED32       | 32  |
|           | 05 | SubIndex 005                                     | UNSIGNED32       | 32  |
|           | 06 | SubIndex 006                                     | UNSIGNED32       | 32  |
|           | 07 | SubIndex 007                                     | UNSIGNED32       | 32  |
|           | 08 | SubIndex 008                                     | UNSIGNED32       | 32  |

#### CoE: Object Description List: RxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|

#### CoE: Object Description List: TxPDO Mappable

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x6000    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6010    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6020    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6030    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6040    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6050    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6060    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |
| 0x6070    | 11 | AI Inputs                                        | UNKNOWN          |     |
|           | 01 | Underrange                                       | BOOLEAN          | 1   |
|           | 02 | Overrange                                        | BOOLEAN          | 1   |
|           | 03 | Limit 1                                          | BIT2             | 2   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Limit 2                                          | BIT2             | 2   |
|           | 06 | SubIndex 006                                     | UNKNOWN          | 0   |
|           | 07 | Error                                            | BOOLEAN          | 1   |
|           | 08 | SubIndex 008                                     | UNKNOWN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 6   |
|           | 0a | SubIndex 010                                     | UNKNOWN          | 0   |
|           | 0b | SubIndex 011                                     | UNKNOWN          | 0   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 0   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | SubIndex 014                                     | UNKNOWN          | 0   |
|           | 0f | TxPDO State                                      | BOOLEAN          | 1   |
|           | 10 | TxPDO Toggle                                     | BOOLEAN          | 1   |
|           | 11 | Value                                            | INTEGER16        | 16  |

#### CoE: Object Description List: Stored for Device Replacement

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8020    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8030    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8040    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8050    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8060    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8070    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |

#### CoE: Object Description List: Startup Parameters

| Index| Max Subindex / Subindex| Name| Type |
|---|---|---|---|
| 0x8000    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8010    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8020    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8030    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8040    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8050    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8060    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |
| 0x8070    | 18 | AI Settings                                      | UNKNOWN          |     |
|           | 01 | Enable user scale                                | BOOLEAN          | 1   |
|           | 02 | Presentation                                     | INVALID          | 3   |
|           | 03 | SubIndex 003                                     | UNKNOWN          | 0   |
|           | 04 | SubIndex 004                                     | UNKNOWN          | 0   |
|           | 05 | Siemens bits                                     | BOOLEAN          | 1   |
|           | 06 | Enable filter                                    | BOOLEAN          | 1   |
|           | 07 | Enable limit 1                                   | BOOLEAN          | 1   |
|           | 08 | Enable limit 2                                   | BOOLEAN          | 1   |
|           | 09 | SubIndex 009                                     | UNKNOWN          | 1   |
|           | 0a | Enable user calibration                          | BOOLEAN          | 1   |
|           | 0b | Enable vendor calibration                        | BOOLEAN          | 1   |
|           | 0c | SubIndex 012                                     | UNKNOWN          | 2   |
|           | 0d | SubIndex 013                                     | UNKNOWN          | 0   |
|           | 0e | Swap limit bits                                  | BOOLEAN          | 1   |
|           | 0f | SubIndex 015                                     | UNKNOWN          | 2   |
|           | 10 | SubIndex 016                                     | UNKNOWN          | 0   |
|           | 11 | User scale offset                                | INTEGER16        | 16  |
|           | 12 | User scale gain                                  | INTEGER32        | 32  |
|           | 13 | Limit 1                                          | INTEGER16        | 16  |
|           | 14 | Limit 2                                          | INTEGER16        | 16  |
|           | 15 | Filter settings                                  | INVALID          | 16  |
|           | 16 | SubIndex 022                                     | UNKNOWN          | 0   |
|           | 17 | User calibration offset                          | INTEGER16        | 16  |
|           | 18 | User calibration gain                            | INTEGER16        | 16  |

