# testmu-browser-agent-public — OpenCode Plugin

Integrates testmu-browser-agent-public with [OpenCode](https://opencode.ai) as an MCP server, giving OpenCode direct access to browser automation tools.

## Prerequisites

- `testmu-browser-agent-public` installed and on your `PATH`
  ```sh
  curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh
  ```

## Installation

### Option 1: Automatic (recommended)

Run the universal plugin installer from the project root:

```sh
./scripts/install-plugins.sh --tool opencode
```

### Option 2: Manual

1. Open (or create) `~/.opencode/config.json`.

2. Merge in the `mcpServers` block from this directory's `config.json`:

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

   If the file already contains other keys or `mcpServers` entries, add only the `"testmu-browser-agent-public"` entry inside the existing `mcpServers` object — do not replace the whole file.

3. Restart OpenCode.

### LambdaTest cloud variant

To run browser sessions on LambdaTest cloud instead of a local Chrome, use `config-lambdatest.json` and supply your credentials:

```sh
export LT_USERNAME="your-username"
export LT_ACCESS_KEY="your-access-key"
```

Then merge the contents of `config-lambdatest.json` into `~/.opencode/config.json`.

## Verification

After restarting OpenCode, ask it:

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
| MCP tools not listed in OpenCode | Check JSON syntax in `~/.opencode/config.json` with `jq . ~/.opencode/config.json` |
| Browser does not open | Ensure Chrome is installed; run `testmu-browser-agent open https://example.com` directly to test |
| LambdaTest sessions fail | Verify `LT_USERNAME` and `LT_ACCESS_KEY` are exported in the same shell OpenCode launches from |
