# Administrative API

This document describes the administrative API exposed by Lauth. The API is
versioned under `/api/v1`. CLI integration is intentionally documented and
implemented separately.

## Authentication

Every administrative endpoint requires:

```http
Authorization: Bearer <BEARER_TOKEN>
Accept: application/json
```

Requests without a valid Bearer token receive `401`:

```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication is required"
  }
}
```

Tokens are never included in responses or API error messages.

## Common Behavior

- Read endpoints use `GET`; mutation endpoints use `POST` as documented below.
- Deleted rows are excluded by default (`dlpsDeleted = "f"`).
- List endpoints return `200` with an empty array when there are no matches.
- Results use database field names and explicit projections.
- Results have stable ordering documented with each endpoint.
- Pagination is not currently supported.
- JSON request bodies ignore unknown fields. Only fields documented for the
  endpoint are read.

Administrative errors use this shape:

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "..."
  }
}
```

The intended status mapping is:

| Status | Meaning |
| --- | --- |
| `400` | Malformed or incomplete request parameters |
| `401` | Missing or invalid authentication |
| `403` | Authenticated but not authorized |
| `404` | Requested exact resource does not exist or is deleted |
| `422` | Valid syntax with invalid semantics |
| `500` | Unexpected server error |

## Institutions

### Search Institutions

```http
GET /api/v1/institutions?organizationName=Michigan
```

`organizationName` is required. Matching is case-insensitive and searches
organization-name fragments. The application wildcard `*` may be used for
variable text. SQL wildcard characters supplied by callers are escaped and
are not interpreted as SQL pattern syntax.

Results are ordered by `uniqueIdentifier`.

For example, a wildcard search for institutions in the University of
Michigan system is:

```http
GET /api/v1/institutions?organizationName=University%20of%20Mich*
```

It can return all matching organization names:

```json
{
  "institutions": [
    {
      "uniqueIdentifier": 101,
      "organizationName": "University of Michigan - Ann Arbor"
    },
    {
      "uniqueIdentifier": 102,
      "organizationName": "University of Michigan - Dearborn"
    },
    {
      "uniqueIdentifier": 103,
      "organizationName": "University of Michigan - Flint"
    }
  ]
}
```

### Create Institution

```http
POST /api/v1/institutions
Content-Type: application/json

{"organizationName":"Example University"}
```

`organizationName` must be a non-empty string after trimming. The API creates
an active institution and returns `201 Created`:

```json
{
  "institution": {
    "uniqueIdentifier": 104,
    "organizationName": "Example University"
  }
}
```

Duplicate active organization names are currently allowed. Unknown request
fields, including legacy fields, are ignored.

Malformed JSON, a non-object JSON body, a missing or blank
`organizationName`, and a non-string `organizationName` return `400` with the
common `invalid_parameter` error envelope.

### Institution Networks

```http
GET /api/v1/institutions/{id}/networks
```

`id` is an exact institution identifier. Results are ordered by
`dlpsAddressStart`, `dlpsAccessSwitch`, and `uniqueIdentifier`.

```json
{
  "networks": [
    {
      "uniqueIdentifier": 12,
      "dlpsDNSName": "example.edu",
      "dlpsCIDRAddress": "192.0.2.0/24",
      "dlpsAddressStart": 3221225984,
      "dlpsAddressEnd": 3221226239,
      "dlpsAccessSwitch": "allow",
      "inst": 7,
      "lastModifiedTime": "2026-08-04T12:00:00Z",
      "dlpsDeleted": "f"
    }
  ]
}
```

### Create Institution Networks

```http
POST /api/v1/institutions/{id}/networks
Content-Type: application/json

{"cidrs":["192.0.2.17/24","198.51.100.0/25"],"accessSwitch":"deny"}
```

`id` must identify an active institution. The request requires a non-empty
`cidrs` array of IPv4 CIDR strings. Each CIDR is canonicalized before
insertion, so `192.0.2.17/24` is stored and returned as `192.0.2.0/24`.
`accessSwitch` defaults to `allow`; when supplied, it must be `allow` or
`deny`. Unknown request fields, including legacy search fields such as `ip`,
`prefix`, `rangeStart`, and `rangeEnd`, are ignored rather than rejected.

The complete batch is validated before any row is inserted and is committed as
one atomic operation. Each CIDR's canonical address bounds are the uniqueness
key for active networks globally: the check covers all institutions and both
`allow` and `deny` access switches. An exact duplicate canonical range returns
`400` with the common `invalid_parameter` error envelope. For an existing
active range, the message includes the canonical CIDR, owning institution ID,
and owning organization name:

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "cidr 192.0.2.0/24 already exists for institution 7 (Example University)"
  }
}
```

