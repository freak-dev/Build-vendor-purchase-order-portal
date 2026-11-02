# Render free-tier deployment

This setup uses Render's free static-site and web-service plans with a separate Aiven free MySQL database. It has no monthly hosting charge under the providers' current free-tier limits, but free services can sleep or be suspended and are not suitable for production. Render's built-in free database is PostgreSQL and expires after 30 days, so this project keeps MySQL and uses Aiven instead.

## Blueprint

`render.yaml` creates:

- `vendor-portal-api`: the Spring Boot Docker image, free plan, `/actuator/health` health check.
- `vendor-portal-web`: a free static React/Vite site built from `frontend/`.

The frontend uses `VITE_API_BASE_URL` to call the backend's public URL. Spring Security CORS is restricted to the named frontend URL in `APP_CORS_ORIGINS`. If Render changes either URL to resolve a name conflict, update both values in the two services and redeploy. The API service generates `ADMIN_PASSWORD`; obtain it from the Render service environment settings after creation. Never commit it.

## Create the free MySQL database

1. Create an Aiven account and a MySQL service on its free plan.
2. Wait until the database reports `RUNNING`. Use the service connection details from Aiven's dashboard.
3. In Render's Blueprint creation flow, provide these API service variables when prompted:
   - `DB_URL`: `jdbc:mysql://<AIVEN_HOST>:<AIVEN_PORT>/<AIVEN_DATABASE>?sslMode=REQUIRED&serverTimezone=UTC`
   - `DB_USER`: the Aiven database username.
   - `DB_PASSWORD`: the matching Aiven password.
4. Keep the database credentials in Render's environment settings only.

## Create and deploy the Render Blueprint

1. Sign in to Render and choose **New → Blueprint**.
2. Select `freak-dev/Build-vendor-purchase-order-portal` and branch `develop` (or `main` after the changes are merged).
3. Review the two free service plans. Enter the database variables above when prompted, then create the resources.
4. Wait for both deploys to finish. Open the `vendor-portal-api` health URL at `/actuator/health`; it should return `{"status":"UP"}`. Open the `vendor-portal-web` URL and sign in as `admin` using the generated `ADMIN_PASSWORD` from the API service's environment page.
5. If Render assigns URLs other than `https://vendor-portal-api.onrender.com` and `https://vendor-portal-web.onrender.com`, update `VITE_API_BASE_URL` on the web service and `APP_CORS_ORIGINS` on the API service to match, then redeploy.

## Free-plan limits and rollback

Render free web services spin down after 15 minutes idle, use ephemeral service filesystems, and have no persistent disk. Render's free plan supports rollback to the two most recent previous deploys. Aiven free MySQL provides 1 CPU, 1 GB RAM, and 1 GB disk, has no SLA, and Aiven may power it off after inactivity. Confirm actual limits in both account dashboards before deployment; provider offerings can change.

Use Render's service **Events** page to select a previous deploy and roll back. Database schema migrations are forward-only in this project, so application rollback does not reverse Flyway migrations. Take an Aiven backup/export before any release that changes the database schema.

## Local checks before hosting

From the repository root, run `scripts/run-local-ci.ps1` to verify the Jenkins/Maven/Selenium/Docker path, or run `scripts/run-integration.ps1` to exercise the local Compose stack. Render Blueprint deployment itself requires authorization in a Render account and an Aiven database account; those accounts are not connected to this workspace.
