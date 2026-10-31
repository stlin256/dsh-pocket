# Navigation, motion and return polish implementation spec

Status: implementation contract. Device evidence belongs in the matching E2E
document and must not be inferred from source changes.

## Navigation ownership

`NativeWorkspace` owns the native session drawer. Opening Settings through its
gear keeps `showSessions` and the drawer translation unchanged while
`pages/Index.ets` raises the Settings layer. Closing Settings only lowers that
layer, so the same drawer instance becomes visible again. The Settings return
stack is unchanged.

Conversation exit confirmation remains in `Index.confirmChatExit()`. File
browser root exit confirmation remains in `NativeFileBrowser.systemBack()`.
Both continue to use a two-second, two-gesture window and terminate or close
only on the second gesture.

## Return-to-bottom motion

The transcript remains a virtualized `List` bound to `Scroller`. With motion
enabled, `returnToBottom()` calls `scrollEdge(Edge.Bottom, { velocity: 6000 })`
once.
The edge API performs an inertial travel to the last mounted tail on List
surfaces; no timed `scrollEdge` follows it. `onScroll` and `onScrollStop` settle
state from the actual scroller position. A touch during travel clears the
pending timer, disables returning state and restores manual scrolling.

Reduced motion resolves directly to the tail with a non-animated index/edge
move. A bounded final-position guard may settle flags after the movement, but
must never animate a second positional jump.

## Disclosure motion

`NativeMotion` owns a `disclosure` semantic. It uses a damped spring with no
decorative loop. Process groups, direct process steps, generic tools, nested
tools, diffs, workspace groups and the task dock call this semantic instead of
using unrelated `micro`, `surface` or immediate boolean updates.

Chevrons, preview fading and inserted detail surfaces derive their implicit
animation from the same disclosure parameter. The spring response is `0.21`,
half of the original `0.42` calibration, while preserving damping and nonlinear
deceleration. Reduced motion returns a zero-duration parameter and executes
state changes directly.

The conditional task dock mount is committed inside disclosure motion and
carries a disclosure transition. Subsequent updates to an already-present plan
do not replay that entrance.

Opening/sync progress is a 14vp indicator adjacent to the existing title in the
36vp title row. It replaces the former conditional progress row below the title,
which changed vertical layout and displaced the dock when it appeared/disappeared.

`NativeDiffBlock` keeps the path, line-number toggle, copy action and optional
Diff expansion affordance. It no longer renders the `drag-handle-outline`
wrapping toggle that visually read as an unrelated hamburger button.

## File browser navigation

`NativeFileBrowser` maintains a monotonically increasing request generation.
The first directory load may show the full reading state. Once content exists:

1. update the logical target path and start a small in-header progress state;
2. keep the previous entries visible with a subtle opacity change;
3. replace path, breadcrumb, entries and truncation only after the matching
   response succeeds;
4. restore the previous path and show a short toast if navigation fails;
5. ignore every response whose generation no longer matches.

Back remains available while a directory request is in flight. Preview state
continues to sit above directory navigation. The browser remains read-only.

## Image lightbox double tap

Zoom target and clamping live in a pure `NativeImageZoom` model so the behavior
is model-tested. At default scale, a deliberate double tap selects a 2.5x target
and calculates translation so the tapped content point moves toward the
viewport center, clamped to image bounds. At enlarged scale, it returns to 1x
and zero translation.

The existing pinch-synthetic-tap guard remains authoritative. The same target
calculation is available to attachment lightboxes and workspace image previews
where their touch models permit; attachment-lightbox behavior is required for
this batch.
