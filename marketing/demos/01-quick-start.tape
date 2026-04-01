Output marketing/demos/01-quick-start.gif

Set FontSize 16
Set Width 900
Set Height 600
Set Theme "Catppuccin Mocha"
Set Padding 20

# ─────────────────────────────────────────────
# Demo: Quick Start with testmu-browser-agent
# ─────────────────────────────────────────────

Type "# Quick Start with testmu-browser-agent"
Enter
Sleep 1s

# Step 1: Open a URL
Type "bin/testmu-browser-agent open https://example.com"
Enter
Sleep 2500ms

# Step 2: Take an accessibility snapshot — discover interactive refs
Type "bin/testmu-browser-agent snapshot"
Enter
Sleep 3s

# Step 3: Click the first link using its @ref ID
Type "bin/testmu-browser-agent click @e1"
Enter
Sleep 2s

# Step 4: Capture a screenshot
Type "bin/testmu-browser-agent screenshot --output demo.png"
Enter
Sleep 2s

# Step 5: Close the browser session
Type "bin/testmu-browser-agent close"
Enter
Sleep 1s
