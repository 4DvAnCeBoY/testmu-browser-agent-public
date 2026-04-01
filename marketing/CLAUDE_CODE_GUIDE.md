# Give Claude Code Eyes and Hands on the Web

You can already ask Claude Code to write code, refactor files, and run tests. Now you can ask it to open a browser, click a button, fill out a form, and screenshot the result — all from a single prompt, no Playwright script required.

**testmu-browser-agent** is a one-binary MCP server that gives Claude Code a real Chrome browser it controls directly. Claude navigates, reads the page, reasons about what to do next, and acts — in a loop, until your task is done.

```
You: "Log into GitHub and screenshot my notification count."

Claude: [opens github.com/login]
        [takes snapshot → sees @e1 username, @e2 password, @e3 sign-in button]
        [fills @e1, fills @e2, clicks @e3]
        [waits for dashboard to load]
        [takes screenshot → done]
```

No CSS selectors. No Playwright boilerplate. No script to write and debug. Just a prompt.

---

## 30-Second Setup

### Step 1 — Install the binary

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

Or via npm:

```bash
npm install -g testmu-browser-agent
```

Or via Homebrew:

```bash
brew install testmu/tap/testmu-browser-agent
```

One binary. No Node runtime. No Python environment. No Chromium download step.

### Step 2 — Add the MCP server to Claude Code

Add this to `~/.claude/settings.json` (user-wide) or `.claude/settings.json` (project-only):

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

### Step 3 — (Optional) Install as a Skill

The plugin installer auto-detects your AI coding tools and configures them all:

```bash
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install-plugins.sh | sh
```

That's it. Restart Claude Code and ask it to open a website.

> **Verify it works:** Ask Claude: *"Navigate to https://example.com and take a screenshot."*
> Claude will call `browser_navigate` and `browser_media` — you'll see the tool calls in the sidebar.

---

## How Claude Uses It

Understanding the loop makes you a better prompt writer. Here is exactly what happens when you give Claude a browser task:

```
┌─────────────────────────────────────────────────────────┐
│  1. You give Claude a task in plain English              │
│                                                         │
│  2. Claude calls browser_navigate                       │
│     → opens the URL, waits for page load                │
│                                                         │
│  3. Claude calls browser_query { action: "snapshot" }   │
│     → gets back an accessibility tree with @ref IDs     │
│                                                         │
│  4. Claude reads the snapshot and reasons:              │
│     "I see @e1 is the email field, @e3 is submit"       │
│                                                         │
│  5. Claude calls browser_interact with the @ref         │
│     → click, fill, press — whatever the task needs      │
│                                                         │
│  6. Claude calls browser_query again to verify          │
│     → did the action work? did the page change?         │
│                                                         │
│  7. Repeat until task is complete                       │
└─────────────────────────────────────────────────────────┘
```

### Why @ref IDs instead of CSS selectors?

When Claude reads a snapshot it sees output like this:

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

Every interactive element has a stable `@ref` ID — `@e1`, `@e2`, etc. These come from the accessibility tree, not the DOM. They survive React re-renders, framework hydration, dynamic class names, and CSS-in-JS changes. Claude just picks the ref for the element it wants and uses it directly. No guessing. No fragile selectors.

### Why snapshots instead of HTML?

| What Claude receives | Size for a login form |
|---|---|
| Full HTML via CDP | ~12,000 tokens |
| DOM snapshot | ~4,000–8,000 tokens |
| Playwright accessibility tree | ~800–1,500 tokens |
| **testmu-browser-agent snapshot** | **~200–400 tokens** |

Smaller context = cheaper inference + more room for your actual task. Claude can read the snapshot for an entire single-page app without burning most of its context window.

### Daemon mode — the browser persists

testmu-browser-agent keeps a single Chrome process alive between tool calls (daemon mode). Claude can make 10 consecutive MCP calls without any browser cold-start overhead. The session — tabs, cookies, local storage — is exactly where it was after the previous call.

---

## Real-World Workflows

### Workflow 1: Log into GitHub and check notifications

**You:**
> "Log into GitHub with my credentials and tell me how many notifications I have."

**What Claude does:**

