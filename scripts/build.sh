#!/bin/bash
# THE-TRANSFORMER Build Script
# Plugin ID: OmegaDSP / TTfm

cd "$(dirname "$0")/.."

JUCER_FILE="TM_THE_TRANSFORMER/TM_THE_TRANSFORMER.jucer"
BACKUP_FILE="scripts/jucer.backup"
PROJUCER="$HOME/JUCE/Projucer.app/Contents/MacOS/Projucer"
BUILD_DIR="TM_THE_TRANSFORMER/Builds/MacOSX"

# Backup JUCER to scripts folder (survives folder deletion)
if [ -f "$JUCER_FILE" ]; then
    cp "$JUCER_FILE" "$BACKUP_FILE"
fi

# Generate JUCE project (overwrites entire folder)
echo "Running faust2juce..."
faust2juce -double TM_THE_TRANSFORMER.dsp

# Restore our JUCER settings
if [ -f "$BACKUP_FILE" ]; then
    cp "$BACKUP_FILE" "$JUCER_FILE"
    echo "JUCER settings preserved"
fi

# Generate Xcode project from JUCER
echo "Generating Xcode project..."
"$PROJUCER" --resave "$JUCER_FILE"

# Build VST3
echo "Building VST3..."
cd "$BUILD_DIR"
xcodebuild -project TM_THE_TRANSFORMER.xcodeproj -scheme "TM_THE_TRANSFORMER - VST3" -configuration Release build | grep -E "(BUILD|error:|warning:)"

# Build AU
echo "Building AU..."
xcodebuild -project TM_THE_TRANSFORMER.xcodeproj -scheme "TM_THE_TRANSFORMER - AU" -configuration Release build | grep -E "(BUILD|error:|warning:)"

echo ""
echo "Done. Plugins installed:"
echo "  VST3: ~/Library/Audio/Plug-Ins/VST3/TM_THE_TRANSFORMER.vst3"
echo "  AU:   ~/Library/Audio/Plug-Ins/Components/TM_THE_TRANSFORMER.component"
