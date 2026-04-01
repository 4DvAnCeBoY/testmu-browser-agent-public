# CLI Scripting with testmu-browser-agent-public

This directory contains shell scripting patterns for automating browser workflows from the command line.

## Output Formats

Choose an output format based on how you intend to consume results:

| Flag                | Best for                                      |
|---------------------|-----------------------------------------------|
| `--output json`     | Parsing with `jq`, CI pipelines, data capture |
| `--output compact`  | Minimal terminal output, human scanning       |
| `--output text`     | Plain readable text (default)                 |

**Tip:** Use `--output json` in scripts so you can pipe to `jq` and extract specific fields reliably.

## Snapshot Filtering

```sh
# Capture all visible text
testmu-browser-agent --output json snapshot

# Show the full tree including hidden elements
testmu-browser-agent --output json snapshot --full
```

Use `--full` when you need to inspect hidden or ARIA-hidden elements. The default snapshot already includes interactive elements with `@ref` IDs.

## Chaining Commands

Use `&&` to chain commands so the script aborts on the first failure:

```sh
testmu-browser-agent --output json open "https://example.com" && \
testmu-browser-agent --output json snapshot && \
testmu-browser-agent --output json close
```

## Waiting Between Navigation and Interaction

Always add a `wait` step after navigation before interacting with elements. This prevents race conditions where the DOM is not yet ready:

```sh
testmu-browser-agent --output json open "https://example.com/dashboard"
testmu-browser-agent --output json wait --selector ".dashboard-loaded"
testmu-browser-agent --output json click "#start-button"
```

Or wait for a URL pattern after a form submission:

```sh
testmu-browser-agent --output json click "button[type=submit]"
testmu-browser-agent --output json wait --url "/success"
```

## Examples in This Directory

| Script                  | Description                                      |
|-------------------------|--------------------------------------------------|
| `login-and-extract.sh`  | Multi-step login, data extraction, and screenshot |
| `batch-screenshots.sh`  | Screenshot a list of URLs to a timestamped dir   |

## Usage

Make scripts executable before running:

```sh
chmod +x login-and-extract.sh batch-screenshots.sh
```
