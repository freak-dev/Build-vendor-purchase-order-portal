# Final Project Audit Report

## DevOps Pipeline for a Vendor Purchase Order Portal

**Student:** Shreyansh Chauhan  
**Roll number:** 23102B0017  
**Division:** BE CMPN B  
**Project duration:** 15 weeks  
**Audit date:** 2 November 2026

## Executive assessment

The repository contains a working academic MVP and substantial local DevOps implementation. The strongest verified evidence is the local Maven build and four passing backend unit tests, five passing Selenium workflows, six passing Playwright tests, Docker Compose startup with MySQL migrations and health checks, and an Ansible syntax check. These results are recorded in `docs/EVIDENCE.md` and were produced in the local WSL/Docker environment.

The assignment is **not fully complete against its end-to-end acceptance criteria**. A GitHub remote and repository are now identified, and a local Jenkins controller was brought up. However, the GitHub integration rejected a contents write (HTTP 403); the local Jenkins Build 1 failed Jenkinsfile validation, and no successful Jenkins build or registry image was verified. No external Linux target or rollback rehearsal was available. Final result remains **4 tasks complete, 11 partially complete, 0 wholly unimplemented**. “Partial” means code or documentation exists but the requested integration or evidence has not been completed.

## Task-by-task audit

### 1. Problem definition and scope — COMPLETE

**Task description:** Define the procurement problem, objectives, users, and scope.  
**Implementation:** The project defines a portal for vendor/product records, purchase orders, approvals, inventory receiving, alerts, and reports. It sets academic MVP boundaries and lists future work.  
**Files:** `docs/PROJECT-REPORT.md`, `docs/SRS.md`, `README.md`.  
**Commands executed:** Repository/document review; no runtime command required.  
**Actual output:** Problem statement, objectives, scope, role descriptions, requirements, and limitations are present in the documents.  
**Evidence required:** Retain the final report and SRS in the submission.  
**Completion status:** Complete.

### 2. Agile planning and DevOps workflow — PARTIAL

**Task description:** Plan the 15-week milestones and describe the delivery workflow.  
**Implementation:** The 15-week milestone checklist and Plan → Code → Build → Test → Release → Deploy → Operate → Monitor workflow are documented. Iteration history is visible in Git commits, but no sprint board, backlog, or review records are present.  
**Files:** `docs/IMPLEMENTATION-PLAN.md`, `docs/PROJECT-REPORT.md`, Git history.  
**Commands executed:** `git log --oneline --decorate -10`.  
**Actual output:** Three implementation commits are present; current branch is `develop`. No sprint-board export or meeting records exist in the repository.  
**Evidence required:** Add dated sprint/backlog snapshots or instructor-approved planning records if required by the course.  
**Completion status:** Partial.

### 3. Requirements and architecture — COMPLETE

**Task description:** Specify functional/non-functional requirements and system architecture.  
**Implementation:** SRS, architecture and ER diagrams, API documentation, database migration scripts, and OpenAPI UI configuration are present.  
**Files:** `docs/SRS.md`, `docs/ARCHITECTURE.md`, `docs/API.md`, `backend/src/main/resources/db/migration/V1__initial_schema.sql`, `V2__vendor_user_scope.sql`.  
**Commands executed:** Source and documentation inspection; Docker/Flyway execution recorded in `docs/EVIDENCE.md`.  
**Actual output:** Flyway applied schema through v2 in the local Compose run; architecture and API descriptions are checked into the project.  
**Evidence required:** Include architecture/ER diagrams and API screenshot in the academic submission if requested.  
**Completion status:** Complete.

### 4. Git and GitHub initialization — PARTIAL

**Task description:** Initialize Git, branches, GitHub templates, and remote collaboration.  
**Implementation:** Local Git repository, `main` and `develop`, `.gitignore`, contribution guide, issue template, and pull-request template are present. `origin` points to the user-provided empty GitHub repository. Named feature/devops branches are documented, but were not created. The connected GitHub integration currently rejects contents writes.
**Files:** `.git`, `.gitignore`, `CONTRIBUTING.md`, `.github/ISSUE_TEMPLATE/bug_report.md`, `.github/pull_request_template.md`, `README.md`.  
**Commands executed:** `git branch --all --verbose`; `git remote -v`; `git log --oneline --decorate -10`.  
**Actual output:** Repository `https://github.com/freak-dev/Build-vendor-purchase-order-portal` exists, is public, and is empty. `origin` is set locally. GitHub repo inspection reports user-level admin/push permission, but the connected integration's file creation returned HTTP 403 `Resource not accessible by integration`; no refs have been pushed. Local `develop` now has commits through `19b303b`.
**Evidence required:** Grant the connected GitHub integration repository contents write permission or authenticate GitHub CLI, then push branches and capture a real pull request/review.
**Completion status:** Partial.

