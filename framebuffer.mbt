///|
pub(all) struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Debug, Eq)

///|
pub struct Framebuffer {
  priv mut width : Int
  priv mut height : Int
  priv mut pixels : Array[Int]
  priv max_pixels : Int
}

///|
pub fn framebuffer(
  width : Int,
  height : Int,
  max_pixels? : Int = 4194304,
) -> Framebuffer raise RfbError {
  check_dimensions(width, height, max_pixels)
  { width, height, pixels: Array::make(width * height, 0), max_pixels, }
}

///|
fn check_dimensions(w : Int, h : Int, max : Int) -> Unit raise RfbError {
  if w <= 0 ||
    h <= 0 ||
    w > 65535 ||
    h > 65535 ||
    max <= 0 ||
    max > 16777216 ||
    w > max / h {
    raise Limit("framebuffer dimensions")
  }
}

///|
fn check_rect(rect : Rect, w : Int, h : Int) -> Unit raise RfbError {
  if rect.x < 0 ||
    rect.y < 0 ||
    rect.width <= 0 ||
    rect.height <= 0 ||
    rect.x > w ||
    rect.y > h ||
    rect.width > w - rect.x ||
    rect.height > h - rect.y {
    raise Invalid("rectangle outside framebuffer")
  }
}

///|
pub fn Framebuffer::size(self : Framebuffer) -> (Int, Int) {
  (self.width, self.height)
}

///|
/// Snapshot is owned by caller; mutating it cannot mutate framebuffer.
pub fn Framebuffer::snapshot(self : Framebuffer) -> Array[Int] {
  self.pixels.copy()
}

///|
pub fn Framebuffer::resize(
  self : Framebuffer,
  width : Int,
  height : Int,
) -> Unit raise RfbError {
  check_dimensions(width, height, self.max_pixels)
  self.width = width
  self.height = height
  self.pixels = Array::make(width * height, 0)
}

///|
pub fn Framebuffer::paint(
  self : Framebuffer,
  rect : Rect,
  pixels : Array[Int],
) -> Unit raise RfbError {
  check_rect(rect, self.width, self.height)
  if pixels.length() != rect.width * rect.height {
    raise Invalid("pixel count")
  }
  for p in pixels {
    if p < 0 || p > 0xffffff {
      raise Invalid("RGB pixel range")
    }
  }
  for y in 0..<rect.height {
    for x in 0..<rect.width {
      self.pixels[(rect.y + y) * self.width + rect.x + x] = pixels[y *
        rect.width +
        x]
    }
  }
}

///|
fn raw_pixels(
  r : Reader,
  f : PixelFormat,
  w : Int,
  h : Int,
) -> Array[Int] raise RfbError {
  if w * h > (r.data.length() - r.pos) / (f.bits / 8) {
    raise NeedMore
  }
  Array::makei(w * h, _ => read_pixel(r, f, false))
}

///|
/// Decode exactly one Raw rectangle payload without needing a network session.
pub fn decode_raw(
  data : Array[Int],
  format : PixelFormat,
  width : Int,
  height : Int,
) -> Array[Int] raise RfbError {
  format.validate()
  check_dimensions(width, height, 4194304)
  let r = Reader::new(data)
  let pixels = raw_pixels(r, format, width, height)
  if r.pos != data.length() {
    raise Invalid("trailing raw bytes")
  }
  pixels
}

///|
/// CopyRect has memmove semantics even when source and destination overlap.
pub fn Framebuffer::copy_rect(
  self : Framebuffer,
  dest : Rect,
  source_x : Int,
  source_y : Int,
) -> Unit raise RfbError {
  check_rect(dest, self.width, self.height)
  check_rect({ ..dest, x: source_x, y: source_y, }, self.width, self.height)
  let saved = Array::makei(dest.width * dest.height, i => {
    self.pixels[(source_y + i / dest.width) * self.width +
    source_x +
    i % dest.width]
  })
  self.paint(dest, saved)
}
