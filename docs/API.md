# API guide

All JSON routes are under `/api`. Sign in with `POST /api/auth/login` and JSON `{ "username": "…", "password": "…" }`; browser/API clients authenticate with HTTP Basic. `POST /api/auth/logout` is a client sign-out signal (stateless Basic credentials must be discarded by the client).

| Method | Route | Access | Purpose |
|---|---|---|---|
| GET | `/auth/me` | signed in | Current principal, role and linked vendor ID (vendor accounts) |
| GET/POST | `/users` | Admin | List users; create a user with a BCrypt password hash and role. Vendor users must include `vendorId`. |
| GET | `/dashboard` | signed in | Database-backed totals, latest orders, stock alerts |
| GET/POST | `/vendors` | signed in / Admin, Purchase Manager | Search/create vendors |
| GET/PUT/DELETE | `/vendors/{id}` | signed in / Admin, Purchase Manager / Admin | Detail/update/deactivate |
| GET/POST | `/products` | signed in / Admin, Inventory Manager | Search/create catalogue |
| GET/PUT/DELETE | `/products/{id}` | signed in / Admin, Inventory Manager / Admin | Detail/update/deactivate |
| GET/POST | `/orders` | signed in / Admin, Purchase Manager | Paged filter/list and create order |
| GET | `/orders/{id}` | signed in | Order detail and line items |
| PATCH | `/orders/{id}/status` | signed in / Admin, Purchase Manager, Inventory Manager | Validated order transition and receipt |
| POST | `/inventory/{productId}/adjust` | signed in / Admin, Inventory Manager | Set count and write stock movement |
| GET | `/inventory/transactions` | signed in / Admin, Inventory Manager | Movement history |
| GET | `/alerts` | signed in | Low stock and pending approval |
| GET | `/reports/summary` | signed in | Vendor, category and status summaries |
| GET | `/reports/orders.csv` | signed in | CSV export |

OpenAPI UI: `/swagger-ui.html`; health: `/actuator/health`. Validation errors and access errors use Spring's HTTP error handling. See source validation annotations and Flyway SQL for field constraints.
