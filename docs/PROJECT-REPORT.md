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
Plan requirements and weekly milestones; code through focused Git branches; build Maven and Vite artifacts; test with JUnit/Spring Boot and Playwright; package artifacts and container images; deploy with Compose/Ansible; operate through health checks and logs; monitor application health and low-stock/order alerts. Jenkins stages are gated in source. Execution evidence must be appended after a real configured run.

## Testing and demonstration
Five browser test scenarios cover login, vendor creation, product creation, order creation and order status update. The Playwright configuration retains screenshots/traces on failure. The backend is configured for Maven Surefire. No seeded credentials, test pass, deployment or deliberately failing defect demonstration is claimed. Reproduce the defect demonstration by introducing a controlled local validation regression in a disposable branch, capture the failing test, fix it, and rerun; retain both CI run links/screenshots as evidence.

## Installation and execution
Follow the root README and [deployment notes](DEPLOYMENT.md). Build/deploy outcomes depend on installing Java 21/Maven, npm packages, Docker and a configured MySQL/target environment. Never publish production credentials.

## Limitations and future work
HTTP Basic is suitable only for a protected academic demo; add OIDC, TLS termination, role-based vendor accounts, notification delivery, overdue rules, advanced filtering/pagination UI, expanded audit logging, stronger API error envelopes, automated rollback and production observability before production use. Multi-line orders are supported in the API, while the current user interface captures one line at a time.

## Conclusion
The repository now contains a source implementation and a reproducible pipeline configuration for a procurement MVP. Final acceptance depends on running actual builds, tests, MySQL integration, browser automation, deployment, health checks and rollback in an equipped environment.

## References
Spring Boot, Spring Security, Spring Data and Flyway official documentation; React and Vite official documentation; MySQL 8 Reference Manual; Docker Compose documentation; Jenkins Pipeline documentation; Ansible documentation; Playwright documentation. See each project's official documentation for version-specific setup.
