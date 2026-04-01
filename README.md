# testmu-browser-agent

AI-native browser automation CLI and MCP server for Chrome. Single binary, zero dependencies.

[![CI](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/actions/workflows/ci.yml/badge.svg)](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/actions)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/releases)

### Works with your AI coding tool

| Claude Code | Cursor | GitHub Copilot | Windsurf | Gemini CLI | Codex | Goose | OpenCode | Cline |
|:-----------:|:------:|:--------------:|:--------:|:----------:|:-----:|:-----:|:--------:|:-----:|
| [Setup](plugins/claude-code/) | [Setup](plugins/cursor/) | [Setup](plugins/copilot/) | [Setup](plugins/windsurf/) | [Setup](plugins/gemini-cli/) | [Setup](plugins/codex/) | [Setup](plugins/goose/) | [Setup](plugins/opencode/) | [Setup](plugins/cline/) |

> Works with any agent that can run shell commands or connect via MCP. [Auto-install all plugins](scripts/install-plugins.sh) with one script.

---

90+ CLI commands. 10 MCP tools. Stable `@ref` element IDs. Single binary. Zero dependencies.

---

## Quick Start

```bash
# Install
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh

# Open a page
testmu-browser-agent open https://example.com

# Take an accessibility snapshot (shows @ref IDs for all interactive elements)
testmu-browser-agent snapshot

# Click a button by its @ref ID
testmu-browser-agent click @e1

# Fill a form field
testmu-browser-agent fill @e5 "hello@example.com"

# Take a screenshot
testmu-browser-agent screenshot --output page.png

# Close the browser
testmu-browser-agent close
```

---

## What is testmu-browser-agent?

testmu-browser-agent is a single Go binary that exposes browser automation through three surfaces: a 90+ command CLI, a 10-tool MCP server for Claude Code, and a REST/SSE daemon API.

- **90+ CLI commands** — navigate, click, fill, screenshot, network interception, auth vault, device emulation, video recording, HAR capture, CDP diagnostics, and more, all from the terminal
- **MCP server with 10 tools** — plug directly into Claude Code so AI agents can control the browser without any additional setup
- **Accessibility snapshots with `@ref` IDs** — token-efficient, stable element references that survive DOM mutations
- **LambdaTest cloud integration** — run sessions on real cloud browsers with a single flag; no infrastructure required
- **AES-256-GCM encryption** — session state is encrypted at rest with a user-supplied storage key
- **Daemon mode with REST API and SSE** — long-lived browser process with HTTP endpoints and a Server-Sent Events stream for real-time event monitoring

---

## Architecture

testmu-browser-agent exposes one engine through three control surfaces:

```
CLI Command → daemon (127.0.0.1) → Chrome (local or LambdaTest cloud)
MCP Server  → executor           → Chrome
REST API    → executor           → Chrome
```

Three ways to control the same browser. Same commands, same engine, same behavior.

- The **CLI** is the primary interface — 90+ commands, scriptable, composable with shell pipelines
- The **MCP server** gives Claude Code 10 structured tools with typed JSON schemas — no shell escaping, no output parsing
- The **REST API + SSE** lets any programming language drive the browser over HTTP, with a real-time event stream on `/events`

All three surfaces share the same underlying executor, so a snapshot taken via MCP returns identical output to a snapshot taken via `curl` or the CLI.

---

## Why testmu-browser-agent?

- **Single binary, zero dependencies** — one Go binary, no Node.js, no Playwright install, no browser drivers
- **90+ CLI commands** — the most complete browser automation CLI available
- **Built-in MCP server with 10 tools** — Claude Code gets structured tools with typed JSON schemas; no shell escaping, no output parsing
- **REST API + SSE** — drive the browser from any programming language over HTTP
- **Accessibility snapshots with stable `@ref` IDs** — token-efficient element references that survive DOM mutations
- **AES-256-GCM encrypted session persistence** — save and restore full browser state securely
- **LambdaTest cloud + Appium mobile testing built in** — switch from local Chrome to cloud or real mobile devices with a single flag
- **25+ CDP diagnostic commands** — `web-vitals`, `cpu-throttle`, `vision-deficiency`, `webauthn`, and more
- **Docker support out of the box** — Chrome included in the image, daemon exposed on port 9222
- **Chrome for Testing auto-install** — `testmu-browser-agent install` downloads the correct Chrome version automatically

