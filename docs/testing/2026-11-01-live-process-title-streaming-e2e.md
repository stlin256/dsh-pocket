# Live process, title and streaming device E2E

| ID | Scenario | Expected | Status |
| --- | --- | --- | --- |
| LPS-01 | Start a tool-heavy turn in standard mode | Latest active `工作过程` opens automatically before the first result | Pending |
| LPS-02 | Collapse the active process group, then receive more deltas | The same group stays collapsed; a new turn may open independently | Pending |
| LPS-03 | Let the active turn finish | Historical disclosure returns to the configured policy after it is no longer current | Pending |
| LPS-04 | Open the final edited-files card near the bottom | Expansion and nonlinear tail follow-through end with the full card visible | Pending |
| LPS-05 | Open an edited-files card in the middle with several turns below | The card expands locally and the viewport does not move | Pending |
| LPS-06 | Collapse a terminal edited-files card near the bottom | It closes without forcing a tail scroll | Pending |
| LPS-07 | Stream a long prose answer containing no Markdown syntax | Text paints at display-frame cadence with no 40ms stepping or disclosure animation | Pending |
| LPS-08 | Stream Markdown headings, lists, links, fenced code and a table | Formatting remains correct while token latency stays perceptually continuous | Pending |
| LPS-09 | Generate a new session title during the first turn | Header and session row update without refresh, reconnect or route change | Pending |
| LPS-10 | Switch sessions while a title projection arrives | A late title cannot overwrite the newly selected session | Pending |
| LPS-11 | Enable reduced motion | Card expansion and any terminal follow-through resolve directly to the final state | Pending |
| LPS-12 | Repeat with API 23 | All behavior and latency targets hold with opaque surfaces and no higher-API-only API calls | Pending |
| LPS-13 | Stream reasoning, then a long prose answer in the same turn | Reasoning remains in its process group while later prose deltas update only the live answer tail at display cadence | Pending |

Device evidence is required before any row becomes Pass. No device was online
for this implementation.
