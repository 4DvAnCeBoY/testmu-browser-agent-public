# testmu-browser-agent-public

AI-native browser automation CLI and MCP server for Chrome. This repo distributes pre-built binaries — no source code.

## Setup for Claude Code

Two integration options are available:

**Option A: Skill (recommended, simpler)** — Claude calls the CLI directly via `Bash(testmu-browser-agent:*)`, no MCP server needed:

```bash
# Install binary + skill in one step
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
```

Or install separately:

```bash
# 1. Install binary
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh

# 2. Install skill
mkdir -p .claude/skills/testmu-browser-agent
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/skills/testmu-browser-agent/SKILL.md \
  -o .claude/skills/testmu-browser-agent/SKILL.md
```

**Option B: MCP server** — structured JSON tool calls via `~/.claude/settings.json`:

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

Restart Claude Code after setup.

See [`plugins/claude-code/README.md`](plugins/claude-code/README.md) for full installation details and when to use each option.

## Core Workflow

Every browser task follows this loop:

1. **Open** — `testmu-browser-agent open <url>`
2. **Snapshot** — `testmu-browser-agent snapshot` to get `@ref` IDs
3. **Act** — `testmu-browser-agent click/fill/select` using `@ref` IDs
4. **Verify** — re-snapshot or `testmu-browser-agent screenshot`

Always re-snapshot after navigation. Refs are only valid for the current page load.

## MCP Tools (Option B)

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
