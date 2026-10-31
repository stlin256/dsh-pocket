# Workspace File Persistent Cache Specification

Date: 2026-11-01

## Storage

`NativeWorkspaceCache` owns one encrypted relational-store database at security
level S3.

Tables:

- `directory_cache`: scoped Session/path JSON, fingerprint, byte count,
  `updated_at`.
- `text_cache`: scoped Session/path JSON, Host version, byte count,
  `updated_at`.
- `binary_cache`: scoped Session/path, Host version, file name, byte count,
  checksum and `updated_at`.

Binary payloads live in the app-private files directory. Database rows are
written before a binary becomes visible. Temporary files are renamed atomically.

All scope ids are one-way hashes of `client.cacheKey()`. File names hash the
scope, Session id and path. Raw origins and device paths do not appear in file
names.

## Local validation

- Directory payloads decode into the existing listing model. Every entry name,
  type and optional size must be valid. The stored fingerprint must equal a
  newly computed canonical fingerprint.
- Text payloads decode into the existing paged text model. Offsets, line counts,
  version and byte metadata must satisfy the same shape rules as network data.
- Binary metadata must match the actual file length, Host version and checksum.
  A corrupt or partial binary is deleted and treated as a cache miss.

Invalid or unsupported persisted payloads are discarded without blocking the
network path.

## Directory flow

`NativeFileBrowser.load` follows this sequence:

1. Start a request generation for the requested Session/path.
2. Read and validate the cached directory.
3. If present, paint its entries immediately, mark the header as refreshing and
   retain them while the network request runs.
4. Request `workspaceFiles/list`.
5. Compute the canonical fingerprint.
6. If equal, update LRU access and retain the cached frame.
7. If different, replace the list and persist the new payload atomically.
8. If the request fails, keep a validated cached frame for transient failures;
   use the existing error state only when no usable cache exists.

Naming is canonical. Fingerprints sort entries by name, type and size before
hashing, so server response order alone cannot cause a rewrite.

## Text flow

1. Read the cached first page.
2. Paint its text, line label and pagination state immediately.
3. Request `workspaceFiles/stat`.
4. If the Host version equals the cached version, stop without calling
   `workspaceFiles/read`.
5. If versions differ, request the first page, replace the visible content and
   persist the new page/version.
6. A stat failure with validated cached content retains the cached frame; a
   stable missing/unreadable response invalidates it.

“Load more” fetches the next uncached range normally and updates the persisted
first-page snapshot only when the response still carries the current version.

## Binary flow

1. Read and checksum the cached image/binary payload.
2. Decode and paint it immediately after local validation.
3. Request `workspaceFiles/stat`.
4. Retain the cached image when versions match.
5. On a version change, reread bytes with the new version, decode, persist and
   replace the visible image.
6. A corrupt cache, failed decode or changed version is a cache miss; network
   behavior remains the source of truth.

SVG preview and code mode use the text or binary cache depending on the active
mode. Switching modes can reuse whichever representation is already valid.

## Quotas and lifecycle

- Encrypted directory/text storage target: 96 MiB per authenticated scope.
- Binary cache target: 256 MiB per authenticated scope, 64 MiB per file.
- LRU eviction removes the least recently accessed rows/files after successful
  inserts.
- Logout clears all rows and binary files for the authenticated scope.
- Removing a Session also clears that Session's workspace workspace cache.

## Failure ownership

Cache failures are silent. Missing cache simply follows the existing loading
path. A real network/content failure remains visible only when no validated
cache can satisfy the request. Cached content never bypasses URL/path
normalization or the read-only gateway contract.

## Verification

- Unit tests cover canonical fingerprint order, metadata changes, truncation,
  payload validation and one-way scope keys.
- Source-contract tests cover cache-before-network paint, version short-circuit,
  generation guards, atomic binary writes and logout cleanup.
- Device E2E covers cold then warm directory/file opens, unchanged validation,
  changed content, offline fallback, restart persistence and account isolation.
- Both Release product variants are built after implementation.
