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

The repeatable WSL integration run is `scripts/run-integration.ps1`. Playwright writes its HTML report and test artifacts under `frontend/playwright-report` and failure screenshots are retained under `backend/target/selenium-screenshots`.

Additional audit attempts on 2026-11-02:

- Jenkins Build 2's recorded console/test/artifact/registry summary is preserved in [`evidence/jenkins-build-2-summary.txt`](evidence/jenkins-build-2-summary.txt).
- GitHub SSH authentication and branch push output are summarized in [`evidence/github-push-summary.txt`](evidence/github-push-summary.txt).

- [x] GitHub SSH authentication succeeded as `freak-dev`; `git push -u origin main` and `git push -u origin develop` both succeeded. GitHub branch search confirmed both refs. Pull-request creation through the connector returned HTTP 403 `Resource not accessible by integration`; no PR/review is claimed. Comparison page: https://github.com/freak-dev/Build-vendor-purchase-order-portal/compare/main...develop?expand=1.
- [x] Clean local Jenkins 2.580.2 controller started in WSL and `vendor-portal-ci` Builds 1 and 2 completed with `SUCCESS`. A prior Jenkins-home attempt failed validation because `timestamps()` was unavailable; that compatibility issue was corrected and a separate clean Jenkins home is used.
- [x] Each successful Jenkins build passed Maven unit tests (4 run, 0 failures/errors) and Selenium Failsafe (5 run, 0 failures/errors); Build 2 Selenium took 27.02 seconds. Frontend `npm ci`/Vite production build passed.
- [x] Jenkins archived `backend/target/vendor-purchase-order-portal-1.0.0.jar` (65,693,412 bytes), `frontend/dist/index.html`, and `published-images.txt`. Build 2 confirmed the optional screenshot archive is skipped cleanly when there are no failure screenshots.
- [x] Jenkins published backend image `localhost:5000/vendor/vendor-purchase-order-portal-backend:2` (digest `sha256:46ebeb32d51fa1e55de478c85fecce21a40f7aab76938ab7d906d2c6abf259fb`) and frontend image `localhost:5000/vendor/vendor-purchase-order-portal-frontend:2` (digest `sha256:accfbf83605b742c6afc62d8ca78b9e64daa338050360ee206628d6de2bdebff`). Registry tag endpoints confirmed both repositories at tags `1` and `2`.
- [x] Jenkins deployment stage was skipped by its target condition; no external deployment is claimed.

Still not demonstrated:

- [ ] Publishing to a hosted registry such as Docker Hub; this verified publish used the local Registry v2 only.
- [ ] Ansible deployment or rollback rehearsal against another machine; the checked-in inventory intentionally uses the documentation-only address `192.0.2.10`.
- [x] Remote Git push: SSH-authenticated pushes of `main` and `develop` succeeded; branch search confirmed both.
- [ ] GitHub pull request/review: connector PR creation returned HTTP 403. Use the `main...develop` comparison link in `evidence/github-push-summary.txt` or grant Pull Requests write access to the connector.
- [ ] Final Windows-host browser check; the portal was checked through the WSL Docker network only.
