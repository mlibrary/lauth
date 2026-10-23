# Administrative CLI Contract

The Go `lauth` command suite replaces the selected legacy Perl utilities and
uses the versioned administrative REST API. This document describes active
user-visible behavior; implementation progress and completed work do not
belong here.

## Active Commands

```text
lauth institution search PATTERN
lauth institution add ORGANIZATION_NAME
lauth institution networks INSTITUTION_ID
lauth institution grants INSTITUTION_ID

lauth network search --ip IP
lauth network search --prefix PREFIX
lauth network search --cidr CIDR
lauth network search --range-start START --range-end END
lauth network add --institution ID --cidr CIDR
lauth network add --institution ID --range-start START --range-end END

lauth user show USERID
lauth location search [--path PATH] [--server SERVER]
lauth collection search PATTERN
lauth collection show COLLECTION
lauth collection grants COLLECTION
lauth access check USERID COLLECTION [IP]

lauth cidr from-range START END
lauth cidr to-range CIDR
lauth cidr to-ints CIDR
```

Command-group aliases are `inst`, `net`, `coll`, and `loc`. The `user` command
is not abbreviated. Frequently used option shorthands are `-i` for
`--institution`, `-c` for `--cidr`, `-s` for `--range-start`, `-e` for
`--range-end`, and `-a` for `--access-switch`.

## Output And API

- Human-readable table output is the default.
- Structured API-shaped output is available with `--output=json`.
- Table headers and JSON field names use the database schema's spelling and
  casing, such as `uniqueIdentifier`, `organizationName`, `dlpsCIDRAddress`,
  `dlpsPath`, and `dlpsServer`.
- HTTP behavior is centralized in the shared API client, including the base
  URL, Bearer token, timeout, request construction, decoding, and API errors.
- The CLI does not connect directly to Oracle or MariaDB and must not expose
  database credentials, API tokens, or local database details.

The API contract is documented in [`docs/ADMIN_API.md`](../docs/ADMIN_API.md).
CLI API fixtures live under `testdata/` and must model the actual response
envelopes.

## Network Creation

`network add` accepts exactly one complete creation mode:

- `--cidr CIDR`
- `--range-start START --range-end END`

Range mode decomposes the inclusive IPv4 range into minimal CIDRs, displays the
complete set, and requires confirmation before posting. A non-canonical CIDR
also requires confirmation; an already canonical CIDR can be posted directly.
The complete CIDR set is sent as one API batch. `--access-switch` accepts
`allow` or `deny` and defaults to `allow`.

The CLI must not reject historical network overlaps. The API rejects exact
active address-range duplicates globally, regardless of institution or access
switch, while allowing different-size and other non-identical overlaps.
Soft-deleted networks are excluded from API results and may be recreated under
the current database uniqueness constraint.

## Local CIDR Commands

The `cidr` commands are local-only and do not call the API. They accept dotted
IPv4 addresses and slash-notation IPv4 CIDRs, reject malformed or reversed
ranges, and produce minimal inclusive range conversions.

## Scope Boundaries

- `export` and `replication status` are retired.
- Raw dump scripts, `auth_to_acls`, direct database access, and unrelated
  legacy utility groups are retired or out of scope.
- Management collections (`dlpsAuthzType = "m"`) are legacy data. The
  administrative API and CLI do not create new management collections.
- Pagination is not currently supported.

See [`RETIRED_FEATURES.md`](RETIRED_FEATURES.md) for retired command details.
