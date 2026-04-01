# Session Management

Deep dive on browser state persistence: save/load, AES-256-GCM encryption, cookies, localStorage, and patterns for authenticated sessions.

## Table of Contents

- [Overview](#overview)
- [State Save & Load](#state-save--load)
- [Encryption with --storage-key](#encryption-with---storage-key)
- [Cookies](#cookies)
- [localStorage & sessionStorage](#localstorage--sessionStorage)
- [Authentication Patterns](#authentication-patterns)
- [State File Location](#state-file-location)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

`testmu-browser-agent` can persist complete browser state across sessions. State includes:

- **Cookies** — authentication tokens, session identifiers, CSRF tokens
- **localStorage** — user preferences, cached data, auth tokens stored by SPAs
- **sessionStorage** — short-lived tab-scoped storage
- **IndexedDB** — structured client-side database (large apps)

The typical pattern: login once with `state save`, then subsequent runs use `state load` to skip authentication entirely.

---

## State Save & Load

### Saving state after login

```sh
# Complete authentication flow
testmu-browser-agent open https://app.example.com/login
testmu-browser-agent fill '#email' "user@example.com"
testmu-browser-agent fill '#password' "s3cr3t"
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent wait --url "/dashboard" --timeout 20

# Verify we're logged in
testmu-browser-agent snapshot
# → Confirm dashboard content visible

# Save the full authenticated state
testmu-browser-agent state save --name app-session
# → State saved: app-session (~/.testmu/sessions/app-session.json)

testmu-browser-agent close
```

### Restoring state in subsequent runs

```sh
# Open any page on the same domain first (required for cookie injection)
testmu-browser-agent open https://app.example.com

# Load previously saved state
testmu-browser-agent state load --name app-session

# Navigate directly to protected route — no redirect to login expected
testmu-browser-agent navigate https://app.example.com/dashboard
testmu-browser-agent wait --url "/dashboard" --timeout 10
testmu-browser-agent snapshot
# → Secure dashboard content visible without re-authenticating
```

### Naming conventions

Use descriptive names that include the environment and purpose:

```sh
testmu-browser-agent state save --name "staging-admin"
testmu-browser-agent state save --name "prod-readonly-user"
testmu-browser-agent state save --name "github-org-member"
```

---

## Encryption with --storage-key

State files may contain sensitive credentials (auth cookies, API tokens). Use `--storage-key` to encrypt them with AES-256-GCM.

### Encrypting state

```sh
# Set a key in your environment (32+ char random string)
export SESSION_KEY="$(openssl rand -hex 32)"

# Save with encryption
testmu-browser-agent state save --name secure-session --storage-key "$SESSION_KEY"
# → State saved (encrypted): secure-session

# Load with the same key
testmu-browser-agent state load --name secure-session --storage-key "$SESSION_KEY"
```

### Key management patterns

**Environment variable (recommended for CI):**
```sh
export TESTMU_SESSION_KEY="your-key-here"
testmu-browser-agent state save --name ci-session --storage-key "$TESTMU_SESSION_KEY"
```

**From a secrets manager:**
```sh
SESSION_KEY="$(aws secretsmanager get-secret-value --secret-id browser-agent-key --query SecretString --output text)"
testmu-browser-agent state load --name prod-session --storage-key "$SESSION_KEY"
```

**Important:** The exact same key must be used for both `save` and `load`. If the key is lost, the state file cannot be decrypted.

---

## Cookies

### Reading cookies

```sh
# All cookies for the current session
testmu-browser-agent cookies get
# → [{"name":"session_id","value":"abc123","domain":"app.example.com",...}]

# Cookies for a specific domain
testmu-browser-agent cookies get --domain app.example.com
```

### Setting cookies manually

Useful for injecting authentication tokens without going through the login UI:

```sh
testmu-browser-agent open https://app.example.com

# Inject a session cookie
testmu-browser-agent cookies set '{
  "name": "session_id",
  "value": "abc123xyz",
  "domain": "app.example.com",
  "path": "/",
  "httpOnly": true,
  "secure": true
}'

testmu-browser-agent reload
testmu-browser-agent navigate https://app.example.com/dashboard
```

### Clearing cookies

```sh
testmu-browser-agent cookies clear                           # All cookies
testmu-browser-agent cookies clear --domain app.example.com # Domain-specific
```

---

## localStorage & sessionStorage

### Reading storage

```sh
# All localStorage keys and values
testmu-browser-agent storage get
# → {"theme":"dark","user_id":"42","token":"eyJ..."}

# A specific key
testmu-browser-agent storage get "auth_token"
# → "eyJhbGciOiJIUzI1NiJ9..."

# sessionStorage
testmu-browser-agent storage get --session
testmu-browser-agent storage get "tab_state" --session
```

### Writing storage

Useful for setting feature flags, bypassing onboarding, or injecting tokens:

```sh
# Set a localStorage value
testmu-browser-agent storage set "feature_flags" '{"newUI":true,"betaFeature":false}'

# Set sessionStorage
testmu-browser-agent storage set "wizard_step" "3" --session

# Reload page to apply
testmu-browser-agent reload
```

### Removing storage entries

```sh
testmu-browser-agent storage remove "old_token"
testmu-browser-agent storage clear           # Clear all localStorage
testmu-browser-agent storage clear --session # Clear all sessionStorage
```

---

## Authentication Patterns

### Pattern 1: Full login flow with state persistence

The standard pattern for most web apps:

```sh
# --- Run once (setup) ---
testmu-browser-agent open "$APP_URL/login"
testmu-browser-agent fill '[name="email"]' "$USER_EMAIL"
testmu-browser-agent fill '[name="password"]' "$USER_PASSWORD"
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent wait --url "/dashboard" --timeout 30
testmu-browser-agent state save --name "$SESSION_NAME" --storage-key "$SESSION_KEY"
testmu-browser-agent close

# --- Subsequent runs ---
testmu-browser-agent open "$APP_URL"
testmu-browser-agent state load --name "$SESSION_NAME" --storage-key "$SESSION_KEY"
testmu-browser-agent navigate "$APP_URL/dashboard"
testmu-browser-agent wait --selector ".dashboard-content" --timeout 10
```

### Pattern 2: Token injection (API-issued tokens)

When you have a token from an API call (no UI login needed):

```sh
TOKEN="$(curl -s -X POST https://api.example.com/auth \
  -d '{"email":"user@example.com","password":"s3cr3t"}' \
  | jq -r '.access_token')"

testmu-browser-agent open https://app.example.com
testmu-browser-agent storage set "auth_token" "$TOKEN"
testmu-browser-agent reload
testmu-browser-agent wait --selector ".user-menu" --timeout 10
```

### Pattern 3: OAuth / SSO flows

For OAuth flows that redirect through third-party providers:

```sh
testmu-browser-agent open https://app.example.com
testmu-browser-agent click '[data-provider="google"]'
testmu-browser-agent wait --url "accounts.google.com" --timeout 15

# Complete OAuth on provider page
testmu-browser-agent fill '[type="email"]' "user@gmail.com"
testmu-browser-agent click '#identifierNext'
testmu-browser-agent wait --selector '[type="password"]' --timeout 10
testmu-browser-agent fill '[type="password"]' "$GOOGLE_PASSWORD"
testmu-browser-agent click '#passwordNext'

# Wait for redirect back to app
testmu-browser-agent wait --url "app.example.com/dashboard" --timeout 30
testmu-browser-agent state save --name "app-oauth-session"
```

### Pattern 4: Session validation before use

Always verify a loaded session is still valid:

```sh
testmu-browser-agent open https://app.example.com
testmu-browser-agent state load --name "app-session"
testmu-browser-agent navigate https://app.example.com/dashboard
testmu-browser-agent wait --timeout 5

# Check if we ended up on the dashboard or were redirected to login
URL="$(testmu-browser-agent get url)"
if echo "$URL" | grep -q "/login"; then
  echo "Session expired — re-authenticating"
  # ... run fresh login flow
else
  echo "Session valid — proceeding"
fi
```

---

## State File Location

By default, state files are stored at:

```
~/.testmu/sessions/<name>.json        # Unencrypted
~/.testmu/sessions/<name>.enc.json    # Encrypted
```

State files contain:
```json
{
  "cookies": [...],
  "localStorage": {"key": "value"},
  "sessionStorage": {"key": "value"},
  "url": "https://app.example.com/dashboard",
  "savedAt": "2025-01-01T12:00:00Z"
}
```

---

## Best Practices

- **Always encrypt production sessions.** Use `--storage-key` for any state containing real credentials.
- **Store encryption keys in environment variables or secrets managers**, never hardcode them.
- **Use descriptive names** that include environment and role: `prod-admin`, `staging-viewer`.
- **Validate sessions before use** — sessions expire. Check the URL after loading to confirm you landed on the expected page.
- **Rotate saved states periodically** — authentication tokens expire. Re-run the login flow when state becomes stale.
- **One state file per role.** Don't share a single state file across different user roles in tests — create separate states for each.
- **Include state save in CI setup jobs** — generate the state as a fixture and load it in each test rather than logging in per test.

---

## Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| `state load` navigates to login page | Session expired or cookies rejected | Re-run login flow and save fresh state |
| `state load` fails: decryption error | Wrong `--storage-key` | Verify the exact key used during `state save` |
| `state load` fails: file not found | Wrong name or state never saved | Check `~/.testmu/sessions/` for available files |
| Cookies not taking effect | State loaded before page open | Always `open` a page first, then `state load` |
| Token injection not working | Page reads from cookies, not localStorage | Use `cookies set` instead of `storage set` |
| SPA not recognizing injected auth | App checks auth on init, not on storage change | Follow injection with `reload` |
| State saves but nothing persists | Page uses httpOnly cookies only | Use `cookies set` with `httpOnly: true` |
