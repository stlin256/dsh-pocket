# Turn file-change surfaces device E2E

Date: 2026-11-01

Status: implementation pending initial device run. No row may be marked Passed
without a physical HarmonyOS device.

Automated evidence in this change:

- Gateway model suite: 128 tests passed, including turn-change aggregation and
  source contracts for the final card, live pill, reusable bottom dock,
  read-only file opening and reduced-motion handling.
- `default` Release build: passed.
- `store` Release build: passed.
- Device evidence: unavailable for this run; every row remains Pending.

| ID | Scenario | Expected evidence | Status |
| --- | --- | --- | --- |
| TFC-01 | One successful single-file edit | Final turn card shows one file and exact `+/-`; tapping opens the read-only file preview | Pending |
| TFC-02 | Repeated edits to one path | Card still says one file and aggregates all line deltas | Pending |
| TFC-03 | One multi-file apply-patch | Card counts distinct files and shows deterministic first-three rows | Pending |
| TFC-04 | Failed, interrupted or denied edit | No file count, total or final card is shown for that operation | Pending |
| TFC-05 | More than three files | `再显示 N 个文件` expands and collapses with interruptible motion | Pending |
| TFC-06 | Live update | Running edit updates the centered pill and number-roll motion without shifting the composer | Pending |
| TFC-07 | Stop/cancel/error | Live pill hides promptly; final card state matches the turn outcome | Pending |
| TFC-08 | Attachment + live changes | Attachment strip, live pill, composer and safe area remain separate and fully reachable | Pending |
| TFC-09 | Return-to-bottom overlap | The floating circular control stays above the complete bottom dock and adds no permanent spacer | Pending |
| TFC-10 | Light/dark and reduced motion | Surfaces, outlines and semantic diff colors remain legible; motion resolves directly | Pending |
| TFC-11 | API 23 fallback | Full-width opaque bottom surface preserves hierarchy when material is unavailable | Pending |
| TFC-12 | Session switch/reconnect | No live summary leaks across sessions; final cards survive cached reopen | Pending |

