# gatorcat

`gatorcat` is an EtherCAT maindevice written in the Zig programming language.

> [!WARNING]
> `gatorcat` is **alpha** software. Using it today means participating in its development.
> You may find bugs or need features implemented before you can use `gatorcat` effectively.

gatorcat provides the following:

- CLI: a pre-built executable for running and scanning ethercat networks.
- module: zig module for writing applications that interact with ethercat networks.

## Documentation

See [doc](doc/README.md).

### Notably Working Features

- [x] automatic configuration via SII and CoE
- [x] process data published on zenoh
- [x] network operation and topology verification against a config file
- [x] multi-OS support (Linux and Windows)

### Notably Missing Features

- [ ] distributed clocks
- [ ] cable redundancy
- [ ] Ethernet Over EtherCAT (EoE), also AoE, FoE, SoE, VoE
- [ ] user configurable processing of CoE emergency messages
- [ ] mapping the mailbox status into the process data
- [ ] async / event loop frames, multi-threading friendly API
- [ ] linux XDP, mac-os, embedded support
- [ ] Segmented SDO transfer
- [ ] EEPROM write access
- [ ] Network diagnosis in the CLI (CRC counters etc.)

## TODO

- [ ] delete everything in stdx
- [ ] change deserialization of embedded protocols to do zero backtracking

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

## Contributing

Please open an issue before contributing so we can discuss.

![tests](https://github.com/jeffective/gatorcat/actions/workflows/main.yml/badge.svg)