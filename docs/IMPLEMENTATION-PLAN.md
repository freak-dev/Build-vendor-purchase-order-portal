# Delivery status

The source implementation and local verification for the Vendor Purchase Order Portal are complete. This checklist tracks the coursework milestones and distinguishes local work from steps that require an external service or target.

## Environment and source

- [x] Windows workspace initialized as a Git repository with `main` and `develop` branches.
- [x] Java 21 and Maven 3.9 installed as portable workspace tools; Node.js 24/npm available.
- [x] Ubuntu WSL2, Docker Engine/Compose, Ansible Core, and `community.docker` installed.
- [x] Spring Boot API, MySQL schema/migrations, role-aware authentication, React client, and documentation implemented.

## 15-week milestone checklist

- [x] Weeks 1–3: scope, requirements, architecture and environment setup.
- [ ] Weeks 4–6: local Git and procurement MVP implemented; GitHub remote, named feature branches and pull-request collaboration remain unverified.
- [ ] Weeks 7–8: Jenkinsfile and deployment configuration implemented; no Jenkins controller run or external deployment recorded.
- [ ] Weeks 9–10: local Selenium (5) and Playwright (6) suites pass; Jenkins continuous-test run remains unverified.
- [ ] Weeks 11–12: Docker Compose lifecycle passed locally; Jenkins registry publication and deployment remain unverified.
- [ ] Week 13: Ansible configuration implemented and syntax checked; provisioning against a separate host remains unverified.
- [ ] Week 14: local container health passed; no separate Linux target or rollback rehearsal is configured.
- [ ] Week 15: final documentation and viva presentation prepared; Jenkins, registry, remote release, rollback and final runtime screenshots remain outstanding.

See [execution evidence](EVIDENCE.md) for test counts and the remaining environment-dependent work.

See [the final 15-task audit](FINAL-AUDIT-REPORT.md) for per-task implementation, files, commands, actual output, evidence required and completion status.
