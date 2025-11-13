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

Therefore, a static configuration the defines the TIMING, and the expected network contents is required to provide the simplest possible API.

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


