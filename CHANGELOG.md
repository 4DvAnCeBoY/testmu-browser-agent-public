# Changelog

All notable changes to testmu-browser-agent-public are documented here.

## [Unreleased]

### Browser Execution

- feat: wire CLI to daemon for real browser execution with auto-start (6586f82)
- feat: add snapshot action to executor for CLI and daemon support (38be384)

### Feature Parity

- feat: add advanced waits, element queries, semantic finders, scrollintoview (237bf2b)
- feat: add download management with CDP download behavior tracking (6d82bdd)
- feat: add network interception with route/unroute via CDP Fetch (e23a5de)
- feat: add auth vault with encrypted credential storage (a11ec96)
- feat: add screenshot annotation with @ref overlay (ac0406e)
- feat: add device emulation, content injection, stream server, and screencast (97c1a22)
- feat: add Appium WebDriver provider for iOS/Android mobile testing (7ddf955)
- feat: add auto browser install and CLI self-upgrade commands (a10c84b)

### Testing

- test: add E2E test suite with local test server (014d304)

### Fixes

- fix: address Wave 1 code review findings (d32ce19)
- fix: clean up marketplace.json to match official Anthropic plugin format (648cb96)
- fix: remove unsupported allowed-tools attribute from SKILL.md frontmatter (793ba7e)
- fix: correct CLI syntax across docs, examples, skills, and configs (440ad58)
- fix: address Gemini review findings (3e7c60f)
- fix: correct docs for @ref syntax, defaults, URLs, and add status disclaimer (ba0cd79)

### Documentation

- docs: add feature parity implementation plan (12 tasks, 3300 lines) (5d8b2d5)
- docs: add skills and MCP installation guide for all AI vendors (d11e90f)
- feat: add AGENTS.md, GEMINI.md, and codex.json for AI agent integration (d2a4f2f)

### Releases

- chore: add cross-platform release binaries (macOS, Linux, Windows) (e1c2dbe)
- chore: unignore bin/ directory for release binaries (5929dec)

### MCP Server

- feat: add MCP JSON-RPC protocol types with request/response parsing (c401fad)
- feat: add 10 grouped MCP tool definitions with JSON Schema (a2bf903)
- feat: add MCP tool call handlers dispatching to executor (0ca6b27)
- feat: add mcp subcommand to CLI for Claude Code integration (6370361)
- feat: add MCP server with stdio message loop and auto-detect (ab3b5ac)
- test: add MCP protocol integration test verifying initialize and tools/list (1162d51)

### CLI Commands

- feat: add all cobra CLI subcommands with global flags (14649cf)
- feat: add all missing CLI commands and aliases for full command parity (1273bdc)
- feat: wire serve command to daemon with provider selection (4f06fc6)

### Browser Providers

- feat: add provider interface and local Chrome provider (77503b1)
- feat: add LambdaTest cloud provider with keepalive and status marking (504887e)

### State Management

- feat: add session state save/load with atomic writes and encryption (65d9f1f)
- feat: add RefMap for @ref ID to backendNodeId mapping (70c1918)

### Snapshots & Accessibility

- feat: add accessibility snapshot with CDP primary, JS fallback, and diff (5210afd)
- feat: add interaction, query, and media actions with element resolution (1a3fa12)
- feat: add query actions (get, eval) and media actions (screenshot, pdf) (a33fd2a)

### Network & Monitoring

- feat: add network monitor, domain filter, and HAR export (d3a44d2)
- feat: add SSE event broadcaster with subscribe/publish/unsubscribe (d7d57de)

### Security & Policy

- feat: add AES-256-GCM encryption for session state (c580174)
- feat: add action policy engine with allow/deny lists (011ec6f)

### Output & Formatting

- feat: add text/json/compact output formatters (ff290e9)

### Daemon

- feat: add daemon HTTP server, Unix socket listener, and middleware (8e4a3ea)
- feat: add all missing action handlers for full command parity (231ff22)
- feat: add action executor with navigation commands (670b817)

### Core

- feat: scaffold project with Go module, CLI, and Makefile (b51cf1d)
- fix: resolve merge conflicts in action package and update deps (de86396)

### Infrastructure

- ci: add GitHub Actions workflow with test, build, and lint jobs (348aa79)
- chore: update gitignore for docs, add marketing readiness spec and plan (b371eaa)
