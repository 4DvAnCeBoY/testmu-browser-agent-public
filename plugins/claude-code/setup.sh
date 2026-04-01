#!/bin/sh
# testmu-browser-agent — Claude Code setup
# Usage: curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
#
# This script installs everything you need:
#   1. Installs the testmu-browser-agent binary (if not already installed)
#   2. Installs Chrome for Testing (if not already present)
#   3. Registers the MCP server in .claude/settings.json (project-level by default, --global for user-wide)
#   4. Installs the skill to .claude/skills/ (for CLI-based Bash integration)
#
# You get both Skill (CLI via Bash) and MCP (structured tools) — use whichever you prefer.
set -e

REPO="4DvAnCeBoY/testmu-browser-agent-public"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${GREEN}[+]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$1"; }
error() { printf "${RED}[x]${NC} %s\n" "$1"; }

# ─── Step 1: Install binary if needed ───
if command -v testmu-browser-agent >/dev/null 2>&1; then
    info "testmu-browser-agent already installed: $(which testmu-browser-agent)"
else
    info "Installing testmu-browser-agent binary..."

    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64) ARCH="amd64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        *) error "Unsupported architecture: $ARCH"; exit 1 ;;
    esac

    case "$OS" in
        darwin) PLATFORM="darwin" ;;
        linux)  PLATFORM="linux" ;;
        *)      error "Unsupported OS: $OS"; exit 1 ;;
    esac

    BINARY="testmu-browser-agent-${PLATFORM}-${ARCH}"
    VERSION=$(curl -sSf "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"//;s/".*//')

    if [ -z "$VERSION" ]; then
        error "Could not determine latest version"
        exit 1
    fi

    URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY}"
    info "Downloading ${BINARY} (${VERSION})..."

    # Try /usr/local/bin first, fall back to ~/.local/bin
    if [ -w /usr/local/bin ]; then
        INSTALL_DIR="/usr/local/bin"
    else
        INSTALL_DIR="$HOME/.local/bin"
        mkdir -p "$INSTALL_DIR"
    fi

    curl -sSfL "$URL" -o "${INSTALL_DIR}/testmu-browser-agent"
    chmod +x "${INSTALL_DIR}/testmu-browser-agent"

    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        warn "Add to your PATH: export PATH=\"${INSTALL_DIR}:\$PATH\""
    fi

    info "Installed to ${INSTALL_DIR}/testmu-browser-agent"
fi

# ─── Step 1b: Install Chrome for Testing ───
info "Installing Chrome for Testing (skip if already present)..."
if command -v testmu-browser-agent >/dev/null 2>&1; then
    testmu-browser-agent install 2>&1 | tail -3 || warn "Chrome for Testing install failed — will use system Chrome if available."
else
    warn "Binary not on PATH yet — skipping Chrome install. Run 'testmu-browser-agent install' manually."
fi

# ─── Step 2: Register MCP server in .claude/settings.json ───
# Writes to project-level by default; use --global for ~/.claude/settings.json
info "Configuring MCP server..."
if [ "${1:-}" = "--global" ]; then
    SETTINGS_DIR="$HOME/.claude"
    info "Using global config: ~/.claude/settings.json"
else
    SETTINGS_DIR=".claude"
    info "Using project config: .claude/settings.json (pass --global for global)"
fi
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
    # Check if already configured
    if grep -q "testmu-browser-agent" "$SETTINGS_FILE" 2>/dev/null; then
        info "MCP server already registered in $SETTINGS_FILE"
    else
        # Merge into existing settings using jq
        MCP_ENTRY='{"testmu-browser-agent":{"command":"testmu-browser-agent","args":["mcp"],"env":{}}}'
        if command -v jq >/dev/null 2>&1; then
            TMP=$(mktemp)
            jq --argjson entry "$MCP_ENTRY" '.mcpServers += $entry' "$SETTINGS_FILE" > "$TMP" && mv "$TMP" "$SETTINGS_FILE"
            info "MCP server added to $SETTINGS_FILE"
        elif command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
with open('$SETTINGS_FILE','r') as f: s=json.load(f)
s.setdefault('mcpServers',{})['testmu-browser-agent']={'command':'testmu-browser-agent','args':['mcp'],'env':{}}
with open('$SETTINGS_FILE','w') as f: json.dump(s,f,indent=2); f.write('\n')
"
            info "MCP server added to $SETTINGS_FILE"
        else
            warn "Neither jq nor python3 found. Add manually to $SETTINGS_FILE:"
            warn '  "mcpServers": { "testmu-browser-agent": { "command": "testmu-browser-agent", "args": ["mcp"] } }'
        fi
    fi
else
    # Create new settings file
    cat > "$SETTINGS_FILE" << 'SETTINGS'
{
  "mcpServers": {
    "testmu-browser-agent": {
      "command": "testmu-browser-agent",
      "args": ["mcp"],
      "env": {}
    }
  }
}
SETTINGS
    info "Created $SETTINGS_FILE with MCP server config"
fi

# ─── Step 3: Install skill globally + to current project ───
# Global install (~/.claude/skills/) makes the skill available in ALL projects.
# Project install (.claude/skills/) is a local copy for this repo only.

install_skill() {
    local TARGET_DIR="$1"
    local LABEL="$2"
    mkdir -p "$TARGET_DIR/references" "$TARGET_DIR/templates"

    curl -sSfL "$BASE_RAW/SKILL.md" -o "$TARGET_DIR/SKILL.md"

    # Verify frontmatter
    if ! grep -q "allowed-tools:" "$TARGET_DIR/SKILL.md" 2>/dev/null; then
        TMP=$(mktemp)
        printf -- '---\nname: testmu-browser-agent\ndescription: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task.\nallowed-tools: Bash(testmu-browser-agent:*)\n---\n\n' > "$TMP"
        cat "$TARGET_DIR/SKILL.md" >> "$TMP"
        mv "$TMP" "$TARGET_DIR/SKILL.md"
    fi

    curl -sSfL "$BASE_RAW/references/commands.md" -o "$TARGET_DIR/references/commands.md" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/references/snapshot-refs.md" -o "$TARGET_DIR/references/snapshot-refs.md" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/references/mcp-tools.md" -o "$TARGET_DIR/references/mcp-tools.md" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/references/session-management.md" -o "$TARGET_DIR/references/session-management.md" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/templates/form-automation.sh" -o "$TARGET_DIR/templates/form-automation.sh" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/templates/authenticated-session.sh" -o "$TARGET_DIR/templates/authenticated-session.sh" 2>/dev/null || true
    curl -sSfL "$BASE_RAW/templates/capture-workflow.sh" -o "$TARGET_DIR/templates/capture-workflow.sh" 2>/dev/null || true

    info "Skill installed to $LABEL ($TARGET_DIR/)"
}

BASE_RAW="https://raw.githubusercontent.com/${REPO}/main/skills/testmu-browser-agent"

# Global install — available in every project
info "Installing skill globally..."
install_skill "$HOME/.claude/skills/testmu-browser-agent" "global"

# Project install — local copy for current repo
info "Installing skill to current project..."
SKILL_DIR=".claude/skills/testmu-browser-agent"
install_skill "$SKILL_DIR" "project"

# ─── Done ───
echo ""
info "Setup complete! Restart Claude Code to activate."
echo ""
echo "  Try asking Claude:"
echo "    \"Open https://example.com and take a screenshot\""
echo ""
echo "  MCP tools available: browser_navigate, browser_interact,"
echo "  browser_query, browser_media, browser_state, browser_tabs,"
echo "  browser_wait, browser_config, browser_network, browser_devtools"
echo ""
