///|
test "server clipboard preserves bytes and cursor masks ignore row padding" {
  match
    server_message(
      Reader::new([3, 0, 0, 0, 0, 0, 0, 2, 65, 255]),
      rgb32(),
      1,
      1,
      default_options(),
    ) {
    Text(bytes) => assert_eq(bytes, [65, 255])
    _ => fail("wrong event")
  }
  let c = read_cursor(
    Reader::new([0, 0, 255, 0, 255, 0, 0, 0, 0x80, 0x00]),
    rgb32(),
    { x: 0, y: 0, width: 1, height: 2, },
    default_options(),
  )
  assert_eq(c.alpha, [1, 0])
  assert_eq(c.pixels, [0xff0000, 255])
}

///|
test "zero size cursor is a valid hide cursor event" {
  let c = read_cursor(
    Reader::new([]),
    rgb32(),
    { x: 0, y: 0, width: 0, height: 0, },
    default_options(),
  )
  assert_eq(c.pixels, [])
}
