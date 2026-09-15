test "TRLE solid raw and packed row alignment" {
  assert_eq(decode_trle([1,3,2,1],rgb32(),3,2),Array::make(6,0x010203))
  assert_eq(decode_trle([0,3,2,1,6,5,4],rgb32(),2,1),[0x010203,0x040506])
  assert_eq(decode_trle([2,0,0,0,255,255,255,0x40,0xa0],rgb32(),3,2),[0,0xffffff,0,0xffffff,0,0xffffff])
}
test "TRLE tile palette reused across 16 pixel boundary" {
  let data = [2,0,0,0,255,255,255,0,0,127,128]
  let pixels = decode_trle(data,rgb32(),17,1)
  assert_eq(pixels.length(),17); assert_eq(pixels[16],0xffffff)
}
