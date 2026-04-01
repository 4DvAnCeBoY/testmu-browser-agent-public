# Accessibility Snapshots & @ref IDs

Deep dive on the `snapshot` command: how the accessibility tree works, how to use `@ref` element IDs, diffing, and token optimization.

## Table of Contents

- [What Is a Snapshot?](#what-is-a-snapshot)
- [Understanding @ref IDs](#understanding-ref-ids)
- [Snapshot Flags](#snapshot-flags)
- [Snapshot Diffing](#snapshot-diffing)
- [Using Refs in Commands](#using-refs-in-commands)
- [Token Optimization](#token-optimization)
- [Edge Cases & Troubleshooting](#edge-cases--troubleshooting)

---

## What Is a Snapshot?

A snapshot captures the **accessibility tree** of the current page — a structured representation of all visible elements as exposed to screen readers and assistive technology. It is the primary way to understand page state without parsing raw HTML.

```sh
testmu-browser-agent snapshot
```

Example output:

```
heading "Books to Scrape"
  link "Home"
  link "Books" [ref=e1]
navigation
  list
    listitem
      link "Travel" [ref=e2]
      link "Mystery" [ref=e3]
main
  heading "All products" [ref=e4]
  list
    listitem
      link "A Light in the Attic" [ref=e5]
      text "£51.77"
      text "In stock"
```

The tree reflects the semantic structure (headings, navigation, lists) rather than visual layout, making it robust to CSS changes.

---

## Understanding @ref IDs

Every interactive element in the accessibility tree is assigned a **ref ID** — a short string like `@e1`, `@e12`, `@e47`. These IDs:

- Are unique within a single snapshot session
- Are stable across multiple snapshots of the same page **without navigation**
- Are invalidated by any page navigation, reload, or significant DOM mutation
- Are used directly as selectors in interaction commands

**Always re-snapshot after navigation:**

```sh
testmu-browser-agent open https://example.com
testmu-browser-agent snapshot    # @e1, @e2, @e3...

testmu-browser-agent click @e2    # navigate to /about

testmu-browser-agent snapshot    # NEW refs: @f1, @f2, @f3... (old @e* are gone)
testmu-browser-agent click @f5    # use new refs
```

**Ref IDs are prefixed** to distinguish sessions. In practice you will see `e`, `f`, `g` prefixes cycling as sessions advance.

---

## Snapshot Flags

```
--full              Include hidden and ARIA-hidden elements
--diff              Show only elements that changed since last snapshot
--max-length N      Truncate output to N characters (default: unlimited)
--output json       Return structured JSON instead of text (global flag)
```

---

## Snapshot Diffing

`--diff` shows only elements that changed since the previous snapshot. This is useful for verifying that an action had the expected effect without processing the entire tree.

```sh
# Initial state
testmu-browser-agent snapshot

# Perform an action
testmu-browser-agent click @e5   # toggle a checkbox

# See only what changed
testmu-browser-agent snapshot --diff
# → [ref=e5] checkbox "Bacon" (checked)   ← changed from unchecked
```

Diff is especially useful for:
- Confirming a form field was filled correctly
- Verifying a UI state transition (e.g. collapsed → expanded)
- Detecting unexpected side effects of an action

---

## Using Refs in Commands

Any command that accepts `<ref|selector>` can take a ref ID directly:

```sh
# All equivalent — ref is preferred for stability
testmu-browser-agent click @e10
testmu-browser-agent click '[type="submit"]'
testmu-browser-agent click 'button:has-text("Submit order")'

# Fill
testmu-browser-agent fill @e1 "Jane Doe"
testmu-browser-agent fill '[name="custname"]' "Jane Doe"

# Highlight before screenshot
testmu-browser-agent highlight @e10
testmu-browser-agent screenshot --output submit-btn.png
```

**When to use CSS selectors instead of refs:**
- When interacting from a script without a preceding snapshot step
- When the selector is semantically meaningful and stable (e.g. `[data-testid="submit"]`)
- When refs are not available (e.g. connecting to an existing browser session)

---

## Token Optimization

Accessibility trees for complex pages can be large. Strategies to reduce output size:

**1. Use `--max-length` to cap output:**
```sh
testmu-browser-agent snapshot --max-length 2000
```

**2. Use `--diff` after actions:**
```sh
testmu-browser-agent snapshot            # full baseline
testmu-browser-agent click @e3
testmu-browser-agent snapshot --diff     # only changed elements
```

**3. Use `get text <selector>` instead of snapshot for reading content:**
```sh
# Instead of a full snapshot to read a result message:
testmu-browser-agent get text '#result-message'
```

**4. Use `--output json` in pipelines** to avoid parsing overhead:
```sh
testmu-browser-agent --output json snapshot | jq '.elements[] | select(.interactive)'
```

---

## Edge Cases & Troubleshooting

| Situation | Behavior | Solution |
|---|---|---|
| Ref not found | Command errors: `ref @e12 not found` | Re-run `snapshot` to get fresh refs |
| Page still loading | Snapshot returns partial tree | Use `wait --selector` before snapshotting |
| Dynamic SPA content | Refs from before navigation are invalid | Always re-snapshot after `click` that triggers navigation |
| Shadow DOM elements | May not appear in accessibility tree | Use `eval` + `find` for Shadow DOM queries |
| Canvas / SVG | Non-interactive, won't appear in snapshot | Use `screenshot` + visual inspection |
| Large trees | Output truncated with `--max-length` | Increase limit or use targeted `get text` queries |
| Iframes | Elements inside iframe not in main snapshot | Switch context with `frame '#iframe-id'` then re-snapshot |
| Disabled elements | Shown in `--full` snapshot | Query with `find` or check `--full` snapshot |
