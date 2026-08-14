# CLI Follow-Ups

These are intentionally deferred decisions, not blockers for the current CLI
and administrative API.

- Map Bearer tokens to audit identities instead of using `root` for mutation
  audit fields.
- Decide whether duplicate active institution names should be prohibited.
- Replace the current `(dlpsAddressStart, dlpsAddressEnd, dlpsDeleted)`
  uniqueness limitation with a history model that permits unlimited
  delete/recreate cycles.
- Decide whether collection-bound legacy networks require administrative API
  support. Current network workflows assume consequential networks are
  institution-bound; duplicate reporting and ownership behavior for `inst =
  NULL` remain unspecified.
- Check the production dataset for management collections (`dlpsAuthzType =
  'm'`) and decide whether any legacy handling is required beyond fail-closed
  denial by `/authorized`.
