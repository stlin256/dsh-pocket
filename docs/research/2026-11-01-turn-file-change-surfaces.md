# Turn file-change surfaces research

Date: 2026-11-01

## Upstream baseline

The pinned upstream revision is
`f3803c96974ad4a94195fb97e5c637e9c2a3afe3`
(`0.2.2-alpha.2`). Relevant behavior is documented in
[`upstream-chat.md`](upstream-chat.md):

- `write`/`edit`/`apply_patch` records are successful only when the tool
  lifecycle is settled and the result is not failed, interrupted or denied.
- The preferred diff source is explicit `meta.diffs`, patch or
  `oldText/newText` data. Output prose is not evidence of a file mutation.
- `turn/end` owns turn completion and the transcript's turn-tail actions.
- `packages/client/ui-chat/src/client/chat/TurnTailNodeView.tsx` places
  turn-local actions in one tail. It does not itself invent file totals.

The official UI is a useful placement and ownership reference. Aggregating all
file mutations into a native per-turn card and live composer-adjacent control
is a DSH Harmony mobile extension and must not be presented as unchanged
upstream UI.

## Current native data path

1. `gateway/src/native-protocol.mjs` normalizes durable `tool/call`,
   `tool/result` and `turn/start`/`turn/end` events while retaining call
   identity, raw arguments, result/meta/content and turn/step numbers.
2. `NativeSessionModel.ets` pairs call and result rows by `callId`, preserves
   streamed tool arguments, tracks settlement and persists the projected
   transcript.
3. `NativeTranscript.ets` groups completed operations into process rows and
   emits one `turn-footer` for `turn/end`.
4. `NativeDiff.ets` already parses explicit `diffs`, patch/text diff and
   `oldText/newText` fields. It returns line rows plus added/removed counts and
   refuses failed, interrupted, denied and arbitrary-looking output.
5. `NativeToolCallView.ets` currently renders one file-mutation diff inside its
   individual operation view.

The missing layer is not transport data. It is a deterministic turn projection
that walks successful edit/write operations, separates multi-file diff rows by
path, deduplicates repeated paths and accumulates a stable summary.

## Plugin assessment

No DSH plugin change is required for this feature:

- The Harness journal already exposes explicit mutation arguments and results.
- The gateway already retains the fields needed by `NativeDiff.ets`.
- `turn/end` already marks the live/final boundary and the current client cache
  already persists paired rows.

Adding another plugin event would duplicate the authoritative journal, enlarge
the wire payload and create reconciliation risk. File contents remain fetched
on demand by the existing authenticated workspace operation.

## Projection semantics

- Process only projected tools whose exact category is `edit` or `write`.
- Require a settled successful tool result.
- Run the existing `nativeDiff()` parser as the single source of truth.
- Split a combined diff document on `path` rows so one apply-patch call can
  contribute several files.
- Normalize slash direction for identity, preserve the Host path for opening,
  and use a case-sensitive path key because Host filesystems may be
  case-sensitive.
- Merge repeated edits by first appearance. Sum their line totals.
- Preserve first-seen file ordering and call order.
- A turn summary exists only when there is at least one file.
- Running means a live turn has no matching `turn/end`. Historical rows without
  a loaded footer are not enough to show the live control; the workspace also
  requires the session's current running/waiting state.

## Composer composition

The current composer measures its own height and positions the attachment strip
with a translated overlay. That makes independent overlays fragile. The safer
model is a natural vertical stack measured as one bottom dock:

```text
floating return-to-bottom control
live turn-change pill
attachment strip
composer
safe-area inset
```

Only the composer dock consumes layout height. The return control and the live
pill remain overlays/flexible transient controls. The dock surface can extend
to the full window width while its content keeps the existing 12vp reading
inset. API 26 material is a progressive enhancement; API 23 uses the theme
surface.

