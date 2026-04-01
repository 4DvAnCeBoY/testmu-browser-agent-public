# CLI Command Reference

Complete reference for all `testmu-browser-agent` commands, flags, and examples.

## Table of Contents

- [Global Flags](#global-flags)
- [Navigation](#navigation)
- [Interaction](#interaction)
- [Querying](#querying)
- [Media Capture](#media-capture)
- [State Management](#state-management)
- [Waiting & Monitoring](#waiting--monitoring)
- [Tabs & Frames](#tabs--frames)
- [DevTools & Config](#devtools--config)
- [Server Modes](#server-modes)
- [Troubleshooting](#troubleshooting)

---

## Global Flags

These flags apply to every command:

```
--provider string      Browser provider: local (default) or lambdatest
--headless             Run browser in headless mode (required in CI)
--browser-path string  Path to Chrome/Chromium binary (overrides auto-detect)
--port int             Daemon HTTP port (default 9222)
--socket string        Unix socket path for daemon communication
--output string        Output format: text (default), json, compact
--storage-key string   AES-256-GCM key for encrypted state files
--verbose              Enable verbose debug logging
```

**Output formats:**

```sh
# Default human-readable text
testmu-browser-agent snapshot

# JSON for scripts and pipelines
testmu-browser-agent snapshot --output json

# Compact single-line JSON
testmu-browser-agent snapshot --output compact
```

---

## Navigation

### `open <url>`

Open a URL in a new browser page. Starts the browser if not already running.

```sh
testmu-browser-agent open https://example.com
testmu-browser-agent open https://example.com --headless
testmu-browser-agent open https://example.com --provider lambdatest
```

### `navigate <url>` / `goto <url>`

Navigate the current page to a new URL without opening a new tab.

```sh
testmu-browser-agent navigate https://example.com/page2
testmu-browser-agent goto https://example.com/page2   # alias
```

### `back`

Go back in browser history.

```sh
testmu-browser-agent back
```

### `forward`

Go forward in browser history.

```sh
testmu-browser-agent forward
```

### `reload`

Reload the current page. Useful after state changes or cookie injection.

```sh
testmu-browser-agent reload
```

### `close` / `quit` / `exit`

Close the browser and terminate the daemon.

```sh
testmu-browser-agent close
testmu-browser-agent quit   # alias
testmu-browser-agent exit   # alias
```

---

## Interaction

### `click <ref|selector>`

Click an element identified by a snapshot ref ID or CSS selector.

```sh
testmu-browser-agent click @e12
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent click '#login-btn'
testmu-browser-agent click 'button:has-text("Submit")'
```

### `fill <ref|selector> <text>`

Clear and fill a text input or textarea.

```sh
testmu-browser-agent fill @e5 "Jane Doe"
testmu-browser-agent fill '#username' "admin"
testmu-browser-agent fill '[name="email"]' "user@example.com"
```

### `type <text>`

Type text into the currently focused element (does not clear first).

```sh
testmu-browser-agent type " additional text"
```

### `press <key>`

Press a keyboard key. Accepts standard key names.

```sh
testmu-browser-agent press Enter
testmu-browser-agent press Tab
testmu-browser-agent press Escape
testmu-browser-agent press "Control+A"
testmu-browser-agent press "Shift+Tab"
```

### `select <ref|selector> <value>`

Select an option in a `<select>` dropdown by value.

```sh
testmu-browser-agent select '[name="size"]' "medium"
testmu-browser-agent select @e8 "US"
```

### `check <ref|selector>`

Check a checkbox or radio button.

```sh
testmu-browser-agent check '[name="topping"][value="bacon"]'
testmu-browser-agent check @e14
```

### `uncheck <ref|selector>`

Uncheck a checkbox.

```sh
testmu-browser-agent uncheck '[name="newsletter"]'
```

### `hover <ref|selector>`

Hover the mouse over an element (triggers CSS hover states, tooltips).

```sh
testmu-browser-agent hover '#menu-item'
testmu-browser-agent hover @e7
```

### `drag <from> <to>`

Drag an element from one target to another. Both accept ref IDs or selectors.

```sh
testmu-browser-agent drag @e5 @e10
testmu-browser-agent drag '#draggable' '#drop-zone'
```

### `upload <ref|selector> <file...>`

Upload one or more files to a file input.

```sh
testmu-browser-agent upload '[type="file"]' /path/to/file.pdf
testmu-browser-agent upload @e3 file1.png file2.png
```

### `scroll <direction> [amount]`

Scroll the page or an element.

```sh
testmu-browser-agent scroll down
testmu-browser-agent scroll up 500
testmu-browser-agent scroll down 1000
```

### `tap <ref|selector>`

Simulate a touch tap (for mobile viewport testing).

```sh
testmu-browser-agent tap @e12
```

### `swipe <direction> [distance]`

Simulate a touch swipe gesture.

```sh
testmu-browser-agent swipe left 300
testmu-browser-agent swipe up 500
```

---

## Querying

### `snapshot [flags]`

Capture the accessibility tree of the current page. Returns element refs for interaction.

```sh
testmu-browser-agent snapshot
testmu-browser-agent snapshot --full               # Full tree including hidden
testmu-browser-agent snapshot --diff               # Show changes since last snapshot
testmu-browser-agent snapshot --max-length 5000    # Limit output tokens
testmu-browser-agent snapshot --output json        # Machine-readable
```

Example output:
```
[ref=e1] heading "Welcome to Example"
[ref=e2] textbox "Search" (editable)
[ref=e3] button "Search"
[ref=e4] link "About"
[ref=e5] link "Contact"
```

### `get <what> [selector] [attr]`

Get a specific property from the page or an element.

```sh
testmu-browser-agent get title                  # Page title
testmu-browser-agent get url                    # Current URL
testmu-browser-agent get text                   # All visible text
testmu-browser-agent get text .article-body     # Text within selector
testmu-browser-agent get html                   # Full page HTML
testmu-browser-agent get html #content          # Inner HTML of element
testmu-browser-agent get attr '#logo' src       # Attribute value
```

### `find <selector>`

Find elements matching a CSS selector and return their details.

```sh
testmu-browser-agent find 'a[href]'
testmu-browser-agent find '.product-card'
testmu-browser-agent find 'input[type="text"]'
```

### `eval <javascript>`

Execute JavaScript in the page context and return the result.

```sh
testmu-browser-agent eval 'document.title'
testmu-browser-agent eval 'window.location.href'
testmu-browser-agent eval 'document.querySelectorAll("a").length'
testmu-browser-agent eval 'JSON.stringify(window.__APP_STATE__)'
testmu-browser-agent eval 'localStorage.getItem("token")'
```

### `inspect`

Show the full DOM tree and computed styles for the focused element.

```sh
testmu-browser-agent inspect
```

---

## Media Capture

### `screenshot [flags]`

Take a screenshot of the current viewport or full page.

```sh
testmu-browser-agent screenshot                            # stdout PNG
testmu-browser-agent screenshot --output page.png         # Save to file
testmu-browser-agent screenshot --output page.jpg --format jpeg --quality 85
testmu-browser-agent screenshot --ref @e5 --output element.png  # Screenshot a specific element
```

Flags:
```
--ref string       Element ref or selector to capture
--output string    File path to save screenshot
--format string    Image format: png (default) or jpeg
--quality int      JPEG quality 1-100 (default 80)
```

### `pdf [output-path] [flags]`

Generate a PDF of the current page.

```sh
testmu-browser-agent pdf                        # stdout PDF
testmu-browser-agent pdf report.pdf             # Save to file
testmu-browser-agent pdf report.pdf --output report.pdf
```

### `record <start|stop|restart>`

Record a video of browser interactions.

```sh
testmu-browser-agent record start
# ... perform interactions ...
testmu-browser-agent record stop
# → Saves recording.webm
testmu-browser-agent record restart   # Reset and start fresh
```

---

## State Management

### `state <save|load> --name <name> [flags]`

Save or load complete browser state (cookies + localStorage + sessionStorage + IndexedDB).

```sh
testmu-browser-agent state save --name my-session
testmu-browser-agent state load --name my-session

# Encrypted state (AES-256-GCM)
testmu-browser-agent state save --name my-session --storage-key "$ENCRYPT_KEY"
testmu-browser-agent state load --name my-session --storage-key "$ENCRYPT_KEY"
```

State files are stored in `~/.testmu/sessions/` by default.

### `cookies [get|set|clear]`

Read, inject, or clear browser cookies.

```sh
testmu-browser-agent cookies get              # All cookies as JSON
testmu-browser-agent cookies get --domain example.com
testmu-browser-agent cookies set '{"name":"token","value":"abc","domain":"example.com"}'
testmu-browser-agent cookies clear
testmu-browser-agent cookies clear --domain example.com
```

### `storage <get|set|clear|remove> [key] [value] [flags]`

Manage localStorage and sessionStorage.

```sh
testmu-browser-agent storage get                    # All localStorage
testmu-browser-agent storage get "user_prefs"       # Single key
testmu-browser-agent storage set "theme" "dark"     # Set value
testmu-browser-agent storage remove "old_key"       # Remove key
testmu-browser-agent storage clear                  # Clear all

# sessionStorage
testmu-browser-agent storage get --session
testmu-browser-agent storage set "tab_id" "abc" --session
```

### `clipboard <read|write> [text]`

Access the system clipboard.

```sh
testmu-browser-agent clipboard read
testmu-browser-agent clipboard write "text to copy"
```

---

## Waiting & Monitoring

### `wait [flags]`

Wait for a condition before continuing. Always prefer over fixed sleeps.

```sh
# Wait for element to appear in DOM
testmu-browser-agent wait --selector ".results" --timeout 15

# Wait for URL to match pattern (substring or regex)
testmu-browser-agent wait --url "/dashboard" --timeout 10

# Wait for visible text anywhere on the page
testmu-browser-agent wait --text "Payment confirmed" --timeout 20

# Fixed timeout (fallback only)
testmu-browser-agent wait --timeout 5
```

Flags:
```
--selector string   CSS selector to wait for
--url string        URL pattern to wait for (substring match)
--text string       Visible text to wait for
--timeout int       Seconds to wait before error (default 30)
```

### `console [--clear]`

Read browser console messages (log, warn, error).

```sh
testmu-browser-agent console
testmu-browser-agent console --clear   # Clear after reading
```

### `errors [--clear]`

Show JavaScript errors and unhandled rejections.

```sh
testmu-browser-agent errors
testmu-browser-agent errors --clear
```

### `dialog <accept|dismiss>`

Handle browser dialogs (alert, confirm, prompt).

```sh
testmu-browser-agent dialog accept
testmu-browser-agent dialog dismiss
testmu-browser-agent dialog accept "typed response"   # For prompt dialogs
```

### `highlight <ref|selector>`

Visually highlight an element (draws outline). Useful before screenshots.

```sh
testmu-browser-agent highlight @e12
testmu-browser-agent highlight '#submit-btn'
```

### `stream [--filter pattern]`

Stream live browser events to stdout (network, console, navigation).

```sh
testmu-browser-agent stream
testmu-browser-agent stream --filter "api"
```

---

## Tabs & Frames

### `tabs`

List all open tabs with their IDs and URLs.

```sh
testmu-browser-agent tabs
# → [0] https://example.com (active)
# → [1] https://other.com
```

### `tab <id|new|close> [arg]`

Manage tabs.

```sh
testmu-browser-agent tab new          # Open new blank tab
testmu-browser-agent tab 1            # Switch to tab 1
testmu-browser-agent tab close        # Close current tab
testmu-browser-agent tab close 1      # Close tab 1
```

### `frame <selector>`

Switch context into an iframe.

```sh
testmu-browser-agent frame '#payment-iframe'
testmu-browser-agent snapshot   # Now operates inside the iframe
```

### `window <new>`

Open a new browser window.

```sh
testmu-browser-agent window new
```

---

## DevTools & Config

### `trace <start|stop>`

Start/stop a Chrome DevTools performance trace.

```sh
testmu-browser-agent trace start
# ... perform interactions ...
testmu-browser-agent trace stop
# → Saves trace.json
```

### `profiler <start|stop>`

Start/stop the V8 JavaScript profiler.

```sh
testmu-browser-agent profiler start
testmu-browser-agent profiler stop
```

### `batch <json-commands> [--bail]`

Execute multiple commands atomically from a JSON array.

```sh
testmu-browser-agent batch '[
  {"cmd":"open","url":"https://example.com"},
  {"cmd":"snapshot"},
  {"cmd":"click","selector":"e5"}
]'

# Stop on first error
testmu-browser-agent batch '[...]' --bail
```

### `set <what> <value>`

Configure browser settings at runtime.

```sh
testmu-browser-agent set viewport "1280x800"
testmu-browser-agent set user-agent "Mozilla/5.0 (custom)"
testmu-browser-agent set geolocation "37.7749,-122.4194"
testmu-browser-agent set timezone "America/Los_Angeles"
```

### `connect <cdp-url>`

Connect to a remote Chrome instance via CDP (Chrome DevTools Protocol).

```sh
testmu-browser-agent connect ws://localhost:9222
testmu-browser-agent connect ws://remote-host:9222/devtools/browser/abc123
```

### `device list`

List available device presets for viewport/UA emulation.

```sh
testmu-browser-agent device list
# → iPhone 14 Pro, Pixel 7, iPad Air, ...
```

---

## Server Modes

### `mcp`

Start the MCP stdio server for Claude Code integration.

```sh
testmu-browser-agent mcp
```

Add to `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### `serve`

Start the HTTP daemon server. Other CLI commands connect to this.

```sh
testmu-browser-agent serve
testmu-browser-agent serve --port 9222
testmu-browser-agent serve --socket /tmp/browser.sock
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `browser not found` | Install Chrome or set `--browser-path` |
| `connection refused` | Run `testmu-browser-agent serve` first, or let a command auto-start it |
| `ref @e12 not found` | Re-run `snapshot` — refs expire on page navigation |
| `timeout waiting for selector` | Increase `--timeout`, check the selector is correct |
| `element not interactable` | Use `wait --selector` first, or scroll element into view |
| State load fails | Verify `--storage-key` matches the key used to save |
| LambdaTest auth error | Set `LAMBDATEST_USERNAME` and `LAMBDATEST_ACCESS_KEY` env vars |
