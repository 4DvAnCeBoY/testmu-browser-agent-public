#!/bin/sh
set -e

# test-login-flow.sh
# Tests the login flow on the-internet.herokuapp.com using LambdaTest.
# Requires LT_USERNAME and LT_ACCESS_KEY to be set in the environment.

SCREENSHOTS_DIR="screenshots"
mkdir -p "$SCREENSHOTS_DIR"

echo "==> Opening login page"
testmu-browser-agent --provider lambdatest --output json \
  open "https://the-internet.herokuapp.com/login"

echo "==> Filling in username"
testmu-browser-agent --provider lambdatest --output json \
  fill "#username" "tomsmith"

echo "==> Filling in password"
testmu-browser-agent --provider lambdatest --output json \
  fill "#password" "SuperSecretPassword!"

echo "==> Submitting login form"
testmu-browser-agent --provider lambdatest --output json \
  click "button[type=submit]"

echo "==> Waiting for redirect to /secure"
testmu-browser-agent --provider lambdatest --output json \
  wait --url "/secure"

echo "==> Taking snapshot to verify 'Secure Area' text"
SNAPSHOT=$(testmu-browser-agent --provider lambdatest --output json \
  snapshot)

echo "$SNAPSHOT" | grep -q "Secure Area" || {
  echo "ERROR: 'Secure Area' not found in snapshot. Login may have failed."
  testmu-browser-agent --provider lambdatest \
    screenshot --output "$SCREENSHOTS_DIR/login-failure.png"
  exit 1
}

echo "==> Login flow passed. Taking success screenshot."
testmu-browser-agent --provider lambdatest \
  screenshot --output "$SCREENSHOTS_DIR/login-success.png"

echo "==> Test complete."
