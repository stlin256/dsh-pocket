# Default cache pool research

Date: 2026-11-01

## Current behavior

- Encrypted transcript snapshots trim to 512 MiB.
- Workspace directory/text metadata trims to 96 MiB per account.
- Workspace binary previews trim to 256 MiB per account.
- Image attachments trim to 256 MiB per account.
- Navigation metadata is bounded by the number of retained sessions,
  workspaces and interactions.

Each owner has a useful local safety bound, but the limits are independent.
Four large owners can therefore retain more than 1 GiB at the same time, and
future limit changes can increase that total without a shared budget.

## Ownership constraints

- Transcript and workspace metadata live in encrypted relational stores.
- Workspace binaries and image attachments live in app-private files.
- Existing cache records already carry an access timestamp or file modification
  time suitable for least-recently-used ordering.
- Live streaming can write a transcript snapshot every 500 ms. A full scan of
  every cache store on every write would add avoidable I/O, so global checks
  must be rate limited.
- A cache candidate should retain only its owner, scope/session identifiers,
  cache key, logical bytes and access time. File content and transcript text
  must not enter the eviction model.

## Selected design

Use a pure eviction planner for deterministic tests and an app-level coordinator
that gathers compact candidates from each cache owner. Protected active entries
are skipped during the first pass. If that cannot bring the pool under the hard
limit, a second pass allows protected entries to fall back so the limit remains
hard rather than advisory.

Per-owner quotas are raised to broad secondary safeguards so the shared pool can
grow toward 5 GiB, while the coordinator remains authoritative. Global checks
are throttled to avoid querying each store during every streamed snapshot.
