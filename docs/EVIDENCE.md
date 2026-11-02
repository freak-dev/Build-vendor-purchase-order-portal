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

Not run in this workspace:

- [ ] Jenkins build, registry push, or Jenkins artifact archive; no Jenkins controller or registry credentials are configured.
- [ ] Ansible deployment or rollback rehearsal against another machine; the checked-in inventory intentionally uses the documentation-only address `192.0.2.10`.
- [ ] Remote Git push or GitHub pull request; no remote is configured.
- [ ] Final Windows-host browser check; the portal was checked through the WSL Docker network only.
