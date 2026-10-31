# Chat Link Existence Preflight Specification

Date: 2026-10-31

## Resolution contract

`NativeInlineText` resolves a linked target with `nativeFileTarget` using the
current Session cwd. Tapping a link creates a request id before network work
starts. The request id remains private to the app process and is used only to
reject stale asynchronous completions.

The resolver runs the exact file stat and exact directory listing from the same
link state:

1. `workspaceFiles/stat` confirms a regular file.
2. `workspaceFiles/list` confirms a directory.
3. The two probes start without waiting for one another.
4. A regular-file result wins and publishes `kind = file`.
5. Otherwise, a successful directory result publishes `kind = browser`.
6. If both exact probes fail and the original link is a bare filename, the
   existing bounded `findWorkspaceFile` lookup may produce a confirmed file.

The resolver never publishes a preview solely because the path syntax is
plausible. A target that is neither a confirmed file nor a confirmed directory
returns no view request.

## User-visible states

- A valid file opens `NativeFilePreview`.
- A valid directory opens `NativeFileBrowser`.
- A missing or unavailable target leaves the current chat in place and shows
  the toast `文件或文件夹不可用`.
- A preview or browser request superseded by another tap, navigation or close
  is ignored.
- Content-level failures after a confirmed file opens remain owned by the
  preview surface. In particular, a confirmed non-text binary may still show
  `此文件仅支持下载`.

## Latency

The exact-file and exact-directory probes overlap. A bare-file fallback starts
only after both exact probes fail. This keeps the common file and folder paths
to essentially one backend round-trip sequence while preserving bounded search
for model-emitted basenames.

No loading cover is mounted during preflight. The app avoids a misleading
preview flash for missing targets and opens the correct root surface as soon as
the type is confirmed.

## Failure ownership

Preflight failures are chat-level navigation failures and are shown as one
short toast. Rendering failures for an existing file stay inside
`NativeFilePreview` with its retry or download affordance. Gateway responses
continue to expose stable `workspace-file/*` codes; raw server details are not
shown to the user.

## Verification

- Source and model tests assert that no `nativeFileViewRevision` is published
  before file or directory confirmation.
- The tests cover exact file success, exact directory success, basename fallback
  and both-probes-failed behavior.
- Existing gateway tests continue to cover authenticated file stat, listing and
  stable workspace-file errors.
- Both Release product variants are built after the shared ArkUI change.
