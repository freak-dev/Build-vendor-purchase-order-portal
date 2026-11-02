# Implementation Plan

## Environment baseline

- Windows PowerShell 7.6.5
- Node.js v24.14.1 and npm 11.11.0
- Git 2.53.0, Python 3.14
- Java, Maven, Docker and Ansible are not installed
- Empty Git repository on `master`; no project files or `AGENTS.md`

## Delivery sequence

1. Define requirements, architecture, environment setup and project conventions.
2. Implement the Spring Boot API, MySQL schema and Flyway migrations, authentication, and role authorization.
3. Implement vendor, product, purchase order, inventory, alert and reporting modules, plus the React application.
4. Add unit, integration and Selenium tests.
5. Add Jenkins CI/CD, Docker Compose, Nginx, Ansible deployment, health checks and rollback.
6. Complete installation guides, SRS, diagrams, college report and evidence checklist.

## 15-week milestone checklist

- [ ] Week 1: Problem definition and scope.
- [ ] Week 2: Agile planning and DevOps workflow.
- [ ] Week 3: Requirements, architecture and environment setup.
- [ ] Week 4: Git and GitHub repository initialization.
- [ ] Week 5: First feature development with branching.
- [ ] Week 6: Complete MVP and Git collaboration.
- [ ] Week 7: Jenkins installation and CI.
- [ ] Week 8: Jenkinsfile and application deployment.
- [ ] Week 9: Selenium test design and local execution.
- [ ] Week 10: Continuous testing in Jenkins.
- [ ] Week 11: Docker image and container lifecycle.
- [ ] Week 12: Jenkins-Docker continuous deployment.
- [ ] Week 13: Ansible configuration management.
- [ ] Week 14: Automated provisioning, health checks and rollback.
- [ ] Week 15: Final release, documentation and viva preparation.

Deployment, builds and test evidence must be recorded only after the required tooling and target environment are available and actual runs have completed.
