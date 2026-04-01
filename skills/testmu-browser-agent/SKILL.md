---
name: testmu-browser-agent
description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "automate browser actions", or any task requiring programmatic web interaction.
allowed-tools: Bash(testmu-browser-agent:*)
---

# testmu-browser-agent — AI Agent Skill Guide

AI-native browser automation for Chrome for Testing. Drives a real browser (local or LambdaTest cloud) through a CLI. The core loop is: open a page → snapshot the accessibility tree → act on element refs → verify. Supports state persistence so authenticated sessions survive across runs.

> **Setup required:** If `testmu-browser-agent` is not installed, run:
> ```sh
> curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
> ```
> This installs the binary, downloads Chrome for Testing, registers the MCP server, and installs this skill. Restart Claude Code after running.

---

## Install

If the `testmu-browser-agent` binary is not found on PATH, run the full setup (installs binary + Chrome for Testing + MCP config):

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
```

Or install the binary only:

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

After install, run `testmu-browser-agent install` to download Chrome for Testing (required if system Chrome is not available).

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

## Command Chaining

Chain commands with `&&` for compact scripting:

```sh
# Open, snapshot, fill, submit, wait, screenshot in one line
testmu-browser-agent open https://httpbin.org/forms/post && \
  testmu-browser-agent snapshot && \
  testmu-browser-agent fill '[name="custname"]' "Jane Doe" && \
  testmu-browser-agent fill '[name="custemail"]' "jane@example.com" && \
  testmu-browser-agent click '[type="submit"]' && \
  testmu-browser-agent wait --text "Customer name" --timeout 15000 && \
  testmu-browser-agent screenshot --output result.png && \
  testmu-browser-agent close

# Login and save state in one chain
testmu-browser-agent open https://example.com/login && \
  testmu-browser-agent fill '#username' "admin" && \
  testmu-browser-agent fill '#password' "secret" && \
  testmu-browser-agent click '[type="submit"]' && \
  testmu-browser-agent wait --url "/dashboard" && \
  testmu-browser-agent state save --name mysite && \
  testmu-browser-agent close
```

---

## Authentication Handling

### State Save / Load

```sh
# Login once and persist the session
testmu-browser-agent open https://example.com/login
testmu-browser-agent fill '#username' "admin"
testmu-browser-agent fill '#password' "secret"
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent wait --url "/dashboard" --timeout 15000
testmu-browser-agent state save --name mysite
testmu-browser-agent close

# Subsequent runs: restore session, skip login
testmu-browser-agent open https://example.com
testmu-browser-agent state load --name mysite
testmu-browser-agent navigate https://example.com/dashboard
testmu-browser-agent snapshot
```

### Auth Vault (encrypted credentials)

```sh
# Store credentials encrypted at rest
testmu-browser-agent auth save --name mysite --url https://example.com/login \
  --username admin --password secret

# Auto-login using stored credentials
testmu-browser-agent auth login --name mysite

# Manage vault entries
testmu-browser-agent auth list
testmu-browser-agent auth show --name mysite
testmu-browser-agent auth delete --name mysite
```

### Session Persistence with Encryption

```sh
# Save session state with an encryption key
testmu-browser-agent state save --name session --storage-key "$MY_KEY"

# Load it back (requires same key)
testmu-browser-agent state load --name session --storage-key "$MY_KEY"

