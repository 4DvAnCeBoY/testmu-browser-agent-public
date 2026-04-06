# Commands Reference

> **v1.0.7** — 90+ commands, all tested. New: `har start/stop`, `click --new-tab`, `dialog --text`, `tab new --url`.

Complete reference for all `testmu-browser-agent` commands and flags.

---

## Global Flags

These flags apply to every command and must be placed before the subcommand name.

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--provider` | string | `local` | Browser provider: `local`, `lambdatest`, or `appium` |
| `--headless` | bool | `true` | Run browser in headless mode |
| `--port` | int | `9222` | Daemon HTTP server port |
| `--socket` | string | `/tmp/testmu-browser-agent.sock` | Unix socket path for daemon communication |
| `--storage-key` | string | _(empty)_ | AES-256-GCM encryption key for saved session state |
| `--browser-path` | string | _(auto-detect)_ | Path to a custom browser executable |
| `--timeout` | int | `30` | Default command timeout in seconds |
| `--output` | string | `text` | Output format: `text`, `json`, or `compact` |
| `--verbose` | bool | `false` | Enable verbose/debug logging |
| `--appium-url` | string | _(empty)_ | Appium server URL (used with `--provider appium`) |
| `--platform` | string | _(empty)_ | Mobile platform: `ios` or `android` (used with `--provider appium`) |

**Example:**

```sh
testmu-browser-agent --provider lambdatest --headless=false --output json open https://example.com
```

---

## Commands

### Lifecycle

| Command | Usage | Description |
|---------|-------|-------------|
| `serve` | `serve` | Start the daemon HTTP server. Reads `--provider`, `--headless`, `--port`, `--socket`, `--browser-path`. |
| `mcp` | `mcp` | Start the MCP stdio server for Claude Code integration. See [mcp-integration.md](./mcp-integration.md). |
| `close` | `close` | Close the browser and end the session. |
| `connect` | `connect <url>` | Connect to a remote browser via its CDP (Chrome DevTools Protocol) endpoint URL. |

---

### Navigation

| Command | Usage | Description |
|---------|-------|-------------|
| `open` | `open <url>` | Open a URL in a new browser page. |
| `navigate` | `navigate <url>` | Navigate the current page to a URL. |
| `back` | `back` | Go back in browser history. |
| `forward` | `forward` | Go forward in browser history. |
| `reload` | `reload` | Reload the current page. |

**Aliases:** `goto` is an alias for `navigate`.

---

### Interaction

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `click` | `click <ref\|selector>` | | Click an element by `@ref` or CSS selector. |
| `dblclick` | `dblclick <ref\|selector>` | | Double-click an element. |
| `fill` | `fill <ref\|selector> <text>` | | Clear a form field and fill it with text. |
| `type` | `type <text>` | | Type text into the currently focused element (no clear). |
| `press` | `press <key>` | | Press a keyboard key (e.g. `Enter`, `Tab`, `Escape`, `ArrowDown`). |
| `select` | `select <ref\|selector> <value>` | | Select an option from a `<select>` dropdown. |
| `check` | `check <ref\|selector>` | | Check a checkbox. |
| `uncheck` | `uncheck <ref\|selector>` | | Uncheck a checkbox. |
| `hover` | `hover <ref\|selector>` | | Hover the mouse pointer over an element. |
| `focus` | `focus <ref\|selector>` | | Move keyboard focus to an element. |
| `tap` | `tap <ref\|selector>` | | Tap an element (touch gesture). |
| `drag` | `drag <from> <to>` | | Drag an element or coordinates to another element or coordinates. |
| `upload` | `upload <ref\|selector> <file...>` | | Upload one or more files to a `<input type="file">`. |
| `scroll` | `scroll <direction> [amount]` | | Scroll the page. Direction: `up`, `down`, `left`, `right`. Amount in pixels. |
| `swipe` | `swipe <direction> [distance]` | | Perform a swipe gesture. Direction: `up`, `down`, `left`, `right`. |
| `keydown` | `keydown <key>` | | Press a key down without releasing it. |
| `keyup` | `keyup <key>` | | Release a held key. |
| `mouse` | `mouse <action> [x] [y]` | | Raw mouse operations: `move`, `click`, `wheel`. Coordinates optional. |

**Aliases:** `key` is an alias for `press`.

---

### Query

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `snapshot` | `snapshot` | `--full`, `--max-length <n>`, `--diff` | Take an accessibility tree snapshot. Returns `@ref` handles for interactive elements. `--full` includes non-interactive nodes. `--diff` shows changes since last snapshot. |
| `get` | `get <type> [selector] [attr]` | | Get content from the page. Types: `text`, `html`, `attr`, `title`, `url`, `count`, `box`, `styles`. |
| `find` | `find [selector]` | `--role`, `--text`, `--label`, `--placeholder`, `--alt`, `--title`, `--testid`, `--nth`, `--first`, `--last` | Find elements by CSS selector or semantic query (role, text, label, placeholder, alt, title, testid). |
| `is` | `is <visible\|hidden\|enabled\|checked> <selector>` | | Check element state. Returns true/false. |
| `scrollintoview` | `scrollintoview <ref\|selector>` | | Scroll an element into the visible viewport. |
| `eval` | `eval <javascript>` | | Evaluate a JavaScript expression in the page context and return the result. |
| `inspect` | `inspect` | | Inspect the current page info (title, URL, viewport). |

---

### Media

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `screenshot` | `screenshot` | `--ref <ref\|selector>`, `--output <path>`, `--format <png\|jpeg>`, `--quality <0-100>` | Take a screenshot. Defaults to PNG. JPEG quality default is 80. |
| `pdf` | `pdf [output-path]` | `--output <path>` | Generate a PDF of the current page. |
| `record` | `record <subcommand>` | | Control video recording. Subcommands: `start`, `stop`, `restart`. |

---

### Tabs & Windows

| Command | Usage | Description |
|---------|-------|-------------|
| `tabs` | `tabs` | List all open browser tabs with their IDs and URLs. |
| `tab` | `tab <id\|new\|close> [arg]` | Manage tabs: open a new tab, close a tab by ID, or switch to a tab by ID. |
| `window` | `window <new>` | Open a new browser window. |
| `frame` | `frame <selector>` | Switch the active context to an iframe matching the selector. |

---

### State Management

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `state` | `state <save\|load> --name <name>` | `--name <name>` (required) | Save or load a named browser session (cookies, storage, auth). Encrypted if `--storage-key` is set. |
| `cookies` | `cookies [get\|set\|clear]` | | Manage cookies. With no subcommand, returns all cookies. |
| `storage` | `storage <get\|set\|clear\|remove> [key] [value]` | `--session` | Manage `localStorage`. Use `--session` for `sessionStorage`. |
| `clipboard` | `clipboard <read\|write> [text]` | | Read or write the system clipboard. |

---

### Wait

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `wait` | `wait` | `--selector <css>`, `--url <pattern>`, `--text <string>`, `--load <state>`, `--fn <js>`, `--download`, `--timeout <ms>` | Wait for a condition before continuing. Default timeout is 30000 ms. At least one condition flag is expected. |

**Examples:**

```sh
# Wait for an element to appear
testmu-browser-agent wait --selector ".dashboard"

