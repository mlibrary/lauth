# Administrative CLI Progress

This file tracks implementation progress against [`ADMIN_CLI_PLAN.md`](ADMIN_CLI_PLAN.md).

## Clarify Before Next Pass

Before beginning any modification work on the next pass, clarify:

- [ ] Real REST endpoint paths, HTTP methods, API-key header, and error response shape.
- [ ] Whether API JSON responses retain the top-level envelopes used by the fixtures.
- [ ] Configuration file format and environment variable names.
- [ ] Exact table columns and ordering expected for each command.
- [x] Decide the remaining local/API command scope: retain `cidr`; retire `export` and `replication status`.

## Completed

- [x] Create the local Go module under `client/` using Cobra and Viper.
- [x] Establish Ginkgo/Gomega behavior-driven command tests.
- [x] Add `authz institution search`.
- [x] Render institution search results as a table by default, with JSON output available.
- [x] Use `aa_inst` schema attribute names: `uniqueIdentifier` and `organizationName`.
- [x] Add fixture-backed responses for the implemented query commands.
- [x] Add `network search`.
- [x] Add `institution networks`.
- [x] Add `institution grants`.
- [x] Add `user show`.
- [x] Add `objects by-path` and `objects by-server`.
- [x] Add `collection show` and `collection grants`.
- [x] Add `authzd_to_coll`.
- [x] Define the initial REST contract for authenticated institution search.
- [x] Back all query commands with the shared authenticated HTTP API client.
- [x] Implement `cidr from-range`, `cidr to-range`, and `cidr to-ints`.

## Next

- [ ] Document the real REST endpoint contracts and response schemas.
- [x] Replace fixture-only query services with the shared authenticated HTTP API client.
- [x] Add centralized API-key, base URL, timeout, and error handling.
- [x] Implement the CIDR validation and conversion test matrix.
- [x] Retire `export` and `replication status`; see `RETIRED_FEATURES.md`.
- [ ] Add empty-result, invalid-input, API-error, and output-format coverage for every command.
- [ ] Verify representative results against the legacy utilities.

## Deferred

- [ ] Leave Phase Two mutation, raw dump, MySQL, and nested operational utilities untouched until Phase Two.
