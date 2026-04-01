#!/bin/sh
# install-plugins.sh — configure testmu-browser-agent as an MCP server for AI coding tools
# Usage: ./scripts/install-plugins.sh [OPTIONS]
#
# Options:
#   --yes              Non-interactive mode; accept all prompts automatically
#   --lambdatest       Pre-enable LambdaTest cloud (will prompt for credentials)
#   --tool <name>      Configure a specific tool only (see SUPPORTED TOOLS below)
#   --help             Show this help message
#
# Supported tool names: claude-code, cursor, copilot, windsurf, gemini-cli, codex, goose, opencode, cline

set -e

# ---------------------------------------------------------------------------
# Color helpers (degraded gracefully when not a tty)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

info()    { printf "${BLUE}[info]${RESET}  %s\n" "$*"; }
success() { printf "${GREEN}[ok]${RESET}    %s\n" "$*"; }
warn()    { printf "${YELLOW}[warn]${RESET}  %s\n" "$*"; }
error()   { printf "${RED}[error]${RESET} %s\n" "$*" >&2; }
header()  { printf "\n${BOLD}%s${RESET}\n" "$*"; }

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
YES=0
LAMBDATEST=0
ONLY_TOOL=""

while [ $# -gt 0 ]; do
  case "$1" in
    --yes)          YES=1 ;;
    --lambdatest)   LAMBDATEST=1 ;;
    --tool)         shift; ONLY_TOOL="$1" ;;
    --help|-h)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      echo "Run with --help for usage."
      exit 1
      ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# Prerequisite: binary must be installed
# ---------------------------------------------------------------------------
if ! command -v testmu-browser-agent >/dev/null 2>&1; then
  error "testmu-browser-agent is not installed or not on PATH."
  echo ""
  echo "Install it first:"
  echo "  curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh"
  exit 1
fi
info "Found $(testmu-browser-agent --version 2>/dev/null || echo 'testmu-browser-agent')"

# ---------------------------------------------------------------------------
# Prerequisite: jq must be available for JSON merging
# ---------------------------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  warn "jq is not installed. It is required to safely merge JSON config files."
  echo ""
  echo "Install jq:"
  echo "  macOS:   brew install jq"
  echo "  Ubuntu:  sudo apt-get install jq"
  echo "  Fedora:  sudo dnf install jq"
  echo "  Windows: winget install jqlang.jq  (or scoop install jq)"
  exit 1
fi

# ---------------------------------------------------------------------------
# Prompting helpers
# ---------------------------------------------------------------------------

# ask_yn QUESTION DEFAULT
# DEFAULT: "y" or "n"
# Returns 0 for yes, 1 for no
ask_yn() {
  question="$1"
  default="$2"
  if [ "$YES" -eq 1 ]; then
    return 0
  fi
  if [ "$default" = "y" ]; then
    prompt="[Y/n]"
  else
    prompt="[y/N]"
  fi
  printf "%s %s " "$question" "$prompt"
  read -r answer </dev/tty
  answer=$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')
  if [ -z "$answer" ]; then
    answer="$default"
  fi
  [ "$answer" = "y" ] || [ "$answer" = "yes" ]
}

ask_value() {
  prompt="$1"
  printf "%s: " "$prompt"
  read -r value </dev/tty
  printf '%s' "$value"
}

# ---------------------------------------------------------------------------
# JSON merge helper
# Merges $2 (fragment) into $1 (target file) under key $3 (e.g. "mcpServers")
# Creates the file with the fragment if it does not exist.
# Backs up the original file before modifying.
# ---------------------------------------------------------------------------
merge_mcp_key() {
  target_file="$1"
  fragment_file="$2"
  key="$3"           # e.g. "mcpServers" or "servers"

  # Derive the server entry from the fragment
  server_name=$(jq -r ".$key | keys[0]" "$fragment_file")
  server_value=$(jq ".$key[\"$server_name\"]" "$fragment_file")

  if [ ! -f "$target_file" ]; then
    # Create fresh file
    mkdir -p "$(dirname "$target_file")"
    jq -n --argjson sv "$server_value" \
       --arg key "$key" \
       --arg sn "$server_name" \
       '{($key): {($sn): $sv}}' > "$target_file"
    success "Created $target_file"
    return
  fi

  # Back up
  backup="${target_file}.bak.$(date +%Y%m%d%H%M%S)"
  cp "$target_file" "$backup"
  info "Backed up existing config to $backup"

  # Merge: add/overwrite only the one server entry
  tmp=$(mktemp)
  jq --argjson sv "$server_value" \
     --arg key "$key" \
     --arg sn "$server_name" \
     '.[$key][$sn] = $sv' "$target_file" > "$tmp"
  mv "$tmp" "$target_file"
  success "Updated $target_file"
}

