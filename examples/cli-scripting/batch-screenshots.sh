#!/bin/sh
set -e

# batch-screenshots.sh
# Screenshot each URL from a file (or stdin) into a timestamped output directory.
#
# Usage:
#   ./batch-screenshots.sh urls.txt
#   cat urls.txt | ./batch-screenshots.sh
#   echo "https://example.com" | ./batch-screenshots.sh

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="screenshots_${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

echo "==> Output directory: $OUTPUT_DIR"

# Read URLs from file argument or stdin
if [ -n "$1" ]; then
  INPUT="$1"
  if [ ! -f "$INPUT" ]; then
    echo "ERROR: File not found: $INPUT" >&2
    exit 1
  fi
  exec < "$INPUT"
fi

INDEX=0
while IFS= read -r URL; do
  # Skip blank lines and comments
  case "$URL" in
    ""|\#*) continue ;;
  esac

  INDEX=$((INDEX + 1))
  # Derive a safe filename from the URL
  SAFE_NAME=$(printf '%s' "$URL" | sed 's|https\?://||' | tr '/:?&=' '_')
  OUTFILE="${OUTPUT_DIR}/${INDEX}_${SAFE_NAME}.png"

  echo "==> [$INDEX] $URL"
  testmu-browser-agent --output compact \
    open "$URL"

  testmu-browser-agent screenshot --output "$OUTFILE"

  testmu-browser-agent --output compact \
    close

  echo "    Saved: $OUTFILE"
done

echo "==> Batch complete. $INDEX screenshot(s) saved to $OUTPUT_DIR/"
