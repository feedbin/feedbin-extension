# Extension Store Release Automation Design

## Goal

Automate releases of Feedbin Subscribe & Save to the existing Chrome Web Store and Firefox Add-ons listings. A pushed version tag will validate, test, package, and submit the matching extension version to both stores for review. After both submissions succeed, the workflow will create a GitHub Release containing the two distributable ZIP files.

## Release Contract

`manifest.yml` remains the single source of truth for the extension version. A release starts when a tag matching `v<version>` is pushed, for example `v1.7.2`.

The workflow must reject the release before packaging when any of these conditions is true:

- The tag does not use the `v<version>` format accepted by browser extension manifests.
- The version after the `v` prefix does not exactly match `defaults.version` in `manifest.yml`.
- The tagged commit is not reachable from the repository's `main` branch.

The workflow will not update, commit, or tag a version. The release operator will update `manifest.yml`, commit that change, and push a matching tag.

## Architecture

The release automation will be implemented as a GitHub Actions workflow in `.github/workflows/release.yml` with these jobs:

1. **Validate and build:** Check out the tagged commit with enough history to verify its relationship to `main`; install the locked Ruby and Node dependencies; validate the tag and manifest versions; run the Ruby test suite; package Chrome and Firefox from the same checkout; lint the generated Firefox extension; verify each generated manifest version and ZIP; and upload both ZIPs as workflow artifacts.
2. **Publish Chrome:** Download the Chrome ZIP, obtain a short-lived Google access token from a service-account credential, upload the ZIP through the Chrome Web Store v2 API, verify that the upload completed successfully, and call the publish endpoint. Calling publish submits the update for review and publishes it after approval under the listing's existing visibility settings.
3. **Publish Firefox:** Download the Firefox ZIP and run the repository's locked `web-ext` dependency with `sign --channel listed`, using AMO API credentials. This adds the version to the existing public listing and submits it for review. No source-code archive will be supplied.
4. **Create GitHub Release:** Run only after both store jobs succeed. Create a release for the pushed tag with automatically generated notes and attach `chrome_<version>.zip` and `firefox_<version>.zip`.

The build output is produced once and passed to downstream jobs so the store submissions and GitHub Release use the same files.

## Packaging

The existing `bin/extension package` command will remain the canonical packaging entry point. It will be hardened to:

- Create `tmp/` when it does not exist.
- Remove existing same-version Chrome and Firefox ZIP files before writing new ones, preventing stale entries from a previous ZIP.
- Build production Jekyll output separately for Chrome and Firefox.
- Emit exactly `tmp/chrome_<version>.zip` and `tmp/firefox_<version>.zip`.

The workflow will inspect both archives and their generated manifests before any store credential is made available.

## Credentials and Permissions

Chrome publishing will use a Google Cloud service account because Chrome documents service accounts as suitable for CI/CD. The service account must have the Chrome Web Store API enabled and must be linked to the publisher in the Chrome Web Store Developer Dashboard.

GitHub configuration:

- Secret `CHROME_SERVICE_ACCOUNT_JSON`: JSON key for the linked Google Cloud service account.
- Variable `CHROME_PUBLISHER_ID`: Chrome Web Store publisher ID.
- Variable `CHROME_EXTENSION_ID`: Existing listing ID (`dokieklajbcljjhhaabkjceopenlimco`).
- Secret `FIREFOX_API_KEY`: AMO JWT issuer/API key.
- Secret `FIREFOX_API_SECRET`: AMO JWT secret.

The workflow will declare minimal GitHub token permissions. The build and publishing jobs need read-only repository contents. Only the GitHub Release job receives `contents: write`. Chrome and Firefox secrets are scoped to their respective publishing jobs and are not available during validation or packaging.

The README will document how to create and register the Chrome service account, obtain Firefox API credentials, and configure the GitHub repository.

## Failure Handling and Repeatability

A concurrency group keyed by the release tag will prevent simultaneous workflows from submitting the same version.

Chrome and Firefox publishing jobs will start independently after the shared build. A failure in one will not cancel the other. The GitHub Release will be created only after both store submissions succeed.

Store submission is not transactionally reversible: one store can accept a version while the other fails. In that case, the operator should use GitHub Actions' **Re-run failed jobs** command. This retries only the failed store job and the skipped GitHub Release job, avoiding a duplicate submission to the successful store.

The GitHub Release creation step will be safe to retry: it will create the release if absent and upload the named assets with replacement enabled. Workflow artifacts will have a finite retention period and are not a permanent release channel.

API responses will be checked for success states rather than relying only on HTTP process exit codes. Error output must identify the affected store without printing credentials or access tokens.

## Verification

Before publishing, the workflow will verify:

- The pushed tag, `manifest.yml` version, Chrome manifest version, and Firefox manifest version are identical.
- The tagged commit belongs to `main`.
- `bundle exec rake` passes.
- `npx web-ext lint` passes against the generated Firefox directory.
- Both ZIP files exist, are non-empty, can be listed, and contain a root-level `manifest.json`.
- Packaging from a dirty `tmp/` directory replaces old same-version archives rather than updating them in place.
- The release workflow parses as valid YAML and uses the expected event, job dependencies, and permission boundaries.

The store upload and submission calls cannot be tested end-to-end without consuming a new store version. Their commands and response handling will therefore be reviewed against the official [Chrome Web Store API documentation](https://developer.chrome.com/docs/webstore/using-api) and [Mozilla `web-ext sign` documentation](https://extensionworkshop.com/documentation/develop/web-ext-command-reference/#web-ext-sign), while local verification stops before authenticated submission.

## User-Facing Release Procedure

After the one-time credentials are configured, a release consists of:

1. Update `defaults.version` in `manifest.yml` and commit it on `main`.
2. Push `main`.
3. Create and push the matching tag, such as `v1.7.2`.
4. Monitor the Release workflow. Once both submissions are accepted, the workflow creates the GitHub Release with both browser ZIPs.

Store review and final public availability remain controlled by Chrome and Mozilla after submission.