# ---------------------------------------------------------------------------
# LambdaTest config resolution
# ---------------------------------------------------------------------------
# Sets FRAGMENT_SUFFIX to "" (local) or "-lambdatest" (cloud)
# and populates LT_USERNAME / LT_ACCESS_KEY if cloud chosen.
resolve_lambdatest() {
  FRAGMENT_SUFFIX=""
  if [ "$LAMBDATEST" -eq 1 ] || ask_yn "  Enable LambdaTest cloud?" "n"; then
    LAMBDATEST=1
    FRAGMENT_SUFFIX="-lambdatest"
    if [ -z "$LT_USERNAME" ]; then
      LT_USERNAME=$(ask_value "  LambdaTest username")
    fi
    if [ -z "$LT_ACCESS_KEY" ]; then
      LT_ACCESS_KEY=$(ask_value "  LambdaTest access key")
    fi
    export LT_USERNAME LT_ACCESS_KEY
    info "LambdaTest cloud enabled (credentials stored in environment for this session)"
  fi
}

# ---------------------------------------------------------------------------
# Per-tool configuration functions
# ---------------------------------------------------------------------------

CONFIGURED=""

configure_claude_code() {
  header "Claude Code"
  ask_yn "  Configure testmu-browser-agent for Claude Code?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.claude/settings.json"
  fragment="$(dirname "$0")/../plugins/claude-code/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Claude Code"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED claude-code"
}

configure_cursor() {
  header "Cursor"
  ask_yn "  Configure testmu-browser-agent for Cursor?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.cursor/mcp.json"
  fragment="$(dirname "$0")/../plugins/cursor/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Cursor"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED cursor"
}

configure_copilot() {
  header "VS Code + GitHub Copilot"
  ask_yn "  Configure testmu-browser-agent for VS Code + Copilot?" "y" || return 0
  resolve_lambdatest
  # VS Code MCP settings live in settings.json under "mcp.servers"
  # but the copilot plugin fragment uses "servers" key for the dedicated mcp.json
  target="$HOME/.vscode/mcp.json"
  fragment="$(dirname "$0")/../plugins/copilot/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Copilot"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "servers"
  CONFIGURED="$CONFIGURED copilot"
}

configure_windsurf() {
  header "Windsurf"
  ask_yn "  Configure testmu-browser-agent for Windsurf?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.codeium/windsurf/mcp_config.json"
  fragment="$(dirname "$0")/../plugins/windsurf/mcp_config${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Windsurf"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED windsurf"
}

configure_gemini_cli() {
  header "Gemini CLI"
  ask_yn "  Configure testmu-browser-agent for Gemini CLI?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.gemini/mcp.json"
  fragment="$(dirname "$0")/../plugins/gemini-cli/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Gemini CLI"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED gemini-cli"
}

configure_codex() {
  header "Codex"
  ask_yn "  Configure testmu-browser-agent for Codex?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.codex/mcp.json"
  fragment="$(dirname "$0")/../plugins/codex/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Codex"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED codex"
}

configure_goose() {
  header "Goose"
  ask_yn "  Configure testmu-browser-agent for Goose?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.config/goose/mcp.json"
  fragment="$(dirname "$0")/../plugins/goose/mcp${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Goose"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED goose"
}

configure_opencode() {
  header "OpenCode"
  ask_yn "  Configure testmu-browser-agent for OpenCode?" "y" || return 0
  resolve_lambdatest
  target="$HOME/.opencode/config.json"
  fragment="$(dirname "$0")/../plugins/opencode/config${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping OpenCode"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED opencode"
}

configure_cline() {
  header "Cline (VS Code extension)"
  ask_yn "  Configure testmu-browser-agent for Cline?" "y" || return 0
  resolve_lambdatest

  # Detect platform-specific settings path
  case "$(uname -s)" in
    Darwin)
      target="$HOME/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
      ;;
    Linux)
      target="$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      target="${APPDATA}/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json"
      ;;
    *)
      warn "Unsupported platform for Cline auto-config. Edit the settings file manually."
      return 0
      ;;
  esac

  fragment="$(dirname "$0")/../plugins/cline/mcp_settings${FRAGMENT_SUFFIX}.json"
  if [ ! -f "$fragment" ]; then
    warn "Plugin fragment not found: $fragment — skipping Cline"
    return 0
  fi
  merge_mcp_key "$target" "$fragment" "mcpServers"
  CONFIGURED="$CONFIGURED cline"
}

