///|
/// RFB keysyms are X11 unsigned 32-bit values, not platform scancodes.
pub fn key_event(keysym : UInt, down : Bool) -> Array[Int] {
  let b = [4, if down { 1 } else { 0 }, 0, 0]
  put32(b, keysym.reinterpret_as_int())
  b
}

///|
pub fn pointer_event(
  x : Int,
  y : Int,
  buttons : Int,
) -> Array[Int] raise RfbError {
  check_u16(x)
  check_u16(y)
  if buttons < 0 || buttons > 255 {
    raise Invalid("button mask")
  }
  let b = [5, buttons]
  put16(b, x)
  put16(b, y)
  b
}

///|
/// Clipboard payload is opaque Latin-1 bytes in classic RFB, not UTF-8 text.
pub fn client_cut_text(text : Array[Int]) -> Array[Int] raise RfbError {
  if text.length() > 1048576 {
    raise Limit("clipboard")
  }
  let b = [6, 0, 0, 0]
  put32(b, text.length())
  b.append(checked_bytes(text))
  b
}

///|
pub fn update_request(
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  incremental : Bool,
) -> Array[Int] raise RfbError {
  check_u16(x)
  check_u16(y)
  check_u16(width)
  check_u16(height)
  let b = [3, if incremental { 1 } else { 0 }]
  put16(b, x)
  put16(b, y)
  put16(b, width)
  put16(b, height)
  b
}

///|
/// Advertise only decoders implemented by this release.
pub fn set_encodings() -> Array[Int] {
  let b = [2, 0, 0, 5]
  for e in [15, 1, 0, -239, -223] {
    put32(b, e)
  }
  b
}

///|
pub fn set_pixel_format(format : PixelFormat) -> Array[Int] raise RfbError {
  let b = [0, 0, 0, 0]
  b.append(write_format(format))
  b
}
