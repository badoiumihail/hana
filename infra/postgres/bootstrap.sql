-- ═══════════════════════════════════════════════════════════════════════════
-- Database bootstrap: roles and permissions for Hana.
--
-- Run by the `db-bootstrap` service as the `postgres` superuser on EVERY
-- `docker compose up`, so every statement must be idempotent: safe to run
-- any number of times, always ending in the same state.
--
-- Executed by psql (not sent raw to the server), which is what allows the
-- psql-only features used below: `\gexec` and `:'variable'` substitution.
-- The variables come from `-v name=value` in compose.yml.
--
-- The model (see docs/adr/0004-separate-migrator-and-app-db-roles.md):
--   hana_migrator  owns the schema; used only by migrations; can run DDL.
--   hana_app       what the API connects as; can only read and write rows.
--
-- Postgres checks privileges in layers. To read a table a role needs:
--   CONNECT on the database  →  USAGE on the schema  →  SELECT on the table.
-- Missing any one layer = "permission denied". The sections below set up
-- each layer in that order.
--
-- Inspect the result in psql with:
--   \du   roles            \l hana   database privileges
--   \dn+  schemas          \ddp      default privileges
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Roles ───────────────────────────────────────────────────────────────
-- A role is Postgres's single concept for "user" and "group"; LOGIN lets it
-- connect. Roles belong to the whole server (cluster), not to one database.
--
-- CREATE ROLE has no IF NOT EXISTS, so we generate the statement as text and
-- only when the role is missing:
--   - pg_roles is a system view listing every role.
--   - format() is printf for SQL; %I quotes an identifier (a name) safely.
--   - If the role exists, the WHERE filters out the only row, the query
--     returns nothing, and \gexec has nothing to run.
--   - Otherwise it returns the text `CREATE ROLE hana_migrator LOGIN`, and
--     \gexec executes each value of the result as a SQL statement.
--   - \gexec replaces the terminating semicolon.
--
-- No other attributes are given, so both roles get the safe defaults:
-- NOSUPERUSER, NOCREATEDB, NOCREATEROLE, NOBYPASSRLS.

SELECT format('CREATE ROLE %I LOGIN', 'hana_migrator')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hana_migrator')
\gexec

SELECT format('CREATE ROLE %I LOGIN', 'hana_app')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'hana_app')
\gexec


-- ─── 2. Passwords ───────────────────────────────────────────────────────────
-- Set on every run (not only at creation), so changing a password in .env
-- takes effect on the next `docker compose up`.
--
-- :'name' inserts the psql variable as a correctly quoted string literal
-- (:name, without quotes, would paste it raw: a quoting bug waiting to
-- happen). This only works in plain statements; psql does not substitute
-- variables inside $$-quoted DO blocks, which is why section 1 uses \gexec.
--
-- Postgres stores only a SCRAM-SHA-256 hash of the password, never the
-- password itself.

ALTER ROLE hana_migrator PASSWORD :'migrator_password';
ALTER ROLE hana_app PASSWORD :'app_password';


-- ─── 3. Database: who may connect ───────────────────────────────────────────
-- PUBLIC is a pseudo-role every role (current and future) is automatically a
-- member of. By default PUBLIC has CONNECT and TEMPORARY on every new
-- database, so any role on the server could connect to `hana`.
-- Start from nothing, then allow exactly our two roles.

REVOKE ALL ON DATABASE hana FROM PUBLIC;
GRANT CONNECT ON DATABASE hana TO hana_app, hana_migrator;

-- CREATE on a *database* means "may create schemas in it" (different from
-- CREATE on a schema, which means "may create tables in it").
-- The migrator needs it because Drizzle's migrator keeps its history table
-- in a schema of its own, `drizzle`, which it creates on first run. Keeping
-- it out of `public` matters: the default privileges in section 5 apply to
-- `public` only, so hana_app gets no access to the migration history.

GRANT CREATE ON DATABASE hana TO hana_migrator;

-- ─── 4. Schema `public`: who owns it, who may look inside ──────────────────
-- A schema is a namespace inside a database: a folder for tables, sequences,
-- views and so on. Every database starts with `public`, owned by
-- pg_database_owner, with USAGE granted to PUBLIC.
--
-- Ownership is the strongest privilege: the owner can create, alter and drop
-- anything in the schema, and privileges never restrict an owner. The
-- migrator owns it; the app never owns anything, so it can never DROP or
-- ALTER a table even if the API is compromised.

ALTER SCHEMA public OWNER TO hana_migrator;

-- Remove everything PUBLIC has on the schema (USAGE, by default since
-- Postgres 15; CREATE too on older versions), so access exists only where
-- granted explicitly below.

REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- USAGE = "may look up objects in this schema". Without it, hana_app couldn't
-- even see tables it has SELECT on. It does NOT include CREATE, so the app
-- cannot create tables here.

GRANT USAGE ON SCHEMA public TO hana_app;


-- ─── 5. Default privileges: grants for tables that don't exist yet ─────────
-- An ordinary GRANT only affects objects that already exist. Our tables will
-- be created later, by migrations running as hana_migrator. Default
-- privileges are rules applied automatically to objects created in the
-- future.
--
-- `FOR ROLE hana_migrator` is the crucial part: the rule applies only to
-- objects that role creates. Without it, the rule would apply to objects
-- created by whoever runs this script (the superuser), and tables created by
-- migrations would get no grants: the app would fail with
-- "permission denied for table bookings" on its first query.
--
-- Deliberately not granted: TRUNCATE (wipes a table, bypasses row-level
-- triggers), REFERENCES, TRIGGER. The app only needs to work with rows.

ALTER DEFAULT PRIVILEGES FOR ROLE hana_migrator IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO hana_app;

-- Identity columns (`id ... GENERATED ALWAYS AS IDENTITY`) are backed by a
-- sequence; every INSERT calls nextval() on it, which requires USAGE.
-- SELECT allows reading the sequence's current value (e.g. currval()).
-- Without this, every INSERT into a table with an identity column fails.

ALTER DEFAULT PRIVILEGES FOR ROLE hana_migrator IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO hana_app;

-- Functions are EXECUTE-able by PUBLIC by default. Revoke that for functions
-- the migrator creates, and grant it to the app explicitly, so the rule
-- stays "nothing unless granted". Relevant once migrations add functions
-- (e.g. for triggers or availability calculations).

ALTER DEFAULT PRIVILEGES FOR ROLE hana_migrator IN SCHEMA public
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE hana_migrator IN SCHEMA public
  GRANT EXECUTE ON FUNCTIONS TO hana_app;
