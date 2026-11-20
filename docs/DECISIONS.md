# Build and update decisions

These are planning defaults, not a claim that the corresponding functionality
exists. The only existing application is the Windows-only Delphi VCL project;
there is no web or mobile application to package. Do not replace the existing
simulation with a nonfunctional shell and call it a port.

| Decision | Default / current state |
| --- | --- |
| Product | EOSIM — Electronic Organ Bath Simulation; existing executable `EOBSIM.exe`. |
| Cross-platform desktop | Plan Electron with a shared web UI. No Electron dependency or version has been selected or installed. This requires porting and validating the existing simulation. |
| Mobile | Plan Capacitor using the same web bundle. No Capacitor dependency, version or native project exists. |
| Distribution | Plan GitHub Releases for installer artifacts. No automated publisher, update feed or release is configured. |
| Web / config | Plan Cloudflare Pages and a Worker for dynamic update configuration. Neither has been deployed or configured. |
| Application identifier | Proposed `io.github.g2code33.eobsim`; not registered or used by any target. Verify ownership/availability before signing or publishing. |
| Signing | None configured. Lack of signing is not treated as successful distribution. Apple store/TestFlight exports require appropriate signing and provisioning. |
| Integrity | `scripts/update-integrity.mjs` checks local bytes and hash against supplied metadata. It is standalone: neither application nor CI release flow invokes it. It does not authenticate metadata or protect against replacement after verification. |
| Licenses | See `THIRD_PARTY_NOTICES.md`; upstream permissions must be established before redistribution. |

GitHub's documented workflow-dispatch input types are `boolean`, `choice`,
`number`, `environment`, and `string`; a `choice` is a **single** selection,
not a multi-select. A future workflow must use separate booleans or a validated
string for target selection instead of claiming native multi-select support.
Source: [GitHub workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#onworkflow_dispatchinputsinput_idtype).
