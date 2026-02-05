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
3. Makes a random API call from 60+ endpoints across enabled categories
4. Calculates a random interval (1-6 hours) for the next request
5. Exits - launchd restarts it in 15 minutes

**Result:** 1-5 requests per day, reliably, without keeping a process running.

---

## Configuration

### Basic Settings

```bash
# Daily limit and active hours
diginoise config --limit 5 --start 8 --end 22
```

### Category Toggles (NEW!)

Customize which API categories to ping:

```bash
# View current category settings
diginoise config

# Enable specific categories
diginoise config categories --finance --sports --recipes

# Disable categories you don't want
diginoise config categories --no-finance --no-sports

# Toggle a category (enable if disabled, disable if enabled)
diginoise config categories --finance
```

All categories are enabled by default. Toggle off what doesn't fit your persona.

---

## API Categories (60+ Endpoints)

| Category | Endpoints | Description |
|----------|-----------|-------------|
| **Reference** | 6 | Wikipedia in 6 languages |
| **Weather** | 14 | Global cities on all continents |
| **Tech** | 2 | Hacker News, GitHub Activity |
| **News** | 3 | Reddit: worldnews, science, space |
| **Finance** | 5 | Bitcoin, crypto rates, S&P 500, Dow, NASDAQ |
| **Science** | (in News) | Space and science news |
| **Entertainment** | 5 | Art Institute, Open Library, Dogs, Cocktails, Activities |
| **Lifestyle** | 1 | Random quotes |
| **Sports** | 3 | Sports list, countries, Premier League |
| **Recipes** | 2 | Random meals from TheMealDB |
| **Travel** | 3 | Country facts, exchange rates, world time |

### Detailed Endpoint List

**Wikipedia (6):** EN, ES, FR, DE, IT, PT

**Weather (14 cities):**
- Europe: London, Paris, Berlin, Rome, Moscow
- Asia: Tokyo, Beijing, Singapore, Dubai, New Delhi, Jakarta
- Americas: NYC, LA, Mexico City, São Paulo, Sydney, Toronto
- Africa: Cape Town, Nairobi

**Finance (5):**
- CoinDesk Bitcoin price
- Coinbase crypto rates
- Yahoo Finance: S&P 500, Dow Jones, NASDAQ

**Sports (3):**
- TheSportsDB: All sports list
- TheSportsDB: All countries
- Football-Data: Premier League matches

**Recipes (2):**
- TheMealDB: Random meal
- TheMealDB: Random selection

**Travel (3):**
- REST Countries: Country facts
- Exchange Rate API: Currency rates
- World Time API: Current time by IP

---

## Log File

Activity logged to: `~/.local/share/diginoise/diginoise.log`

View with menu bar "View Log" button or: `diginoise log`

---

## Digital Footprint Diversity

The app creates a realistic browsing pattern by calling diverse APIs. **Customize which categories match your persona:**

**International Persona:**
- Reference: Wikipedia in 6 languages
- Weather: 14 cities across all continents
- Travel: Country facts, exchange rates, world time

**Professional/Investor Persona:**
- Tech: Hacker News, GitHub Activity
- Finance: Bitcoin, crypto, stock indices (S&P 500, Dow, NASDAQ)
- News: World events, science, space

**Lifestyle/Casual Persona:**
- Entertainment: Art, books, dog photos, cocktails
- Recipes: Food inspiration
- Lifestyle: Quotes, activity suggestions
- Sports: Premier League, general sports

**Mix and match** to create your ideal digital footprint. Toggle off categories that don't fit.

### Example Personas

```bash
# The Global Business Traveler
diginoise config categories --no-sports --no-recipes
# Enables: Reference, Weather, Tech, News, Finance, Travel

# The Foodie Creative
diginoise config categories --no-finance --no-sports --no-tech
# Enables: Reference, Weather, News, Entertainment, Lifestyle, Recipes

# The Minimalist
diginoise config categories --no-finance --no-sports --no-recipes --no-travel --no-entertainment
# Enables: Just Reference, Weather, Tech, News

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
