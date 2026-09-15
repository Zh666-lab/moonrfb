///|
test "input messages exact wire bytes" {
  assert_eq(key_event(0xff0dU, true), [4, 1, 0, 0, 0, 0, 255, 13])
  assert_eq(key_event(0xffffffffU, false), [4, 0, 0, 0, 255, 255, 255, 255])
  assert_eq(pointer_event(640, 480, 1), [5, 1, 2, 128, 1, 224])
  assert_eq(client_cut_text([65, 255]), [6, 0, 0, 0, 0, 0, 0, 2, 65, 255])
  assert_eq(update_request(0, 0, 640, 480, true), [
    3, 1, 0, 0, 0, 0, 2, 128, 1, 224,
  ])
  assert_eq(set_pixel_format(rgb32()).length(), 20)
  assert_eq(set_encodings().length(), 24)
}
