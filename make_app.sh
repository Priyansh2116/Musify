#!/bin/bash
# Builds a release binary and assembles "Musify.app" — a self-contained,
# Dock-less menu-bar app. Works with just the Command Line Tools (no Xcode).
set -euo pipefail
cd "$(dirname "$0")"

APP_NAME="Musify"
BUNDLE="build/${APP_NAME}.app"
EXEC_NAME="Musify"

echo "▸ Building release…"
swift build -c release

echo "▸ Assembling bundle…"
rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS"
mkdir -p "$BUNDLE/Contents/Resources"

cp ".build/release/${EXEC_NAME}" "$BUNDLE/Contents/MacOS/${EXEC_NAME}"
cp "Resources/Info.plist" "$BUNDLE/Contents/Info.plist"
printf 'APPL????' > "$BUNDLE/Contents/PkgInfo"

# Ad-hoc sign so macOS keeps a stable Automation-permission identity across runs.
echo "▸ Signing (ad-hoc)…"
codesign --force --deep --sign - "$BUNDLE" >/dev/null 2>&1 || \
    echo "  (codesign skipped — app still runs unsigned)"

echo "✓ Built: $BUNDLE"
echo "  Run:   open \"$BUNDLE\""
echo "  (First launch will ask permission to control Music / Spotify.)"
