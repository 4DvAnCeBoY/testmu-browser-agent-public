# Introducing testmu-browser-agent: AI-Native Browser Automation for the Agentic Era

> **Latest: v1.0.6** — 31 bug fixes, hardened auth encryption (PBKDF2), comprehensive CLI audit, all 85 E2E tests passing. [Release notes →](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/releases/tag/v1.0.6)

Browser automation was designed for humans writing test scripts. AI agents are not humans writing test scripts — and the mismatch is costing you tokens, reliability, and developer time. Today we are shipping testmu-browser-agent: a single Go binary that gives AI agents a proper interface to the web.

---

## The Problem: Your Browser Tool Is Burning Context

Every major AI coding assistant can call tools. The question is what those tools return.

Today's typical browser automation tools hand an AI agent the raw DOM — thousands of lines of nested HTML, inline styles, data attributes, and vendor cruft. The agent has to parse that noise to find the two things it actually cares about: "where is the login button, and what do I call it?" The model burns a meaningful fraction of its context window just to answer that question.

Then the page re-renders. The session state changes. The selector it computed no longer matches. Start over.

AI agents need a browser that speaks their language: structured, minimal, stable output with references that survive normal DOM churn. That is what testmu-browser-agent delivers.

---

## What We Built

testmu-browser-agent is a single statically-linked Go binary with three surfaces:

- **CLI** — 90+ commands covering navigation, interaction, querying, media capture, network interception, device emulation, and CDP diagnostics. Pipe-friendly, scriptable, composable.
- **MCP server** — 10 grouped tools that plug directly into Claude Code, Cursor, GitHub Copilot, Codex, Gemini CLI, Windsurf, Goose, OpenCode, and Cline. Zero configuration beyond a three-line JSON block.
- **REST/SSE daemon** — a long-lived HTTP server that exposes every CLI action as an endpoint, plus a Server-Sent Events stream for real-time browser events.

All three surfaces control the same underlying browser. Switch between them freely in the same workflow.

```
CLI / MCP / REST API
       |
  testmu-browser-agent (single Go binary)
       |
  Chrome (local) or LambdaTest (cloud)
```

The binary handles its own daemon lifecycle. Run `testmu-browser-agent open https://example.com` and it starts Chrome in the background, connects, and runs the command. Run another command and it reuses the same process. No process management required.

---

## The @ref Revolution: Snapshots Instead of Selectors

Here is the core idea. Instead of giving an agent raw HTML, we give it an **accessibility snapshot** — a compact, structured representation of the page as seen by assistive technology:

**Before: what agents typically receive**

```html
<div class="sc-bdVTJa bJYnUn" data-qa="login-form">
  <div class="sc-bZkfAA kGOXXF">
    <label class="sc-hBMUJo fzZXUI" for="username">Email address</label>
    <input class="sc-bZkfAA kGOXXF input" id="username" name="username"
      type="email" autocomplete="email" placeholder="you@company.com"
      data-qa="login-email-input" aria-required="true" value="">
  </div>
  <div class="sc-bZkfAA kGOXXF">
    <label class="sc-hBMUJo fzZXUI" for="password">Password</label>
    <input class="sc-bZkfAA kGOXXF input" id="password" name="password"
      type="password" autocomplete="current-password"
      data-qa="login-password-input" aria-required="true" value="">
  </div>
  <button class="sc-gPEVay hqXaFD btn btn--primary" type="submit"
    data-qa="login-submit-btn">Sign in</button>
</div>
```

**After: what testmu-browser-agent gives an AI agent**

```
form "Sign in"
  textbox "Email address" @e1
  textbox "Password" @e2
  button "Sign in" @e3
```

Same information. A fraction of the tokens. And every interactive element carries a stable `@ref` ID.

### How @ref IDs work

Every interactive element in the accessibility tree is assigned a short ref like `@e1`, `@e12`, `@e47`. These refs:

- Are stable across multiple snapshots of the same page without navigation
- Typically survive DOM re-renders caused by framework state updates
- Are invalidated by navigation or page reload
- Work as first-class selectors in every interaction command

```bash
# Snapshot the page — get refs for free
testmu-browser-agent snapshot

# Use refs directly — no CSS archaeology required
testmu-browser-agent fill @e1 "user@example.com"
testmu-browser-agent fill @e2 "hunter2"
testmu-browser-agent click @e3
```

After an action that does not trigger navigation, run `snapshot --diff` to see only what changed:

```bash
testmu-browser-agent click @e5   # toggle a menu
testmu-browser-agent snapshot --diff
# → navigation "Main menu" (expanded)   ← only the delta
```

This is the core loop for agentic browser use: snapshot, act, diff, repeat. The agent always knows exactly where it is without processing the entire page tree on every step.

---

