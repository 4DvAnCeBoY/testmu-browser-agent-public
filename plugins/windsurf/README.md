# testmu-browser-agent — Windsurf Plugin

Integrates testmu-browser-agent with Windsurf via MCP (direct tool calls) or rules (AI code generation guidance).

---

## Option 1: MCP Server

Gives Windsurf's AI direct tool-call access to the browser via 10 structured MCP tools.

### Prerequisites

```sh
# Verify the CLI is installed
testmu-browser-agent --version
```

### Install

Merge the server entry into `~/.codeium/windsurf/mcp_config.json`:

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

Or copy the provided config (creates the file if it does not exist):

```sh
mkdir -p ~/.codeium/windsurf
cp plugins/windsurf/mcp_config.json ~/.codeium/windsurf/mcp_config.json
```

### LambdaTest Cloud Variant

For cloud browsers via LambdaTest, use `mcp_config-lambdatest.json`:

```sh
cp plugins/windsurf/mcp_config-lambdatest.json ~/.codeium/windsurf/mcp_config.json
```

Set credentials before starting Windsurf:

```sh
export LT_USERNAME=your-username
export LT_ACCESS_KEY=your-access-key
```

### Verify

1. Restart Windsurf after editing the config
2. Open the AI panel (Cascade)
3. Ask: `Use testmu-browser-agent to open https://example.com and take a screenshot`
4. Cascade should invoke `browser_navigate` and `browser_media` tools directly

---

## Option 2: Rules File

Teaches Windsurf's AI how to generate testmu-browser-agent code — no MCP required.

### Install

Copy the rules file into your project:

```sh
mkdir -p .windsurf/rules
cp plugins/windsurf/rules/testmu-browser-agent.md .windsurf/rules/testmu-browser-agent.md
```

Windsurf reads `.windsurf/rules/` automatically and applies rules to all Cascade AI responses in the project.

### Verify

1. Open Cascade in Windsurf
2. Ask: `Write a script to log into the-internet.herokuapp.com and save the session`
3. Cascade should generate `testmu-browser-agent` CLI commands using the snapshot → @ref → verify workflow

---

## Both Options Together

MCP enables direct tool-call automation; rules enable guided code generation. Install both for the best experience.

---

## File Reference

| File | Purpose |
|---|---|
| `mcp_config.json` | Windsurf MCP config (local Chrome) |
| `mcp_config-lambdatest.json` | Windsurf MCP config (LambdaTest cloud) |
| `rules/testmu-browser-agent.md` | Windsurf rules for `.windsurf/rules/` |