---

## Installation

### Install script (macOS and Linux)

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

The script detects your OS and architecture, downloads the correct binary from the latest release, and installs it to `/usr/local/bin`.

### Manual download

Download the pre-built binary for your platform from the [Releases](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/releases) page:

| Platform        | Binary                                  |
|-----------------|-----------------------------------------|
| macOS (Apple Silicon) | `testmu-browser-agent-darwin-arm64`   |
| macOS (Intel)   | `testmu-browser-agent-darwin-amd64`     |
| Linux (x86-64)  | `testmu-browser-agent-linux-amd64`      |
| Windows (x86-64)| `testmu-browser-agent-windows-amd64.exe`|

Make the binary executable and move it to a directory on your PATH:

```bash
chmod +x testmu-browser-agent-darwin-arm64
mv testmu-browser-agent-darwin-arm64 /usr/local/bin/testmu-browser-agent
```

---

## CLI Commands

All commands accept [global flags](#global-flags). Run any command with `--help` for full usage.

### Navigation

```bash
testmu-browser-agent open <url>          # Open a URL in a new browser page
testmu-browser-agent navigate <url>      # Navigate current page to a URL
testmu-browser-agent goto <url>          # Alias for navigate
testmu-browser-agent back                # Go back in browser history
testmu-browser-agent forward             # Go forward in browser history
testmu-browser-agent reload              # Reload the current page
testmu-browser-agent close               # Close the browser
testmu-browser-agent quit                # Alias for close
testmu-browser-agent exit                # Alias for close
```

### Interaction

```bash
# Click
testmu-browser-agent click <ref|selector>           # Click an element
testmu-browser-agent dblclick <ref|selector>        # Double-click an element

# Forms
testmu-browser-agent fill <ref|selector> <text>     # Fill a form field with text
testmu-browser-agent type <text>                    # Type into the focused element
testmu-browser-agent select <ref|selector> <value>  # Choose a dropdown option
testmu-browser-agent check <ref|selector>           # Check a checkbox
testmu-browser-agent uncheck <ref|selector>         # Uncheck a checkbox

# Keyboard
testmu-browser-agent press <key>                    # Press a keyboard key (e.g. Enter, Tab)
testmu-browser-agent key <key>                      # Alias for press
testmu-browser-agent keydown <key>                  # Hold a key down
testmu-browser-agent keyup <key>                    # Release a held key

# Pointer
testmu-browser-agent hover <ref|selector>           # Hover over an element
testmu-browser-agent tap <ref|selector>             # Tap (mobile-style)
testmu-browser-agent drag <from> <to>               # Drag from one element to another
testmu-browser-agent scroll <direction> [amount]    # Scroll the page (up/down/left/right)
testmu-browser-agent swipe <direction> [distance]   # Swipe gesture
testmu-browser-agent mouse <action> [x] [y]         # Raw mouse operations (move, click, wheel)

# Files and focus
testmu-browser-agent upload <ref|selector> <file>   # Upload a file to a file input
testmu-browser-agent focus <ref|selector>           # Focus an element
```

### Query

```bash
# Accessibility snapshot — the recommended way to inspect pages
testmu-browser-agent snapshot                       # Full accessibility snapshot with @ref IDs
testmu-browser-agent snapshot --full                # Full tree including hidden elements
testmu-browser-agent snapshot --diff                # Show only what changed since last snapshot
testmu-browser-agent snapshot --max-length 4000     # Cap output length

# Get page content
testmu-browser-agent get text                       # Get visible text of the page
testmu-browser-agent get title                      # Get page title
testmu-browser-agent get url                        # Get current URL
testmu-browser-agent get text <selector>            # Get text of a specific element
testmu-browser-agent get attr <selector> <attr>     # Get an element attribute
testmu-browser-agent get count <selector>           # Count elements matching a selector
testmu-browser-agent get box <selector>             # Get bounding box of an element
testmu-browser-agent get styles <selector>          # Get computed styles of an element

# Find and inspect
testmu-browser-agent find <selector>                # Find all elements matching a CSS selector
testmu-browser-agent find --role button             # Find by ARIA role
testmu-browser-agent find --text "Sign in"          # Find by visible text content
testmu-browser-agent find --label "Email"           # Find by aria-label or associated label
testmu-browser-agent find --placeholder "Search"    # Find by placeholder attribute
testmu-browser-agent find --alt "Logo"              # Find by alt attribute
testmu-browser-agent find --title "Close"           # Find by title attribute
testmu-browser-agent find --testid "submit-btn"     # Find by data-testid attribute
testmu-browser-agent find --role button --first     # Return only the first match
testmu-browser-agent find --role link --nth 3       # Return the 3rd match
testmu-browser-agent find --role button --last      # Return only the last match
testmu-browser-agent eval <javascript>              # Evaluate JavaScript in the page
testmu-browser-agent inspect                        # Inspect page info and metadata
```

### Media

```bash
# Screenshots
testmu-browser-agent screenshot                     # Full-page screenshot (PNG)
testmu-browser-agent screenshot --output page.png   # Save to file
testmu-browser-agent screenshot --ref @e5        # Screenshot a single element
testmu-browser-agent screenshot --format jpeg --quality 90

# PDF and recording
testmu-browser-agent pdf output.pdf                 # Generate a PDF of the current page
testmu-browser-agent record start                   # Start screen recording
testmu-browser-agent record stop                    # Stop and save recording
testmu-browser-agent record restart                 # Restart recording
```

### Tabs

```bash
testmu-browser-agent tabs                           # List open tabs
testmu-browser-agent tab new                        # Open a new tab
testmu-browser-agent tab new https://example.com    # Open a new tab with a URL
testmu-browser-agent tab close <id>                 # Close a tab by ID
testmu-browser-agent tab switch <id>                # Switch to a tab by ID
testmu-browser-agent window new                     # Open a new browser window
testmu-browser-agent frame <selector>               # Switch into an iframe
```

### State

```bash
# Save and load full browser state (cookies, storage, etc.)
testmu-browser-agent state save --name my-session
testmu-browser-agent state load --name my-session

# Cookies
testmu-browser-agent cookies get                    # List all cookies
testmu-browser-agent cookies set                    # Set a cookie
testmu-browser-agent cookies clear                  # Clear all cookies

# localStorage / sessionStorage
testmu-browser-agent storage get <key>              # Get a storage value
testmu-browser-agent storage set <key> <value>      # Set a storage value
testmu-browser-agent storage clear                  # Clear all storage
testmu-browser-agent storage remove <key>           # Remove a specific key
testmu-browser-agent storage get <key> --session    # Use sessionStorage

# Clipboard
testmu-browser-agent clipboard read                 # Read clipboard content
testmu-browser-agent clipboard write "text"         # Write to clipboard
```

### Wait

```bash
testmu-browser-agent wait --selector "#result"      # Wait for an element to appear
testmu-browser-agent wait --url "/dashboard"        # Wait for URL to match a pattern
testmu-browser-agent wait --text "Welcome"          # Wait for text to appear on page
testmu-browser-agent wait --load networkidle        # Wait for load state (domcontentloaded, load, networkidle)
testmu-browser-agent wait --fn "() => window.ready" # Wait for JS function to return truthy
testmu-browser-agent wait --download                # Wait for a download to complete
testmu-browser-agent wait --timeout 60000           # Set custom timeout in milliseconds (default: 30000)
```

### Network and Monitoring

```bash
testmu-browser-agent console                        # Get captured console messages
testmu-browser-agent console --clear                # Get and clear console messages
testmu-browser-agent errors                         # Get page JavaScript errors
testmu-browser-agent errors --clear                 # Get and clear errors
testmu-browser-agent dialog accept                  # Accept a browser dialog (alert/confirm)
testmu-browser-agent dialog dismiss                 # Dismiss a browser dialog
testmu-browser-agent highlight <ref|selector>       # Visually highlight an element
testmu-browser-agent stream                         # Stream browser events (SSE)
testmu-browser-agent stream --filter "click"        # Filter events by type
```

### DevTools

```bash
testmu-browser-agent trace start                    # Start a Chrome DevTools trace
testmu-browser-agent trace stop                     # Stop tracing and save
testmu-browser-agent profiler start                 # Start the JS CPU profiler
testmu-browser-agent profiler stop                  # Stop and save profiler output
testmu-browser-agent batch '<json-commands>'        # Execute multiple commands atomically
testmu-browser-agent batch --bail '<json-commands>' # Stop batch on first error
```

### Element Queries

```bash
testmu-browser-agent is visible <selector>           # Check if element is visible
testmu-browser-agent is hidden <selector>            # Check if element is hidden
testmu-browser-agent is enabled <selector>           # Check if element is enabled
testmu-browser-agent is checked <selector>           # Check if checkbox is checked
testmu-browser-agent scrollintoview <selector>       # Scroll an element into the viewport
```

### Downloads

```bash
testmu-browser-agent download                        # Enable download tracking and wait for next download
testmu-browser-agent download --dir /tmp/downloads   # Set download directory
testmu-browser-agent download --timeout 60000        # Custom timeout in milliseconds
```

### Network Interception

```bash
testmu-browser-agent route "**/*.png" --abort        # Block all PNG requests
testmu-browser-agent route "/api/data" --body '{"mock":true}' --status 200  # Mock an API response
testmu-browser-agent route "/api/*" --header "X-Test:true"  # Add response headers
testmu-browser-agent unroute "/api/data"             # Remove a specific interception rule
testmu-browser-agent unroute                         # Remove all interception rules
```

### Auth Vault

```bash
testmu-browser-agent auth save --name mysite --url https://example.com/login --username user --password pass
testmu-browser-agent auth login --name mysite        # Auto-login using stored credentials
testmu-browser-agent auth list                       # List stored credentials (passwords masked)
testmu-browser-agent auth show --name mysite         # Show credential details
testmu-browser-agent auth delete --name mysite       # Delete a stored credential
```

### Diff

```bash
testmu-browser-agent diff snapshot                   # Diff accessibility tree against last snapshot
testmu-browser-agent diff url <url>                  # Navigate to URL and diff before/after
testmu-browser-agent diff screenshot                 # Diff current screenshot against last stored
```

### Device Emulation

```bash
testmu-browser-agent geolocation 37.7749 -122.4194  # Override browser geolocation
testmu-browser-agent timezone America/New_York       # Override browser timezone
testmu-browser-agent locale fr-FR                    # Override browser locale
testmu-browser-agent permissions geolocation notifications  # Grant browser permissions
testmu-browser-agent offline                         # Enable offline mode
testmu-browser-agent offline --disable               # Restore network connectivity
testmu-browser-agent device-list                     # List available device profiles
testmu-browser-agent device-emulate "iPhone 15"      # Emulate a device (viewport, UA, scale)
```

### Content Injection

```bash
testmu-browser-agent addscript 'console.log("hi")'  # Evaluate JS in the current page
testmu-browser-agent addinitscript 'window.x = 1'   # Register JS that runs on every new document
testmu-browser-agent addstyle 'body { color: red }'  # Inject CSS into the current page
testmu-browser-agent expose myCallback               # Expose a function to page JS (calls forwarded as SSE events)
```

### Video Recording

```bash
testmu-browser-agent video start                     # Start recording page frames (screencast-based)
testmu-browser-agent video stop                      # Stop recording and save as GIF
testmu-browser-agent video stop --format frames      # Stop and save individual PNG frames
testmu-browser-agent video start --output-dir /tmp   # Set output directory for recordings
testmu-browser-agent video start --quality 90        # Set screencast quality (0-100)
```

### HAR Capture

```bash
testmu-browser-agent har start                       # Start capturing network traffic in HAR format
testmu-browser-agent har stop                        # Stop and return HAR data inline
testmu-browser-agent har stop --path traffic.har     # Stop and save HAR to file
```

### Network Request Inspection

```bash
testmu-browser-agent requests                        # List all captured network requests
testmu-browser-agent requests --filter "api"         # Filter requests by URL pattern
testmu-browser-agent request-detail <id>             # Get full details for a specific request
testmu-browser-agent response-body <id>              # Get the response body for a specific request
```

### Streaming

```bash
testmu-browser-agent stream-enable                   # Subscribe to CDP events via SSE
testmu-browser-agent stream-enable --events console,network  # Subscribe to specific event categories
testmu-browser-agent stream-disable                  # Unsubscribe from CDP events
testmu-browser-agent stream-status                   # Check if CDP event streaming is active
testmu-browser-agent screencast start                # Stream live page frames as base64 images
testmu-browser-agent screencast stop                 # Stop screencast
```

### Sessions

Run multiple isolated browser sessions concurrently. Each session gets its own daemon process and browser instance.

```bash
# Default session (backward compatible — no flag needed)
testmu-browser-agent open https://example.com

# Named sessions
testmu-browser-agent --session work open https://github.com
testmu-browser-agent --session personal open https://gmail.com

# Check current session
testmu-browser-agent session

# List all active sessions
testmu-browser-agent session list

# JSON output
testmu-browser-agent session list --output json
```

Each session creates a separate daemon with its own Unix socket in `~/.testmu-browser-agent/`. The `--socket` flag overrides session-based socket resolution for backward compatibility.

### CDP / Advanced Browser Control

Low-level Chrome DevTools Protocol actions for advanced diagnostics, security testing, and performance analysis.

```bash
# Security
testmu-browser-agent ignore-certs                    # Ignore TLS certificate errors
testmu-browser-agent ignore-certs --disable          # Re-enable certificate validation
testmu-browser-agent bypass-csp                      # Bypass Content Security Policy
testmu-browser-agent bypass-csp --disable            # Re-enable CSP

# Cookies and Storage (CDP-level)
testmu-browser-agent cookies-delete <name>           # Delete a specific cookie by name
testmu-browser-agent clear-origin <origin>           # Clear all storage for an origin
testmu-browser-agent cache --disable                 # Disable browser cache
testmu-browser-agent cache --enable                  # Re-enable browser cache
testmu-browser-agent indexeddb <origin>              # List IndexedDB databases for an origin

# Emulation
testmu-browser-agent touch-emulation                 # Enable touch event emulation
testmu-browser-agent touch-emulation --disable       # Disable touch emulation
testmu-browser-agent media-emulate print             # Emulate CSS media type (print, screen)
testmu-browser-agent vision-deficiency deuteranopia   # Simulate vision deficiency
testmu-browser-agent cpu-throttle 4                  # Throttle CPU (4x slowdown)
testmu-browser-agent cpu-throttle 1                  # Remove CPU throttling

# Authentication
testmu-browser-agent fetch-auth <user> <pass>        # Handle HTTP Basic/Digest auth prompt
testmu-browser-agent fetch-auth-persist <user> <pass> # Persist HTTP auth across navigations

# Performance and Diagnostics
testmu-browser-agent performance-metrics             # Get runtime performance metrics
testmu-browser-agent web-vitals                      # Measure Core Web Vitals (LCP, FID, CLS)
testmu-browser-agent dom-snapshot                    # Capture a full DOM snapshot
testmu-browser-agent ax-query                        # Query the accessibility tree via CDP
testmu-browser-agent frame-tree                      # Get the page frame tree hierarchy

# Target and Worker Management
testmu-browser-agent new-targets                     # List newly created tabs/popups
testmu-browser-agent sw-unregister                   # Unregister service workers
testmu-browser-agent browser-logs                    # Start capturing browser-level logs
testmu-browser-agent browser-logs-get                # Retrieve captured browser logs

# Scripting
testmu-browser-agent isolated-world                  # Create an isolated JavaScript world
testmu-browser-agent scroll-into-view-cdp <nodeId>   # Scroll node into view via CDP (by backend node ID)

# WebAuthn
testmu-browser-agent webauthn-add                    # Add a virtual WebAuthn authenticator
testmu-browser-agent webauthn-remove <id>            # Remove a virtual authenticator

# Request Data
testmu-browser-agent get-post-data <requestId>       # Get POST body for a captured request
```

### Maintenance

```bash
testmu-browser-agent install                         # Download and install Chrome for Testing
testmu-browser-agent install --dest /opt/chrome      # Install to a custom directory
testmu-browser-agent upgrade                         # Self-update to the latest release
```

### Configuration

```bash
testmu-browser-agent set viewport 1920x1080         # Set browser viewport
testmu-browser-agent set useragent "MyAgent/1.0"    # Override the user agent
testmu-browser-agent set geolocation "37.77,-122.4" # Set geolocation
testmu-browser-agent set offline true               # Enable offline mode
testmu-browser-agent connect <cdp-url>              # Connect to a remote CDP endpoint
testmu-browser-agent device list                    # List emulatable device profiles
```

---

## MCP Server (Claude Code Integration)

> **Unique:** testmu-browser-agent is the only browser automation CLI with a built-in MCP server. Claude Code gets 10 structured tools with typed JSON schemas — no shell escaping, no output parsing.

testmu-browser-agent ships a Model Context Protocol server that Claude Code can use to control a real Chrome browser during conversations. The MCP server exposes 10 grouped tools and communicates over stdio — no network port required.

### Setup

Add the following to your Claude Code settings file (`.claude/settings.json` or `~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "env": {}
    }
  }
}
```

For headless mode (useful in CI or when you do not want a visible browser window):

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--headless"]
    }
  }
}
```

After saving, restart Claude Code. The browser tools will be available in your next conversation.

### Available Tools

| Tool | Actions | Description |
|------|---------|-------------|
| `browser_navigate` | open, navigate, back, forward, reload, close | Navigate pages and manage browser history |
| `browser_interact` | click, dblclick, fill, type, press, select, scroll, hover, tap, drag, upload, focus, check, uncheck, swipe | Interact with page elements |
| `browser_query` | snapshot, get, find, eval, inspect | Query page content and the DOM |
| `browser_media` | screenshot, pdf, record | Capture screenshots, PDFs, and video recordings |
| `browser_state` | cookies_get/set/clear, state_save/load, storage_get/set/clear/remove, clipboard_read/write | Manage browser state and persistence |
| `browser_tabs` | list, new, close, switch, window_new, frame | Manage tabs, windows, and frames |
| `browser_wait` | (condition-based) | Wait for elements, URLs, text, or timeouts |
| `browser_config` | set, connect | Configure viewport, user-agent, and remote connections |
| `browser_network` | console, errors, dialog, highlight, stream | Monitor console output, errors, and dialogs |
| `browser_devtools` | trace_start/stop, profiler_start/stop, batch, performance_metrics, browser_logs, frame_tree, isolated_world, webauthn_add/remove | DevTools tracing, profiling, batch execution, and low-level CDP diagnostics |

For a complete integration guide, see [docs/guides/mcp-integration.md](docs/guides/mcp-integration.md).

---

## LambdaTest Cloud

Run your browser sessions on LambdaTest's cloud infrastructure instead of a local Chrome installation. This is useful for CI pipelines, cross-browser testing on Windows, and avoiding local browser setup.

### Environment variables

```bash
export LT_USERNAME="your-lambdatest-username"
export LT_ACCESS_KEY="your-lambdatest-access-key"
```

### CLI with LambdaTest

```bash
testmu-browser-agent --provider lambdatest open https://example.com
testmu-browser-agent --provider lambdatest snapshot
testmu-browser-agent --provider lambdatest screenshot --output result.png
```

### Daemon with LambdaTest

```bash
testmu-browser-agent serve --provider lambdatest --port 9222
```

### MCP with LambdaTest

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "lambdatest"],
      "env": {
        "LT_USERNAME": "your-username",
        "LT_ACCESS_KEY": "your-access-key"
      }
    }
  }
}
```

