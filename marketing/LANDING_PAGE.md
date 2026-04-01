# testmu-browser-agent

**The browser automation layer built for AI agents.**

A single Go binary. 90+ commands. 10 MCP tools. Works with every AI coding tool you already use.

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

```bash
testmu-browser-agent open https://app.example.com
testmu-browser-agent snapshot          # → compact accessibility tree with @ref IDs
testmu-browser-agent click @e3         # → stable ref, not a fragile CSS selector
testmu-browser-agent fill @e7 "test@example.com"
testmu-browser-agent screenshot --output result.png
```

---

## Works With Every AI Coding Tool

**Claude Code** — first-class citizen. Drop in the MCP config and Claude controls a real browser in seconds.

| Tool | Integration |
|------|-------------|
| Claude Code | MCP server (10 tools) |
| Cursor | MCP server |
| GitHub Copilot | CLI / REST API |
| Codex | CLI / REST API |
| Gemini CLI | CLI / REST API |
| Windsurf | MCP server |
| Goose | MCP server |
| OpenCode | MCP server |
| Cline | MCP server |

Any tool that can run a shell command or speak MCP works with testmu-browser-agent.

---

## Six Reasons Developers Choose It

### Agent-First Output
Outputs a compact accessibility tree, not raw HTML. Your AI agent gets the semantic structure it needs — role, name, value, `@ref` — without wading through thousands of tokens of markup.

### Ref-Based Interaction
Every interactive element gets a stable `@ref` ID (`@e1`, `@e2`, ...) assigned from the accessibility tree. Refs survive DOM mutations, re-renders, and framework hydration. No fragile CSS selectors. No XPath archaeology.

### Fast by Default
A native Go binary starts in milliseconds. Daemon mode keeps a single Chrome process alive across commands so there is no browser cold-start overhead between actions. Run commands individually or batch them through the REST API.

### Complete Command Set
90+ commands cover the full browser automation surface: navigation, clicks, forms, keyboard, scrolling, screenshots, video recording, network interception, HAR export, cookie management, device emulation, CDP diagnostics, auth credential vault, response body capture, mobile via Appium, and more. Playwright and Puppeteer script the browser. testmu-browser-agent commands the browser — the distinction matters when an AI agent is the one deciding what to do next.

### Cloud-Ready from Day One
Pass `--provider lambdatest` and your session runs on LambdaTest's real browser grid. No local Chrome required, no Selenium Grid to maintain, no Docker compose file. The same commands work locally and in CI.

### Secure by Design
Session state is encrypted at rest with AES-256-GCM. Credentials stored in the built-in vault never appear in shell history. A policy engine lets you define allow/deny rules for what domains an agent is permitted to visit — essential when AI agents browse autonomously.

---

## Token Efficiency

Accessibility snapshots are dramatically smaller than HTML DOM dumps — up to 90% context reduction vs raw HTML. Smaller context windows mean cheaper inference and more room for your actual task.

| Method | Typical output for a login form |
|--------|--------------------------------|
| Full HTML via CDP | ~12,000 tokens |
| Chrome DevTools MCP (DOM snapshot) | ~4,000–8,000 tokens |
| Playwright MCP (accessibility) | ~800–1,500 tokens |
| **testmu-browser-agent snapshot** | **~200–400 tokens** |

testmu-browser-agent returns only the nodes that matter — interactive elements, headings, landmarks — with the minimum fields needed to act on them. Claude Code can process an entire single-page app's snapshot without burning most of its context window.

---

## How It Works

**Step 1 — Install**

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

One binary. No Node runtime. No Python environment. No Playwright install step.

**Step 2 — Snapshot**

```bash
testmu-browser-agent open https://github.com/login
testmu-browser-agent snapshot
```

```
[document] GitHub · Build and ship software on a single, collaborative platform
  [main]
    [heading] Sign in to GitHub
    [textbox] Username or email address @e1
    [textbox] Password @e2
    [checkbox] Remember me @e3
    [button] Sign in @e4
    [link] Forgot password? @e5
```

Compact. Semantic. Every element you need to act on is here.

**Step 3 — Act**

