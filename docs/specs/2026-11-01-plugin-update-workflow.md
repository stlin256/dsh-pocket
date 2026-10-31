# Versioned Plugin Update Workflow Specification

Date: 2026-11-01

## Command

```sh
node scripts/update-plugin-version.mjs <major.minor.patch>
```

The command reads the current version from
`plugins/dsh-harmony/package.json`, validates the requested semantic version,
and rewrites only known version-reference documents:

- plugin package manifest and README;
- App `BuildInfo` release tag, artifact URL and installation prompt;
- Store showcase plugin metadata;
- root Chinese/English README files;
- `docs/PLUGIN-INSTALL.md`.

After rewriting, the command runs `scripts/package-plugin.mjs`. That existing
script rebuilds the browser entry, stages production dependencies, creates the
versioned tarball and invokes `scripts/verify-plugin-package.mjs`.

`--no-package` skips that final step for review-only version changes.

## Failure behavior

Invalid versions fail before any file write. Packaging or verification failure
leaves changed source files available for diagnosis and does not claim an
installable artifact.

## Version ownership

The App does not silently update server plugins. Users receive a versioned
installation prompt from the matching App build and install through DSH's
plugin manager. This keeps execution of server-side plugin code under the DSH
owner's control.
