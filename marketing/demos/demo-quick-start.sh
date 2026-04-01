#!/bin/bash
# Quick Start Demo — opens example.com and captures screenshots at each step.
# Run from the project root: bash marketing/demos/demo-quick-start.sh

set -euo pipefail

TBA="bin/testmu-browser-agent"
OUT="marketing/demos/screenshots"
mkdir -p "$OUT"

echo "=== Quick Start Demo ==="

echo ""
echo "Step 1: Open example.com"
$TBA open https://example.com
$TBA screenshot --output "$OUT/01-open.png"
echo "  -> screenshot saved: $OUT/01-open.png"

echo ""
echo "Step 2: Take accessibility snapshot"
$TBA snapshot

echo ""
echo "Step 3: Click the first link (@e1)"
$TBA click @e1
$TBA screenshot --output "$OUT/02-clicked.png"
echo "  -> screenshot saved: $OUT/02-clicked.png"

echo ""
echo "Step 4: Close browser session"
$TBA close

echo ""
echo "=== Done! Screenshots saved to $OUT ==="