# ---------------------------------------------------------------------------
# Detection helpers
# ---------------------------------------------------------------------------

tool_detected() {
  tool="$1"
  case "$tool" in
    claude-code)
      [ -d "$HOME/.claude" ] && return 0
      return 1
      ;;
    cursor)
      [ -d "$HOME/.cursor" ] && return 0
      command -v cursor >/dev/null 2>&1 && return 0
      return 1
      ;;
    copilot)
      [ -d "$HOME/.vscode" ] && return 0
      command -v code >/dev/null 2>&1 && return 0
      return 1
      ;;
    windsurf)
      [ -d "$HOME/.codeium/windsurf" ] && return 0
      command -v windsurf >/dev/null 2>&1 && return 0
      return 1
      ;;
    gemini-cli)
      command -v gemini >/dev/null 2>&1 && return 0
      [ -d "$HOME/.gemini" ] && return 0
      return 1
      ;;
    codex)
      command -v codex >/dev/null 2>&1 && return 0
      [ -d "$HOME/.codex" ] && return 0
      return 1
      ;;
    goose)
      command -v goose >/dev/null 2>&1 && return 0
      [ -d "$HOME/.config/goose" ] && return 0
      return 1
      ;;
    opencode)
      command -v opencode >/dev/null 2>&1 && return 0
      [ -d "$HOME/.opencode" ] && return 0
      return 1
      ;;
    cline)
      case "$(uname -s)" in
        Darwin) [ -d "$HOME/Library/Application Support/Code/User/globalStorage/saoudrizwan.claude-dev" ] && return 0 ;;
        Linux)  [ -d "$HOME/.config/Code/User/globalStorage/saoudrizwan.claude-dev" ] && return 0 ;;
        MINGW*|MSYS*|CYGWIN*) [ -d "${APPDATA}/Code/User/globalStorage/saoudrizwan.claude-dev" ] && return 0 ;;
      esac
      return 1
      ;;
  esac
  return 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

printf "\n${BOLD}testmu-browser-agent — Plugin Installer${RESET}\n"
printf "==========================================\n"

ALL_TOOLS="claude-code cursor copilot windsurf gemini-cli codex goose opencode cline"

if [ -n "$ONLY_TOOL" ]; then
  # Validate
  found=0
  for t in $ALL_TOOLS; do
    [ "$t" = "$ONLY_TOOL" ] && found=1 && break
  done
  if [ "$found" -eq 0 ]; then
    error "Unknown tool: $ONLY_TOOL"
    echo "Supported tools: $ALL_TOOLS"
    exit 1
  fi
  info "Configuring $ONLY_TOOL only"
  TOOLS_TO_RUN="$ONLY_TOOL"
else
  # Auto-detect installed tools
  info "Scanning for installed AI coding tools..."
  TOOLS_TO_RUN=""
  for t in $ALL_TOOLS; do
    if tool_detected "$t"; then
      info "  Detected: $t"
      TOOLS_TO_RUN="$TOOLS_TO_RUN $t"
    fi
  done
  if [ -z "$TOOLS_TO_RUN" ]; then
    warn "No supported AI coding tools detected."
    echo ""
    echo "You can configure a specific tool manually with:"
    echo "  $0 --tool <name>"
    echo ""
    echo "Supported tools: $ALL_TOOLS"
    exit 0
  fi
fi

# Run configuration for each tool
for tool in $TOOLS_TO_RUN; do
  case "$tool" in
    claude-code) configure_claude_code ;;
    cursor)      configure_cursor ;;
    copilot)     configure_copilot ;;
    windsurf)    configure_windsurf ;;
    gemini-cli)  configure_gemini_cli ;;
    codex)       configure_codex ;;
    goose)       configure_goose ;;
    opencode)    configure_opencode ;;
    cline)       configure_cline ;;
  esac
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
header "Summary"
if [ -z "$CONFIGURED" ]; then
  info "No tools were configured."
else
  for t in $CONFIGURED; do
    success "$t — configured"
  done
  echo ""
  info "Restart the configured tools to pick up the new MCP server."
  if [ "$LAMBDATEST" -eq 1 ]; then
    echo ""
    warn "LambdaTest cloud is enabled. Make sure LT_USERNAME and LT_ACCESS_KEY"
    warn "are set in the environment where you launch your AI coding tool."
  fi
fi
echo ""
