# Administrative API

- [x] Add shared Bearer authentication and JSON errors
- [x] Add institution search
- [x] Add network search: `ip`, `prefix`, `cidr`, and `rangeStart`/`rangeEnd`
- [x] Add institution networks and grants
- [x] Add protected-object searches
- [x] Add collection inspection and grants
- [x] Add collection identifier search
- [x] Add user inspection
- [x] Add authorization diagnostic
- [x] Document administrative API endpoint contracts
- [ ] Update the CLI to consume the administrative API

## Next Handoff

- Reconcile the terminology mismatch where the `/api/v1/objects` endpoint
  returns location records. Decide whether to rename the endpoint/response
  terminology or preserve it for compatibility, then update code, docs, and
  tests consistently.
- Propagate the finalized API v1 shapes to the CLI. Use `docs/ADMIN_API.md` as
  the contract, including Bearer authentication, `id` for collection search,
  explicit response projections, and the resolved location/object naming.
- Keep CLI integration separate until the API terminology and response shapes
  are finalized.
