# DigiNoise-Personas

Enhanced version of DigiNoise with person-based digital footprint generation.

## New Features

### 🎭 Digital Personas
Choose from 10 pre-configured personas that create realistic browsing patterns:

1. **Korean Gymnast** - Korean news, K-pop, gymnastics, Seoul weather
2. **The Traveling Euro** - European cities, train travel, EUR exchange rates
3. **Silicon Valley Tech Bro** - Tech news, crypto, startup culture
4. **Fitness Enthusiast** - Health, nutrition, sports activities
5. **Foodie Explorer** - Recipes, cooking, culinary culture
6. **Financial Analyst** - Markets, stocks, crypto, economic news
7. **Sports Fan** - Multiple leagues, teams, scores
8. **Digital Nomad** - Time zones, currencies, global weather
9. **University Student** - Academic resources, campus life
10. **General** - Balanced mix of all categories

### 🚀 Quick Start with Personas

```bash
# List available personas
diginoise persona list

# Set your persona
diginoise persona set "Korean Gymnast"

# Start generating noise
diginoise start

# Get detailed info about a persona
diginoise persona info "The Traveling Euro"
```

### 📱 Menu Bar App with Persona Selection

The menu bar app now includes:
- Persona dropdown selector
- Detailed persona information
- Automatic category enabling based on persona
- Visual feedback for active persona

## Building from Source

```bash
# Clone the repository
git clone https://github.com/rosakowski/DigiNoise-Personas.git
cd DigiNoise-Personas

# Build both CLI and Menu Bar app
swift build -c release

# Install CLI
make install

# Install Menu Bar app
make install-menu
```

## Configuration

Personas can be configured through:
1. CLI commands: `diginoise persona set "Persona Name"`
2. Menu bar app: Click persona dropdown
3. Config file: `~/.config/diginoise/config.json`

## How It Works

Each persona includes:
- **Curated API endpoints** specific to the persona's interests
- **Geographic relevance** (e.g., Korean persona gets Korean news/weather)
- **Realistic browsing patterns** based on persona demographics
- **Automatic category selection** when switching personas

## API Endpoints by Persona

### Korean Gymnast (12 endpoints)
- Korean Wikipedia pages
- Seoul/Busan weather
- K-pop and Korean entertainment news
- Gymnastics communities
- Korean movie databases

### The Traveling Euro (15 endpoints)
- European Wikipedia (DE, FR, IT, ES)
- Major European city weather
- Deutsche Bahn train APIs
- EUR exchange rates
- European time zones
- r/europe and r/AskEurope

### And more personas with tailored endpoints...

## Custom Personas

Create your own persona by modifying `Sources/Shared/Personas.swift`:

```swift
case .myPersona:
    return [
        APIEndpoint(url: "https://api.example.com", 
                   description: "Custom API", category: .tech),
        // Add more endpoints...
    ]
```

## Backwards Compatibility

- All original DigiNoise functionality preserved
- Existing configurations work unchanged
- Category toggles still available
- Can switch between "General" (original behavior) and personas

## Installation

### Pre-built Release

1. Download latest release from [Releases](https://github.com/rosakowski/DigiNoise-Personas/releases)
2. Unzip and run installer
3. Launch menu bar app from Applications

### Manual Installation

```bash
# Install CLI and service
make install

# Install menu bar app
make install-menu

# Start with a persona
diginoise persona set "Digital Nomad"
diginoise start
```

## Persona Examples

### Digital Business Traveler
```bash
diginoise persona set "The Traveling Euro"
```
Creates footprint of someone working across Europe with train travel, multiple languages, and business interests.

### Tech Professional
```bash
diginoise persona set "Silicon Valley Tech Bro"
```
Focuses on tech news, crypto, startup culture, and Bay Area weather.

### Fitness Enthusiast
```bash
diginoise persona set "Fitness Enthusiast"
```
Generates activity around fitness communities, healthy recipes, sports, and wellness content.

## Benefits

1. **More Realistic** - Personas create believable digital footprints
2. **Targeted** - Each persona has specific interests and geographic focus
3. **Easy to Use** - One command to switch entire browsing pattern
4. **Extensible** - Easy to add new personas
5. **Visual** - Menu bar shows active persona

## Future Enhancements

- [ ] Custom persona creation via CLI
- [ ] Persona scheduling (different persona at different times)
- [ ] Geographic personas for more countries
- [ ] Professional personas (doctor, lawyer, teacher, etc.)
- [ ] Age-based personas (teenager, retiree, etc.)
- [ ] Seasonal personas (skier in winter, beachgoer in summer)

## License

MIT - Same as original DigiNoise