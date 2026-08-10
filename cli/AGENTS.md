# Agent Guidance

## Project Context

- `ADMIN_CLI_PLAN.md` is the source of truth for CLI scope and command names.
- `TODO.md` records current progress and remaining work; update it when completing a meaningful plan item.
- The new CLI lives under `cli/` and uses Go, Cobra, Viper, and Ginkgo/Gomega.
- Legacy Perl utilities under `bin/` are reference behavior only. Do not add database access or migrate their embedded credentials.

## Development Approach

- Use a behavior-driven TDD loop for CLI work:
  1. Identify one user-visible behavior.
  2. Add a failing Ginkgo/Gomega spec.
  3. Confirm the request and response contract, especially JSON field names.
  4. Implement the smallest production slice that makes the spec pass.
  5. Run the focused spec and then `go test ./...`.
- Keep work incremental. Do not implement unrelated commands in the same loop.
- Preserve passing behavior and tests from earlier slices.
- For API-backed commands, use a fake or fixture-backed service in command tests; do not make tests depend on a live API.

## Schema And API Contracts

- Use attribute names from `sql/primary/create_tables.sql` in response models and JSON tags, including their database spelling and casing. Examples: `uniqueIdentifier`, `organizationName`, `dlpsCIDRAddress`, `dlpsPath`, and `dlpsServer`.
- Do not infer renamed fields such as `id` or `organization_name` when the database schema provides the canonical name.
- Keep command handlers independent of SQL-equivalent logic.
- Centralize real HTTP behavior in a shared API client: base URL, Bearer token, timeout, request construction, decoding, and error normalization.
- Fixture responses should be deterministic JSON files under `cli/testdata/` and should model the eventual API response shape.

## CLI Conventions

- Preserve the active plan's command names; access checks use `access check`.
- The executable is `lauth`; command-group aliases are `inst`, `net`, `coll`,
  and `loc`. Keep `user` unabridged.
- Human-readable table output is the default; structured JSON is available through `--output=json`.
- Use `lauth` as the binary name. Support `inst`, `net`, `coll`, and `loc`
  aliases, standard option shorthands, and never abbreviate `user`.
- Keep table headers stable and based on schema field names.
- Validate required arguments with Cobra and return errors rather than silently accepting malformed input.
- For `network add`, send one batch of CIDRs to the API. Decompose range input
  into minimal CIDRs, show the full set, and require confirmation before
  posting; do not reject historical network overlaps.
- Keep command wiring thin. Resource services return typed data; output functions render it.
- Do not expose API keys, database credentials, Oracle environment variables, or local database details.

## Verification

- Run Ruby unit and request specs from the repository root with
  `docker compose run --rm app-dev`; this service uses RSpec as its default
  command.
- Run Ruby integration tests with `docker compose run --rm test`.
- Do not assume the host Ruby environment or local database is configured for
  Ruby tests.
- Run `gofmt` on changed Go files.
- Run `go test ./...` from `cli/` after each completed TDD loop.
- Exercise representative commands with `go run ./cmd/lauth ...` when fixture-backed behavior changes.
- Check `git diff --check` before committing.
- Review `git status`, recent log, and staged diff before committing.
- Stage only intended files. Do not revert or include unrelated user changes without explicit instruction.

## Scope Boundaries

- Active query work includes institution, network, user, location, collection, and access checks.
- `cidr` is a local command. `export` and `replication status` are retired; do not reintroduce them without an explicit scope change.
- Institution and network creation are in scope. Dump scripts, `auth_to_acls`,
  and the irrelevant legacy utility groups are retired rather than deferred.
