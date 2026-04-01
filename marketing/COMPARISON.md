# testmu-browser-agent: Competitive Comparison

## Executive Summary

testmu-browser-agent is a Go single-binary browser automation tool built for AI agents. It ships three surfaces in one download — a 90+ command CLI, a 10-tool MCP server, and a REST/SSE daemon API — and connects to either a local Chrome instance or LambdaTest cloud with a single flag. Where Playwright MCP and Chrome DevTools MCP each burn an estimated 13,000–17,000 tokens before a single page action, testmu-browser-agent's CLI surface costs zero tokens for tool definitions and produces 200–400 token accessibility snapshots. Where agent-browser (Vercel) is the closest CLI peer, testmu-browser-agent extends the command set by ~80%, adds encrypted session persistence, a credential vault, a policy engine, Appium mobile testing, and first-class LambdaTest cloud integration — while remaining a single 10–15 MB binary installable with one curl command.

---

## Feature Comparison Table

| Feature | testmu-browser-agent | agent-browser (Vercel) | Playwright MCP | Chrome DevTools MCP | Puppeteer | Selenium | Bright Data Agent Browser |
|---|---|---|---|---|---|---|---|
| **Language** | Go | Rust | TypeScript (Node) | TypeScript (Node) | JavaScript (Node) | Java (primary) | Closed-source (cloud) |
| **Binary size** | ~10–15 MB | ~8–12 MB | N/A (npm package) | N/A (npm package) | N/A (npm package) | N/A (jar + driver) | N/A (SaaS) |
| **Install method** | `curl` install script / Homebrew / npm shim / binary download | `curl` install script / npm shim | `npm install` | `npm install` | `npm install` | Maven/Gradle dependency | Cloud dashboard / API key |
| **CLI command count** | 90+ | ~50 | None (MCP only) | None (MCP only) | None (library API) | None (library API) | Limited REST API |
| **MCP server** | Yes (10 grouped tools, stdio) | No | Yes (50+ individual tools, stdio) | Yes (30+ individual tools, stdio) | No | No | No |
| **Element referencing** | `@ref` IDs (stable, DOM-mutation-proof) | `@ref` IDs | CSS / XPath / ARIA | CSS / XPath | CSS / XPath | CSS / XPath / ID | CSS / XPath |
| **Snapshot format** | Compact accessibility tree with `@ref` IDs | Compact accessibility tree | Full ARIA tree or screenshot | DOM tree | N/A | N/A | N/A |
| **Token efficiency** | High (0 tool-def overhead on CLI, 200–400 tokens/snapshot) | High (CLI-based) | Low (13,700 tokens tool defs + 3,000–5,000/page) | Low (17,000 tokens tool defs) | N/A | N/A | N/A |
| **Session persistence** | Yes (AES-256-GCM encrypted, named sessions) | Partial (basic state save) | Yes (storageState) | No | Manual | Manual | Yes (managed cloud) |
| **Encryption** | AES-256-GCM at rest (storage key required) | No | No | No | No | No | TLS in transit only |
| **Cloud provider** | LambdaTest (built-in, `--provider lambdatest`) | No | BrowserStack via separate config | No | No | Sauce Labs / BrowserStack (manual) | Bright Data proprietary cloud |
| **Mobile testing** | Appium (via `--provider appium`) + device emulation | Device emulation only | Device emulation only | Device emulation only | Device emulation only | Yes (Appium separate) | No |
| **Network interception** | Yes (`route`, mock responses, headers, abort) | Yes | Yes | Partial | Yes | Limited (proxy-based) | Yes (anti-bot proxy) |
| **HAR export** | Yes (`har start` / `har stop`) | No | No | No | Manual | No | No |
| **Video recording** | Yes (GIF or PNG frames, screencast-based) | No | Yes (Playwright-native) | No | No | No | Yes (cloud dashboard) |
| **Device emulation** | Yes (named profiles, viewport, UA, scale, touch) | Yes | Yes | Yes | Yes | Yes | No |
| **Batch commands** | Yes (atomic JSON batch, `--bail` option) | No | No | No | Manual (Promise.all) | Manual | No |
| **Auth vault** | Yes (encrypted credential store, auto-login) | No | No | No | No | No | No |
| **Performance metrics** | Yes (`performance-metrics`, CPU throttle) | No | Limited | Yes | Limited | No | No |
| **Web Vitals** | Yes (`web-vitals`: LCP, FID, CLS) | No | No | Yes | Manual | No | No |
| **CI/CD integration** | Yes (headless flag, GitHub Actions examples) | Yes | Yes | Yes | Yes | Yes | Limited |
| **Cross-platform** | macOS, Linux, Windows (pre-built binaries) | macOS, Linux (Rust builds) | macOS, Linux, Windows | macOS, Linux, Windows | macOS, Linux, Windows | macOS, Linux, Windows | Cloud-only |
| **Skills system** | Yes (Claude Code skills integration) | No | No | No | No | No | No |
| **Daemon mode** | Yes (long-lived process, Unix socket) | Yes | No | No | No | No | Yes (cloud-managed) |
| **REST API** | Yes (HTTP endpoints via daemon) | No | No | No | No | No | Yes |
| **SSE streaming** | Yes (real-time browser events) | No | No | No | No | No | No |
| **Policy engine** | Yes (request/action policies) | No | No | No | No | No | Partial (proxy rules) |

