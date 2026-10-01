# Hardware validation

The 2.3.1 driver was built and installed with DKMS on Proxmox VE kernels:

- `7.0.14-11-pve`
- `7.0.14-12-pve`

Hardware under test was a WCH CH348 adapter (`1a86:55d9`) with all eight tty
devices present. A live 115200-baud router console was used for end-to-end TX
and RX validation. CH9344 (`1a86:e018`) is supported by the packaged vendor
driver but was not covered by this hardware run.

## Results

The test was run before and after installation from the generated Debian
package:

- 3,000 numbered burst records: 3,000 received, zero gaps, zero reordering;
- 200 close/open cycles: 200 commands executed and acknowledged;
- all eight `/dev/ttyCH9344USB*` devices remained present;
- no new CH9344 errors appeared in the kernel log.

This exercises the shared receive path and tty lifecycle. It does not emulate
every possible electrical or host-controller failure. The transient-error
handling follows the Linux `cdc-acm` and generic USB-serial receive pattern:
terminal unlink/shutdown conditions stop a URB, while other completion errors
are retried.

## Reproduce

Install `expect` and `socat`, connect a shell console, and run:

```sh
CH9344_PORT=/dev/ttyCH9344USB2 \
CH9344_BAUD=115200 \
CH9344_PROMPT_RE='[^\r\n]*# ' \
tests/ch9344-rx-stress.exp
```

The test only sends output and `printf` commands. It does not reboot or write
flash on the connected target.


## Complete 2.3.1-3 candidate, 2026-10-01

The complete driver from PR #2 (source head `3c20254`), including all final
changes in WCH ch9344ser_linux PRs #50 and #51, was validated on the physical
CH348Q adapter with package `ch9344-dkms 2.3.1-3` and Proxmox
`7.0.14-19-pve`.

The source extracted from the exact Debian package matches the installed
`ch9344.c` and `ch9344.h` byte for byte. A fresh external-module build against
the active kernel headers passes with `W=1 KCFLAGS=-Werror`. The freshly
built module, loaded module and installed DKMS modules for `7.0.14-17-pve`
and `7.0.14-19-pve` report source version `F64C8B8FE91078B6C647A82`.
The `ch9344.c` SHA-256 is
`b551698ee57fb603ced01717e0c9512b476eb0b5d004a53a21e0c29c45f4a499`.

At 115200 baud, UART channel 5 connected to a live OpenWrt shell received
3000/3000 numbered records in order without missing or duplicate records,
and passed 200/200 open/command/close cycles. All eight TTY ports remained
present. The installed module was retained and the test console was logged
out afterward.

This validates ordinary TTY TX/RX and lifecycle behavior of the complete
packaged candidate. It does not validate the CH9344 variant or every GPIO,
vendor-command/control ioctl, disconnect or USB-error path.
