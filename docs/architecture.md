# Architecture and adapter contract

`wire → handshake / pixel / DES → framebuffer / TRLE → server → client` is the dependency flow. The core does not open sockets, start threads, invoke external binaries, or render a window.

Each feed appends checked bytes to a bounded pending buffer. Handshake steps commit only when their whole message is available. Server frame messages are parsed into operations before framebuffer mutation; an incomplete or malformed later rectangle must not expose an earlier rectangle from the same update. CopyRect takes a source snapshot, so overlapping rectangles behave consistently. TRLE tiles are 16×16, with row-aligned packed indices and bounded runs.

The application drains both output and events after every feed. It writes output in order and serializes its own input/update messages onto that same transport. Do not call feed concurrently. Ready supplies the server metadata; the client negotiates canonical BGRx wire pixels and exports RGB snapshots. Clipboard and names are raw byte arrays: applications choose their text policy. Keyboard values are X11 keysyms, not operating-system keycodes. Pointer coordinates are framebuffer coordinates.

`snapshot()` returns an owned copy of the latest framebuffer. Events report operations, not historical pixel snapshots: if one feed contains multiple frames, the snapshot is the final frame. Cursor is a separate overlay with alpha; it does not change stored desktop pixels. DesktopSize is only accepted as the final rectangle with zero origin.

NeedMore is internal flow control for partial streams. Public feed accepts ordinary partial input without failing; malformed or over-limit input poisons the session. finish validates EOF and closes the session. Create a new session after an error, not a retry on the same object. Queue limits also protect applications that forget to drain events/output.

The implementation buffers a complete update transaction. Byte-by-byte feeds can reparse partial TRLE work, so this release does not promise constant-time incremental parsing or production-level resistance to CPU exhaustion. Adapters should impose timeouts, connection limits and appropriately sized chunks. Default limits are bounded, but applications should lower them for their workload.

The JS bridge is an example ABI surface; typed arrays are Int32Array. Its stateless decoder helpers map errors to empty arrays for differential scripts; production MoonBit callers should use the root API and structured RfbError. See examples/transport.cjs for the complete local TCP lifecycle.
