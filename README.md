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

## First Pipeline Job

Create a new item named `hello-pipeline`, choose **Pipeline**, and paste this pipeline script:

```groovy
pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                sh 'echo "Hello from Jenkins Pipeline"'
            }
        }

        stage('Inspect Workspace') {
            steps {
                sh 'pwd'
                sh 'ls -la'
            }
        }
    }
}
```

What you should learn:

- `pipeline` defines the full job.
- `agent any` means Jenkins can run the job on any available executor.
- `stages` organize the workflow visually.
- `steps` perform real work.
- `sh` runs shell commands on Linux/macOS agents.

## The Most Important Jenkinsfile

Most Jenkins pipelines you see in real projects are variations of this:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
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
        always {
            echo 'Pipeline finished.'
        }

        success {
            echo 'Pipeline succeeded.'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}
```

This is the core pattern:

- Checkout code.
- Test the code.
- Build the code.
- Save useful outputs.
- Run cleanup or notifications after the result is known.

## Declarative Pipeline Basics

Prefer declarative pipelines when learning Jenkins.

Declarative pipeline structure:

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = 'jenkins-demo'
    }

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
    }

    stages {
        stage('Example') {
            steps {
                sh 'echo "App: $APP_NAME"'
                sh 'echo "Environment: $ENVIRONMENT"'
            }
        }
    }

    post {
        always {
            echo 'Done'
        }
    }
}
```

Important blocks:

- `agent`: Where the pipeline runs.
- `environment`: Environment variables available to steps.
- `parameters`: Inputs users can choose when starting a build.
- `stages`: The major phases of the pipeline.
- `steps`: Commands or Jenkins actions inside a stage.
- `post`: Actions that run after success, failure, or every build.

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

## Mini Project Plan

This repository will grow into a tiny Jenkins learning project:

```text
jenkins-demo/
  README.md
  Jenkinsfile
  app/
    hello.sh
  scripts/
    test.sh
    build.sh
  dist/
    generated by build.sh
```

The pipeline will eventually do this:

1. Check out the repository.
2. Run a test script.
3. Build a small artifact.
4. Archive the artifact in Jenkins.
5. Show success/failure output clearly.

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

## Debugging Checklist

When a Jenkins build fails, check these first:

- Read the console log from the first failing line, not the last line.
- Check the workspace path with `pwd`.
- Check available files with `ls -la`.
- Confirm scripts are executable with `ls -l scripts/`.
- Confirm the correct branch was checked out.
- Confirm required tools are installed on the agent.
- Confirm environment variables are set.
- Confirm credentials IDs match Jenkins configuration.
- Confirm plugins are installed.
- Rerun the exact failing command locally if possible.

## Common Problems

### Permission Denied

If Jenkins says a script cannot be executed:

```text
permission denied: ./scripts/test.sh
```

Fix it locally:

```bash
chmod +x scripts/test.sh scripts/build.sh
```

### Command Not Found

If Jenkins says `node`, `python`, `java`, `make`, or another command is missing, the agent does not have that tool installed.

Fix options:

- Install the tool on the Jenkins agent.
- Use a Docker-based agent with the tool included.
- Use Jenkins tool configuration.

### Credentials Not Found

If Jenkins says a credential ID does not exist, check:

- The credential was created in Jenkins.
- The ID matches exactly.
- The job has permission to use it.
- The credential is stored in the correct scope.

### Pipeline Syntax Error

If Jenkins cannot parse the `Jenkinsfile`, check:

- Braces are balanced.
- Strings are quoted correctly.
- Declarative blocks are in the correct location.
- Plugin-specific steps are available.

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

## Next Step

The next file to add is a `Jenkinsfile` with a minimal pipeline that calls local scripts. After that, add `scripts/test.sh` and `scripts/build.sh` so Jenkins has something real to run.
