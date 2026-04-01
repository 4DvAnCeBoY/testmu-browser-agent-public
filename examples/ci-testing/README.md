# CI Testing with testmu-browser-agent-public and LambdaTest

This example shows how to run browser tests in GitHub Actions using `testmu-browser-agent-public` with LambdaTest as the browser provider.

## Prerequisites

- A [LambdaTest](https://www.lambdatest.com/) account
- GitHub repository with Actions enabled

## Setup

### 1. Add GitHub Secrets

In your repository go to **Settings → Secrets and variables → Actions** and add:

| Secret name         | Value                          |
|---------------------|--------------------------------|
| `LT_USERNAME`       | Your LambdaTest username       |
| `LT_ACCESS_KEY`     | Your LambdaTest access key     |

Find your credentials at: https://accounts.lambdatest.com/detail/profile

### 2. Copy the Workflow

Copy `browser-test.yml` into your repository:

```sh
mkdir -p .github/workflows
cp browser-test.yml .github/workflows/
```

### 3. Add Test Scripts

Copy `test-login-flow.sh` into a `tests/` directory (or wherever your workflow expects it):

```sh
mkdir -p tests
cp test-login-flow.sh tests/
chmod +x tests/test-login-flow.sh
```

Commit and push — the workflow will trigger on the next push or pull request.

## How It Works

1. GitHub Actions installs `testmu-browser-agent-public` via the install script.
2. LambdaTest credentials are injected as environment variables.
3. The test script runs browser actions against LambdaTest's cloud grid.
4. On failure, screenshots are uploaded as workflow artifacts for inspection.

## Viewing Results

- Live test sessions: https://automation.lambdatest.com/
- Workflow artifacts (screenshots): **Actions → your run → Artifacts**
