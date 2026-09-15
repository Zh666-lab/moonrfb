///| Wire failures are explicit. NeedMore is recoverable only before session EOF.
pub(all) suberror RfbError {
  NeedMore
  Invalid(String)
  Limit(String)
  Unsupported(Int)
  AuthenticationFailed
} derive(Debug, Eq)

///| Internal cursor over unsigned byte values. Transactional callers commit position only on success.
priv struct Reader {
  data : Array[Int]
  mut pos : Int
}

///|
fn Reader::new(data : Array[Int]) -> Reader { { data, pos: 0 } }

///|
fn Reader::u8(self : Reader) -> Int raise RfbError {
  if self.pos >= self.data.length() { raise NeedMore }
  let value = self.data[self.pos]
  if value < 0 || value > 255 { raise Invalid("byte out of range") }
  self.pos += 1
  value
}

///|
fn Reader::u16(self : Reader) -> Int raise RfbError { (self.u8() << 8) | self.u8() }

///|
fn Reader::i32(self : Reader) -> Int raise RfbError {
  (self.u8() << 24) | (self.u8() << 16) | (self.u8() << 8) | self.u8()
}

///|
fn Reader::take(self : Reader, n : Int) -> Array[Int] raise RfbError {
  if n < 0 { raise Invalid("negative length") }
  if n > self.data.length() - self.pos { raise NeedMore }
  Array::makei(n, _ => self.u8())
}

///|
fn put16(out : Array[Int], value : Int) -> Unit {
  out.push((value >> 8) & 255); out.push(value & 255)
}

///|
fn put32(out : Array[Int], value : Int) -> Unit {
  out.push((value >> 24) & 255); out.push((value >> 16) & 255); put16(out, value)
}

///|
fn check_u16(n : Int) -> Unit raise RfbError {
  if n < 0 || n > 65535 { raise Invalid("u16 out of range") }
}

///| Copy bytes at the boundary to prevent mutation by callers.
fn checked_bytes(data : Array[Int]) -> Array[Int] raise RfbError {
  for n in data { if n < 0 || n > 255 { raise Invalid("byte out of range") } }
  data.copy()
}

