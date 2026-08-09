# Retired Features

These legacy utilities are intentionally not part of the new API-backed CLI.
Do not add REST endpoints or command replacements for them unless the scope is
explicitly reopened.

## Authorization Export

- Legacy utility: `bin/dumpall`
- Removed command: `authz export`
- Reason: authorization-table export is not required by the new API.

## Replication Status

- Legacy utility: `bin/check_replication`
- Removed command: `authz replication status`
- Reason: replication health is not required by the new API.
