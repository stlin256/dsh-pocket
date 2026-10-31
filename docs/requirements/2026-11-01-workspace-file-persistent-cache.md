# Workspace File Persistent Cache

Date: 2026-11-01

## User requirement

Previously loaded workspace directory structures and file previews must survive
app restarts. Reopening a cached directory or file should paint immediately
while metadata, content version or a deterministic fingerprint validates the
cache.

## Required behavior

- Cache keys are isolated by the one-way authenticated session scope, Session
  id and canonical workspace path.
- Directory listings persist with a deterministic fingerprint of names, types,
  sizes and truncation state.
- Text preview pages persist with the Host-provided file version.
- Image and SVG binary previews persist with the Host version, byte length and
  a local integrity checksum.
- A cached surface may paint before revalidation, but only after local payload
  shape, length and checksum validation succeed.
- Revalidation runs in the background so a warm read does not block on the
  network.
- An unchanged directory fingerprint or file version keeps the cached result
  without a second content read.
- A changed fingerprint or version replaces the cached result and atomically
  updates persistence.
- A transient network failure may retain a previously validated cached result.
  A stable missing, unreadable or changed-target response removes the obsolete
  entry and returns the existing user-visible error state.
- Older asynchronous requests cannot overwrite a newer path or file selection.
- Cache size is bounded with least-recently-used eviction.
- Logout and account-scope changes clear workspace directory, text and binary
  caches.
- Cache data remains app-private; absolute device paths, credentials and raw
  server origins are not stored as key material or user-visible diagnostics.

## Scope

The cache is read-only and never creates, modifies, deletes, uploads or renames
workspace content. Explicit downloads continue to use the system save picker.
