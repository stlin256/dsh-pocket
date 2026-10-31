# Chat Link Existence Device E2E

Status: The user manually passed the file-link audit on the connected device,
including unavailable file and directory references. Remaining rows stay
pending until individually exercised.

| ID | Scenario | Expected evidence | Status |
| --- | --- | --- | --- |
| LINK-EXIST-01 | Tap a valid Markdown or code file link in chat | The native reader opens after existence confirmation and displays the file | Pending |
| LINK-EXIST-02 | Tap a valid directory link in chat | The native file browser opens at that directory | Pending |
| LINK-EXIST-03 | Tap a nonexistent file path in chat | No preview/browser panel opens; one `文件或文件夹不可用` toast appears | Passed by user device audit |
| LINK-EXIST-04 | Tap a nonexistent directory path in chat | No preview/browser panel opens; one `文件或文件夹不可用` toast appears | Passed by user device audit |
| LINK-EXIST-05 | Tap a valid basename-only file located below the Session cwd | The bounded lookup resolves it and opens the matching file preview | Pending |
| LINK-EXIST-06 | Tap a valid non-text binary file | The preview remains available for download and is not reported as missing | Pending |
| LINK-EXIST-07 | Tap a valid link, then tap it again before its first response settles | Only the current request can open; no stale duplicate surface appears | Pending |

Record the device model, build variant, build timestamp and observed result for
each row after execution.
