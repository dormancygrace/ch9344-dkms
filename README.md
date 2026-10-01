# CH9344/CH348 Linux driver — stable DKMS package

This repository packages the official WCH CH9344/CH348 Linux driver as a DKMS
module for Debian, Ubuntu, and Proxmox VE, and fixes a receive-path failure seen
with long-running multi-port console use.

It is based on
[`WCHSoftGroup/ch9344ser_linux`](https://github.com/WCHSoftGroup/ch9344ser_linux),
V2.3 at commit `0450213977f8a9acc8b9ccc70754efed0842d1d0`.

## The failure

The vendor callbacks retired a receive URB after **any** non-zero completion
status. The adapter has a finite receive-URB pool, so transient USB errors could
silently drain that pool. TX kept working while RX remained dead until the USB
interface was unbound and bound again.

Version 2.3.1 resubmits command and data receive URBs after transient errors.
It still stops on deliberate unlink, disconnect, shutdown, and endpoint stall.
The receive parser also initializes its per-port notification state and rejects
truncated frames before accessing them. A pre-existing write-timeout/runtime-PM
leak is fixed as well.

## Install the release package

```sh
sudo apt install ./ch9344-dkms_2.3.1-3_all.deb
modinfo ch9344 | grep '^version:'
dkms status ch9344/2.3.1
```

Installing or upgrading the package unloads and reloads `ch9344`; every serial
session on that physical adapter is interrupted. Stop console collectors first.

## Build the Debian package

```sh
sudo apt install dpkg-dev
./scripts/build-deb.sh
```

The package is written to `dist/`. Its maintainer scripts build the module for
every installed kernel that has headers available, which covers both the active
Proxmox kernel and a newly installed kernel awaiting reboot.

## Source layout

- `driver/` — complete patched source and DKMS metadata;
- `patches/` — patch against the pinned official WCH commit;
- `packaging/` — Debian package metadata and installed support files;
- `tests/` — bounded end-to-end serial RX stress test;
- `docs/TESTING.md` — hardware setup, scope, and measured results.

## Supported hardware

- `1a86:e018` — CH9344
- `1a86:55d9` — CH348/CH348Q

The source retains WCH's GPL-2.0-or-later/GPL-2.0 SPDX declarations. Packaging
and original additions in this repository are distributed under GPL-2.0-or-later.
