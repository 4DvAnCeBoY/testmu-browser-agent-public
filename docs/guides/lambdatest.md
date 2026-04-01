# LambdaTest Integration

`testmu-browser-agent-public` can run browser sessions on [LambdaTest](https://www.lambdatest.com/) cloud infrastructure instead of a local browser. This enables parallel test execution, cross-browser testing, and CI/CD pipelines without managing local browser installations.

---

## Prerequisites

- A LambdaTest account ([sign up free](https://accounts.lambdatest.com/register))
- Your **Username** and **Access Key** from the [LambdaTest Automation Dashboard](https://automation.lambdatest.com/)

---

## Configuration

### Environment variables

Export your credentials before running any command:

```sh
export LT_USERNAME="your-lt-username"
export LT_ACCESS_KEY="your-lt-access-key"
```

These variables are required whenever `--provider lambdatest` is used. The agent will exit with an error if either is missing.

You can also store them in your shell profile (`~/.zshrc`, `~/.bashrc`) or a `.env` file loaded by your CI system.

---

## CLI Usage

Add `--provider lambdatest` to any command:

```sh
# Open a URL on a LambdaTest cloud browser
testmu-browser-agent --provider lambdatest open https://example.com

# Take a snapshot
testmu-browser-agent --provider lambdatest snapshot

# Take a screenshot
testmu-browser-agent --provider lambdatest screenshot --output result.png

# Run a full session
testmu-browser-agent --provider lambdatest open https://app.example.com
testmu-browser-agent --provider lambdatest snapshot
testmu-browser-agent --provider lambdatest fill @e1 "user@example.com"
testmu-browser-agent --provider lambdatest click @e2
testmu-browser-agent --provider lambdatest screenshot --output dashboard.png
testmu-browser-agent --provider lambdatest close
```

The `--provider` flag is a global flag and can be combined with any other global flags:

```sh
testmu-browser-agent --provider lambdatest --output json open https://example.com
```

---

## MCP Server with LambdaTest

To use LambdaTest as the browser backend when running as an MCP server for Claude Code, pass the provider flag in your MCP server configuration. See [mcp-integration.md](./mcp-integration.md) for the full `settings.json` example.

Quick reference:

```json
{
  "mcpServers": {
    "testmu-browser-agent-public": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--provider", "lambdatest"],
      "env": {
        "LT_USERNAME": "your-lt-username",
        "LT_ACCESS_KEY": "your-lt-access-key"
      }
    }
  }
}
```

---

## Daemon Mode with LambdaTest

You can start the HTTP daemon backed by LambdaTest:

```sh
export LT_USERNAME="your-lt-username"
export LT_ACCESS_KEY="your-lt-access-key"

testmu-browser-agent --provider lambdatest serve
```

This starts the daemon on the default port (9222) and all connected sessions will use LambdaTest cloud browsers. The daemon supports the same `--port` and `--socket` flags as the local variant.

---

## Local vs Cloud Comparison

| Feature | Local | LambdaTest Cloud |
|---------|-------|-----------------|
| **Setup** | Install binary only | Binary + `LT_USERNAME`/`LT_ACCESS_KEY` credentials |
| **Session speed** | Fast (sub-second launch) | Slightly higher latency (cloud spin-up) |
| **Parallelism** | Limited by local CPU/RAM | High concurrency available |
| **CI/CD** | Requires browser installed in CI | No browser installation needed |
| **Debugging** | Local DevTools, screenshots | LambdaTest session recordings, logs, and video |
| **Cost** | Free (uses local resources) | Billed by LambdaTest session minutes |

---

## Troubleshooting

### `LT_USERNAME and LT_ACCESS_KEY must be set for lambdatest provider`

You passed `--provider lambdatest` but the environment variables are not set. Export them before running:

```sh
export LT_USERNAME="your-lt-username"
export LT_ACCESS_KEY="your-lt-access-key"
```

### `connect browser: failed to connect to LambdaTest`

- Verify your credentials are correct in the [LambdaTest Automation Dashboard](https://automation.lambdatest.com/)
- Check that your LambdaTest plan has available parallel session capacity
- Confirm outbound HTTPS access to `*.lambdatest.com` is not blocked by a firewall

### Session hangs or times out

- LambdaTest sessions have a maximum idle timeout. Ensure you are sending actions regularly or call `close` when finished
- Use `testmu-browser-agent --provider lambdatest --timeout 60 <command>` to increase the per-command timeout

### `Error: Unsupported OS` during install

Windows users: download `testmu-browser-agent-public-windows-amd64.exe` manually from the releases page. The install script only supports macOS and Linux.

---

## See Also

- [Quick Start](./quick-start.md)
- [MCP Integration](./mcp-integration.md)
- [Commands Reference](./commands.md)
