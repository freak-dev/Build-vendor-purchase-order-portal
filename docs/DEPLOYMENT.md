# Deployment and operations

## Docker Compose
Install Docker Desktop with WSL2 or Docker Engine + Compose v2 on Linux. Copy `.env.example` to `.env`, replace every example value, and run `docker compose up --build -d`. App is exposed on `${HTTP_PORT:-8088}`. Check `docker compose ps`, `docker compose logs -f backend`, and `curl http://localhost:8088/actuator/health` (or `/` for Nginx). Restart with `docker compose restart`; stop with `docker compose down`. The `mysql-data` volume persists database state; `docker compose down -v` permanently deletes it.

The Windows integration setup is `scripts/setup-wsl-tools.sh` followed by `scripts/run-integration.ps1`. It installs Docker Engine and Ansible in the Ubuntu WSL distro, creates a random local admin and database secret file at `~/.config/vendor-portal/.env` with mode 0600, then waits for Compose health and runs Selenium and Playwright test containers on the Compose network. Do not commit or copy that secret file into the repository.

## Jenkins
Run `scripts/run-local-ci.ps1` to start the repeatable WSL Jenkins and local Registry v2 demonstration. It creates a local Pipeline job from the `develop` branch and stores generated administrator/database secrets in WSL only. See [local Jenkins instructions](../ci/jenkins/README.md). The job runs Maven tests, frontend build, isolated Compose/Selenium tests, report archiving, Docker builds and a push to `localhost:5000`.

The Jenkinsfile also retains the external release path. Five-minute SCM polling is configured; a GitHub webhook is not configured. To use Docker Hub, configure `REGISTRY_NAMESPACE` and a Jenkins username/password credential, then pass its ID as `REGISTRY_CREDENTIALS_ID`; set `PUBLISH_IMAGES=true` to build/tag/push after the test stages pass.

### Configure a real deployment target

The sample inventory uses the documentation-only address `192.0.2.10`. Replace it with an Ubuntu/Debian VM you control and an SSH user:

```yaml
all:
  children:
    procurement:
      hosts:
        target-host:
          ansible_host: YOUR_PUBLIC_IP
          ansible_user: deploy
```

The target needs inbound SSH from the Jenkins machine and inbound TCP `8088` from the demo client. Restrict both firewall rules to known source IPs where possible. The playbook uses `become: true` to install Docker and configure the host. The current Jenkins command does not pass a sudo password, so the dedicated deployment account needs noninteractive sudo on this controlled VM; do not enable root SSH login. Keep SSH host-key checking enabled: verify the target fingerprint using the VM provider console, then add that host key to the Jenkins account's `known_hosts` before running the job.

Create a deployment-specific SSH keypair with `ssh-keygen -t ed25519 -C vendor-portal-deploy -f vendor-portal-deploy`. Install only its public key in `/home/deploy/.ssh/authorized_keys` on the VM. In Jenkins, add a credential of type **SSH Username with private key**, username `deploy`, credential ID `deploy-ssh-key`, and the matching private key (plus its passphrase, if set). Jenkins uses that credential through its `sshagent` step; keep this deployment key separate from the GitHub key. See [Jenkins SSH credentials](https://www.jenkins.io/doc/book/using/using-credentials/) and the [SSH Agent Pipeline step](https://www.jenkins.io/doc/pipeline/steps/ssh-agent/).

Before the first run, create `/opt/vendor-portal/.env` on the VM with mode `0600` and these entries (use unique strong values):

```dotenv
DB_PASSWORD=<database-user-secret>
MYSQL_ROOT_PASSWORD=<mysql-root-secret>
ADMIN_USERNAME=admin
ADMIN_PASSWORD=<portal-admin-secret>
```

The target must be able to pull the published images. For a public Docker Hub repository, set `REGISTRY_NAMESPACE` to its owner. For a private registry, authenticate the target's root Docker daemon (the play uses `become: true`) using that registry's supported credential storage; Jenkins' build credential does not automatically log the remote VM in.

Run the Jenkins job with `PUBLISH_IMAGES=true`, `REGISTRY_NAMESPACE=<registry-owner>`, `REGISTRY_CREDENTIALS_ID=<Jenkins-registry-credential-id>`, and `DEPLOY_TARGET=procurement`. The build tag is the Jenkins build number. The deploy stage installs the pinned `community.docker` collection from `ansible/requirements.yml`, applies the matching tag, and checks `http://<VM>:8088/actuator/health` from the target. The Ansible inventory format and SSH options are documented in the [Ansible inventory guide](https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html).

## Ansible
Ansible is installed in the local Ubuntu WSL distro with `community.docker`. The playbook syntax can be checked locally with `ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --syntax-check`. Edit `ansible/inventory/hosts.yml` to identify a Linux host you control and configure key-based SSH before deploying. The playbook installs Docker, stages Compose and starts the service. Configure the server `.env` securely out of band; the sample playbook deliberately does not copy secrets. Review Compose registry/image tags and host environment before deployment.

## Rollback
The Ansible playbook preserves the prior Compose file and attempts to restore it if a deployment health check fails. After one healthy deployment, rehearse recovery on the controlled VM by supplying a deliberately unavailable image tag to the playbook; expect Ansible to report the failed rollout after restoring the prior Compose release and confirming HTTP 200. A rollback rehearsal against a separate Linux target has not been run. Verify Nginx availability and backend health before declaring recovery.

## Local source
Backend: Java 21 and Maven 3.9 with MySQL 8. Frontend: Node 24/npm 11. Set DB connection and admin bootstrap environment variables; see root README. Flyway migrations run automatically at backend startup.
