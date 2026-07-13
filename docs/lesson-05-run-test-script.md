# Lesson 05 — Run a Test Script from Jenkins

## What This Lesson Adds

The pipeline now has a real `Test` stage that runs `scripts/test.sh`. This is the first time a build can fail for a *meaningful* reason — a broken assertion — not just a syntax error in the Jenkinsfile.

```
Before (lesson 04)          After (this lesson)
──────────────────          ──────────────────────────────
Checkout                    Checkout
Hello (echo only)     →     Test (runs scripts/test.sh)
post                        post
```

---

## How the Test Stage Works

The `Jenkinsfile` now contains:

```groovy
stage('Test') {
    steps {
        sh 'chmod +x scripts/test.sh'
        sh './scripts/test.sh'
    }
}
```

And `scripts/test.sh` exists at the repo root:

```bash
#!/bin/bash
set -e

echo "=== Running tests ==="
echo "Workspace: $(pwd)"

# TODO(human): Add a test assertion here.

echo "=== All tests passed ==="
```

### Why `set -e`?

`set -e` tells bash to exit immediately if any command returns a non-zero exit code. Without it, a failing command is silently ignored and the script continues. With it, the first failure stops the script — and Jenkins sees a non-zero exit, marks the stage red, and stops the build.

```bash
set -e          # ← "strict mode" — any failure = script exits
```

### Why `chmod +x` in the pipeline?

Git does not always preserve file execute permissions across platforms. Running `chmod +x scripts/test.sh` inside the pipeline guarantees the script is executable in the workspace, regardless of how the file was committed.

---

● **Learn by Doing**

**Context:** `scripts/test.sh` runs successfully right now, but it doesn't actually test anything — it's just two `echo` statements. A test script needs at least one assertion: a condition that fails the build if something is wrong. The simplest useful assertion checks that expected files and directories exist in the workspace.

**Your Task:** In `scripts/test.sh`, replace the `# TODO(human)` comment with an assertion that checks whether the `scripts/` directory exists. If it doesn't, print a failure message and exit with code 1.

**Guidance:** Use the pattern `if [ ! -d "path" ]; then echo "FAIL: ..."; exit 1; fi`. The `-d` flag tests for a directory. A non-zero exit (`exit 1`) is what tells Jenkins the test failed — the `echo` alone does nothing to the build status.

---

## Intentionally Breaking the Test

Once you've written your assertion, test that Jenkins actually catches failures. Change your assertion to check for a directory that doesn't exist (e.g. `nonexistent/`), commit, push, and watch the build go red.

```
Stage View after a failing test:

  Checkout   Test
  ✓ 2s       ✗ 0s    ← red, build stops here
```

The `post { failure { ... } }` block then runs. Open the console log — read from the **first** `+` line inside the `Test` stage, not from the bottom.

Revert to a passing assertion before moving on.

---

## Debugging Checklist

When a test stage fails, check in this order:

1. Read the console log from the **first failing line** inside the stage, not the last
2. Check the workspace path with `pwd` — is the script running where you expect?
3. Check available files with `ls -la` — is the file your script expects actually there?
4. Confirm the script is executable: `ls -l scripts/`
5. Run the exact failing command locally to reproduce outside Jenkins

---

## Common Problems

### `Permission denied: ./scripts/test.sh`

The script is not executable. The `chmod +x` step should handle this, but if you see it, run locally:

```bash
chmod +x scripts/test.sh
git add scripts/test.sh
git commit -m "fix: make test.sh executable"
```

### `No such file or directory`

The `checkout scm` step clones the repo but Jenkins runs commands relative to the workspace root. If your script references a path, make sure it exists in the repo and was committed.

### Script exits 0 even when assertion fails

You're missing `set -e`, or your `if` block doesn't call `exit 1`. Jenkins only sees the exit code of the last command in the script — every failure path must explicitly `exit 1`.

---

## Key Takeaways

- `set -e` is essential in CI scripts — without it, failures are silently swallowed
- Jenkins marks a stage as failed when any `sh` step returns a non-zero exit code
- The console log's first `+` line inside a failing stage is where to start debugging, not the bottom
- `chmod +x` in the pipeline is safer than trusting git to preserve permissions

---

## What's Next

Lesson 06 adds `scripts/build.sh` — a script that produces an artifact — and wires it into the pipeline's `Build` and `Archive` stages.