LambdaTest sessions automatically capture video, console logs, and network traffic in your LambdaTest dashboard. The provider sends a keepalive ping every 60 seconds to keep long-running sessions alive, and marks tests as passed or failed when the session closes.

For the complete LambdaTest setup guide, see [docs/guides/lambdatest.md](docs/guides/lambdatest.md).

---

## Appium Mobile Testing

Run browser sessions on real iOS and Android devices via an Appium server. This is useful for mobile web testing and responsive validation.

### Environment variables

```bash
export APPIUM_URL="http://localhost:4723"   # Appium server URL (or set via --appium-url)
```

### CLI with Appium

```bash
testmu-browser-agent --provider appium --platform android open https://example.com
testmu-browser-agent --provider appium --platform ios snapshot
testmu-browser-agent --provider appium --appium-url http://hub:4723 --platform android screenshot --output mobile.png
```

### MCP with Appium

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "appium", "--platform", "android"],
      "env": {
        "APPIUM_URL": "http://localhost:4723"
      }
    }
  }
}
```

---

## Daemon Mode

Daemon mode starts a long-lived browser process and exposes it over HTTP and a Unix domain socket. CLI commands automatically connect to a running daemon, so you can reuse a single browser session across many commands without the startup overhead of launching a new browser each time.

### Start the daemon

```bash
testmu-browser-agent serve                          # HTTP on port 9222 (default)
testmu-browser-agent serve --port 9000              # Custom port
testmu-browser-agent serve --socket /tmp/tmu.sock   # Unix socket
testmu-browser-agent serve --headless               # Headless mode
testmu-browser-agent serve --provider lambdatest    # Cloud browser
```

### REST API

Every CLI action is available as an HTTP endpoint:

```
POST /{action}   — JSON body with action parameters
GET  /{action}   — query string parameters
GET  /events     — Server-Sent Events stream
```

Examples:

```bash
# Navigate
curl -X POST http://localhost:9222/open \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'

