# Reviewable milestones

1. Package/license/scope and duplicate gate.
2. Bounded wire reader and writer.
3. Pixel format validation/conversion.
4. Client input message serializers.
5. DES source port and known-answer tests.
6. Version/security handshake.
7. VNC authentication integration.
8. Framebuffer model and raw rectangles.
9. Overlapping CopyRect.
10. TRLE compact pixels/packed palettes.
11. TRLE runs and palette reuse.
12. Server messages and pseudo-encodings.
13. Incremental session engine.
14. Resource and malformed-input hardening.
15. Node TCP adapter and screen capture example.
16. Controlled keyboard/pointer example.
17. Multi-frame replay example.
18. Independent reference/differential corpus.
19. Measured reproducible benchmark.
20. CI, API/support documentation, security and release validation.

Each milestone will be committed only when the actual work is present; tests/fixes can be combined when they form a single coherent change. No empty or retroactive history.