### 5. Feature development with branching — PARTIAL

**Task description:** Develop features through the assigned feature branches.  
**Implementation:** Authentication, vendor/product management, purchase orders, inventory, and dashboard/report features are implemented. Work is committed locally, but feature branch names listed in the assignment are not present in Git history.  
**Files:** `backend/src/main/java/com/vendorportal/`, `frontend/src/`, Git history.  
**Commands executed:** `git branch --all --verbose`; `git log --oneline --decorate -10`.  
**Actual output:** Functional source and commits exist on `main`/`develop`; the requested `feature/*` and `devops/*` branches are absent.  
**Evidence required:** Do not fabricate historical branches. If branch evidence is mandatory, use future changes to create real branches and merge them through pull requests.  
**Completion status:** Partial.

### 6. MVP completion and Git collaboration — PARTIAL

**Task description:** Complete the MVP and demonstrate collaboration/merging.  
**Implementation:** The local MVP supports user sign-in, role-aware APIs, vendor/product CRUD, purchase-order workflow, receiving and stock, dashboard, alerts, and reports. No remote pull request or collaborator review is recorded. The interface currently supports one order line at a time although the API accepts multiple lines.  
**Files:** `backend/src/main/java/com/vendorportal/`, `frontend/src/App.jsx`, `docs/SRS.md`, `docs/PROJECT-REPORT.md`.  
**Commands executed:** Maven tests, Selenium and Playwright suites, and Docker Compose checks; see actual counts below and `docs/EVIDENCE.md`.  
**Actual output:** Backend unit tests 4/4 passed; Selenium 5/5 passed; Playwright 6/6 passed in the recorded integration run.  
**Evidence required:** Capture a clean application demonstration and a merged GitHub pull request.  
**Completion status:** Partial.

### 7. Jenkins CI setup — PARTIAL

**Task description:** Configure Jenkins and verify continuous integration.  
**Implementation:** A declarative `Jenkinsfile` defines SCM polling, Maven verification, frontend installation/build, Selenium, JUnit publishing, artifact archiving, and parameterized registry/deploy gates. A local Jenkins controller and local Registry v2 were started in WSL. The pipeline job initialized and Build 1 was triggered.
**Files:** `Jenkinsfile`, `docs/DEPLOYMENT.md`.  
**Commands executed:** `scripts/run-local-ci.ps1` (local Jenkins/Registry bootstrap and build trigger).
**Actual output:** Jenkins 2.580.2 started at `http://localhost:8081`; job `vendor-portal-ci` was created. Build 1 was recorded and failed during Jenkinsfile validation because the controller did not have the Timestamper plugin. That directive has since been removed. A subsequent rerun did not return a verified final build result before this report was updated. No successful build/test report is claimed. SCM polling is configured for five-minute intervals; GitHub webhook is not configured.
**Evidence required:** Rerun the pipeline and capture a successful build number, console output, and archived reports.
**Completion status:** Partial.

### 8. Pipeline as Code and deployment — PARTIAL

**Task description:** Keep pipeline/deployment configuration as code and run a deployment.  
**Implementation:** Jenkinsfile contains checkout, build/test, package, Docker publication, Ansible deployment gates, and health checking. Deployment runs only on `main` after prior stages pass and requires a configured target.  
**Files:** `Jenkinsfile`, `ansible/playbooks/deploy.yml`, `ansible/templates/docker-compose.deploy.yml.j2`.  
**Commands executed:** Local Jenkins controller startup and pipeline trigger; Ansible syntax check recorded.
**Actual output:** Pipeline and deploy playbook are checked in. Jenkins Build 1 failed validation; no successful pipeline run or target deployment is verified.
**Evidence required:** Capture successful Jenkins stage logs and target health response after deployment.  
**Completion status:** Partial.

### 9. Selenium local testing — COMPLETE

