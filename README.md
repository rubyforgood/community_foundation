# Community Foundations

Community Foundations is a legacy planner for clients of Community Foundations.
Each foundation is an **organization** whose members build
their own **giving scenarios** — annual plans that divide a total giving budget between
**ongoing** percentage-based recurring grants and **one-time** fixed-dollar
gifts.
The app is multi-tenant: every organization is served from its own
subdomain (for example `arlington.community-foundations.rowhomelabs.com`).

## Tech stack

- **Ruby 4.0.2** / **Rails 8.1** (tracks the `8-1-stable` branch)
- **SQLite** via Active Record
- **Propshaft** asset pipeline, **Tailwind CSS**
- **Hotwire** — Turbo + Stimulus, with import maps (no Node build step)
- **ReactionView** — HTML-aware ERB rendering via the Herb engine
- **Solid Queue / Solid Cache / Solid Cable** — database-backed jobs, cache, and Action Cable
- **Active Storage** for organization logo uploads
- **Postmark** for transactional email in production
- **Kamal** for Docker-based deployment

## Domain concepts

- **User** — authenticates via password or magic link; can belong to multiple organizations.
- **Organization** — a community foundation; has a name, website, subdomain, and logo.
- **OrganizationMembership** — joins a user to an organization with a role (`owner`, `admin`, or `member`). Users may also carry a `super_admin` flag for system-wide access.
- **Scenario** — a giving plan owned by a user within an organization; has a name and a total giving amount.
- **Allocation** — a line item within a scenario (single-table inheritance):
  - **Allocation::Ongoing** — a percentage-based recurring grant.
  - **Allocation::OneTime** — a fixed-dollar one-time gift.

## Getting started

Prerequisites: Ruby 4.0.2 (see [`.ruby-version`](.ruby-version)) and `libvips`
for Active Storage image processing.

```bash
bin/setup        # install gems, prepare and seed the database, then start the dev server
```

`bin/setup` ends by launching `bin/dev`. To run the server on its own
afterwards:

```bash
bin/dev          # runs Procfile.dev: Rails server + Tailwind CSS watcher
```

Useful flags and tasks:

```bash
bin/setup --skip-server   # set up without starting the server
bin/setup --reset         # reset the database during setup
bin/rails db:seed         # (re)seed sample data
```

### Seed data

`bin/rails db:seed` is idempotent and creates the **Arlington Community
Foundation** organization plus one user per role — `owner@example.com`,
`admin@example.com`, and `member@example.com`, all with the password
`password` — and two sample scenarios ("Balanced giving" and "Education
focus").

## Testing

```bash
bin/rails test           # unit, model, and controller tests (Minitest)
bin/rails test:system    # browser-based system tests (Capybara)
```

CI prepares the test database first with `bin/rails db:test:prepare`.

## Code quality & security

These run in CI and can be run locally:

```bash
bin/rubocop              # Ruby style linting (rails-omakase)
bin/brakeman             # static analysis for Rails security issues
bin/bundler-audit        # scan gems for known vulnerabilities
bin/importmap audit      # scan JavaScript dependencies for vulnerabilities
```
