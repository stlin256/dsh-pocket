# Navigation, motion and return polish E2E

Target device: `33Z0224801015621`

| ID | Action | Expected result | Status |
| --- | --- | --- | --- |
| RET-E2E-01 | Open drawer, open Settings, then return from Settings root | The drawer is still open in its prior state; chat is not exposed directly | Pending |
| RET-E2E-02 | Enter a Settings child, press Back, then close Settings root | Back returns to Settings root; closing root restores the open drawer | Pending |
| RET-E2E-03 | In a selected chat press system Back once, wait under two seconds, press again | First shows `再次返回退出App`; second exits the app | Pending |
| RET-E2E-04 | In a selected chat press Back once and wait over two seconds | App stays open; another Back starts a new confirmation window | Pending |
| RET-E2E-05 | At file-browser workspace root press Back once, then again | First shows `再次返回退出文件浏览`; second closes only the browser | Pending |
| RET-E2E-06 | In a nested file-browser folder press Back | Returns to the parent without an exit toast | Pending |
| MOT-E2E-01 | Scroll away from a long conversation tail and tap the circular bottom control | Travel starts immediately, decelerates into the tail and does not make a final snap | Pending |
| MOT-E2E-02 | Trigger return-to-bottom and touch the transcript during travel | Automatic travel cancels and the transcript follows the finger | Pending |
| MOT-E2E-03 | Expand and collapse process groups, steps, tool calls, nested tools, diffs, workspace groups and task plan | Each moves with the same nonlinear disclosure motion in both directions and remains interruptible | Pending |
| MOT-E2E-04 | Repeat MOT-E2E-01 through MOT-E2E-03 with reduced motion enabled | All final states resolve without non-essential motion | Pending |
| MOT-E2E-05 | Let a response create its first task plan after chat is already visible | The task dock enters with disclosure motion rather than mounting abruptly | Pending |
| MOT-E2E-06 | Expand and collapse the task dock and process disclosures | Both complete crisply at the 50% faster calibration while retaining a decelerating finish | Pending |
| MOT-E2E-07 | Open a session with a task dock and observe opening/sync progress start and finish | The compact progress indicator stays in the title row; the dock and transcript do not move vertically | Pending |
| DIFF-E2E-01 | Expand a modified-file process item | Its toolbar contains no hamburger/wrap button; line numbers, copy and Diff expansion remain usable | Pending |
| FILE-E2E-01 | From a populated folder open a child folder and immediately navigate Back | Existing rows remain visible throughout; no full-screen spinner replaces them | Pending |
| FILE-E2E-02 | Repeatedly tap breadcrumbs or parents faster than responses complete | The final selected directory wins; no stale listing appears afterward | Pending |
| FILE-E2E-03 | Navigate to a directory that fails | The previous readable listing remains and a short failure message appears | Pending |
| ZOOM-E2E-01 | Double-tap a default-size image near an off-center detail | Image enlarges around that point rather than always at its center | Pending |
| ZOOM-E2E-02 | Double-tap the enlarged image | Image returns smoothly to default scale and center | Pending |
| ZOOM-E2E-03 | Pinch, pan, double-tap, tap outside and long-press | Existing pinch, pan, dismissal and save behavior remains intact; post-pinch synthetic taps do not zoom/reset | Pending |
| THEME-E2E-01 | Repeat navigation, file browser and lightbox checks in light and dark modes | Surfaces, text, controls and progress feedback remain legible with no black-edge regressions | Pending |
