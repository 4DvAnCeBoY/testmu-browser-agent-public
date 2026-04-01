# Quick Start Guide

Get up and running with `testmu-browser-agent` in 5 minutes.

## Install

### Option 1: curl (recommended)

```sh
curl -sSL https://raw.githubusercontent.com/4DvAnCeBoY/testmu-browser-agent-public/main/scripts/install.sh | sh
```

The script auto-detects your OS and architecture (darwin/linux, amd64/arm64), downloads the latest release, verifies the checksum, and installs to `/usr/local/bin`.

### Option 2: Manual download

1. Visit the [releases page](https://github.com/4DvAnCeBoY/testmu-browser-agent-public/releases) and download the binary for your platform:

   | Platform      | Binary                                    |
   |---------------|-------------------------------------------|
   | macOS (Apple) | `testmu-browser-agent-darwin-arm64`       |
   | macOS (Intel) | `testmu-browser-agent-darwin-amd64`       |
   | Linux         | `testmu-browser-agent-linux-amd64`        |
   | Windows       | `testmu-browser-agent-windows-amd64.exe`  |

2. Make it executable and move it to your PATH:

   ```sh
   chmod +x testmu-browser-agent-darwin-arm64
   sudo mv testmu-browser-agent-darwin-arm64 /usr/local/bin/testmu-browser-agent
   ```

3. Verify the install:

   ```sh
   testmu-browser-agent --help
   ```

## Your First Session

### 1. Open a URL

Start a browser and navigate to a page:

```sh
testmu-browser-agent open https://example.com
```

By default the browser runs headless. To see it on screen:

```sh
testmu-browser-agent --headless=false open https://example.com
```

### 2. Take a Snapshot

Get an accessibility tree snapshot of the current page. Snapshots expose `@ref` handles you can use to target elements:

```sh
testmu-browser-agent snapshot
```

Example output (abbreviated):

```
heading "Example Domain" @e1
paragraph "This domain is for use in illustrative examples." @e2
link "More information..." @e3
```

### 3. Click with @ref

Use the `@ref` value from the snapshot to click an element without guessing CSS selectors:

```sh
testmu-browser-agent click @e3
```

You can also use any CSS selector:

```sh
testmu-browser-agent click "a[href*='iana']"
```

### 4. Fill a Form

Navigate to a page with a form, take a snapshot, then fill fields by ref:

```sh
testmu-browser-agent open https://example.com/login
testmu-browser-agent snapshot
# snapshot shows: input[type=email] @e5, input[type=password] @e6
testmu-browser-agent fill @e5 "user@example.com"
testmu-browser-agent fill @e6 "s3cr3t"
testmu-browser-agent click @e7   # submit button
```

### 5. Take a Screenshot

Capture the current page state as a PNG:

```sh
testmu-browser-agent screenshot --output page.png
```

Capture a specific element:

```sh
testmu-browser-agent screenshot --ref @e1 --output header.png
```

Capture as JPEG with custom quality:

```sh
testmu-browser-agent screenshot --format jpeg --quality 90 --output page.jpg
```

### 6. Close the Browser

```sh
testmu-browser-agent close
```

## Full Example Script

```sh
#!/bin/sh
# Log in and screenshot the dashboard

testmu-browser-agent open https://app.example.com/login
testmu-browser-agent fill "#email" "user@example.com"
testmu-browser-agent fill "#password" "s3cr3t"
testmu-browser-agent click "#login-btn"
testmu-browser-agent wait --selector ".dashboard" --timeout 10
testmu-browser-agent screenshot --output dashboard.png
testmu-browser-agent close
```

## Next Steps

- **[MCP Integration](./mcp-integration.md)** — Use testmu-browser-agent as an MCP server inside Claude Code so AI can drive the browser directly.
- **[LambdaTest Cloud](./lambdatest.md)** — Run sessions on LambdaTest's cloud grid for parallelism and CI/CD.
- **[Command Reference](./commands.md)** — Full list of every command, flag, and alias.
