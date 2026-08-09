# Administrative CLI Progress

This file tracks implementation progress against [`ADMIN_CLI_PLAN.md`](ADMIN_CLI_PLAN.md).

## Clarify Before Next Pass

Before beginning any modification work on the next pass, clarify:

- [x] Real REST endpoint paths, HTTP methods, Bearer header, and error response shape.
- [x] API JSON responses retain the documented top-level envelopes.
- [x] Configuration uses required `AUTHZ_API_BASE_URL` and `AUTHZ_API_TOKEN` plus optional timeout.
- [x] Exact table columns and ordering are based on former CLI conventions.
- [x] Decide the remaining local/API command scope: retain `cidr`; retire `export` and `replication status`.

## Completed

- [x] Create the local Go module under `cli/` using Cobra and Viper.
- [x] Establish Ginkgo/Gomega behavior-driven command tests.
- [x] Add `lauth institution search`.
- [x] Render institution search results as a table by default, with JSON output available.
- [x] Use `aa_inst` schema attribute names: `uniqueIdentifier` and `organizationName`.
- [x] Add fixture-backed responses for the implemented query commands.
- [x] Add `network search`.
- [x] Add `institution networks`.
- [x] Add `institution grants`.
- [x] Add `user show`.
- [x] Add `locations search` with path and/or server filters.
- [x] Add `collection show` and `collection grants`.
- [x] Add `collection search`.
- [ ] Revisit deferred `authzd_to_coll` diagnostic support.
- [ ] Add `institution add` backed by the administrative API.
- [ ] Add `network add` with required institution association and CIDR/range validation.
- [ ] Add `lauth` command-group aliases and option shorthands; keep `user` unabridged.
- [x] Define the initial REST contract for authenticated institution search.
- [x] Back all query commands with the shared authenticated HTTP API client.
- [x] Implement `cidr from-range`, `cidr to-range`, and `cidr to-ints`.

## Next

- [x] Document the real REST endpoint contracts and response schemas.
- [x] Replace fixture-only query services with the shared authenticated HTTP API client.
- [x] Add centralized Bearer-token, base URL, timeout, and error handling.
- [x] Implement the CIDR validation and conversion test matrix.
- [x] Retire `export` and `replication status`; see `RETIRED_FEATURES.md`.
- [x] Retire dump scripts and `auth_to_acls`; see `RETIRED_FEATURES.md`.
- [ ] Complete empty-result, invalid-input, API-error, and output-format coverage for every active command.
- [ ] Verify representative results against the legacy utilities.
