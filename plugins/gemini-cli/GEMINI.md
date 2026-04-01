# GEMINI.md

Instructions for Gemini CLI working with testmu-browser-agent and using it for browser automation tasks.

## Project Overview

testmu-browser-agent is a Go CLI and MCP server for AI-native browser automation. It controls Chrome (local or LambdaTest cloud) via the Chrome DevTools Protocol (CDP). Use it whenever you need to navigate websites, fill forms, extract data, take screenshots, or test web applications.

**Two usage modes:**
- **CLI**: Shell commands (`testmu-browser-agent open`, `testmu-browser-agent snapshot`, etc.)
- **MCP**: Structured tool calls via the MCP server (`testmu-browser-agent mcp`)

---

## Build & Test

```bash
make build              # Build to bin/testmu-browser-agent
make test               # Unit tests (no Chrome required)
make test-e2e           # E2E tests (needs Chrome)
make test-lambdatest    # Cloud tests (needs LT_USERNAME + LT_ACCESS_KEY)
make lint               # golangci-lint
make build-all          # Cross-compile for macOS, Linux, Windows
```

---

## Browser Automation — Core Workflow

The standard loop for any browser task: navigate, snapshot, interact, verify.

```bash
# 1. Open the target page
testmu-browser-agent open https://app.example.com

# 2. Snapshot the accessibility tree to discover interactive elements
testmu-browser-agent snapshot
# Output: [ref=e1] textbox "Email" (editable)
#         [ref=e2] textbox "Password" (editable)
#         [ref=e3] button "Sign in"

# 3. Act on elements by their @ref ID
testmu-browser-agent fill @e1 "user@example.com"
testmu-browser-agent fill @e2 "hunter2"
testmu-browser-agent click @e3

# 4. Wait for async content
testmu-browser-agent wait --url "/dashboard" --timeout 15000

# 5. Snapshot again to verify state
testmu-browser-agent snapshot

# 6. Capture evidence
testmu-browser-agent screenshot --output result.png
testmu-browser-agent close
```

> Always snapshot before interacting. @ref IDs are only valid for the current page load — re-snapshot after any navigation.

---

## @ref IDs — the Core Concept

When you run `testmu-browser-agent snapshot`, the accessibility tree is returned with stable reference IDs:

```
[ref=e1] textbox "Customer name" (editable)
[ref=e2] textbox "Telephone" (editable)
[ref=e3] select "Pizza size"
[ref=e7] button "Submit order"
```

Use these refs to interact:

```bash
testmu-browser-agent fill @e1 "Jane Doe"
testmu-browser-agent fill @e2 "555-0100"
testmu-browser-agent select @e3 "medium"
testmu-browser-agent click @e7
```

Refs are more stable than CSS selectors. Prefer `@ref` IDs when available.

---

## Key CLI Commands

```bash
# Navigation
testmu-browser-agent open <url>               # Open URL, launch browser if needed
testmu-browser-agent navigate <url>           # Navigate within existing session
testmu-browser-agent back / forward / reload  # History controls
testmu-browser-agent close                    # Close browser

# Page reading
testmu-browser-agent snapshot                 # Accessibility tree with @ref IDs
testmu-browser-agent snapshot --output json   # Machine-readable JSON
testmu-browser-agent get title                # Page title
testmu-browser-agent get url                  # Current URL
testmu-browser-agent get text <selector>      # Text content of element
testmu-browser-agent eval '<js>'              # Execute JavaScript

# Interaction
testmu-browser-agent click @e1               # Click by ref
testmu-browser-agent fill @e1 "value"        # Fill input by ref
testmu-browser-agent select @e1 "option"     # Select dropdown option
testmu-browser-agent check @e1               # Check checkbox
testmu-browser-agent press Enter             # Keyboard input
testmu-browser-agent scroll down 500         # Scroll page
testmu-browser-agent hover @e1              # Hover element

# Waiting
testmu-browser-agent wait --selector ".results"      # Wait for element
testmu-browser-agent wait --url "/confirmation"      # Wait for URL change
testmu-browser-agent wait --text "Order confirmed"   # Wait for text
testmu-browser-agent wait --timeout 3000             # Fixed pause (ms)

# Capture
testmu-browser-agent screenshot --output page.png
testmu-browser-agent screenshot --output page.jpg --format jpeg --quality 85
testmu-browser-agent pdf report.pdf

# Session state
testmu-browser-agent state save --name my-session    # Save cookies + localStorage
testmu-browser-agent state load --name my-session    # Restore saved session
testmu-browser-agent state list                      # List saved sessions

# Network interception
testmu-browser-agent route "**/*.png" --abort        # Block images
testmu-browser-agent route "/api/data" --body '{"mock":true}' --status 200
testmu-browser-agent unroute                         # Remove all rules

# Auth vault
testmu-browser-agent auth save --name mysite --url https://example.com/login --username user --password pass
testmu-browser-agent auth login --name mysite        # Auto-login

# Multi-tab
testmu-browser-agent tabs                            # List open tabs
testmu-browser-agent tab new                         # Open new tab
testmu-browser-agent tab 0                           # Switch to tab 0
testmu-browser-agent frame '#iframe-id'              # Switch into iframe

# Diagnostics
testmu-browser-agent errors                          # JavaScript errors
testmu-browser-agent console                         # Console messages

# Server modes
testmu-browser-agent mcp                             # Start MCP server (stdio JSON-RPC)
testmu-browser-agent serve                           # Start HTTP daemon
```

