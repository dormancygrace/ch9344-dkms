# CH348 upstream v9 preparation test

This is a hardware smoke test of Martin Blumenstingl's upstream preparation
branch, independent of the vendor-derived DKMS module in this repository.

## Source

- repository: [`xdarklight/ch348`](https://github.com/xdarklight/ch348)
- branch: `v9-prep-20251221`
- commit: `d399dab58f80c7c2eda715b3628a906f6f521844`

The unmodified branch built as an external module with `W=1` against
`7.0.14-11-pve`. There were no compiler warnings; only the host's unrelated
missing-vmlinux BTF message was emitted.

## Hardware

- USB ID: `1a86:55d9`
- detected by the driver as: `WCH CH348Q version 0x90`
- all eight ports attached successfully
- one channel connected to a live 115200-baud router console

## Result

- 3,000 numbered burst records received;
- zero gaps and zero reordering;
- 200 tty close/open cycles completed;
- 200 commands executed and acknowledged;
- clean module unload followed by successful restoration of the installed
  vendor-derived DKMS driver.

This validates basic enumeration, configuration, TX, RX and repeated port
lifecycle on one channel. Simultaneous all-eight-port traffic, suspend/resume,
USB recovery and the full baud-rate matrix remain to be tested when the
remaining channels are wired.
