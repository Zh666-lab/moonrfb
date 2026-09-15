///|
test "TRLE solid raw and packed row alignment" {
  assert_eq(decode_trle([1, 3, 2, 1], rgb32(), 3, 2), Array::make(6, 0x010203))
  assert_eq(decode_trle([0, 3, 2, 1, 6, 5, 4], rgb32(), 2, 1), [
    0x010203, 0x040506,
  ])
  assert_eq(
    decode_trle([2, 0, 0, 0, 255, 255, 255, 0x40, 0xa0], rgb32(), 3, 2),
    [0, 0xffffff, 0, 0xffffff, 0, 0xffffff],
  )
}

///|
test "TRLE tile palette reused across 16 pixel boundary" {
  let data = [2, 0, 0, 0, 255, 255, 255, 0, 0, 127, 128]
  let pixels = decode_trle(data, rgb32(), 17, 1)
  assert_eq(pixels.length(), 17)
  assert_eq(pixels[16], 0xffffff)
}

///|
test "TRLE plain and palette runs" {
  assert_eq(
    decode_trle([128, 3, 2, 1, 5], rgb32(), 3, 2),
    Array::make(6, 0x010203),
  )
  assert_eq(
    decode_trle([130, 0, 0, 0, 255, 255, 255, 128, 1, 129, 3], rgb32(), 3, 2),
    [0, 0, 0xffffff, 0xffffff, 0xffffff, 0xffffff],
  )
}

///|
test "TRLE run overrun fails before writing" {
  try decode_trle([128, 0, 0, 0, 6], rgb32(), 3, 2) catch {
    e => assert_eq(e, Invalid("TRLE run exceeds tile"))
  } noraise {
    _ => fail("accepted overrun")
  }
}

///|
test "TRLE long run requires a zero terminator" {
  assert_eq(
    decode_trle([128, 1, 0, 0, 255, 0], rgb32(), 16, 16),
    Array::make(256, 1),
  )
  try decode_trle([128, 1, 0, 0, 255], rgb32(), 16, 16) catch {
    e => assert_eq(e, NeedMore)
  } noraise {
    _ => fail("missing run terminator")
  }
}