---

## Token Efficiency Comparison

Token consumption is a first-order cost in AI agent workflows. Every token spent on tool definitions or verbose page representations is a token unavailable for reasoning, context, or instructions.

### Tool Definition Overhead (paid once per conversation)

| Tool | Tool definition tokens | Source |
|---|---|---|
| testmu-browser-agent (CLI mode) | **0** | No MCP registration required |
| testmu-browser-agent (MCP mode) | ~800–1,200 | 10 compact grouped tools |
| agent-browser | **0** | CLI-based, no MCP |
| Playwright MCP | ~13,700 | 50+ individual tools with full JSON schemas |
| Chrome DevTools MCP | ~17,000 | 30+ verbose tools with nested schemas |

### Per-Page Snapshot Cost

| Tool | Tokens per snapshot | Notes |
|---|---|---|
| testmu-browser-agent | 200–400 | Compact `@ref` accessibility tree, configurable `--max-length` |
| agent-browser | 200–400 | Same `@ref` approach |
| Playwright MCP | 3,000–5,000 | Full ARIA tree or screenshot bytes |
| Chrome DevTools MCP | 3,000–6,000 | DOM tree serialization |
| Puppeteer | N/A | No native snapshot; must script custom extraction |
| Selenium | N/A | No native snapshot; page source is full HTML |

### 10-Action Workflow: Context Window Math

Assume a 10-action workflow (navigate, snapshot, click, fill, snapshot, submit, wait, snapshot, screenshot, assert). Context window consumed by tooling overhead:

```
Playwright MCP:
  Tool definitions:  13,700 tokens  (paid once)
  10 snapshots:      35,000 tokens  (3,500 avg each)
  Total tooling:     48,700 tokens

Chrome DevTools MCP:
  Tool definitions:  17,000 tokens
  10 snapshots:      40,000 tokens
  Total tooling:     57,000 tokens

testmu-browser-agent (CLI):
  Tool definitions:       0 tokens
  10 snapshots:       3,000 tokens  (300 avg each)
  Total tooling:      3,000 tokens

testmu-browser-agent (MCP):
  Tool definitions:   1,000 tokens
  10 snapshots:       3,000 tokens
  Total tooling:      4,000 tokens
```

Estimated savings over Playwright MCP: up to ~44,700 tokens per 10-action workflow (up to ~92% reduction).
Estimated savings over Chrome DevTools MCP: up to ~53,000 tokens per 10-action workflow (up to ~93% reduction).

