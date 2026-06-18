# Lesson 01 — Core Jenkins Concepts

## The One Mental Model

Everything Jenkins does maps to this loop:

```
trigger → checkout → run commands → collect results → report status
```

All the vocabulary below is just naming the parts of that loop.

---

## What Jenkins Actually Does

In practice, Jenkins runs these jobs in order:

1. Pull source code from Git
2. Install dependencies
3. Run tests
4. Build / package the application
5. Publish artifacts
6. Deploy to an environment
7. Notify people or systems on success or failure

---

## How Work Flows

```
                        ┌─────────────┐
   Git push / cron ───► │  Controller │  (schedules job, picks agent)
                        └──────┬──────┘
                               │ delegates
                        ┌──────▼──────┐
                        │    Agent    │  (a real machine)
                        └──────┬──────┘
                               │
                    ┌──────────▼──────────┐
                    │      Workspace       │  (code lives here)
                    └──────────┬──────────┘
                               │
              ┌────────────────▼─────────────────┐
              │            Pipeline               │
              │  Stage: Checkout                  │
              │    step: checkout scm             │
              │  Stage: Test                      │
              │    step: sh './scripts/test.sh'   │
              │  Stage: Build                     │
              │    step: sh './scripts/build.sh'  │
              │  Stage: Archive                   │
              │    step: archiveArtifacts 'dist/' │
              │  Post                             │
              │    always: notify / clean up      │
              └───────────────────────────────────┘
```

---

## The Anatomy of a Jenkinsfile

Every real Jenkinsfile is just this skeleton with content filled in:

```groovy
pipeline {
    agent any              // WHERE to run (any available agent)

    environment {          // shared env vars for all stages
        APP_NAME = 'hello'
    }

    triggers {             // WHAT kicks it off
        pollSCM('H/5 * * * *')  // check git every 5 min
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm   // clone the repo into workspace
            }
        }
        stage('Test') {
            steps {
                sh './scripts/test.sh'
            }
        }
        stage('Build') {
            steps {
                sh './scripts/build.sh'
            }
        }
        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'dist/**', fingerprint: true
            }
        }
    }

    post {
        success { echo 'Pipeline passed!' }
        failure { echo 'Pipeline failed!' }
        always  { cleanWs() }   // wipe workspace after every run
    }
}
```

---

## The 10 Terms That Unlock Everything — The Restaurant Kitchen

Every Jenkins concept maps to a role or object in a professional kitchen.

### The Story

A **customer places an order** — that's the **Trigger**. It lands on the pass.

The **head chef** — the **Controller** — receives it. She doesn't cook. She reads the **recipe card** — the **Jenkinsfile** — which lives in the recipe binder (your git repo). That card describes the full **Pipeline**: every phase, in order.

She assigns the order to a **line cook** — the **Agent** — and points them to an empty **prep station** — the **Workspace** — where all the ingredients (your source code) are laid out.

The cook works through the recipe **phase by phase** — those are **Stages**: Prep → Cook → Plate. Inside each phase are individual actions — **Steps**: dice the onion, add salt, reduce heat.

Some ingredients are kept in a **locked pantry** — those are **Credentials**. The cook can request them, but never sees the key itself.

The **finished dish** that goes out to the customer is the **Artifact** — the thing the pipeline produced and saved.

After every service, the **Post** crew runs: clean the station regardless (**always**), ring the bell if the dish was perfect (**success**), call the manager if something burned (**failure**).

### The Scene

```
  Customer order
       │  ← Trigger
       ▼
 ┌─────────────┐        reads        ┌──────────────┐
 │  Head Chef  │ ──────────────────► │  Jenkinsfile │
 │ (Controller)│                     │  (Pipeline)  │
 └──────┬──────┘                     └──────────────┘
        │ assigns
        ▼
 ┌─────────────┐
 │  Line Cook  │  ← Agent
 │  at their   │
 │   Station   │  ← Workspace
 └──────┬──────┘
        │
  ┌─────▼──────────────────────────┐
  │  Stage: Prep   (Steps: dice…)  │
  │  Stage: Cook   (Steps: sauté…) │
  │  Stage: Plate  (Steps: garnish)│──► Finished dish (Artifact)
  └────────────────────────────────┘
        │
  ┌─────▼──────────────────┐
  │  Post                  │
  │  always  → clean up    │
  │  success → ring bell   │
  │  failure → call manager│
  └────────────────────────┘

  🔒 Locked Pantry = Credentials
     (cook can use contents, never sees the key)
```

### Quick-Reference Table

| Jenkins Term | Kitchen Equivalent |
|---|---|
| **Trigger** | Customer places an order |
| **Controller** | Head chef — schedules, never cooks |
| **Agent** | Line cook — does the actual work |
| **Jenkinsfile** | The recipe card (lives in the recipe binder = git) |
| **Pipeline** | The full recipe, start to finish |
| **Workspace** | The cook's prep station |
| **Stage** | A cooking phase (Prep / Cook / Plate) |
| **Step** | A single action within a phase (dice, sauté) |
| **Credentials** | Locked pantry — usable but never visible |
| **Artifact** | The finished dish sent to the customer |
| **Post** | End-of-service routine (clean up / ring bell / call manager) |

---

## Controller vs Agent — The Key Distinction

```
┌─────────────────────────────────────────────────────────┐
│  Controller (Jenkins server)                            │
│  - Stores job configs & build history                   │
│  - Reads your Jenkinsfile                               │
│  - Decides which agent to use                           │
│  - Never runs your sh commands directly                 │
└─────────────────────────────────────────────────────────┘
              │ sends work to
┌─────────────▼───────────────────────────────────────────┐
│  Agent (could be: bare metal, VM, Docker container,     │
│         Kubernetes pod)                                 │
│  - Gets a workspace directory                           │
│  - Runs your sh / bat commands                          │
│  - Sends results back to controller                     │
└─────────────────────────────────────────────────────────┘
```

`agent any` means "use whatever agent is free." Real pipelines often specify a Kubernetes pod with specific Docker containers — same concept, more control.

---

## What the `post` Block Does

`post` blocks are your safety net — they always run, even if the pipeline crashes mid-stage:

```groovy
post {
    always   { }   // runs no matter what
    success  { }   // only on green build
    failure  { }   // only on red build
    unstable { }   // tests ran but some failed
    changed  { }   // status changed vs last run (e.g. fixed or broke)
}
```

---

## Additional Vocabulary

| Term | Meaning |
|---|---|
| **Build** | One execution of a job or pipeline |
| **Executor** | A slot on an agent that can run one build at a time |
| **Node** | A Jenkins machine capable of running builds |
| **SCM** | Source control management (usually Git) |
| **Fingerprint** | Jenkins metadata for tracking which build produced an artifact |
| **Multibranch pipeline** | A pipeline job that auto-creates jobs for each branch and PR |
| **Blue Ocean** | Jenkins UI focused on pipeline visualization |

---

## What To Ignore For Now

- Complex shared libraries
- Jenkins Configuration as Code (JCasC)
- Custom plugins
- Advanced distributed build farms
- Deep Groovy scripting
- Complex deployment orchestration

Learn the mental model and core terms first. The rest builds on top.
