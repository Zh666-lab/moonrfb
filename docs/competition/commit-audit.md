# Commit substance audit

Audit date: 2026-09-15. 22 commits reviewed; conservative valid count: 21. The initial scope/license scaffold is retained but excluded conservatively. Checks refer to the final integrated tree, not a claim that every intermediate scaffold compiled.

| SHA | Purpose / retained result | Changed paths | Verification | Counted |
|---|---|---|---|---|
| d757367 | chore: establish licensed port scope and reviewed duplication gate | .gitignore, LICENSE, README.md, THIRD_PARTY.md, docs/competition/duplicate-check.md, docs/milestones.md, moon.mod, moon.pkg | license/provenance/gate inspected; conservative exclusion of scaffold | no |
| fd78177 | feat: add bounded big-endian wire primitives with truncation tests | wire.mbt, wire_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 9167064 | feat: validate true-color formats and normalize compact endian pixels | pixel.mbt, pixel_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 87e1e0f | feat: serialize keyboard pointer clipboard and update requests | messages.mbt, messages_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 450d7c4 | feat: port DES and VNC challenge response with upstream known-answer vectors | des.mbt, des_wbtest.mbt, messages.mbt, vendor/DES-LICENSE | 26 final suite tests, three backends locally; strict four-target check | yes |
| abef1e0 | feat: negotiate RFB versions and select explicit security policy | handshake.mbt, handshake_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| a150273 | feat: integrate transactional VNC authentication handshake states | handshake.mbt, handshake_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 971e694 | feat: decode Raw pixels into bounded owned framebuffers | framebuffer.mbt, framebuffer_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 427bf85 | feat: implement overlap-safe CopyRect framebuffer updates | framebuffer.mbt, framebuffer_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 925a281 | feat: port compact tile palettes with RFC-correct TRLE geometry | trle.mbt, trle_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 9cfeb93 | feat: support bounded TRLE runs and reused RLE palettes | trle.mbt, trle_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 28d4a00 | feat: parse bounded server updates clipboard cursor and desktop resize | server.mbt, server_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| cb22717 | feat: expose incremental sans-I/O client with atomic framebuffer transactions | client.mbt, client_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 61afbf1 | fix: bound queued events enforce EOF and reject partial update mutations | client.mbt, client_wbtest.mbt, des.mbt, des_wbtest.mbt, framebuffer.mbt, framebuffer_wbtest.mbt, handshake.mbt, handshake_wbtest.mbt, messages.mbt, messages_wbtest.mbt, moon.mod, pixel.mbt, pixel_wbtest.mbt, server.mbt, server_wbtest.mbt, trle.mbt, trle_wbtest.mbt, wire.mbt, wire_wbtest.mbt | 26 final suite tests, three backends locally; strict four-target check | yes |
| 176f44d | feat: connect MoonBit client to real loopback TCP and capture desktop image | bridge/bridge.mbt, bridge/moon.pkg, examples/capture.cjs, examples/fixture-server.cjs, examples/transport.cjs | npm run examples: all three real loopback TCP flows passed | yes |
| 3a005a5 | test: verify keyboard pointer and clipboard delivery over controlled TCP | examples/input.cjs | npm run examples: all three real loopback TCP flows passed | yes |
| a202690 | test: reconstruct three live frames across fragmented TCP updates | examples/replay.cjs | npm run examples: all three real loopback TCP flows passed | yes |
| b6dd394 | test: compare 1350 deterministic cases against unmodified noVNC modules | .gitignore, package-lock.json, package.json, tools/differential.cjs | tools/differential.cjs: 1,350 cases, zero differences | yes |
| 778a598 | test: independently encode 442 TRLE palette and run-length fixtures | tools/trle-corpus.cjs | tools/trle-corpus.cjs: 442 valid + 6 invalid cases passed | yes |
| 5d839d0 | test: add compiled original Rust authentication oracle and file provenance | THIRD_PARTY.md, tools/upstream-des.rs, tools/upstream-differential.cjs, vendor/upstream-des.rs | original source preserved and harness reviewed; execution required in CI (no local rustc) | yes |
| f0b576b | perf: add reproducible owned-frame decode latency measurement | tools/benchmark.cjs | tools/benchmark.cjs: 30 recorded samples after 5 warmups | yes |
| 3a56774 | ci: verify four backends and document supported integration contract | .github/workflows/ci.yml, AI_USE.md, CHANGELOG.md, CONTRIBUTING.md, README.md, SECURITY.md, docs/architecture.md, docs/competition/duplicate-check.md, docs/evidence/benchmark.json, docs/evidence/differential.json, docs/evidence/trle-corpus.json, docs/evidence/verification-local.json, pkg.generated.mbti, tools/verify.py | tools/verify.py passed with explicit native/Rust runtime deferrals; package file list inspected | yes |

No empty, whitespace-only or manufactured retrospective commits are counted. Future release/CI repair commits are not needed to meet the conservative 20-commit floor.