# List and clean up saved states
testmu-browser-agent state list
testmu-browser-agent state delete --name session
```

---

## Essential Commands

### Navigation

```sh
testmu-browser-agent open <url>           # Open URL in browser
testmu-browser-agent navigate <url>       # Navigate current tab to URL
testmu-browser-agent back                 # Browser back
testmu-browser-agent forward              # Browser forward
testmu-browser-agent reload               # Reload current page
testmu-browser-agent close                # Close browser
```

### Snapshot

```sh
testmu-browser-agent snapshot             # Accessibility tree with @ref IDs
testmu-browser-agent snapshot --output json  # Machine-readable JSON output
```

### Interaction

```sh
testmu-browser-agent click <ref|selector>              # Click element
testmu-browser-agent fill <ref|selector> <text>        # Fill input field
testmu-browser-agent type <ref|selector> <text>        # Type keystroke-by-keystroke
testmu-browser-agent press <key>                       # Press keyboard key (Enter, Tab, Escape)
testmu-browser-agent select <ref|selector> <value>     # Select dropdown option
testmu-browser-agent scroll <ref|selector> <direction> # Scroll element or page
testmu-browser-agent hover <ref|selector>              # Hover over element
testmu-browser-agent check <ref|selector>              # Check a checkbox
testmu-browser-agent uncheck <ref|selector>            # Uncheck a checkbox
testmu-browser-agent drag <source> <target>            # Drag and drop
testmu-browser-agent tap <ref|selector>                # Tap (touch event)
testmu-browser-agent swipe <ref|selector> <direction>  # Swipe gesture
```

### Get Info

```sh
testmu-browser-agent get text <selector>  # Extract text from element
testmu-browser-agent get url              # Current page URL
testmu-browser-agent get title            # Current page title
testmu-browser-agent eval '<js>'          # Evaluate JavaScript expression
```

### Wait

```sh
testmu-browser-agent wait --selector ".el"        # Wait for element to appear
testmu-browser-agent wait --url "/path"           # Wait for URL to match
testmu-browser-agent wait --text "Success"        # Wait for text to appear
testmu-browser-agent wait --timeout 5000          # Fixed pause (ms)
testmu-browser-agent wait --download              # Wait for a file download
```

### Network

```sh
testmu-browser-agent route "**/*.png" --abort                           # Block requests
testmu-browser-agent route "/api/data" --body '{"mock":true}' --status 200  # Mock response
testmu-browser-agent route "/api/*" --header "X-Test:true"              # Add header
testmu-browser-agent unroute "/api/data"                                # Remove rule
testmu-browser-agent unroute                                            # Remove all rules
testmu-browser-agent console                                            # Read console logs
testmu-browser-agent errors                                             # Read JS errors
```

### Capture

```sh
testmu-browser-agent screenshot --output page.png              # PNG screenshot
testmu-browser-agent screenshot --output page.jpg --quality 85 # JPEG screenshot
testmu-browser-agent pdf report.pdf                            # Save page as PDF
testmu-browser-agent record start                              # Start video recording
testmu-browser-agent record stop --output video.webm           # Stop and save recording
```

### State

```sh
testmu-browser-agent state save --name <name>           # Save full browser state
testmu-browser-agent state load --name <name>           # Load saved state
testmu-browser-agent state list                         # List saved states
testmu-browser-agent state delete --name <name>         # Delete saved state
testmu-browser-agent cookies                            # Get all cookies
testmu-browser-agent storage                            # Read localStorage/sessionStorage
testmu-browser-agent clipboard                          # Read clipboard contents
```

### Tabs

```sh
testmu-browser-agent tabs                   # List all open tabs
testmu-browser-agent tab new               # Open new tab
testmu-browser-agent tab <index>           # Switch to tab by index
testmu-browser-agent frame '<selector>'    # Switch to iframe context
testmu-browser-agent window new            # Open new browser window
```

### Device Emulation

```sh
testmu-browser-agent geolocation <lat> <lon>    # Override geolocation
testmu-browser-agent timezone <tz>              # Override timezone (e.g. America/New_York)
testmu-browser-agent locale <locale>            # Override locale (e.g. fr-FR)
testmu-browser-agent device-list               # List supported device profiles
testmu-browser-agent device-emulate "iPhone 15" # Emulate a device
testmu-browser-agent permissions geolocation notifications  # Grant permissions
testmu-browser-agent offline                    # Toggle offline mode
testmu-browser-agent offline --disable          # Disable offline mode
```

### Diff

```sh
testmu-browser-agent diff snapshot        # Diff accessibility tree vs last snapshot
testmu-browser-agent diff screenshot      # Diff screenshot vs last stored
testmu-browser-agent diff url <url>       # Navigate and diff before/after
```

---

## Common Patterns

### Form Submission

```sh
testmu-browser-agent open https://httpbin.org/forms/post
testmu-browser-agent snapshot
# → [ref=e1] textbox "Customer name"
# → [ref=e2] textbox "Telephone"
# → [ref=e7] button "Submit order"
testmu-browser-agent fill @e1 "Jane Doe"
testmu-browser-agent fill @e2 "555-0100"
testmu-browser-agent select '[name="size"]' "medium"
testmu-browser-agent check '[name="topping"][value="bacon"]'
testmu-browser-agent click @e7
testmu-browser-agent wait --text "Customer name" --timeout 15000
testmu-browser-agent snapshot
```

### Auth with Vault

```sh
# Store once
testmu-browser-agent auth save --name github --url https://github.com/login \
  --username myuser --password mypass

