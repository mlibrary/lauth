# Administrative API Handoff Plan

This document defines the work required for the Ruby/Hanami application in
`the lauth project` to support the active `lauth` CLI commands.
The `lauth` project is reference material for this plan; this document does
not authorize changes to that directory unless the work is explicitly handed
off there.

## Scope

Implement a versioned administrative API backed by Hanami actions,
operations, and ROM repositories.

The API must support:

- Institution search, networks, and grants
- Institution creation
- Network search
- Institution-associated network creation
- User inspection
- Protected-location searches by path and server
- Collection inspection and grants
- Authorization diagnostics (deferred)

The following are intentionally out of scope:

- `lauth export`
- `lauth replication status`
- Raw dump compatibility endpoints
- The local `cidr` commands, which do not call the API

See [`RETIRED_FEATURES.md`](RETIRED_FEATURES.md) for retired commands.

## Current Lauth Baseline

The current Hanami application has:

- A single route, `GET /authorized`
- Bearer-token authentication using `settings.bearer_token`
- ROM SQL persistence using Trilogy and `database_url`
- Auto-registered ROM relations under `lib/lauth/persistence`
- `CollectionRepo` with URI matching and public-collection lookup
- `GrantRepo` with authorization evaluation for normal and delegated modes
- An `Authorize` operation used by `/authorized`

The existing `/authorized` endpoint accepts `user`, `uri`, and `ip`, and returns
an `Access::Result` containing `determination`, `authorized_collections`, and
`public_collections`. It is not a drop-in implementation of the CLI's
`authzd_to_coll` diagnostic, whose input includes a collection identifier.

Do not overload `/authorized` with administrative list operations.

## Authentication Decision

The active Go client sends a Bearer token, while Lauth validates:

```http
Authorization: Bearer <bearer-token>
```

The administrative API reuses the existing Bearer-token scheme and the CLI is
configured with `AUTHZ_API_TOKEN`.

Every administrative route must define its required scope or role. A shared
Bearer token is acceptable for the first local implementation, but the
authorization boundary must remain centralized and must not be implemented
independently in every action.

## Endpoint Contract

Use `/api/v1` as the public namespace. If the deployment intentionally omits
the version prefix, make that a single documented base-URL decision and update
the CLI client consistently.

| CLI command | Method and path | Query or path values | Response envelope |
|---|---|---|---|
| `institution search` | `GET /api/v1/institutions` | `organizationName=Michigan` | `{ "institutions": [...] }` |
| `institution add` | `POST /api/v1/institutions` | JSON body: `organizationName` | `{ "institution": {...} }` |
| `institution networks` | `GET /api/v1/institutions/{id}/networks` | `id=7` | `{ "networks": [...] }` |
| `institution grants` | `GET /api/v1/institutions/{id}/grants` | `id=7` | `{ "grants": [...] }` |
| `network search` | `GET /api/v1/networks` | `cidr=192.0.2` | `{ "networks": [...] }` |
| `network add` | `POST /api/v1/institutions/{id}/networks` | JSON body: canonical `cidrs` array, optional `accessSwitch` | `{ "networks": [...] }` |
| `collection search` | `GET /api/v1/collections` | `id=example*` | `{ "collections": [...] }` |
| `user show` | `GET /api/v1/users/{userid}` | `userid=alice` | `{ "userid": ..., "user": ..., "memberships": [...], "grants": [...] }` |
| `locations search` | `GET /api/v1/locations` | `path=/books`, `server=server.example`, or both | `{ "locations": [...] }` |
| `collection show` | `GET /api/v1/collections/{id}` | `id=example` | `{ "collection": ..., "grants": [...] }` |
| `collection grants` | `GET /api/v1/collections/{id}/grants` | `id=example` | `{ "grants": [...] }` |
| `authzd_to_coll` | Deferred | Existing legacy request and response contract | Unchanged until the feature decision |

The API uses `grants` consistently for relationship responses.

### Mutation Semantics

