#!/bin/sh
set -e

# login-and-extract.sh
# Multi-step example: open a site, log in, extract page text,
# save session state, take a screenshot, and close.

SITE="https://the-internet.herokuapp.com/login"
SCREENSHOT="login-result.png"

echo "==> Opening site"
testmu-browser-agent --output json \
  open "$SITE"

echo "==> Taking initial snapshot"
testmu-browser-agent --output compact \
  snapshot

echo "==> Filling username"
testmu-browser-agent --output json \
  fill "#username" "tomsmith"

echo "==> Filling password"
testmu-browser-agent --output json \
  fill "#password" "SuperSecretPassword!"

echo "==> Clicking submit"
testmu-browser-agent --output json \
  click "button[type=submit]"

echo "==> Waiting for redirect to /secure"
testmu-browser-agent --output json \
  wait --url "/secure"

echo "==> Extracting page text"
testmu-browser-agent snapshot

echo "==> Saving session state"
testmu-browser-agent --output json \
  state save --name "login-session"
echo "    State saved as login-session"

echo "==> Taking screenshot"
testmu-browser-agent screenshot --output "$SCREENSHOT"
echo "    Screenshot saved to $SCREENSHOT"

echo "==> Closing browser"
testmu-browser-agent --output json \
  close

echo "==> Done."