# Reuse in every run
testmu-browser-agent auth login --name github
testmu-browser-agent wait --url "/dashboard" --timeout 20000
testmu-browser-agent state save --name github-session
testmu-browser-agent close

# Future runs: just load state
testmu-browser-agent open https://github.com
testmu-browser-agent state load --name github-session
```

### Data Extraction

```sh
testmu-browser-agent open https://books.toscrape.com
testmu-browser-agent eval 'JSON.stringify(
  Array.from(document.querySelectorAll("article.product_pod")).map(el => ({
    title: el.querySelector("h3 a").getAttribute("title"),
    price: el.querySelector(".price_color").textContent.trim()
  }))
)'
# → [{"title":"A Light in the Attic","price":"£51.77"},...]
testmu-browser-agent get text .page_inner
```

### Parallel Sessions

```sh
# Session A — tab 0
testmu-browser-agent open https://app.example.com
testmu-browser-agent state load --name user-a

# Open second tab — session B
testmu-browser-agent tab new
testmu-browser-agent open https://app.example.com
testmu-browser-agent state load --name user-b

# Switch back to tab 0
testmu-browser-agent tab 0
testmu-browser-agent snapshot
```

---

## Ref Lifecycle

- `@ref` IDs (e.g. `@e12`, `@e23`) are assigned fresh on each snapshot.
- They remain valid until the next navigation or page reload.
- After **any** navigation (`navigate`, `click` that triggers redirect, form submit, `back`, `forward`, `reload`), always call `snapshot` again before using refs.
- Stale ref usage will return an error — that is your signal to re-snapshot.

---

## Security

**Domain allowlist** — restrict the agent to specific origins:

```sh
testmu-browser-agent open https://app.example.com --allow-origins "app.example.com,api.example.com"
```

**Action policy** — disallow dangerous actions in automated pipelines:

```sh
testmu-browser-agent open https://app.example.com --deny-actions "download,eval"
```

**Encrypted state** — store sensitive sessions encrypted at rest:

```sh
testmu-browser-agent state save --name prod-session --storage-key "$SESSION_KEY"
testmu-browser-agent state load --name prod-session --storage-key "$SESSION_KEY"
```

**Headless CI** — always use headless mode in automated environments:

```sh
testmu-browser-agent open https://app.example.com --headless
```

---

## References

Deep-dive documentation:

| File | Contents |
|---|---|
| [references/commands.md](./references/commands.md) | Complete CLI command reference with all flags and examples |
| [references/snapshot-refs.md](./references/snapshot-refs.md) | Accessibility snapshots, @ref IDs, diffing, token optimization |
| [references/session-management.md](./references/session-management.md) | State save/load, encryption, cookies, localStorage patterns |
| [references/mcp-tools.md](./references/mcp-tools.md) | All MCP tools with JSON schemas and request/response examples |

---

## Templates

Ready-to-run shell scripts in [`templates/`](./templates/):

| Template | Description |
|---|---|
| [`form-automation.sh`](./templates/form-automation.sh) | Fill and submit an HTML form (httpbin.org pizza order demo) |
| [`authenticated-session.sh`](./templates/authenticated-session.sh) | Login once, save state, restore in future runs |
| [`capture-workflow.sh`](./templates/capture-workflow.sh) | Scrape a page: snapshot, screenshot, JS extraction, PDF |
