# testmu-browser-agent-public — Social Media Launch Kit

---

## 1. Twitter/X Launch Thread

---

**Tweet 1 — Hook**

We built a browser automation tool that cuts AI token usage by up to 90% and is resistant to CSS changes.

testmu-browser-agent-public: AI-native CLI + MCP server, single Go binary, 90+ commands, open source.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

**Tweet 2 — The Problem**

The dirty secret of AI browser automation:

- Selectors break when devs rename a class
- Full-page HTML dumps waste thousands of tokens per step
- Every tool reinvents the same fragile crawl loop

Your AI agent is burning money just to click a button.

---

**Tweet 3 — The Solution**

testmu-browser-agent-public uses stable `@ref` IDs on an accessibility tree snapshot.

Instead of dumping raw HTML, the agent sees:

```
button @e45 "Submit"
input @e12 "Email" (focused)
```

Stable across CSS refactors. Token-efficient. No brittle XPath needed.

---

**Tweet 4 — Claude Code Integration**

One JSON block and Claude Code can drive a real browser:

```json
{
  "mcpServers": {
    "testmu": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

Add to `.claude/settings.json`, restart Claude Code, done.

---

**Tweet 5 — Works Everywhere**

testmu-browser-agent-public works as an MCP server with:

- Claude Code
- Cursor
- GitHub Copilot
- Codex
- Gemini CLI
- Windsurf
- Goose
- OpenCode
- Cline

One binary. Every AI tool. No per-tool wrappers.

---

**Tweet 6 — The Numbers**

- 90+ CLI commands
- 10 MCP tools
- Comprehensive E2E test suite
- Single static binary (Go, no runtime deps)
- AES-256-GCM encrypted sessions
- LambdaTest cloud built in

Ships as a curl one-liner or npm package.

---

**Tweet 7 — Cloud Scale**

Running tests at scale? testmu-browser-agent-public has LambdaTest cloud built in.

Flip one flag and your AI-driven tests run on real cloud browsers — no Selenium Grid to manage, no Docker headaches.

Same commands. Same MCP tools. Cloud or local.

---

**Tweet 8 — Getting Started**

Install in one line:

```bash
curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh
```

Or via npm:

```bash
npm install -g testmu-browser-agent-public
```

Then: `testmu-browser-agent mcp` and point your AI tool at it.

---

**Tweet 9 — CTA**

If you're building AI agents that touch a browser, try testmu-browser-agent-public.

- Star the repo: https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public
- Drop feedback in the issues — we read everything
- RT if you know someone building browser automation with AI

---

## 2. Twitter/X Standalone Posts (Ongoing Promotion)

---

**Standalone 1 — Token efficiency angle**

Most AI browser agents dump the entire DOM into context.

testmu-browser-agent-public sends a compact accessibility snapshot with stable `@ref` IDs instead.

Same automation. Up to 90% fewer tokens. Your API bill will thank you.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

**Standalone 2 — Go binary angle**

testmu-browser-agent-public is a single static Go binary.

No Node runtime. No Python venv. No Docker image.

`curl | sh`, add it to `.claude/settings.json`, and your AI agent has a full browser.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

**Standalone 3 — Security angle**

AI browser sessions can contain credentials, cookies, and auth tokens.

testmu-browser-agent-public encrypts all persisted sessions with AES-256-GCM.

That's the same standard used by banks. It should be table stakes for browser automation too.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

**Standalone 4 — CI/CD angle**

testmu-browser-agent-public runs headless out of the box.

- Local dev: headed Chrome
- CI: headless, same binary
- Cloud: LambdaTest, same commands

Comprehensive E2E test coverage. No environment-specific hacks.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

**Standalone 5 — Developer frustration angle**

"Why did my AI agent break? The page looks the same."

A class name changed. The CSS selector died. The AI is lost.

testmu-browser-agent-public references elements by accessibility role and a stable `@ref` ID — not CSS. Survives most UI refactors.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

## 3. LinkedIn Launch Post

---

**Announcing testmu-browser-agent-public — Open Source AI-Native Browser Automation**

We're open sourcing testmu-browser-agent-public, a CLI and MCP server built in Go that gives AI coding assistants reliable, token-efficient browser control.

**Why we built it**

Most browser automation tools were designed for human-written scripts. When AI agents drive them, two problems surface quickly:

1. Selectors are fragile. A CSS class rename breaks a test with no warning.
2. Context is expensive. Dumping full DOM into an LLM context costs thousands of tokens per step and degrades reasoning quality.

testmu-browser-agent-public addresses both. The agent receives a compact accessibility tree snapshot where each interactive element has a stable `@ref` ID — unaffected by CSS or layout changes. AI tools send back `@ref` references, not XPath or CSS selectors.

**What it includes**

- 90+ CLI commands covering navigation, interaction, assertions, network interception, and more
- 10 MCP (Model Context Protocol) tools for direct AI assistant integration
- Native support for Claude Code, Cursor, GitHub Copilot, Codex, Gemini CLI, Windsurf, Goose, OpenCode, and Cline
- AES-256-GCM encrypted session persistence
- LambdaTest cloud testing built in for teams running at scale
- Single static Go binary — no runtime dependencies, trivial to deploy in CI/CD

**Enterprise-ready from day one**

- All 85 end-to-end tests pass on every commit
- Cloud browser infrastructure via LambdaTest removes the overhead of maintaining Selenium Grids
- Encrypted credential storage makes it safe to include in automated pipelines
- Works headless in CI and headed in development with zero configuration changes

**Getting started**

```bash
curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh
```

Or install via npm for teams already on Node-based tooling:

```bash
npm install -g testmu-browser-agent-public
```

We believe browser automation should be a first-class capability for AI development tools — not an afterthought bolted on top of Selenium. testmu-browser-agent-public is our bet on what that looks like.

Star the project, try it in your workflow, and let us know what's missing.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

## 4. Hacker News Launch

---

**Title:**

Show HN: testmu-browser-agent-public – AI-native browser automation CLI + MCP server (Go, open source)

---

**Post Body:**

I've been frustrated with how AI agents handle browser automation. Two problems kept coming up:

**Token waste.** Every step, the agent dumps the full page HTML into context — 10k-50k tokens for a simple form. Most of it is navigation chrome, ads, scripts. The signal is buried.

**Fragile selectors.** AI-generated CSS selectors break on the next frontend deploy. XPath is worse. You end up in a maintenance loop that eats any productivity gain from the AI in the first place.

testmu-browser-agent-public tries to fix both.

**How it works**

Instead of raw HTML, the agent gets an accessibility tree snapshot with stable `@ref` IDs:

```
landmark @e1 role=main
  heading @e2 "Sign in"
  input @e3 type=email placeholder="Email address"
  input @e4 type=password placeholder="Password"
  button @e5 "Sign in"
