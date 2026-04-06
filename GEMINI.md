# GEMINI.md

Instructions for Gemini CLI working with this codebase.

## Overview

testmu-browser-agent is a Go CLI and MCP server for AI-native browser automation. It controls Chrome (local or LambdaTest cloud) via the Chrome DevTools Protocol.

## Build & Test

```bash
make build              # Build to bin/testmu-browser-agent
make test               # Unit tests
make test-e2e           # E2E tests (needs Chrome)
make test-lambdatest    # Cloud tests (needs LT_USERNAME + LT_ACCESS_KEY)
```

## Project Structure

| Directory | Responsibility |
|-----------|---------------|
| `cmd/testmu-browser-agent/` | CLI entry point (cobra) |
| `internal/cli/` | 75+ CLI commands and output formatting |
| `internal/mcp/` | MCP JSON-RPC server (10 grouped tools) |
| `internal/action/` | Browser action executor |
| `internal/snapshot/` | Accessibility tree snapshots with @ref IDs |
| `internal/provider/` | Browser providers (local, LambdaTest, Appium) |
| `internal/daemon/` | HTTP server, Unix socket, middleware |
| `internal/state/` | Session persistence (AES-256-GCM) |
| `internal/network/` | Network monitor + domain filter |
| `internal/policy/` | Action allow/deny engine |
| `internal/stream/` | SSE broadcaster |
| `internal/auth/` | Encrypted credential vault |
| `internal/intercept/` | Network interception via CDP Fetch |
| `internal/browser/` | Chrome for Testing auto-install |
| `internal/selfupdate/` | CLI self-upgrade from GitHub releases |
| `internal/e2e/` | End-to-end test suite |

## Code Conventions

- Go 1.23+, standard library preferred
- CLI commands registered in `internal/cli/commands.go`
- MCP tools defined in `internal/mcp/tools.go`
- No emojis in code or output
- Table-driven tests
- Flags use kebab-case in help text

## Key Commands

```bash
testmu-browser-agent open <url>               # Open page
testmu-browser-agent snapshot                  # Accessibility tree
testmu-browser-agent click @e1                  # Click element
testmu-browser-agent fill @e1 "hello"            # Fill form field by @ref
testmu-browser-agent screenshot --output page.png  # Screenshot
testmu-browser-agent mcp                       # Start MCP server
testmu-browser-agent serve                     # Start daemon
```

## Documentation

When adding or changing user-facing features, update:

1. `internal/cli/commands.go` -- CLI command definition
2. `internal/mcp/tools.go` -- MCP tool definitions (if applicable)
3. `README.md` -- feature sections and examples
4. `skills/testmu-browser-agent/SKILL.md` -- AI agent skill guide
5. `docs/guides/commands.md` -- command reference
