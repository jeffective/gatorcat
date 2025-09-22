# Gatorcat Documentation

> [!WARNING]
> `gatorcat` is **alpha** software. Using it today means participating in its development.
> You may find bugs or need features implemented before you can use `gatorcat` effectively.

`gatorcat` provides the following:

1. [gatorcat-cli](#gatorcat-cli): a command-line interface executable for common tasks when working with EtherCAT networks, incuding running and scanning.
    > Run: automatically operate an EtherCAT network with zero configuration.

    > Scan: obtain information about the contents of the network.

    > Debug: (Work in progress) debug issues with your network.
1. [gatorcat-module](#gatorcat-module): a zig module for writing applications that interact with EtherCAT networks.

## Zig Version

Please review the `minimum_zig_version` field of the [`build.zig.zon`](/build.zig.zon).

## Gatorcat CLI

### Installation

The CLI can be downloaded from the github releases page or built from source.

To build from source:

1. Install the zig compiler. See [Zig Version](#zig-version). There are no other build-time dependencies.
1. Clone this repo.
1. Run `zig build` in the repo.
1. The executable will be named `gatorcat` and placed in `./zig-out/bin/`.

### Windows

On Windows, the gatorcat CLI depends on [npcap](https://npcap.com/). It must be installed prior to running the CLI.
Please do not use windows for anything other than developer convienience (using the CLI, etc.).
Npcap has poor realtime performance and so does Windows in general.

The CLI must have permissions to interact with npcap. The easiest way to accomplish this is to launch it from a terminal with administrator priviledges.

### Windows (WSL)

On linux on windows through WSL, is is very difficult to obtain raw access to ethernet interfaces on the host. It is possible through [usbipd](https://learn.microsoft.com/en-us/windows/wsl/connect-usb) but you might as well just use the windows CLI.

### Linux

The CLI requires `CAP_NET_RAW` permissions to open raw sockets. The easiest way to acheive this is to run the CLI with `sudo`.

### Docker

The CLI is also provided as a docker image:

```
$ docker run ghcr.io/jeffective/gatorcat:0.4.0 version
0.4.0
```

To obtain raw access to ethernet ports with docker, the easiest way is to use network mode host. This will give the container host-level access to the ethernet interfaces.

```
$ docker run --network host ghcr.io/jeffective/gatorcat:0.4.0 run --ifname enx00e04c68191a --zenoh-config-default --auto-scan-plugin-zenoh-enable
warning: Scheduler: NORMAL
warning: Ping returned in 487 us.
warning: Cycle time not specified. Estimating appropriate cycle time...
warning: Max ping after 1000 tries is 616 us. Selected 2000 us as cycle time.
warning: Scanning bus...
warning: Detected 7 subdevices.
```


### Usage

Please review the help text printed with `gatorcat -h`.
There is also sub-help for each sub-command, for example: `gatorcat scan -h`.

To obtain the name of network interfaces on windows:

1. Run `getmac /fo csv /v` in command prompt
2. ifname for npcap is of the format: `\Device\NPF_{538CF305-6539-480E-ACD9-BEE598E7AE8F}`

### Suggested Workflow

1. Run `gatorcat info --ifname eth0 > info.md` to create a human readable markdown file with information about the subdevices on your network.
1. Run `gatorcat scan --ifname eth0 > eni.zon` to create an ENI file for the network.
1. Run the network with `gatorcat run --ifname eth0 --cycle-time-us 10000 --zenoh-config-default --eni-file eni.zon`.
1. Observe data published on zenoh from ethercat.
    > The keys are defined in the `eni.zon`.

### Zenoh Details

A zenoh config file can be provided. See the CLI help text on how to specify the path.

The keys look like this:

```
subdevices/1/EL2008/outputs/0x7000/Channel_1/0x01/Output
```
| Zenoh Key Expression Segment | Explanation                                                              |
|------------------------------|--------------------------------------------------------------------------|
| `subdevices/1/`              | This is the second subdevice on the bus (zero indexed).                  |
| `EL2008`                     | The name of the subdevice from the SII EEPROM.                           |
| `outputs`                    | This is an output PDO.                                                   |
| `0x7000`                     | The index of the PDO (in hex).                                           |
| `Channel_1`                  | The name of the PDO from the SII EEPROM or CoE object description.       |
| `0x01`                       | The subindex of the PDO entry (in hex).                                  |
| `Output`                     | The pdo entry description from the SII EEPROM or CoE object description. |

The data is published in CBOR encoding.

The subscribed keys accept CBOR encoded data.

In the ENI file, the `pv_name` is the process variable name. gatorcat subscribes for outputs and publishes for input at this `pv_name`, you can apply a prefix on generation of this name.

Similarly, there is a `pv_name_fb`. This is the process variable feedback channel. gatorcat publishes for both inputs and outputs at these keys to enable applications to see the results of their publishes to output channels.

## GatorCAT Module

### Examples

Examples can be found in [examples](doc/examples/). The examples can be built using `zig build examples`.

### Using the Zig Package Manager

To add gatorcat to your project as a dependency, run:

```sh
zig fetch --save git+https://github.com/jeffective/gatorcat
```

Then add the following to your build.zig:

```zig
// assuming you have an existing executable called `exe`
const gatorcat = b.dependency("gatorcat", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("gatorcat", gatorcat.module("gatorcat"));
```

And import the library to begin using it:

```zig
const gcat = @import("gatorcat");
```

### Windows Support

To provide windows support, gatorcat depends on [npcap](https://npcap.com/). Npcap does not need to be installed
to build for windows targets, but it must be installed on the target when running resulting executables.

### Suggested Workflow

1. Build your EtherCAT network.
1. Use the [gatorcat CLI](#gatorcat-cli) to scan the network.
1. Write your network configuration (ENI). See [example](./examples/simple/network_config.zig).
1. Write your application. See [example](./examples/simple/main.zig).


## MainDevice Class

Ref: ETG 1500

Class A Features

| Feature                           | Class A      | Class B      | Supported? |
| --------------------------------- | ------------ | ------------ | ---------- |
| service commands                  | shall if eni | shall if eni | yes        |
| irq                               | should       | should       | no         |
| subdevice device emulation        | shall        | shall        | yes?       |
| ecat state machine                | shall        | shall        | yes?       |
| error handling                    | shall        | shall        | yes        |
| vlan tagging                      | may          | may          | no         |
| ecat frames                       | shall        | shall        | yes        |
| udp frames                        | may          | may          | no         |
| cyclic pdo                        | shall        | shall        | yes        |
| multiple cyclic tasks             | may          | may          | no         |
| frame repetition                  | may          | may          | no         |
| online scanning                   |              |              | yes        |
| read ENI                          |              |              | yes*       |
| compare against eni               | shall        | shall        | yes        |
| explicit device id                | should       | should       | no?        |
| alias addressing                  | may          | may          | no         |
| eeprom read                       | shall        | shall        | yes        |
| eeprom write                      | may          | may          | no         |
| mailbox transfer                  | shall        | shall        | yes        |
| reslient mailbox                  | shall        | shall        | no         |
| multiple mailboxes                | may          | may          | no         |
| mailbox polling                   | shall        | shall        | no         |
| sdo upload download               | shall        | should       | no         |
| complete access                   | shall        | should       | yes        |
| sdo info                          | shall        | should       | yes        |
| emergency messages                | shall        | shall        | yes        |
| pdo in coe                        | may          | may          | no         |
| eoe                               | shall        | may          | no         |
| virtual switch                    | shall        | may          | no         |
| eoe endpoint to operation systems | should       | should       | no         |
| foe                               | shall        | may          | no         |
| firmware upload and download      | shall        | should       | no         |
| boot state                        | shall        | should       | no         |
| soe                               | shall        | should       | no         |
| aoe                               | should       | should       | no         |
| voe                               | may          | may          | no         |
| dc                                | shall        | may          | no         |
| continous prop delay measurement  | should       | should       | no         |
| sync window monitoring            | should       | should       | no         |
| sub to sub comms                  | shall        | shall        | no         |
| maindevice object dictionary      | should       | may          | no         |