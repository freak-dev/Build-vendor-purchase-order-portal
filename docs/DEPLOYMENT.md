# Deployment and operations

## Docker Compose
Install Docker Desktop with WSL2 or Docker Engine + Compose v2 on Linux. Copy `.env.example` to `.env`, replace every example value, and run `docker compose up --build -d`. App is exposed on `${HTTP_PORT:-8088}`. Check `docker compose ps`, `docker compose logs -f backend`, and `curl http://localhost:8088/actuator/health` (or `/` for Nginx). Restart with `docker compose restart`; stop with `docker compose down`. The `mysql-data` volume persists database state; `docker compose down -v` permanently deletes it.

The Windows integration setup is `scripts/setup-wsl-tools.sh` followed by `scripts/run-integration.ps1`. It installs Docker Engine and Ansible in the Ubuntu WSL distro, creates a random local admin and database secret file at `~/.config/vendor-portal/.env` with mode 0600, then waits for Compose health and runs Selenium and Playwright test containers on the Compose network. Do not commit or copy that secret file into the repository.

## Jenkins
Install Jenkins with Git, JDK 21, Maven 3.9, Node 24/npm 11, Docker Engine, curl, Ansible and a Selenium-compatible Docker runtime. Configure a Multibranch Pipeline. The Jenkinsfile runs five-minute SCM polling; a GitHub webhook is not configured. It verifies the backend, installs and builds the frontend, starts a Compose test stack and runs Selenium through Maven Failsafe, then archives packages and publishes Surefire/Failsafe XML and failure screenshots. Configure Jenkins credentials `portal-admin-password`, `portal-db-password`, `portal-mysql-root-password`, and `dockerhub`. Deploy runs only on `main` after prior stages pass and only when the deployment target is configured. Provide inventory, SSH key access, and target secrets securely before enabling external deployment.

## Ansible
Ansible is installed in the local Ubuntu WSL distro with `community.docker`. The playbook syntax can be checked locally with `ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --syntax-check`. Edit `ansible/inventory/hosts.yml` to identify a Linux host you control and configure key-based SSH before deploying. The playbook installs Docker, stages Compose and starts the service. Configure the server `.env` securely out of band; the sample playbook deliberately does not copy secrets. Review Compose registry/image tags and host environment before deployment.

## Rollback
The Ansible playbook preserves the prior Compose file and attempts to restore it if a deployment health check fails. A rollback rehearsal against a separate Linux target has not been run. Verify Nginx availability and backend health before declaring recovery.

## Local source
Backend: Java 21 and Maven 3.9 with MySQL 8. Frontend: Node 24/npm 11. Set DB connection and admin bootstrap environment variables; see root README. Flyway migrations run automatically at backend startup.
