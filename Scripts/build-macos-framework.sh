#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.
set -e

# The directory for final output of the framework.
PRODUCTS_DIR="${SRCROOT}/../WindowsAzureMessaging-SDK-Apple/macOS"

# Cleaning the previous builds.
rm -rf "${PRODUCTS_DIR}/${PROJECT_NAME}.framework"

# Creates the final product folder.
mkdir -p "${PRODUCTS_DIR}"

# Copy framework.
cp -RHv "${BUILD_DIR}/${CONFIGURATION}/${PROJECT_NAME}.framework" "${PRODUCTS_DIR}"
