# Administrative API

- [x] Add shared Bearer authentication and JSON errors
- [x] Add institution search
- [x] Add network search: `ip`, `prefix`, `cidr`, and `rangeStart`/`rangeEnd`
- [x] Add institution networks and grants
- [x] Add protected-object searches
- [x] Add collection inspection and grants
- [x] Add collection identifier search
- [x] Add user inspection
- [x] Add access check by collection ID
- [x] Document administrative API endpoint contracts
- [x] Update the CLI to consume the administrative API

## Next Handoff

- The administrative API contract is finalized around `/api/v1`, Bearer
  authentication, explicit projections, and location terminology.
- The Go CLI under `cli/` is the replacement
  CLI. The Ruby CLI is out of scope.
- The `access check` CLI command and `/api/v1/access` endpoint reuse the
  collection-based authorization behavior from `/authorized`.
