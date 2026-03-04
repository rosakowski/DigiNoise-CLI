#!/bin/bash
# DigiNoise Uninstaller
# Run this before installing a new version

echo "Uninstalling DigiNoise..."

# Remove from Applications
if [ -d "/Applications/DigiNoise.app" ]; then
    rm -rf "/Applications/DigiNoise.app"
    echo "✓ Removed DigiNoise.app from Applications"
fi

# Remove config (optional - comment out to keep settings)
if [ -d "$HOME/.config/diginoise" ]; then
    rm -rf "$HOME/.config/diginoise"
    echo "✓ Removed config files"
fi

# Remove logs (optional)
if [ -d "$HOME/.local/share/diginoise" ]; then
    rm -rf "$HOME/.local/share/diginoise"
    echo "✓ Removed log files"
fi

echo "✓ DigiNoise uninstalled successfully"
echo ""
echo "You can now install the new version."
