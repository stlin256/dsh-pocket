# Default cache pool requirement

Date: 2026-11-01

## Requirement

- `CACHE-01` The default app-private cache limit is 5 GiB
  (`5 * 1024 * 1024 * 1024` bytes).
- `CACHE-02` Conversation snapshots, workspace metadata, cached file content,
  image attachments and navigation metadata share this one limit.
- `CACHE-03` When the pool exceeds its limit, the least recently used
  unprotected entries are evicted until usage is back within the limit.
- `CACHE-04` The active conversation and other in-memory protected sessions are
  preserved whenever older entries can free enough space. They may be evicted
  only when the hard limit is still exceeded after all unprotected entries are
  gone.
- `CACHE-05` Existing per-file limits remain in force. One PDF, HTML document,
  image or attachment cannot consume the entire pool.
- `CACHE-06` Storage management shows the global pool usage and the 5 GiB
  default limit while retaining the current-account category breakdown.
- `CACHE-07` Clearing cache remains complete for the active authenticated
  scope and does not change the default limit.
