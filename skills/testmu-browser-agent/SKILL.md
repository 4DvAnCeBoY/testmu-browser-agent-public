---
name: testmu-browser-agent-public
description: AI-native browser automation for Chrome. Use when you need to navigate websites, fill forms, take screenshots, extract data, or test web applications. Supports local Chrome and LambdaTest cloud browsers via CLI or MCP server.
---

# testmu-browser-agent-public — AI Agent Skill Guide

AI-native browser automation for Chrome. Drives a real browser (local or LambdaTest cloud) through a CLI or MCP server. The core loop is: open a page → snapshot the accessibility tree → act on element refs → verify. Supports state persistence so authenticated sessions survive across runs.

---

## Quick Start

Five commands to get started immediately:

```sh
# 1. Open a URL and take a screenshot
testmu-browser-agent open https://example.com
testmu-browser-agent screenshot --output example.png
# → Saved screenshot to example.png

# 2. Snapshot the page (get @ref IDs for interactive elements)
testmu-browser-agent open https://httpbin.org/forms/post
testmu-browser-agent snapshot
# → [ref=e1] textbox "Customer name"
# → [ref=e2] textbox "Telephone"
# → [ref=e7] button "Submit order"

# 3. Fill a form using ref IDs
testmu-browser-agent fill @e1 "Jane Doe"
testmu-browser-agent fill @e2 "555-0100"
testmu-browser-agent click @e7
# → Clicked [ref=e7]

# 4. Extract structured data with JS
testmu-browser-agent eval 'JSON.stringify(document.title)'
# → "Pizza order form"

# 5. Save browser state after login
testmu-browser-agent state save --name my-session
# → State saved: my-session
testmu-browser-agent close
```

---

## Core Workflow

The standard AI browsing loop — navigate, snapshot, interact, verify:

```sh
# Step 1: Open the target page
testmu-browser-agent open https://app.example.com

# Step 2: Snapshot to read interactive elements and their refs
testmu-browser-agent snapshot
# → Returns accessibility tree; note the ref IDs (e.g. @e12, @e23)

# Step 3: Act on elements by ref
testmu-browser-agent fill @e12 "search query"
testmu-browser-agent click @e23

# Step 4: Wait for async content before reading results
testmu-browser-agent wait --selector ".results" --timeout 15000

# Step 5: Snapshot again to verify the new state
testmu-browser-agent snapshot

# Step 6: Capture evidence
testmu-browser-agent screenshot --output result.png
testmu-browser-agent close
```

> Always snapshot before interacting. Refs are stable only within the same page load — re-snapshot after navigation.

---

## Common Tasks

### Web Research & Data Extraction

```sh
testmu-browser-agent open https://books.toscrape.com
testmu-browser-agent snapshot

# Extract structured data as JSON
testmu-browser-agent eval 'JSON.stringify(
  Array.from(document.querySelectorAll("article.product_pod")).map(el => ({
    title: el.querySelector("h3 a").getAttribute("title"),
    price: el.querySelector(".price_color").textContent.trim()
  }))
)'
# → [{"title":"A Light in the Attic","price":"£51.77"},...]

# Get plain text from a specific section
testmu-browser-agent get text .page_inner

# Get page title and current URL
testmu-browser-agent get title
testmu-browser-agent get url
```

### Form Filling

```sh
testmu-browser-agent open https://httpbin.org/forms/post
testmu-browser-agent snapshot
# → discover refs

testmu-browser-agent fill '[name="custname"]' "Jane Doe"
testmu-browser-agent fill '[name="custemail"]' "jane@example.com"
testmu-browser-agent select '[name="size"]' "medium"
testmu-browser-agent check '[name="topping"][value="bacon"]'
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent wait --text "Customer name" --timeout 15000
testmu-browser-agent snapshot
```

### Visual Testing & Screenshots

```sh
# Full-page screenshot
testmu-browser-agent screenshot --output page.png --format png

# Generate PDF
testmu-browser-agent pdf report.pdf

# Screenshot with JPEG compression
testmu-browser-agent screenshot --output page.jpg --format jpeg --quality 85

# Highlight an element before screenshotting
testmu-browser-agent highlight @e12
testmu-browser-agent screenshot --output highlighted.png
```

### Authenticated Sessions

```sh
# Login once and save state
testmu-browser-agent open https://the-internet.herokuapp.com/login
testmu-browser-agent fill '#username' "tomsmith"
testmu-browser-agent fill '#password' "SuperSecretPassword!"
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent wait --url "/secure" --timeout 15000
testmu-browser-agent state save --name herokuapp-session
testmu-browser-agent close

# Subsequent runs: skip login
testmu-browser-agent open https://the-internet.herokuapp.com
testmu-browser-agent state load --name herokuapp-session
testmu-browser-agent navigate https://the-internet.herokuapp.com/secure
testmu-browser-agent snapshot
# → Shows secure area content without re-authenticating
```

### Waiting for Dynamic Content

```sh
# Wait for element to appear (SPA routing, lazy load)
testmu-browser-agent wait --selector ".results-table" --timeout 15000

# Wait for URL change (after form submit or redirect)
testmu-browser-agent wait --url "/confirmation" --timeout 10000

# Wait for visible text (success message)
testmu-browser-agent wait --text "Order confirmed" --timeout 20000

# Fixed pause in milliseconds (avoid when possible; prefer condition-based waits)
testmu-browser-agent wait --timeout 3000
```

