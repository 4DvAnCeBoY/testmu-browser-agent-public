# testmu-browser-agent — AI-Native Browser Automation for the Agentic Era

---

## The Problem

AI agents need to see and interact with the web — but existing browser tools weren't built for them. Screenshots flood context windows with thousands of tokens. CSS selectors break the moment a designer touches the DOM. And spinning up Playwright or Selenium in a CI pipeline is still a multi-step slog.

---

## The Solution

**testmu-browser-agent** is a single Go binary that speaks the language of AI agents. Instead of noisy screenshots, it serves accessibility tree snapshots with stable `@ref` IDs — giving your AI exactly what it needs in ~200 tokens instead of 3,000–5,000. Drop in the MCP config and Claude Code, Cursor, Copilot, Codex, or any of seven other tools can drive a real browser in seconds.

---

## Key Numbers

| Metric | Value |
|---|---|
| CLI commands | 90+ |
| MCP tools | 10 |
| Tokens per snapshot | ~200 (vs. 3,000–5,000 for alternatives) |
| Dependencies | Zero — single static binary |
| AI coding tools supported | 9 (Claude Code, Cursor, Copilot, Codex, Gemini CLI, Windsurf, Goose, OpenCode, Cline) |
| Cloud testing | Built-in LambdaTest integration |
| Credential security | AES-256-GCM encrypted vault |
| Test suite | Comprehensive E2E coverage |

---

## How It Works

```
1. INSTALL    curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh

2. CONNECT    Add one JSON block to your Claude Code MCP config

3. AUTOMATE   "Claude, run a checkout flow on staging and report any errors."
```

That's it. No Dockerfile. No driver binaries. No version pinning.

---

## What Makes It Different

- **Stable `@ref` IDs** — element references survive re-renders; no more flaky selectors
- **Accessibility snapshots** — token-efficient, readable by any LLM, no vision model required
- **REST/SSE daemon** — attach multiple AI agents to one browser session simultaneously
- **Mobile-ready** — Appium integration for native iOS/Android testing in the same workflow
- **Encrypted state** — credentials and session data stored with AES-256-GCM, never plaintext
- **Cross-platform** — macOS, Linux, Windows; amd64 and arm64

---

## Who It's For

- **AI/ML teams** building agents that need reliable web interaction
- **QA engineers** who want to describe tests in plain English and get results
- **DevOps/CI teams** running browser checks without heavyweight infrastructure
- **Developer productivity teams** integrating browser automation into AI-assisted workflows

---

## Why TestMu

TestMu builds infrastructure for the agentic testing era. The team has shipped production-grade browser tooling used across enterprise CI pipelines and brings that reliability to the open-source community. testmu-browser-agent is the first tool purpose-built for the reality that AI agents — not humans — are increasingly the ones clicking around your app.

---

## Get Started

```bash
# Install (macOS / Linux)
curl -sSL https://raw.githubusercontent.com/testmu/testmu-browser-agent/main/scripts/install.sh | sh
```

**GitHub:** github.com/testmu/testmu-browser-agent
**License:** Open source

---

*Open source. Agent-first. Built for the agentic era.*
