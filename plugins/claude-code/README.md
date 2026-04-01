# testmu-browser-agent-public — Claude Code Plugin

Browser automation for Claude Code via MCP. Drives a real Chrome browser (local or LambdaTest cloud) from within your Claude Code session.

---

## Installation

### One-liner

```sh
npx skills add 4DvAnCeBoY/testmu-browser-agent-public-public
```

### Manual MCP Configuration

Add the MCP server to your Claude Code settings. Choose **one** of:

**Global** (`~/.claude/settings.json`) — available in all projects:

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "env": {}
    }
  }
}
```

**Project-level** (`.claude/settings.json` in your repo) — scoped to this project:

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "env": {}
    }
  }
}
```

You can also copy `plugins/claude-code/settings.json` from this repo directly into `.claude/settings.json`.

---

## LambdaTest Cloud Variant

To run against LambdaTest cloud browsers, use `plugins/claude-code/settings-lambdatest.json` and fill in your credentials:

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "lambdatest"],
      "env": {
        "LT_USERNAME": "your-lambdatest-username",
        "LT_ACCESS_KEY": "your-lambdatest-access-key"
      }
    }
  }
}
```

Get your credentials at [lambdatest.com/capabilities-generator](https://www.lambdatest.com/capabilities-generator/).

---

## Verification

After adding the config and restarting Claude Code, verify the server is active:

1. Open Claude Code and start a new conversation.
2. Ask: "List the available MCP tools for testmu-browser-agent-public."
3. Claude should list 10 tools: `browser_navigate`, `browser_interact`, `browser_query`, `browser_media`, `browser_state`, `browser_tabs`, `browser_wait`, `browser_config`, `browser_network`, `browser_devtools`.

---

## Quick Example

Once configured, Claude Code can drive the browser directly:

```
Open https://example.com, take a snapshot, fill the search box with "hello", and screenshot the result.
```

Claude will call `browser_navigate`, `browser_query`, `browser_interact`, and `browser_media` automatically.

---

## Full Reference

See [`skills/testmu-browser-agent-public/SKILL.md`](../../skills/testmu-browser-agent-public/SKILL.md) for the complete agent guide covering:
- Core workflow (open → snapshot → @ref → verify)
- Common tasks: forms, auth, scraping, device emulation, network interception
- All 10 MCP tools with JSON schemas
- Best practices and templates