### Network Interception

```sh
# Block all image requests
testmu-browser-agent route "**/*.png" --abort
testmu-browser-agent route "**/*.jpg" --abort

# Mock an API response
testmu-browser-agent route "/api/data" --body '{"mock":true}' --status 200

# Add a response header
testmu-browser-agent route "/api/*" --header "X-Test:true"

# Remove a specific rule
testmu-browser-agent unroute "/api/data"

# Remove all interception rules
testmu-browser-agent unroute
```

### Auth Vault

```sh
# Save credentials to the encrypted vault
testmu-browser-agent auth save --name mysite --url https://example.com/login --username user --password pass

# Auto-login using stored credentials
testmu-browser-agent auth login --name mysite

# List stored credentials (passwords masked)
testmu-browser-agent auth list

# Show or delete a credential
testmu-browser-agent auth show --name mysite
testmu-browser-agent auth delete --name mysite
```

### Device Emulation

```sh
# Override geolocation (latitude, longitude)
testmu-browser-agent geolocation 37.7749 -122.4194

# Override timezone and locale
testmu-browser-agent timezone America/New_York
testmu-browser-agent locale fr-FR

# Grant permissions
testmu-browser-agent permissions geolocation notifications

# Toggle offline mode
testmu-browser-agent offline
testmu-browser-agent offline --disable

# Emulate a device
testmu-browser-agent device-list
testmu-browser-agent device-emulate "iPhone 15"
```

### Downloads

```sh
# Enable download tracking and wait for next download
testmu-browser-agent download

# Set download directory
testmu-browser-agent download --dir /tmp/downloads

# Wait for a download to complete
testmu-browser-agent wait --download
```

### Diff Snapshots

```sh
# Diff accessibility tree against last snapshot
testmu-browser-agent diff snapshot

# Navigate to a URL and diff before/after
testmu-browser-agent diff url https://example.com

# Diff current screenshot against last stored
testmu-browser-agent diff screenshot
```

### Multi-Tab Workflows

```sh
# List open tabs
testmu-browser-agent tabs
# → [0] https://example.com (active)

# Open a new tab and switch to it
testmu-browser-agent tab new
testmu-browser-agent open https://other-site.com

# Switch back to tab 0
testmu-browser-agent tab 0

# Work inside an iframe
testmu-browser-agent frame '#iframe-selector'
testmu-browser-agent snapshot
```

---

## MCP Server Usage

Start the MCP server and add it to Claude Code's `settings.json`:

```sh
testmu-browser-agent mcp
```

**settings.json** (Claude Code MCP configuration):

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

Once configured, Claude Code can call the 10 MCP tools directly. Example tool calls:

```json
// Navigate to a URL
{ "tool": "browser_navigate", "action": "open", "url": "https://example.com" }

// Snapshot interactive elements
{ "tool": "browser_query", "action": "snapshot", "interactive": true }

// Fill a form field
{ "tool": "browser_interact", "action": "fill", "selector": "@e12", "text": "hello" }

// Take a screenshot
{ "tool": "browser_media", "action": "screenshot", "output": "page.png" }

// Save session state
{ "tool": "browser_state", "action": "state_save", "name": "my-session" }
```

See [references/mcp-tools.md](./references/mcp-tools.md) for complete schemas and response formats.

---

## Best Practices

- **Always snapshot before acting.** Refs like `@e12` are only valid for the current page load. After any navigation, re-snapshot.
- **Use `--output json` in scripts.** Machine-readable output avoids parsing issues: `testmu-browser-agent snapshot --output json`.
- **Prefer condition-based waits.** Use `--selector`, `--url`, or `--text` over fixed `--timeout` sleeps.
- **Save state after login.** Call `state save` once after authenticating; subsequent runs load it to skip the login flow.
- **Use `--storage-key` for encrypted state.** Sensitive sessions (tokens, cookies) should be stored encrypted: `state save --name session --storage-key $MY_KEY`.
- **Use `--headless` in CI.** Always pass `--headless` when running in automated pipelines.
- **Ref IDs over CSS selectors.** When possible, use `@ref` IDs from snapshot — they are more stable than brittle CSS selectors.
- **Check console errors.** After complex interactions run `testmu-browser-agent errors` to catch JavaScript exceptions.

---

## References

Deep-dive documentation:

| File | Contents |
|---|---|
| [references/commands.md](./references/commands.md) | Complete CLI command reference with all flags and examples |
| [references/snapshot-refs.md](./references/snapshot-refs.md) | Accessibility snapshots, @ref IDs, diffing, token optimization |
| [references/session-management.md](./references/session-management.md) | State save/load, encryption, cookies, localStorage patterns |
| [references/mcp-tools.md](./references/mcp-tools.md) | All 10 MCP tools with JSON schemas and request/response examples |

---

## Templates

Ready-to-run shell scripts in [`templates/`](./templates/):

| Template | Description |
|---|---|
| [`form-automation.sh`](./templates/form-automation.sh) | Fill and submit an HTML form (httpbin.org pizza order demo) |
| [`authenticated-session.sh`](./templates/authenticated-session.sh) | Login once, save state, restore in future runs |
| [`capture-workflow.sh`](./templates/capture-workflow.sh) | Scrape a page: snapshot, screenshot, JS extraction, PDF |
