# Roadmap

Each milestone is ~1–2 weeks at 1–2 h/day and ends with something deployed.
Loop per milestone: grill the design → implement → review → deploy → update CONTEXT.md / ADRs.

- **M0a Local skeleton**: monorepo, hello-world api + web, Postgres + Mailpit in Docker Compose, first migration, DB roles, CI on PRs. See [milestones/M0.md](milestones/M0.md).
- **M0b Deploy**: domain, VPS hardening, Caddy, CD on merge to `main`. Must be done before M1 counts as done (verification emails need a real domain for Resend).
- **M1 Accounts**: hand-rolled session auth ([ADR 0001](adr/0001-hand-rolled-session-auth.md)), email verification via Resend (Mailpit locally).
- **M2 Business setup**: Business, Owner, Staff Members, Categories, Services, Working Hours, Time Off.
- **M3 Search**: Businesses by name, Category and city; full-text search + trigram indexes on a large seeded dataset.
- **M4 Booking core**: computed Availability ([ADR 0003](adr/0003-availability-is-computed.md)); creating Bookings with no double-booking under concurrency ([ADR 0002](adr/0002-no-hold-bookings-block-time.md)).
- **M5 Booking lifecycle**: confirm / decline / cancel with reasons; auto-decline and auto-complete jobs; staff-vs-job races; Correction window.
- **M6 Email notifications**: transactional outbox.
- **M7 Reviews**: Reviews of completed Bookings; per-Staff-Member ratings via a materialized view.
- **M8 Reliability**: Customer reliability history visible to Businesses; later, automatic loss of Auto-confirm.

## Launch gate

No real Business is onboarded until all of these hold:

- Nightly `pg_dump` backups stored off the server (e.g. Hetzner Storage Box).
- At least one successful restore drill from such a backup.
- A staging environment exists.

## Later

SSR (flip SvelteKit `ssr` on), platform administrator approval of Businesses, Locations, "any available Staff Member", row-level security, infrastructure automation (cloud-init / Ansible), secrets tooling.
