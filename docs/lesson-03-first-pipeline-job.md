# Lesson 03 — First Pipeline Job

## Why Pipeline Over Freestyle

From the comparison table in [lesson-02](lesson-02-first-manual-job.md):

|                          | Freestyle       | Pipeline                   |
| ------------------------ | --------------- | -------------------------- |
| Defined in               | Jenkins UI form | `Jenkinsfile` in your repo |
| Version controlled       | No              | Yes                        |
| Stages / visual progress | No              | Yes                        |
| Reusable across branches | No              | Yes                        |

This lesson uses an **inline** pipeline script (pasted directly in the UI) as a stepping stone. Lesson 04 moves that script into a real `Jenkinsfile` in the repo.

---

## Create the Pipeline Job

1. Open `http://localhost:8080`
2. Click **New Item**
3. Enter name: `hello-pipeline`
4. Choose **Pipeline**
5. Click **OK**

In the configuration page, scroll to the **Pipeline** section:

- **Definition**: Pipeline script ← keep this (not "from SCM" yet)

Paste the starter script below into the **Script** box.

---

## Starter Script

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                sh 'echo "Hello from Jenkins Pipeline"'
            }
        }

        // TODO(human): Add the Inspect Workspace stage here
    }
}
```

Click **Save**, then **Build Now** to confirm the `Hello` stage runs. Open the build — you will see the **Stage View** instead of a plain console log.

---

● **Learn by Doing**

**Context:** The `Hello` stage is working. The pipeline now needs an `Inspect Workspace` stage to show where Jenkins is running your commands — the workspace path. This is the most useful thing to know when debugging why a script can't find a file.

**Your Task:** In the Pipeline script in the Jenkins UI, replace the `// TODO(human)` comment with a second stage. The stage should be named `Inspect Workspace` and run two shell commands: one to print the current directory, one to list its contents.

**Guidance:** Each `sh` call is its own step. A stage with two `sh` steps looks exactly like the `Hello` stage above, just with different commands. Both `pwd` and `ls -la` are plain shell commands — no arguments needed.

---

## Reading the Stage View

After both stages run, the build page shows a **Stage View** — a grid where each column is a stage and colour shows pass/fail per stage:

```
         Hello    Inspect Workspace
Build #1  ✓ 0s        ✓ 0s
```

This is the first major difference from freestyle jobs:

- **Per-stage timing** — you see which stage is slow
- **Per-stage colour** — a failure in `Test` doesn't colour `Checkout` red
- **Re-run from stage** — Jenkins can replay a specific stage without rerunning everything before it

---

## Annotated Console Log

Click into a build and open **Console Output**. A pipeline log has more structure than freestyle:

```
Started by user admin
[Pipeline] Start of Pipeline
[Pipeline] agent                          ← allocating an executor
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Hello)                      ← entering the Hello stage
[Pipeline] sh
+ echo 'Hello from Jenkins Pipeline'
Hello from Jenkins Pipeline               ← your command output
[Pipeline] }
[Pipeline] stage
[Pipeline] { (Inspect Workspace)          ← entering your stage
[Pipeline] sh
+ pwd
/var/jenkins_home/workspace/hello-pipeline   ← workspace path
[Pipeline] sh
+ ls -la
total 8
drwxr-xr-x 2 jenkins jenkins ...
[Pipeline] }
[Pipeline] End of Pipeline
Finished: SUCCESS
```

Key lines:

- `[Pipeline] stage` — marks a stage boundary; easy to jump between stages in a long log
- `+ command` — trace mode, same as freestyle; every command echoed before running
- The workspace path is always `jenkins_home/workspace/<job-name>` for the built-in agent

---

## The Most Important Jenkinsfile

Most real pipelines you will read are variations of this pattern:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm        // clone the repo into the workspace
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
        always  { echo 'Pipeline finished.' }
        success { echo 'Pipeline succeeded.' }
        failure { echo 'Pipeline failed.' }
    }
}
```

This is what lessons 04–06 build toward: a real `Jenkinsfile` in this repo that runs `scripts/test.sh`, `scripts/build.sh`, and archives the result.

---

## Declarative Pipeline Block Reference

| Block           | Purpose                                                  | Where it goes          |
| --------------- | -------------------------------------------------------- | ---------------------- |
| `agent`         | Where the pipeline runs (`any`, a label, a Docker image) | Top-level or per-stage |
| `environment`   | Env vars available to all stages                         | Inside `pipeline {}`   |
| `parameters`    | User inputs shown before a build                         | Inside `pipeline {}`   |
| `stages`        | Container for all stage blocks                           | Inside `pipeline {}`   |
| `stage('Name')` | One named phase                                          | Inside `stages {}`     |
| `steps`         | The commands inside a stage                              | Inside `stage {}`      |
| `post`          | Actions after all stages finish                          | Inside `pipeline {}`   |

Deeper anatomy with code examples is in [lesson-00](lesson-00-core-concepts.md#the-anatomy-of-a-jenkinsfile).

---

## Key Takeaways

- Pipeline jobs give you staged output, per-stage pass/fail, and version-controllable definitions
- An inline script is fine for learning; a `Jenkinsfile` in the repo is required for anything real
- The workspace path follows the pattern `jenkins_home/workspace/<job-name>` — knowing this is essential for debugging
- The console log's `[Pipeline] stage` markers let you jump directly to any stage in a long build

---

## What's Next

Lesson 04 moves the inline pipeline script into a `Jenkinsfile` at the root of this repo and registers the job to read from SCM — so every push to git automatically uses the updated pipeline.