# Take a snapshot
curl http://localhost:9222/snapshot

# Get page title
curl "http://localhost:9222/get?type=title"

# Subscribe to browser events
curl -N http://localhost:9222/events
```

### SSE event stream

The `/events` endpoint streams all browser events in real time using Server-Sent Events. Clients can subscribe with any SSE-capable library or `curl -N`.

```bash
curl -N http://localhost:9222/events
# data: {"type":"navigate","url":"https://example.com","timestamp":"..."}
# data: {"type":"click","ref":"@e12","timestamp":"..."}
```

### Idle timeout

The daemon shuts itself down after 5 minutes of inactivity by default. Each incoming request resets the timer. You can configure this in the `serve` command.

---

## Accessibility Snapshots

`snapshot` is the primary way to understand what is on a page. Instead of returning raw HTML, it produces a compact, structured accessibility tree where every interactive element is assigned a stable `@ref` ID.

### Example output

```
[1] Page: Example Domain
  [2] heading: Example Domain @e1
  [3] paragraph: This domain is for use in illustrative examples...
  [4] link: More information... @e2
    href: https://www.iana.org/domains/reserved
```

You can then reference any element directly:

```bash
testmu-browser-agent click @e2
testmu-browser-agent fill @e5 "search query"
```

### Why snapshots instead of screenshots?

- **Stable references** — `@ref` IDs survive page re-renders and minor DOM changes
- **Full tree mode** — `--full` includes non-interactive and hidden elements when you need the complete picture
- **Diffing** — `--diff` shows only what changed since the last snapshot, ideal for verifying that an action had the expected effect
- **Token-efficient** — the accessibility tree is far smaller than HTML or image data, making it suitable for LLM context windows

---

## Global Flags

These flags apply to every command:

| Flag | Default | Description |
|------|---------|-------------|
| `--provider` | `local` | Browser provider: `local`, `lambdatest`, or `appium` |
| `--session` | `default` | Browser session name for concurrent sessions |
| `--headless` | `true` | Run browser in headless mode (no visible window) |
| `--port` | `9222` | Daemon port for HTTP API |
| `--socket` | `` | Unix socket path for daemon communication |
| `--storage-key` | `` | AES-256-GCM encryption key for saved session state |
| `--browser-path` | `` | Path to a custom Chrome or Chromium binary |
| `--timeout` | `30` | Default command timeout in seconds |
| `--output` | `text` | Output format: `text`, `json`, or `compact` |
| `--verbose` | `false` | Enable verbose logging |
| `--appium-url` | `` | Appium server URL (used with `--provider appium`) |
| `--platform` | `` | Mobile platform: `ios` or `android` (used with `--provider appium`) |

---

## Environment Variables

| Variable | Description |
|----------|-------------|
| `LT_USERNAME` | LambdaTest account username (required for `--provider lambdatest`) |
| `LT_ACCESS_KEY` | LambdaTest access key (required for `--provider lambdatest`) |
| `APPIUM_URL` | Appium server URL (used with `--provider appium`, default `http://localhost:4723`) |
| `TMU_SESSION` | Default session name (overridden by `--session` flag) |
| `TMU_SOCKET_DIR` | Custom directory for session socket and PID files |

