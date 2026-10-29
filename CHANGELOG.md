# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **CentOS 7 & Legacy Linux Kernel (< 4.1) Support**:
  - Auto-detection of Linux kernel version via `/proc/sys/kernel/osrelease`.
  - Automatic activation of `AF_PACKET` packet capturing fallback on kernels older than 4.1 (such as CentOS 7 with Linux 3.10), where `struct tcp_info` lacks `tcpi_bytes_acked` and `tcpi_bytes_received`.
  - `SSTOP_USE_PROC=1` environment variable to force `/proc` and `AF_PACKET` collection mode.
  - Graceful handling of environments where IPv6 is disabled in the kernel (`ipv6.disable=1`), allowing IPv4 monitoring to function without error.
- **Build System**:
  - Added project `Makefile` supporting multi-platform cross-compilation, static builds (`make build-static`), dedicated CentOS 7 build target (`make centos7`), release packaging (`make dist`), testing, and self-documenting help (`make help`).
- **10 Killer CLI & TUI Features**:
  - Non-interactive streaming output modes: `--json` (JSONL) and `--csv`, compatible with `--once` and `--interval` flags.
  - Exit summary on quit displaying session duration, total upload/download bandwidth, and top active processes.
  - Cumulative bandwidth mode (`c`) to toggle between instantaneous rate and total accumulated bytes transferred.
  - Protocol & service mapping for ~50 well-known network ports (HTTP, HTTPS, SSH, DNS, PostgreSQL, Redis, etc.).
  - Advanced filter expressions support (e.g. `port:443`, `up>1M`, `down>100k`, `proto:udp`, `host:`, `svc:`, `group:`).
  - Process tree view (`t`) displaying parent-child process hierarchy with recursive bandwidth aggregation.
  - GeoIP country resolution in Remote Hosts view with country name and flag emoji.
  - Bandwidth alert threshold overlay (`A`) with visual flash highlight and terminal bell notification.
  - Session recording and playback: `--record <file>` to capture traffic sessions and `--playback <file>` with pause and variable speed control.
  - Container & service group view (`D`) aggregating bandwidth by Docker/Podman container ID or systemd service unit.

### Changed
- CI/CD release workflow (`release.yml` and `ci.yml`) now builds with `CGO_ENABLED=0` and `-trimpath`, ensuring fully static, glibc-independent binaries that run out-of-the-box on older distributions including CentOS 7.
- Netlink runtime error recovery: automatically falls back to `/proc` parsing if Netlink query encounters runtime errors.

### Fixed
- Flaky `TestRecordSession` test on CI caused by non-blocking channel send.

---

## [0.1.2] - 2026-02-15

### Fixed
- Added TB tier (`T = 1024 GB`) to `FormatRateCompact` to prevent formatting overflow on high-throughput links (>= 10,000 GB/s).

---

## [0.1.1] - 2026-02-15

### Added
- Fixed-width `FormatRateCompact()` (6 chars) to guarantee consistent column alignment across all terminal widths.
- Comprehensive layout and format tests across terminal widths 60–250 columns and fuzz testing for transfer rates from $2^0$ to $2^{40}$.

### Fixed
- Column width calculations and gap counts across Process Table, Remote Hosts, Listen Ports, and Process Detail views.
- Filtered inactive interfaces with zero traffic from header statistics line.

---

## [0.1.0] - 2026-02-14

### Added
- Initial release of `sstop`: real-time per-process network bandwidth monitor for the terminal.
- Live upload and download rates per process with sparklines and Tokyo Night colored bandwidth bars.
- 4 primary interactive views:
  - **Process Table**: Overview of all processes with active socket connections.
  - **Process Detail**: Detailed socket list, TCP state badges, connection duration, and DNS resolution.
  - **Remote Hosts**: Remote IP aggregation across all processes.
  - **Listen Ports**: Local listening services and open ports.
  - **Help Overlay** (`?`) and **Kill Process Overlay** (`K`).
- System-wide 60-second total bandwidth trend sparkline in header.
- Cross-platform support:
  - Linux: Netlink `SOCK_DIAG` with `/proc` + `AF_PACKET` raw socket fallback.
  - macOS: `netstat` + `lsof` process mapping.
- Mouse support: click-to-select and scroll-wheel navigation.
- Dynamic refresh interval adjustment (`+` / `-`) and display pause/resume (`Space`).
