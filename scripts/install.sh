#!/bin/bash
# =============================================================================
# THE-TRANSFORMER Install Script
# =============================================================================
# Copies built plugins to system plugin folders
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

VST3_INSTALL="$HOME/Library/Audio/Plug-Ins/VST3"
AU_INSTALL="$HOME/Library/Audio/Plug-Ins/Components"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing plugins..."

# Install VST3
if ls "$BUILD_DIR"/*.vst3 1> /dev/null 2>&1; then
    mkdir -p "$VST3_INSTALL"
    cp -R "$BUILD_DIR"/*.vst3 "$VST3_INSTALL/"
    echo -e "${GREEN}VST3 installed to: $VST3_INSTALL${NC}"
else
    echo -e "${YELLOW}No VST3 found in build folder${NC}"
fi

# Install AU
if ls "$BUILD_DIR"/*.component 1> /dev/null 2>&1; then
    mkdir -p "$AU_INSTALL"
    cp -R "$BUILD_DIR"/*.component "$AU_INSTALL/"
    echo -e "${GREEN}AU installed to: $AU_INSTALL${NC}"
else
    echo -e "${YELLOW}No AU found in build folder${NC}"
fi

echo ""
echo "Done. Restart your DAW to load the plugin."