Two CIDRs in the same request that canonicalize to the same range are rejected
before insertion with a message containing the canonical CIDR, for example
`cidr 192.0.2.0/24 is duplicated in request`. The batch creates no networks
in either duplicate case. Different-size or otherwise non-identical
overlapping ranges remain allowed. Soft-deleted ranges are not considered
active owners and may be recreated while the historical row remains deleted.
Because the current schema uses `dlpsDeleted` in the unique key, only one
deleted historical row can exist for a range; repeated delete/recreate cycles
are a deferred limitation. A future history table can remove that limitation.

Malformed JSON, a non-object body, missing or invalid `cidrs`, invalid CIDRs or
address bounds, and an invalid `accessSwitch` also return `400` with the
common `invalid_parameter` error envelope.

A successful request returns `201 Created`:

```json
{
  "networks": [
    {
      "uniqueIdentifier": 13,
      "dlpsDNSName": null,
      "dlpsCIDRAddress": "192.0.2.0/24",
      "dlpsAddressStart": 3221225984,
      "dlpsAddressEnd": 3221226239,
      "dlpsAccessSwitch": "deny",
      "inst": 7,
      "lastModifiedTime": "2026-08-04T12:00:00Z",
      "dlpsDeleted": "f"
    }
  ]
}
```

If `{id}` does not identify an active institution, the API returns `404` with
`{"error":{"code":"not_found","message":"institution not found"}}`.

### Institution Grants

```http
GET /api/v1/institutions/{id}/grants
```

`id` is exact. Results are ordered by `coll` and `uniqueIdentifier`.

```json
{
  "grants": [
    {
      "uniqueIdentifier": 12,
      "userid": null,
      "user_grp": null,
      "inst": 7,
      "coll": "example",
      "lastModifiedTime": "2026-08-04T12:00:00Z",
      "dlpsDeleted": "f"
    }
  ]
}
```

## Networks

```http
GET /api/v1/networks
```

Exactly one search mode is required:

| Mode | Example | Meaning |
| --- | --- | --- |
| `ip` | `?ip=192.0.2.1` | Networks containing one complete IPv4 address |
| `prefix` | `?prefix=192.0.2` | Networks overlapping the implied `/24` range |
| `cidr` | `?cidr=192.0.2.0/24` | Networks overlapping the CIDR range |
| `rangeStart` and `rangeEnd` | `?rangeStart=192.0.2.1&rangeEnd=192.0.2.200` | Networks overlapping the inclusive range |

`prefix` accepts a string containing one through four dotted IPv4 segments:

```text
192       -> 192.0.0.0/8
192.0     -> 192.0.0.0/16
192.0.2   -> 192.0.2.0/24
192.0.2.1 -> 192.0.2.1/32
```

`prefix` does not accept integer input. The repository also accepts unsigned
integer address values for `ip`, `rangeStart`, and `rangeEnd`; the HTTP API
normally supplies dotted-decimal strings.

CIDR and explicit range searches use inclusive overlap:

```text
network.dlpsAddressStart <= search_end
AND network.dlpsAddressEnd >= search_start
```

Results are ordered by `dlpsAddressStart`, `dlpsAccessSwitch`, and
`uniqueIdentifier`. Invalid or combined modes return `400`.

## Protected Locations

```http
GET /api/v1/locations?path=/books
GET /api/v1/locations?server=server.example
GET /api/v1/locations?path=/books&server=server.example
```

At least one of `path` or `server` is required. Values use case-insensitive
fragment matching. Both values may be supplied and are combined with AND.
The application wildcard `*` is supported; SQL wildcard characters are
escaped. Results exclude deleted locations and are ordered by `dlpsPath`,
`dlpsServer`, and `coll`.

