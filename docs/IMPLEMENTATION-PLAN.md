# Delivery status

The source implementation and local verification for the Vendor Purchase Order Portal are complete. This checklist tracks the coursework milestones and distinguishes local work from steps that require an external service or target.

## Environment and source

- [x] Windows workspace initialized as a Git repository with `main` and `develop` branches.
- [x] Java 21 and Maven 3.9 installed as portable workspace tools; Node.js 24/npm available.
- [x] Ubuntu WSL2, Docker Engine/Compose, Ansible Core, and `community.docker` installed.
- [x] Spring Boot API, MySQL schema/migrations, role-aware authentication, React client, and documentation implemented.

## 15-week milestone checklist

- [x] Weeks 1–3: scope, requirements, architecture and environment setup.
- [x] Weeks 4–6: Git workflow and procurement MVP.
- [x] Weeks 7–8: Jenkins pipeline and Docker deployment configuration.
- [x] Weeks 9–10: Selenium and Playwright tests; local end-to-end suites executed successfully.
- [x] Weeks 11–12: Docker images and Compose services built and started locally.
- [x] Week 13: Ansible deployment and rollback playbook implemented and syntax checked.
- [ ] Week 14: deployment, health verification and rollback against a separate Linux target; no authorized target is configured.
- [ ] Week 15: Jenkins run, registry publication, remote release and viva screenshots; no Jenkins controller or registry/remote credentials are configured.

See [execution evidence](EVIDENCE.md) for test counts and the remaining environment-dependent work.
