# External link affordance specification

Date: 2026-11-01

## Model

`NativeInlineMarkdown` exports a pure helper that identifies links opened outside
the workspace:

- `http:` and `https:`;
- `mailto:` and `tel:`;
- other explicit non-file external URI schemes already accepted by
  `nativeLinkKind()`;
- never bare paths, fragment-only links or `dsh-resource://` links.

## Rendering

The helper adds one `ImageSpan($rawfile('dsh-icons/external-link-outline.svg'))`
immediately after every inline external `Span`. The image is 10-11 vp, centered
on the text baseline, uses the active link blue token through a drawing color
filter, and performs the same `open(run)` action as the label. No literal text
glyph or extra row is added.

The existing underline and link color remain on the label. Workspace links keep
their current styling without the marker.

## Verification

- Model tests cover HTTP, HTTPS, mail and telephone links, and reject workspace,
  fragment and ordinary text values.
- Source contracts verify the local SVG path, inline `ImageSpan`, color filter
  and click behavior.
- Both Release variants build.
- Device rows verify light/dark appearance, wrapping and external opening.

