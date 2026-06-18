# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Teaching Guide

Read **`AGENTS.md`** first — it is the canonical instruction set for how to teach Jenkins in this sandbox. Key points it covers:

- Use the Feynman technique: simple explanation → sandbox example → map to real Jenkinsfile
- User is a visual learner: prefer Mermaid diagrams, ASCII flow charts, and comparison tables
- Real production Jenkinsfiles for reference (backend: `automation-server`, frontend: `automation-app`)
- Explanation checklist: minimal sandbox version first, then real-world mapping, then branch-specific behavior

## Running Jenkins Locally

```bash
# Docker
docker run --name jenkins-demo --rm -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts

# Podman (identical flags)
podman run --name jenkins-demo --rm -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

Access at http://localhost:8080.

## Intended Project Structure

None of these files exist yet — creating them is the learning exercise.

```
jenkins-demo/
  Jenkinsfile          # declarative pipeline
  app/hello.sh         # sample application
  scripts/test.sh      # called by pipeline Test stage
  scripts/build.sh     # called by pipeline Build stage
  dist/                # generated artifacts (gitignored)
```

## Architecture

This is a teaching sandbox, not a production app. Keep the pipeline minimal, shell scripts transparent, and reference real patterns conceptually — no real secrets or endpoints.
