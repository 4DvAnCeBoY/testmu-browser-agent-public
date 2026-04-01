#!/bin/bash
# form-automation.sh
#
# Description: Demonstrates filling and submitting an HTML form using
#              testmu-browser-agent. Uses the httpbin.org pizza order form
#              as a demo target.
#
# Usage:
#   bash form-automation.sh [url]
#   bash form-automation.sh https://httpbin.org/forms/post
#
# Environment variables:
#   TARGET_URL       Form page URL (default: https://httpbin.org/forms/post)
#   CUSTOMER_NAME    Name to fill in (default: Jane Doe)
#   CUSTOMER_PHONE   Phone number to fill in (default: 555-0100)
#   CUSTOMER_EMAIL   Email to fill in (default: jane@example.com)
#   PIZZA_SIZE       Pizza size to select: small, medium, large (default: medium)
#   SCREENSHOT_FILE  Output screenshot path (default: form-result.png)

set -euo pipefail

BIN="testmu-browser-agent"
TARGET_URL="${1:-https://httpbin.org/forms/post}"
CUSTOMER_NAME="${CUSTOMER_NAME:-Jane Doe}"
CUSTOMER_PHONE="${CUSTOMER_PHONE:-555-0100}"
CUSTOMER_EMAIL="${CUSTOMER_EMAIL:-jane@example.com}"
PIZZA_SIZE="${PIZZA_SIZE:-medium}"
SCREENSHOT_FILE="${SCREENSHOT_FILE:-form-result.png}"

echo "==> Opening form: ${TARGET_URL}"
$BIN open "$TARGET_URL"

# --- Snapshot to discover interactive element refs ---
echo "==> Snapshotting interactive elements..."
$BIN snapshot

# --- Fill text fields ---
echo "==> Filling form fields..."
$BIN fill '[name="custname"]'  "$CUSTOMER_NAME"
$BIN fill '[name="custtel"]'   "$CUSTOMER_PHONE"
$BIN fill '[name="custemail"]' "$CUSTOMER_EMAIL"

# --- Select pizza size from dropdown ---
echo "==> Selecting pizza size: ${PIZZA_SIZE}"
$BIN select '[name="size"]' "$PIZZA_SIZE"

# --- Check the "Bacon" topping checkbox ---
echo "==> Checking bacon topping..."
$BIN check '[name="topping"][value="bacon"]'

# --- Submit the form ---
echo "==> Submitting form..."
$BIN click '[type="submit"]'

# --- Wait for the result page to load ---
$BIN wait --text "Customer name" --timeout 15

# --- Snapshot the result to verify submission ---
echo "==> Verifying submission result..."
$BIN snapshot

# --- Take a screenshot for visual record ---
echo "==> Taking screenshot -> ${SCREENSHOT_FILE}"
$BIN screenshot --output "$SCREENSHOT_FILE" --format png

echo "==> Form automation complete. Screenshot saved to ${SCREENSHOT_FILE}."
$BIN close