```
browser_navigate
  action: "open"
  url: "https://github.com/login"

browser_query
  action: "snapshot"

→ Returns:
  [textbox] Username or email address @e1
  [textbox] Password @e2
  [button] Sign in @e3

browser_interact
  action: "fill"
  selector: "@e1"
  text: "monalisa"

browser_interact
  action: "fill"
  selector: "@e2"
  text: "••••••••"

browser_interact
  action: "click"
  selector: "@e3"

browser_wait
  url: "https://github.com"

browser_query
  action: "snapshot"

→ Returns:
  [link] 3 notifications @e14
  ...

Claude: "You have 3 unread notifications."
```

---

### Workflow 2: Fill out a form and submit it

**You:**
> "Go to https://app.example.com/contact and submit the contact form with my name 'Alex Rivera', email 'alex@example.com', and the message 'Interested in your enterprise plan'. Screenshot the confirmation."

**What Claude does:**

```
browser_navigate
  action: "open"
  url: "https://app.example.com/contact"

browser_query
  action: "snapshot"

→ Returns:
  [textbox] Name @e1
  [textbox] Email @e2
  [textbox] Message @e4
  [button] Send Message @e5

browser_interact
  action: "fill"
  selector: "@e1"
  text: "Alex Rivera"

browser_interact
  action: "fill"
  selector: "@e2"
  text: "alex@example.com"

browser_interact
  action: "fill"
  selector: "@e4"
  text: "Interested in your enterprise plan"

browser_interact
  action: "click"
  selector: "@e5"

browser_wait
  text: "Thank you"

browser_media
  action: "screenshot"
  output: "confirmation.png"

Claude: "Form submitted. Screenshot saved to confirmation.png. The page shows 'Thank you for reaching out'."
```

---

### Workflow 3: Screenshot every page in a list

**You:**
> "Take a screenshot of each of these pages and save them: https://example.com, https://github.com, https://news.ycombinator.com"

**What Claude does:**

```
browser_navigate { action: "open", url: "https://example.com" }
browser_media { action: "screenshot", output: "example-com.png" }

browser_navigate { action: "open", url: "https://github.com" }
browser_media { action: "screenshot", output: "github-com.png" }

browser_navigate { action: "open", url: "https://news.ycombinator.com" }
browser_media { action: "screenshot", output: "hn.png" }

Claude: "Done. Saved 3 screenshots:
  - example-com.png
  - github-com.png
  - hn.png"
```

This pattern scales. Give Claude a list of 20 URLs, it will loop through all of them. No loop to write yourself.

---

### Workflow 4: Test your deployed app's login flow

**You:**
> "Smoke test the login flow on https://staging.myapp.com — use test@example.com / testpass123. Verify that after login I end up on /dashboard. Screenshot it."

**What Claude does:**

```
browser_navigate
  action: "open"
  url: "https://staging.myapp.com/login"

browser_query
  action: "snapshot"

→ Identifies email field @e1, password @e2, login button @e3

browser_interact { action: "fill", selector: "@e1", text: "test@example.com" }
browser_interact { action: "fill", selector: "@e2", text: "testpass123" }
browser_interact { action: "click", selector: "@e3" }

browser_wait
  url: "https://staging.myapp.com/dashboard"
  timeout: 15

browser_media { action: "screenshot", output: "dashboard-smoke.png" }

Claude: "Login flow passed. Redirected to /dashboard as expected.
         Screenshot saved to dashboard-smoke.png."
```

If the redirect fails, Claude will tell you what URL it ended up on and what the snapshot shows — instant debug output.

---

### Workflow 5: Monitor a page for changes

**You:**
> "Check https://status.myservice.com every 30 seconds for 5 minutes. Tell me if the status changes from 'All systems operational'."

**What Claude does:**

```
# Round 1
browser_navigate { action: "open", url: "https://status.myservice.com" }
browser_query { action: "snapshot" }
→ Stores: "All systems operational"

browser_wait { timeout: 30000 }

# Round 2
browser_navigate { action: "reload" }
browser_query { action: "snapshot" }
→ Compares to stored value

# ... repeats 10 times total

Claude: "Monitored for 5 minutes (10 checks). Status remained
         'All systems operational' throughout."
```

Or if something changes:

```
Claude: "Alert — status changed at check 4 (2:03pm):
         Was: 'All systems operational'
         Now: 'Partial outage — API degraded'"
```

---

## MCP Tools Reference

All 10 tools, with their actions:

