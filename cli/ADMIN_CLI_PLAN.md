# Administrative CLI Development Plan

Current implementation progress is tracked in [`TODO.md`](TODO.md).

## 1. Objective

Replace the selected top-level Perl utilities in `bin/` with a command-suite CLI backed by the existing authorization REST API.

The CLI will:

- Use a Bearer token for authenticated API requests.
- Preserve useful administrative and diagnostic behavior.
- Remove direct Oracle and MySQL dependencies.
- Keep local IP-range conversion independent of the API.
- Support institution and network creation through the administrative API.

## 2. Scope

Implement the selected administrative and diagnostic functionality from top-level `bin/`:

- Institution lookup: `qi`
- Institution network lookup: `qn`, `qin`
- Institution collection lookup: `qic`
- User inspection: `qu`
- Collection inspection: `qc`
- Protected-location lookup: `qp`, `qs`
- Authorization diagnostic: `authzd_to_coll` (deferred)
- CIDR range conversion: `aggis`/`vip` behavior exposed as `cidr`
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

lauth locations search --path PATH
lauth locations search --server SERVER

lauth collection search PATTERN
lauth collection show
lauth collection grants

lauth network search
lauth network add --institution INSTITUTION_ID --cidr CIDR
lauth network add --institution INSTITUTION_ID --range-start START --range-end END

lauth authzd_to_coll

lauth cidr from-range START END
lauth cidr to-range CIDR
lauth cidr to-ints CIDR
```

The existing `authzd_to_coll` name remains unchanged for now.

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
| `qp` | `locations search --path` | 1 | Search protected locations by path. |
| `qs` | `locations search --server` | 1 | Search protected locations by server. |
| `qc` | `collection show` | 1 | Show collection metadata and matching grant information. |
| `authzd_to_coll` | `authzd_to_coll` | Deferred | Preserve the existing diagnostic contract until its necessity is decided. |
| `aggis`/`vip` | `cidr from-range` | 1 | Convert an inclusive IPv4 range into minimal CIDR blocks. |
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
- Authorization diagnostics.

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
confirmation before posting. Each confirmed CIDR is posted as one associated
network. `--access-switch` accepts `allow` or `deny` and defaults to `allow`.
The API validates the institution, derives the address bounds, and associates
each network through `inst`.

Network creation does not reject overlaps. Overlapping networks within one
institution and a network contained by a network associated with another
institution are valid historical configurations.

### Output Layer

Use a consistent output strategy:

- Human-readable output by default.
- Structured JSON output where useful.
- Stable headers and field ordering.

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
- Do not preserve `aggis` classful-network explanations or unrelated output modes.

### Algorithm

At each current start address:

1. Determine the largest CIDR block aligned at that address.
2. Limit its size to the remaining range.
3. Emit the block.
4. Advance to the next address.
5. Repeat until the end address is covered.

This is a clean-room implementation based on CIDR properties, not a source translation of `aggis`.

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
- Compare `authzd_to_coll` diagnostic fields.
- Compare CIDR output against mathematically expected decompositions.

## 10. Acceptance Criteria

The active CLI scope is complete when:

- All selected top-level utilities have command equivalents or an explicit retired status.
- `locations` is a top-level command group.
- `authzd_to_coll` remains available under that exact name.
- `lauth cidr from-range START END` emits minimal CIDR coverage for valid IPv4 ranges.
- `lauth cidr to-range CIDR` emits the starting and ending dotted-decimal addresses.
- `lauth cidr to-ints CIDR` emits the starting and ending 32-bit integers.
- `lauth institution add` creates an institution through the administrative API.
- `lauth network add` creates an institution-associated network from CIDR or range input.
- Command aliases and option shorthands behave identically to canonical names.
- Range-mode network creation confirms the complete CIDR set before posting.
- No command requires Oracle, MySQL, Perl DBI, or local database credentials.
- Bearer-token handling is centralized and secure.
- No pagination is introduced.
- Unit and command-level tests cover normal, empty, invalid, and API-error cases.
