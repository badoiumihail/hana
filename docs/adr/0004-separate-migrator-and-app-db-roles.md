# Separate Postgres roles for migrations and for the running app

The schema is owned by `hana_migrator`, used only by the one-shot migrate container. NestJS connects as `hana_app`, which has only SELECT/INSERT/UPDATE/DELETE on application tables and cannot run DDL. This limits the damage of a SQL injection or app bug (no `DROP TABLE`), at the cost of every new table needing grants for `hana_app` (set via default privileges). Neither role is the Postgres superuser.
