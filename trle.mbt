// Port of vnc-rs codec/trle.rs palette and run decoding, corrected to RFC 6143
// TRLE (16x16, no length prefix, palette reuse), unlike upstream's 64x64 routine.

///|
fn packed_tile(
  r : Reader,
  palette : Array[Int],
  w : Int,
  h : Int,
) -> Array[Int] raise RfbError {
  let n = palette.length()
  if n < 2 || n > 16 {
    raise Invalid("packed palette size")
  }
  let bits = if n == 2 { 1 } else if n <= 4 { 2 } else { 4 }
  let mask = (1 << bits) - 1
  let out = []
  for _ in 0..<h {
    let mut shift = -1
    let mut byte = 0
    for _ in 0..<w {
      if shift < 0 {
        byte = r.u8()
        shift = 8 - bits
      }
      let index = (byte >> shift) & mask
      if index >= n {
        raise Invalid("palette index")
      }
      out.push(palette[index])
      shift -= bits
    }
  }
  out
}

///|
fn trle_pixels(
  r : Reader,
  f : PixelFormat,
  w : Int,
  h : Int,
) -> Array[Int] raise RfbError {
  let out = Array::make(w * h, 0)
  let mut palette : Array[Int] = []
  let mut ty = 0
  while ty < h {
    let th = if h - ty < 16 { h - ty } else { 16 }
    let mut tx = 0
    while tx < w {
      let tw = if w - tx < 16 { w - tx } else { 16 }
      let mode = r.u8()
      let tile = if mode == 0 {
        Array::makei(tw * th, _ => read_pixel(r, f, true))
      } else if mode == 1 {
        Array::make(tw * th, read_pixel(r, f, true))
      } else if mode >= 2 && mode <= 16 {
        palette = Array::makei(mode, _ => read_pixel(r, f, true))
        packed_tile(r, palette, tw, th)
      } else if mode == 127 {
        packed_tile(r, palette, tw, th)
      } else if mode == 128 {
        rle_tile(r, f, [], tw * th)
      } else if mode == 129 {
        if palette.length() < 2 {
          raise Invalid("missing reused palette")
        }
        rle_tile(r, f, palette, tw * th)
      } else if mode >= 130 {
        palette = Array::makei(mode - 128, _ => read_pixel(r, f, true))
        rle_tile(r, f, palette, tw * th)
      } else {
        raise Invalid("reserved TRLE subencoding")
      }
      for y in 0..<th {
        for x in 0..<tw {
          out[(ty + y) * w + tx + x] = tile[y * tw + x]
        }
      }
      tx += tw
    }
    ty += th
  }
  out
}

///|
/// Decode RFC 6143 TRLE payload, not compressed ZRLE data.
pub fn decode_trle(
  data : Array[Int],
  format : PixelFormat,
  width : Int,
  height : Int,
) -> Array[Int] raise RfbError {
  format.validate()
  check_dimensions(width, height, 4194304)
  let r = Reader::new(data)
  let out = trle_pixels(r, format, width, height)
  if r.pos != data.length() {
    raise Invalid("trailing TRLE bytes")
  }
  out
}

///|
fn run_length(r : Reader, remaining : Int) -> Int raise RfbError {
  let mut length = 1
  while true {
    let b = r.u8()
    if b > remaining - length {
      raise Invalid("TRLE run exceeds tile")
    }
    length += b
    if b != 255 {
      break
    }
  }
  length
}

///|
fn rle_tile(
  r : Reader,
  f : PixelFormat,
  palette : Array[Int],
  count : Int,
) -> Array[Int] raise RfbError {
  let out = []
  while out.length() < count {
    let (color, length) = if palette.is_empty() {
      let color = read_pixel(r, f, true)
      (color, run_length(r, count - out.length()))
    } else {
      let control = r.u8()
      let index = control & 127
      if index >= palette.length() {
        raise Invalid("palette index")
      }
      let length = if (control & 128) != 0 {
        run_length(r, count - out.length())
      } else {
        1
      }
      (palette[index], length)
    }
    for _ in 0..<length {
      out.push(color)
    }
  }
  out
}
