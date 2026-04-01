#!/bin/sh
# testmu-browser-agent — Claude Code setup
# Usage: curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/plugins/claude-code/setup.sh | sh
#
# This script:
#   1. Installs the testmu-browser-agent binary (if not already installed)
#   2. Registers the MCP server in ~/.claude/settings.json
#   3. Installs the skill to .claude/skills/ in the current project
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

# ─── Step 2: Register MCP server in ~/.claude/settings.json ───
info "Configuring MCP server..."
SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"

if [ -f "$SETTINGS_FILE" ]; then
    # Check if already configured
    if grep -q "testmu-browser-agent" "$SETTINGS_FILE" 2>/dev/null; then
        info "MCP server already registered in $SETTINGS_FILE"
    else
        # Merge into existing settings using python (available on macOS/Linux)
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json, sys

with open('$SETTINGS_FILE', 'r') as f:
    settings = json.load(f)

if 'mcpServers' not in settings:
    settings['mcpServers'] = {}

settings['mcpServers']['testmu-browser-agent'] = {
    'command': 'testmu-browser-agent',
    'args': ['mcp'],
    'env': {}
}

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')
"
            info "MCP server added to $SETTINGS_FILE"
        else
            warn "Cannot merge settings (python3 not found). Add manually:"
            warn '  "testmu-browser-agent": { "command": "testmu-browser-agent", "args": ["mcp"] }'
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

# ─── Step 3: Install skill to current project ───
info "Installing skill to current project..."
SKILL_DIR=".claude/skills/testmu-browser-agent"
mkdir -p "$SKILL_DIR/references" "$SKILL_DIR/templates"

# Download skill files from the repo
BASE_RAW="https://raw.githubusercontent.com/${REPO}/main/skills/testmu-browser-agent"

# Download SKILL.md with the proper frontmatter (allowed-tools: Bash(testmu-browser-agent:*))
curl -sSfL "$BASE_RAW/SKILL.md" -o "$SKILL_DIR/SKILL.md"

# Verify frontmatter is present; if not, prepend it
if ! grep -q "allowed-tools:" "$SKILL_DIR/SKILL.md" 2>/dev/null; then
    warn "SKILL.md missing frontmatter — patching..."
    TMP=$(mktemp)
    printf -- '---\nname: testmu-browser-agent\ndescription: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task.\nallowed-tools: Bash(testmu-browser-agent:*)\n---\n\n' > "$TMP"
    cat "$SKILL_DIR/SKILL.md" >> "$TMP"
    mv "$TMP" "$SKILL_DIR/SKILL.md"
    info "Frontmatter patched into $SKILL_DIR/SKILL.md"
fi
curl -sSfL "$BASE_RAW/references/commands.md" -o "$SKILL_DIR/references/commands.md" 2>/dev/null || true
curl -sSfL "$BASE_RAW/references/snapshot-refs.md" -o "$SKILL_DIR/references/snapshot-refs.md" 2>/dev/null || true
curl -sSfL "$BASE_RAW/references/mcp-tools.md" -o "$SKILL_DIR/references/mcp-tools.md" 2>/dev/null || true
curl -sSfL "$BASE_RAW/references/session-management.md" -o "$SKILL_DIR/references/session-management.md" 2>/dev/null || true
curl -sSfL "$BASE_RAW/templates/form-automation.sh" -o "$SKILL_DIR/templates/form-automation.sh" 2>/dev/null || true
curl -sSfL "$BASE_RAW/templates/authenticated-session.sh" -o "$SKILL_DIR/templates/authenticated-session.sh" 2>/dev/null || true
curl -sSfL "$BASE_RAW/templates/capture-workflow.sh" -o "$SKILL_DIR/templates/capture-workflow.sh" 2>/dev/null || true

info "Skill installed to $SKILL_DIR/"

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
