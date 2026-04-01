# testmu-browser-agent — Claude Code Plugin

Browser automation for Claude Code. Drives a real Chrome browser (local or LambdaTest cloud) from within your Claude Code session. Supports two integration modes: a **Skill** (CLI via Bash, no server needed) and an **MCP server** (structured JSON tool calls).

---

## Option A: Skill (recommended, simpler)

The skill integration works like agent-browser — Claude calls the `testmu-browser-agent` CLI directly via `Bash(testmu-browser-agent:*)`. No separate MCP server setup required (the CLI manages its own browser daemon internally).

### Install

**Step 1: Install the binary**

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

**Step 2: Install the skill**

```sh
mkdir -p .claude/skills/testmu-browser-agent
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/skills/testmu-browser-agent/SKILL.md \
  -o .claude/skills/testmu-browser-agent/SKILL.md
```

**Or use the setup script (installs both at once):**

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
```

Restart Claude Code after running.

### How it works

Claude reads the skill's `allowed-tools: Bash(testmu-browser-agent:*)` declaration and calls the CLI directly:

```
Open https://example.com and take a screenshot
```

Claude will run `testmu-browser-agent open`, `testmu-browser-agent snapshot`, `testmu-browser-agent screenshot` — no MCP handshake needed.

---

## Option B: MCP Server (structured tool calls)

The MCP integration exposes 10 structured tools that Claude calls as JSON. Useful for programmatic workflows where you want typed tool schemas and JSON responses.

### Install

Add the MCP server to your Claude Code settings. Choose **one** of:

**Global** (`~/.claude/settings.json`) — available in all projects:

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

**Project-level** (`.claude/settings.json` in your repo) — scoped to this project:

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

Restart Claude Code after adding the config.

### LambdaTest Cloud Variant

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
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

### Verification

After adding the config and restarting Claude Code, verify the server is active:

1. Open Claude Code and start a new conversation.
2. Ask: "List the available MCP tools for testmu-browser-agent."
3. Claude should list 10 tools: `browser_navigate`, `browser_interact`, `browser_query`, `browser_media`, `browser_state`, `browser_tabs`, `browser_wait`, `browser_config`, `browser_network`, `browser_devtools`.

---

## When to use which

| | Skill (Option A) | MCP Server (Option B) |
|---|---|---|
| Setup | Binary + SKILL.md file | Binary + settings.json config |
| How Claude calls it | `Bash(testmu-browser-agent:*)` | JSON tool calls |
| Separate server setup | No (CLI manages browser internally) | No (MCP starts on demand) |
| Works in any Claude Code project | Yes (copy SKILL.md) | Yes (global settings) |
| Typed JSON schemas | No | Yes |
| Best for | General use, simplest setup | Programmatic/structured workflows |

---

## Quick Example

Once configured (either option), Claude Code can drive the browser directly:

```
Open https://example.com, take a snapshot, fill the search box with "hello", and screenshot the result.
```

With the skill, Claude runs the CLI commands. With MCP, Claude calls `browser_navigate`, `browser_query`, `browser_interact`, and `browser_media` as structured tool calls.

---

## Full Reference

See [`skills/testmu-browser-agent/SKILL.md`](../../skills/testmu-browser-agent/SKILL.md) for the complete agent guide covering:
- Core workflow (open → snapshot → @ref → verify)
- Common tasks: forms, auth, scraping, device emulation, network interception
- Auth vault and session persistence
- All CLI commands organized by category
- Best practices and templates
