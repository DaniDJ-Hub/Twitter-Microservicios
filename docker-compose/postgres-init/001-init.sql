-- elastic-query-service uses schema "public" (default, no action needed).
-- analytics-service uses its own schema.
CREATE SCHEMA IF NOT EXISTS analytics;

-- keycloak-authorization-server (services.yml) expects its own database AND
-- role - DB_USER/DB_PASSWORD there is keycloak/keycloak, but only the
-- "postgres" superuser (POSTGRES_USER/PASSWORD above) actually exists by
-- default, so a database with no matching role always failed
-- authentication ("password authentication failed for user keycloak").
-- Owning the database directly (not just GRANT ALL PRIVILEGES) also avoids
-- Postgres 15+'s public-schema privilege restriction, which would
-- otherwise block Keycloak's own Hibernate schema migration from creating
-- its tables even after authentication succeeded.
CREATE ROLE keycloak WITH LOGIN PASSWORD 'keycloak';
CREATE DATABASE keycloak OWNER keycloak;

-- services.yml also sets DB_SCHEMA=keycloak (a dedicated schema, not the
-- database's default "public") - this whole script runs in the context of
-- POSTGRES_DB (postgres, per postgres.yml) via docker-entrypoint-initdb.d,
-- so CREATE SCHEMA here would land in the wrong database entirely; \connect
-- switches into the keycloak database first. Without this, Keycloak's own
-- Liquibase migration failed immediately with 'schema "keycloak" does not
-- exist' even after the role/database auth issue above was fixed.
\connect keycloak
CREATE SCHEMA IF NOT EXISTS keycloak AUTHORIZATION keycloak;
