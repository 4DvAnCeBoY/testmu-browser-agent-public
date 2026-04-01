# testmu-browser-agent as MCP Server in Claude Code

This guide shows how to set up testmu-browser-agent as an MCP (Model Context Protocol) server so Claude Code can control a browser directly during your sessions.

## Prerequisites

- Claude Code installed
- testmu-browser-agent binary installed

## 1. Install the Binary

Download and install the latest release:

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

Or place the binary manually somewhere on your `PATH`:

```sh
mv testmu-browser-agent /usr/local/bin/
chmod +x /usr/local/bin/testmu-browser-agent
```

Verify the install:

```sh
testmu-browser-agent --help
```

## 2. Add the MCP Server to Claude Code

Copy `claude-code-settings.json` from this directory into your Claude Code config, or merge the `mcpServers` block into your existing `~/.claude/settings.json`:

```sh
cp claude-code-settings.json ~/.claude/settings.json
```

If you already have a `settings.json`, merge the `mcpServers` section manually. See `claude-code-settings.json` for the exact block.

## 3. Restart Claude Code

Close and reopen Claude Code (or run `/reload` in the CLI) so it picks up the new MCP server configuration.

## 4. Verify

In a new Claude Code session, ask:

> "Open https://example.com and take a screenshot"

Claude will use the `testmu-browser-agent` MCP tools to open the page and return a screenshot.

## Troubleshooting

- Make sure `testmu-browser-agent` is on your `PATH` — Claude Code spawns it as a subprocess.
- Run `testmu-browser-agent mcp` directly in a terminal to confirm it starts without errors.
- Check Claude Code logs (`~/.claude/logs/`) for MCP connection errors.
