# Chat Link Existence and Failure Handling

Date: 2026-10-31

## User requirement

An unavailable file URL or folder reference in chat must report that the target
is unavailable without opening a file surface. It must not be presented as an
existing binary that is only available for download.

The first tap must still open valid files and folders promptly. A valid
download-only binary file may retain the existing download-only state after its
existence has been confirmed.

## Required behavior

- Resolve a chat link relative to the active Session working directory before
  probing the workspace.
- Confirm a regular file before publishing a file-preview request.
- Confirm a directory before publishing a file-browser request.
- If the exact path is absent, a basename-only reference may use the existing
  bounded workspace lookup.
- If neither file nor directory resolution succeeds, keep the chat visible and
  show one short `文件或文件夹不可用` toast.
- A cancelled or superseded link resolution must not open an overlay.
- The preflight must not serialize independent file and directory probes when
  doing so would add avoidable latency.
- Unsupported-but-existing files keep their existing preview or download
  fallback; they are not treated as missing.

## Out of scope

- Making the workspace writable.
- Changing how valid Markdown, code, image, SVG or download-only files render.
- Persisting workspace file paths in public logs or diagnostics.