---

## MCP Tools Reference

When running as an MCP server (`testmu-browser-agent mcp`), 10 grouped tools are available:

| Tool | Actions | Purpose |
|------|---------|---------|
| `browser_navigate` | open, navigate, back, forward, reload, close | URL navigation |
| `browser_interact` | click, fill, type, press, select, scroll, hover, check, uncheck, drag, upload | Element interaction |
| `browser_query` | snapshot, get, find, eval, inspect | Read page state |
| `browser_media` | screenshot, pdf, record | Capture output |
| `browser_state` | state_save, state_load, cookies_get, cookies_set, storage_get, storage_set | Session persistence |
| `browser_tabs` | list, new, close, switch, frame | Tab management |
| `browser_wait` | (condition params) | Wait for conditions |
| `browser_config` | set, connect | Viewport, user-agent, CDP connection |
| `browser_network` | console, errors, dialog, highlight, stream | Console and dialog handling |
| `browser_devtools` | trace_start, trace_stop, profiler_start, profiler_stop, batch | DevTools and batch execution |

Example MCP tool calls:

```json
{ "tool": "browser_navigate", "action": "open", "url": "https://example.com" }
{ "tool": "browser_query", "action": "snapshot", "interactive": true }
{ "tool": "browser_interact", "action": "fill", "selector": "e1", "text": "hello" }
{ "tool": "browser_media", "action": "screenshot", "output": "page.png" }
{ "tool": "browser_wait", "selector": ".results", "timeout": 15 }
{ "tool": "browser_state", "action": "state_save", "name": "my-session" }
```

---

## Common Patterns

### Login and save session

```bash
testmu-browser-agent open https://app.example.com/login
testmu-browser-agent snapshot
testmu-browser-agent fill @e1 "user@example.com"
testmu-browser-agent fill @e2 "password"
testmu-browser-agent click @e3
testmu-browser-agent wait --url "/dashboard" --timeout 15000
testmu-browser-agent state save --name app-session
testmu-browser-agent close
# Next run: load state instead of logging in
testmu-browser-agent state load --name app-session
```

### Extract data with JavaScript

```bash
testmu-browser-agent open https://books.toscrape.com
testmu-browser-agent eval 'JSON.stringify(
  Array.from(document.querySelectorAll("article.product_pod")).map(el => ({
    title: el.querySelector("h3 a").getAttribute("title"),
    price: el.querySelector(".price_color").textContent.trim()
  }))
)'
```

### Mock an API for testing

```bash
testmu-browser-agent route "/api/user" --body '{"id":1,"name":"Test User"}' --status 200
testmu-browser-agent open https://app.example.com
testmu-browser-agent snapshot
```

---

## Best Practices

- **Always snapshot before acting.** Refs are only valid for the current page load.
- **Use condition-based waits.** Prefer `--selector`, `--url`, `--text` over fixed `--timeout` sleeps.
- **Use `--output json` in scripts.** Machine-readable output avoids parsing fragility.
- **Save state after login.** Avoid re-authenticating on every run with `state save/load`.
- **Use `--headless` in CI.** Pass `--headless` for automated pipelines.
- **Check console errors after complex interactions.** Run `testmu-browser-agent errors` to catch JS exceptions.
- **Prefer @ref IDs over CSS selectors.** They are more stable than hand-crafted selectors.
- **Use `--storage-key` for sensitive sessions.** Encrypt state files that contain auth tokens.

---

## Project Structure

| Directory | Responsibility |
|-----------|---------------|
| `cmd/testmu-browser-agent/` | CLI entry point (cobra) |
| `internal/cli/` | 75+ CLI commands and output formatting |
| `internal/mcp/` | MCP JSON-RPC server (10 grouped tools) |
| `internal/action/` | Browser action executor |
| `internal/snapshot/` | Accessibility tree snapshots with @ref IDs |
| `internal/provider/` | Browser providers (local, LambdaTest, Appium) |
| `internal/daemon/` | HTTP server, Unix socket, middleware |
| `internal/state/` | Session persistence (AES-256-GCM) |
| `internal/network/` | Network monitor + domain filter |
| `internal/policy/` | Action allow/deny engine |
| `internal/auth/` | Encrypted credential vault |
| `internal/intercept/` | Network interception via CDP Fetch |
| `internal/browser/` | Chrome for Testing auto-install |

## Code Conventions

- Go 1.23+, standard library preferred
- CLI commands registered in `internal/cli/commands.go`
- MCP tools defined in `internal/mcp/tools.go`
- No emojis in code or output
- Table-driven tests
- Flags use kebab-case in help text

## Documentation Updates

When adding or changing user-facing features, update:

1. `internal/cli/commands.go` — CLI command definition
2. `internal/mcp/tools.go` — MCP tool definitions (if applicable)
3. `README.md` — feature sections and examples
4. `skills/testmu-browser-agent/SKILL.md` — AI agent skill guide
5. `docs/guides/commands.md` — command reference
