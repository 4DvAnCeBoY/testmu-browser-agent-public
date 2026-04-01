# testmu-browser-agent-public — Copilot Instructions

testmu-browser-agent-public is an AI-native browser automation CLI and MCP server. Use it for browser automation, web testing, scraping, form filling, screenshots, and authenticated session workflows.

## When to Use

- Navigating websites and extracting data
- Filling and submitting forms
- Visual testing (screenshots, PDFs)
- End-to-end test automation
- Authenticated sessions (login once, reuse state)

## Core Workflow

```sh
# 1. Open the target page
testmu-browser-agent open https://example.com

# 2. Snapshot to get @ref IDs for interactive elements
testmu-browser-agent snapshot
# → [ref=e1] textbox "Search"
# → [ref=e2] button "Go"

# 3. Act on elements by @ref
testmu-browser-agent fill @e1 "query"
testmu-browser-agent click @e2

# 4. Wait for dynamic content
testmu-browser-agent wait --selector ".results" --timeout 15000

# 5. Verify and capture
testmu-browser-agent snapshot
testmu-browser-agent screenshot --output result.png
testmu-browser-agent close
```

> Always snapshot before acting. Refs are only valid for the current page load — re-snapshot after any navigation.

## Key CLI Commands

| Command | Description |
|---|---|
| `open <url>` | Open URL in browser |
| `snapshot` | Accessibility tree with @ref IDs |
| `fill <selector> <text>` | Fill input field |
| `click <selector>` | Click element |
| `select <selector> <value>` | Select dropdown option |
| `check <selector>` | Check checkbox |
| `wait --selector <sel>` | Wait for element |
| `wait --url <pattern>` | Wait for URL change |
| `wait --text <text>` | Wait for visible text |
| `screenshot --output <file>` | Take screenshot |
| `pdf <file>` | Save page as PDF |
| `eval <js>` | Run JavaScript, return result |
| `get text <selector>` | Extract text content |
| `get title` | Get page title |
| `get url` | Get current URL |
| `navigate <url>` | Navigate without new session |
| `back` / `forward` / `reload` | Browser history controls |
| `state save --name <n>` | Save authenticated session |
| `state load --name <n>` | Restore saved session |
| `route <pattern> --abort` | Block network requests |
| `route <pattern> --body <json>` | Mock API response |
| `tabs` | List open tabs |
| `tab new` | Open new tab |
| `tab <n>` | Switch to tab by index |
| `errors` | Show JavaScript console errors |
| `close` | Close browser session |

## MCP Tools (when MCP is configured)

Add `plugins/copilot/mcp.json` contents to `.vscode/mcp.json` to enable direct tool calls:

| Tool | Purpose |
|---|---|
| `browser_navigate` | open, navigate, back, forward, reload, close |
| `browser_interact` | click, dblclick, fill, type, press, select, scroll, hover, tap, drag, upload, focus, check, uncheck, swipe, mousedown, mouseup, setvalue, scrollintoview, multiselect, selectall, clear |
| `browser_query` | snapshot, get, find, eval, inspect |
| `browser_media` | screenshot, pdf, record (start/stop) |
| `browser_state` | cookies_get/set/clear/delete, state_save/load/list/clean/delete, storage, clipboard |
| `browser_tabs` | tabs, tab, window, frame |
| `browser_wait` | wait by selector, url, text, load, function, download, or timeout (no action field) |
| `browser_config` | set, connect, vision_deficiency, cpu_throttle, bypass_csp, media_emulate, touch_emulation |
| `browser_network` | console, errors, dialog, highlight, stream_enable/disable/status, requests, request_detail, har_start/stop |
| `browser_devtools` | trace, profiler, batch, performance_metrics, ax_query, browser_logs, frame_tree, dom_snapshot, webauthn |

## Best Practices

- Snapshot before every interaction — refs reset on navigation
- Use `--selector`, `--url`, or `--text` waits instead of fixed timeouts
- Use `@ref` IDs from snapshot rather than CSS selectors when possible
- Save state after login: `state save --name session`; load in future runs to skip login
- Pass `--headless` in CI pipelines
- Use `--output json` for machine-readable output in scripts
- Run `errors` after complex interactions to catch JavaScript exceptions