```json
{
  "locations": [
    {
      "coll": "example",
      "dlpsPath": "/books%",
      "dlpsServer": "server.example",
      "lastModifiedTime": "2026-08-04T12:00:00Z",
      "dlpsDeleted": "f"
    }
  ]
}
```

## Collections

### Search Collections

```http
GET /api/v1/collections?id=ampo20*
```

`id` is required. Matching is case-insensitive and operates only on
`uniqueIdentifier`. The application wildcard `*` may be used for variable
text; SQL wildcard characters supplied by callers are escaped. Results are
ordered by `uniqueIdentifier` and contain only the identifier:

```json
{
  "collections": [
    {"uniqueIdentifier": "ampo20"},
    {"uniqueIdentifier": "ampo20-dev"}
  ]
}
```

### Show Collection

```http
GET /api/v1/collections/{id}
```

`id` is an exact collection identifier. The response includes collection
metadata and active grants:

Management collections (`dlpsAuthzType = "m"`) are a legacy data type. The
administrative API does not create new management collections; new collections
must use a supported non-management authorization type.

```json
{
  "collection": {
    "uniqueIdentifier": "example",
    "commonName": "Example",
    "description": "Example collection",
    "dlpsClass": "example",
    "dlpsSource": "source",
    "dlpsAuthenMethod": "any",
    "dlpsAuthzType": "n",
    "dlpsPartlyPublic": "f",
    "manager": 1,
    "lastModifiedTime": "2026-08-04T12:00:00Z",
    "dlpsDeleted": "f"
  },
  "grants": []
}
```

### Collection Grants

```http
GET /api/v1/collections/{id}/grants
```

The response is `{ "grants": [...] }`, using the same grant projection and
ordering as institution grants.

## Users

```http
GET /api/v1/users/{userid}
```

`userid` is exact. The response includes the safe user projection, active
institution memberships, and active direct grants:

```json
{
  "userid": "alice",
  "user": {
    "userid": "alice",
    "givenName": "Alice",
    "surname": "Example",
    "dlpsDeleted": "f"
  },
  "memberships": [],
  "grants": []
}
```

`userPassword` and `dlpsKey` are never returned.

## Access Check

```http
GET /api/v1/access?userid=alice&collection=example&ip=192.0.2.1
```

The operation evaluates the requested collection using the same collection-based
access policy as `/authorized`. The collection is resolved directly by its
identifier rather than by URI. Delegated collections evaluate grants for the
collection class. Deleted collections and grants are excluded.

```json
{
  "determination": "allowed",
  "authorized_collections": [],
  "public_collections": []
}
```

`userid` and `collection` are required exact identifiers. `ip` is optional when
checking access without a client address, and must be a complete IPv4 address
when supplied. A missing collection returns `404`; malformed input returns
`400`.

### Overlapping Network Authorization

Active networks are selected globally by client IP, not independently per
institution. The authorization evaluator chooses the smallest matching active
network by address range. A more-specific network therefore takes precedence
over a containing network, even when the networks belong to different
institutions. Deleted networks are excluded from this selection.

For example, if institution 7 owns `192.0.2.0/24` with `allow` and institution
8 owns `192.0.2.0/25` with `deny`, a client at `192.0.2.10` matches the `/25`
and the network-based result is denied, while a client at `192.0.2.200` matches
only the `/24` and the network-based result is allowed. Reversing the switches
reverses those network-based results.

Network selection is only one authorization path. A direct user grant,
institution-membership grant, or group-membership grant can authorize a user
independently of the selected network's switch. A `deny` network does not
revoke those grants; it only prevents that network from contributing an
`allow` result.

Two active CIDRs with the same address bounds are exact duplicates and are
rejected globally, including when their access switches or institutions differ.
For IPv4 CIDRs, equal-sized overlapping ranges necessarily have the same
bounds, so there is no active equal-sized tie to resolve. Different-size and
other non-identical overlaps remain valid and use the most-specific-match rule
above. Network creation must not add broader overlap validation.

## Out Of Scope

This API does not provide:

- Export or replication endpoints.
- Raw dump compatibility endpoints.
- CIDR conversion commands.
- Pagination.