## Claude Code Integration: The 5-Second Setup

testmu-browser-agent's MCP server is the primary way to give Claude browser capabilities. Setup is one edit to your settings file.

### Step 1: Install

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

### Step 2: Configure Claude Code

Add this to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "env": {}
    }
  }
}
```

Restart Claude Code. That's it — the browser tools are now available in every conversation.

### The 10 MCP Tools

The MCP server exposes 10 grouped tools that map cleanly to everything a browser agent needs:

| Tool | What it does |
|------|-------------|
| `browser_navigate` | Open URLs, navigate history, reload, close |
| `browser_interact` | Click, fill, type, press, select, scroll, drag, upload |
| `browser_query` | Snapshot, get text/title/URL, find by role/text/label, eval JS |
| `browser_media` | Screenshot, PDF export, video recording |
| `browser_state` | Cookies, localStorage/sessionStorage, saved sessions, clipboard |
| `browser_tabs` | Open, close, switch tabs; manage windows and iframes |
| `browser_wait` | Wait for element, URL, text, network idle, or fixed timeout |
| `browser_config` | Set viewport, user agent, geolocation; connect to remote CDP |
| `browser_network` | Read console logs, capture errors, handle dialogs, stream events |
| `browser_devtools` | Trace, profile, batch commands, performance metrics |

### A Real Workflow: Login, Fill, Screenshot

Here is exactly what happens when you tell Claude: "Log into https://app.example.com and take a screenshot of the dashboard."

**Claude's tool calls (automatic):**

```
1. browser_navigate { "action": "open", "url": "https://app.example.com/login" }

2. browser_query { "action": "snapshot" }
   → Returns compact accessibility tree:
     form "Sign in"
       textbox "Email" @e1
       textbox "Password" @e2
       button "Sign in" @e3

3. browser_interact { "action": "fill", "selector": "@e1", "text": "user@example.com" }

4. browser_interact { "action": "fill", "selector": "@e2", "text": "p@ssw0rd" }

5. browser_interact { "action": "click", "selector": "@e3" }

6. browser_wait { "selector": ".dashboard", "timeout": 15 }

7. browser_media { "action": "screenshot", "output": "dashboard.png" }

8. browser_navigate { "action": "close" }
```

Claude chains these calls automatically. It never needed to see a CSS class, an XPath expression, or a DOM node ID. It worked entirely with the semantic structure the snapshot provided.

### More things you can ask Claude

Once the MCP server is configured, your imagination is the limit. A few examples from the wild:

- "Go to https://news.ycombinator.com and list the top 10 story titles with their point counts."
- "Open https://books.toscrape.com, navigate to Mystery, and give me every book title, price, and star rating as a markdown table."
- "Open three Wikipedia tabs — Go, Rust, and TypeScript — and compare their Paradigm and Designed by fields side by side."
- "Take screenshots of https://getbootstrap.com at 375px, 768px, and 1440px viewport widths and show me the responsive layout differences."

These are not contrived demos. They are real single-prompt workflows Claude handles end-to-end with the MCP tools.

### Headless mode for CI

Running in CI or prefer no visible browser window? Pass `--headless`:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp", "--headless"]
    }
  }
}
```

---

## Beyond Local: LambdaTest Cloud

Local Chrome is fine for development. For CI pipelines, cross-browser validation, or testing on configurations you do not own locally, testmu-browser-agent has LambdaTest cloud built in.

```bash
export LT_USERNAME="your-lt-username"
export LT_ACCESS_KEY="your-lt-access-key"

# Every command gains --provider lambdatest
testmu-browser-agent --provider lambdatest open https://example.com
testmu-browser-agent --provider lambdatest snapshot
testmu-browser-agent --provider lambdatest screenshot --output result.png
```

The same flag works for the MCP server:

```json
{
  "mcpServers": {
    "testmu-browser-agent": {
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

LambdaTest sessions automatically capture video, console logs, and network traffic in your LambdaTest dashboard. The agent sends a keepalive every 60 seconds and marks sessions passed or failed on close. No infrastructure to manage — just set two environment variables and flip the provider flag.

For teams running parallel test suites, this means high-concurrency browser execution without standing up any browser infrastructure.

---

## The Complete Toolkit

Accessibility snapshots and MCP are the headline features, but testmu-browser-agent covers the full surface area of browser automation:

**Network interception**

Mock API responses, block resource types, inject headers — without touching application code:

```bash
testmu-browser-agent route "/api/user" --body '{"id":1,"name":"Test User"}' --status 200
testmu-browser-agent route "**/*.png" --abort   # block all image loads
testmu-browser-agent route "/api/*" --header "X-Test:true"
```

**Credential vault (AES-256-GCM encrypted)**

Store credentials encrypted at rest and replay login flows without embedding passwords in scripts:

```bash
testmu-browser-agent auth save --name staging \
  --url https://staging.example.com/login \
  --username deploy@example.com \
  --password "$STAGING_PASS"

