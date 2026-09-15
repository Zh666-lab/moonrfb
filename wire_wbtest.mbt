test "wire big endian and truncation" {
  let bytes = []
  put16(bytes, 65535); put32(bytes, -239)
  let r = Reader::new(bytes)
  assert_eq(r.u16(), 65535)
  assert_eq(r.i32(), -239)
  assert_eq(try? r.u8(), Err(NeedMore))
  assert_eq(try? Reader::new([256]).u8(), Err(Invalid("byte out of range")))
  assert_eq(Reader::new([1,2,3]).take(2), [1,2])
  check_u16(65535)
  assert_eq(try? check_u16(-1), Err(Invalid("u16 out of range")))
  assert_eq(checked_bytes([0,255]), [0,255])
}
