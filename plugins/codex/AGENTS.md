# AGENTS.md

Instructions for AI coding agents working with this codebase.

## Language & Build

This is a Go project (Go 1.23+). Use `make` for all build operations:

- `make build` — build to `bin/testmu-browser-agent`
- `make test` — run unit tests
- `make test-e2e` — run end-to-end tests (requires Chrome)
- `make test-lambdatest` — run cloud tests (requires LT_USERNAME + LT_ACCESS_KEY)
- `make lint` — run golangci-lint
- `make build-all` — cross-compile for macOS, Linux, Windows

## Code Style

- Do not use emojis in code, output, or documentation
- CLI flags use kebab-case in help text but Go struct fields use CamelCase
- Follow existing patterns in the codebase
- All CLI commands are registered in `internal/cli/commands.go`
- Output formatting (text/json/compact) is in `internal/cli/output.go`

## Architecture

The browser automation daemon lives in `internal/`. Key packages:

| Package | Responsibility |
|---------|---------------|
| `cmd/testmu-browser-agent/` | CLI entry point (cobra) |
| `internal/cli/` | Command definitions and flags |
| `internal/action/` | Browser action executor |
| `internal/mcp/` | MCP JSON-RPC server |
| `internal/snapshot/` | Accessibility tree with @ref IDs |
| `internal/provider/` | Browser providers (local, lambdatest, appium) |
| `internal/daemon/` | HTTP server, Unix socket, middleware |
| `internal/state/` | Session persistence, AES-256-GCM encryption |
| `internal/network/` | Network monitoring, domain filtering |
| `internal/policy/` | Action allow/deny engine |
| `internal/stream/` | Server-Sent Events |
| `internal/auth/` | Encrypted credential vault (auth save/login/list/delete/show) |
| `internal/intercept/` | Network interception via CDP Fetch (route/unroute) |
| `internal/browser/` | Chrome for Testing auto-install |
| `internal/selfupdate/` | CLI self-upgrade from GitHub releases |
| `internal/e2e/` | End-to-end test suite with local test server |

## Documentation

When adding or changing user-facing features, update:

1. `internal/cli/commands.go` — CLI command definition
2. `internal/mcp/tools.go` — MCP tool definitions (if applicable)
3. `README.md` — feature sections and examples
4. `skills/testmu-browser-agent/SKILL.md` — so AI agents know about the feature
5. `docs/guides/commands.md` — command reference

## Testing

### Unit Tests
```bash
make test
```
Runs all unit tests. Fast, no Chrome required.

### E2E Tests
```bash
make test-e2e
```
Requires Chrome installed locally.

### LambdaTest Tests
```bash
export LT_USERNAME="..."
export LT_ACCESS_KEY="..."
make test-lambdatest
```

## MCP Server

The MCP server (`internal/mcp/`) uses stdio JSON-RPC 2.0. Start with:
```bash
testmu-browser-agent mcp
```

10 grouped tools: browser_navigate, browser_interact, browser_query, browser_media, browser_state, browser_tabs, browser_wait, browser_config, browser_network, browser_devtools.

---

## Using testmu-browser-agent for Browser Tasks

### Core Workflow

The standard loop for any browser task: navigate, snapshot, interact, verify.

```bash
# 1. Open the target page
testmu-browser-agent open https://app.example.com

# 2. Snapshot the accessibility tree to get @ref IDs
testmu-browser-agent snapshot
# Output: [ref=e1] textbox "Email" (editable)
#         [ref=e2] textbox "Password" (editable)
#         [ref=e3] button "Sign in"

# 3. Interact using @ref IDs
testmu-browser-agent fill @e1 "user@example.com"
testmu-browser-agent fill @e2 "hunter2"
testmu-browser-agent click @e3

# 4. Wait for navigation or async content
testmu-browser-agent wait --url "/dashboard" --timeout 15000

# 5. Verify by snapshotting again
testmu-browser-agent snapshot

# 6. Capture evidence
testmu-browser-agent screenshot --output result.png
testmu-browser-agent close
```

> Always snapshot before interacting. @ref IDs are only valid for the current page load.

### Key Commands

```bash
testmu-browser-agent open <url>                     # Open page
testmu-browser-agent snapshot                        # Get accessibility tree with @refs
testmu-browser-agent snapshot --output json          # Machine-readable JSON
testmu-browser-agent click @e1                       # Click by ref
testmu-browser-agent fill @e1 "value"               # Fill input by ref
testmu-browser-agent select @e1 "option"            # Select dropdown
testmu-browser-agent check @e1                      # Check checkbox
testmu-browser-agent press Enter                    # Keyboard input
testmu-browser-agent wait --selector ".results"     # Wait for element
testmu-browser-agent wait --url "/done"             # Wait for URL
testmu-browser-agent wait --text "Success"          # Wait for text
testmu-browser-agent screenshot --output page.png   # Screenshot
testmu-browser-agent pdf report.pdf                 # Generate PDF
testmu-browser-agent eval 'document.title'          # Execute JS
testmu-browser-agent get text .article              # Get element text
testmu-browser-agent state save --name session      # Save browser state
testmu-browser-agent state load --name session      # Restore browser state
testmu-browser-agent route "/api/*" --abort         # Block requests
testmu-browser-agent errors                         # JS errors
testmu-browser-agent close                          # Close browser
```

### MCP Tools (10 tools)

| Tool | Purpose |
|------|---------|
| `browser_navigate` | Open URLs, navigate history, close |
| `browser_interact` | Click, fill, type, press, select, scroll, drag, upload |
| `browser_query` | Snapshot, get text/title/url, eval JS, find elements |
| `browser_media` | Screenshot, PDF, video recording |
| `browser_state` | Save/load session, cookies, localStorage |
| `browser_tabs` | List, open, switch, close tabs; iframe context |
| `browser_wait` | Wait for selector, URL, text, or fixed timeout |
| `browser_config` | Viewport, user-agent, geolocation, CDP connect |
| `browser_network` | Console output, JS errors, dialog handling |
| `browser_devtools` | Performance traces, JS profiler, batch execution |

### Best Practices

- **Snapshot before every interaction.** Refs change after navigation.
- **Use condition-based waits.** `--selector`, `--url`, `--text` over fixed sleeps.
- **Save state after login.** Use `state save/load` to avoid re-authenticating each run.
- **Use `--headless` in CI.** Required for automated pipelines without a display.
- **Check errors after complex flows.** Run `testmu-browser-agent errors` to catch JS exceptions.
- **Prefer @ref IDs over CSS selectors.** More stable across page variations.
- **Use `--output json` in scripts.** Structured output is easier to parse programmatically.
