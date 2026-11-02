# Deployment and operations

## Docker Compose
Install Docker Desktop with WSL2 or Docker Engine + Compose v2 on Linux. Copy `.env.example` to `.env`, replace every example value, and run `docker compose up --build -d`. App is exposed on `${HTTP_PORT:-8088}`. Check `docker compose ps`, `docker compose logs -f backend`, and `curl http://localhost:8088/actuator/health` (or `/` for Nginx). Restart with `docker compose restart`; stop with `docker compose down`. The `mysql-data` volume persists database state; `docker compose down -v` permanently deletes it.

The Windows integration setup is `scripts/setup-wsl-tools.sh` followed by `scripts/run-integration.ps1`. It installs Docker Engine and Ansible in the Ubuntu WSL distro, creates a random local admin and database secret file at `~/.config/vendor-portal/.env` with mode 0600, then waits for Compose health and runs Selenium and Playwright test containers on the Compose network. Do not commit or copy that secret file into the repository.

## Jenkins
Run `scripts/run-local-ci.ps1` to start the repeatable WSL Jenkins and local Registry v2 demonstration. It creates a local Pipeline job from the `develop` branch and stores generated administrator/database secrets in WSL only. See [local Jenkins instructions](../ci/jenkins/README.md). The job runs Maven tests, frontend build, isolated Compose/Selenium tests, report archiving, Docker builds and a push to `localhost:5000`.

The Jenkinsfile also retains the external release path. Five-minute SCM polling is configured; a GitHub webhook is not configured. To use Docker Hub, configure `REGISTRY_NAMESPACE` and Jenkins username/password credential `dockerhub`, then set `PUBLISH_IMAGES=true` or run from `main`. External deploy is gated by `DEPLOY_TARGET`; supply a real inventory, `deploy-ssh-key` credential, and target secrets before enabling it. Jenkins reports and artifacts are published only after an actual build.

## Ansible
Ansible is installed in the local Ubuntu WSL distro with `community.docker`. The playbook syntax can be checked locally with `ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --syntax-check`. Edit `ansible/inventory/hosts.yml` to identify a Linux host you control and configure key-based SSH before deploying. The playbook installs Docker, stages Compose and starts the service. Configure the server `.env` securely out of band; the sample playbook deliberately does not copy secrets. Review Compose registry/image tags and host environment before deployment.

## Rollback
The Ansible playbook preserves the prior Compose file and attempts to restore it if a deployment health check fails. A rollback rehearsal against a separate Linux target has not been run. Verify Nginx availability and backend health before declaring recovery.

## Local source
Backend: Java 21 and Maven 3.9 with MySQL 8. Frontend: Node 24/npm 11. Set DB connection and admin bootstrap environment variables; see root README. Flyway migrations run automatically at backend startup.
