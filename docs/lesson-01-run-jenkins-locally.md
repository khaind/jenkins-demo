# Lesson 01 — Run Jenkins Locally

## Starting Jenkins

Use Podman with the `-d` flag (detached) so the container is owned by the Podman daemon, not your shell:

```bash
podman run -d \
  --name jenkins-demo \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e JAVA_OPTS="-Xmx512m -Xms256m" \
  jenkins/jenkins:lts
```

If you use Docker, swap `podman` for `docker` — flags are identical.

### Why `-d`, not `--rm &`

| Approach | What happens |
|---|---|
| `podman run -d` | Container runs as a daemon, survives shell exit |
| `podman run --rm … &` | Container is tied to the shell process — shell exits, container is killed (exit 137) |

Always use `-d` for any service you want to keep running.

### The `-e JAVA_OPTS` Flag

Jenkins is a Java process. Without an explicit heap ceiling it will try to claim up to a quarter of the VM's RAM, which can trigger an OOM kill inside the Podman VM. `-Xmx512m` caps the heap at 512 MB — enough for a local learning instance.

---

## Container Management

```bash
# Check if it's running
podman ps --filter name=jenkins-demo

# Tail the logs (useful during first boot)
podman logs -f jenkins-demo

# Stop Jenkins
podman stop jenkins-demo

# Start it again later (reuses the same volume)
podman start jenkins-demo

# Remove the container entirely (data survives in the volume)
podman rm jenkins-demo
```

The `jenkins_home` named volume persists all job configs, credentials, and history across container restarts and removals.

---

## Why Two Ports?

```
Your browser
    │
    │ HTTP :8080
    ▼
┌─────────────────────────────┐
│   Jenkins Controller        │
│   :8080  ← web UI           │
│   :50000 ← agent listener   │
└──────────────┬──────────────┘
               │ JNLP :50000
               ▼
        Remote Agent
        (runs your sh commands)
```

| Port | Who uses it | Purpose |
|---|---|---|
| **8080** | You (browser, webhooks, API) | Web UI and all HTTP traffic |
| **50000** | Jenkins agents (other machines) | Agents phone home to get work |

**Right now you don't need 50000.** `agent any` uses the built-in executor inside the controller container — no remote agent, no JNLP handshake. It's included in the run command so you don't have to restart the container later when you add real agents.

Kubernetes-based agents (used in production pipelines at Dynatrace) connect via HTTP instead of JNLP, so they only ever need 8080.

---

## First-Time Setup Wizard

Open `http://localhost:8080` after the container starts.

### Step 1 — Unlock Jenkins

Jenkins prints a one-time password in the container logs during first boot:

```bash
podman logs jenkins-demo 2>&1 | grep -A2 "Please use the following password"
```

Paste that password into the "Unlock Jenkins" screen and click **Continue**.

### Step 2 — Install Suggested Plugins

Choose **Install suggested plugins**. This installs Git, Pipeline, Credentials, and other essentials in one click. Takes 1–2 minutes.

### Step 3 — Create Admin User

Fill in a username, password, full name, and email. Click **Save and Continue**.

### Step 4 — Instance Configuration

Leave the Jenkins URL as `http://localhost:8080/`. Click **Save and Finish**, then **Start using Jenkins**.

---

## How Jenkins Learns About Your Repo

Jenkins doesn't auto-discover repos. You register each repo once, then Jenkins reads the `Jenkinsfile` from it on every build.

```
Jenkins UI → New Item → enter a name → Pipeline → OK
    │
    ▼
Pipeline tab
  Definition: Pipeline script from SCM
  SCM: Git
  Repository URL: <your repo URL>
  Branch: */main
  Script Path: Jenkinsfile        ← default, change if needed
```

Jenkins pulls the `Jenkinsfile` fresh from git on every build — so changes to it take effect on the next run without touching Jenkins itself.

### Three Registration Patterns

| Type | What you configure | What Jenkins does |
|---|---|---|
| **Pipeline job** | Repo URL + branch | Builds that one branch |
| **Multibranch Pipeline** | Repo URL only | Scans all branches, auto-creates a job per branch that has a `Jenkinsfile` |
| **GitHub/GitLab Org** | Org URL | Scans every repo in the org automatically |

Start with a plain Pipeline job. Graduate to Multibranch once you want branch-based workflows.
