# Administrative API

This document describes the read-only administrative API exposed by Lauth.
The API is versioned under `/api/v1`. CLI integration is intentionally
documented and implemented separately.

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

- All endpoints are read-only and use `GET`.
- Deleted rows are excluded by default (`dlpsDeleted = "f"`).
- List endpoints return `200` with an empty array when there are no matches.
- Results use database field names and explicit projections.
- Results have stable ordering documented with each endpoint.
- Pagination is not currently supported.

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

## Protected Objects

```http
GET /api/v1/objects?path=/books
GET /api/v1/objects?server=server.example
```

Exactly one of `path` or `server` is required. Values use case-insensitive
fragment matching. SQL wildcard characters are escaped. Results exclude
deleted objects and are ordered by `dlpsPath`, `dlpsServer`, and
`uniqueIdentifier`.

```json
{
  "objects": [
    {
      "uniqueIdentifier": 3,
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

### Show Collection

```http
GET /api/v1/collections/{id}
```

`id` is an exact collection identifier. The response includes collection
metadata and active grants:

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

## Authorization Diagnostic

```http
GET /api/v1/authorization/diagnostic?ip=192.0.2.1&userid=alice&collection=example
```

The operation evaluates the requested collection using direct, institution,
group, and network-aware grant policy. Delegated collections evaluate grants
for the collection class. Deleted collections and grants are excluded.

```json
{
  "authorized": true,
  "authorizedCollection": "example",
  "publicCollection": null
}
```

`ip` must be a complete IPv4 address. `userid` and `collection` are required
exact identifiers. A missing collection returns `404`; malformed input
returns `400`.

## Out Of Scope

This API does not provide:

- Database mutations.
- Export or replication endpoints.
- Raw dump compatibility endpoints.
- CIDR conversion commands.
- Pagination.