`institution add` requires a non-empty `organizationName` and creates an
active institution. The request body is `{ "organizationName": "..." }` and
the successful response is `{ "institution": {...} }` with status `201
Created`. Unknown request fields, including legacy fields, are ignored.
Duplicate active organization names are currently allowed. Malformed JSON,
non-object bodies, and invalid or missing `organizationName` currently return
`400` with the `invalid_parameter` error envelope.

`network add` requires an active institution identified by the path `id` and
accepts a non-empty `cidrs` array containing canonicalizable IPv4 CIDRs. The
CLI may accept an inclusive range, but it must decompose that range into
minimal CIDRs, display the complete set, obtain confirmation when required,
and post the complete array as one operation. The request body is
`{ "cidrs": [...], "accessSwitch": "allow|deny" }`; `accessSwitch` defaults
to `allow`. The API ignores unknown fields, including legacy `ip`, `prefix`,
`rangeStart`, and `rangeEnd` fields. It canonicalizes each CIDR, derives
`dlpsAddressStart` and `dlpsAddressEnd`, and rejects malformed CIDRs,
duplicate canonical CIDRs, invalid address bounds, invalid `accessSwitch`,
and missing, empty, or incorrectly typed `cidrs` with `400` and an
`invalid_parameter` error envelope.

Network creation is atomic: all CIDRs are validated before insertion and the
batch is committed in one database transaction; an invalid batch creates no
networks. A successful response is `{ "networks": [...] }` with status `201
Created`. A missing or inactive institution returns `404` with a `not_found`
error.

Overlapping networks within one institution and cross-institution containment
are valid historical configurations. Preserve them when creating networks;
authorization continues to use the most-specific matching network.

### Historical Overlap Follow-Up

Historical behavior did not enforce or otherwise manage cross-institution
overlap rules. Add focused coverage later for multiple institutions matching
the same client IP, especially equal-sized overlaps, so the authorization
behavior is documented without introducing new creation-time validation.

## Response Fields

Use the database schema's field spelling and casing in JSON responses. Do not
rename fields to generic alternatives such as `id` or `organization_name`.

Examples:

```json
{
  "uniqueIdentifier": 7,
  "organizationName": "Example University"
}
```

```json
{
  "uniqueIdentifier": 12,
  "userid": "alice",
  "user_grp": 0,
  "inst": 7,
  "coll": "example",
  "lastModifiedTime": "2026-08-04T12:00:00Z",
  "dlpsDeleted": "f"
}
```

Use explicit projections. Never return `SELECT *` from user-facing API
responses. In particular, do not expose `userPassword`, `dlpsKey`, database
credentials, or other authentication material.

## Search Semantics

Do not expose SQL wildcard construction as an accidental API contract.

Recommended semantics:

- `organizationName=Michigan` means a case-insensitive fragment search.
- `cidr=192.0.2` means a CIDR-prefix search.
- `path=/books` and `server=server.example` mean prefix or fragment searches
  as documented by the endpoint, not arbitrary SQL expressions.
- Collection and user identifiers are exact identifiers unless the endpoint
  explicitly documents a search operation.
- Escape URL path segments and query values using the framework/client
  facilities.

For every list endpoint, document:

- Whether deleted rows are excluded by default. Recommended: exclude rows
  where `dlpsDeleted` is not `f`.
- Whether an `includeDeleted` option exists.
- Stable ordering.
- Empty-result behavior. Recommended: `200` with an empty array.
- Maximum result size and whether pagination is intentionally absent.

## ROM Repository Work

Actions should validate input, invoke an operation, and serialize the result.
They should not contain Sequel joins or SQL-equivalent authorization logic.

Add or extend repositories with methods similar to these:

| Repository | Required methods |
|---|---|
| `InstitutionRepo` | `search_by_organization_name`, `find`, active-row filtering |
| `NetworkRepo` | `search_by_cidr`, `for_institution` |
| `GrantRepo` | `for_institution`, `for_collection`, `for_user`, explicit grant projection |
| `UserRepo` | `find_with_memberships_and_grants`, safe user projection |
| `InstitutionMembershipRepo` | `for_user`, `for_institution` |
| `LocationRepo` | `search_by_path`, `search_by_server`, active-row filtering |
| `CollectionRepo` | `find`, `find_with_grants`, active-row filtering |
| `GroupRepo` and membership repositories | Support user/group grant expansion where required |

The existing `GrantRepo#base_grants_for` contains authorization-specific joins
for direct users, institution membership, group membership, and network
allowance. Preserve that logic for authorization evaluation, but do not use it
as an opaque implementation for administrative grant listing. List operations
and authorization decisions need separate named methods and tests.

The existing `CollectionRepo#find_by_uri` has important behavior: it ignores
deleted collections and locations, matches `dlpsPath`, and selects the most
specific path by depth and length. Preserve and test that behavior for
authorization; do not replace it with a simple first-match query.

## Authorization Diagnostic

If authorization diagnostics are reinstated, implement a dedicated diagnostic operation for:

```text
ip=192.0.2.1
userid=alice
collection=example
```

The operation should define whether it:

- Checks a direct user grant
- Checks institution membership grants
- Checks group membership grants
- Applies the smallest matching network and `dlpsAccessSwitch`
- Excludes deleted collections and grants
- Reports public or delegated collections

The response must be stable and must not expose internal SQL or repository
details. If the existing `Authorize` operation can be safely extended, share
lower-level policy components rather than making the administrative action
call another HTTP route internally.

## Error Contract

Use one JSON error shape for all administrative endpoints:

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "organizationName is required"
  }
}
```

Recommended status mapping:

- `400` malformed query or path input
- `401` missing or invalid authentication
- `403` authenticated but not authorized for admin access
- `404` exact resource does not exist
- `422` valid syntax with invalid semantics
- `500` unexpected server error

Do not include API tokens, SQL, database URLs, stack traces, or credentials in
error responses.

## Hanami Structure

Use the existing application conventions:

```text
config/routes.rb
app/actions/admin/...
app/ops/admin/...
app/repositories/...
lib/lauth/persistence/relations/...
spec/requests/admin/...
spec/operations/admin/...
```

The exact directory names may follow the project's established Hanami
autoloading convention, but responsibilities should remain separated:

1. Routes define HTTP method and path.
2. Actions authenticate, validate, invoke an operation, and serialize.
3. Operations coordinate repositories and domain policy.
4. Repositories own ROM queries and projections.
5. Request specs verify the external contract.
6. Repository/operation specs verify filtering and authorization semantics.

## BDD Implementation Order

Implement one endpoint at a time:

1. Add a request spec with method, path, authentication, parameters, response
   envelope, and error behavior.
2. Add or extend the smallest repository spec needed by the endpoint.
3. Implement the repository method.
4. Implement the operation and Hanami action.
5. Run focused specs, then the full Lauth test suite.
6. Update the endpoint contract and CLI fixture when the response is stable.

Recommended order:

1. `institution search`
2. `institution add`
3. `network search`
4. `network add`
5. `institution networks`
6. `institution grants`
7. `locations search`
8. `collection search`, `collection show`, and `collection grants`
9. `user show`
10. `authzd_to_coll` (deferred)

Each endpoint should have tests for normal results, empty results, malformed
input, authentication failure, authorization failure, repository/API failure,
and JSON field names.

## Completion Criteria

The handoff is complete when:

- Every active CLI command has a documented endpoint.
- Every endpoint has a request and response spec.
- Bearer-token behavior is explicit and tested.
- Institution and network mutations validate input and association rules.
- Response envelopes use `grants` consistently.
- Deleted-row behavior and ordering are documented.
- User-sensitive fields are excluded from projections.
- Existing authorization semantics remain covered by operation specs.
- No export or replication endpoint is introduced.
- The local CIDR commands remain API-independent.
