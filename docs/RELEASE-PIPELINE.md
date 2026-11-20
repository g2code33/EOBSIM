# Release pipeline — current implementation and gaps

**Not a release-ready pipeline.** No `.github/workflows/release.yml`, release
publisher, update service, web build, native mobile projects, Linux build, or
automated Windows build exists. Do not use this branch to publish installers.
The repository contains a Windows Delphi VCL application, which requires an
application port before the requested common web-asset pipeline is possible.

## Current job / artifact map

| Job | Trigger | Output | Signing |
| --- | --- | --- | --- |
| PR source checks | pull request | test results only; no artifact | not applicable |
| Web, Windows, Linux, Android, iOS | none | none | not implemented |

The PR checks run the standalone integrity helper's Node tests and existing
Python source checks. They do not compile or smoke-test the app, and no release
or artifact names/sizes can be reported. They do not prove that the two update
surfaces work.

## Secrets and signing

No CI secrets are currently consumed. Future deployment will require separate
Windows code-signing credentials, Android signing credentials, Apple signing
and provisioning credentials / App Store Connect API access, and Cloudflare
deployment credentials. Names, provisioning, missing-secret handling and the
`release` environment are not implemented. An unsigned iOS archive is not an
installable TestFlight/App Store export. No publish or tag operation is performed
by this branch.

## Release and rollback

There is no implemented release-cut command, manifest endpoint, release
verification script, or manifest rollback procedure. Do not publish until those
are implemented and exercised against a private test repository and the upstream
licensing questions are resolved. A future implementation needs to stage a
draft, verify the actual remote asset sizes and checksums, rebuild the feed
from those assets, and only then publish; deletion and rollback must also update
the feed. The standalone checksum helper checks metadata consistency only: it
does not authenticate a manifest, prevent a file replacement race, download or
install anything, and is not integrated with the app.

## Update surfaces as actually implemented

| Capability | Windows desktop | Mobile / PWA |
| --- | --- | --- |
| UI or manual check | Not implemented | Not implemented; apps do not exist |
| Auto-check, prompts, snooze, forced-update gate | Not implemented | Not implemented |
| Admin settings, rollout and audit | Not implemented | Not implemented |
| Download, hash verification and install | Not integrated | Not integrated |

## Local checks

```sh
node --test tests/update-integrity.test.mjs
python3 -m unittest discover -s tests -v
```

The tests use local temporary files; they are not a substitute for an
OS-level network-isolated run, Windows/Delphi build, web/PWA validation, desktop
smoke run, native mobile build, installer inspection or clean-clone build.
