# Architecture and data model

```mermaid
flowchart LR
 Browser[Browser / React + Vite] -->|HTTP Basic API| Proxy[Nginx]
 Proxy -->|/api| API[Spring Boot REST API]
 API -->|JDBC, transactions| DB[(MySQL 8.4)]
 Flyway[Flyway migrations] --> DB
 CI[Jenkins] --> Build[Build and tests]
 Build --> Images[Docker images]
 Images --> Target[Docker Compose target]
 Ansible[Ansible] --> Target
```

## Relational model

```mermaid
erDiagram
 APP_USERS ||--o{ PURCHASE_ORDERS : creates
 APP_USERS ||--o{ INVENTORY_TRANSACTIONS : performs
 VENDORS ||--o{ PURCHASE_ORDERS : supplies
 PURCHASE_ORDERS ||--|{ PURCHASE_ORDER_ITEMS : contains
 PRODUCTS ||--o{ PURCHASE_ORDER_ITEMS : ordered
 PRODUCTS ||--o{ INVENTORY_TRANSACTIONS : moves
```

Tables: `app_users` (unique username, BCrypt hash, role and optional vendor link), `vendors` (unique email), `products` (unique SKU and nonnegative stock constraints), `purchase_orders` (unique PO number, vendor and creator foreign keys, indexed status/date), `purchase_order_items` (quantity and price snapshot), `inventory_transactions` (signed quantity changes and user/product references), and `audit_logs` (future service-level audit expansion). Flyway owns schema; Hibernate validates it. Vendor accounts are scoped to one vendor on vendor and order reads.

## Security and data flow
Spring Security uses BCrypt and HTTP Basic; method-level role checks protect mutations. The application bootstraps an admin only when a password environment variable is provided, and never overwrites an existing account. REST input uses bean validation, database writes use parameterized SQL, and purchase order create/receive/stock changes run within transactions. Configure TLS at the edge and replace Basic auth with OIDC before production.
