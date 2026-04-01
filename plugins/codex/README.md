# testmu-browser-agent — OpenAI Codex Plugin

Adds browser automation to OpenAI Codex CLI via `testmu-browser-agent`.

## Prerequisites

- `testmu-browser-agent` installed and on your PATH
- Chrome (local) or LambdaTest credentials (cloud)

```bash
# Verify installation
testmu-browser-agent --version
```

---

## Installation Options

### Option 1: codex.json (Project context)

Copy `codex.json` from this directory to your project root. Codex loads it as project context.

```bash
cp plugins/codex/codex.json /your/project/codex.json
```

### Option 2: AGENTS.md (Agent instructions)

Copy the enhanced `AGENTS.md` to your project root. It adds a "Using testmu-browser-agent" section that guides Codex on browser automation tasks.

```bash
cp plugins/codex/AGENTS.md /your/project/AGENTS.md
```

If your project already has an `AGENTS.md`, append the browser automation section manually from `plugins/codex/AGENTS.md`.

### Option 3: MCP Server (Tool Calls)

Add the MCP server to `~/.codex/config.json` so Codex can call browser tools directly as structured tool invocations.

```bash
mkdir -p ~/.codex
```

Merge the following into `~/.codex/config.json`:

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

Or copy the provided config:

```bash
cp plugins/codex/config.json ~/.codex/config.json
```

---

## Verification

```bash
# Confirm the MCP server starts
testmu-browser-agent mcp

# Run a quick browser task with Codex
codex "Open https://example.com and tell me the page title"
```

---

## Quick Usage

```
"Navigate to https://httpbin.org/forms/post and fill out the pizza order form"
"Take a screenshot of https://example.com and save it to /tmp/example.png"
"Scrape the first 10 product titles from https://books.toscrape.com"
"Login to https://the-internet.herokuapp.com/login with tomsmith / SuperSecretPassword!"
```

---

## Files in This Directory

| File | Purpose |
|------|---------|
| `codex.json` | Enhanced project context — copy to project root |
| `AGENTS.md` | Enhanced agent instructions with browser automation section |
| `config.json` | MCP config for `~/.codex/config.json` |
| `README.md` | This file |
