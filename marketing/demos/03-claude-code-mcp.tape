Output marketing/demos/03-claude-code-mcp.gif

Set FontSize 15
Set Width 1000
Set Height 700
Set Theme "Catppuccin Mocha"
Set Padding 20

# ─────────────────────────────────────────────
# Demo: MCP Integration with Claude Code
# ─────────────────────────────────────────────

Type "# testmu-browser-agent — Claude Code MCP Integration"
Enter
Sleep 1s

# Show the MCP config — just 5 lines
Type "cat ~/.claude/claude_desktop_config.json"
Enter
Sleep 2s

# Explain what Claude sees
Type "# That's it — Claude Code now has browser control via MCP"
Enter
Sleep 1500ms

Type "# Here's what Claude does under the hood..."
Enter
Sleep 1s

# Demonstrate the exact CLI commands Claude sends via MCP
Type "bin/testmu-browser-agent open https://news.ycombinator.com"
Enter
Sleep 2500ms

# Snapshot to see the page structure
Type "bin/testmu-browser-agent snapshot"
Enter
Sleep 3s

# Get page title
Type "bin/testmu-browser-agent get title"
Enter
Sleep 1500ms

# Click the first story link
Type "bin/testmu-browser-agent click @e3"
Enter
Sleep 2500ms

# Take a screenshot of the article
Type "bin/testmu-browser-agent screenshot --output marketing/demos/screenshots/mcp-article.png"
Enter
Sleep 2s

# Eval JS to extract headline text
Type "bin/testmu-browser-agent eval 'document.title'"
Enter
Sleep 1500ms

# Go back
Type "bin/testmu-browser-agent back"
Enter
Sleep 1500ms

Type "# All of this runs automatically when Claude Code uses the MCP server"
Enter
Sleep 2s

Type "bin/testmu-browser-agent close"
Enter
Sleep 1s
