# Vendor Purchase Order Portal

A DevOps-enabled procurement MVP for managing suppliers, catalogue items, stock, purchase orders, approvals and reporting.

## Stack

- React 19, Vite, Axios, responsive CSS
- Java 21, Spring Boot 3.5, Spring Security HTTP Basic, Spring JDBC/JPA, Flyway
- MySQL 8.4, Docker Compose, Nginx, Jenkins, Ansible
- JUnit 5/Spring Boot Test and Playwright browser automation

## Start with Docker

1. Install Docker Desktop with the WSL2 backend.
2. Copy `.env.example` to `.env`, then replace every placeholder with strong local secrets. The Compose startup refuses to start unless `ADMIN_PASSWORD` is set.
3. Run `docker compose up --build` from the repository root.
4. Visit http://localhost:8088. Sign in with `ADMIN_USERNAME` and `ADMIN_PASSWORD` from `.env`.
5. Stop with `docker compose down`; preserve the database with its named volume. Remove stored data only with `docker compose down -v`.

The default Compose port is 8088. The backend and database are internal services; MySQL is not published to the host. The health endpoint is `/actuator/health`, and OpenAPI is at `/swagger-ui.html`.

## Local development

Requires Java 21, Maven 3.9+, Node.js 24, npm 11, and a MySQL 8 instance. Create a database and set `DB_URL`, `DB_USER`, `DB_PASSWORD`, `ADMIN_USERNAME`, and a strong `ADMIN_PASSWORD`. In separate terminals:

```powershell
cd backend
mvn spring-boot:run
```

```powershell
cd frontend
npm ci
npm run dev
```

Vite proxies `/api` to `localhost:8080`. The app uses HTTP Basic over TLS at deployment; configure HTTPS at the edge in a real deployment. Accounts are initialized at startup only when `ADMIN_PASSWORD` is set, and existing accounts are never overwritten.

## Test and build

```powershell
cd backend; mvn verify
cd frontend; npm ci; npm run build
```

E2E tests require the app, seeded vendor/product data and `E2E_USER`/`E2E_PASSWORD` (`admin`/`change-me` is only the Playwright local default):

```powershell
npx playwright install chromium
npm run test:e2e
```

Playwright captures screenshots and traces on failures and writes an HTML report to `frontend/playwright-report`.

## Jenkins and deployment

The Jenkinsfile runs backend verification, frontend install/build, archives packages and publishes Surefire reports. `RUN_E2E=true` enables the browser stage. Main-branch image publishing uses Jenkins credential `dockerhub`; deployment is gated after successful stages and uses the Ansible playbook. Configure a real Docker Hub namespace, registry credential, deployment inventory, SSH key credential, environment secrets and a Linux Docker target before enabling deployment. Never store credentials in source control.

Ansible inventory is a safe example placeholder (`192.0.2.10`). Configure it for a host you control. See [deployment notes](docs/DEPLOYMENT.md).

To execute the pipeline without external credentials, run `scripts/run-local-ci.ps1`. It launches a local Jenkins controller and registry inside WSL, runs the `develop` pipeline, and publishes images only to the local registry. See [the CI harness guide](ci/jenkins/README.md).

## GitHub

Local branches: `main` and `develop`. The `origin` remote is configured as `https://github.com/freak-dev/Build-vendor-purchase-order-portal.git`. The GitHub repository is public but empty; the connected GitHub integration currently returns HTTP 403 for contents writes, so no remote branch push or pull request is claimed. Named feature and DevOps branches in the coursework checklist were not fabricated as historical work.

```powershell
git push -u origin main
git push origin develop
```

## Scope and limitations

See [documentation](docs/README.md), [final 15-task audit](docs/FINAL-AUDIT-REPORT.md), [viva presentation](docs/FINAL-PRESENTATION.html), [SRS](docs/SRS.md), [architecture](docs/ARCHITECTURE.md), [milestone plan](docs/IMPLEMENTATION-PLAN.md), and [project report](docs/PROJECT-REPORT.md). This MVP exposes role-aware HTTP Basic credentials held in browser session storage; use an OAuth2/OIDC identity provider and secure same-site session/cookie strategy for production. Vendor accounts and notifications, overdue detection, robust multi-line UI editing, pagination controls, and a live Linux rollback rehearsal remain future work. Runtime evidence is only recorded after actual execution.
