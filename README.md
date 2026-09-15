# MoonRFB

Work in progress: a MoonBit source port of the VNC client protocol engine in HsuJv/vnc-rs 0.5.3. No external VNC binary or Rust FFI is used by the library.

Release scope: RFB 3.3/3.7/3.8, explicit opt-in unauthenticated sessions, VNC challenge-response, true-color pixel formats, Raw/CopyRect/TRLE, cursor/desktop size, keyboard/pointer/clipboard messages. Compressed encodings, TLS, indexed color and a full GUI are outside v0.1.