---

## Docker

Run testmu-browser-agent in a Docker container with Chrome included:

```bash
# Build the image
docker build -t testmu-browser-agent:latest .

# Run a one-off command
docker run --rm testmu-browser-agent:latest open https://example.com

# Start the daemon and expose the REST API
docker run -p 9222:9222 testmu-browser-agent:latest serve --headless

# Run with LambdaTest
docker run --rm \
  -e LT_USERNAME=your-username \
  -e LT_ACCESS_KEY=your-access-key \
  testmu-browser-agent:latest --provider lambdatest open https://example.com
```

---

## Examples

| Example | Description |
|---------|-------------|
| [examples/mcp-claude/](examples/mcp-claude/) | Using testmu-browser-agent as an MCP server inside a Claude Code conversation |
| [examples/ci-testing/](examples/ci-testing/) | Running browser tests in a CI pipeline with GitHub Actions |
| [examples/cli-scripting/](examples/cli-scripting/) | Shell scripts that chain CLI commands for common automation tasks |

---

## Documentation

| Guide | Description |
|-------|-------------|
| [docs/guides/quick-start.md](docs/guides/quick-start.md) | Five-minute walkthrough from install to first automation |
| [docs/guides/commands.md](docs/guides/commands.md) | Complete reference for every CLI command and flag |
| [docs/guides/mcp-integration.md](docs/guides/mcp-integration.md) | MCP server setup, tool reference, and Claude Code examples |
| [docs/guides/lambdatest.md](docs/guides/lambdatest.md) | LambdaTest cloud setup, capabilities, and session management |

---

## Benchmarks

Benchmark results and historical data are in [benchmarks/](benchmarks/).