testmu-browser-agent auth login --name staging   # auto-fills and submits
```

**Device emulation**

Test responsive layouts and mobile-specific behavior without physical devices:

```bash
testmu-browser-agent device-emulate "iPhone 15"
testmu-browser-agent geolocation 37.7749 -122.4194
testmu-browser-agent timezone America/Los_Angeles
testmu-browser-agent cpu-throttle 4   # 4x CPU slowdown
```

**Video recording**

Capture page sessions as GIF or individual PNG frames:

```bash
testmu-browser-agent video start
# ... run your workflow ...
testmu-browser-agent video stop              # saves as GIF
testmu-browser-agent video stop --format frames  # saves PNG frames
```

**HAR capture**

Record full network traffic for performance analysis and debugging:

```bash
testmu-browser-agent har start
# ... navigate, interact ...
testmu-browser-agent har stop --path traffic.har
```

**Core Web Vitals**

Measure LCP, FID, and CLS programmatically:

```bash
testmu-browser-agent web-vitals
```

**Batch commands**

Execute multiple actions in a single round trip, with optional bail-on-error:

```bash
testmu-browser-agent batch '[
  {"action":"open","url":"https://example.com"},
  {"action":"snapshot"},
  {"action":"screenshot","output":"page.png"}
]'
```

**Appium mobile (iOS and Android)**

Run the same command surface on real mobile devices via an Appium server:

```bash
testmu-browser-agent --provider appium --platform android open https://example.com
testmu-browser-agent --provider appium --platform ios snapshot
```

---

## Architecture

testmu-browser-agent is written in Go. That choice was deliberate.

**Single binary deployment.** No runtime to install, no dependency tree to manage. Download one file and run it. This matters especially for CI environments where installing Node, Python, or JVM runtimes adds setup time and failure surface.

**Daemon architecture.** The first command you run starts a background process connected to Chrome via CDP. Every subsequent command reuses that process through a Unix domain socket. Browser startup cost is paid once per session, not once per command.

**Concurrent sessions.** Multiple isolated browser sessions run in separate daemon processes, each with its own socket:

```bash
testmu-browser-agent --session work open https://github.com
testmu-browser-agent --session personal open https://gmail.com
testmu-browser-agent --session work snapshot   # independent, non-conflicting
```

**MCP over stdio.** The MCP server communicates over stdin/stdout using newline-delimited JSON-RPC 2.0. No network port, no firewall rule, no auth token. The OS handles process isolation.

**AES-256-GCM session encryption.** Pass `--storage-key` and saved session state (cookies, localStorage snapshots) is encrypted at rest. Useful for storing authenticated sessions in version control or passing them through CI artifact stores.

The REST/SSE daemon exposes every action as an HTTP endpoint, making it straightforward to drive testmu-browser-agent from any language with an HTTP client — useful for integration with systems that do not speak MCP.

---

## Getting Started

Five commands to go from zero to an AI agent controlling a browser:

```bash
# 1. Install
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh

# 2. Verify
testmu-browser-agent --version

# 3. Try the CLI
testmu-browser-agent open https://example.com
testmu-browser-agent snapshot
testmu-browser-agent screenshot --output example.png
testmu-browser-agent close

# 5. Ask Claude to use the browser
# "Go to https://news.ycombinator.com and tell me the top 5 stories."
```

**Step 4 — Add to Claude Code**

Add the following to your existing `~/.claude/settings.json` (merge into the `mcpServers` object if it already exists):

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

macOS, Linux, and Windows are all supported. Pre-built binaries for Apple Silicon, Intel, Linux x86-64, and Windows x86-64 are available on the releases page. Build from source with Go 1.23+.

**Docker:**

```bash
docker run -p 9222:9222 testmu/testmu-browser-agent:latest serve --headless
```

---

## What's Next

The 1.0 release covers local Chrome, LambdaTest cloud, and Appium mobile. The work ahead includes:

- **Additional cloud providers** — support for more cloud browser platforms beyond LambdaTest
- **Playwright compatibility layer** — run existing Playwright test suites through testmu-browser-agent without rewriting them
- **Persistent ref tracking** — refs that survive navigation by tracking element identity across page loads
- **Richer snapshot formats** — optional structured JSON snapshots optimized for specific LLM context window sizes
- **Agent-native test assertions** — semantic assertions that match the way AI agents reason about page state rather than DOM structure

---

testmu-browser-agent is available now. The source is on GitHub. The install script puts you on the latest release in under 30 seconds.

If you are building AI agents that need to interact with the web, this is the browser tool that was designed for them.

```bash
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```
