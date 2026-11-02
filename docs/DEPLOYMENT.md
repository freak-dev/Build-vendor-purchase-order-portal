# Deployment and operations

## Docker Compose
Install Docker Desktop (Windows WSL2) or Docker Engine + Compose v2 on Linux. Copy `.env.example` to `.env`, replace every example value, and run `docker compose up --build -d`. App is exposed on `${HTTP_PORT:-8088}`. Check `docker compose ps`, `docker compose logs -f backend`, and `curl http://localhost:8088/actuator/health` (or `/` for Nginx). Restart with `docker compose restart`; stop with `docker compose down`. The `mysql-data` volume persists database state; `docker compose down -v` permanently deletes it.

## Jenkins
Install Jenkins with Git, JDK 21, Maven 3.9, Node 24/npm 11, Docker Engine, Ansible, and the HTML Publisher plugin. Configure a Multibranch Pipeline and GitHub webhook (or Jenkins polling configured here). Ensure agents can run shell commands. The Jenkinsfile compiles/tests backend and builds frontend; Surefire XML is published. Set `RUN_E2E=true` to enable Playwright; install browser dependencies on the agent. Configure a Jenkins credential `dockerhub`. Deploy stage runs only on `main` after successful earlier stages and only when deployment target is configured. Provide inventory and secrets securely (Ansible Vault/Jenkins credential integration must be set up by the operator).

## Ansible
On Windows install WSL2 and Ubuntu, then install Ansible inside WSL; Ansible is not supported as a native Windows control node. On Linux install Ansible Core and `community.docker` collection (`ansible-galaxy collection install community.docker`). Edit `ansible/inventory/hosts.yml` to identify a Linux host you control and configure key-based SSH. The playbook installs Docker, stages Compose and starts the service. Configure the server `.env` securely out of band; the sample playbook deliberately does not copy secrets. Review Compose registry/image tags and host environment before deployment.

## Rollback
Pin the last stable backend and frontend image tags in a versioned Compose release file and redeploy that file. Verify Nginx availability and backend health before declaring recovery. Automated blue/green rollback is not implemented or demonstrated in this workspace.

## Local source
Backend: Java 21 and Maven 3.9 with MySQL 8. Frontend: Node 24/npm 11. Set DB connection and admin bootstrap environment variables; see root README. Flyway migrations run automatically at backend startup.

