# 🖥 sshGPUMonitor

A lightweight macOS menu bar app that monitors remote GPU usage via SSH. Displays real-time GPU utilization percentages directly in the menu bar — no need to SSH into servers manually.

## Features

- **Menu Bar Display** — GPU utilization percentages shown directly in the macOS menu bar, always visible
- **Auto-Polling** — Automatically cycles through multiple servers at configurable intervals
- **Bar Chart View** — Click the menu bar icon to see a detailed bar chart of each GPU
- **Multi-Server** — Configure and switch between multiple SSH servers
- **SSH Key Auth** — Supports key-based and password authentication
- **Security-Scoped Bookmarks** — SSH key file access authorized only once
- **Auto-Start** — Optional login item for launch at startup

## Screenshot

*Coming soon*

## Installation

### Download Release

Download the latest `GPUMonitor.app.zip` from [Releases](https://github.com/leonlee233/sshGPUMonitor/releases), unzip, and drag to `/Applications`.

### Build from Source

**Prerequisites:** macOS 13+ with [Xcode](https://developer.apple.com/xcode/) installed.

```bash
git clone https://github.com/leonlee233/sshGPUMonitor.git
cd sshGPUMonitor/GPUMonitor
./build.sh
open .build/GPUMonitor.app
```

## Usage

1. Launch the app — a 🖥 icon appears in the menu bar
2. Click the icon → **Settings** → add your SSH server (host, port, user, key/password)
3. Click **▶ Play** to start monitoring a single server
4. Or click **Auto: OFF** to enable auto-polling across all servers

### Menu Bar Display

| Mode | Menu Bar Text |
|------|--------------|
| Idle | `🖥` |
| Single Server | `🖥 85% 42% 73% 91% 15% 60% 33% 8%` |
| Auto-Polling | `🖥 ServerName: 85% 42% 73% ...` |

### Auto-Polling

When auto-polling is enabled, the app cycles through all configured servers at the specified interval (default 10 seconds). The menu bar text updates to show the current server name and its GPU percentages.

## Requirements

- macOS 13.0 (Ventura) or later
- Remote servers with NVIDIA GPUs and `nvidia-smi` installed
- SSH access (key-based or password)

## Tech Stack

- Swift / SwiftUI / AppKit
- Combine
- Process (`/usr/bin/ssh`)
- Security-Scoped Bookmarks for key file access
- ServiceManagement (SMAppService) for auto-start

## License

MIT
