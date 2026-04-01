#!/bin/bash
# authenticated-session.sh
#
# Description: Login to a website once, save browser state, and restore it in
#              subsequent runs to skip re-authentication.
#
# Usage:
#   Phase 1 (first run):  bash authenticated-session.sh
#   Phase 2 (later runs): PHASE=2 bash authenticated-session.sh
#
# Environment variables:
#   TARGET_URL    Base URL of the target site (default: https://the-internet.herokuapp.com)
#   USERNAME      Login username (default: tomsmith)
#   PASSWORD      Login password (default: SuperSecretPassword!)
#   STATE_NAME    Name for saved session state (default: herokuapp-session)
#   SESSION_KEY   AES-256-GCM encryption key for state (optional)
#   PHASE         Set to 2 to run the restore phase instead of login (default: 1)

set -euo pipefail

BIN="testmu-browser-agent"
TARGET_URL="${1:-https://the-internet.herokuapp.com}"
USERNAME="${USERNAME:-tomsmith}"
PASSWORD="${PASSWORD:-SuperSecretPassword!}"
STATE_NAME="${STATE_NAME:-herokuapp-session}"
PHASE="${PHASE:-1}"

# Build optional --storage-key flag if SESSION_KEY is set
STORAGE_KEY_FLAG=""
if [[ -n "${SESSION_KEY:-}" ]]; then
  STORAGE_KEY_FLAG="--storage-key ${SESSION_KEY}"
fi

# =============================================================================
# PHASE 1 — Login and persist session state
# Run this block the first time to capture authenticated cookies and storage.
# =============================================================================

if [[ "$PHASE" == "1" ]]; then
  echo "==> Phase 1: Logging in to ${TARGET_URL}/login ..."

  $BIN open "${TARGET_URL}/login"

  # Wait for the login form to be ready
  $BIN wait --selector '#username' --timeout 10

  # Fill credentials
  $BIN fill '#username' "$USERNAME"
  $BIN fill '#password' "$PASSWORD"

  # Submit the form
  $BIN click '[type="submit"]'

  # Wait for the redirect to the secure area
  $BIN wait --url "/secure" --timeout 15

  # Snapshot the secured page to confirm login succeeded
  $BIN snapshot

  # Save full browser state (cookies + localStorage + sessionStorage)
  # shellcheck disable=SC2086
  $BIN state save --name "$STATE_NAME" $STORAGE_KEY_FLAG

  echo "==> Session saved as '${STATE_NAME}'. Run with PHASE=2 to restore."

  $BIN close

# =============================================================================
# PHASE 2 — Restore session and access protected page directly
# =============================================================================

elif [[ "$PHASE" == "2" ]]; then
  echo "==> Phase 2: Restoring saved session '${STATE_NAME}' ..."

  $BIN open "$TARGET_URL"

  # Load previously saved state (restores cookies so the server sees us as logged in)
  # shellcheck disable=SC2086
  $BIN state load --name "$STATE_NAME" $STORAGE_KEY_FLAG

  # Navigate directly to the protected area (no login redirect expected)
  $BIN navigate "${TARGET_URL}/secure"

  # Verify access with a snapshot — should show the secure area content
  $BIN snapshot

  $BIN close

else
  echo "ERROR: Unknown PHASE '${PHASE}'. Set PHASE=1 or PHASE=2." >&2
  exit 1
fi
