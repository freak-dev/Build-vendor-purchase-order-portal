# Execution evidence

Verified locally on 2026-11-02:

- [x] Docker Compose builds the frontend and backend images and starts MySQL, API, and Nginx; database migrations applied through Flyway v2.
- [x] Compose health checks pass for MySQL, backend `/actuator/health`, and frontend Nginx.
- [x] Selenium: 5 browser workflows passed (login, vendor and product creation, purchase order creation, and approval).
- [x] Playwright: 6 tests passed, including sign-in rendering, dashboard login, vendor/product creation, purchase order creation, and approval.
- [x] Backend unit suite passed: 4 tests, 0 failures.
- [x] `git diff --check` passed after the implementation changes.
- [x] Ansible deployment playbook syntax checked against the sample inventory.

The repeatable WSL integration run is `scripts/run-integration.ps1`. Playwright writes its HTML report and test artifacts under `frontend/playwright-report` and `frontend/test-results`; failure screenshots are retained under `backend/target/selenium-screenshots`.

Not run in this workspace:

- [ ] Jenkins build, registry push, or Jenkins artifact archive; no Jenkins controller or registry credentials are configured.
- [ ] Ansible deployment or rollback rehearsal against another machine; the checked-in inventory intentionally uses the documentation-only address `192.0.2.10`.
- [ ] Release image publication or remote Git push; no Git remote is configured.
- [ ] Separate dashboard, inventory, reports, and alerts screenshots for the final report.
