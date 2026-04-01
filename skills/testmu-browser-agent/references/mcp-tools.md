# MCP Tools Reference

Complete reference for all 10 MCP tools exposed by `testmu-browser-agent mcp`. Includes JSON schemas, example request/response pairs, and usage tips.

## Table of Contents

- [Setup](#setup)
- [browser_navigate](#browser_navigate)
- [browser_interact](#browser_interact)
- [browser_query](#browser_query)
- [browser_media](#browser_media)
- [browser_state](#browser_state)
- [browser_tabs](#browser_tabs)
- [browser_wait](#browser_wait)
- [browser_config](#browser_config)
- [browser_network](#browser_network)
- [browser_devtools](#browser_devtools)
- [Error Handling](#error-handling)

---

## Setup

Start the MCP server:

```sh
testmu-browser-agent mcp
```

Add to `~/.claude/settings.json`:

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

All tools communicate over stdio using the MCP protocol. Claude Code calls them as structured JSON tool invocations.

---

## browser_navigate

Navigate the browser: open URLs, traverse history, close.

**Actions:** `open`, `navigate`, `back`, `forward`, `reload`, `close`

### `open`

```json
{
  "tool": "browser_navigate",
  "action": "open",
  "url": "https://example.com"
}
```

Response:
```json
{
  "success": true,
  "url": "https://example.com",
  "title": "Example Domain",
  "loadTime": 842
}
```

### `navigate`

```json
{
  "tool": "browser_navigate",
  "action": "navigate",
  "url": "https://example.com/about"
}
```

### `back` / `forward` / `reload`

```json
{ "tool": "browser_navigate", "action": "back" }
{ "tool": "browser_navigate", "action": "forward" }
{ "tool": "browser_navigate", "action": "reload" }
```

### `close`

```json
{ "tool": "browser_navigate", "action": "close" }
```

---

## browser_interact

Interact with page elements: click, fill, type, press, select, and more.

**Actions:** `click`, `fill`, `type`, `press`, `select`, `scroll`, `hover`, `check`, `uncheck`, `drag`, `upload`, `tap`, `swipe`

### `click`

```json
{
  "tool": "browser_interact",
  "action": "click",
  "selector": "e12"
}
```

Also accepts CSS selectors:
```json
{
  "tool": "browser_interact",
  "action": "click",
  "selector": "[type=\"submit\"]"
}
```

Response:
```json
{
  "success": true,
  "element": "[ref=e12] button \"Submit order\""
}
```

### `fill`

```json
{
  "tool": "browser_interact",
  "action": "fill",
  "selector": "e3",
  "text": "user@example.com"
}
```

### `type`

Types into the currently focused element without clearing it first:
```json
{
  "tool": "browser_interact",
  "action": "type",
  "text": " appended text"
}
```

### `press`

```json
{
  "tool": "browser_interact",
  "action": "press",
  "key": "Enter"
}
```

```json
{
  "tool": "browser_interact",
  "action": "press",
  "key": "Control+A"
}
```

### `select`

```json
{
  "tool": "browser_interact",
  "action": "select",
  "selector": "[name=\"size\"]",
  "value": "medium"
}
```

### `check` / `uncheck`

```json
{
  "tool": "browser_interact",
  "action": "check",
  "selector": "[name=\"topping\"][value=\"bacon\"]"
}
```

### `scroll`

```json
{
  "tool": "browser_interact",
  "action": "scroll",
  "direction": "down",
  "amount": 500
}
```

### `hover`

```json
{
  "tool": "browser_interact",
  "action": "hover",
  "selector": "#dropdown-menu"
}
```

### `drag`

```json
{
  "tool": "browser_interact",
  "action": "drag",
  "from": "e5",
  "to": "e10"
}
```

### `upload`

```json
{
  "tool": "browser_interact",
  "action": "upload",
  "selector": "[type=\"file\"]",
  "files": ["/path/to/document.pdf"]
}
```

---

## browser_query

Read page state: accessibility tree, text, HTML, DOM attributes, JS evaluation.

**Actions:** `snapshot`, `get`, `find`, `eval`, `inspect`

### `snapshot`

```json
{
  "tool": "browser_query",
  "action": "snapshot"
}
```

With options:
```json
{
  "tool": "browser_query",
  "action": "snapshot",
  "interactive": true,
  "maxLength": 3000
}
```

Response:
```json
{
  "success": true,
  "snapshot": "[ref=e1] textbox \"Customer name\" (editable)\n[ref=e2] textbox \"Telephone\" (editable)\n[ref=e3] button \"Submit order\"",
  "elementCount": 3
}
```

### `get`

```json
{
  "tool": "browser_query",
  "action": "get",
  "what": "title"
}
```

```json
{
  "tool": "browser_query",
  "action": "get",
  "what": "text",
  "selector": ".article-body"
}
```

```json
{
  "tool": "browser_query",
  "action": "get",
  "what": "attr",
  "selector": "#logo",
  "attr": "src"
}
```

Response:
```json
{
  "success": true,
  "value": "https://example.com/logo.png"
}
```

### `find`

```json
{
  "tool": "browser_query",
  "action": "find",
  "selector": "a[href]"
}
```

Response:
```json
{
  "success": true,
  "elements": [
    {"ref": "e4", "text": "Home", "href": "/"},
    {"ref": "e5", "text": "About", "href": "/about"}
  ],
  "count": 2
}
```

### `eval`

```json
{
  "tool": "browser_query",
  "action": "eval",
  "script": "JSON.stringify(window.__APP_STATE__)"
}
```

Response:
```json
{
  "success": true,
  "result": "{\"user\":{\"id\":42,\"name\":\"Jane\"},\"theme\":\"dark\"}"
}
```

---

## browser_media

Capture screenshots, generate PDFs, record video.

**Actions:** `screenshot`, `pdf`, `record`

### `screenshot`

```json
{
  "tool": "browser_media",
  "action": "screenshot"
}
```

With options:
```json
{
  "tool": "browser_media",
  "action": "screenshot",
  "output": "page.png",
  "format": "png",
  "full": false
}
```

JPEG with quality:
```json
{
  "tool": "browser_media",
  "action": "screenshot",
  "output": "page.jpg",
  "format": "jpeg",
  "quality": 85
}
```

Response:
```json
{
  "success": true,
  "path": "/absolute/path/to/page.png",
  "size": 142857,
  "dimensions": {"width": 1280, "height": 800}
}
```

### `pdf`

```json
{
  "tool": "browser_media",
  "action": "pdf",
  "output": "report.pdf"
}
```

Response:
```json
{
  "success": true,
  "path": "/absolute/path/to/report.pdf",
  "pages": 3
}
```

### `record`

```json
{ "tool": "browser_media", "action": "record", "command": "start" }
{ "tool": "browser_media", "action": "record", "command": "stop" }
{ "tool": "browser_media", "action": "record", "command": "restart" }
```

---

## browser_state

Persist and restore full browser state, manage cookies and storage.

**Actions:** `state_save`, `state_load`, `cookies_get`, `cookies_set`, `cookies_clear`, `storage_get`, `storage_set`, `clipboard_read`, `clipboard_write`

### `state_save`

```json
{
  "tool": "browser_state",
  "action": "state_save",
  "name": "my-session"
}
```

With encryption:
```json
{
  "tool": "browser_state",
  "action": "state_save",
  "name": "secure-session",
  "storageKey": "your-aes-256-key-here"
}
```

Response:
```json
{
  "success": true,
  "name": "my-session",
  "path": "/Users/user/.testmu/sessions/my-session.json",
  "encrypted": false
}
```

### `state_load`

```json
{
  "tool": "browser_state",
  "action": "state_load",
  "name": "my-session"
}
```

### `cookies_get`

```json
{
  "tool": "browser_state",
  "action": "cookies_get"
}
```

```json
{
  "tool": "browser_state",
  "action": "cookies_get",
  "domain": "example.com"
}
```

### `cookies_set`

```json
{
  "tool": "browser_state",
  "action": "cookies_set",
  "cookie": {
    "name": "session_id",
    "value": "abc123",
    "domain": "example.com",
    "path": "/",
    "httpOnly": true,
    "secure": true
  }
}
```

### `storage_get` / `storage_set`

```json
{
  "tool": "browser_state",
  "action": "storage_get",
  "key": "auth_token"
}
```

```json
{
  "tool": "browser_state",
  "action": "storage_set",
  "key": "theme",
  "value": "dark"
}
```

---

## browser_tabs

Manage tabs, windows, and iframe contexts.

**Actions:** `list`, `new`, `close`, `switch`, `window_new`, `frame`

### `list`

```json
{ "tool": "browser_tabs", "action": "list" }
```

Response:
```json
{
  "success": true,
  "tabs": [
    {"id": 0, "url": "https://example.com", "title": "Example", "active": true},
    {"id": 1, "url": "https://other.com", "title": "Other Site", "active": false}
  ]
}
```

### `new` / `switch` / `close`

```json
{ "tool": "browser_tabs", "action": "new" }
{ "tool": "browser_tabs", "action": "switch", "tabId": 1 }
{ "tool": "browser_tabs", "action": "close", "tabId": 1 }
```

### `frame`

Switch to an iframe context:
```json
{
  "tool": "browser_tabs",
  "action": "frame",
  "selector": "#payment-iframe"
}
```

---

## browser_wait

Wait for conditions before continuing.

```json
{
  "tool": "browser_wait",
  "selector": ".results-table",
  "timeout": 15
}
```

```json
{
  "tool": "browser_wait",
  "url": "/dashboard",
  "timeout": 10
}
```

```json
{
  "tool": "browser_wait",
  "text": "Payment confirmed",
  "timeout": 20
}
```

Fixed timeout:
```json
{
  "tool": "browser_wait",
  "timeout": 3
}
```

Response:
```json
{
  "success": true,
  "condition": "selector",
  "waitedMs": 1243
}
```

---

## browser_config

Configure viewport, user-agent, geolocation, or connect to remote CDP.

**Actions:** `set`, `connect`

### `set`

```json
{
  "tool": "browser_config",
  "action": "set",
  "setting": "viewport",
  "value": "1280x800"
}
```

```json
{
  "tool": "browser_config",
  "action": "set",
  "setting": "user-agent",
  "value": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0)"
}
```

```json
{
  "tool": "browser_config",
  "action": "set",
  "setting": "geolocation",
  "value": "37.7749,-122.4194"
}
```

### `connect`

```json
{
  "tool": "browser_config",
  "action": "connect",
  "url": "ws://localhost:9222"
}
```

---

## browser_network

Monitor console output, handle dialogs, stream events.

**Actions:** `console`, `errors`, `dialog`, `highlight`, `stream`

### `console`

```json
{ "tool": "browser_network", "action": "console" }
{ "tool": "browser_network", "action": "console", "clear": true }
```

Response:
```json
{
  "success": true,
  "messages": [
    {"level": "log", "text": "App initialized", "timestamp": 1700000001},
    {"level": "warn", "text": "Deprecated API used", "timestamp": 1700000002}
  ]
}
```

### `errors`

```json
{ "tool": "browser_network", "action": "errors" }
```

### `dialog`

```json
{ "tool": "browser_network", "action": "dialog", "response": "accept" }
{ "tool": "browser_network", "action": "dialog", "response": "dismiss" }
{ "tool": "browser_network", "action": "dialog", "response": "accept", "text": "typed input" }
```

### `highlight`

```json
{
  "tool": "browser_network",
  "action": "highlight",
  "selector": "e12"
}
```

---

## browser_devtools

Performance tracing, JavaScript profiling, batch command execution.

**Actions:** `trace_start`, `trace_stop`, `profiler_start`, `profiler_stop`, `batch`

### `trace_start` / `trace_stop`

```json
{ "tool": "browser_devtools", "action": "trace_start" }
{ "tool": "browser_devtools", "action": "trace_stop" }
```

### `profiler_start` / `profiler_stop`

```json
{ "tool": "browser_devtools", "action": "profiler_start" }
{ "tool": "browser_devtools", "action": "profiler_stop" }
```

### `batch`

Execute multiple tool calls atomically:

```json
{
  "tool": "browser_devtools",
  "action": "batch",
  "commands": [
    {"tool": "browser_navigate", "action": "open", "url": "https://example.com"},
    {"tool": "browser_query", "action": "snapshot", "interactive": true},
    {"tool": "browser_interact", "action": "fill", "selector": "e1", "text": "hello"}
  ],
  "bail": true
}
```

Response:
```json
{
  "success": true,
  "results": [
    {"step": 0, "success": true},
    {"step": 1, "success": true, "snapshot": "..."},
    {"step": 2, "success": true}
  ]
}
```

---

## Error Handling

All tools return a consistent error structure when a call fails:

```json
{
  "success": false,
  "error": "Element not found: ref e99",
  "code": "ELEMENT_NOT_FOUND",
  "details": {
    "selector": "e99",
    "availableRefs": ["e1", "e2", "e3"]
  }
}
```

Common error codes:

| Code | Meaning | Solution |
|---|---|---|
| `ELEMENT_NOT_FOUND` | Ref ID no longer valid | Re-run `snapshot` to get fresh refs |
| `NAVIGATION_TIMEOUT` | Page load exceeded timeout | Increase timeout or check network |
| `SELECTOR_NOT_FOUND` | CSS selector matched nothing | Check selector correctness, use `find` to debug |
| `STATE_NOT_FOUND` | Named state file doesn't exist | Check `~/.testmu/sessions/` for available states |
| `DECRYPTION_FAILED` | Wrong `storageKey` | Verify key matches the one used during `state_save` |
| `BROWSER_NOT_RUNNING` | No browser session active | Call `browser_navigate.open` first |
| `DIALOG_NOT_PRESENT` | No dialog to dismiss | Only call `dialog` when a dialog is expected |
