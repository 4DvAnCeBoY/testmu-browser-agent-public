# MCP Integration

`testmu-browser-agent` ships a built-in [Model Context Protocol](https://modelcontextprotocol.io) (MCP) server. Running `testmu-browser-agent mcp` starts a stdio JSON-RPC 2.0 server that exposes 10 grouped browser tools to any MCP client, including **Claude Code**.

---

## Setup

### Claude Code — local browser

Add the server to your Claude Code `settings.json` (usually `~/.claude/settings.json` or the workspace `.claude/settings.json`):

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

By default the agent launches a headless Chromium instance. To run with a visible browser window:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--headless=false"],
      "env": {}
    }
  }
}
```

### Claude Code — LambdaTest cloud

Set your LambdaTest credentials and pass the `--provider` flag:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "lambdatest"],
      "env": {
        "LT_USERNAME": "your-lt-username",
        "LT_ACCESS_KEY": "your-lt-access-key"
      }
    }
  }
}
```

See [lambdatest.md](./lambdatest.md) for full LambdaTest setup details.

---

## Available Tools

The MCP server exposes 10 tools, each grouping related actions:

| Tool | Actions | Description |
|------|---------|-------------|
| `browser_navigate` | `open`, `navigate`, `back`, `forward`, `reload`, `close` | Navigate the browser: open URLs, move through history, reload or close the page |
| `browser_interact` | `click`, `dblclick`, `fill`, `type`, `press`, `select`, `scroll`, `hover`, `tap`, `drag`, `upload`, `focus`, `check`, `uncheck`, `swipe` | Interact with page elements: clicks, form filling, keyboard input, gestures, and file uploads |
| `browser_query` | `snapshot`, `get`, `find`, `eval`, `inspect` | Query the page: accessibility tree snapshots, DOM content, element search, and JavaScript evaluation |
| `browser_media` | `screenshot`, `pdf`, `record` | Capture media: screenshots, PDF exports, and video recording |
| `browser_state` | `cookies_get`, `cookies_set`, `cookies_clear`, `state_save`, `state_load`, `storage_get`, `storage_set`, `storage_clear`, `storage_remove`, `clipboard_read`, `clipboard_write` | Manage browser state: cookies, saved sessions, localStorage/sessionStorage, and clipboard |
| `browser_tabs` | `list`, `new`, `close`, `switch`, `window_new`, `frame` | Manage tabs and frames: list open tabs, open/close/switch tabs, open new windows, switch to iframes |
| `browser_wait` | `selector`, `url`, `text`, `timeout` | Wait for conditions: element visibility, URL navigation, text appearance, or a fixed timeout |
| `browser_config` | `set`, `connect` | Configure the browser: set viewport/useragent/geolocation/headers, or connect to a remote CDP endpoint |
| `browser_network` | `console`, `errors`, `dialog`, `highlight`, `stream` | Monitor and control: read console logs, capture page errors, handle dialogs, highlight elements, stream events |
| `browser_devtools` | `trace_start`, `trace_stop`, `profiler_start`, `profiler_stop`, `batch` | DevTools integration: tracing, CPU profiling, and batch command execution |

---

## Example Workflow

Here is how Claude uses MCP tools to automate a login flow:

**User prompt:** "Log into https://app.example.com and take a screenshot of the dashboard."

**Claude's tool calls:**

```
1. browser_navigate { "action": "open", "url": "https://app.example.com/login" }

2. browser_query { "action": "snapshot" }
   → Returns accessibility tree with refs: @e1 (email input), @e2 (password input), @e3 (submit button)

3. browser_interact { "action": "fill", "selector": "@e1", "text": "user@example.com" }

4. browser_interact { "action": "fill", "selector": "@e2", "text": "p@ssw0rd" }

5. browser_interact { "action": "click", "selector": "@e3" }

6. browser_wait { "selector": ".dashboard", "timeout": 15 }

7. browser_media { "action": "screenshot", "output": "dashboard.png" }

8. browser_navigate { "action": "close" }
```

Claude chains these calls automatically based on the snapshot refs, without requiring you to specify CSS selectors manually.

---

## Protocol Details

| Property | Value |
|----------|-------|
| Transport | stdio (stdin/stdout) |
| Message format | Newline-delimited JSON-RPC 2.0 |
| Protocol version | `2024-11-05` |
| Server name | `testmu-browser-agent` |
| Server version | `1.0.0` |
| Logs | Sent to stderr (does not interfere with protocol) |

### Supported JSON-RPC methods

| Method | Description |
|--------|-------------|
| `initialize` | Handshake; returns protocol version, server info, and capabilities |
| `notifications/initialized` | Client acknowledgement (no response sent) |
| `tools/list` | Returns the full list of 10 tool definitions |
| `tools/call` | Executes a tool by name with the provided arguments |

### Example `initialize` exchange

Request:
```json
{ "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {} }
```

Response:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "protocolVersion": "2024-11-05",
    "serverInfo": { "name": "testmu-browser-agent", "version": "1.0.0" },
    "capabilities": { "tools": {} }
  }
}
```

### Example `tools/call` exchange

Request:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "browser_navigate",
    "arguments": { "action": "open", "url": "https://example.com" }
  }
}
```

Response:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "content": [{ "type": "text", "text": "{\"success\":true}" }]
  }
}
```

---

## See Also

- [Quick Start](./quick-start.md)
- [LambdaTest Integration](./lambdatest.md)
- [Commands Reference](./commands.md)
