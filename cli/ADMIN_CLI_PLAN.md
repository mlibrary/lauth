# Administrative CLI Development Plan

Current implementation progress is tracked in [`TODO.md`](TODO.md).

## 1. Objective

Replace the selected top-level Perl utilities in `bin/` with a command-suite CLI backed by the existing authorization REST API.

The CLI will:

- Use a Bearer token for authenticated API requests.
- Preserve useful administrative and diagnostic behavior.
- Remove direct Oracle and MySQL dependencies.
- Keep local IP-range conversion independent of the API.
- Defer nested MySQL utilities and mutation workflows to later phases.

## 2. Scope

### Phase One

Port the read-only administrative and diagnostic functionality from top-level `bin/`:

- Institution lookup: `qi`
- Institution network lookup: `qn`, `qin`
- Institution collection lookup: `qic`
- User inspection: `qu`
- Collection inspection: `qc`
- Protected-location lookup: `qp`, `qs`
- Authorization diagnostic: `authzd_to_coll` (deferred)
- CIDR range conversion: `aggis`/`vip` behavior exposed as `cidr`

### Phase Two

Defer:

- All `bin/mysql/*` utilities.
- Database mutations:
  - `add_inst`
  - `ain`
  - `auth_to_acls`
- Raw dump utilities:
  - `dump_paths.pl`
  - `dump_server.pl`
  - `dump_coll.pl`
- Nested operational utilities under `util/`.
- Bulk imports, synchronization, password rotation, email, and destructive loads.

## 3. Target Command Structure

Use a single command-suite executable with subcommands.

```text
authz institution search
authz institution networks
authz institution grants

authz user show

authz locations search --path PATH
authz locations search --server SERVER

authz collection search PATTERN
authz collection show
authz collection grants

authz network search

authz authzd_to_coll

authz cidr from-range START END
authz cidr to-range CIDR
authz cidr to-ints CIDR
```

The existing `authzd_to_coll` name remains unchanged for now.

The exact root executable name is an implementation detail; the command and subcommand structure is the important boundary.

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
| `dump_paths.pl` | `locations search --path --raw` | 2 | Preserve raw collection-location dump behavior if still required. |
| `dump_server.pl` | `locations search --server --raw` | 2 | Preserve raw collection-location dump behavior if still required. |
| `dump_coll.pl` | `collection grants --raw` | 2 | Preserve raw collection-grant dump behavior if still required. |
| `add_inst` | `institution create` | 2 | Create an institution. |
| `ain` | `institution network add` | 2 | Add institution network ranges with overlap checks. |
| `auth_to_acls` | `institution grants grant-default-acls` | 2 | Grant default ACLS collection grants. |

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
- Replication/health.
- Export.

These interfaces should return structured results to command handlers.

### Command Layer

Each command should:

- Parse arguments and options.
- Validate required input.
- Call the API client or local CIDR library.
- Render output.
- Return an appropriate exit status.

Commands should not contain SQL-equivalent logic.

### Output Layer

Use a consistent output strategy:

- Human-readable output by default.
- Structured JSON output where useful.
- TSV/raw output only for explicit Phase Two dump compatibility.
- Stable headers and field ordering.

## 6. `cidr` Command

### Interfaces

```text
authz cidr from-range START END
authz cidr to-range CIDR
authz cidr to-ints CIDR
```

Example:

```text
authz cidr from-range 141.212.0.0 141.215.255.255
authz cidr to-range 141.212.0.0/14
authz cidr to-ints 141.212.0.0/14
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

Phase One is complete when:

- All selected top-level read-only utilities have command equivalents.
- `locations` is a top-level command group.
- `authzd_to_coll` remains available under that exact name.
- `authz cidr from-range START END` emits minimal CIDR coverage for valid IPv4 ranges.
- `authz cidr to-range CIDR` emits the starting and ending dotted-decimal addresses.
- `authz cidr to-ints CIDR` emits the starting and ending 32-bit integers.
- No Phase One command requires Oracle, MySQL, Perl DBI, or local database credentials.
- Bearer-token handling is centralized and secure.
- No pagination is introduced.
- Phase Two utilities remain untouched.
- Unit and command-level tests cover normal, empty, invalid, and API-error cases.
