# Administrative CLI Development Plan

Current implementation progress is tracked in [`TODO.md`](TODO.md).

## 1. Objective

Replace the selected top-level Perl utilities in `bin/` with a command-suite CLI backed by the existing authorization REST API.

The CLI will:

- Use an API key for authenticated API requests.
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
- Protected-object lookup: `qp`, `qs`
- Authorization diagnostic: `authzd_to_coll`
- Authorization-table export: `dumpall`
- Replication status: `check_replication`
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
authz institution collections

authz user show

authz objects by-path
authz objects by-server

authz collection show
authz collection access

authz network search

authz authzd_to_coll

authz export

authz replication status

authz cidr START - END
```

The existing `authzd_to_coll` name remains unchanged for now.

The exact root executable name is an implementation detail; the command and subcommand structure is the important boundary.

## 4. Command Responsibilities

| Existing utility | Target command | Phase | Behavior |
|---|---|---:|---|
| `qi` | `institution search` | 1 | Search institutions by organization-name fragments. |
| `qn` | `network search` | 1 | Search networks by CIDR prefix. |
| `qin` | `institution networks` | 1 | List networks associated with an institution. |
| `qic` | `institution collections` | 1 | List collections authorized for an institution. |
| `qu` | `user show` | 1 | Show user data, institution memberships, and direct collection permissions. |
| `qp` | `objects by-path` | 1 | Search protected objects by path. |
| `qs` | `objects by-server` | 1 | Search protected objects by server. |
| `qc` | `collection show` | 1 | Show collection metadata and matching access information. |
| `authzd_to_coll` | `authzd_to_coll` | 1 | Call the REST authorization diagnostic endpoint with IP, user, and collection. |
| `dumpall` | `export` | 1 | Export authorization data locally using API responses. |
| `check_replication` | `replication status` | 1 | Report stale or unhealthy replication state exposed by the API. |
| `aggis`/`vip` | `cidr` | 1 | Convert an inclusive IPv4 range into minimal CIDR blocks. |
| `dump_paths.pl` | `objects by-path --raw` | 2 | Preserve raw collection-object dump behavior if still required. |
| `dump_server.pl` | `objects by-server --raw` | 2 | Preserve raw collection-object dump behavior if still required. |
| `dump_coll.pl` | `collection access --raw` | 2 | Preserve raw collection-access dump behavior if still required. |
| `add_inst` | `institution create` | 2 | Create an institution. |
| `ain` | `institution network add` | 2 | Add institution network ranges with overlap checks. |
| `auth_to_acls` | `institution collections grant-default-acls` | 2 | Grant default ACLS collection access. |

## 5. Internal Architecture

### API Client

Provide one shared API client responsible for:

- Base URL configuration.
- API-key authentication.
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
- Objects.
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

### Interface

```text
authz cidr START - END
```

Example:

```text
authz cidr 141.212.0.0 - 141.215.255.255
```

Output:

```text
141.212.0.0/14
```

### Semantics

- Treat the range as inclusive.
- Accept full dotted-decimal IPv4 addresses.
- Require the literal `-` separator.
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
- Missing or malformed separators.

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

If the API does not expose equivalents for `export` or `replication status`, define those as separate API requirements rather than recreating database access in the CLI.

## 8. Configuration and Security

Configuration should support:

- API base URL.
- API key from an environment variable or protected config file.
- Request timeout.
- Optional output format.
- Optional verbosity/debug mode.

Do not carry forward embedded database credentials, Oracle environment variables, hard-coded filesystem paths, or shell pipelines.

API keys must never appear in normal command output or error messages.

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
- `objects` is a top-level command group.
- `authzd_to_coll` remains available under that exact name.
- `authz cidr START - END` emits minimal CIDR coverage for valid IPv4 ranges.
- No Phase One command requires Oracle, MySQL, Perl DBI, or local database credentials.
- API-key handling is centralized and secure.
- No pagination is introduced.
- Phase Two utilities remain untouched.
- Unit and command-level tests cover normal, empty, invalid, and API-error cases.
