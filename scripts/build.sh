#!/bin/bash
# =============================================================================
# J-A Hysteresis Library - Build Script
# =============================================================================
# Builds transformer.dsp example as VST3/AU plugin
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DSP_FILE="$PROJECT_DIR/transformer.dsp"
PLUGIN_NAME="Transformer"

JUCER_DIR="$PROJECT_DIR/$PLUGIN_NAME"
JUCER_FILE="$JUCER_DIR/$PLUGIN_NAME.jucer"
BACKUP_FILE="$SCRIPT_DIR/jucer.backup"
PROJUCER="$HOME/JUCE/Projucer.app/Contents/MacOS/Projucer"
BUILD_DIR="$JUCER_DIR/Builds/MacOSX"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

cd "$PROJECT_DIR"

echo "============================================="
echo "Building $PLUGIN_NAME"
echo "============================================="

# Check DSP file
if [ ! -f "$DSP_FILE" ]; then
    echo -e "${RED}Error: DSP file not found: $DSP_FILE${NC}"
    exit 1
fi

# Backup JUCER if exists
if [ -f "$JUCER_FILE" ]; then
    cp "$JUCER_FILE" "$BACKUP_FILE"
    echo "JUCER settings backed up"
fi

# Generate JUCE project
echo ""
echo "Running faust2juce..."
faust2juce -double -I "$PROJECT_DIR" "$DSP_FILE"

# Restore JUCER settings if backup exists
if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$JUCER_FILE"
    echo "JUCER settings restored"
fi

# Check Projucer exists
if [ ! -f "$PROJUCER" ]; then
    echo -e "${RED}Error: Projucer not found at $PROJUCER${NC}"
    echo "Install JUCE or update PROJUCER path in script"
    exit 1
fi

# Generate Xcode project
echo ""
echo "Generating Xcode project..."
"$PROJUCER" --resave "$JUCER_FILE"

# Build VST3
echo ""
echo "Building VST3..."
cd "$BUILD_DIR"
xcodebuild -project "$PLUGIN_NAME.xcodeproj" -scheme "$PLUGIN_NAME - VST3" -configuration Release build | grep -E "(BUILD|error:|warning:)" || true

# Build AU
echo ""
echo "Building AU..."
xcodebuild -project "$PLUGIN_NAME.xcodeproj" -scheme "$PLUGIN_NAME - AU" -configuration Release build | grep -E "(BUILD|error:|warning:)" || true

echo ""
echo "============================================="
echo -e "${GREEN}Build complete${NC}"
echo "============================================="
echo "VST3: ~/Library/Audio/Plug-Ins/VST3/$PLUGIN_NAME.vst3"
echo "AU:   ~/Library/Audio/Plug-Ins/Components/$PLUGIN_NAME.component"
