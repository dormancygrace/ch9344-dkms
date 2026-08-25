# Hardware validation

The 2.3.1 driver was built and installed with DKMS on Proxmox VE kernels:

- `7.0.14-11-pve`
- `7.0.14-12-pve`

Hardware under test was a WCH CH9344 adapter (`1a86:e018`) with all eight tty
devices present. A live 115200-baud router console was used for end-to-end TX
and RX validation.

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
