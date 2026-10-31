# Local Storage Management

Date: 2026-11-01

## User requirement

Native Settings must include a Storage Management page that reports the local
cache footprint for the active authenticated scope. The page separates
conversation content, workspace browsing metadata, workspace file content and
image attachments so users can understand what the app retains.

The page provides a destructive clear-cache action with red text and a native
confirmation dialog.

## Required behavior

- Settings exposes Storage Management from the root list.
- The page loads automatically and reports total cache use plus category
  breakdowns.
- Usage belongs to the current authenticated scope and covers:
  - conversation transcripts;
  - workspace directory listings;
  - workspace text and binary preview content;
  - downloaded image attachments;
  - navigation and session index metadata.
- Values use compact binary units and remain stable while a read is pending.
- Clearing cache requires explicit second confirmation.
- Clearing removes only app-owned local cache for the active scope.
- Clearing never logs out, clears the login cookie, changes the saved server
  address or deletes content from the DSH Host.
- The workspace remains read-only.
- A successful clear refreshes the visible usage silently, without a toast.
- Cancellation leaves all cache intact.
- Failure keeps the page usable and shows one inline error with a retry path.
- Motion and colors follow the existing DSH Harmony settings language and
  reduced-motion behavior.

## Out of scope

- Device-wide storage totals.
- Server disk usage.
- Deleting or mutating Host files.
- Logout and account switching, which retain their existing flows.
