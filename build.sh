#!/bin/bash
set -e

# Configuration
APP_NAME="AeroClean"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ICON_PNG="icon.png"

echo "=== Building ${APP_NAME}.app ==="

# 1. Recreate bundle directories
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 2. Copy Info.plist
cp Info.plist "${CONTENTS_DIR}/Info.plist"

# 3. Create macOS App Icon (.icns) from PNG
# Determine icon source
ICON_SRC=""
if [ -f "${ICON_PNG}" ]; then
    ICON_SRC="${ICON_PNG}"
elif [ -f "AeroClean-Windows/icon.png" ]; then
    ICON_SRC="AeroClean-Windows/icon.png"
    echo "Using fallback icon from AeroClean-Windows/icon.png"
fi

if [ -n "${ICON_SRC}" ]; then
    echo "Creating AppIcon.icns from ${ICON_SRC}..."
    ICONSET_DIR="AppIcon.iconset"
    rm -rf "${ICONSET_DIR}"
    mkdir -p "${ICONSET_DIR}"
    
    # Generate all icon sizes required by macOS
    sips -s format png -z 16 16     "${ICON_SRC}" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
    sips -s format png -z 32 32     "${ICON_SRC}" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
    sips -s format png -z 32 32     "${ICON_SRC}" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
    sips -s format png -z 64 64     "${ICON_SRC}" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
    sips -s format png -z 128 128   "${ICON_SRC}" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
    sips -s format png -z 256 256   "${ICON_SRC}" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
    sips -s format png -z 256 256   "${ICON_SRC}" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
    sips -s format png -z 512 512   "${ICON_SRC}" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
    sips -s format png -z 512 512   "${ICON_SRC}" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
    sips -s format png -z 1024 1024 "${ICON_SRC}" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null
    
    # Package into .icns
    iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns"
    
    # Cleanup iconset
    rm -rf "${ICONSET_DIR}"
    echo "AppIcon.icns created successfully."
else
    echo "Warning: Icon PNG not found. App will build without custom icon."
fi

# 4. Compile Swift sources
echo "Compiling Swift source files..."
SWIFT_SOURCES="CleanModel.swift AppState.swift ThemeBackgroundView.swift DashboardView.swift SystemCleanView.swift LargeFilesView.swift StartupsView.swift UninstallerView.swift DeveloperCleanView.swift SettingsView.swift AeroCleanApp.swift"

if [ "$1" = "--universal" ] || [ "${UNIVERSAL}" = "true" ]; then
    echo "Compiling for arm64..."
    swiftc -O -parse-as-library -sdk "$(xcrun --show-sdk-path)" -target arm64-apple-macosx14.0 -o "${MACOS_DIR}/${APP_NAME}_arm64" $SWIFT_SOURCES
    
    echo "Compiling for x86_64..."
    swiftc -O -parse-as-library -sdk "$(xcrun --show-sdk-path)" -target x86_64-apple-macosx14.0 -o "${MACOS_DIR}/${APP_NAME}_x86_64" $SWIFT_SOURCES
    
    echo "Creating Universal binary using lipo..."
    lipo -create -output "${MACOS_DIR}/${APP_NAME}" "${MACOS_DIR}/${APP_NAME}_arm64" "${MACOS_DIR}/${APP_NAME}_x86_64"
    rm -f "${MACOS_DIR}/${APP_NAME}_arm64" "${MACOS_DIR}/${APP_NAME}_x86_64"
else
    echo "Compiling for arm64..."
    swiftc -O -parse-as-library -sdk "$(xcrun --show-sdk-path)" -target arm64-apple-macosx14.0 -o "${MACOS_DIR}/${APP_NAME}" $SWIFT_SOURCES
fi

# 5. Codesign
if [ -n "${SIGNING_IDENTITY}" ]; then
    echo "Signing the application bundle with identity: ${SIGNING_IDENTITY} (Hardened Runtime)..."
    codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUNDLE_DIR}"
else
    echo "Signing the application bundle (ad-hoc codesign)..."
    codesign --force --deep --sign - "${BUNDLE_DIR}"
fi

# 6. Create distributable installer DMG image
echo "Creating distributable installer DMG image..."
DMG_TEMP="dmg_temp"
rm -rf "${DMG_TEMP}"
mkdir -p "${DMG_TEMP}"

# Copy app bundle to temp
cp -R "${BUNDLE_DIR}" "${DMG_TEMP}/"

# Create Applications folder symlink
ln -s /Applications "${DMG_TEMP}/Applications"

# Create DMG file
rm -f "${APP_NAME}.dmg"
hdiutil create -volname "${APP_NAME}" -srcfolder "${DMG_TEMP}" -ov -format UDZO "${APP_NAME}.dmg"

# Cleanup temp directory
rm -rf "${DMG_TEMP}"

echo "=== Build Complete ==="
echo "Application: ${BUNDLE_DIR}"
echo "Installer DMG: ${APP_NAME}.dmg"
echo "You can launch the app with: open ${BUNDLE_DIR}"

