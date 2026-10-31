# Rendering, navigation and startup E2E

Date: 2026-11-01

Status: implementation complete pending user device verification.

| ID | Scenario | Expected result | Result |
|---|---|---|---|
| EXT-01 | Open a conversation containing HTTP, HTTPS and mail links in light mode | Each label is blue/underlined and has a compact external-link SVG; tapping either label area or icon opens the external target | Pending |
| EXT-02 | Repeat EXT-01 in dark mode and on a link-heavy paragraph | Marker remains blue, aligns with text, wraps without an extra row and has no dark glyph edge | Pending |
| EXT-03 | Open a workspace path and a Markdown fragment | Neither receives the external-link marker | Pending |
| START-01 | Complete a conversation, terminate the app and reopen with automatic login ten times | The launch surface transitions directly into that conversation; no starter/new-conversation frame appears | Pending |
| START-02 | Open after the remembered conversation is archived on another client | Launch resolves to the session drawer or a stable error state without the old conversation flashing | Pending |
| DOCK-01 | Open a conversation with a collapsed task-plan dock | The first row and history-loading control begin immediately below the measured dock with no blank strip | Pending |
| DOCK-02 | Expand and collapse the task-plan dock while at the first row | Inset follows the rendered dock height; content remains reachable and the dock never covers it | Pending |
| BROWSER-01 | Open browser -> nested directory -> README -> linked README | Each transition enters the browser history; preview content remains readable | Pending |
| BROWSER-02 | From BROWSER-01 press system Back repeatedly | Returns linked README, README, nested directory and opening directory in reverse order; chat is not exposed early | Pending |
| BROWSER-03 | Build a long chain of 20 directory/file transitions and return | All transitions replay from compact path history without retaining directory payloads or crashing | Pending |
| BROWSER-04 | At the opening directory press Back once then again within two seconds | First shows the existing exit hint; second closes the browser | Pending |
| PDF-01 | Open a PDF from chat and file browser | PDF opens in a readable preview; underlying reader keeps copy/download/close controls; Back restores the source | Pending |
| PDF-02 | Cancel the PDF system preview and use the native `打开预览` action | Preview can be reopened without another full remote transfer | Pending |
| HTML-01 | Open an HTML file referencing local CSS, image, script and nested CSS asset | Preview renders with those local assets; source/code toggle remains available | Pending |
| HTML-02 | Open HTML referencing a missing local asset | Main document still renders; missing optional asset does not replace the entire preview with an error | Pending |
| HTML-03 | Tap a local file anchor in rendered HTML | The target opens in the same browser/file history and Back returns to the HTML preview | Pending |
| HTML-04 | Tap an HTTP(S) anchor in rendered HTML | The target opens in the system browser without leaving the native file reader | Pending |
| FILE-01 | Download PDF and HTML from their preview toolbars | System save picker writes the current file version; workspace remains unchanged | Pending |
| REG-01 | Open Markdown, SVG, image, source, directory and Markdown table links after the changes | Existing native previews and navigation still work in light/dark modes | Pending |

