# testmu-browser-agent-public — Cline Plugin

Integrates testmu-browser-agent-public with [Cline](https://github.com/saoudrizwan/claude-dev) (VS Code extension) as an MCP server, giving Cline direct access to browser automation tools.

## Prerequisites

- `testmu-browser-agent-public` installed and on your `PATH`
  ```sh
  curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh
  ```
- Cline extension installed in VS Code (`saoudrizwan.claude-dev`)

## MCP Settings File Location

Cline stores MCP server configuration in a per-platform path:

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` |
| Linux | `~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json` |
| Windows | `%APPDATA%\Code\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json` |

## Installation

### Option 1: Automatic (recommended)

Run the universal plugin installer from the project root:

```sh
./scripts/install-plugins.sh --tool cline
```

### Option 2: Manual

1. Locate the settings file for your platform (see table above).

2. If the file does not exist, create it with the contents of `mcp_settings.json`:

   ```json
   {
     "mcpServers": {
       "testmu-browser-agent-public": {
         "command": "testmu-browser-agent",
         "args": ["mcp"],
         "disabled": false
       }
     }
   }
   ```

3. If the file already exists and contains other MCP servers, add only the `"testmu-browser-agent-public"` entry inside the existing `mcpServers` object — do not replace the whole file.

4. Reload VS Code (or use **Developer: Reload Window** from the command palette). Cline picks up changes automatically on most versions; a reload ensures they take effect.

### LambdaTest cloud variant

To run browser sessions on LambdaTest cloud instead of a local Chrome, use `mcp_settings-lambdatest.json` and supply your credentials:

```sh
export LT_USERNAME="your-username"
export LT_ACCESS_KEY="your-access-key"
```

Then merge the contents of `mcp_settings-lambdatest.json` into the Cline settings file.

## Verification

After reloading VS Code, open a Cline chat and ask:

```
List available MCP tools
```

You should see the 10 tools: `browser_navigate`, `browser_interact`, `browser_query`, `browser_media`, `browser_state`, `browser_tabs`, `browser_wait`, `browser_config`, `browser_network`, `browser_devtools`.

Alternatively, verify the binary is reachable:

```sh
testmu-browser-agent --version
testmu-browser-agent mcp --help
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `command not found: testmu-browser-agent-public` | Re-run the install script or add `/usr/local/bin` to `PATH` |
| MCP tools not listed in Cline | Check JSON syntax with `jq . "<settings-file-path>"` |
| `disabled: true` in settings | Set `"disabled": false` in the `mcpServers` entry |
| Browser does not open | Ensure Chrome is installed; run `testmu-browser-agent open https://example.com` directly to test |
| LambdaTest sessions fail | Verify `LT_USERNAME` and `LT_ACCESS_KEY` are exported in the environment VS Code was launched from |
