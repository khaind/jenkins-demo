# Lesson 02 — First Manual Job (Freestyle)

## Why Start With a Freestyle Job

Freestyle jobs skip pipeline abstraction entirely. Jenkins just runs your shell commands directly, then shows you the result. That exposes the three things every Jenkins job does — regardless of type:

```
checkout code → run commands in a workspace → report status
```

Once you've seen this at its simplest, pipelines are just a structured way to express the same thing.

---

## Freestyle vs Pipeline

| | Freestyle | Pipeline |
|---|---|---|
| Defined in | Jenkins UI (click-through form) | `Jenkinsfile` in your repo |
| Version controlled | No | Yes |
| Stages / visualization | No | Yes |
| Reusable across branches | No | Yes |
| When to use | Learning / one-off tasks | Everything in production |

Freestyle is a stepping stone. You will use Pipelines for everything real.

---

## Create the Job

1. Open `http://localhost:8080`
2. Click **New Item**
3. Enter name: `hello-freestyle`
4. Choose **Freestyle project**
5. Click **OK**

---

## Add a Build Step

In the job configuration page, scroll to the **Build Steps** section:

1. Click **Add build step**
2. Choose **Execute shell**
3. Paste this into the command box:

```bash
echo "Hello from Jenkins"
date
pwd
ls -la
```

4. Click **Save**

---

## Run It

1. Click **Build Now** in the left sidebar
2. A build row appears under **Build History** (bottom-left) — click the `#1` link
3. Click **Console Output**

---

## Reading the Console Log

This is what you will see, annotated:

```
Started by user admin                        ← who triggered it
Running as SYSTEM
Building in workspace /var/jenkins_home/workspace/hello-freestyle   ← workspace path
[hello-freestyle] $ /bin/sh -xe /tmp/jenkins...sh   ← Jenkins runs your script via sh
+ echo 'Hello from Jenkins'
Hello from Jenkins
+ date
Thu Jun 18 15:52:00 UTC 2026
+ pwd
/var/jenkins_home/workspace/hello-freestyle
+ ls -la
total 8
drwxr-xr-x 2 jenkins jenkins 4096 Jun 18 15:52 .
drwxr-xr-x 3 jenkins jenkins 4096 Jun 18 15:52 ..
Finished: SUCCESS                            ← build result
```

Three things to notice:

- **Workspace path**: Jenkins creates a directory per job under `jenkins_home/workspace/`. All your commands run there.
- **`+ command` prefix**: The `+` means the shell is in trace mode (`-x`). Every command is echoed before it runs — that's why debugging is easy.
- **`Finished: SUCCESS`**: This is the final verdict. Any non-zero exit code from any command flips it to `FAILURE`.

---

## Make It Fail on Purpose

Understanding failure is as important as success. Edit the job (**Configure** in the sidebar), change the shell command to:

```bash
echo "About to fail"
exit 1
echo "This line never runs"
```

Click **Save**, then **Build Now**. Open the console log — you'll see:

```
+ echo 'About to fail'
About to fail
+ exit 1
Build step 'Execute shell' marked build as failure
Finished: FAILURE
```

`exit 1` tells the shell something went wrong. Jenkins treats any non-zero exit as failure and stops immediately — `echo "This line never runs"` is never reached.

Restore the original command before moving on.

---

## Key Takeaways

- Every build runs in an isolated workspace directory
- The console log is your primary debugging tool — always read from the **first failing line**, not the last
- Jenkins stops a build the moment any command returns a non-zero exit code
- Freestyle jobs are configured in the UI and not version controlled — that's why real teams use Pipelines

---

## What's Next

Lesson 03 covers Pipeline jobs — the same concept, but defined as code in a `Jenkinsfile` so it lives in your repo, is version controlled, and can have named stages with visual progress tracking.
