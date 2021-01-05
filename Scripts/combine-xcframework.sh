#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Cleaning the previous builds.
rm -rf "${BUILT_PRODUCTS_DIR}/${PROJECT_NAME}.xcframework"

# Create a command to build XCFramework.
function add_framework() {
  local framework_path="$1/${PRODUCT_NAME}.framework"
  [ -e "${framework_path}" ] && XC_FRAMEWORKS+=( -framework "${framework_path}")
}
add_framework "${BUILD_DIR}/${CONFIGURATION}"
for SDK in iphoneos iphonesimulator appletvos appletvsimulator maccatalyst; do
  add_framework "${BUILD_DIR}/${CONFIGURATION}-${SDK}"
done

# Build XCFramework.
xcodebuild -create-xcframework "${XC_FRAMEWORKS[@]}" -output "${BUILT_PRODUCTS_DIR}/${PROJECT_NAME}.xcframework"