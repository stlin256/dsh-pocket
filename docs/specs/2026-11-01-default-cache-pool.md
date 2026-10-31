# Default cache pool implementation spec

Date: 2026-11-01

## Budget model

- Define `NATIVE_DEFAULT_CACHE_LIMIT_BYTES` as `5 * 1024 * 1024 * 1024`.
- Define a compact `NativeStorageCandidate` with owner, scope id, optional
  session id, cache key, bytes, access time and protected flag.
- Invalid, empty and non-finite candidate sizes are ignored.
- A pure `nativeStorageEvictionPlan` returns candidates in eviction order:
  1. unprotected entries by access time, ascending;
  2. protected entries by access time, ascending only when step 1 cannot meet
     the hard limit.
- Candidates exactly equal to the limit require no eviction.

## Cache owners

- Transcript owner exposes manifest and legacy-row candidates and can delete a
  candidate transactionally.
- Workspace owner exposes directory, text and binary candidates and deletes the
  matching relational row and binary file when applicable.
- Attachment owner exposes app-private file candidates using file modification
  time and size.
- Navigation owner exposes one candidate per scope and can delete that scope's
  navigation keys.
- Candidate queries are read-only. Existing load paths remain responsible for
  updating access time.

## Coordination

- `NativeStorageManager.enforceDefaultLimit` gathers all owners, marks the active
  scope/session and provided protected sessions, and executes the pure plan.
- Global checks run at most once per five seconds unless explicitly forced.
- Cache writes notify the coordinator after persistence. Individual notify
  failures cannot fail the main request or display a user-facing success
  message.
- `NativeStorageManager.usageScope` reports current-account category values plus
  global pool usage and the current limit.
- Storage management presents pool usage and limit in the summary card. Category
  rows continue to describe the current authenticated account.

## Safety

- Only app-private cache records and files are candidates.
- Route state, login credentials and remote workspace content are never deleted
  by global trimming except through the existing complete clear-cache action.
- Per-document transfer limits remain unchanged. Per-owner quotas become broad
  secondary safeguards so the shared 5 GiB pool is usable.