# Wait for the URL to match a pattern
testmu-browser-agent wait --url "*/dashboard"

# Wait for text to be visible
testmu-browser-agent wait --text "Welcome back"

# Wait for load state (domcontentloaded, load, networkidle)
testmu-browser-agent wait --load networkidle

# Wait for a JS function to return truthy
testmu-browser-agent wait --fn "() => document.querySelector('.ready')"

# Wait for a download to complete
testmu-browser-agent wait --download

# Wait with a custom timeout (milliseconds)
testmu-browser-agent wait --selector "#result" --timeout 60000
```

---

### Network & Monitoring

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `console` | `console` | `--clear` | Get captured browser console messages. `--clear` removes messages after reading. |
| `errors` | `errors` | `--clear` | Get captured page errors. `--clear` removes errors after reading. |
| `dialog` | `dialog <accept\|dismiss>` | | Handle a pending browser dialog (alert, confirm, prompt). |
| `highlight` | `highlight <ref\|selector>` | | Visually highlight an element on the page. |
| `stream` | `stream` | `--filter <pattern>` | Stream browser events in real time. Use `--filter` to narrow event types. |

---

### DevTools

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `trace` | `trace <start\|stop>` | | Start or stop a performance trace. |
| `profiler` | `profiler <start\|stop>` | | Start or stop the CPU profiler. |
| `batch` | `batch <json-commands>` | `--bail` | Execute multiple commands in a single call by passing a JSON array of command objects. `--bail` stops on the first error. |

**`batch` example:**

```sh
testmu-browser-agent batch '[
  {"action":"navigate","params":{"url":"https://example.com"}},
  {"action":"snapshot"},
  {"action":"screenshot","params":{"output":"result.png"}}
]' --bail
```

---

### Configuration

| Command | Usage | Description |
|---------|-------|-------------|
| `set` | `set <what> <value>` | Set a browser configuration option at runtime. Options: `viewport` (e.g. `1920x1080`), `useragent`, `geolocation` (e.g. `lat,lng`), `offline` (`true`/`false`), `headers` (JSON string). |
| `connect` | `connect <url>` | Connect to a remote Chrome DevTools Protocol (CDP) endpoint (e.g. `ws://localhost:9222`). |

