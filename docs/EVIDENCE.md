# Execution evidence

Verified locally on 2026-11-02:

- [x] Repeated `scripts/run-integration.ps1` during this audit: rebuilt backend/frontend images and started MySQL, API, and Nginx; all three Compose services reached healthy status.
- [x] Backend `/actuator/health` returned `{"status":"UP"}` and the portal homepage returned HTML through Nginx.
- [x] Selenium rerun: 5 browser workflows passed (login, vendor creation, product creation, purchase-order creation, and approval), 0 failures/errors.
- [x] Playwright rerun: 6 tests passed in 24.7 seconds, covering sign-in, login/dashboard, vendor/product creation, purchase-order creation, and approval.
- [x] Backend unit suite passed: 4 tests, 0 failures.
- [x] Frontend dependencies installed with `npm ci` (98 packages); Vite 7.3.7 production build passed (1,637 modules transformed).
- [x] Flyway migrations applied through v2.
- [x] `git diff --check` passed after the audit documentation changes.
- [x] Ansible deployment playbook syntax checked against the sample inventory; a mounted-config warning was emitted.

Latest local launch on 2026-11-02:

- [x] `wsl.exe -d Ubuntu -u root -- bash -lc 'bash /mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal/scripts/start-compose-wsl.sh'` rebuilt the backend/frontend Docker images and started the project with the existing WSL-only secret file.
- [x] Docker Compose `--wait` reported MySQL, backend, and frontend healthy.
- [x] `curl http://127.0.0.1:8088/actuator/health` returned `{"status":"UP"}`; `curl http://127.0.0.1:8088/` returned HTTP 200 (`text/html`).
- [x] The portal is available at `http://localhost:8088` while the Ubuntu WSL distro and Docker Engine are running. No external hosting is configured.

The repeatable WSL integration run is `scripts/run-integration.ps1`. Playwright writes its HTML report and test artifacts under `frontend/playwright-report` and failure screenshots are retained under `backend/target/selenium-screenshots`.

Additional audit attempts on 2026-11-02:

- Jenkins Build 2's recorded console/test/artifact/registry summary is preserved in [`evidence/jenkins-build-2-summary.txt`](evidence/jenkins-build-2-summary.txt).
- Jenkins Build 3's validation of the updated deployment pipeline is preserved in [`evidence/jenkins-build-3-summary.txt`](evidence/jenkins-build-3-summary.txt).
- GitHub SSH authentication and branch push output are summarized in [`evidence/github-push-summary.txt`](evidence/github-push-summary.txt).

- [x] GitHub SSH authentication succeeded as `freak-dev`; `git push -u origin main` and `git push -u origin develop` both succeeded. GitHub branch search confirmed both refs. Pull-request creation through the connector returned HTTP 403 `Resource not accessible by integration`; no PR/review is claimed. Comparison page: https://github.com/freak-dev/Build-vendor-purchase-order-portal/compare/main...develop?expand=1.
- [x] Clean local Jenkins 2.580.2 controller started in WSL and `vendor-portal-ci` Builds 1, 2, and 3 completed with `SUCCESS`. A prior Jenkins-home attempt failed validation because `timestamps()` was unavailable; that compatibility issue was corrected and a separate clean Jenkins home is used.
- [x] Each successful Jenkins build passed Maven unit tests (4 run, 0 failures/errors) and Selenium Failsafe (5 run, 0 failures/errors). Build 2 Selenium took 27.02 seconds; Build 3 took 28.15 seconds. Frontend `npm ci`/Vite production build passed.
- [x] Jenkins archived `backend/target/vendor-purchase-order-portal-1.0.0.jar` (65,693,412 bytes), `frontend/dist/index.html`, and `published-images.txt`. Build 2 confirmed the optional screenshot archive is skipped cleanly when there are no failure screenshots.
- [x] Jenkins Build 3 published backend image `localhost:5000/vendor/vendor-purchase-order-portal-backend:3` (digest `sha256:46ebeb32d51fa1e55de478c85fecce21a40f7aab76938ab7d906d2c6abf259fb`) and frontend image `localhost:5000/vendor/vendor-purchase-order-portal-frontend:3` (digest `sha256:accfbf83605b742c6afc62d8ca78b9e64daa338050360ee206628d6de2bdebff`). Registry tag endpoints confirmed both repositories at tags `1`, `2`, and `3`.
- [x] Build 3 validated the updated Jenkins deploy-stage definition. Deployment was skipped because no external target was configured.
- [x] Jenkins deployment stage was skipped by its target condition; no external deployment is claimed.

Still not demonstrated:

- [ ] Publishing to a hosted registry such as Docker Hub; this verified publish used the local Registry v2 only.
- [ ] Ansible deployment or rollback rehearsal against another machine; the checked-in inventory intentionally uses the documentation-only address `192.0.2.10`.
- [x] Remote Git push: SSH-authenticated pushes of `main` and `develop` succeeded; branch search confirmed both.
- [ ] GitHub pull request/review: connector PR creation returned HTTP 403. Use the `main...develop` comparison link in `evidence/github-push-summary.txt` or grant Pull Requests write access to the connector.
- [ ] Final Windows-host browser check; the portal was checked through the WSL Docker network only.

Render hosting preparation on 2026-11-02:

- [x] Parsed `render.yaml` with PyYAML; it defines `vendor-portal-api` (Docker, free) and `vendor-portal-web` (static, free).
- [x] Built the Vite production frontend with `VITE_API_BASE_URL=https://vendor-portal-api.onrender.com`; the expected API hostname was present in the generated bundle.
- [x] Ran `scripts/run-integration.ps1` after adding Render URL configuration and Spring CORS support: Compose backend/frontend/MySQL healthy, Maven 4/4 unit tests passed, Selenium 5/5 passed, and Playwright 6/6 passed.
- [x] Fixed a Selenium setup wait that could read a React heading after its node was replaced; the final Selenium rerun passed in 28.46 seconds.
- [ ] Public Render deployment remains pending: no Render or Aiven account authorization is configured. The Blueprint requires an Aiven free MySQL service because Render's free database offering is PostgreSQL.
