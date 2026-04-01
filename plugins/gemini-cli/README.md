# testmu-browser-agent — Gemini CLI Plugin

Adds browser automation to Gemini CLI via `testmu-browser-agent`.

## Prerequisites

- `testmu-browser-agent` installed and on your PATH
- Chrome (local) or LambdaTest credentials (cloud)

```bash
# Verify installation
testmu-browser-agent --version
```

---

## Installation Options

### Option 1: GEMINI.md (Recommended)

Copy `GEMINI.md` from this directory to your project root. Gemini CLI automatically loads it as context when you work in that project.

```bash
cp plugins/gemini-cli/GEMINI.md /your/project/GEMINI.md
```

Or copy directly from this repo:

```bash
cp /path/to/testmu-browser-agent/plugins/gemini-cli/GEMINI.md .
```

Gemini will now understand how to use `testmu-browser-agent` for browser tasks in that project.

### Option 2: MCP Server (Tool Calls)

Add the MCP server to `~/.gemini/settings.json` so Gemini can call browser tools directly as structured tool invocations.

```bash
# Create settings directory if it does not exist
mkdir -p ~/.gemini
```

Merge the following into `~/.gemini/settings.json`:

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

Or copy the provided config file:

```bash
cp plugins/gemini-cli/settings.json ~/.gemini/settings.json
```

For LambdaTest cloud browsers, use the cloud variant instead:

```bash
cp plugins/gemini-cli/settings-lambdatest.json ~/.gemini/settings.json
```

Then set your credentials:

```bash
export LT_USERNAME="your-username"
export LT_ACCESS_KEY="your-access-key"
```

---

## Verification

After installation, verify Gemini CLI can reach the MCP server:

```bash
# Start the MCP server manually to confirm it runs
testmu-browser-agent mcp

# In a separate terminal, check Gemini sees the tools
# (Gemini CLI will list available MCP tools on startup)
gemini
```

You should see `browser_navigate`, `browser_interact`, `browser_query`, and the other 7 tools available.

---

## Quick Usage

Once installed, ask Gemini to perform browser tasks naturally:

```
"Open https://example.com, take a screenshot, and tell me the page title"
"Fill out the login form at https://app.example.com with user@test.com"
"Scrape the product list from https://books.toscrape.com as JSON"
```

Gemini will use the MCP tools or CLI commands depending on your installation method.

---

## Files in This Directory

| File | Purpose |
|------|---------|
| `GEMINI.md` | Enhanced context file — copy to your project root |
| `settings.json` | MCP config for local Chrome |
| `settings-lambdatest.json` | MCP config for LambdaTest cloud |
| `README.md` | This file |
