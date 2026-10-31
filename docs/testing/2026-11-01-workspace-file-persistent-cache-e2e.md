# Workspace File Persistent Cache Device E2E

Status: Pending connected-device execution.

| ID | Scenario | Expected evidence | Status |
| --- | --- | --- | --- |
| FCACHE-01 | Open a populated directory, close the app, reopen the browser | The persisted listing paints before the refresh request completes | Pending |
| FCACHE-02 | Warm-open an unchanged text or Markdown file | Cached content paints immediately; stat runs and no second text read is needed | Pending |
| FCACHE-03 | Warm-open an unchanged PNG, JPEG or SVG preview | Checked cached bytes decode immediately; matching metadata avoids a second byte transfer | Pending |
| FCACHE-04 | Change a file on the Host, then warm-open it | Cached content paints first, the version differs, and the new content replaces it | Pending |
| FCACHE-05 | Add, remove, rename or resize an entry, then warm-open its directory | The changed fingerprint triggers a new persisted listing | Pending |
| FCACHE-06 | Disconnect the Host after a successful warm cache fill, then reopen a cached directory/file | Validated cached content remains usable while no stable unavailable result is returned | Pending |
| FCACHE-07 | Rapidly enter several directories while responses are pending | Only the latest directory can paint; stale responses cannot replace or persist it | Pending |
| FCACHE-08 | Corrupt a binary cache payload externally in a test build | The payload is rejected, removed and downloaded again | Pending |
| FCACHE-09 | Logout and authenticate another account, then inspect workspace files | The previous account's cached directory and file content are unavailable | Pending |
| FCACHE-10 | Reopen a very large previously loaded directory | LRU-cached structure opens promptly without rendering beyond the existing bounded entry count | Pending |
| FCACHE-11 | Exercise explicit download after a cached preview | Download still asks for a system save location and writes the current file version | Pending |

Record device model, build variant, cache state, Host revision and observed
network calls for each row after execution.
