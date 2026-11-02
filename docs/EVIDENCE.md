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

- [x] GitHub remote set to `https://github.com/freak-dev/Build-vendor-purchase-order-portal.git`; repository inspection confirmed a public, empty repository. GitHub integration file creation still returns HTTP 403 `Resource not accessible by integration`, so no branch push or PR was made.
- [x] Clean local Jenkins 2.580.2 controller started in WSL and `vendor-portal-ci` Build 1 completed with `SUCCESS`. A prior Jenkins-home attempt failed validation because `timestamps()` was unavailable; that compatibility issue was corrected, and a fresh home was used for the verified run.
- [x] Jenkins Maven unit tests: 4 run, 0 failures/errors. Jenkins Selenium Failsafe: 5 run, 0 failures/errors (23.69 seconds). Frontend `npm ci`/Vite production build passed.
- [x] Jenkins archived `backend/target/vendor-purchase-order-portal-1.0.0.jar` (65,693,412 bytes), `frontend/dist/index.html`, and `published-images.txt`. The optional Selenium screenshot glob was empty on a successful run; Jenkins printed a warning for that empty glob.
- [x] Jenkins published backend image `localhost:5000/vendor/vendor-purchase-order-portal-backend:1` (digest `sha256:46ebeb32d51fa1e55de478c85fecce21a40f7aab76938ab7d906d2c6abf259fb`) and frontend image `localhost:5000/vendor/vendor-purchase-order-portal-frontend:1` (digest `sha256:accfbf83605b742c6afc62d8ca78b9e64daa338050360ee206628d6de2bdebff`). Registry catalog and tag endpoints confirmed both at tag `1`.
- [x] Jenkins deployment stage was skipped by its target condition; no external deployment is claimed.

Still not demonstrated:

- [ ] Publishing to a hosted registry such as Docker Hub; this verified publish used the local Registry v2 only.
- [ ] Ansible deployment or rollback rehearsal against another machine; the checked-in inventory intentionally uses the documentation-only address `192.0.2.10`.
- [ ] Remote Git push or GitHub pull request. `origin` is configured, but the connected GitHub integration rejected the write with HTTP 403.
- [ ] Final Windows-host browser check; the portal was checked through the WSL Docker network only.
