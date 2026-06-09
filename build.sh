#!/bin/bash
set -e

# Configuration
APP_NAME="AeroClean"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ICON_PNG="/Users/ugurmac/.gemini/antigravity/brain/5956f0c4-a5b2-4d79-a176-97b3aad13a5e/aeroclean_app_icon_1781016582456.png"

echo "=== Building ${APP_NAME}.app ==="

# 1. Recreate bundle directories
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 2. Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/Info.plist"

# 3. Create macOS App Icon (.icns) from PNG
if [ -f "${ICON_PNG}" ]; then
    echo "Creating AppIcon.icns from generated PNG..."
    ICONSET_DIR="AppIcon.iconset"
    rm -rf "${ICONSET_DIR}"
    mkdir -p "${ICONSET_DIR}"
    
    # Generate all icon sizes required by macOS
    sips -s format png -z 16 16     "${ICON_PNG}" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
    sips -s format png -z 32 32     "${ICON_PNG}" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
    sips -s format png -z 32 32     "${ICON_PNG}" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
    sips -s format png -z 64 64     "${ICON_PNG}" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
    sips -s format png -z 128 128   "${ICON_PNG}" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
    sips -s format png -z 256 256   "${ICON_PNG}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
    sips -s format png -z 256 256   "${ICON_PNG}" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
    sips -s format png -z 512 512   "${ICON_PNG}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
    sips -s format png -z 512 512   "${ICON_PNG}" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
    sips -s format png -z 1024 1024 "${ICON_PNG}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null
    
    # Package into .icns
    iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns"
    
    # Cleanup iconset
    rm -rf "${ICONSET_DIR}"
    echo "AppIcon.icns created successfully."
else
    echo "Warning: Icon PNG not found at ${ICON_PNG}. App will build without custom icon."
fi

# 4. Compile Swift sources
echo "Compiling Swift source files..."
swiftc -O -parse-as-library \
    -sdk "$(xcrun --show-sdk-path)" \
    -target arm64-apple-macosx14.0 \
    -o "${MACOS_DIR}/${APP_NAME}" \
    CleanModel.swift \
    AppState.swift \
    DashboardView.swift \
    SystemCleanView.swift \
    LargeFilesView.swift \
    StartupsView.swift \
    UninstallerView.swift \
    DeveloperCleanView.swift \
    SettingsView.swift \
    AeroCleanApp.swift

echo "=== Build Complete: ${BUNDLE_DIR} created successfully ==="
echo "You can open it by typing: open ${BUNDLE_DIR}"
