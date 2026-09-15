///| True-color pixel format. Validate before reading any pixel.
pub(all) struct PixelFormat {
  bits : Int
  depth : Int
  big_endian : Bool
  red_max : Int
  green_max : Int
  blue_max : Int
  red_shift : Int
  green_shift : Int
  blue_shift : Int
} derive(Debug, Eq)

///| Canonical wire format: little endian B,G,R,padding, represented as RGB integers.
pub fn rgb32() -> PixelFormat {
  { bits: 32, depth: 24, big_endian: false, red_max: 255, green_max: 255, blue_max: 255, red_shift: 16, green_shift: 8, blue_shift: 0 }
}

///|
pub fn PixelFormat::validate(self : PixelFormat) -> Unit raise RfbError {
  if !(self.bits == 8 || self.bits == 16 || self.bits == 32) || self.depth <= 0 || self.depth > self.bits { raise Invalid("pixel depth") }
  let maxima = [self.red_max, self.green_max, self.blue_max]
  let shifts = [self.red_shift, self.green_shift, self.blue_shift]
  let mut used : UInt = 0
  let mut significant = 0
  for i in 0..<3 {
    let max = maxima[i]
    if max <= 0 || max > 65535 || (max & (max + 1)) != 0 { raise Invalid("channel maximum") }
    let mut width = 0
    let mut v = max
    while v > 0 { width += 1; v = v >> 1 }
    if shifts[i] < 0 || shifts[i] + width > self.bits { raise Invalid("channel shift") }
    let mask = max.to_uint() << shifts[i]
    if (mask & used) != 0 { raise Invalid("overlapping channels") }
    used = used | mask
    significant += width
  }
  if significant > self.depth { raise Invalid("pixel depth smaller than channels") }
}

///|
fn read_format(r : Reader) -> PixelFormat raise RfbError {
  let bits = r.u8(); let depth = r.u8(); let endian = r.u8(); let color = r.u8()
  if endian > 1 || color != 1 { raise Invalid("indexed color or endian flag") }
  let red_max = r.u16(); let green_max = r.u16(); let blue_max = r.u16()
  let red_shift = r.u8(); let green_shift = r.u8(); let blue_shift = r.u8()
  ignore(r.take(3))
  let f = { bits, depth, big_endian: endian == 1, red_max, green_max, blue_max, red_shift, green_shift, blue_shift }
  f.validate()
  f
}

///|
fn write_format(f : PixelFormat) -> Array[Int] raise RfbError {
  f.validate()
  let b = [f.bits, f.depth, if f.big_endian {1} else {0}, 1]
  put16(b,f.red_max); put16(b,f.green_max); put16(b,f.blue_max)
  b.append([f.red_shift,f.green_shift,f.blue_shift,0,0,0]); b
}

///|
fn read_pixel(r : Reader, f : PixelFormat, compact : Bool) -> Int raise RfbError {
  // CPIXEL drops an unused extreme byte only for 32-bit true-color depth <= 24.
  let mask = (f.red_max.to_uint() << f.red_shift) | (f.green_max.to_uint() << f.green_shift) | (f.blue_max.to_uint() << f.blue_shift)
  let omit_high = compact && f.bits == 32 && f.depth <= 24 && (mask & 0xff000000U) == 0
  let omit_low = compact && f.bits == 32 && f.depth <= 24 && !omit_high && (mask & 255U) == 0
  let mut v : UInt = 0
  for i in 0..<(f.bits / 8) {
    let shift = if f.big_endian { f.bits - 8 - i * 8 } else { i * 8 }
    if !(omit_high && shift == 24) && !(omit_low && shift == 0) { v = v | (r.u8().to_uint() << shift) }
  }
  let red = ((v >> f.red_shift) & f.red_max.to_uint()).to_int() * 255 / f.red_max
  let green = ((v >> f.green_shift) & f.green_max.to_uint()).to_int() * 255 / f.green_max
  let blue = ((v >> f.blue_shift) & f.blue_max.to_uint()).to_int() * 255 / f.blue_max
  (red << 16) | (green << 8) | blue
}
