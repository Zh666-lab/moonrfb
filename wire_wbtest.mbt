///|
test "wire big endian and truncation" {
  let bytes = []
  put16(bytes, 65535)
  put32(bytes, -239)
  let r = Reader::new(bytes)
  assert_eq(r.u16(), 65535)
  assert_eq(r.i32(), -239)
  try r.u8() catch {
    e => assert_eq(e, NeedMore)
  } noraise {
    _ => fail("expected truncation")
  }
  try Reader::new([256]).u8() catch {
    e => assert_eq(e, Invalid("byte out of range"))
  } noraise {
    _ => fail("invalid byte")
  }
  assert_eq(Reader::new([1, 2, 3]).take(2), [1, 2])
  check_u16(65535)
  try check_u16(-1) catch {
    e => assert_eq(e, Invalid("u16 out of range"))
  } noraise {
    _ => fail("invalid u16")
  }
  assert_eq(checked_bytes([0, 255]), [0, 255])
}
