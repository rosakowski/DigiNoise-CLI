#!/bin/bash
# DigiNoise App Bundle Builder
# Creates a distributable .app bundle from SPM build

set -e

APP_NAME="DigiNoise"
BUNDLE_ID="com.diginoise.app"
VERSION="1.0.17"

echo "🔨 Building DigiNoise Menu Bar..."

# Clean previous builds
rm -rf .build/release/DigiNoiseMenuBar
rm -rf dist/

# Build the Menu Bar app
swift build -c release --product DigiNoiseMenuBar

# Create .app bundle structure
APP_DIR="dist/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Creating app bundle..."

mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy the executable
cp ".build/release/DigiNoiseMenuBar" "${MACOS_DIR}/${APP_NAME}"

# Create Info.plist (this goes in Contents, not Resources!)
cat > "${CONTENTS_DIR}/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>DigiNoise</string>
    <key>CFBundleIdentifier</key>
    <string>com.diginoise.app</string>
    <key>CFBundleName</key>
    <string>DigiNoise</string>
    <key>CFBundleDisplayName</key>
    <string>DigiNoise</string>
    <key>CFBundleVersion</key>
    <string>1.0.17</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.17</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>DigiNoise</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 DigiNoise. All rights reserved.</string>
</dict>
</plist>
EOF

# Copy the icon (if exists in assets folder)
if [ -f "assets/DigiNoise.icns" ]; then
    cp "assets/DigiNoise.icns" "${RESOURCES_DIR}/"
fi

# Create PkgInfo
echo "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# Create a simple install script
cat > "dist/install.sh" << 'EOF'
#!/bin/bash
# DigiNoise Installer
# Double-click to install to /Applications

APP_NAME="DigiNoise"
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APP_PATH="${SOURCE_DIR}/${APP_NAME}.app"
DEST_DIR="/Applications"

if [ -d "${DEST_DIR}/${APP_NAME}.app" ]; then
    echo "Removing old version..."
    rm -rf "${DEST_DIR}/${APP_NAME}.app"
fi

echo "Installing to /Applications..."
cp -R "${APP_PATH}" "${DEST_DIR}/"

# Also copy config directory to ensure it exists
mkdir -p ~/.config/diginoise
mkdir -p ~/.local/share/diginoise

echo "✅ DigiNoise installed to /Applications!"
echo ""
echo "Launch DigiNoise from:"
echo "  • /Applications folder"
echo "  • Spotlight search (⌘+Space, type 'DigiNoise')"
echo ""
echo "The app will appear in your menu bar as 📡"
EOF

chmod +x "dist/install.sh"

# Create zip archive for easy distribution
cd dist
zip -r "${APP_NAME}-${VERSION}-macOS.zip" "${APP_NAME}.app" "install.sh"
cd ..

echo ""
echo "✅ Build complete!"
echo ""
echo "Output files in dist/:"
ls -la dist/
echo ""
echo "📦 Distributable: dist/${APP_NAME}-${VERSION}-macOS.zip"
echo ""
echo "To install:"
echo "  1. Unzip the file"
echo "  2. Double-click 'install.sh' or drag .app to /Applications"