```

The AI sends back `@ref` references. The daemon resolves them to the actual DOM node via Chrome DevTools Protocol. `@ref` IDs are stable across CSS changes because they're derived from the accessibility tree, not the visual layout.

**Architecture**

- Single Go binary. Runs a local daemon that manages a Chrome connection over CDP.
- CLI for human-driven or scripted use (90+ commands).
- MCP server mode for AI tool integration — tested against Claude Code, Cursor, Copilot, Codex, Gemini CLI, Windsurf, Goose, OpenCode, and Cline.
- Sessions are persisted with AES-256-GCM encryption so credentials aren't stored in plaintext.
- LambdaTest cloud is integrated for teams that need real-device testing at scale.

**Why Go**

Distribution. A static binary that installs with `curl | sh` removes a whole category of environment problems. Node, Python, and JVM runtimes all introduce version conflicts that show up in CI. Go doesn't.

**Status**

- Comprehensive E2E test suite
- Open source under MIT
- Install: `curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh`

Happy to answer questions about the `@ref` system, the daemon design, or the MCP integration.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

## 5. Reddit Posts

---

### r/programming

**Title:** I got tired of AI browser agents breaking on CSS changes, so I built a tool that uses stable accessibility IDs instead — open source

**Post:**

Background: I've been building browser automation with AI assistants for a while. The workflow is powerful but there's a recurring problem — the AI generates CSS selectors that break the moment a frontend dev renames a class.

I built testmu-browser-agent-public to fix this. The core idea: instead of exposing raw DOM to the AI, expose an accessibility tree snapshot with stable `@ref` IDs. Something like:

```
button @e45 "Submit"
input @e12 "Email" (focused)
```

The AI navigates using `@ref` references, not CSS. These IDs are derived from the accessibility tree, so they survive most UI refactors. It's also significantly more token-efficient than dumping raw HTML.

The project is a Go binary that runs as both a CLI (90+ commands) and an MCP server. Works with Claude Code, Cursor, Copilot, Codex, Gemini CLI, and others. Sessions are AES-256-GCM encrypted. LambdaTest cloud is built in for teams.

Install: `curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh`

Repo: https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

Would love feedback on the `@ref` approach specifically — I think it's the most interesting design decision and I'm curious what edge cases others see.

---

### r/golang

**Title:** Show r/golang: AI-native browser automation in Go — single binary, CDP-based, MCP server mode

**Post:**

Built a browser automation tool in Go that I wanted to share here because the Go-specific design decisions were interesting.

**Why Go for this**

The primary reason: distribution. Browser automation tools have a runtime dependency problem. npm packages require the right Node version. Python tools require a venv. When you're shipping a developer tool that gets installed via curl in CI pipelines, a static binary removes a whole class of environment problems.

Go gave us:
- Single static binary with no external deps
- `curl | sh` install that actually works cross-platform
- Trivial Docker inclusion (scratch image)
- Fast startup (daemon is up in ~150ms)

**Architecture highlights**

- Local daemon manages a persistent Chrome connection over CDP (Chrome DevTools Protocol)
- CLI connects to daemon via Unix socket with a simple JSON protocol
- MCP server mode exposes 10 tools for AI assistant integration
- Sessions are encrypted with AES-256-GCM using `crypto/cipher` from stdlib

**The accessibility tree trick**

The interesting part is how we reduce token usage. Instead of serializing DOM to HTML for AI context, we walk the accessibility tree via CDP's `Accessibility.getFullAXTree` and emit a compact text format with stable `@ref` IDs. This cuts context size by up to 90% on typical pages while making AI-generated interactions more robust to UI changes.

**Stats**

- 90+ CLI commands
- 10 MCP tools
- Comprehensive E2E test suite
- MIT license

Repo: https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

Happy to dig into any of the Go implementation details if people are curious.

---

### r/ClaudeAI

**Title:** Give Claude Code a real browser with testmu-browser-agent-public — open source MCP server, stable @ref IDs

**Post:**

If you're using Claude Code and want it to control a browser, testmu-browser-agent-public is the cleanest setup I've found.

**Setup is three steps:**

1. Install the binary:
```bash
curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh
```

2. Add to `.claude/settings.json`:
```json
{
  "mcpServers": {
    "testmu": {
      "command": "testmu-browser-agent",
      "args": ["mcp"]
    }
  }
}
```

3. Restart Claude Code

**Why it works well with Claude**

The tool sends Claude an accessibility tree snapshot with `@ref` IDs instead of raw HTML. Claude gets a compact, structured view of the page — something like:

```
form @e8 "Login"
  input @e9 type=email "Email address"
  input @e10 type=password "Password"
  button @e11 "Sign in"
