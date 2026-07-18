# Container Runtime CLI

A minimal container runtime utilizing Linux namespaces and cgroups.

## Features
* **Namespaces:** Isolates `net`, `mnt`, `pid`, and `uts`.
* **Filesystem:** Provisions an isolated Ubuntu 20.04 root filesystem per container.
* **Process Isolation:** Ensures the bash entrypoint runs as PID 1.
* **Memory Limits (Bonus):** Supports memory bounding via cgroups (v1/v2).

## Usage

**Standard Execution:**
```bash
sudo ./your-cli <hostname>
