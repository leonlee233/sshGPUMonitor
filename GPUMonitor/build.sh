#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"
APP_NAME="GPUMonitor"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

if [ ! -d "/Applications/Xcode.app" ]; then
    echo "Error: Xcode.app is required to build this project."
    echo "Please install Xcode from the App Store, then run:"
    echo "  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo ""
    echo "After installing Xcode, you can also open Package.swift directly in Xcode."
    exit 1
fi

echo "Building $APP_NAME..."

mkdir -p "$BUILD_DIR"

echo "Compiling..."
swiftc \
    -target arm64-apple-macosx13.0 \
    -sdk $(xcrun --show-sdk-path) \
    -o "$BUILD_DIR/$APP_NAME" \
    -framework SwiftUI \
    -framework Combine \
    -framework Foundation \
    -framework AppKit \
    -framework ServiceManagement \
    "$PROJECT_DIR/Sources/GPUMonitor/Models/GPUInfo.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Models/ServerConfig.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Services/SSHManager.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Services/KeyFileManager.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Services/ConfigStore.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Services/AutoStartManager.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/ViewModels/GPUMonitorViewModel.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Views/GPUBarView.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Views/GPUBarChartView.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Views/FloatingWindowController.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Views/ServerConfigView.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/Views/MenuBarView.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/AppDelegate.swift" \
    "$PROJECT_DIR/Sources/GPUMonitor/GPUMonitorApp.swift"

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>GPUMonitor</string>
    <key>CFBundleIdentifier</key>
    <string>com.gpumonitor.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>GPU Monitor</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

rm "$BUILD_DIR/$APP_NAME"

echo "Build complete: $APP_BUNDLE"
echo "Run with: open \"$APP_BUNDLE\""
