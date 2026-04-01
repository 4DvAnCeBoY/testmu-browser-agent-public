# testmu-browser-agent-public

AI-native browser automation for Chrome. Use when asked to navigate websites, fill forms, extract data, take screenshots, or test web UIs. Drives a real browser via CLI or MCP server. Local Chrome and LambdaTest cloud are both supported.

---

## Core Workflow

Every task follows this loop:

```
open URL -> snapshot -> act on @ref -> re-snapshot -> verify
```

1. `open <url>` — navigate to the page
2. `snapshot` — read the accessibility tree; note the `@ref` IDs
3. act using `@ref` IDs: `fill`, `click`, `select`, `check`
4. wait for async content if needed, then re-snapshot to confirm

After any navigation or page transition, always re-snapshot before acting. Refs are only valid for the current page load.

---

## CLI Quick Reference

| Command | Description |
|---|---|
| `open <url>` | Open a URL in the browser |
| `snapshot` | Print accessibility tree with @ref IDs |
| `fill <ref\|selector> <text>` | Type text into an input |
| `click <ref\|selector>` | Click an element |
| `select <ref\|selector> <value>` | Choose a select option |
| `check <ref\|selector>` | Toggle a checkbox |
| `screenshot --output <file>` | Capture full-page screenshot |
| `pdf <file>` | Save page as PDF |
| `wait --selector <css>` | Wait for element to appear |
| `wait --url <pattern>` | Wait for URL to match |
| `wait --text <string>` | Wait for text to appear |
| `eval <js>` | Execute JavaScript and return result |
| `get text <selector>` | Extract text from element |
| `get title` | Get page title |
| `get url` | Get current URL |
| `navigate <url>` | Navigate without opening new session |
| `state save --name <n>` | Save browser session (cookies, storage) |
| `state load --name <n>` | Restore a saved session |
| `route <pattern> --abort` | Block matching network requests |
| `route <pattern> --body <json>` | Mock an API response |
| `tabs` | List open tabs |
| `tab new` | Open a new tab |
| `tab <n>` | Switch to tab by index |
| `frame <selector>` | Focus an iframe for subsequent actions |
| `highlight <ref>` | Highlight element before screenshot |
| `diff snapshot` | Diff accessibility tree vs last snapshot |
| `errors` | Print browser console errors |
| `close` | Close the browser session |

---

## MCP Tools

When using MCP mode (`testmu-browser-agent mcp`), these 10 tools are available:

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

---

## Best Practices

- Use `@ref` IDs from snapshot output — do not guess CSS selectors
- Re-snapshot after every navigation before acting
- Prefer `--selector` / `--url` / `--text` waits over fixed `--timeout` sleeps
- After login, call `state save --name <session>` to persist authentication
- Use `--headless` in CI or automated pipelines
- Run `errors` after complex interactions to catch JavaScript exceptions
- Use `--output json` for machine-readable snapshot output in scripts
- For sensitive sessions, use `--storage-key $MY_KEY` to encrypt state

---

## Common Patterns

**Form filling:**
```sh
testmu-browser-agent open https://example.com/form
testmu-browser-agent snapshot
testmu-browser-agent fill @e1 "Jane Doe"
testmu-browser-agent fill @e2 "jane@example.com"
testmu-browser-agent click @e7
testmu-browser-agent wait --url "/confirmation"
testmu-browser-agent snapshot
```

**Authenticated session:**
```sh
# Login once
testmu-browser-agent open https://example.com/login
testmu-browser-agent fill '#username' "user"
testmu-browser-agent fill '#password' "pass"
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent state save --name my-session
testmu-browser-agent close

# Subsequent runs
testmu-browser-agent open https://example.com
testmu-browser-agent state load --name my-session
```

**Data extraction:**
```sh
testmu-browser-agent open https://example.com/list
testmu-browser-agent eval 'JSON.stringify(Array.from(document.querySelectorAll("li")).map(el => el.textContent.trim()))'
```

---

## Full Reference

See `skills/testmu-browser-agent-public/SKILL.md` for complete documentation including network interception, device emulation, multi-tab workflows, auth vault, downloads, and diff snapshots.
