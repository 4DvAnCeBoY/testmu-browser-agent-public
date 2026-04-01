# testmu-browser-agent-public — Cursor Plugin

Browser automation for Cursor via MCP. Drives a real Chrome browser (local or LambdaTest cloud) from within your Cursor AI session.

---

## Installation

### Step 1: Add the MCP Server

**Option A — Cursor Settings UI:**

1. Open Cursor Settings (`Cmd+,` / `Ctrl+,`)
2. Go to **MCP Servers**
3. Add a new server with:
   - Name: `testmu-browser-agent-public`
   - Command: `testmu-browser-agent-public`
   - Args: `mcp`

**Option B — Project config file:**

Create `.cursor/mcp.json` in your project root (or copy `plugins/cursor/mcp.json`):

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### Step 2: Add the Rules File

Copy the rules file into your Cursor rules directory:

```sh
mkdir -p .cursor/rules
cp plugins/cursor/rules/testmu-browser-agent-public.md .cursor/rules/
```

Or add it via Cursor Settings > Rules > Add Rule File.

---

## LambdaTest Cloud Variant

To run against LambdaTest cloud browsers, use `plugins/cursor/mcp-lambdatest.json` and fill in your credentials:

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

After adding the config and restarting Cursor, verify the server is active:

1. Open the Cursor AI chat panel.
2. Ask: "What MCP tools are available for browser automation?"
3. Cursor should list the 10 testmu-browser-agent-public tools.

Or verify the binary is reachable:

```sh
testmu-browser-agent --version
testmu-browser-agent mcp --help
```

---

## Quick Example

Once configured, Cursor's AI can drive the browser:

```
Open https://example.com, snapshot the page, fill the search input with "hello", and take a screenshot.
```

---

## Full Reference

See [`skills/testmu-browser-agent-public/SKILL.md`](../../skills/testmu-browser-agent-public/SKILL.md) for the complete agent guide, or check the condensed rules at `plugins/cursor/rules/testmu-browser-agent-public.md`.
