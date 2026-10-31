# Live process, title and streaming research

## Process disclosure

- `NativeProcessView` initializes expansion from `message.flat`, the showcase
  override or a saved manual disclosure. A standard running group is therefore
  closed until tapped.
- `nativePresentTranscript` has an `ended` set and currently marks
  `runningTurn` true for an unended turn or a deferred older turn. That field is
  also used by the `next-input` presentation policy, so it cannot by itself
  identify the one current process group.
- Upstream DSH `detailed` mode flattens a running process group. The mobile
  client still needs a separate presentation rule for the current group because
  compact and standard remain selectable.

## Terminal edited-files card

- `NativeTurnChangesCard` animates only its local `expanded` state.
- The transcript List is owned by `NativeWorkspace`; the card has no event that
  lets the list owner decide whether to follow the newly increased height.
- `Scroller.isAtEnd()` detects the exact tail. A new helper is needed for the
  requested near-tail zone and for identifying that the card is the final row.
- HarmonyOS 12+ `scrollEdge(Edge.Bottom, { velocity })` provides nonlinear,
  velocity-based movement for `List`; it must start after the expanded layout
  has been committed.

## Streaming

- Every socket message is reduced synchronously, which is correct for cursor,
  revision and gap checks.
- Visual work is delayed by a fixed 40ms timer in `NativeWorkspace`, limiting
  updates to roughly 25 frames per second.
- Every paint calls `nativeTranscript` over the full loaded history, then
  computes turn changes, plan state and a full presentation pass.
- `NativeTextContent` calls `nativeMarkdownTable` for every text update.
  `NativeInlineText` runs the full inline scanner for every text update.
- `NativeListSource` compares up to the last 16 rows by serializing their full
  objects. Large cumulative streamed text therefore creates avoidable main-thread
  work even though most durable rows did not change.
- The safest latency improvements are display-frame coalescing, reuse of the
  projection for unchanged durable records, fast no-syntax Markdown paths and
  avoiding per-token decorative animation. Wire ordering and gap detection must
  stay synchronous.

## Session title

- The title is read correctly at initial `session/list`.
- The live adapter opens `session/observeProjections`, but forwards only
  `userQuestions`. `title` projection updates are discarded.
- The modern `session/control` fallback reads the baseline only for questions;
  it similarly ignores the title projection.
- The Host already exposes title through the existing projection stream, so no
  new privileged API or plugin credential is required.

## Upstream reference

The pinned DSH revision is recorded in `docs/NATIVE-INTERACTION-SPEC.md`.
Its presentation model treats the current running turn as live while completed
turns return to the selected transcript policy. Chat activity remains driven by
the latest still-running operation; streamed prose itself must not create
decorative disclosure or row motion.
