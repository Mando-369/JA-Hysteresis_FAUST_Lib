#!/bin/bash
# =============================================================================
# J-A Hysteresis Library - Install Script
# =============================================================================
# Installs jahysteresis.lib to Faust library path
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LIB_FILE="$PROJECT_DIR/jahysteresis.lib"

# Faust library paths (check common locations)
FAUST_LIB_PATHS=(
    "/usr/local/share/faust"
    "/usr/share/faust"
    "$HOME/.faust"
    "/opt/homebrew/share/faust"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================="
echo "Installing jahysteresis.lib"
echo "============================================="

# Check library exists
if [ ! -f "$LIB_FILE" ]; then
    echo -e "${RED}Error: Library not found: $LIB_FILE${NC}"
    exit 1
fi

# Find Faust library path
FAUST_LIB=""
for path in "${FAUST_LIB_PATHS[@]}"; do
    if [ -d "$path" ]; then
        FAUST_LIB="$path"
        break
    fi
done

if [ -z "$FAUST_LIB" ]; then
    echo -e "${YELLOW}No standard Faust library path found${NC}"
    echo "Creating ~/.faust directory..."
    FAUST_LIB="$HOME/.faust"
    mkdir -p "$FAUST_LIB"
fi

echo "Installing to: $FAUST_LIB"

# Copy library
if cp "$LIB_FILE" "$FAUST_LIB/" 2>/dev/null; then
    echo -e "${GREEN}Installed: $FAUST_LIB/jahysteresis.lib${NC}"
else
    echo -e "${YELLOW}Permission denied. Trying with sudo...${NC}"
    sudo cp "$LIB_FILE" "$FAUST_LIB/"
    echo -e "${GREEN}Installed: $FAUST_LIB/jahysteresis.lib${NC}"
fi

echo ""
echo "============================================="
echo -e "${GREEN}Installation complete${NC}"
echo "============================================="
echo ""
echo "Usage:"
echo "  ja = library(\"jahysteresis.lib\");"
echo "  process = ja.processor_stereo_ui;"
