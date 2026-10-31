# Navigation, motion and return polish requirement

Status: accepted for implementation on the target phone.

## Drawer-to-settings continuity

- `NAV-RET-01` Opening Settings from the session drawer must leave the drawer
  logically open underneath the Settings surface. Closing Settings restores the
  same drawer state instead of removing the drawer and revealing chat.
- Returning from a Settings child page still returns to the Settings root.
  System Back and the page-level return affordance continue to share that stack.

## Intentional exit confirmation

- `RETURN-01` In a selected conversation, the first system Back gesture shows
  `再次返回退出App`. A second Back gesture within two seconds exits the app.
- `RETURN-02` At the workspace root in the file browser, the first system Back
  gesture shows `再次返回退出文件浏览`. A second gesture within two seconds
  closes the browser.
- `RETURN-03` Folder navigation continues to consume Back by returning to the
  parent directory. File previews consume Back before the browser directory.

## Nonlinear motion

- `MOT-RET-01` Returning to the conversation tail starts immediately, advances
  with a decelerating curve, and settles at the bottom without a second abrupt
  jump. It uses the fast travel requested for practical long transcripts.
- `MOT-RET-02` A touch during return-to-bottom cancels automatic travel and
  restores direct user control.
- `MOT-RET-03` Process steps, tool calls, nested calls, diffs, workspace groups
  and the task dock use one semantic disclosure motion. Expansion and collapse
  are interruptible, use nonlinear deceleration, and resolve immediately when
  reduced motion, background execution or power saving applies. Its response is
  50% faster than the original disclosure calibration.
- `MOT-RET-04` A task plan dock that becomes present after the conversation is
  already visible enters with the disclosure semantic instead of mounting
  abruptly. Later task-state updates remain direct.
- `MOT-RET-05` Conversation opening/sync progress appears inside the existing
  title row. Its presence or disappearance must not change title-bar height or
  move the floating task-plan dock.
- `DIFF-RET-01` Expanded file-change views expose only meaningful controls:
  line numbers, copy and Diff expansion. The extra hamburger-style wrap toggle
  is removed.

## File browser continuity

- `BROWSER-RET-01` Entering a folder, returning to a parent, using a breadcrumb
  and returning to the root must preserve the existing directory content while
  the next listing is pending.
- `BROWSER-RET-02` Navigation feedback is compact and in place. A full-screen
  spinner must not replace an already loaded directory.
- `BROWSER-RET-03` Stale requests cannot overwrite a newer directory selection.
  A failed navigation keeps the previous readable directory and reports the
  failure without destroying its content.

## Image lightbox zoom

- `ZOOM-RET-01` Double-tapping the contained image at default scale zooms in
  around the tapped point.
- `ZOOM-RET-02` Double-tapping again while enlarged returns smoothly to the
  default scale and centered position.
- `ZOOM-RET-03` Pinch, pan, outside-tap dismissal and long-press save retain
  their existing behavior. A platform-synthesized tap after pinch must not
  trigger an accidental zoom or reset.
