#!/bin/bash
# capture-workflow.sh
#
# Description: Full capture workflow — open a page, snapshot the accessibility
#              tree, take a screenshot, extract structured data via JS
#              evaluation, and generate a PDF.
#
# Usage:
#   bash capture-workflow.sh [url]
#   bash capture-workflow.sh https://books.toscrape.com
#
# Environment variables:
#   TARGET_URL      Page to capture (default: https://books.toscrape.com)
#   OUTPUT_DIR      Directory for output files (default: current directory)
#   SCREENSHOT_FILE Filename for screenshot (default: page.png)
#   PDF_FILE        Filename for PDF output (default: page.pdf)

set -euo pipefail

BIN="testmu-browser-agent"
TARGET_URL="${1:-https://books.toscrape.com}"
OUTPUT_DIR="${OUTPUT_DIR:-.}"
SCREENSHOT_FILE="${SCREENSHOT_FILE:-page.png}"
PDF_FILE="${PDF_FILE:-page.pdf}"

echo "==> Opening: ${TARGET_URL}"
$BIN open "$TARGET_URL"

# --- Accessibility snapshot to understand page structure ---
echo "==> Snapshotting page structure..."
$BIN snapshot

# --- Screenshot for visual record ---
echo "==> Taking screenshot -> ${OUTPUT_DIR}/${SCREENSHOT_FILE}"
$BIN screenshot --output "${OUTPUT_DIR}/${SCREENSHOT_FILE}" --format png

# --- Get the page title ---
echo "==> Page title:"
$BIN get title

# --- Get visible text from the inner content container ---
echo "==> Page text (.page_inner):"
$BIN get text .page_inner

# --- Evaluate JavaScript to extract structured data ---
# Collects all book titles and prices as a JSON array
echo "==> Extracting structured data (books JSON)..."
$BIN eval 'JSON.stringify(
  Array.from(document.querySelectorAll("article.product_pod")).map(function(el) {
    return {
      title: el.querySelector("h3 a").getAttribute("title"),
      price: el.querySelector(".price_color").textContent.trim()
    };
  })
)'

# --- Generate a PDF of the full page ---
echo "==> Generating PDF -> ${OUTPUT_DIR}/${PDF_FILE}"
$BIN pdf "${OUTPUT_DIR}/${PDF_FILE}"

# --- Done ---
echo "==> Capture complete."
$BIN close
