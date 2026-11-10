# CLI Follow-Ups

These are intentionally deferred decisions, not blockers for the current CLI
and administrative API.

- Map Bearer tokens to audit identities instead of using `root` for mutation
  audit fields.
- Decide whether duplicate active institution names should be prohibited.
- Decide whether collection-bound legacy networks require administrative API
  support. Current network workflows assume consequential networks are
  institution-bound; behavior for `inst = NULL` remains unspecified.
- Check the production dataset for management collections (`dlpsAuthzType =
  'm'`) and decide whether any legacy handling is required beyond fail-closed
  denial by `/authorized`.
