# Hana

A booking platform for service businesses (salons, barbers, nail studios): Customers book a Service with a Staff Member, Businesses manage their schedules and confirm Bookings, and Customers review the Businesses they've visited.

Built as a deliberate learning project: one long-lived, deployed app grown milestone by milestone.

## Stack

- **API:** NestJS 12 (ESM), Drizzle, PostgreSQL
- **Web:** SvelteKit in SPA mode (`ssr = false`, adapter-static)
- **Tooling:** pnpm workspaces, oxlint, Prettier, Vitest, GitHub Actions

## Repository layout

```
apps/api/       NestJS API
apps/web/       SvelteKit SPA
packages/       shared packages (generated API client, coming in M0a)
docs/           roadmap, milestones, ADRs
CONTEXT.md      domain glossary: read this first
```

## Getting started

Requires Node 24+ and pnpm 11 (`corepack enable` picks up the pinned version).

```bash
pnpm install
pnpm --filter web exec playwright install chromium   # browser for component tests

pnpm dev:api        # API on http://localhost:3000
pnpm dev:web        # web app on http://localhost:5173
```

## Scripts (run from the repo root)

| Command                             | What it does                                                  |
| ----------------------------------- | ------------------------------------------------------------- |
| `pnpm lint`                         | oxlint across both apps (type-aware)                          |
| `pnpm check`                        | svelte-check: types and accessibility warnings in the web app |
| `pnpm test`                         | all test suites                                               |
| `pnpm build`                        | builds both apps                                              |
| `pnpm format` / `pnpm format:check` | Prettier, one config for the whole repo                       |

## Docs

- [Domain glossary](CONTEXT.md)
- [Roadmap](docs/roadmap.md)
- [Architecture decisions](docs/adr/)
