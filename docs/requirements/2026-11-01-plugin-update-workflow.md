# Versioned Plugin Update Workflow

Date: 2026-11-01

## User requirement

Plugin content must remain updatable after the App and server are deployed. A
plugin change needs one repeatable path that updates every App/install reference,
packages the complete bundle and validates the resulting tarball.

## Required behavior

- Plugin versions remain independent from App version codes.
- Updating the plugin version updates its package manifest, in-App install
  prompt, Store showcase metadata, README files and installation guide.
- The updater rejects malformed versions and does not partially publish.
- The normal update command packages and verifies the bundle automatically.
- A maintainer may update only the manifests/prompts without packaging for a
  review-only change, but the resulting package remains explicitly unverified.
- No private host, credential or local absolute path is introduced.