| Tool | Actions / Conditions | What it does |
|---|---|---|
| `browser_navigate` | `open`, `navigate`, `back`, `forward`, `reload`, `close` | Navigate the browser: open URLs, move through history, reload or close |
| `browser_interact` | `click`, `dblclick`, `fill`, `type`, `press`, `select`, `scroll`, `hover`, `tap`, `drag`, `upload`, `focus`, `check`, `uncheck`, `swipe` | Interact with elements: clicks, forms, keyboard, gestures, file upload |
| `browser_query` | `snapshot`, `get`, `find`, `eval`, `inspect` | Read the page: accessibility tree, DOM content, element search, JavaScript |
| `browser_media` | `screenshot`, `pdf`, `record` | Capture media: PNG/JPEG screenshots, PDF export, video recording |
| `browser_state` | `cookies_get`, `cookies_set`, `cookies_clear`, `cookies_delete`, `state_save`, `state_load`, `state_list`, `state_clean`, `state_delete`, `storage`, `clipboard` | Browser state: cookies, saved sessions, localStorage, clipboard |
| `browser_tabs` | `tabs`, `tab`, `window`, `frame` | Tab management: open, close, switch tabs; switch to iframes |
| `browser_wait` | no `action` field — use condition fields: `selector`, `url`, `text`, `load`, `function`, `download`, `timeout` | Wait for conditions: element visible, URL change, text appears, load state, JS condition, download, fixed delay |
| `browser_config` | `set`, `connect`, `vision_deficiency`, `cpu_throttle`, `bypass_csp`, `media_emulate`, `touch_emulation` | Configure: viewport, user-agent, remote CDP, vision/CPU/CSP/media/touch emulation |
| `browser_network` | `console`, `errors`, `dialog`, `highlight`, `stream_enable`, `stream_disable`, `stream_status`, `requests`, `request_detail`, `har_start`, `har_stop` | Monitor: console logs, page errors, dialog handling, event streaming, network requests, HAR capture |
| `browser_devtools` | `trace`, `profiler`, `batch`, `performance_metrics`, `ax_query`, `browser_logs`, `frame_tree`, `dom_snapshot`, `webauthn` | DevTools: performance tracing, CPU profiling, batch execution, AX query, DOM snapshot, WebAuthn |

Claude has all 10 tools available the moment you restart after adding the MCP config. It picks the right tool for each step automatically.

---

## Advanced: LambdaTest Cloud

No local Chrome required. Run every browser session on LambdaTest's real browser infrastructure — directly from Claude Code.

### Setup

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

