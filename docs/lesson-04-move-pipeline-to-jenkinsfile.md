# Lesson 04 — Move Pipeline to Jenkinsfile

## What Changes in This Lesson

In lesson 03 the pipeline script lived inside Jenkins — pasted into a UI form, invisible to git, editable only by someone with Jenkins access.

This lesson moves it into the repo as a `Jenkinsfile`. After this:

```
Before                        After
──────────────────────────    ──────────────────────────────────
Pipeline stored in Jenkins    Pipeline stored in git
Changed via Jenkins UI        Changed via code editor + git push
No history                    Full git history
One config per job            One file works across all branches
```

Jenkins becomes a reader of your code, not a separate system to maintain.

---

## The Jenkinsfile in This Repo

A `Jenkinsfile` already exists at the root of this repo:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Hello') {
            steps {
                sh 'echo "Running from Jenkinsfile in the repo"'
                sh 'echo "Build number: ${BUILD_NUMBER}"'
                sh 'pwd'
            }
        }
    }

    // TODO(human): Add a post block here
}
```

### What `checkout scm` Does

`checkout scm` tells Jenkins to clone the repo that this `Jenkinsfile` came from — using the branch, credentials, and URL already configured in the job. You never hardcode a repo URL inside a `Jenkinsfile`.

```
Jenkins reads Jenkinsfile from git
       │
       ▼
Jenkinsfile says: checkout scm
       │
       ▼
Jenkins clones the same repo into the workspace
       │
       ▼
All your scripts and files are now available in the workspace
```

### Built-in Environment Variables

The `Hello` stage uses `${BUILD_NUMBER}` — one of Jenkins' built-in variables available in every pipeline:

| Variable | Value |
|---|---|
| `BUILD_NUMBER` | Incrementing build counter (`1`, `2`, `3` …) |
| `BUILD_URL` | Full URL to this build's page |
| `JOB_NAME` | Name of the job |
| `BRANCH_NAME` | Git branch (only set in Multibranch pipelines) |
| `WORKSPACE` | Absolute path to the workspace directory |

---

● **Learn by Doing**

**Context:** The Jenkinsfile has a `Checkout` stage and a `Hello` stage. It's missing a `post` block — the cleanup and notification section that runs after all stages finish, regardless of outcome. You've seen `post` in the lesson-00 anatomy and lesson-03 reference table. Now write it yourself.

**Your Task:** In `Jenkinsfile` at the repo root, replace the `// TODO(human): Add a post block here` comment with a `post` block. It should handle three conditions: `always`, `success`, and `failure`. Each condition should print a descriptive `echo` message.

**Guidance:** The `post` block sits inside `pipeline {}` but outside `stages {}`, at the same indentation level as `stages`. Each condition (`always`, `success`, `failure`) is a block containing `steps`-style commands — but without the `steps` keyword. Reference: `post { always { echo '...' } }`.

---

## Connect Jenkins to the Repo

Once you've added the `post` block, committed, and pushed to GitHub, update the Jenkins job to read from the repo instead of the inline script.

> **Why not a local file path?**
> Jenkins runs inside a Podman container with its own isolated filesystem. A path like `file:///Users/khai.nguyen/Codes/misc/jenkins-demo` exists on your Mac but is invisible to the container — it can only see paths explicitly mounted as volumes. Using GitHub sidesteps this entirely and is how Jenkins is used in real projects.

### Option A — Update the existing `hello-pipeline` job

1. Open `http://localhost:8080/job/hello-pipeline/configure`
2. Scroll to **Pipeline**
3. Change **Definition** from `Pipeline script` → `Pipeline script from SCM`
4. Set **SCM**: Git
5. Set **Repository URL**: `https://github.com/<your-username>/jenkins-demo.git`
6. Set **Branch**: `*/main`
7. Leave **Script Path** as `Jenkinsfile`
8. Click **Save**

For a **public repo**, no credentials are needed. For a **private repo**, first add a GitHub personal access token as a Jenkins credential (Dashboard → Manage Jenkins → Credentials → Add → Secret text), then select it in the **Credentials** dropdown.

### Option B — Create a new job

Repeat the "New Item → Pipeline" flow from lesson 03 but choose `Pipeline script from SCM` from the start and enter the GitHub URL above. Name it `jenkins-demo`.

### Build It

Click **Build Now**. Jenkins will:
1. Clone the repo from GitHub into the workspace
2. Read `Jenkinsfile` from the cloned copy
3. Execute the stages defined in it

---

## Triggering Builds

Jenkins never watches GitHub on its own. A build only starts when something explicitly tells it to. There are three ways:

| Trigger | How it works | Works locally? |
|---|---|---|
| **Manual** | Click "Build Now" in the UI | Yes — always available |
| **SCM Polling** | Jenkins checks git on a timer | Yes — no public URL needed |
| **Webhook** | GitHub notifies Jenkins on push | No — requires a public URL |

Your Jenkins runs at `http://localhost:8080` — a private address GitHub cannot reach. Webhooks need a public URL, so **SCM polling** is the right choice for this sandbox.

### Enable SCM Polling

In your job: **Configure → Build Triggers → Poll SCM**

Set the schedule:

```
H/2 * * * *
```

This checks GitHub every 2 minutes. The `H` (hash) staggers the start time so all jobs don't hit GitHub at the exact same second.

```
H/2 * * * *
 │   │ │ │ └── day of week (any)
 │   │ │ └──── month (any)
 │   │ └────── day of month (any)
 │   └──────── hour (any)
 └──────────── every 2 minutes
```

After saving, the polling loop is:

```
git push to GitHub
       │
       ▼  (up to 2 min wait)
Jenkins polls → detects new commit → triggers build automatically
```

### Triggering in the Jenkinsfile

You can also declare the trigger directly in the `Jenkinsfile` so it is version controlled alongside the pipeline:

```groovy
pipeline {
    agent any

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages { ... }
}
```

When Jenkins first reads this, it registers the schedule automatically — no manual UI config needed for future jobs or branches.

---

## The Pipeline as Code Loop

After this setup, your development loop is:

```
Edit Jenkinsfile locally
       │
       ▼
git commit && git push
       │
       ▼
Jenkins picks up the change on next build
       │
       ▼
No Jenkins UI changes needed
```

A broken pipeline change is just a `git revert` away. Your pipeline history is your git log.

---

## Key Takeaways

- `Jenkinsfile` at the repo root is the standard convention — Jenkins looks there by default
- `checkout scm` clones the same repo the `Jenkinsfile` came from; never hardcode a repo URL
- `BUILD_NUMBER`, `WORKSPACE`, and other built-in vars are always available in pipeline steps
- After switching to SCM, every pipeline change goes through git — the same review process as code

---

## What's Next

Lesson 05 adds `scripts/test.sh` and wires it into the pipeline's `Test` stage — so Jenkins has something real to run and report on.
