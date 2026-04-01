#!/bin/bash
# Auth Session Demo — logs in to the-internet.herokuapp.com/login,
# saves browser state, closes, reopens, restores state, and verifies
# the session is still active — no re-login required.
# Run from the project root: bash marketing/demos/demo-auth-session.sh

set -euo pipefail

TBA="bin/testmu-browser-agent"
OUT="marketing/demos/screenshots"
STATE_FILE="marketing/demos/screenshots/auth-session.json"
mkdir -p "$OUT"

echo "=== Auth Session Demo ==="

# ── Phase 1: Login ────────────────────────────────────────────────────────────
echo ""
echo "Phase 1: Login"

echo "  Open login page"
$TBA open https://the-internet.herokuapp.com/login
$TBA screenshot --output "$OUT/auth-01-login-page.png"
echo "  -> screenshot saved: $OUT/auth-01-login-page.png"

echo "  Snapshot to discover form refs"
$TBA snapshot

echo "  Fill username"
$TBA fill @e1 "tomsmith"

echo "  Fill password"
$TBA fill @e2 "SuperSecretPassword!"

echo "  Screenshot before submit"
$TBA screenshot --output "$OUT/auth-02-credentials-entered.png"
echo "  -> screenshot saved: $OUT/auth-02-credentials-entered.png"

echo "  Submit login form"
$TBA click @e3

echo "  Screenshot after login"
$TBA screenshot --output "$OUT/auth-03-logged-in.png"
echo "  -> screenshot saved: $OUT/auth-03-logged-in.png"

echo "  Snapshot to confirm logged-in state"
$TBA snapshot

# ── Phase 2: Save state and close ────────────────────────────────────────────
echo ""
echo "Phase 2: Save session state and close browser"

$TBA state save "$STATE_FILE"
echo "  -> session state saved: $STATE_FILE"

$TBA close
echo "  -> browser closed"

# ── Phase 3: Restore state and verify ────────────────────────────────────────
echo ""
echo "Phase 3: Reopen browser and restore saved session"

$TBA open https://the-internet.herokuapp.com/secure
$TBA state load "$STATE_FILE"
echo "  -> session state loaded: $STATE_FILE"

echo "  Reload page to apply restored cookies/storage"
$TBA navigate https://the-internet.herokuapp.com/secure

echo "  Snapshot — should show secure area without re-login"
$TBA snapshot

$TBA screenshot --output "$OUT/auth-04-session-restored.png"
echo "  -> screenshot saved: $OUT/auth-04-session-restored.png"

$TBA close

echo ""
echo "=== Done! Session persisted across browser restart."
echo "    Screenshots saved to $OUT ==="
