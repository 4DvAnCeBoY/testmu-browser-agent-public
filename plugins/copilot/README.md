# testmu-browser-agent-public — GitHub Copilot Plugin

Integrates testmu-browser-agent-public with GitHub Copilot via MCP (VS Code) or custom instructions (Copilot Chat / Workspace).

---

## Option 1: MCP Server (VS Code Copilot)

Gives Copilot direct tool-call access to the browser via 10 structured MCP tools.

### Prerequisites

```sh
# Verify the CLI is installed
testmu-browser-agent --version
```

### Install

Copy `mcp.json` into your project's `.vscode/` folder:

```sh
mkdir -p .vscode
cp plugins/copilot/mcp.json .vscode/mcp.json
```

Or add the server entry manually to an existing `.vscode/mcp.json`:

```json
{
  "servers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

### LambdaTest Cloud Variant

For cloud browsers via LambdaTest, use `mcp-lambdatest.json` instead:

```sh
cp plugins/copilot/mcp-lambdatest.json .vscode/mcp.json
```

Set your credentials as environment variables before starting VS Code:

```sh
export LT_USERNAME=your-username
export LT_ACCESS_KEY=your-access-key
```

### Verify

1. Open VS Code with the project
2. Open Copilot Chat (Ctrl+Alt+I / Cmd+Option+I)
3. Ask: `@workspace Use testmu-browser-agent-public to open https://example.com and take a screenshot`
4. Copilot should invoke `browser_navigate` and `browser_media` tools directly

---

## Option 2: Custom Instructions (Copilot Chat / Workspace)

Teaches Copilot how to use testmu-browser-agent-public via natural language instructions — no MCP required.

### Install

Copy `copilot-instructions.md` to your project's `.github/` folder:

```sh
mkdir -p .github
cp plugins/copilot/copilot-instructions.md .github/copilot-instructions.md
```

GitHub Copilot reads `.github/copilot-instructions.md` automatically and applies it to all Copilot Chat responses in the repository.

### Verify

1. Open Copilot Chat in VS Code or GitHub Copilot Workspace
2. Ask: `Write a script to scrape book titles from books.toscrape.com`
3. Copilot should generate `testmu-browser-agent-public` CLI commands using the snapshot → @ref → verify workflow

---

## Both Options Together

Use MCP for tool-call automation and custom instructions for code generation guidance — they complement each other. Install both for the best experience.

---

## File Reference

| File | Purpose |
|---|---|
| `mcp.json` | VS Code MCP config (local Chrome) |
| `mcp-lambdatest.json` | VS Code MCP config (LambdaTest cloud) |
| `copilot-instructions.md` | Custom instructions for `.github/copilot-instructions.md` |
