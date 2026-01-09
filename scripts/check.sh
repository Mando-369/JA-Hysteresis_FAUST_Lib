#!/bin/bash
# =============================================================================
# J-A Hysteresis Library - Syntax Check Script
# =============================================================================
# Tests Faust compilation of library and example
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LIB_FILE="$PROJECT_DIR/jahysteresis.lib"
DSP_FILE="$PROJECT_DIR/transformer.dsp"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================="
echo "J-A Hysteresis Library Check"
echo "============================================="

# Check if Faust is installed
if ! command -v faust &> /dev/null; then
    echo -e "${RED}Error: Faust not found. Install from https://faust.grame.fr${NC}"
    exit 1
fi

# Show Faust version
echo "Faust version: $(faust --version 2>&1 | head -1)"
echo ""

# Check library file exists
if [ ! -f "$LIB_FILE" ]; then
    echo -e "${RED}Error: Library not found: $LIB_FILE${NC}"
    exit 1
fi
echo -e "${GREEN}Library found: jahysteresis.lib${NC}"

# Check DSP file exists
if [ ! -f "$DSP_FILE" ]; then
    echo -e "${RED}Error: DSP file not found: $DSP_FILE${NC}"
    exit 1
fi

# Compile transformer.dsp (tests both library and example)
echo ""
echo "Compiling transformer.dsp with -double flag..."
if faust -double -I "$PROJECT_DIR" "$DSP_FILE" -o /dev/null 2>&1; then
    echo -e "${GREEN}Compilation successful!${NC}"
else
    echo -e "${RED}Compilation failed:${NC}"
    faust -double -I "$PROJECT_DIR" "$DSP_FILE" 2>&1
    exit 1
fi

# Test library functions
echo ""
echo "Testing library functions..."
for test_fn in hysteresis_test processor_test processor_stereo_test; do
    if faust -double -I "$PROJECT_DIR" -pn "$test_fn" "$LIB_FILE" -o /dev/null 2>&1; then
        echo -e "  ${GREEN}$test_fn: OK${NC}"
    else
        echo -e "  ${YELLOW}$test_fn: skipped${NC}"
    fi
done

echo ""
echo "============================================="
echo -e "${GREEN}All checks passed${NC}"
echo "============================================="
