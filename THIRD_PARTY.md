# Port provenance

Upstream: https://github.com/HsuJv/vnc-rs, crate 0.5.3, source commit ab684d009d767c968af2f7559576334038623124.
Crate SHA-256: 5607299ce93dc285571540ee93de681a1be7a5765c35dfb2e1f049b493652145.
MIT option of upstream MIT OR Apache-2.0, upstream LICENSE retained. DES also retains Antoni Boucher's MIT copyright in its source.

Port design: replace Tokio reads and event callbacks with a bounded sans-I/O state machine. Application provides transport and rendering; MoonBit owns negotiation, auth, decoding and serialization. Unsafe allocation and unbounded reads are not carried over. File mapping and deviations are recorded with implementation.