```bash
testmu-browser-agent fill @e1 "monalisa"
testmu-browser-agent fill @e2 "hunter2"
testmu-browser-agent click @e4
testmu-browser-agent snapshot    # verify you're now on the dashboard
```

Refs are stable. Paste `@e4` into any command and it resolves to the right element — even after the page re-renders.

---

## MCP Integration with Claude Code

Add to `~/.claude/settings.json` (user-wide) or your project's `.claude/settings.json`:

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

Restart Claude Code. That is the entire setup.

### The 10 MCP Tools

Tools are grouped by function so Claude Code's tool picker stays clean:

| Tool | What it does |
|------|-------------|
| `browser_navigate` | Open URLs, navigate, back, forward, reload, close |
| `browser_interact` | Click, fill, type, press, select, scroll, hover, drag, tap, check, upload |
| `browser_query` | Accessibility snapshot, get text/HTML, find elements, eval JS, inspect |
| `browser_media` | Screenshot (PNG/JPEG), PDF export, video recording |
| `browser_state` | Cookies, localStorage, clipboard, session save/load |
| `browser_tabs` | List, create, close, switch tabs/windows/frames |
| `browser_wait` | Wait for selector, URL pattern, text, load state, JS condition, download |
| `browser_config` | Viewport, user-agent, geolocation, timezone, CDP connection |
| `browser_network` | Console logs, page errors, dialog handling, highlight, SSE stream |
| `browser_devtools` | Chrome trace, CPU profiler, batch commands, performance metrics |

Each tool maps to the same underlying engine as the CLI, so behavior is identical whether you call it from a shell or from Claude Code.

---

## Use Cases

### Automated Testing
Write test suites that run in CI against a real browser. Use `--provider lambdatest` for LambdaTest's cross-browser grid. Export HAR files for debugging failures. Record video for flaky test post-mortems.

```bash
testmu-browser-agent open https://staging.example.com
testmu-browser-agent snapshot
testmu-browser-agent click @e12   # "Add to cart"
testmu-browser-agent screenshot --output cart-test.png
```

### Web Scraping
Navigate authenticated flows that JavaScript scrapers can't handle. Extract structured data via the accessibility tree — no brittle CSS selectors to maintain.

### CI/CD Pipelines
Smoke test deployments on every push. testmu-browser-agent exits non-zero on errors and returns structured output that your CI pipeline can parse.

```yaml
- name: Smoke test
  run: |
    testmu-browser-agent open ${{ env.DEPLOY_URL }}
    testmu-browser-agent snapshot | grep "Welcome"
```

### AI Agents
Give Claude Code, Codex, or any LLM-powered agent a real browser. The agent reads the accessibility tree, decides what to click, fills in forms, and reports back — all through a stable, token-efficient interface.

### Mobile Testing
Connect real iOS or Android devices via Appium. The same `snapshot`, `click`, and `fill` commands work on mobile. No separate mobile framework to learn.

### Performance Monitoring
Capture HAR exports on every deploy. Intercept network requests to assert on payload size and response time. Integrate with your existing observability stack.

---

## Installation

### curl (macOS and Linux) — recommended

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

### npm

```bash
npm install -g testmu-browser-agent
```

### Homebrew

```bash
brew install testmu/tap/testmu-browser-agent
```

### Docker

```bash
docker run --rm -it ghcr.io/testmu/testmu-browser-agent:latest snapshot
```

### Build from source

```bash
git clone https://github.com/testmu/testmu-browser-agent
cd testmu-browser-agent
go build -o testmu-browser-agent ./cmd/testmu-browser-agent
```

Requires Go 1.23+. No CGO. Cross-compiles cleanly.

---

## Numbers

- **90+** CLI commands
- **10** MCP tools
- **Comprehensive** E2E test suite
- **3** integration surfaces: CLI, MCP, REST/SSE
- **1** binary to install
- **0** runtime dependencies

---

## Get Started

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

- [GitHub](https://github.com/testmu/testmu-browser-agent) — source, issues, releases
- [Docs](https://github.com/testmu/testmu-browser-agent/tree/main/docs) — full command reference and guides
- [Changelog](https://github.com/testmu/testmu-browser-agent/blob/main/CHANGELOG.md) — what's new

Star the repo if testmu-browser-agent is useful. It helps other developers find it.
