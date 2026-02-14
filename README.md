# DigiNoise

**Digital noise generator for privacy.** Runs in your menu bar, makes automated API calls to obscure your online footprint.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue) ![License](https://img.shields.io/badge/License-MIT-green)

---

## ⬇️ Download

**[Download DigiNoise for macOS](https://github.com/rosakowski/DigiNoise-CLI/releases/latest)**

---

## 🚀 Quick Start

1. **Download** the zip from above
2. **Unzip** → Drag `DigiNoise.app` to **Applications**
3. **Launch** — Click 📡 in your menu bar
4. **Done!** — It auto-starts generating noise

That's it. No terminal, no setup.

---

## What It Does

Makes 1-5 random API calls per day (Wikipedia, weather, news, tech) to create a realistic browsing pattern that masks your actual activity.

- **60+ endpoints** across 11 categories
- **Customizable** — choose categories that match your persona
- **Menu bar control** — start/stop with one click
- **Minimal battery** — exits between requests

---

## Features

| Feature | Description |
|---------|-------------|
| 📡 Menu Bar App | One-click control in your menu bar |
| 🎭 Personas | Pre-built profiles (Tech Bro, Foodie, Traveler, etc.) |
| 📊 Activity Log | See what requests were made |
| ⚙️ Settings | Adjust daily limits, active hours, categories |
| 🔒 Privacy-First | No tracking, no cloud, runs locally |

---

## Building From Source

```bash
git clone https://github.com/rosakowski/DigiNoise-CLI.git
cd DigiNoise-CLI

# Build the .app bundle
chmod +x scripts/build-app.sh
./scripts/build-app.sh

# Or install CLI directly
make install
```

---

## Requirements

- macOS 13.0+ (Ventura or later)

---

## License

MIT
