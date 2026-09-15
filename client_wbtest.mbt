///|
fn fixture_init() -> Array[Int] {
  let out = banner(8)
  out.append([1, 1, 0, 0, 0, 0, 0, 2, 0, 2])
  out.append([32, 24, 0, 1, 0, 255, 0, 255, 0, 255, 16, 8, 0, 0, 0, 0])
  out.append([0, 0, 0, 1, 65])
  out
}

///|
fn fixture_raw() -> Array[Int] {
  [
    0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 255, 0, 0, 255, 0, 0, 255,
    0, 0, 0, 255, 255, 255, 0,
  ]
}

///|
test "complete session one byte at a time" {
  let c = client(options={ ..default_options(), allow_none: true, })
  for b in fixture_init() {
    c.feed([b])
  }
  assert_true(c.is_ready())
  assert_eq(c.size(), (2, 2))
  assert_eq(c.take_output().length(), 68)
  ignore(c.take_events())
  for b in fixture_raw() {
    c.feed([b])
  }
  assert_eq(c.snapshot(), [0xff0000, 0x00ff00, 255, 0xffffff])
  assert_eq(c.take_events(), [
    Painted({ x: 0, y: 0, width: 2, height: 2, }),
    UpdateComplete,
  ])
  c.finish()
}

///|
test "every cut yields identical session" {
  let bytes = fixture_init()
  bytes.append(fixture_raw())
  for cut in 0..<=bytes.length() {
    let c = client(options={ ..default_options(), allow_none: true, })
    c.feed(bytes[:cut].to_owned())
    c.feed(bytes[cut:].to_owned())
    c.finish()
    assert_eq(c.snapshot(), [0xff0000, 0x00ff00, 255, 0xffffff])
  }
}

///|
test "unsupported update fails closed without altering pixels" {
  let c = client(options={ ..default_options(), allow_none: true, })
  c.feed(fixture_init())
  let bytes = [0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 16]
  try c.feed(bytes) catch {
    e => assert_eq(e, Unsupported(16))
  } noraise {
    _ => fail("unsupported encoding accepted")
  }
  assert_true(c.is_failed())
  assert_eq(c.snapshot(), [0, 0, 0, 0])
}

///|
test "EOF detects truncation at every prefix" {
  let bytes = fixture_init()
  for n in 0..<bytes.length() {
    let c = client(options={ ..default_options(), allow_none: true, })
    c.feed(bytes[:n].to_owned())
    try c.finish() catch {
      _ => assert_true(c.is_failed())
    } noraise {
      _ => fail("accepted partial handshake")
    }
  }
}

///|
test "atomic multirectangle rollback when second rectangle truncated" {
  let c = client(options={ ..default_options(), allow_none: true, })
  c.feed(fixture_init())
  ignore(c.take_events())
  let bytes = fixture_raw()
  bytes[3] = 2
  bytes.append([0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 3, 2])
  c.feed(bytes)
  assert_eq(c.snapshot(), [0, 0, 0, 0])
  assert_eq(c.take_events(), [])
  c.feed([1, 0])
  assert_eq(c.snapshot(), [0x010203, 0x00ff00, 255, 0xffffff])
}

///|
test "invalid options and event backpressure" {
  try client(options={ ..default_options(), max_pixels: 0, }) catch {
    _ => ()
  } noraise {
    _ => fail("accepted zero pixel limit")
  }
  let c = client(options={
    ..default_options(),
    allow_none: true,
    max_buffer: 1024,
    max_text: 64,
  })
  c.feed(fixture_init())
  ignore(c.take_events())
  c.feed(Array::make(256, 2))
  assert_eq(c.take_events().length(), 256)
  c.feed(Array::make(256, 2))
  try c.feed([2]) catch {
    e => assert_eq(e, Limit("event queue: drain events"))
  } noraise {
    _ => fail("unbounded event queue")
  }
}
