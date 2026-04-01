# Skills & MCP Installation Guide

Install testmu-browser-agent as a skill or MCP server in your AI coding assistant.

**Supports 9 AI coding tools:** Claude Code, Cursor, GitHub Copilot, Windsurf, Gemini CLI, OpenAI Codex, Goose, OpenCode, Cline

## Quick Setup (Auto-Installer)

The installer auto-detects your tools and configures them all:

```bash
./scripts/install-plugins.sh
```

Options: `--yes` (non-interactive), `--lambdatest` (enable cloud), `--tool cursor` (single tool).

## Prerequisites

Install the binary first:

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

Or download from [GitHub Releases](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/releases).

## Plugin Packages

Ready-to-use config files for each tool are in [`plugins/`](../plugins/):

| Tool | Directory | Contents |
|------|-----------|----------|
| Claude Code | [`plugins/claude-code/`](../plugins/claude-code/) | MCP settings, CLAUDE.md, LambdaTest variant |
| Cursor | [`plugins/cursor/`](../plugins/cursor/) | MCP config, rules file, LambdaTest variant |
| GitHub Copilot | [`plugins/copilot/`](../plugins/copilot/) | VS Code MCP, copilot-instructions.md |
| Windsurf | [`plugins/windsurf/`](../plugins/windsurf/) | MCP config, rules file, LambdaTest variant |
| Gemini CLI | [`plugins/gemini-cli/`](../plugins/gemini-cli/) | MCP settings, enhanced GEMINI.md |
| OpenAI Codex | [`plugins/codex/`](../plugins/codex/) | MCP config, codex.json, AGENTS.md |
| Goose | [`plugins/goose/`](../plugins/goose/) | YAML config, LambdaTest variant |
| OpenCode | [`plugins/opencode/`](../plugins/opencode/) | MCP config, LambdaTest variant |
| Cline | [`plugins/cline/`](../plugins/cline/) | MCP settings, LambdaTest variant |

Each directory has a README with step-by-step instructions.

---

## Claude Code

### Option A: One-liner setup (recommended)

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
```

This installs the binary, registers the MCP server in `~/.claude/settings.json`, and copies the skill to `.claude/skills/testmu-browser-agent/` in your current project.

### Option B: Manual MCP Setup

Add to your project or user settings (`.claude/settings.json` or `~/.claude/settings.json`):

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

With LambdaTest cloud:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "lambdatest"],
      "env": {
        "LT_USERNAME": "your-username",
        "LT_ACCESS_KEY": "your-access-key"
      }
    }
  }
}
```

### Option C: Manual Skill Copy

```bash
mkdir -p .claude/skills
cp -r skills/testmu-browser-agent .claude/skills/
```

Restart Claude Code after any of the above.

---

## Cursor

### MCP Server

Open Cursor Settings > MCP Servers > Add Server:

- **Name:** `testmu-browser-agent`
- **Command:** `testmu-browser-agent`
- **Arguments:** `mcp`

Or add to `.cursor/mcp.json` in your project:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### Skill (Rules)

Copy the skill into Cursor rules:

```bash
mkdir -p .cursor/rules
cp skills/testmu-browser-agent/SKILL.md .cursor/rules/testmu-browser-agent.md
```

---

## Windsurf

### MCP Server

Add to `~/.codeium/windsurf/mcp_config.json`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### Skill (Rules)

```bash
mkdir -p .windsurf/rules
cp skills/testmu-browser-agent/SKILL.md .windsurf/rules/testmu-browser-agent.md
```

Restart Windsurf after setup.

---

## Gemini CLI

### Project Instructions

The `GEMINI.md` file at the project root is automatically loaded by Gemini CLI. No extra setup needed if you're working inside this repository.

For other projects, copy it:

```bash
cp GEMINI.md /path/to/your/project/GEMINI.md
```

### MCP Server

Add to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

---

## OpenAI Codex CLI

### Project Instructions

The `codex.json` and `AGENTS.md` files at the project root are automatically loaded by Codex CLI. No extra setup needed inside this repository.

For other projects:

```bash
cp codex.json /path/to/your/project/
cp AGENTS.md /path/to/your/project/
```

### MCP Server

Add to `~/.codex/config.json`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

---

## GitHub Copilot

### MCP Server (VS Code)

Add to `.vscode/mcp.json`:

```json
{
  "servers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### Skill (Instructions)

```bash
mkdir -p .github
cp skills/testmu-browser-agent/SKILL.md .github/copilot-instructions.md
```

---

## Goose

### MCP Server

Add to `~/.config/goose/config.yaml`:

```yaml
mcp_servers:
  testmu-browser-agent:
    command: testmu-browser-agent
    args:
      - mcp
```

---

## OpenCode

### MCP Server

Add to `~/.opencode/config.json`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

---

## Cline (VS Code)

### MCP Server

Add to Cline MCP settings (`~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`):

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "disabled": false
    }
  }
}
```

---

## LambdaTest Cloud (All Vendors)

For any vendor above, add LambdaTest support by:

1. Setting environment variables:

```bash
export LT_USERNAME="your-username"
export LT_ACCESS_KEY="your-access-key"
```

2. Changing the MCP args from `["mcp"]` to `["mcp", "--provider", "lambdatest"]`

3. Or passing env in the MCP config:

```json
{
  "command": "testmu-browser-agent",
  "args": ["mcp", "--provider", "lambdatest"],
  "env": {
    "LT_USERNAME": "your-username",
    "LT_ACCESS_KEY": "your-access-key"
  }
}
```

---

## Verify Installation

After setup, ask your AI assistant:

> Navigate to https://example.com and take a screenshot

If configured correctly, it will use the `browser_navigate` and `browser_media` MCP tools to open the page and capture a screenshot.

## Available MCP Tools

| Tool | Description |
|------|-------------|
| `browser_navigate` | open, navigate, back, forward, reload, close |
| `browser_interact` | click, dblclick, fill, type, press, select, scroll, hover, tap, drag, upload, focus, check, uncheck, swipe |
| `browser_query` | snapshot, get, find, eval, inspect |
| `browser_media` | screenshot, pdf, record |
| `browser_state` | cookies, storage, clipboard, session save/load |
| `browser_tabs` | list, new, close, switch tabs/windows/frames |
| `browser_wait` | wait for element, URL, text, or timeout |
| `browser_config` | viewport, user-agent, connection |
| `browser_network` | console, errors, dialog, highlight, stream |
| `browser_devtools` | trace, profiler, batch |

## Skill Files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill guide for AI agents |
| `references/commands.md` | Full CLI command reference |
| `references/snapshot-refs.md` | @ref ID system deep dive |
| `references/session-management.md` | State persistence and encryption |
| `references/mcp-tools.md` | MCP tool schemas and examples |
| `templates/form-automation.sh` | Form filling template |
| `templates/authenticated-session.sh` | Login + session save template |
| `templates/capture-workflow.sh` | Screenshot + data extraction template |
