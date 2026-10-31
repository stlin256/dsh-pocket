# Default cache pool E2E

Date: 2026-11-01

Status: implementation and automated checks complete; device rows pending user verification.

| ID | Scenario | Expected result | Result |
|---|---|---|---|
| CACHE-01 | Open Settings > Storage with a small cache | Summary shows global usage against a 5 GiB default limit; category rows remain account-specific | Pending |
| CACHE-02 | Populate transcript, directory, text, binary, attachment and navigation caches in light and dark modes | Summary is readable, values do not overflow and the total includes every category | Pending |
| CACHE-03 | Add old cached records from multiple owners until the pool would exceed 5 GiB | Oldest unprotected records are removed first; the current conversation remains available | Pending |
| CACHE-04 | Keep the active conversation plus enough protected sessions to exceed the pool | Unprotected entries are removed first; protected entries are removed only if the hard limit still cannot be met | Pending |
| CACHE-05 | Stream a long response for more than one minute | Cache enforcement does not introduce visible stream stalls or repeated storage scans | Pending |
| CACHE-06 | Terminate and reopen the app after eviction | Cache use remains at or below 5 GiB and unaffected recent conversations/files open from cache | Pending |
| CACHE-07 | Clear cache from storage management | Current-account values return to zero; other obvious app data and the configured login address remain intact | Pending |