**Task description:** Run at least five meaningful browser tests locally with assertions and failure artifacts.  
**Implementation:** Selenium covers login, vendor creation, product creation, purchase-order creation, and approval/status change. It supports remote WebDriver and stores failure HTML/screenshots.  
**Files:** `backend/src/test/java/com/vendorportal/PortalE2EIT.java`, `backend/pom.xml`, `scripts/run-integration.ps1`, `scripts/run-integration-wsl.sh`.  
**Commands executed:** `scripts/run-integration.ps1` (repeated successfully during this audit).  
**Actual output:** Maven Failsafe: `Tests run: 5, Failures: 0, Errors: 0`; Selenium passed. The same run reported Playwright `6 passed (24.7s)`.  
**Evidence required:** Preserve `backend/target/failsafe-reports` and screenshots for submission.  
**Completion status:** Complete.

### 10. Continuous testing in Jenkins — PARTIAL

**Task description:** Run automated tests in Jenkins and prevent deployment after test failure.  
**Implementation:** Jenkinsfile runs Maven verification and Selenium before package/image/deployment stages. Jenkins declarative stage ordering gates later stages on success.  
**Files:** `Jenkinsfile`, `backend/pom.xml`.  
**Commands executed:** Inspected pipeline; local Selenium command is documented above. Jenkins execution was unavailable.  
**Actual output:** Jenkins Build 1 failed before tests ran (`timestamps()` declarative option unavailable). The option was removed, but no later successful Jenkins run or Jenkins test report is verified. Earlier local tests pass; no controlled application-defect/fix pair is demonstrated.
**Evidence required:** Run Jenkins once successfully and capture a controlled failing test followed by a fixed successful build, if the assignment requires the defect demonstration.  
**Completion status:** Partial.

### 11. Docker lifecycle — COMPLETE

**Task description:** Build and run the application containers with persistent MySQL, Nginx, and health checks.  
**Implementation:** Backend/frontend Dockerfiles and Compose services for MySQL, Spring Boot, and Nginx; database volume and service health checks; lifecycle commands in documentation.  
**Files:** `Dockerfile.backend`, `Dockerfile.frontend`, `docker-compose.yml`, `nginx/default.conf`, `.dockerignore`, `docs/DEPLOYMENT.md`.  
**Commands executed:** Compose build/up/health checks through the WSL integration scripts (recorded successful run).  
**Actual output:** The repeated integration run rebuilt the images and confirmed MySQL, backend, and frontend healthy; Flyway is at v2. `/actuator/health` returned `{"status":"UP"}` and the portal homepage returned HTML through Nginx. Windows browser access was not verified.  
**Evidence required:** Capture `docker compose ps`, healthy container status, and browser access from the intended demo machine on the day of presentation.  
**Completion status:** Complete for local lifecycle testing; WSL health confirmed, Windows browser access unverified.

### 12. Jenkins-Docker deployment — PARTIAL

**Task description:** Build/tag/push images and deploy them through Jenkins after tests.  
**Implementation:** Jenkinsfile has main-branch Docker build/tag/push and gated Ansible deploy stages using Jenkins credentials.  
**Files:** `Jenkinsfile`, `Dockerfile.backend`, `Dockerfile.frontend`, `ansible/playbooks/deploy.yml`.  
**Commands executed:** Local Registry v2 and Jenkins containers were started; pipeline was triggered with `PUBLISH_IMAGES=true`, `REGISTRY_HOST=localhost:5000`, and namespace `vendor`.
**Actual output:** The pipeline has not produced a verified successful run. No image tag/digest was confirmed in Registry v2, and no external deployment or Jenkins deployment log exists.
**Evidence required:** Configure registry/Jenkins credentials, push a tagged release, deploy to a controlled host, and capture image digest and health response.  
**Completion status:** Partial.

### 13. Ansible configuration management — PARTIAL

**Task description:** Provision and deploy idempotently with Ansible.  
**Implementation:** Configuration, sample inventory/group variables, community Docker dependency, compose template, Docker installation, secret precondition, deploy, health check, and rescue rollback tasks are present.  
**Files:** `ansible/ansible.cfg`, `ansible/inventory/hosts.yml`, `ansible/group_vars/procurement.yml`, `ansible/requirements.yml`, `ansible/playbooks/deploy.yml`, `ansible/templates/docker-compose.deploy.yml.j2`.  
**Commands executed:** `ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/deploy.yml --syntax-check`.  
**Actual output:** `playbook: plays/deploy.yml`; syntax check passed with a warning that project-mounted Ansible configuration was ignored because the mounted path is world-writable. No target was provisioned.  
**Evidence required:** Configure a Linux host and SSH key, run the playbook, then capture the resulting services and health check.  
**Completion status:** Partial.

