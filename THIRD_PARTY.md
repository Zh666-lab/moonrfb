# Port provenance

Upstream: https://github.com/HsuJv/vnc-rs, crate 0.5.3, source commit ab684d009d767c968af2f7559576334038623124.
Crate SHA-256: 5607299ce93dc285571540ee93de681a1be7a5765c35dfb2e1f049b493652145.
MIT option of upstream MIT OR Apache-2.0, upstream LICENSE retained. DES also retains Antoni Boucher's MIT copyright in its source.

Port design: replace Tokio reads and event callbacks with a bounded sans-I/O state machine. Application provides transport and rendering; MoonBit owns negotiation, auth, decoding and serialization. Unsafe allocation and unbounded reads are not carried over. File mapping and deviations are recorded with implementation.

## Reference-only development files

`vendor/upstream-des.rs` is an unmodified copy of vnc-rs 0.5.3 `src/client/security/des.rs`; its embedded MIT notice is retained. `tools/upstream-des.rs` compiles it for differential testing. It is not linked into the MoonBit package.

`@novnc/novnc` 1.7.0 is an npm development-only reference (MPL-2.0, individual crypto source attribution retained in the installed package). No noVNC source is copied into the MoonBit implementation. The lockfile pins its registry integrity. Tests invoke unmodified Raw/CopyRect/DES modules.

## Source mapping and deviations

| Upstream | MoonBit | Adaptation |
|---|---|---|
| client/connector.rs, client/auth.rs | handshake.mbt, client.mbt | Tokio stream reads become transactional incremental states; explicit opt-in None security; bounds and poison-on-error |
| client/security/des.rs | des.mbt | Preserve DES tables/rounds; right-aligned UInt64 arithmetic; password bit reversal from auth.rs |
| config.rs | pixel.mbt, handshake.mbt | Validated true-color channels; owned metadata; normalized RGB pixels |
| client/messages.rs | messages.mbt | Byte-exact client message serializers |
| codec/raw.rs, client/connection.rs | framebuffer.mbt, server.mbt | Owned RGB framebuffer and atomic updates; overlap-safe CopyRect |
| codec/trle.rs | trle.mbt | Palette, compact pixel and run decoding ported; corrected to RFC 6143 TRLE: 16x16 tiles, no length prefix, palette reuse; upstream routine uses 64x64 tiles and a length prefix |
| codec/cursor.rs, event.rs | server.mbt | Owned cursor/alpha and bounded event queue |

Not ported: Tokio runtime, Zlib/ZRLE/Tight compressed streams, TLS/VeNCrypt, GUI. RRE/Hextile are not implemented by the selected upstream and are not claimed here. This is a scoped core port with deliberate protocol corrections, not full upstream feature parity.
