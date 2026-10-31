# Turn file-change surfaces requirement

Date: 2026-11-01

## User outcome

Every completed assistant turn that changed workspace files must end with a
compact change card in the transcript. During a running turn, the same
information must appear in a small live control immediately above the composer.
The live control hides when the turn completes or stops.

## Final turn card

- The card states how many distinct files were edited and shows aggregate
  `+added/-removed` line totals.
- It contains a readable, deterministic list of the changed files. The first
  three files are visible while collapsed; a row such as `再显示 22 个文件`
  expands the list.
- A file row opens that Host workspace file in the existing read-only native
  file preview.
- The card has no undo action and no separate `查看变更` action.
- The normal completed/stopped/failed state and final-answer copy action remain
  available without creating an extra footer row.
- The card supports light and dark themes and uses the compact DSH spacing and
  business glyph language.

## Live change control

- It appears only while a turn is running and has at least one successful
  explicit file mutation.
- It shows distinct file count and aggregate `+added/-removed` values.
- Numeric changes animate with a short vertical roll. The animation resolves
  directly when reduced motion is enabled.
- It uses an intrinsic, centered width and remains narrower than a full-width
  card.
- Completion, cancellation, failure settlement or stop hides it with the
  semantic disclosure motion.
- It never covers the selected-image/file attachment strip, the composer, the
  return-to-bottom control or the system gesture safe area.

## Bottom composition

- The composer area uses one reusable bottom-dock composition rather than
  independent absolute offsets.
- Attachment previews increase the dock's measured height and reserve space
  above the composer.
- The live change control sits above the attachment/composer content and below
  the return-to-bottom control.
- The return-to-bottom control never adds permanent bottom space because it is
  a floating overlay.
- API 26 may use a full-width translucent material/blur surface. API 23 keeps
  the same function and hierarchy with an opaque themed surface.

## Data and plugin

- Counts come only from successful edit/write operations with explicit diff
  data. Tool prose, file names in arbitrary output and failed/interrupted calls
  never create counts.
- Repeated edits to one path form one file entry and aggregate their line
  totals.
- The existing DSH event stream, native gateway projection and local transcript
  cache should be sufficient. Plugin changes are acceptable only if a concrete
  protocol gap is demonstrated.
- File preview stays read-only.

## Verification

- Add pure projection tests for success filtering, deduplication, multi-file
  patches, ordering, aggregate totals, running/final state and malformed data.
- Build `default` and `store` Release HAPs when shared ArkUI code changes.
- Add device E2E rows. They remain Pending until tested on a real device.