### 14. Provisioning, health checks and rollback — PARTIAL

**Task description:** Verify app/database/container health and demonstrate rollback/recovery.  
**Implementation:** Actuator health, Compose health checks, Ansible deploy health retry, and rollback rescue tasks exist. Local Compose health passed. The rescue path has not been exercised on a separate target.  
**Files:** `backend/src/main/resources/application.yml`, `docker-compose.yml`, `ansible/playbooks/deploy.yml`, `docs/DEPLOYMENT.md`.  
**Commands executed:** Local Compose health checks passed in the recorded run; Ansible syntax check passed.  
**Actual output:** Local MySQL/backend/frontend healthy. No failed-release rehearsal or rollback recovery output exists.  
**Evidence required:** Deploy a known good image, attempt a deliberately unhealthy tagged release, capture rollback logs and verify the prior release returns HTTP 200.  
**Completion status:** Partial.

### 15. Final release, documentation and viva — PARTIAL

**Task description:** Prepare release, complete documentation, and support viva/demo.  
**Implementation:** README, SRS, architecture, API, deployment, evidence, implementation plan and project report are present. This audit and presentation complete the written submission package. Release publication, GitHub/Jenkins evidence, and screenshots from the final live environment remain outstanding.  
**Files:** `README.md`, `docs/`, `docs/FINAL-AUDIT-REPORT.md`, `docs/FINAL-PRESENTATION.html`.  
**Commands executed:** Maven and browser suites as recorded above; final presentation/report files authored in this audit.  
**Actual output:** Documentation is in the repository; external release activities were not executed.  
**Evidence required:** Add real dashboard/workflow screenshots, GitHub remote/PR, Jenkins build, registry image, target deployment and rollback outputs before claiming full acceptance.  
**Completion status:** Partial.

## Consolidated verification results

| Check | Actual result | Status |
|---|---|---|
| Maven `verify` | 4 tests, 0 failures, 0 errors; `BUILD SUCCESS` | Pass |
| Selenium Failsafe | 5 tests, 0 failures, 0 errors | Pass (repeated during audit) |
| Playwright | 6 passed in 24.7 seconds | Pass (repeated during audit) |
| Docker Compose | Rebuild passed; all 3 services healthy; homepage served; actuator returned `{"status":"UP"}` | Pass (repeated during audit) |
| Flyway | Migrations applied through v2 | Pass (recorded integration run) |
| Ansible syntax | `playbook: plays/deploy.yml`; syntax passed with mounted config warning | Pass with warning |
| Frontend install/build | `npm ci --no-audit --no-fund` added 98 packages in 11s; `npm run build` passed with Vite 7.3.7 and 1,637 modules transformed | Pass |
| GitHub push/PR | `origin` set to user repository; connector write returned HTTP 403; no remote refs or PR | Blocked on GitHub integration contents-write authorization or local GitHub CLI auth |
| Jenkins | Jenkins 2.580.2 local controller and job started; Build 1 failed Jenkinsfile validation (`timestamps` option unavailable); later final result unverified | Fail / rerun needed |
| Local registry publish | Local Registry v2 started and publish parameters supplied; no successful image/digest verified | Not demonstrated |
| External Ansible deploy/rollback | No authorized target or SSH credential configured | Not run |

## Project acceptance gaps

The MVP is a demonstrable academic application, not a production-hardened procurement service. Current documented limitations include HTTP Basic authentication, no vendor self-service accounts, no delivered notifications or overdue-order detection, limited date/sort filters, and a one-line-per-entry order UI (the API accepts multiple lines). The final demo should use non-production data and secrets. Do not claim GitHub publication, Jenkins success, registry push, external provisioning, or rollback until captured from the actual services.

## Submission evidence checklist

- [ ] Application dashboard and responsive layout screenshot
- [ ] Vendor and product create/update screenshots
- [ ] Purchase-order approval and goods receipt screenshots
- [ ] Report/CSV and low-stock alert screenshot
- [ ] Maven Surefire report and Selenium Failsafe report
- [ ] Playwright HTML report
- [ ] Healthy Docker Compose service listing and Flyway migration evidence
- [ ] GitHub remote, required branches, and merged pull request
- [ ] Jenkins successful build console and published reports
- [ ] Tagged registry images and image digests
- [ ] Ansible provision/deploy output from a controlled Linux target
- [ ] Failed-release rollback log and post-rollback HTTP 200
