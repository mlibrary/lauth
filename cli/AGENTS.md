# Agent Guidance

## Project Context

- `ADMIN_CLI_PLAN.md` is the source of truth for CLI scope and command names.
- `TODO.md` records current progress and remaining work; update it when completing a meaningful plan item.
- The new CLI lives under `client/` and uses Go, Cobra, Viper, and Ginkgo/Gomega.
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
- Fixture responses should be deterministic JSON files under `client/testdata/` and should model the eventual API response shape.

## CLI Conventions

- Preserve the active plan's command names; `authzd_to_coll` is deferred.
- Human-readable table output is the default; structured JSON is available through `--output=json`.
- Keep table headers stable and based on schema field names.
- Validate required arguments with Cobra and return errors rather than silently accepting malformed input.
- Keep command wiring thin. Resource services return typed data; output functions render it.
- Do not expose API keys, database credentials, Oracle environment variables, or local database details.

## Verification

- Run `gofmt` on changed Go files.
- Run `go test ./...` from `client/` after each completed TDD loop.
- Exercise representative commands with `go run ./cmd/authz ...` when fixture-backed behavior changes.
- Check `git diff --check` before committing.
- Review `git status`, recent log, and staged diff before committing.
- Stage only intended files. Do not revert or include unrelated user changes without explicit instruction.

## Scope Boundaries

- Phase One query work includes institution, network, user, location, and collection read operations. Authorization diagnostic work is deferred.
- `cidr` is a local Phase One command. `export` and `replication status` are retired; do not reintroduce them without an explicit scope change.
- Keep Phase Two mutations, raw dump compatibility, nested MySQL utilities, imports, synchronization, password rotation, email, and destructive loads untouched.
