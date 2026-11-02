# Render free-tier demo deployment

The project has a free Render Postgres database and a live static frontend in the confirmed Render workspace. `render.yaml` defines only the Spring Boot API and references the existing Postgres database by its Render name; it will not create duplicate database or frontend resources. The API uses the free plan in Singapore, PostgreSQL Flyway migrations, and `/actuator/health` for its health check.

Render's free Postgres expires after 30 days (this instance is scheduled to expire on December 2, 2026). Export data before expiration. Free web services may sleep after inactivity. These free resources are for coursework and demos, not durable production hosting.

## Finish the API deployment

1. In the Render Dashboard, choose **New > Blueprint** and connect `https://github.com/freak-dev/Build-vendor-purchase-order-portal`, branch `develop`.
2. Keep the Blueprint path as `render.yaml`. It defines only `vendor-portal-api-shreyansh-23102b0017`; its database references resolve to the already provisioned `vendor-portal-db` resource in this workspace.
3. Review the changes and deploy the Blueprint. Render requires this Dashboard action to create/sync a Blueprint; the connected Render tools cannot submit that action.
4. Wait for the API deploy to become live and pass `/actuator/health`. The static site already embeds this API URL and its origin is configured in `APP_CORS_ORIGINS`.
5. Retrieve the generated `ADMIN_PASSWORD` from the API service's environment settings. Never commit or paste it into chat.

## Local PostgreSQL mode

Set `DB_URL`, `DB_USER`, `DB_PASSWORD`, and `FLYWAY_LOCATIONS=classpath:db/migration-postgresql`. The local Docker Compose setup continues to use MySQL migrations. Both migration sets represent the same schema.

## Recreate resources in another workspace

Create a free Postgres database named `vendor-portal-db` and a static site named `vendor-portal-web-shreyansh-23102b0017` first. Use `frontend/` as the static site's root directory, `npm ci && npm run build` as the build command, and `dist` as the publish path. Set `VITE_API_BASE_URL` to `https://vendor-portal-api-shreyansh-23102b0017.onrender.com`, then apply this Blueprint to create the API.
