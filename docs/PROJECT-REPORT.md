# Project Report

## DevOps Pipeline for a Vendor Purchase Order Portal

**Student:** Shreyansh Chauhan  
**Roll number:** 23102B0017  
**Division:** BE CMPN B  
**Duration:** 15 weeks

## Abstract
This project develops a procurement portal to centralize vendor records, product catalogue, purchase orders and inventory receipt while demonstrating a software delivery pipeline. A React client communicates with a Spring Boot REST API backed by MySQL and Flyway. Docker Compose, Jenkins and Ansible provide reproducible build and deployment configuration. Automated test sources and operational health endpoints support verification.

## Problem statement and objectives
Manual purchasing through disconnected documents obscures current approvals, vendor history and stock needs. The project aims to provide a role-aware system of record, enforce a controlled purchase workflow, record inventory movements, identify low stock, and demonstrate automated build, test and deployment practices.

## Scope and proposed solution
The MVP contains Admin, Purchase Manager and Inventory Manager permissions, a vendor/product catalogue, multi-line purchase order API, status transitions, receiving, stock adjustment, dashboard, alerts and report export. MySQL constraints and transactional service operations protect key data. A responsive React interface provides common workflows. Vendor self-service, notifications and production identity integration are outside the current MVP scope.

## System architecture and requirements
See [SRS](SRS.md), [architecture and ER diagram](ARCHITECTURE.md), and [API guide](API.md). Runtime components are the browser, Nginx, Spring Boot, MySQL and Flyway; CI uses Jenkins and deployment configuration uses Docker and Ansible.

## DevOps lifecycle
Plan requirements and weekly milestones; code through Git branches; build Maven and Vite artifacts; test with JUnit/Spring Boot, Selenium and Playwright; package container images; deploy locally with Compose; and monitor health through Docker checks and the API endpoint. Jenkins stages are gated in source. Ansible deployment and rollback are implemented and syntax checked, but a remote deployment has not been performed.

## Testing and demonstration
Five Selenium browser scenarios cover login, vendor creation, product creation, order creation and order approval. Six Playwright tests cover the sign-in screen, login, vendor/product creation, order creation and approval. The backend unit suite has four passing tests. Compose starts MySQL, the API and Nginx; Flyway applies migrations through version 2. See [execution evidence](EVIDENCE.md) for verified results and environment-dependent steps that were not run.

## Installation and execution
Follow the root README and [deployment notes](DEPLOYMENT.md). Java 21/Maven, Node.js/npm, Docker Compose, MySQL and the local browser suites were exercised in this workspace. Never publish production credentials.

## Limitations and future work
HTTP Basic is suitable only for a protected academic demo; add OIDC, TLS termination, role-based vendor accounts, notification delivery, overdue rules, advanced filtering/pagination UI, expanded audit logging, stronger API error envelopes, automated rollback and production observability before production use. Multi-line orders are supported in the API, while the current user interface captures one line at a time.

## Conclusion
The repository contains an implemented procurement MVP and reproducible CI/deployment configuration. Local builds, tests, MySQL integration, browser automation and health checks passed. Jenkins execution, registry publication and deployment/rollback against a separate Linux host remain to be configured.

## References
Spring Boot, Spring Security, Spring Data and Flyway official documentation; React and Vite official documentation; MySQL 8 Reference Manual; Docker Compose documentation; Jenkins Pipeline documentation; Ansible documentation; Playwright documentation. See each project's official documentation for version-specific setup.

## Final checklist audit
See [the 15-task audit](FINAL-AUDIT-REPORT.md) for the implementation/files/commands/output/evidence/status ledger. The audit distinguishes local results from GitHub, Jenkins, registry, remote provisioning and rollback steps that were not executed.
