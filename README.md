# Jenkins 80/20 Learning Project

This project is a hands-on guide for learning Jenkins using the Pareto principle: focus on the 20% of Jenkins concepts and workflows that cover 80% of real-world usage.

The goal is not to memorize every Jenkins feature. The goal is to become productive with Jenkins pipelines, understand how CI/CD jobs run, and know how to debug the common problems you will actually encounter.

## Lesson 00 — Core Concepts

Start here: [docs/lesson-00-core-concepts.md](docs/lesson-00-core-concepts.md)

Covers the mental model, the 10 terms that unlock everything (with a restaurant kitchen analogy to link them into one story), and vocabulary to ignore until later.

## Recommended Learning Order

1. Run Jenkins locally.
2. Create a basic job manually.
3. Create a pipeline job.
4. Move the pipeline into a `Jenkinsfile`.
5. Run a test script from Jenkins.
6. Archive a build artifact.
7. Add parameters and environment variables.
8. Add credentials safely.
9. Learn how to debug failed builds.
10. Learn multibranch pipelines.

## Lesson 01 — Run Jenkins Locally

See: [docs/lesson-01-run-jenkins-locally.md](docs/lesson-01-run-jenkins-locally.md)

Covers the correct Podman/Docker command, container management, the first-time setup wizard, and how to register a repo so Jenkins can find your `Jenkinsfile`.

## Lesson 02 — First Manual Job

See: [docs/lesson-02-first-manual-job.md](docs/lesson-02-first-manual-job.md)

Covers freestyle jobs, the workspace, reading the console log, and intentionally breaking a build to understand failure.

## Lesson 03 — First Pipeline Job

See: [docs/lesson-03-first-pipeline-job.md](docs/lesson-03-first-pipeline-job.md)

Covers creating a Pipeline job in the UI, reading the Stage View, the declarative pipeline block reference, and the core Checkout→Test→Build→Archive pattern.

## Lesson 04 — Move Pipeline to Jenkinsfile

See: [docs/lesson-04-move-pipeline-to-jenkinsfile.md](docs/lesson-04-move-pipeline-to-jenkinsfile.md)

Covers creating the `Jenkinsfile` in the repo, what `checkout scm` does, built-in environment variables, connecting Jenkins to read from SCM, and triggering builds with SCM polling.

## Lesson 05 — Run a Test Script

See: [docs/lesson-05-run-test-script.md](docs/lesson-05-run-test-script.md)

Covers `scripts/test.sh`, `set -e`, writing assertions that fail the build, the debugging checklist, and common permission/path problems.

## Common Pipeline Patterns

### Run Commands

```groovy
steps {
    sh 'make test'
}
```

### Use Environment Variables

```groovy
environment {
    APP_ENV = 'test'
}
```

```groovy
steps {
    sh 'echo "$APP_ENV"'
}
```

### Use Parameters

```groovy
parameters {
    booleanParam(name: 'RUN_SLOW_TESTS', defaultValue: false, description: 'Run slow tests')
}
```

```groovy
steps {
    sh 'echo "RUN_SLOW_TESTS=$RUN_SLOW_TESTS"'
}
```

### Archive Artifacts

```groovy
steps {
    archiveArtifacts artifacts: 'dist/**', fingerprint: true
}
```

### Run Steps In Parallel

```groovy
stage('Quality Checks') {
    parallel {
        stage('Unit Tests') {
            steps {
                sh './scripts/test.sh'
            }
        }

        stage('Lint') {
            steps {
                sh './scripts/lint.sh'
            }
        }
    }
}
```

### Use Credentials

```groovy
steps {
    withCredentials([string(credentialsId: 'demo-api-token', variable: 'API_TOKEN')]) {
        sh 'curl -H "Authorization: Bearer $API_TOKEN" https://example.invalid/api'
    }
}
```

Never hardcode secrets in a `Jenkinsfile`.

## Practice Exercises

Do these in order:

1. Create a freestyle job that prints `Hello Jenkins`.
2. Create a pipeline job with two stages: `Hello` and `Inspect Workspace`.
3. Add a `Jenkinsfile` to this repository.
4. Create `scripts/test.sh` and make Jenkins run it.
5. Make the test fail and inspect the console log.
6. Fix the test and rerun the build.
7. Create `scripts/build.sh` that writes a file into `dist/`.
8. Archive `dist/**` as Jenkins artifacts.
9. Add a parameter named `TARGET_ENV`.
10. Print the selected `TARGET_ENV` during the build.
11. Add a scheduled trigger.
12. Add a credentials example using a dummy secret.
13. Convert one stage into parallel stages.
14. Create a multibranch pipeline job.


## What To Learn Later

After you are comfortable with the basics, learn these:

- Multibranch pipelines.
- GitHub or GitLab webhooks.
- Jenkins agents with Docker or Kubernetes.
- Shared libraries.
- Jenkins Configuration as Code.
- Matrix builds.
- Test reports with JUnit output.
- Static analysis reports.
- Deployment approvals.
- Role-based access control.

