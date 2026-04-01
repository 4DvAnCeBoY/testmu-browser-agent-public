# testmu-browser-agent — Claude Code Instructions

This project has browser automation available via **testmu-browser-agent** (MCP server). Use it whenever you need to navigate websites, interact with UI elements, extract data, or verify web application behavior.

---

## Core Loop

Every browser task follows this pattern:

1. **Open** — navigate to the target URL
2. **Snapshot** — read the accessibility tree to discover interactive elements and their `@ref` IDs
3. **Act** — interact using `@ref` IDs (fill, click, select, check)
4. **Verify** — re-snapshot or screenshot to confirm the outcome

```
open URL -> snapshot -> act on @ref -> re-snapshot -> verify
```

> Always re-snapshot after any navigation. Refs are only valid for the current page load.

---

## Key Rules

- Use `@ref` IDs from snapshot output — do not construct CSS selectors manually
- After every navigation or page transition, call snapshot again before acting
- Prefer condition-based waits (`--selector`, `--url`, `--text`) over fixed timeouts
- In CI or headless contexts, pass `--headless`
- After login, call `state save` so subsequent runs skip re-authentication

---

## MCP Tools Available

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

## Full Reference

See [`skills/testmu-browser-agent/SKILL.md`](../../skills/testmu-browser-agent/SKILL.md) for the complete guide including common task recipes, session management, network interception, device emulation, and all MCP tool schemas.