On a 200k-token context window, Playwright MCP exhausts ~24% of available context on tooling overhead alone in a 10-action session. testmu-browser-agent uses ~1.5%.

---

## AI Agent Integration Comparison

### Supported AI Tools

| AI Tool | testmu-browser-agent | agent-browser | Playwright MCP | Chrome DevTools MCP | Puppeteer | Selenium |
|---|---|---|---|---|---|---|
| Claude Code | Yes (CLI + MCP) | Yes (CLI) | Yes (MCP) | Yes (MCP) | Manual | Manual |
| Cursor | Yes (CLI + MCP) | Yes (CLI) | Yes (MCP) | Yes (MCP) | Manual | Manual |
| GitHub Copilot | Yes (CLI) | Yes (CLI) | No | No | Manual | Manual |
| Codex CLI | Yes (CLI) | Yes (CLI) | No | No | Manual | Manual |
| Gemini CLI | Yes (CLI) | Yes (CLI) | No | No | Manual | Manual |
| Windsurf | Yes (CLI + MCP) | Yes (CLI) | Yes (MCP) | Yes (MCP) | Manual | Manual |
| Goose | Yes (CLI) | Yes (CLI) | No | No | Manual | Manual |
| OpenCode | Yes (CLI) | Yes (CLI) | No | No | Manual | Manual |
| Cline | Yes (CLI + MCP) | No | Yes (MCP) | Yes (MCP) | Manual | Manual |

**Key distinction:** testmu-browser-agent is one of few tools that supports all major AI agent surfaces — both CLI-first tools (Codex, Gemini CLI, Goose) and MCP-first tools (Claude Code, Cline, Windsurf) — with native integration, not workarounds.

### Setup Complexity

**testmu-browser-agent (CLI mode — any agent):**
```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
# Done. Zero config.
```
Config lines required: **0**

**testmu-browser-agent (MCP mode — Claude Code):**
```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```
Config lines required: **5**

