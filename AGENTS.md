# Repository Guidance

These instructions apply to the whole repository. More specific guidance in a
subdirectory supplements this file.

## Project Context

- The Ruby application lives under `lauth/` and uses Hanami, ROM, and RSpec.
- The Go administrative CLI lives under `cli/`; CLI-specific guidance is in
  `cli/AGENTS.md`.
- The database setup files live under `db/` and are consumed by Docker Compose.

## Test Environment

- Run Ruby unit and request specs inside Docker Compose:
  `docker compose run --rm app-dev rspec <spec paths>`.
- Run Ruby integration tests with `docker compose run --rm test`.
- Do not treat host-side Ruby test failures as authoritative. The database
  hostname `db.lauth.local` is a Docker network alias and is normally not
  resolvable from the host.
- If a test cannot run because of environment setup, report it as an
  unverified test rather than as evidence of an application defect.
- Include the exact test command, execution environment, and result when
  reporting runtime findings.

## Review Validation

- Prefer public-boundary tests, such as request or command tests, when checking
  observable behavior.
- Treat static concerns about constructors, dependency wiring, or framework
  behavior as hypotheses until verified against the framework configuration or
  a public-boundary test.
- Hanami/Dry-System components using `include Deps[...]` may receive
  dependencies through framework-generated injection. Do not infer a runtime
  wiring failure from an explicit initializer signature alone.
- Before reporting a confirmed runtime bug, reproduce it or trace the relevant
  framework wiring. If reproduction is unavailable, label the finding and its
  confidence accordingly.

## General Verification

- Run `git diff --check` before committing.
- Review `git status`, the complete diff, and recent history before committing.
- Preserve unrelated user changes and stage only intended files.
