# Contributing

Use a current stable MoonBit toolchain, Node 24 and Rust for the original-source oracle. Run `npm ci --ignore-scripts` then `python tools/verify.py`. CI checks wasm-gc, wasm, js and native. A missing native compiler is not a passing native test; use explicit deferral only locally.

Protocol fixes should cite the relevant RFC rule, include a failing fixture and test arbitrary fragmentation. Keep transport and rendering outside the core. Never include real server credentials or unauthorized capture data. Preserve upstream notices and explain deviations from vnc-rs in THIRD_PARTY.md.
