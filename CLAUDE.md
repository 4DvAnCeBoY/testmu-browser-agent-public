# testmu-browser-agent-public

AI-native browser automation CLI and MCP server for Chrome. This repo distributes pre-built binaries — no source code.

## Setup for Claude Code

One command to install everything:

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
```

This installs the binary, registers the MCP server in `~/.claude/settings.json`, and downloads skill files to `.claude/skills/`.

Restart Claude Code after running.

## Core Workflow

Every browser task follows this loop:

1. **Open** — `browser_navigate` with action `open`
2. **Snapshot** — `browser_query` with action `snapshot` to get `@ref` IDs
3. **Act** — `browser_interact` using `@ref` IDs (click, fill, select)
4. **Verify** — re-snapshot or `browser_media` screenshot

Always re-snapshot after navigation. Refs are only valid for the current page load.

## MCP Tools

| Tool | Purpose |
|------|---------|
| `browser_navigate` | open, navigate, back, forward, reload, close |
| `browser_interact` | click, fill, type, press, select, scroll, hover, drag, upload, check |
| `browser_query` | snapshot, get, find, eval, inspect |
| `browser_media` | screenshot, pdf, record |
| `browser_state` | cookies, storage, clipboard, session save/load |
| `browser_tabs` | list, create, close, switch tabs/windows/frames |
| `browser_wait` | wait by selector, url, text, load, function, download |
| `browser_config` | viewport, user-agent, geolocation, timezone |
| `browser_network` | console, errors, dialog, HAR, request inspection |
| `browser_devtools` | trace, profiler, batch, performance metrics |

## Full Reference

See `skills/testmu-browser-agent/SKILL.md` for the complete guide.
