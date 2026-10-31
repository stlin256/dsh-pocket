# Conversation dock inset specification

Date: 2026-11-01

## Measurement

The conversation dock wrapper reports its actual height through `onAreaChange`
to `NativeWorkspace.conversationDockHeight`. The height includes collapsed or
expanded plan content. When no plan exists, the effective inset is zero even if
the last measured value remains retained.

## List contract

The transcript `List` calls `contentStartOffset()` on every render:

```text
taskPlan.items.length > 0 ? conversationDockHeight : 0
```

The List itself remains mounted in the same `Stack`; no spacer row, translated
content or duplicate lazy item is introduced. The inset affects only the
scrollable content start, so the first conversation item is immediately below
the measured dock at the top edge.

The existing history button remains part of the scroll content and follows the
same inset. The dock keeps its current overlay z-order and movement tokens.

## Verification

- Source contracts verify measurement, conditional offset and no spacer item.
- The height and plan lifecycle tests remain green.
- Both Release variants build.
- Device E2E checks collapsed and expanded docks at initial load, first-message
  top and while history is loading.

