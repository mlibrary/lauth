# Administrative CLI Development Plan

Current implementation progress is tracked in [`TODO.md`](TODO.md).

## 1. Objective

Replace the selected top-level Perl utilities in `bin/` with a command-suite CLI backed by the existing authorization REST API.

The CLI will:

- Use a Bearer token for authenticated API requests.
- Preserve useful administrative and access-check behavior.
- Remove direct Oracle and MySQL dependencies.
- Keep local IP-range conversion independent of the API.
- Support institution and network creation through the administrative API.

## 2. Scope

Implement the selected administrative and access-check functionality from top-level `bin/`:

- Institution lookup: `qi`
- Institution network lookup: `qn`, `qin`
- Institution collection lookup: `qic`
- User inspection: `qu`
- Collection inspection: `qc`
- Protected-location lookup: `qp`, `qs`
- Access check: `authzd_to_coll` mapped to `access check`
- CIDR range conversion: local `cidr` behavior
- Institution creation: `add_inst`
- Institution network creation: `ain`

## 3. Target Command Structure

Use a single command-suite executable with subcommands.

```text
lauth institution search
lauth institution add
lauth institution networks
lauth institution grants

lauth user show

lauth location search --path PATH
lauth location search --server SERVER

lauth collection search PATTERN
lauth collection show
lauth collection grants

lauth network search
lauth network add --institution INSTITUTION_ID --cidr CIDR
lauth network add --institution INSTITUTION_ID --range-start START --range-end END

lauth access check USERID COLLECTION [IP]

lauth cidr from-range START END
lauth cidr to-range CIDR
lauth cidr to-ints CIDR
```

The legacy `authzd_to_coll` behavior is available as `access check`; its
parameters are ordered as `USERID COLLECTION [IP]`, with IP optional.

Management collections (`dlpsAuthzType = "m"`) are legacy data. The
administrative API and CLI do not create new management collections; new
collections must use a supported non-management authorization type.

Command-group aliases are `inst`, `net`, `coll`, and `loc`; `user` is not
abbreviated. Frequently used options have standard one-letter shorthands:
`--institution`/`-i`, `--cidr`/`-c`, `--range-start`/`-s`,
`--range-end`/`-e`, and `--access-switch`/`-a`.

## 4. Command Responsibilities

| Existing utility | Target command | Phase | Behavior |
|---|---|---:|---|
| `qi` | `institution search` | 1 | Search institutions by organization-name fragments. |
| `qn` | `network search` | 1 | Search networks by CIDR prefix. |
| `qin` | `institution networks` | 1 | List networks associated with an institution. |
| `qic` | `institution grants` | 1 | List collection grants for an institution. |
| `qu` | `user show` | 1 | Show user data, institution memberships, and direct collection permissions. |
| `qp` | `location search --path` | 1 | Search protected locations by path. |
| `qs` | `location search --server` | 1 | Search protected locations by server. |
| `qc` | `collection show` | 1 | Show collection metadata and matching grant information. |
| `authzd_to_coll` | `access check` | 1 | Check access for a user, collection, and optional IP. |
| `add_inst` | `institution add` | 1 | Create an institution through the administrative API. |
| `ain` | `network add` | 1 | Add an institution-associated network from CIDR or an inclusive range. |

## 5. Internal Architecture

### API Client

Provide one shared API client responsible for:

- Base URL configuration.
- Bearer-token authentication.
- HTTP methods.
- Request timeouts.
- Response decoding.
- API error normalization.
- Non-success status handling.

Command implementations must not construct authentication headers or parse HTTP responses independently.

### Resource Interfaces

Group API calls by domain:

- Institutions.
- Users.
- Collections.
- Locations.
- Networks.
- Access checks.

These interfaces should return structured results to command handlers.

### Command Layer

Each command should:

- Parse arguments and options.
- Validate required input.
- Call the API client or local CIDR library.
- Render output.
- Return an appropriate exit status.

Commands should not contain SQL-equivalent logic.

### Mutating Commands

`institution add` accepts an organization name and creates an active
institution through the administrative API.

`network add` requires an institution ID and accepts exactly one of:

- `--cidr CIDR`
- `--range-start START --range-end END`

It rejects `--ip`, `--prefix`, mixed modes, incomplete ranges, invalid CIDR,
and reversed ranges. Range mode decomposes the inclusive range into the
minimal CIDR set, displays every CIDR that will be added, and requires explicit
confirmation before posting. A direct CIDR posts immediately when it is
already canonical; a CIDR whose host bits would be truncated is displayed in
canonical form and requires confirmation. The CLI posts the complete CIDR set
as one API batch. `--access-switch` accepts `allow` or `deny` and defaults to
`allow`. The API validates the institution, derives the address bounds, and
associates every network through `inst` atomically.

Network creation rejects an exact active address-range duplicate globally,
regardless of institution or `allow`/`deny` access switch. The API compares
canonical address bounds, so host bits are normalized before uniqueness is
checked. An owner-aware `400 invalid_parameter` error identifies the canonical
CIDR, owning institution ID, and organization name. Canonical duplicates in a
single request are also rejected with a message containing the canonical CIDR;
the batch is atomic. Different-size and other non-identical overlaps remain
allowed, and a soft-deleted range can be recreated while its historical row
remains deleted. The current composite key permits only one deleted historical
row for a range; repeated delete/recreate cycles and a future history table
remain deferred.

