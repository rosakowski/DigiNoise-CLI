# DigiNoise CLI

A lightweight Mac tool that generates "digital noise" by making automated API requests to obscure your online footprint. Available as both a CLI tool and a menu bar app.

## Two Interfaces

### 1. Command Line Tool
For Terminal users who prefer keyboard control.

### 2. Menu Bar App ⭐ (Recommended)
A visual interface in your Mac's menu bar with one-click control and live status.

---

## Installation

### Full Install (CLI + Menu Bar)

```bash
git clone https://github.com/rosakowski/DigiNoise-CLI.git
cd DigiNoise-CLI
make install           # Installs CLI and launchd service
make install-menu      # Installs menu bar app
```

### Menu Bar App Only

```bash
make install-menu
```

Then launch **DigiNoiseMenuBar** from Applications or Spotlight.

---

## Menu Bar App

The menu bar app provides:

- **🟢/🔴 Status indicator** - Green when running, red when stopped
- **Click to expand** - Shows detailed status and controls
- **Today's request count** - See your daily progress
- **Recent activity log** - Last 8 entries
- **Start/Stop button** - Toggle with one click
- **Settings** - Adjust limits and hours
- **View Log** - Open full log file

### Menu Bar Screenshot

```
┌─────────────────────────────┐
│ DigiNoise              🟢   │
├─────────────────────────────┤
│ Status: Running             │
│ Today's Requests: 2/5       │
│ Active Hours: 7:00-23:00    │
├─────────────────────────────┤
│ Recent Activity             │
│ [2026-02-05] Success: Wiki  │
│ [2026-02-05] Success: Weather│
├─────────────────────────────┤
│ [  Stop  ]                  │
│ [Settings] [View Log]       │
└─────────────────────────────┘
```

---

## CLI Usage

If you prefer Terminal:

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

# Uninstall
diginoise uninstall
```

---

## How It Works

1. **launchd** runs the daemon every 15 minutes
2. Daemon checks if it should make a request (within limits/hours)
3. Makes a random API call from 40 endpoints:
   - Wikipedia (6 languages: EN, ES, FR, DE, IT, PT) - random articles
   - Weather (14 global cities across all continents)
   - Tech (Hacker News, GitHub Activity)
   - News/Science (Reddit: worldnews, science, space)
   - Entertainment (Art Institute, Open Library, Dog Photos)
   - Lifestyle (Quotes, Cocktail recipes)
4. Calculates a random interval (1-6 hours) for the next request
5. Exits - launchd restarts it in 15 minutes

**Result:** 1-5 requests per day, reliably, without keeping a process running.

---

## Configuration

Settings stored in `~/.config/diginoise/config.json`:

| Option | Default | Description |
|--------|---------|-------------|
| `dailyLimit` | 5 | Max requests per day |
| `startHour` | 7 | Earliest hour to run (24h) |
| `endHour` | 23 | Latest hour to run (24h) |

Change via menu bar Settings or: `diginoise config --limit 5 --start 8 --end 22`

---

## Log File

Activity logged to: `~/.local/share/diginoise/diginoise.log`

View with menu bar "View Log" button or: `diginoise log`

---

## Digital Footprint Diversity

The app creates a realistic browsing pattern by calling diverse APIs:

**Reference (6 sources):** Wikipedia articles in 6 languages (EN, ES, FR, DE, IT, PT)

**Weather (14 cities):** Global coverage across all continents
- Europe: London, Paris, Berlin, Rome, Moscow
- Asia: Tokyo, Beijing, Singapore, Dubai, New Delhi, Jakarta
- Americas: NYC, LA, Mexico City, São Paulo, Sydney, Toronto
- Africa: Cape Town, Nairobi

**Tech (2 sources):** Hacker News, GitHub public events

**News/Science (3 sources):** Reddit worldnews, science, space

**Entertainment (4 sources):** Art Institute, Open Library, Dog photos, Cocktail recipes

**Lifestyle (1 source):** Random quotes

This variety makes your traffic look like someone who:
- Checks weather in places they travel or have connections to
- Reads tech news and follows coding
- Is interested in science, art, and culture
- Enjoys casual entertainment browsing

---

## Why This Works Better Than iOS

| Feature | iOS App | Mac CLI/Menu Bar |
|---------|---------|------------------|
| Background reliability | ❌ iOS decides when to run | ✅ launchd guarantees execution |
| Process running? | Must stay in memory | Exits between runs |
| Battery impact | Higher | Minimal |
| Visibility | Hidden in app switcher | Always visible in menu bar |
| Control | Open app, navigate | One click in menu bar |

---

## Uninstall

```bash
diginoise uninstall          # Remove service
rm /usr/local/bin/diginoise  # Remove CLI
rm -rf /Applications/DigiNoiseMenuBar.app  # Remove menu bar app
rm -rf ~/.config/diginoise ~/.local/share/diginoise  # Remove data
```

---

## Requirements

- macOS 13.0+
- Swift 5.9+ (for building from source)

---

## License

MIT
