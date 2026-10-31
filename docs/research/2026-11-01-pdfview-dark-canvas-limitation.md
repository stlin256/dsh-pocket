# PDFKit Dark Canvas Limitation

Date: 2026-11-01
Status: accepted implementation limitation; revisit after a PDFKit update

## Observed behavior

On the tested HarmonyOS device, `PdfView` keeps its internal page canvas white
in dark appearance even when the component and surrounding reader container
receive the dark theme background.

Applying PDFKit `PresetRenderMode.DARKMODE` through `PdfController.setRenderMode`
changes authored document colors, but it does not darken the internal canvas.
This produces content inversion without solving the requested container color,
so the preset must remain disabled.

## Current decision

- Preserve authored PDF page colors and document fidelity.
- Keep the surrounding native reader container theme-aware.
- Do not use `PresetRenderMode.DARKMODE` as a workaround.
- Keep `PDF-03` pending in the device E2E table until a future PDFKit release
  provides a reliable themed canvas.

## Revisit criteria

Reopen this investigation when the pinned HarmonyOS SDK or device PDFKit version
changes. A replacement implementation is acceptable only when:

1. The internal canvas follows light and dark appearance immediately.
2. Switching appearance with a document open does not reload the PDF.
3. Authored PDF colors do not invert or otherwise change unexpectedly.
4. Existing zoom, drag, scroll, download and close behavior remains intact.
