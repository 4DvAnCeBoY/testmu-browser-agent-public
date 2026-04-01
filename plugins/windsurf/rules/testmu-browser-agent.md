# testmu-browser-agent

AI-native browser automation CLI and MCP server for Chrome. Use for browser automation, web testing, scraping, form filling, screenshots, and authenticated session workflows — local or via LambdaTest cloud.

---

## Core Workflow

Always follow this loop: open → snapshot → act on @refs → wait → verify.

```sh
# 1. Open the target page
testmu-browser-agent open https://example.com

# 2. Snapshot to discover interactive elements and their @ref IDs
testmu-browser-agent snapshot
# → [ref=e1] textbox "Search"
# → [ref=e2] button "Go"

# 3. Interact using @ref IDs
testmu-browser-agent fill @e1 "query"
testmu-browser-agent click @e2

# 4. Wait for dynamic content before reading results
testmu-browser-agent wait --selector ".results" --timeout 15000

# 5. Snapshot again to verify new state
testmu-browser-agent snapshot

# 6. Capture evidence and close
testmu-browser-agent screenshot --output result.png
testmu-browser-agent close
```

> Re-snapshot after every navigation — @ref IDs reset on page load.

---

## Key Commands

| Command | Description |
|---|---|
| `open <url>` | Open URL in browser |
| `snapshot` | Accessibility tree with @ref IDs |
| `fill <selector> <text>` | Fill input field |
| `click <selector>` | Click element |
| `select <selector> <value>` | Select dropdown option |
| `check <selector>` | Check/uncheck checkbox |
| `wait --selector <sel>` | Wait for element to appear |
| `wait --url <pattern>` | Wait for URL change |
| `wait --text <text>` | Wait for visible text |
| `screenshot --output <file>` | Take screenshot (PNG/JPEG) |
| `pdf <file>` | Save page as PDF |
| `eval <js>` | Execute JavaScript, return result |
| `get text <selector>` | Extract text content |
| `get title` / `get url` | Page title or current URL |
| `navigate <url>` | Navigate within session |
| `back` / `forward` / `reload` | History controls |
| `state save --name <n>` | Save browser session (cookies, storage) |
| `state load --name <n>` | Restore saved session |
| `route <pattern> --abort` | Block network requests |
| `route <pattern> --body <json>` | Mock API response |
| `tabs` | List open tabs |
| `tab new` / `tab <n>` | Open or switch tabs |
| `frame <selector>` | Focus iframe context |
| `highlight <selector>` | Highlight element |
| `errors` | Show JS console errors |
| `diff snapshot` | Diff accessibility tree vs last snapshot |
| `close` | Close browser |

---

## MCP Tools

When MCP is configured (`~/.codeium/windsurf/mcp_config.json`), Cascade can call these tools directly:

| Tool | Actions |
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

---

## Best Practices

- Snapshot before every interaction — refs are invalid after navigation
- Prefer `--selector`/`--url`/`--text` waits over fixed `--timeout` sleeps
- Use `@ref` IDs from snapshot rather than fragile CSS selectors
- Save state after login once: `state save --name session`; load in subsequent runs
- Pass `--headless` in CI/CD pipelines
- Use `--output json` for machine-readable output in scripts
- Run `errors` after complex interactions to surface JavaScript exceptions
- Use `route` to mock APIs or block slow resources during testing