```

Claude references `@ref` IDs in its actions. This is much more token-efficient than HTML dumps and more reliable than CSS selectors.

**What Claude can do with it:**
- Navigate to URLs, fill forms, click buttons
- Take screenshots and compare states
- Wait for network requests to complete
- Intercept and inspect API responses
- Extract structured data from pages
- Run tests and assertions

90+ commands total. Open source on GitHub: https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public

---

## 6. Dev.to / Hashnode Article Pitch

---

**Title:**

How We Cut AI Browser Automation Token Usage by Up to 90% with Accessibility Trees

**Summary:**

Most AI-driven browser automation tools work by dumping the full page HTML into the model's context. This works, but it's slow and expensive — a typical page sends 10,000–50,000 tokens before the agent takes a single action. The bigger problem is reliability: AI-generated CSS selectors break whenever a frontend developer renames a class or restructures a component.

This post walks through how testmu-browser-agent-public approaches the problem differently. Instead of HTML serialization, the tool exposes a compact accessibility tree snapshot where every interactive element has a stable `@ref` ID — a short identifier derived from the element's role and position in the accessibility tree rather than its CSS or DOM path. When the AI sends back an action like `click @e45`, the agent resolves it through Chrome DevTools Protocol to the actual DOM node. Because accessibility roles are tied to semantic meaning rather than visual presentation, `@ref` IDs survive most UI refactors intact.

The second half of the post covers the architecture of the tool itself: how a local Go daemon manages a persistent Chrome connection over CDP, how the CLI and MCP server mode share the same underlying command layer, how sessions are encrypted with AES-256-GCM for safe use in CI pipelines, and how LambdaTest cloud integration fits into the same command surface without special-casing. The goal is a reference design for anyone building AI-integrated developer tooling where token efficiency, stability, and distribution simplicity all matter at the same time.

---

## 7. Product Hunt Launch

---

**Tagline:**

AI browser automation that doesn't break when CSS changes

---

**Description:**

testmu-browser-agent-public is an open source CLI and MCP server that gives AI coding assistants reliable, token-efficient browser control.

Most browser automation tools expose raw HTML to AI agents — expensive in tokens and fragile when CSS changes. testmu-browser-agent-public exposes a compact accessibility tree with stable `@ref` IDs instead. Elements are referenced by role and meaning, not by CSS selectors, so AI-driven tests survive UI refactors.

Single Go binary. 90+ commands. 10 MCP tools. Works natively with Claude Code, Cursor, GitHub Copilot, Codex, Gemini CLI, Windsurf, Goose, OpenCode, and Cline.

Install: `curl -fsSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public-public/main/scripts/install.sh | sh`

Or: `npm install -g testmu-browser-agent-public`

Features:
- Stable @ref IDs via accessibility tree — survives CSS changes
- Up to 90% token reduction vs raw HTML dumps
- AES-256-GCM encrypted session persistence
- LambdaTest cloud integration built in
- Comprehensive E2E test suite
- MIT license

---

**First Comment (Maker comment):**

Hey Product Hunt — maker here.

The core problem testmu-browser-agent-public is solving: AI browser agents generate CSS selectors that break constantly, and they dump entire HTML pages into context burning thousands of tokens per step.

The fix we landed on is using Chrome's accessibility tree instead of the DOM. Each element gets a short stable `@ref` ID tied to its semantic role, not its visual structure. The AI navigates using those IDs, and a local Go daemon resolves them to real DOM nodes via CDP. Token usage drops up to 90%. Selectors are resistant to routine frontend changes.

The project ships as a single static binary so there's no runtime to install — just `curl | sh` and point your AI tool at it. We've tested MCP integration against 9 different AI tools and all 85 E2E tests pass.

We'd love to hear from anyone using AI assistants for browser testing or web scraping — especially about edge cases in the `@ref` system or AI tools we haven't integrated yet. Feedback here or in GitHub issues.

https://github.com/4DvAnCeBoY/testmu-browser-agent-public-public
