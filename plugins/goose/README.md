# testmu-browser-agent-public — Goose Plugin

Adds browser automation to Block's Goose AI agent via `testmu-browser-agent-public`.

## Prerequisites

- `testmu-browser-agent-public` installed and on your PATH
- Chrome (local) or LambdaTest credentials (cloud)

```bash
# Verify installation
testmu-browser-agent --version
```

---

## Installation

### MCP Server

Add the MCP server to Goose's config file at `~/.config/goose/config.yaml`.

```bash
mkdir -p ~/.config/goose
```

Merge the following into `~/.config/goose/config.yaml`:

```yaml
mcp_servers:
  testmu-browser-agent-public:
    command: testmu-browser-agent
    args:
      - mcp
```

Or copy the provided config:

```bash
cp plugins/goose/config.yaml ~/.config/goose/config.yaml
```

For LambdaTest cloud browsers:

```bash
cp plugins/goose/config-lambdatest.yaml ~/.config/goose/config.yaml
```

Then set your credentials:

```bash
export LT_USERNAME="your-username"
export LT_ACCESS_KEY="your-access-key"
```

---

## Verification

```bash
# Confirm the MCP server starts
testmu-browser-agent mcp

# Start Goose and confirm it sees the browser tools
goose session
# Goose will list available MCP tools on startup
```

You should see `browser_navigate`, `browser_interact`, `browser_query`, and the other 7 tools in the tool list.

---

## Quick Usage

Once installed, Goose can perform browser tasks via natural language:

```
"Open https://example.com and take a screenshot"
"Fill out and submit the form at https://httpbin.org/forms/post"
"Scrape the top 10 books from https://books.toscrape.com as a JSON list"
"Log in to https://the-internet.herokuapp.com/login and verify the secure page loads"
```

---

## Files in This Directory

| File | Purpose |
|------|---------|
| `config.yaml` | Goose MCP config for local Chrome |
| `config-lambdatest.yaml` | Goose MCP config for LambdaTest cloud |
| `README.md` | This file |
