# Building from Source

## Prerequisites

- Go 1.21 or later
- Git

## Build

Using Make:

```bash
# Build for host OS
make build

# Build static binary for CentOS 7 / legacy Linux
make centos7

# See all make targets
make help
```

Or using `go build` directly:

```bash
git clone https://github.com/googlesky/sstop.git
cd sstop
go build -o sstop .
```

## Cross-Compile

Using Make:

```bash
make linux-amd64   # Linux amd64 (static)
make linux-arm64   # Linux arm64 (static)
make darwin-arm64  # macOS Apple Silicon
make darwin-amd64  # macOS Intel
make dist          # Package all platforms with tar.gz + checksums
```

Or manually:

## Install

```bash
go install github.com/googlesky/sstop@latest
```

The binary will be placed in `$GOPATH/bin/` (or `$HOME/go/bin/` by default).

## Run Tests

```bash
go test ./...
```

## Build Tags

The project uses build tags for platform-specific code:

- `linux` — Netlink, /proc, AF_PACKET support
- `darwin` — netstat/lsof-based collection

No manual build tags are needed; Go selects the correct files automatically based on `GOOS`.

## Dependencies

| Package | Purpose |
|---------|---------|
| `charmbracelet/bubbletea` | TUI framework (Elm architecture) |
| `charmbracelet/bubbles` | Text input widget (search bar) |
| `charmbracelet/lipgloss` | Terminal styling and layout |
| `mdlayher/netlink` | Linux netlink socket communication |

All dependencies are managed via Go modules (`go.mod`).
