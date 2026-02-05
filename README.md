# DigiNoise CLI

A lightweight Mac command-line tool that generates "digital noise" by making automated API requests to obscure your online footprint. Runs as a background daemon with guaranteed execution.

## Why CLI vs iOS?

- **Reliable execution** - Uses macOS `launchd` for guaranteed background scheduling
- **No suspension** - Runs even when you're not actively using your Mac
- **More control** - Simple config, logs, and full visibility into operations
- **Lower overhead** - No UI, no complex lifecycle management

## Installation

### Quick Install (Recommended)

```bash
git clone https://github.com/rosakowski/DigiNoise-CLI.git
cd DigiNoise-CLI
make install
```

### Manual Build

```bash
# Build the binary
swift build -c release

# Copy to a PATH location
cp .build/release/diginoise /usr/local/bin/

# Install as service
diginoise install
```

## Usage

```bash
# Install the background service (one-time setup)
diginoise install

# Start generating noise
diginoise start

# Check status
diginoise status

# View recent activity
diginoise log

# Configure settings
diginoise config --limit 5 --start 8 --end 22

# Stop the daemon
diginoise stop

# Uninstall the service
diginoise uninstall
```

## Configuration

Settings are stored in `~/.config/diginoise/config.json`:

| Option | Default | Description |
|--------|---------|-------------|
| `dailyLimit` | 5 | Max API requests per day (0 = unlimited) |
| `startHour` | 7 | Earliest hour to run (24h format) |
| `endHour` | 23 | Latest hour to run (24h format) |

## How It Works

1. **launchd** runs `diginoise daemon` every 15 minutes
2. The daemon checks if it should make a request (within limits/hours)
3. Makes a random API call (Wikipedia, weather, etc.)
4. Calculates a random interval (1-6 hours) for the next request
5. Exits - launchd will wake it up again in 15 minutes
6. If the scheduled time passed while daemon was sleeping, it executes immediately

This approach ensures reliable execution without keeping a process running constantly.

## Log File

Activity is logged to:
- Terminal output (when running manually)
- `~/.local/share/diginoise/diginoise.log` (persistent)

View with: `diginoise log` or `tail -f ~/.local/share/diginoise/diginoise.log`

## Uninstall

```bash
diginoise uninstall
rm /usr/local/bin/diginoise
rm -rf ~/.config/diginoise ~/.local/share/diginoise
```

## Requirements

- macOS 13.0+
- Swift 5.9+

## License

MIT
