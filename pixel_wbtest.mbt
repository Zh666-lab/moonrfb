///|
test "pixel formats serialize and convert rgb565 and compact endian" {
  let f = rgb32()
  assert_eq(read_format(Reader::new(write_format(f))), f)
  assert_eq(read_pixel(Reader::new([3, 2, 1, 0]), f, false), 0x010203)
  assert_eq(read_pixel(Reader::new([3, 2, 1]), f, true), 0x010203)
  let big = { ..f, big_endian: true, }
  assert_eq(read_pixel(Reader::new([1, 2, 3]), big, true), 0x010203)
  let f16 = {
    bits: 16,
    depth: 16,
    big_endian: false,
    red_max: 31,
    green_max: 63,
    blue_max: 31,
    red_shift: 11,
    green_shift: 5,
    blue_shift: 0,
  }
  f16.validate()
  assert_eq(read_pixel(Reader::new([0, 248]), f16, false), 0xff0000)
}

///|
test "overlapping pixel channels rejected" {
  try { ..rgb32(), red_shift: 8, }.validate() catch {
    e => assert_eq(e, Invalid("overlapping channels"))
  } noraise {
    _ => fail("accepted invalid format")
  }
}
