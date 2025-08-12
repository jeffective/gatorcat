# gatorcat

![tests](https://github.com/jeffective/gatorcat/actions/workflows/main.yml/badge.svg)

`gatorcat` is an EtherCAT maindevice written in the Zig programming language.

> [!WARNING]
> `gatorcat` is **alpha** software. Using it today means participating in its development.
> You may find bugs or need features implemented before you can use `gatorcat` effectively.

## Documentation

See [doc](doc/README.md).

## Status

### Notably Working Features

- [x] no config, "just works" executable
    - [x] automatic configuration to reach OP for most subdevices, via SII and CoE
    - [x] process data published on zenoh
- [x] verifcation of the network contents against an ethercat network information struct (ENI)
- [x] cli for scanning a network to generate ENI
- [x] can manipulate process data
- [x] CoE startup parameters
- [x] CLI for scanning networks and getting information about subdevices
- [x] multi-OS support (Linux and Windows)

### Notably Missing Features

- [ ] distributed clocks
- [ ] Ethernet Over EtherCAT (EoE), also AoE, FoE, SoE, VoE
- [ ] user configurable processing of CoE emergency messages
- [ ] mapping the mailbox status into the process data
- [ ] async / event loop frames
- [ ] multi-threading friendly API
- [ ] linux XDP
- [ ] mac-os, embedded support
- [ ] allocation-free API
- [ ] cable redundancy
- [ ] EtherCAT Network Information(ENI) XML Parsing
- [ ] Segmented SDO transfer
- [ ] EEPROM write access
- [ ] Embedded friendly API / timers
- [ ] Network diagnosis in the CLI (CRC counters etc.)

## TODO

- [ ] validate individual pdo types at runtime (not just size of pdos)
- [ ] revise error handling

## TODO for Zig 0.15

- [ ] linked list api change
- [ ] remove bounded array
- [ ] remove array multiplication
- [ ] writergate
- [ ] std.io?

## Sponsors

![GitHub Sponsors](https://img.shields.io/github/sponsors/jeffective)

Please consider [❤️ Sponsoring](https://github.com/sponsors/jeffective) if you depend on this project or just want to see it succeed.

## Release Procedure

1. roll version in build.zig.zon
2. commit
3. tag commit
4. push commit, push tags
5. wait for CI pass
6. click release in github
