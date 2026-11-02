# Execution evidence checklist

Capture evidence only after actual execution; do not substitute mock screenshots.

- [ ] Backend `mvn verify` result and Surefire report XML.
- [ ] Flyway migration success and MySQL schema/integration verification.
- [ ] Frontend `npm ci` and `npm run build` output.
- [ ] Five Playwright E2E results plus HTML report; failure screenshot/trace if a test fails.
- [ ] Reproducible defect demonstration: failing test, corrective commit, successful rerun.
- [ ] Jenkins build URL/log and archived artifacts.
- [ ] Docker Compose service status, image tags, frontend screenshot and backend health endpoint.
- [ ] Ansible playbook run against an authorized Linux target and health check.
- [ ] Rollback from a test release and post-rollback health verification.
- [ ] Final application screenshots: dashboard, vendor, product, order workflow, inventory, reports, alerts.

Environment inspection on 2026-11-02 (client date): Windows PowerShell 7.6.5, Node 24.14.1, npm 11.11.0, Git 2.53.0 and Python 3.14 available; Java, Maven, Docker and Ansible were not found. Therefore none of the above executions are currently claimed.
