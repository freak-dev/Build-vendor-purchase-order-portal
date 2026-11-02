# Render free-tier demo deployment

`render.yaml` defines a free Render Postgres database, the Spring Boot API container, and the static React/Vite frontend. This is suitable for a student/demo deployment with no monthly hosting cost under Render's current free limits. Free web services may sleep after inactivity. Render's free Postgres expires after 30 days, with a limited grace period before deletion; export any data you need before it expires. It is not durable production hosting.

## Blueprint resources

- `vendor-portal-db`: free Render Postgres in Singapore.
- `vendor-portal-api-shreyansh-23102b0017`: Dockerized Spring Boot backend with `/actuator/health` check and PostgreSQL Flyway migrations.
- `vendor-portal-web-shreyansh-23102b0017`: static frontend; its build embeds the API URL and the backend allows requests from the frontend origin.

The API bootstrap creates an `admin` user with a generated password. Retrieve that password from the API service's environment settings in the Render Dashboard after the first deployment. Never put it in Git.

## Deploy

1. Open the Render Dashboard and create a new Blueprint from `https://github.com/freak-dev/Build-vendor-purchase-order-portal`, branch `develop`.
2. Review the resources and keep all three on the free plan, then apply the Blueprint.
3. Wait for the database to become available and the API health check to pass, then verify the static site.
4. If the generated `onrender.com` names differ because a name is already taken, update `VITE_API_BASE_URL` on the static site and `APP_CORS_ORIGINS` on the API to the actual URLs, then redeploy both.
5. Open the frontend URL, sign in as `admin` using the generated API environment variable, and change the password before using the demo with other people.

## Local PostgreSQL mode

Set `DB_URL`, `DB_USER`, `DB_PASSWORD`, and `FLYWAY_LOCATIONS=classpath:db/migration-postgresql`. The default local setup continues to use the MySQL migrations. Both migration sets represent the same schema.

## Limitations

The Render free database is temporary and can be removed after its expiration window. Export data before expiration. Free web services can cold-start after idle periods. Use a paid durable database and service plan before relying on this portal for business records.
