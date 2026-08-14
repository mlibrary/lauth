# Retired Features

These legacy utilities are intentionally not part of the new API-backed CLI.
Do not add REST endpoints or command replacements for them unless the scope is
explicitly reopened.

## Authorization Export

- Legacy utility: `bin/dumpall`
- Removed command: `lauth export`
- Reason: authorization-table export is not required by the new API.

## Replication Status

- Legacy utility: `bin/check_replication`
- Removed command: `lauth replication status`
- Reason: replication health is not required by the new API.

## Raw Collection Dumps

The following utilities are retired and have no CLI or API replacements:

- `dump_paths.pl`
- `dump_server.pl`
- `dump_coll.pl`

Reason: raw dump compatibility is outside the administrative CLI scope.

## Default ACL Grants

- Legacy utility: `auth_to_acls`
- Removed command: `lauth institution grants grant-default-acls`
- Reason: database mutation through default ACL grant expansion is outside the
  administrative CLI scope.

## Irrelevant Legacy Groups

The following groups are outside this project and should not be migrated or
tracked as deferred work:

- `bin/mysql/*` utilities
- Nested operational utilities
- Bulk imports and synchronization
- Password rotation and email utilities
- Destructive data-load workflows
