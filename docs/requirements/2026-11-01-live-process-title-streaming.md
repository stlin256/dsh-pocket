# Live process, title and streaming refinement

## User requirement

- While a conversation is running, the latest active `工作过程` group starts
  expanded. Historical groups keep the normal transcript presentation policy.
  Manual collapse remains available and must not be undone by later stream
  frames from the same turn.
- When a completed-turn `已编辑 N 个文件` card is the final transcript row and
  the user is already near the bottom, expanding the card follows the growing
  layout down to the real bottom with nonlinear motion. The card expansion and
  list follow-through should read as one movement.
- Expanding the same card from the middle of the transcript must preserve the
  current reading position.
- Streaming prose must feel immediate and smooth. The client must batch work at
  display-frame frequency without re-projecting historical rows or re-parsing
  unchanged Markdown on every token.
- A newly generated session title must appear in the conversation header and
  session surfaces as soon as the Host projects it, without manually refreshing
  the session list or reconnecting.
- Notification, history ordering, stream gap detection and durable settlement
  semantics remain unchanged.

## Acceptance criteria

- A new active process group is open before the first tool result arrives.
- Closing the active group stays closed until the user opens it or a different
  turn becomes active.
- The latest finished turn no longer remains automatically open merely because
  a presentation delay marked it deferred.
- Expanding a terminal edited-files card near the bottom ends with the expanded
  card fully visible above the composer; expanding a middle card does not move
  the viewport.
- Delta frames are applied in wire order, while visual paints are coalesced to
  one update per display frame.
- Plain streaming prose does not execute the full Markdown table or inline
  scanner when the text contains no relevant syntax.
- A `title` projection frame updates the active title immediately and cannot
  apply to a different selected session.