Authorization evaluates active networks globally for the requested client IP
and uses the smallest matching range. A more-specific range takes precedence
over a containing range even when the ranges belong to different institutions.
For example, an institution 7 `/24` `allow` network and an institution 8
`/25` `deny` network deny clients in the `/25`, while clients elsewhere in the
`/24` use the `/24` `allow` configuration. Direct user,
institution-membership, and group-membership grants are separate authorization
paths and are not revoked by a deny network.
Deleted networks are excluded. Equal-sized overlapping IPv4 CIDRs are exact
duplicates by definition and are rejected globally; different-size and other
non-identical overlaps remain allowed. The CLI must not add broader overlap
validation.

### Output Layer

Use a consistent output strategy:

- Human-readable output by default.
- Structured JSON output where useful.
- Stable headers and field ordering.
- Normalize structured API errors to `<code>: <message>` and emit no mutation
  success output when a mutation fails.

## 6. `cidr` Command

### Interfaces

```text
lauth cidr from-range START END
lauth cidr to-range CIDR
lauth cidr to-ints CIDR
```

Example:

```text
lauth cidr from-range 141.212.0.0 141.215.255.255
lauth cidr to-range 141.212.0.0/14
lauth cidr to-ints 141.212.0.0/14
```

`from-range` output:

```text
141.212.0.0/14
```

`to-range` output:

```text
141.212.0.0 141.215.255.255
```

`to-ints` output:

```text
2379481088 2379743231
```

### Semantics

- Treat the range as inclusive.
- Accept full dotted-decimal IPv4 addresses.
- `from-range` takes exactly two dotted-decimal IPv4 arguments.
- `to-range` and `to-ints` take exactly one slash-notation IPv4 CIDR argument.
- Reject malformed addresses.
- Reject `START > END`.
- Emit the minimal CIDR decomposition, one block per line.
- Do not call the API.
- Do not preserve legacy classful-network explanations or unrelated output modes.

### Algorithm

At each current start address:

1. Determine the largest CIDR block aligned at that address.
2. Limit its size to the remaining range.
3. Emit the block.
4. Advance to the next address.
5. Repeat until the end address is covered.

This is a clean-room implementation based on CIDR properties, not a source translation of a legacy utility.

### Tests

Include:

- Single-address ranges.
- One aligned `/24`.
- Ranges crossing octet boundaries.
- Unaligned ranges requiring multiple blocks.
- Ranges beginning at `0.0.0.0`.
- Ranges ending at `255.255.255.255`.
- The full IPv4 address space.
- Reversed ranges.
- Invalid octets.
- Invalid or non-IPv4 CIDR notation.

## 7. API Integration

Before implementing API-backed commands, document the endpoint contract for each operation:

- HTTP method and path.
- Query parameters.
- Request body, if any.
- API-key header.
- Response schema.
- Error response schema.
- Whether deleted rows are included by default.
- Whether wildcard searches are supported.

Pagination does not need to be implemented.


## 8. Configuration and Security

Configuration should support:

- API base URL.
- Bearer token from `AUTHZ_API_TOKEN` or the explicit CLI override.
- Request timeout.
- Optional output format.
- Optional verbosity/debug mode.

Do not carry forward embedded database credentials, Oracle environment variables, hard-coded filesystem paths, or shell pipelines.

Tokens must never appear in normal command output or error messages.

## 9. Verification Strategy

### Unit Tests

- CIDR conversion.
- Input validation.
- API client request construction.
- API error normalization.
- Output formatting.

### Command Tests

Use a fake or stubbed API client to verify:

- Argument parsing.
- Correct API calls.
- Human-readable output.
- JSON output where supported.
- Exit statuses.
- Empty-result handling.
- API failure handling.

### Compatibility Checks

For representative existing queries:

- Compare institution results.
- Compare network results.
- Compare collection and user inspection results.
- Compare `access check` results with the legacy `authzd_to_coll` fields and the `/authorized` result structure.
- Compare CIDR output against mathematically expected decompositions.

## 10. Acceptance Criteria

The active CLI scope is complete when:

- All selected top-level utilities have command equivalents or an explicit retired status.
- `location` is a top-level command group.
- `access check` is available under the access command group.
- `lauth legacy-scripts` renders mappings only for legacy utilities with active
  command equivalents and does not execute legacy scripts or translate their
  parameters.
- `lauth cidr from-range START END` emits minimal CIDR coverage for valid IPv4 ranges.
- `lauth cidr to-range CIDR` emits the starting and ending dotted-decimal addresses.
- `lauth cidr to-ints CIDR` emits the starting and ending 32-bit integers.
- `lauth institution add` creates an institution through the administrative API.
- `lauth network add` creates an institution-associated network from CIDR or range input.
- Command aliases and option shorthands behave identically to canonical names.
- Network creation posts one atomic CIDR batch; range mode and non-canonical direct CIDRs confirm before posting.
- No command requires Oracle, MySQL, Perl DBI, or local database credentials.
- Bearer-token handling is centralized and secure.
- No pagination is introduced.
- Unit and command-level tests cover normal, empty, invalid, and API-error cases.
