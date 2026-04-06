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
