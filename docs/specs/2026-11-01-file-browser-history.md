# File browser navigation history specification

Date: 2026-11-01

## History model

`NativeBrowserHistoryEntry` stores only:

- `kind`: `directory` or `file`;
- `path`: the workspace-relative path.

`NativeBrowserHistory` owns push and pop operations. It never stores directory
entries, file bytes or rendered Markdown. Existing account-scoped directory and
file caches remain the only owners of payload memory.

## Browser integration

Before opening a directory or file, the browser pushes the current location.
Before replacing one preview by another, it pushes the current preview path.
Header Back, preview Close and system Back all use the same `back()` operation
to pop the newest entry.

Only an empty history at the browser's opening directory arms the existing
two-activation exit confirmation. No Back action can bypass an active history
entry and close the browser.

## File links rendered inside previews

`NativeWorkspace` observes workspace-link publications while a browser root is
active. Instead of replacing that root overlay, it publishes one compact
browser-push request through AppStorage. `NativeFileBrowser` consumes that
request once and pushes the requested file or directory on its own history.

Requests for another Session are rejected. Invalid targets keep the existing
single unavailable-target message and do not alter history.

## Verification

- Model tests cover push/pop order, arbitrary depth, peek, clearing and compact
  entry shape.
- Source contracts verify browser forwarding, unified Back and absence of
  directory-list retention in history.
- Both Release variants build.
- Device E2E traverses directory -> README -> linked README/code/image ->
  directory and returns through the complete chain.

