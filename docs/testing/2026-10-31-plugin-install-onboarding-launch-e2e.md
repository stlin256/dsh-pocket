# Plugin Installation, Onboarding and Branded Launch E2E

Date: 2026-10-31

Status: device run in progress. Passed rows below were verified on the target
phone on 2026-11-01. Environment-dependent rows remain partial or pending.

| ID | Scenario | Expected Result | Status |
| --- | --- | --- | --- |
| ONB-E2E-01 | Install the signed personal HAP with no saved session and launch. | Branded launch appears first; the editable address form is not exposed during initialization; welcome logo, name and two actions appear. | Passed; cleared bundle data, launched the signed personal Release build and captured the branded intro with both actions inside the display. |
| ONB-E2E-02 | Tap the guide action. | Logo moves to the lower-right watermark; three concise steps enter in the correct direction; reduced motion resolves instantly. | Partial; the settled guide, lower-right watermark and all three steps were captured. Motion direction and reduced-motion timing still require a frame-level run. |
| ONB-E2E-03 | Use the guide copy action and paste into a text field. | The canonical installation prompt is copied without private hosts or credentials. | Partial; the device action changed to the copied state and the model contract test verifies the canonical prompt, but HDC provides no clipboard-read command for an independent content check. |
| ONB-E2E-04 | Use the guide repository action. | The project repository opens in the system browser. | Passed; WindowManager focus moved to browser window `2359`, and the repository page was visible. |
| ONB-E2E-05 | Choose direct entry, enter native credentials and connect. | Login succeeds and the launch surface crossfades into the workspace. | Partial; continuing from the guide reached the login surface and native access-key mode was selected by default, with Passkey below it. A successful credential exchange was not run with a real account. |
| ONB-E2E-06 | Relaunch with a valid saved native session. | Branded launch remains visible during restore and transitions directly to the workspace. | Pending |
| ONB-E2E-07 | Relaunch with an expired native session and saved origin. | No editable form appears during restore; login opens with the saved address prefilled. | Pending |
| ONB-E2E-08 | Submit an invalid key, then use copy and retry with the valid key. | Error remains inside the launch visual system, copy works and valid retry succeeds. | Partial; a deliberately invalid origin produced the inline launch-surface error with copy and retry controls. A valid credential retry was not available in the sanitized device run. |
| ONB-E2E-09 | Select Passkey, complete system authentication and enter the workspace. | Passkey controls remain below native login; HTTPS flow, authentication and workspace entry remain functional. | Pending |
| ONB-E2E-10 | Log out, terminate and reopen the app. | Welcome flow appears again and the previous service address is still prefilled upon direct entry. | Pending |
| ONB-E2E-11 | Repeat primary paths in light, dark, reduced-motion, API 23, large-text and landscape configurations. | No clipped action, unreadable text, unsafe overlap or motion that ignores reduce-motion. | Partial; the dark-phone pass had no clipped actions or unsafe overlap. Light, reduced-motion, API 23, large-text and landscape remain pending. |
| ONB-E2E-12 | Install the stable tarball through DSH Plugins or `plugin_manager`. | The package is accepted as a bundle, activates, reports its version in app settings and survives a Harness restart. | Partial; the self-contained tarball passed external extraction/import verification and the published URL returns HTTP 200. Installation in a real DSH profile and restart verification remain pending. |

## Device evidence

Local evidence directory:
`artifacts/device-e2e/plugin-onboarding-launch-20261101`.

Captured surfaces include:

- `intro.jpeg` and `intro.layout.json`
- `guide.jpeg` and `guide.layout.json`
- `guide-copied.jpeg`
- `repository-open.jpeg`
- `login.jpeg` and `login.layout.json`
- `error.jpeg` and `error.layout.json`

Automated gates completed on the same source tree:

- `gateway/npm test`: 138 passed, 0 failed.
- Personal/default Release build: successful.
- AppGallery/store Release build: successful.
- `node scripts/package-plugin.mjs`: bundle, host import, browser factory and
  external extraction verification passed.
- Plugin release:
  [plugin-v0.3.6](https://github.com/stlin256/DSH-Harmony/releases/tag/plugin-v0.3.6).
