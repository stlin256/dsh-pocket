# Local Storage Management Device E2E

Status: Pending connected-device execution after build and installation.

| ID | Scenario | Expected evidence | Status |
| --- | --- | --- | --- |
| STORAGE-01 | Open Settings after conversations and workspace previews have been cached | Storage Management is visible and its total loads without blocking the rest of Settings | Pending |
| STORAGE-02 | Compare category values with populated transcript, directory, text and image caches | Every category is non-negative and the total equals their sum | Pending |
| STORAGE-03 | Reopen the Storage Management page | Usage refreshes and no layout overlap, clipping or safe-area regression appears | Pending |
| STORAGE-04 | Tap `清空缓存`, then cancel the native confirmation | All values remain unchanged and login remains valid | Pending |
| STORAGE-05 | Confirm clear | Usage refreshes to zero without a success toast; the app remains logged in | Pending |
| STORAGE-06 | Open conversations and workspace files after clearing | Content reloads from the Host correctly; Host files remain unchanged | Pending |
| STORAGE-07 | Switch light/dark/system appearance on the page | Text, dividers, spinner and red action keep readable contrast | Pending |
| STORAGE-08 | Enable reduced motion and navigate/clear | Navigation resolves to final state and clearing remains usable | Pending |
| STORAGE-09 | Logout, authenticate another scope and open Storage Management | Only the new scope's cache is reported; the previous scope is not exposed | Pending |

Record the HAP variant, build version, device model and observed behavior for
each row after execution.
