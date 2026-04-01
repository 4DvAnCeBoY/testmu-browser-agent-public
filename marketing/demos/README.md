# testmu-browser-agent — Demo Assets

This directory contains runnable demo scripts and VHS tape files for recording
terminal GIF demos of testmu-browser-agent.

---

## Available Demos

| File | Type | What it shows |
|------|------|---------------|
| `demo-quick-start.sh` | Shell script | Open a URL, snapshot, click a link, screenshot, close |
| `demo-form-fill.sh` | Shell script | Discover form refs, fill fields, submit, verify |
| `demo-auth-session.sh` | Shell script | Login, save state, close, reopen, restore session |
| `01-quick-start.tape` | VHS tape | Core workflow in ~30 seconds (renders to GIF) |
| `02-form-automation.tape` | VHS tape | Form fill flow with @ref IDs (renders to GIF) |
| `03-claude-code-mcp.tape` | VHS tape | MCP integration with Claude Code (renders to GIF) |

---

## Running the Shell Scripts

All scripts must be run from the **project root** (not from this directory):

```bash
# Quick start
bash marketing/demos/demo-quick-start.sh

# Form fill automation
bash marketing/demos/demo-form-fill.sh

# Auth session persistence
bash marketing/demos/demo-auth-session.sh
```

Screenshots are saved to `marketing/demos/screenshots/`.

---

## Recording GIFs with VHS

[VHS](https://github.com/charmbracelet/vhs) turns `.tape` files into polished
terminal GIFs. Install it once, then run any tape:

```bash
# Install (macOS)
brew install vhs

# Record a single demo
vhs marketing/demos/01-quick-start.tape

# Record all demos
for tape in marketing/demos/*.tape; do vhs "$tape"; done
```

GIF output files are written alongside the tape files:

- `marketing/demos/01-quick-start.gif`
- `marketing/demos/02-form-automation.gif`
- `marketing/demos/03-claude-code-mcp.gif`

> VHS requires a working terminal emulator (`ttyd` or `chromium`) to render
> frames. On CI, add `vhs` to your toolchain and run the tape files as part of
> your release pipeline.

---

## Screenshot Output Location

Shell scripts write screenshots to:

```
marketing/demos/screenshots/
  01-open.png                  # quick-start: page opened
  02-clicked.png               # quick-start: after link click
  form-01-open.png             # form-fill: page opened
  form-02-filled.png           # form-fill: fields filled
  form-03-result.png           # form-fill: after submit
  auth-01-login-page.png       # auth: login page
  auth-02-credentials-entered.png
  auth-03-logged-in.png        # auth: after login
  auth-04-session-restored.png # auth: session restored after reopen
  mcp-article.png              # mcp demo: article page
```

---

## Customising the Demos

### Change the URL or credentials
Edit the relevant `.sh` file. The binary, output directory, and state file
paths are declared as variables at the top of each script.

### Change the GIF theme or dimensions
Edit the `Set` directives at the top of any `.tape` file. Available themes
include `"Catppuccin Mocha"`, `"Dracula"`, `"Nord"`, `"Tokyo Night"`, and
any other theme supported by VHS.

### Adjust timing
Increase `Sleep` durations in tape files if your machine is slower, or if
you want more time for viewers to read each command.

---

## Prerequisites

- `bin/testmu-browser-agent` built and on PATH (or referenced by relative path from project root)
- Chrome or Chromium installed (or run `bin/testmu-browser-agent install`)
- VHS installed for GIF recording (`brew install vhs`)
- Network access to `example.com`, `httpbin.org`, `the-internet.herokuapp.com`, `news.ycombinator.com`
