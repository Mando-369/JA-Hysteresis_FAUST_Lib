#!/bin/bash
# =============================================================================
# THE-TRANSFORMER Syntax Check Script
# =============================================================================
# Tests Faust compilation without building plugins
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DSP_FILE="$PROJECT_DIR/TM_THE_TRANSFORMER.dsp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================="
echo "Checking THE-TRANSFORMER DSP"
echo "============================================="

# Check if DSP file exists
if [ ! -f "$DSP_FILE" ]; then
    echo -e "${RED}Error: DSP file not found: $DSP_FILE${NC}"
    exit 1
fi

# Check if Faust is installed
if ! command -v faust &> /dev/null; then
    echo -e "${RED}Error: Faust not found. Install from https://faust.grame.fr${NC}"
    exit 1
fi

# Show Faust version
echo "Faust version: $(faust --version 2>&1 | head -1)"
echo ""

# Compile to C++ with double precision (syntax check)
echo "Compiling with -double flag..."
if faust -double "$DSP_FILE" -o /dev/null 2>&1; then
    echo -e "${GREEN}Compilation successful!${NC}"
else
    echo -e "${RED}Compilation failed:${NC}"
    faust -double "$DSP_FILE" 2>&1
    exit 1
fi

# Show signal info
echo ""
echo "Signal analysis:"
faust -double "$DSP_FILE" 2>&1 | grep -E "(inputs|outputs|controls)" || true

echo ""
echo "============================================="
echo -e "${GREEN}DSP check passed${NC}"
echo "============================================="