Get your `LT_USERNAME` and `LT_ACCESS_KEY` from the [LambdaTest Automation Dashboard](https://automation.lambdatest.com/).

### What this unlocks

- **No local Chrome** — works in CI environments that don't have a display
- **Session recordings** — LambdaTest saves video of every session automatically
- **Parallel sessions** — run multiple Claude browser tasks simultaneously
- **Real browsers** — Chrome, Firefox, Edge, Safari on real OS/browser combinations
- **Same commands** — every MCP tool call works identically, local or cloud

### Example: CI pipeline smoke test

```yaml
# .github/workflows/smoke.yml
- name: Configure testmu credentials
  run: |
    mkdir -p ~/.claude
    cat > ~/.claude/settings.json << 'EOF'
    {
      "mcpServers": {
        "testmu-browser-agent": {
          "command": "testmu-browser-agent",
          "args": ["mcp", "--provider", "lambdatest"],
          "env": {
            "LT_USERNAME": "${{ secrets.LT_USERNAME }}",
            "LT_ACCESS_KEY": "${{ secrets.LT_ACCESS_KEY }}"
          }
        }
      }
    }
    EOF

- name: Smoke test via Claude Code
  run: |
    claude -p "Open ${{ env.DEPLOY_URL }}/login, fill email test@example.com and password testpass, click login, verify redirect to /dashboard, screenshot it to smoke-result.png"
```

Claude handles the entire flow. The LambdaTest dashboard shows the video replay if something fails.

---

## Advanced: Session Persistence

Save your authenticated state and reuse it across Claude Code conversations. Log in once, never log in again.

### Save a session after login

Ask Claude:
> "Log into https://app.example.com with email@example.com / mypassword, then save the session state to app-session."

Claude will call:

```
browser_navigate { action: "open", url: "https://app.example.com/login" }
# ... fill and submit login form ...
browser_state { action: "state_save", name: "app-session" }
```

### Load the session in a future conversation

Ask Claude:
> "Load the app-session state and check my account dashboard."

Claude will call:

```
browser_state { action: "state_load", name: "app-session" }
browser_navigate { action: "open", url: "https://app.example.com/dashboard" }
browser_query { action: "snapshot" }
# → Already logged in, dashboard loads immediately
```

Session state is encrypted at rest with AES-256-GCM. Your cookies and localStorage never appear in plaintext in any log file.

### Why this matters

Multi-step tasks that require authentication — checking your dashboard, scraping data behind a login, running tests on a private staging environment — no longer require re-entering credentials every time. Save once, reference by name.

---

## Tips for Best Results

### Be specific about what "done" looks like

Instead of: *"Log into GitHub"*

Try: *"Log into GitHub with username monalisa and password hunter2. Verify you land on the home feed and tell me how many open pull requests are listed in the sidebar."*

Claude uses the end condition to know when to stop and what to report back.

### Reference the URL explicitly

Instead of: *"Go to my app and check the settings"*

Try: *"Open https://app.example.com/settings and take a snapshot."*

Claude can construct URLs from context, but explicit URLs are faster and more reliable.

### Ask for a screenshot at the end

Adding *"screenshot the result"* to any task gives you visual confirmation without having to re-run anything. Claude saves the PNG to your working directory.

### Use "snapshot first" for exploration

If you're not sure what's on a page:
> "Open https://app.example.com/admin and take a snapshot. Tell me what links and buttons are available."

Claude reads the accessibility tree and summarizes it in plain English. This is faster than asking it to screenshot and describe — the snapshot is structured data, not pixels.

### Chain tasks naturally

You don't have to give Claude one step at a time. Give it the whole workflow:

> "Open https://app.example.com, log in with test@example.com / test123, go to Settings > Billing, find the current plan name, then close the browser."

Claude will plan the steps, execute them in order, and report back when done.

### Debug failures by asking for details

If something goes wrong, ask:
> "What does the current snapshot show? What URL are you on?"

Claude will call `browser_query` and report the current page state — instant context for debugging without you having to open a browser yourself.

---

## Before & After

### The old way: write a Playwright script

```javascript
// login-test.js — 50+ lines, you wrote and debugged this yourself
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();

  await page.goto('https://staging.myapp.com/login');
  await page.waitForSelector('#email');
  await page.fill('#email', 'test@example.com');
  await page.fill('#password', 'testpass123');
  await page.click('button[type="submit"]');

  await page.waitForURL('**/dashboard');

  if (!page.url().includes('/dashboard')) {
    throw new Error('Login redirect failed');
  }

  await page.screenshot({ path: 'dashboard.png' });
  await browser.close();

  console.log('Login test passed.');
})();
```

You wrote this. Then you debugged it when selectors changed. Then you updated it when the login form added a CAPTCHA. Then you updated it again when the submit button changed from `button[type="submit"]` to a `div` with an `onClick` handler.

### The new way: one prompt to Claude

```
"Smoke test the login flow on https://staging.myapp.com —
use test@example.com / testpass123. Verify redirect to /dashboard.
Screenshot the result."
```

Claude writes no scripts. It reads the actual accessibility tree of the live page, finds the right elements by their semantic role and label (not their CSS class), fills them, and verifies the result. When the login form changes, Claude adapts because it re-reads the snapshot every time.

No maintenance. No fragile selectors. No boilerplate.

---

## Get Started

```bash
# 1. Install
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh

# 2. Add to Claude Code settings
# ~/.claude/settings.json → see "30-Second Setup" above

# 3. Restart Claude Code

# 4. Try it
# Ask Claude: "Open https://example.com and tell me what links are on the page."
```

- [GitHub](https://github.com/4DvAnCeBoY/testmu-browser-agent-public) — source, issues, releases
- [Full Command Reference](../docs/guides/commands.md) — every CLI command and flag
- [LambdaTest Integration](../docs/guides/lambdatest.md) — cloud browser setup
- [MCP Protocol Details](../docs/guides/mcp-integration.md) — tool schemas, JSON-RPC examples
- [Skills & Other AI Tools](../skills/README.md) — Cursor, Windsurf, Copilot, Codex, Gemini
