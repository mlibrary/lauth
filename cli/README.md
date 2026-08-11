# lauth administrative CLI

`lauth` is the command-line client for the versioned lauth administrative API.
It manages institutions, networks, users, locations, collections, and access
checks without connecting directly to the database.

## Installation

Download the archive for your operating system and architecture from the lauth
release page, extract it, and place the `lauth` executable somewhere on your
`PATH`. The release archive includes this README and the project license.

## Configuration

The CLI reads its API configuration from environment variables:

- `AUTHZ_API_BASE_URL` — base URL of the administrative API.
- `AUTHZ_API_TOKEN` — Bearer token used for API authentication.
- `AUTHZ_API_TIMEOUT` — optional request timeout.

Do not put API tokens or database credentials in source files, shell history,
or release documentation.

## Output

Human-readable table output is the default. Use `--output=json` for structured
API-shaped output suitable for scripts.

Table headers and JSON field names preserve the API and database schema names,
including fields such as `uniqueIdentifier`, `organizationName`,
`dlpsCIDRAddress`, `dlpsPath`, and `dlpsServer`.

## Commands

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
is not abbreviated. Run `lauth --help` or `lauth <command> --help` for the
complete options and examples.

## Network creation

`network add` accepts either one canonical CIDR or an inclusive IPv4 range.
Range input is decomposed into minimal CIDRs, displayed, and confirmed before
posting. The complete CIDR set is sent as one API batch. Use
`--access-switch=allow` or `--access-switch=deny`; the default is `allow`.

The CLI does not reject historical network overlaps. The API rejects exact
active address-range duplicates globally while allowing different-size and
other non-identical overlaps.

## Local CIDR commands

The `cidr` commands are local-only and do not call the API. They convert between
IPv4 CIDRs, address ranges, and integer bounds.

## Scope

`export` and `replication status` are retired. Management collections
(`dlpsAuthzType = "m"`) are legacy data; the administrative API and CLI do not
create new management collections. Pagination is not currently supported.

For the full API contract, see the lauth project documentation.
