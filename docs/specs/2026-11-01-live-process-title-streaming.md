# Live process, title and streaming implementation spec

## 1. Projection fields

Add `NativeMessage.currentTurn`. In `nativePresentTranscript`, derive the one
current process group from the last process row whose `turnKey` is not present
in the `ended` set. Set `currentTurn` only on that group.

This field is presentation-only. It must not affect grouping, manual disclosure,
history identity or cache serialization.

## 2. Process expansion

`NativeProcessView` resolves its initial expansion in this order:

1. verbose/flat presentation or showcase override;
2. saved manual disclosure;
3. `currentTurn`.

A manual disclosure wins for the lifetime of the same disclosure key. When a
new key becomes current, or when `currentTurn` changes, the view updates without
requiring the user to tap it. Switching to another key resolves the new key
independently. No entrance animation is added to streaming content rows.

## 3. Terminal card follow-through

`NativeTurnChangesCard` exposes `onExpandedChange(expanded)`. The callback is
committed in the same `NativeMotion.disclosure` action as the card state.

The transcript owner follows only when all conditions hold:

- expansion is opening;
- the card is the final visible transcript row;
- its visible rectangle is inside the bottom near-tail zone;
- no modal menu is open.

The owner sets `returningToBottom`, schedules one post-layout
`scrollEdge(Edge.Bottom, { velocity })`, and settles the tail state when the
scroll stops. Opening a middle card or collapsing any card does not scroll.
Reduced motion resolves the card expansion and scroll to the final state.

## 4. Streaming scheduler

- Keep `NativeSessionModel.apply` synchronous for every socket frame so cursor,
  revision and gap validation remain exact.
- Coalesce visual paints at 16ms, giving the renderer one chance per 60Hz frame
  while still combining bursts.
- Cache the expensive `nativeTranscript` result for the current durable
  `model.messages` array. A text-only stream delta clones the cached projection
  and replaces only its live assistant row. Reasoning/tool streams continue
  through the full projector because their grouping can change.
- Record whether the pending batch contains only assistant text. Once a live
  assistant row exists, later text-only deltas patch that row even when the same
  turn still carries completed reasoning or tool rows. Any structural frame
  invalidates the fast path so the next paint performs a complete projection.
- Add no animation to token text updates or ordinary tail appends.
- Gateway delivery uses 256 KiB high and 64 KiB low watermarks on
  `bufferedAmount`. WebSocket writes remain ordered, while the source pauses
  only when the socket buffer is saturated. Terminal/error frames retain their
  write-completion promise so they are not dropped when the connection closes.

## 5. Markdown work reduction

- `nativeMarkdownTable` returns immediately when the source has no table pipe or
  no second line.
- `nativeInlineMarkdown` returns one plain run when the source has no Markdown
  control character. Existing behavior remains for syntax-bearing text.

## 6. Live title

The live adapter forwards bounded, sanitized `title` projection updates as:

```json
{ "type": "title", "title": "..." }
```

It reads both modern `session/observeProjections` and legacy
`session/control` baseline/projection shapes. The client accepts `title` on
`NativeFrame`, applies it only for the selected session, updates the matching
session row and current header, and returns before transcript/cache work.

Titles are trimmed and capped at the existing 160-character boundary. Empty or
malformed values are ignored.

## 7. Tests

- Model/source contracts cover current-turn selection, manual disclosure
  precedence, terminal-card callback placement, 16ms visual coalescing, Markdown
  fast paths and title frame handling.
- Gateway WebSocket tests cover initial and updated title projections in both
  modern and legacy paths, plus malformed value rejection.
- Existing stream ordering, Unicode, settlement, history and reconnect tests
  must remain green.
