# Release Process

This repository uses a one-active-release workflow:

- `main` always contains the current working release.
- each shipped release is preserved in an `rhdh-x.x-lls-x.x` branch (for example `rhdh-1.9-lls-0.4.3`).
  - Where `lls-x.x` denotes the Llama Stack version compatible with the configuration files.
- each shipped release is tagged on GitHub as `v<version>`.

## Release Candidates

Sometimes during a release cycle the underlying Llama Stack version will change. 
To ensure that these changes are properly versioned, a release candidate should be cut.

1. Create or update the release candidate branch for the outgoing release candidate snapshot (e.g. `rc-rhdh-1.9-lls-0.4.3`).
2. Create a Git tag for the release candidate snapshot (e.g. `rc-v1.9.0`).
3. Mark the release as **pre-release** to indicate it is not an official release.

## Releasing a New Version

When cutting a new release from the current `main`:

1. Ensure `main` is stable and release-ready.
2. Create or update the release branch for the outgoing release snapshot (for example `rhdh-1.9-lls-0.4.3`).
3. Create a Git tag for the outgoing release snapshot (for example `v1.9.0`).
4. Update `main` to the next active release (configs, images, docs, and compose wiring).
5. Update `README.md` release metadata on `main`:
   - `Llama Stack Version` badge
   - `RHDH Release` badge
   - version table row
6. Keep `README.md` release metadata updated in `rhdh-x.x` branches as well when that branch receives a fix release.

## Historical Release Hotfixes

Critical fixes for older releases are made in their release branch:

1. Branch from `rhdh-x.x-lls-x.x`.
2. Apply and validate the fix.
3. Merge back into `rhdh-x.x-lls-x.x`.
4. Update `README.md` release metadata in that release branch (including the `RHDH Release` badge) if any release values changed.
5. Tag the patched release (for example `v1.9.1` for a patch release line).
6. Cherry-pick the fix to `main` if it still applies to the current release.