**Playwright MCP (Claude Code):**
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"],
      "env": {}
    }
  }
}
```
Config lines required: **7** plus Node.js runtime, plus `npx` network download on each start.

**Chrome DevTools MCP (Claude Code):**
```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-chrome-devtools"],
      "env": {
        "CHROME_PATH": "/path/to/chrome"
      }
    }
  }
}
```
Config lines required: **9** plus manual Chrome path configuration.

**Puppeteer / Selenium:** No MCP surface. Must write glue scripts; no AI-native integration.

---

## Unique Advantages

The following capabilities exist only in testmu-browser-agent among this comparison set.

### Go single binary
testmu-browser-agent compiles to a single self-contained binary (~10–15 MB) with no runtime dependencies. Compare this to Playwright MCP's requirement for Node.js, npm, and a ~200 MB Playwright installation. Go's toolchain is widely installed and the compile cycle is fast, which can ease community contribution.

### LambdaTest cloud built-in
One flag (`--provider lambdatest`) switches any command from local Chrome to a real cloud browser. This requires no proxy configuration, no separate SDK, and no infrastructure. LambdaTest sessions get automatic video recording, HAR capture, and pass/fail test marking in the dashboard. Among the tools in this comparison, testmu-browser-agent is the only one that ships cloud-browser switching as a built-in CLI flag.

### Appium mobile testing
The `--provider appium` flag connects testmu-browser-agent to an Appium server, enabling the same 90+ command surface against real iOS and Android devices or emulators. Playwright MCP supports device viewport emulation but not actual mobile device control. Selenium requires a separate Appium configuration entirely distinct from its web automation API.

### AES-256-GCM encrypted sessions
Session state (cookies, localStorage, storage keys) is encrypted at rest using AES-256-GCM with a user-supplied key. No other tool in this set encrypts persisted browser state. This matters in CI environments where session files may be committed to version control or stored in shared artifact stores.

### Credential vault
The `auth` command group provides a named credential store: save credentials once (`auth save`), replay them (`auth login`) across sessions. Credentials are stored encrypted. No MCP tool or other CLI in this set has an equivalent abstraction — users must either hardcode credentials or build their own vault.

### Policy engine
The internal policy package allows defining allow/deny rules for requests and actions, enabling testmu-browser-agent to act as a controlled automation agent in sensitive environments. Bright Data has proxy-level rules, but no other tool exposes a programmable policy surface at the automation layer.

### REST API and SSE daemon
The daemon process (`testmu-browser-agent serve`) exposes HTTP endpoints and a Server-Sent Events stream. This enables browser automation to be orchestrated from any language over HTTP — not just from Go or Node processes. The SSE stream delivers real-time browser events (console messages, network requests, navigation events) to any subscriber.

### 90+ commands (most complete CLI)
agent-browser ships ~50 commands. testmu-browser-agent ships 90+, adding: `har start/stop`, `video start/stop`, `trace start/stop`, `profiler start/stop`, `web-vitals`, `performance-metrics`, `dom-snapshot`, `ax-query`, `frame-tree`, `webauthn-add/remove`, `isolated-world`, `expose`, `stream-enable/disable`, `screencast start/stop`, `batch`, `diff snapshot/url/screenshot`, `auth save/login/list/show/delete`, `route`/`unroute`, `request-detail`, `response-body`, `geolocation`, `timezone`, `locale`, `permissions`, `device-emulate`, `device-list`, `cpu-throttle`, `vision-deficiency`, `media-emulate`, `touch-emulation`, `ignore-certs`, `bypass-csp`, `fetch-auth`, `fetch-auth-persist`, `sw-unregister`, `indexeddb`, `clear-origin`, `browser-logs`, `new-targets`, and more.

---

## When to Choose What

### Choose testmu-browser-agent when:
- You are building AI agents that need browser control from any tool (Claude Code, Cursor, Codex, Gemini CLI, Goose, Cline, Windsurf, etc.)
- Token efficiency matters — you are running multi-step workflows or have context window constraints
- You want a single binary with no Node.js, no npm, no runtime dependency installation
- You need LambdaTest cloud integration without a separate SDK
- You need mobile testing (real devices via Appium) alongside web automation
- You need encrypted session state or a credential vault
- You want both CLI and MCP surfaces from the same binary
- You are writing a CI pipeline and want `curl && run` simplicity

### Choose agent-browser (Vercel) when:
- You are already in the Vercel ecosystem and prefer Rust-compiled tooling
- You only need the ~50 core navigation/interaction commands
- You prefer a smaller command surface with less surface area to learn
- You do not need cloud providers, mobile, encryption, or HAR export

### Choose Playwright MCP when:
- You work exclusively in MCP-first environments (Claude Code, Cline)
- You need Playwright's cross-browser support (Firefox, WebKit, Chromium) beyond just Chrome
- You already have Playwright installed and want to reuse it
- Token overhead is not a constraint for your use case
- You need Playwright's mature test-runner ecosystem (assertions, fixtures, reporters)

### Choose Chrome DevTools MCP when:
- You need raw CDP access and are comfortable with verbose tooling
- You are doing protocol-level browser debugging rather than AI agent automation

### Choose Puppeteer when:
- You are writing Node.js scripts (not AI agents) that need fine-grained programmatic control
- You have existing Puppeteer codebases to maintain
- You do not need AI integration and are comfortable with callback/promise-based API

### Choose Selenium when:
- You have existing Selenium test suites in Java, Python, C#, or Ruby
- You need true cross-browser and cross-platform test execution at scale
- You require WebDriver-standard compliance for regulatory or organizational reasons
- AI agent integration is not a requirement

### Choose Bright Data Agent Browser when:
- Your primary challenge is anti-bot detection and IP rotation, not general automation
- You need residential proxy networks and fingerprint management
- You are doing web scraping at scale and do not mind cloud-only, managed pricing
- You do not need local development or offline capability

---

*Document reflects testmu-browser-agent at time of writing. Competitor feature data based on publicly available documentation.*
