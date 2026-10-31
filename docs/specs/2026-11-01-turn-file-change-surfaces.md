# Turn file-change surfaces implementation spec

Date: 2026-11-01

Requirement:
[`2026-11-01-turn-file-change-surfaces.md`](../requirements/2026-11-01-turn-file-change-surfaces.md)

Research:
[`2026-11-01-turn-file-change-surfaces.md`](../research/2026-11-01-turn-file-change-surfaces.md)

## 1. Data contract

Add a pure ArkTS projection in `NativeTurnChanges.ets`:

```ts
class NativeTurnFileChange {
  path: string
  added: number
  removed: number
}

class NativeTurnChangeSummary {
  turnKey: string
  files: NativeTurnFileChange[]
  fileCount: number
  added: number
  removed: number
  running: boolean
  outcome: string
}

function nativeTurnChanges(rows: NativeMessage[]): NativeTurnChangeSummary[]
```

Rules:

1. `nativeTurnChanges` accepts the already paired `nativeTranscript()` rows.
2. It visits process children in source order and accepts only root or nested
   `role === 'tool'` rows whose `nativeToolCategory(name)` is `edit` or `write`.
3. `phase === 'result'` or `status === 'success'` is required.
4. `nativeDiff(tool)` must return a matched document with at least one added or
   removed row.
5. A combined diff is partitioned at `row.kind === 'path'`. Context rows between
   path markers belong to the preceding path.
6. Empty paths are ignored. Existing path spelling is retained for display and
   opening; slash normalization is used only for deduplication and lookup.
7. Repeated paths merge into the first occurrence and add their deltas.
8. A `turn-footer` closes the turn and supplies the outcome.
9. Summary order follows first turn appearance and file first appearance.
10. The projection never mutates `NativeMessage`, journal data or cache rows.

The workspace derives and stores:

- `turnChanges`: tool-derived fallback summaries keyed by stable `turnKey`.
- `officialTurnChanges`: validated stopped-turn summaries keyed by the latest
  durable `workspace/changes` event sequence.
- `liveTurnChanges`: the newest summary with `running === true`, exposed only
  when the session is currently running/waiting.

The live projection accepts only a settled successful tool result. Preparing
and running arguments are intent and may still be denied, interrupted or fail.
Activity state invalidates live visibility even when tool rows and footer
identity are unchanged.

## 2. Official stopped-turn summary

The gateway adds a read-only authenticated route:

```text
GET /pocket/api/native/changes/summary?sessionId=<id>&seq=<eventSeq>
```

It fetches DSH's `/api/changes.summary` with the Host-held cookie, validates and
forwards only `turn`, `total`, `added`, `deleted`, and bounded
`files[{path,display,added,deleted,binary?,oversized?}]`. It never forwards
`cwd` or snapshot identities.

The client parses loaded journal entries for `workspace/changes`, keeps the
highest event sequence for each turn, and loads summaries with at most three
requests in flight. A summary for an obsolete sequence is ignored. Completion
cards prefer the official summary; an unavailable, malformed or older-Host
response keeps the successful-tool fallback.

## 3. File preview

`NativeTurnChangesCard` receives an `onOpenFile(path)` callback. The workspace
resolves paths with the existing `nativeFileTarget(path, workspaceRoot)` rule
and opens the existing `NativeFileBrowser` in file mode. No new read/write API
is introduced.

## 4. Final transcript card

Render the card in the existing `turn-footer` ListItem when a summary exists.
For turns without file changes, keep the existing compact footer row.

The card:

- uses one rounded themed surface with a 0.5vp outline;
- puts an edit glyph, `已编辑 N 个文件`, aggregate numbers and the final-answer
  copy action in one header row;
- shows at most three file rows while collapsed;
- renders a `再显示 N 个文件`/`收起文件` control for larger sets;
- caps expanded contents to `min(260vp, 45% transcript viewport height)` in an
  internal vertical scroll;
- opens a file when its row is tapped;
- animates expansion with `NativeMotion.disclosure`;
- uses no undo action and no `查看变更` action.

## 5. Rolling number

`NativeRollingNumber` is a local presentational component. On a value change it:

1. holds the outgoing formatted value;
2. places the incoming value one small step below at low opacity;
3. runs a 170ms vertical roll/fade;
4. settles on the incoming value without a later layout jump.

With reduced motion or while backgrounded, the incoming value resolves
immediately. Accessibility reads the final numeric value, not the transient
layers.

## 6. Live bottom control

`NativeTurnChangePill`:

- shows edit glyph, `N 个文件`, `+A`, `-R`;
- uses intrinsic width with `maxWidth: min(360vp, viewport - 32vp)`;
- updates with the rolling number components;
- uses themed neutral fill, a fine outline and the DSH accent only for the
  glyph;
- is hidden when `liveTurnChanges` is absent, the session is no longer
  running/waiting, or the turn has a footer.

The conversation's bottom area is one natural-height reusable dock:

1. full-width dock surface and blur/material;
2. centered live change pill;
3. selected attachment strip;
4. composer;
5. safe-area bottom inset.

The return-to-bottom control remains an independent overlay immediately above
the bottom stack. It does not add layout height and does not overlap the live
pill, attachments or composer.

API 26 material is used only when `NativeExperience.materialsEnabled()`; API 23
uses the opaque themed surface.

## 7. Motion

- New live changes: `rowTransition` and numeric roll.
- Numeric changes: 170ms `FastOutSlowIn`; no loop.
- Live pill exit: disclosure/opacity transition.
- Card list expansion: `NativeMotion.disclosure`.
- File row press: existing immediate themed cup highlight.
- Streaming transcript rows receive no new item entrance animation.
- All motion resolves to the final state under reduced motion.

## 8. Correctness and performance

- Aggregate only when the transcript projection changes; do not parse diffs on
  every small streamed text delta unless the paired tool rows changed.
- Keep summary objects small: paths and counts only. Diff rows remain owned by
  the tool projection and are not duplicated into cache or network payloads.
- Final card expanded state is keyed by `turnKey` and remains stable across
  ordinary list refreshes.
- A history prepend preserves card identity through the existing footer ID.

## 9. Tests

Add pure-model tests for:

- one successful write/edit;
- repeated edits to one path;
- one apply-patch/multi-file diff;
- a failed, interrupted, denied or preparing tool excluded;
- a non-edit tool with diff-looking output excluded;
- stable file order and exact totals;
- final outcome copied from `turn/end`;
- running summary closed by `turn/end`;
- malformed diff data inert.
- preparing, running and failed mutations excluded from live totals;
- activity-only stop hides the live pill;
- latest `workspace/changes` sequence selected per turn;
- official summary validation, hostile-field stripping, bounded request
  concurrency and fallback behavior.

Add source-contract assertions for:

- footer card ownership and no undo/view-change actions;
- file-row callback to the existing preview;
- live pill hidden by running state/footer;
- intrinsic pill width and full-width bottom dock surface;
- return-to-bottom remains above the measured stack;
- reduced-motion handling.

## 10. Build and evidence

- Run Gateway model tests.
- Build `default` and `store` Release HAPs.
- Add device E2E rows and leave them Pending until a physical-device run.
- Do not claim device completion from a build or mock.

