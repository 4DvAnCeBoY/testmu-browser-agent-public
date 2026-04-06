# Changelog

All notable changes to testmu-browser-agent are documented here.

## [v1.0.7] — 2026-04-06

### Security Hardening (7 fixes)
- fix: path traversal protection — new `safePath()` helper applied to all 11 file-output handlers (screenshot, PDF, HAR, trace, record, state, download, video, upload, auth vault)
- fix: symlink bypass prevention — `filepath.EvalSymlinks` on parent directory in safePath
- fix: KDF upgrade — replace weak iterated SHA-256 with PBKDF2-HMAC-SHA256 (100k rounds) for state encryption
- fix: DevTools WebSocket origin check — reject non-localhost origins (DNS rebinding protection)
- fix: CORS origin bypass — `localhost.evil.com` no longer passes origin check
- fix: VaultPath traversal — validate through safePath() in all 5 auth handlers
- fix: upload file paths validated through safePath() before DOM.setFileInputFiles

### Concurrency Fixes (10 fixes)
- fix: `handleConnect` data race — add `clientMu` RWMutex for e.client/e.session swap
- fix: `StartTargetMonitor` goroutine leak — cancellable context, cleanup on browser swap
- fix: `handleFetchAuth` goroutine lifetime — use background context with stored cancel
- fix: `handleCredentials` goroutine lifetime — same pattern as handleFetchAuth
- fix: `handleExpose` goroutine lifetime — use background context with stored cancel (was dying immediately after response)
- fix: trace data race — `traceMu` protects traceChunks append/read
- fix: `fetchCredsStore` global map leak — moved into Executor struct
- fix: `browserLogStore` global sync.Map leak — moved into Executor struct
- fix: `handleRecord` — protect screencastInUse reads/writes with mediaMu
- fix: `handleConnect` — serialize entire connect sequence under clientMu; restart targetMonitor and enableAutoAttach after swap
- fix: `StartConsoleCapture`/`StartErrorCapture` — store cancel before launching goroutine (race fix)
- fix: `wait domcontentloaded` — snapshot e.client under clientMu.RLock
- fix: `diff.go` — protect lastSnapshot/lastScreenshot with pageMu

### Memory Bounds (9 caps added)
- fix: `NetworkCapture` capped at 5,000 entries with oldest eviction + backing array freed
- fix: `recordFrames` capped at 600 (matches maxVideoFrames)
- fix: `consoleMessages` capped at 10,000 entries
- fix: `pageErrors` capped at 5,000 entries
- fix: `browserLogCapture.logs` capped at 5,000
- fix: `newTargets` capped at 1,000
- fix: HAR entries/completed capped at 5,000
- fix: individual console messages truncated at 64KB
- fix: port=0 + empty socketPath returns error instead of silent no-listener daemon

### MCP & REST API Fixes (7 fixes)
- fix: `browser_state` MCP routing — correct action name mapping for storage/clipboard
- fix: `batch` JSON parsing — restructure flat commands to nested {action, params} format
- fix: `trace_start`/`trace_stop` MCP routing — use params["action"] not subcommand
- fix: `profiler_start`/`profiler_stop` — same routing fix
- fix: REST API — always bind TCP listener on non-zero port; fix executor race condition
- fix: MCP shutdown calls `executor.Cleanup()` before closing provider
- fix: `handleClose` cancels console/error capture goroutines before nulling page
- fix: shutdown() panic recovery — wrap Cleanup() in deferred recover

### LambdaTest
- fix: CDP heartbeat every 30s prevents idle session timeout

### Documentation
- README: correct "90+ CLI commands" to "68+ CLI commands, 90+ total actions"
- README: CDP section now clearly marked "MCP & REST API only" with table format

### Testing
- test: 80+ new unit tests across 5 new test files
- test: path traversal, KDF round-trip, WebSocket origin check, memory caps, executor fields, daemon HTTP handler, MCP routing
- test: 304 unit tests + 98 E2E tests all passing with -race

### BREAKING CHANGES
- State encryption KDF upgraded from iterated SHA-256 to PBKDF2. Previously encrypted state files will not decrypt — re-save state after upgrading.

---

## [v1.0.6] — 2026-04-04

### Bug Fixes (31 total)

**Critical**
- fix: `record stop --output` now writes base64 PNG frames to disk (BUG-003)
- fix: auth vault encrypted by default using PBKDF2-HMAC-SHA256 (100k iterations) — plaintext migration automatic (BUG-008)

**High**
- fix: `batch` command normalizes `command→action`, `args→params` field mapping + stdin support (BUG-017)
- fix: `trace stop --output` CLI flag wired to handler (BUG-018)
- fix: MCP server cleans stale daemon socket before connecting (BUG-021)
- fix: `find --role` matches implicit ARIA roles (a→link, button→button, etc.) (BUG-024)
- fix: `swipe` CLI converts direction+distance to startX/startY/endX/endY coords
- fix: `device` CLI maps subcommands to `device_list`/`device_emulate` actions
- fix: `stream` CLI routes to `stream_enable` instead of non-existent action

**Medium**
- fix: `har` CLI command added (start/stop with --output)  (BUG-009)
- fix: `clipboard write` grants CDP permissions for headless mode (BUG-028)
- fix: `cookies delete` auto-detects current page URL for CDP (BUG-030)
- fix: `addinitscript` executes on navigate, not just open (BUG-032)
- fix: `dialog accept/dismiss` persists across multiple dialogs + `Page.enable` (BUG-034)
- fix: `screenshot --full` uses `captureBeyondViewport` + content size clip (BUG-039)
- fix: `frame main/top/parent` returns to top-level frame (BUG-043)
- fix: `find --label` returns labeled inputs AND label elements (BUG-046)
- fix: `wait --load domcontentloaded` pre-checks `document.readyState` before subscribing
- fix: `wait --fn` accepts any truthy value (numbers, strings), not just `true`
- fix: HAR output permissions changed to 0o600 (contains auth headers)
- fix: output directory auto-created for record, trace, HAR

**Low**
- fix: `is hidden` returns `true` for nonexistent elements instead of 30s timeout (BUG-045)
- fix: dialog handler cancels previous goroutine on re-configure (prevents leaks)

### New CLI Flags
- `click --new-tab` — Ctrl+click to open in new tab
- `dialog --text` — text input for prompt dialogs
- `tab new --url` — open new tab with pre-loaded URL
- `record stop --output` — save screencast frames
- `trace stop --output` — save trace data
- `har stop --output` — save HAR data

### Resource Leak Fixes
- `cleanupBeforeBrowserSwap()` now cancels: dialog handler, record frame collector, browser log capture, fetch auth credentials, stale init scripts

### Documentation
- SKILL.md: fix geolocation syntax (--lat/--lon flags, not positional)
- SKILL.md: fix tab switch syntax (`tab switch <id>`, not `tab <id>`)
- SKILL.md: fix record output format (JSON frames, not WebM)
- SKILL.md: add HAR capture commands, dialog --text, tab --url

---

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
