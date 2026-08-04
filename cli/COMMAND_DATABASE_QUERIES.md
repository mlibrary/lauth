# Command-to-Database Query Reference

This document maps the administrative CLI commands to the SQL used by their
legacy Perl utilities. The SQL examples show representative values inserted
for readability; the legacy utilities actually used bind parameters where
noted.

The current CLI calls the REST API rather than connecting directly to Oracle.
These statements describe the database behavior the REST operations replace.

## Oracle And MariaDB 12 Compatibility

The ordinary `SELECT`, `FROM`, `WHERE`, `LIKE`, and `ORDER BY` statements in
this document are valid in both Oracle and MariaDB 12, assuming the tables and
columns have been migrated. The following differences require attention:

- **Schema qualification:** `authz_umichlib.aa_coll` is an Oracle schema and
  table reference. In MariaDB, the equivalent is a database and table
  reference, so the same two-part form works after creating the
  `authz_umichlib` database. Use backticks if a migrated identifier conflicts
  with a MariaDB keyword.
- **Bind parameters:** The examples substitute values for readability. Both
  databases support prepared statements, and production code should continue
  binding values rather than concatenating them into SQL.
- **Case and `LIKE`:** `UPPER(organizationname) LIKE ...` is supported by both
  databases. MariaDB collation settings can make `LIKE` case-insensitive even
  without `UPPER`, so choose and document the target collation explicitly when
  matching Oracle behavior.
- **Empty strings:** Oracle treats `''` as `NULL`, while MariaDB distinguishes
  an empty string from `NULL`. The empty second argument in
  `authzd_to_coll_function` must be checked when that function is ported.
- **`SELECT *`:** The syntax is portable, but result-column order and data
  types depend on the migrated table definition. Stable API responses should
  use explicit column lists.
- **Table-valued function:** Oracle supports
  `SELECT * FROM TABLE(function(...))`. MariaDB 12 has no direct equivalent
  for an Oracle collection-returning function. Port the logic as a stored
  procedure that returns a result set, a normal query against a persisted
  result table, or an appropriate `JSON_TABLE` design if the function is
  changed to return JSON.
- **Date formatting:** Oracle's `TO_CHAR(date, format)` is not MariaDB
  syntax. The equivalent formatting expression is
  `DATE_FORMAT(date, '%Y-%m-%d %H:%i:%s')`.
## Query Commands

### `authz institution search Michigan Library`

Legacy utility: `bin/qi`

The utility builds the case-insensitive pattern `%MICHIGAN%LIBRARY%`.

```sql
SELECT
    uniqueidentifier,
    organizationname
FROM
    aa_inst
WHERE
    UPPER(organizationname) LIKE '%MICHIGAN%LIBRARY%'
ORDER BY
    uniqueidentifier;
```

### `authz network search 192.0.2`

Legacy utility: `bin/qn`

The utility appends `%` to the supplied prefix.

```sql
SELECT
    inst,
    dlpsCIDRAddress,
    dlpsAccessSwitch,
    dlpsAddressStart,
    dlpsAddressEnd,
    lastModifiedTime
FROM
    aa_network
WHERE
    dlpsCIDRAddress LIKE '192.0.2%'
ORDER BY
    dlpsAddressStart,
    dlpsAccessSwitch;
```

### `authz institution networks 7`

Legacy utility: `bin/qin`

```sql
SELECT
    dlpsCIDRAddress,
    dlpsAccessSwitch,
    dlpsAddressStart,
    dlpsAddressEnd,
    lastModifiedTime
FROM
    aa_network
WHERE
    inst = 7
ORDER BY
    dlpsAddressStart,
    dlpsAccessSwitch;
```

### `authz institution grants 7`

Legacy utility: `bin/qic`

```sql
SELECT
    coll,
    lastModifiedTime,
    dlpsDeleted
FROM
    aa_may_access
WHERE
    inst = 7
ORDER BY
    coll;
```

### `authz user show alice`

Legacy utility: `bin/qu`

The user inspection runs three queries: one for the user row, one for
institution memberships, and one for direct collection grants.

```sql
SELECT *
FROM aa_user
WHERE userid = 'alice';
```

```sql
SELECT *
FROM aa_is_member_of_inst
WHERE userid = 'alice';
```

```sql
SELECT
    coll,
    lastModifiedTime,
    dlpsDeleted
FROM
    aa_may_access
WHERE
    userid = 'alice'
ORDER BY
    userid;
```

### `authz objects by-path /books`

Legacy utility: `bin/qp`

The legacy utility surrounds the supplied path with `%` wildcards.

```sql
SELECT *
FROM authz_umichlib.aa_coll_obj
WHERE dlpspath LIKE '%/books%';
```

### `authz objects by-server server.example`

Legacy utility: `bin/qs`

```sql
SELECT *
FROM authz_umichlib.aa_coll_obj
WHERE dlpsserver LIKE '%server.example%';
```

### `authz collection show example`

Legacy utility: `bin/qc`

The collection inspection utility runs a metadata query followed by a query
for matching grants. With the CLI's prefix-style lookup, the example pattern
is `example%`.

```sql
SELECT *
FROM authz_umichlib.aa_coll
WHERE uniqueidentifier LIKE 'example%';
```

```sql
SELECT *
FROM authz_umichlib.aa_may_access
WHERE coll LIKE 'example%';
```

### `authz collection grants example`

Legacy utility: `bin/qc`

This command corresponds to the matching-grants query from `qc`.

```sql
SELECT *
FROM authz_umichlib.aa_may_access
WHERE coll LIKE 'example%';
```

### `authz authzd_to_coll 192.0.2.1 alice example`

Legacy utility: `bin/authzd_to_coll`

The utility converts `192.0.2.1` to its unsigned numeric IPv4 value
`3221225985` before calling the Oracle table function.

```sql
SELECT *
FROM TABLE(authz_umichlib.authzd_to_coll_function(
    3221225985,
    '',
    'alice',
    'example'
));
```

This statement is Oracle-specific. A MariaDB procedure-based port would use a
result-set procedure call such as the following only if the function logic
has been reimplemented as a procedure:

```sql
CALL authz_umichlib.authzd_to_coll_function(3221225985, '', 'alice', 'example');
```

## Local Command

### `authz cidr from-range 141.212.0.0 141.215.255.255`

These commands perform local IPv4 conversion and do not run a database query
or call the REST API.

`from-range` output:

```text
141.212.0.0/14
```

`to-range` example:

```text
$ authz cidr to-range 141.212.0.0/14
141.212.0.0 141.215.255.255
```

`to-ints` example:

```text
$ authz cidr to-ints 141.212.0.0/14
2379481088 2379743231
```
