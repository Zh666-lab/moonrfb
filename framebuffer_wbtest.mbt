test "raw rectangle and owned framebuffer snapshot" {
  let fb = framebuffer(2,2)
  let rect = {x:0,y:0,width:2,height:1}
  let pixels = decode_raw([0,0,255,0,0,255,0,0],rgb32(),2,1)
  fb.paint(rect,pixels)
  assert_eq(fb.snapshot(),[0xff0000,0x00ff00,0,0])
  let copy = fb.snapshot(); copy[0] = 0
  assert_eq(fb.snapshot()[0],0xff0000)
  fb.resize(1,1); assert_eq(fb.size(),(1,1)); assert_eq(fb.snapshot(),[0])
}
test "invalid paint leaves framebuffer untouched" {
  let fb = framebuffer(2,2)
  try fb.paint({x:1,y:1,width:2,height:1},[1,2]) catch {
    _ => assert_eq(fb.snapshot(),[0,0,0,0])
  } noraise { _ => fail("accepted out of bounds") }
}
