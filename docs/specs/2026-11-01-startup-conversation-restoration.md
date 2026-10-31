# Restored conversation startup specification

Date: 2026-11-01

## Readiness contract

`NativeWorkspace` exposes an idempotent `onWorkspaceReady` callback. Readiness is
reached only after initial navigation chooses one of these final states:

1. a valid remembered conversation has been selected;
2. no valid remembered conversation exists and the drawer is opened;
3. session resolution failed and a recoverable error surface is ready.

The callback is scoped to the current workspace generation and cannot fire from
a stale reload.

## Launch sequencing

For native mode, successful gateway connection mounts `NativeWorkspace` behind
the opaque launch surface with phase `entering` and opacity `1`. The surface
does not begin fading until `onWorkspaceReady` fires. Compatibility mode keeps
the existing post-connect handoff because its Web surface has its own load
completion.

`finishLaunch()` remains responsible for fade, timers and phase transition; only
its trigger changes.

## Workspace first paint

The no-selection starter surface is not shown while cached sessions exist and
the remembered route is unresolved. The workspace retains its restoring state
until the route choice is complete. Setting `loading = false` before route
resolution is prohibited.

If the route is unavailable, its metadata is forgotten and the drawer opens
only after the choice is final. The workspace then reports readiness.

## Verification

- Source contracts verify the callback prop, connect gating, delayed
  `loading = false`, and use of the route-before-starter ordering.
- Model tests keep launch phase decisions deterministic.
- Both Release variants build.
- Device E2E starts from a completed conversation several times and checks the
  first visible frame after automatic login.

