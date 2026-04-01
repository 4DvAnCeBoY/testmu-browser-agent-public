#!/bin/bash
# Form Fill Demo — opens httpbin.org/forms/post, snapshots to discover refs,
# fills fields, submits, and captures screenshots at each step.
# Run from the project root: bash marketing/demos/demo-form-fill.sh

set -euo pipefail

TBA="bin/testmu-browser-agent"
OUT="marketing/demos/screenshots"
mkdir -p "$OUT"

echo "=== Form Fill Demo ==="

echo ""
echo "Step 1: Open httpbin.org/forms/post"
$TBA open https://httpbin.org/forms/post
$TBA screenshot --output "$OUT/form-01-open.png"
echo "  -> screenshot saved: $OUT/form-01-open.png"

echo ""
echo "Step 2: Snapshot to discover element refs"
$TBA snapshot

echo ""
echo "Step 3: Fill customer name"
$TBA fill @e1 "Alice Example"

echo ""
echo "Step 4: Fill telephone"
$TBA fill @e2 "555-0100"

echo ""
echo "Step 5: Fill email"
$TBA fill @e3 "alice@example.com"

echo ""
echo "Step 6: Select pizza size (Medium)"
$TBA click @e5

echo ""
echo "Step 7: Check a topping"
$TBA check @e7

echo ""
echo "Step 8: Screenshot before submitting"
$TBA screenshot --output "$OUT/form-02-filled.png"
echo "  -> screenshot saved: $OUT/form-02-filled.png"

echo ""
echo "Step 9: Submit the form"
$TBA click @e12

echo ""
echo "Step 10: Snapshot result page"
$TBA snapshot

echo ""
echo "Step 11: Screenshot of submission result"
$TBA screenshot --output "$OUT/form-03-result.png"
echo "  -> screenshot saved: $OUT/form-03-result.png"

echo ""
echo "Step 12: Close browser session"
$TBA close

echo ""
echo "=== Done! Screenshots saved to $OUT ==="
