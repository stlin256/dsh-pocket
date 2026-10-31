# Rendering, navigation and startup refinement requirements

Date: 2026-11-01

## External link affordance

- `EXT-01` HTTP, HTTPS, mail, telephone and other externally opened links in
  rendered chat text show a compact external-link SVG after the link label.
- `EXT-02` The marker uses the DSH blue link color in light and dark themes and
  is clickable as part of the same link action.
- `EXT-03` Workspace file links and internal document anchors do not receive the
  external-link marker.

## Restored conversation startup

- `START-01` When a previous valid conversation is available, automatic login
  restores that conversation without exposing the empty/new-conversation
  surface for even one visible frame.
- `START-02` The launch surface remains visible until the native workspace has
  resolved either the remembered conversation or the current session list.
- `START-03` When no conversation can be restored, the workspace opens the
  session drawer after session resolution instead of flashing a starter page
  under the launch surface.

## Conversation dock inset

- `DOCK-01` While a conversation dock is visible, the transcript content start
  is inset by the dock's measured rendered height.
- `DOCK-02` At a genuinely empty, loading or first-message top position, the
  first visible content begins immediately below the dock without extra blank
  space.
- `DOCK-03` Collapsed and expanded dock heights participate in the inset so the
  expanded plan cannot cover the first conversation row.

## File browser history

- `BROWSER-01` Directory changes, file previews opened from the browser and
  workspace links opened inside a rendered file preview form one navigation
  history.
- `BROWSER-02` Back from a nested file preview returns to the previous preview
  or directory, including arbitrarily deep chains of files and directories.
- `BROWSER-03` Back inside a file browser never falls through to chat while the
  browser history still has an entry. At the opening directory, existing
  two-step exit confirmation remains in effect.
- `BROWSER-04` History retains only compact path/type descriptors. Directory
  listings and file payloads remain owned by the existing bounded caches.

## PDF and HTML preview

- `PREVIEW-01` PDF files open in a readable preview without being treated as an
  unknown binary.
- `PREVIEW-02` HTML files open in rendered preview mode by default and can switch
  between rendered preview and highlighted source through the shared
  eye/code segmented control.
- `PREVIEW-03` Relative and workspace-root HTML references to stylesheets,
  scripts, images, media and fonts are read through the authenticated,
  session-scoped workspace API where possible.
- `PREVIEW-04` Referenced resources are bounded by count and byte limits. A
  missing or oversized optional resource cannot prevent the main document from
  rendering.
- `PREVIEW-05` Links from rendered HTML to workspace files use the native file
  navigation history; external HTTP(S) links open outside the app.
- `PREVIEW-06` Every PDF/HTML preview retains the shared top download action and
  the workspace remains strictly read-only.

