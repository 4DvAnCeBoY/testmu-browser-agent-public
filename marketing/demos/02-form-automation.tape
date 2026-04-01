Output marketing/demos/02-form-automation.gif

Set FontSize 16
Set Width 900
Set Height 650
Set Theme "Catppuccin Mocha"
Set Padding 20

# ─────────────────────────────────────────────
# Demo: Form Automation with @ref IDs
# ─────────────────────────────────────────────

Type "# Form Automation — fill fields by @ref"
Enter
Sleep 1s

# Step 1: Open the form page
Type "bin/testmu-browser-agent open https://httpbin.org/forms/post"
Enter
Sleep 2500ms

# Step 2: Snapshot — discover all interactive element refs
Type "bin/testmu-browser-agent snapshot"
Enter
Sleep 3s

# Step 3: Fill the customer name field
Type "bin/testmu-browser-agent fill @e1 'Alice Example'"
Enter
Sleep 1500ms

# Step 4: Fill the telephone field
Type "bin/testmu-browser-agent fill @e2 '555-0100'"
Enter
Sleep 1500ms

# Step 5: Fill the email field
Type "bin/testmu-browser-agent fill @e3 'alice@example.com'"
Enter
Sleep 1500ms

# Step 6: Select pizza size
Type "bin/testmu-browser-agent click @e5"
Enter
Sleep 1s

# Step 7: Check a topping
Type "bin/testmu-browser-agent check @e7"
Enter
Sleep 1s

# Step 8: Screenshot before submitting
Type "bin/testmu-browser-agent screenshot --output marketing/demos/screenshots/form-before-submit.png"
Enter
Sleep 2s

# Step 9: Submit the form
Type "bin/testmu-browser-agent click @e12"
Enter
Sleep 2500ms

# Step 10: Verify result with snapshot
Type "bin/testmu-browser-agent snapshot"
Enter
Sleep 2s

# Step 11: Screenshot of submission result
Type "bin/testmu-browser-agent screenshot --output marketing/demos/screenshots/form-result.png"
Enter
Sleep 1500ms

Type "bin/testmu-browser-agent close"
Enter
Sleep 1s
