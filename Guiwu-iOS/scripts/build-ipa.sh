#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

plutil -lint "$ROOT_DIR/Guiwu.xcodeproj/project.pbxproj"

xcodebuild \
  -project "$ROOT_DIR/Guiwu.xcodeproj" \
  -scheme Guiwu \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  -archivePath "$BUILD_DIR/Guiwu.xcarchive" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  archive

APP_PATH="$BUILD_DIR/Guiwu.xcarchive/Products/Applications/Guiwu.app"
test -f "$APP_PATH/Guiwu"
test -f "$APP_PATH/Info.plist"

STAGING_DIR="$(mktemp -d "$BUILD_DIR/package.XXXXXX")"
mkdir -p "$STAGING_DIR/Payload"
ditto "$APP_PATH" "$STAGING_DIR/Payload/Guiwu.app"
ditto -c -k --keepParent "$STAGING_DIR/Payload" "$BUILD_DIR/Guiwu-unsigned.ipa"

unzip -t "$BUILD_DIR/Guiwu-unsigned.ipa"
echo 'Created build/Guiwu-unsigned.ipa. Sign on Windows before installing.'
