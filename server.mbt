///|
/// Cursor alpha is stored separately as one 0/1 integer per pixel.
pub(all) struct Cursor {
  hotspot_x : Int
  hotspot_y : Int
  width : Int
  height : Int
  pixels : Array[Int]
  alpha : Array[Int]
} derive(Debug, Eq)

///|
pub(all) enum Event {
  Ready(Screen)
  Painted(Rect)
  Copied(Rect, Int, Int)
  Resized(Int, Int)
  CursorChanged(Cursor)
  Bell
  Clipboard(Array[Int])
  UpdateComplete
} derive(Debug, Eq)

///|
priv enum Update {
  Paint(Rect, Array[Int])
  Copy(Rect, Int, Int)
  Resize(Int, Int)
  SetCursor(Cursor)
}

///|
priv enum ServerMessage {
  Frame(Array[Update])
  Ring
  Text(Array[Int])
}

///|
fn read_rectangle(r : Reader) -> Rect raise RfbError {
  let x = r.u16()
  let y = r.u16()
  let width = r.u16()
  let height = r.u16()
  { x, y, width, height, }
}

///|
fn read_cursor(
  r : Reader,
  f : PixelFormat,
  rect : Rect,
  opt : Options,
) -> Cursor raise RfbError {
  let w = rect.width
  let h = rect.height
  if w > 1024 || h > 1024 || (h > 0 && w > opt.max_pixels / h) {
    raise Limit("cursor")
  }
  if (w == 0) != (h == 0) || (w > 0 && (rect.x >= w || rect.y >= h)) {
    raise Invalid("cursor hotspot")
  }
  let pixels = raw_pixels(r, f, w, h)
  let stride = (w + 7) / 8
  let mask = r.take(stride * h)
  let alpha = Array::makei(w * h, i => {
    (mask[i / w * stride + i % w / 8] >> (7 - i % w % 8)) & 1
  })
  { hotspot_x: rect.x, hotspot_y: rect.y, width: w, height: h, pixels, alpha, }
}

///|
/// Parse a whole update transaction before applying any rectangle.
fn server_message(
  r : Reader,
  f : PixelFormat,
  width : Int,
  height : Int,
  opt : Options,
) -> ServerMessage raise RfbError {
  match r.u8() {
    0 => {
      ignore(r.u8())
      let count = r.u16()
      if count > 4096 {
        raise Limit("rectangle count")
      }
      let updates = []
      let mut w = width
      let mut h = height
      let mut work = 0
      for i in 0..<count {
        let rect = read_rectangle(r)
        let encoding = r.i32()
        if encoding == -223 {
          if i != count - 1 || rect.x != 0 || rect.y != 0 {
            raise Invalid("DesktopSize must be last at origin")
          }
          check_dimensions(rect.width, rect.height, opt.max_pixels)
          w = rect.width
          h = rect.height
          updates.push(Resize(w, h))
        } else if encoding == -239 {
          let cursor = read_cursor(r, f, rect, opt)
          let n = cursor.pixels.length()
          if n > opt.max_pixels - work {
            raise Limit("update pixel work")
          }
          work += n
          updates.push(SetCursor(cursor))
        } else {
          check_rect(rect, w, h)
          let n = rect.width * rect.height
          if n > opt.max_pixels - work {
            raise Limit("update pixel work")
          }
          work += n
          match encoding {
            0 =>
              updates.push(
                Paint(rect, raw_pixels(r, f, rect.width, rect.height)),
              )
            1 => {
              let sx = r.u16()
              let sy = r.u16()
              check_rect({ ..rect, x: sx, y: sy, }, w, h)
              updates.push(Copy(rect, sx, sy))
            }
            15 =>
              updates.push(
                Paint(rect, trle_pixels(r, f, rect.width, rect.height)),
              )
            _ => raise Unsupported(encoding)
          }
        }
      }
      Frame(updates)
    }
    2 => Ring
    3 => {
      ignore(r.take(3))
      let n = r.i32()
      if n < 0 || n > opt.max_text {
        raise Limit("clipboard")
      }
      Text(r.take(n))
    }
    tag => raise Unsupported(tag)
  }
}
