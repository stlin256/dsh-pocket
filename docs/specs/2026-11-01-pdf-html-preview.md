# PDF and HTML preview specification

Date: 2026-11-01

## Descriptors

`nativeDocumentDescriptor()` adds:

- `pdf`: kind `pdf`, no mode toggle;
- `html` / `htm`: kind `html`, language `html`, default mode `preview`, toggle
  enabled and preview supported.

The shared eye/code segmented control remains 82 vp wide and uses the existing
sliding highlight.

## PDF

PDF loading uses `NativeFileTransfer.readComplete()` with a 64 MiB ceiling and
the versioned `statFile()` identity. Bytes are written to a unique app-cache
file. `fileUri.getUriFromPath()` supplies the sandbox URI to
`filePreview.canPreview()` and `filePreview.openPreview()`.

After a successful load, the reader opens the system PDF preview. The native
reader remains mounted underneath with a compact `打开预览` retry action and the
shared top copy/download/close toolbar.

## HTML source and assets

HTML preview reads at most 8 MiB of complete source and shares a 32 MiB asset
budget. Asset resolution accepts workspace-relative paths and
workspace-root-relative paths. It rejects traversal outside the workspace,
Internet URLs, data/blob/fragment URLs and malformed paths.

The resolver supports:

- `link[rel=stylesheet]` and nested CSS `url(...)` references;
- `script[src]`;
- `img[src]`, `source[srcset]`, `video[poster]` and media `src`;
- `object[data]` and `embed[src]`;
- ordinary local anchors as native workspace-file navigation.

At most 32 assets are fetched. Text and base64 payloads are bounded before
inlining. A missing or oversized optional asset is replaced with an inert empty
value and does not fail the main document. Absolute HTTP(S) assets are left
unchanged; absolute HTTP(S) anchors open in the system browser. The app does not
fetch arbitrary Internet resources with workspace credentials.

## Web surface

`NativeHtmlPreview` uses one ArkWeb controller and
`loadData(html, 'text/html', 'UTF-8', safeBaseUrl)`. It disables file access,
uses automatic dark mode without forced darkening and does not expose a
JavaScript proxy. Local navigation is rewritten to an app-only scheme and is
intercepted by the component.

The generated document always includes a responsive viewport and
no-referrer policy while preserving document-authored styling.

## Read-only and download

Preview code never writes to the workspace. The existing top download action
uses the system save picker and the current file bytes. Cache materializations
are app-private and removable through Storage Management.

## Verification

- Model tests cover descriptors, relative path resolution, CSS URLs, rewrite
  ordering, srcset parsing, traversal rejection and output safety.
- Source contracts verify Preview Kit usage, bounded reads, local Web loading
  and shared download controls.
- Both Release variants build.
- Device E2E checks PDF, HTML with CSS/image/script references, source toggle,
  internal links and download.

