# Changelog

## 2.3.1-2 — 2026-09-01

- Recommend the native generic kernel-header package on Ubuntu while retaining
  the Proxmox VE and Debian alternatives.
- Compile the external module against current Ubuntu generic headers in CI,
  with extra kernel warnings enabled and promoted to errors.
- Remove an unused packet-count calculation reported by the kernel's `W=1`
  checks.

## 2.3.1-1 — 2026-08-25

- Resubmit command and data receive URBs after transient USB errors.
- Preserve shutdown semantics for deliberately unlinked, disconnected, stalled,
  or shut-down URBs.
- Initialize the per-port receive notification array.
- Validate receive-buffer and frame boundaries before parsing.
- Release the write buffer and runtime-PM reference after a write timeout.
- Package the driver as DKMS for Debian, Ubuntu, and Proxmox VE.

The driver is based on WCH V2.3, upstream commit
`0450213977f8a9acc8b9ccc70754efed0842d1d0`.