---

### Downloads

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `download` | `download` | `--dir <path>`, `--timeout <ms>` | Enable download tracking and wait for the next download. Default timeout: 30000 ms. |

---

### Network Interception

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `route` | `route <url-pattern>` | `--abort`, `--body <json>`, `--status <code>`, `--header <key:value>` (repeatable) | Intercept network requests matching a URL pattern. Use `--abort` to block, `--body` to mock a response. |
| `unroute` | `unroute [url-pattern]` | | Remove a network interception rule. Omit pattern to clear all rules. |

---

### Auth Vault

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `auth save` | `auth save` | `--name` (required), `--url`, `--username`, `--password`, `--vault`, `--storage-key` | Save a credential to the encrypted vault. |
| `auth login` | `auth login` | `--name` (required), `--username-selector`, `--password-selector`, `--submit-selector` | Auto-login using a stored credential (opens URL, fills form, submits). |
| `auth list` | `auth list` | `--vault`, `--storage-key` | List all stored credentials (passwords masked). |
| `auth show` | `auth show` | `--name` (required) | Show credential details (password masked). |
| `auth delete` | `auth delete` | `--name` (required) | Delete a credential from the vault. |

---

### Diff

| Command | Usage | Description |
|---------|-------|-------------|
| `diff snapshot` | `diff snapshot` | Diff the accessibility tree against the last stored snapshot. |
| `diff url` | `diff url <url>` | Navigate to a URL and diff the accessibility tree before and after. |
| `diff screenshot` | `diff screenshot` | Diff the current screenshot against the last stored screenshot. |

---

### Device Emulation

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `geolocation` | `geolocation <lat> <lon>` | `--accuracy <metres>` | Override the browser's geolocation. |
| `timezone` | `timezone <timezone-id>` | | Override the browser's timezone (e.g. `America/New_York`). |
| `locale` | `locale <locale>` | | Override the browser's locale (e.g. `fr-FR`). |
| `permissions` | `permissions <perm> [perm...]` | `--origin <url>` | Grant browser permissions (e.g. `geolocation`, `notifications`). |
| `offline` | `offline` | `--disable` | Enable offline mode. Use `--disable` to restore connectivity. |
| `device-list` | `device-list` | | List available device emulation profiles. |
| `device-emulate` | `device-emulate <name>` | | Emulate a device profile (viewport, user-agent, device scale factor). |

---

### Content Injection

| Command | Usage | Description |
|---------|-------|-------------|
| `addscript` | `addscript <js>` | Evaluate a JavaScript snippet in the current page. |
| `addinitscript` | `addinitscript <js>` | Register a script that runs on every new document. |
| `addstyle` | `addstyle <css>` | Inject a CSS snippet into the current page. |
| `expose` | `expose <name>` | Expose a function to page JS; calls are forwarded as SSE events. |

---

### Streaming

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `stream-enable` | `stream-enable` | `--events <categories>` | Subscribe to CDP events and forward them to the SSE broadcaster. Categories: `console`, `network`, `page`. |
| `stream-disable` | `stream-disable` | | Unsubscribe from CDP events. |
| `stream-status` | `stream-status` | | Report whether CDP event streaming is active. |
| `screencast` | `screencast <start\|stop>` | `--format <jpeg\|png>`, `--quality <0-100>` | Stream live page frames as base64 images to the SSE broadcaster. |

---

### Maintenance

| Command | Usage | Flags | Description |
|---------|-------|-------|-------------|
| `install` | `install` | `--dest <dir>` | Download and install Chrome for Testing. Default: `~/.testmu-browser-agent/chrome/`. |
| `upgrade` | `upgrade` | | Check GitHub for the latest release and self-update the CLI binary. |

---

### Miscellaneous

| Command | Usage | Description |
|---------|-------|-------------|
| `device` | `device list` | List available device emulation presets (legacy; prefer `device-list`). |
| `confirm` | `confirm <id>` | Confirm a pending policy-guarded action by its ID. |
| `deny` | `deny <id>` | Deny a pending policy-guarded action by its ID. |

---

### Aliases

| Alias | Equivalent |
|-------|-----------|
| `goto` | `navigate` |
| `quit` | `close` |
| `exit` | `close` |
| `key` | `press` |

---

## See Also

- [Quick Start](./quick-start.md)
- [MCP Integration](./mcp-integration.md)
- [LambdaTest Integration](./lambdatest.md)
