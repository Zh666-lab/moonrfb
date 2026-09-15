# Release acceptance audit — 0.1.0

Verified 2026-09-15. Public repository: https://github.com/Zh666-lab/moonrfb (main). Authenticated account Zh666-lab, user id 328942604, owner ADMIN permission. GitHub commit API resolves both author and committer to Zh666-lab; local repository uses the participant's GitHub noreply identity. No personal contact or login credential is included in the repository.

## Direct evidence

- Scope/source/license: README.md, THIRD_PARTY.md, LICENSE, vendor/DES-LICENSE. MoonBit protocol implementation, no Rust FFI.
- Three acceptance workflows: examples/capture.cjs, input.cjs, replay.cjs; actual TCP loopback, assertions rather than log-only demos.
- Tests: 26 tests each on wasm-gc, wasm, js, native. Linux CI includes strict check/build/test. Windows local native check passed, native runtime deliberately deferred to CI.
- First fully passing run: https://github.com/Zh666-lab/moonrfb/actions/runs/34988527766 at commit 9ccda83. Toolchain moon 0.1.20260915, moonc v0.10.13+cbb11c36f. Artifact measurements-js includes original Rust DES (1,000 cases), noVNC (1,350 cases), TRLE corpus and benchmark. All four jobs successful. Final release metadata commits run the same gate again before tagging.
- CI caught TCP write coalescing in the replay example. Fixed through update-request pacing; controlled maximum feed size now verifies real parser fragmentation. No claim that socket.write boundaries are network boundaries.
- Measured snapshots: docs/evidence. Local benchmark is explicitly Windows JS debug; CI benchmark is a separate machine and is not substituted into local numbers.
- Clean external consumer: a separate module with a path dependency compiled the public README constructor and checked banner output / Raw decoding; 1 test passed (wasm-gc). Registry-installed consumer must be checked after MoonCakes publication; not claimed yet.
- `moon package --list`: inspected source archive; no node_modules, _build, credentials or personal application. Package includes development fixtures and their licenses.
- Commit audit: docs/competition/commit-audit.md. 22 milestone commits audited, 21 conservatively counted; initial scaffold excluded. Later metadata, paperwork and repair commits are not required to reach 20.
- AI disclosure: AI_USE.md. Unsupported encodings, security and streaming CPU limits: SECURITY.md and docs/architecture.md.
- Duplicate check: docs/competition/duplicate-check.md. Fresh vnc/rfb/trle MoonCakes searches at 2026-09-15 23:27 +08:00 returned no results, before this package's publication. Unpublished entries cannot be ruled out.
- Chinese application is local-only outside Git, passed strict structural check (33 lines, 1,833 characters); three concrete scenarios, measured comparisons and scoped source-port statement. No duplicate log in application.

## Publication boundary

GitHub publication is authorized and identity verified. MoonCakes publication is also requested but MUST wait for isolated CLI whoami to confirm Zh666-lab. The machine's default MoonCakes identity is not the participant and was not used or modified. Package 0.1.0 must never be uploaded under that default identity. This audit records readiness, not a claim of MoonCakes publication.
