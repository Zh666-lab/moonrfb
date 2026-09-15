///|
/// Negotiated framebuffer metadata. Name is opaque server UTF-8 bytes.
pub(all) struct Screen {
  width : Int
  height : Int
  format : PixelFormat
  name : Array[Int]
} derive(Debug, Eq)

///|
priv enum Phase {
  Version
  Security(Int)
  Challenge(Int)
  SecurityResult(Int)
  Init
  Running
  Failed
  Closed
} derive(Eq)

///|
pub(all) struct Options {
  password : Array[Int]?
  allow_none : Bool
  shared : Bool
  max_pixels : Int
  max_buffer : Int
  max_text : Int
} derive(Debug)

///|
/// Unauthenticated servers are rejected unless explicitly opted in.
pub fn default_options() -> Options {
  {
    password: None,
    allow_none: false,
    shared: true,
    max_pixels: 4194304,
    max_buffer: 33554432,
    max_text: 1048576,
  }
}

///|
fn parse_version(r : Reader) -> Int raise RfbError {
  let b = r.take(12)
  if b[0:4].to_owned() != [82, 70, 66, 32] || b[7] != 46 || b[11] != 10 {
    raise Invalid("RFB version banner")
  }
  for i in [4, 5, 6, 8, 9, 10] {
    if b[i] < 48 || b[i] > 57 {
      raise Invalid("RFB version digits")
    }
  }
  let major = (b[4] - 48) * 100 + (b[5] - 48) * 10 + b[6] - 48
  let minor = (b[8] - 48) * 100 + (b[9] - 48) * 10 + b[10] - 48
  if major != 3 || minor < 3 {
    raise Invalid("unsupported RFB version")
  }
  // Unknown minor versions negotiate down to the newest supported protocol.
  if minor >= 8 {
    8
  } else if minor >= 7 {
    7
  } else {
    3
  }
}

///|
fn banner(minor : Int) -> Array[Int] {
  [82, 70, 66, 32, 48, 48, 51, 46, 48, 48, 48 + minor, 10]
}

///|
fn choose_security(
  r : Reader,
  minor : Int,
  opt : Options,
) -> Int raise RfbError {
  let types = if minor == 3 {
    [r.i32()]
  } else {
    let n = r.u8()
    if n == 0 {
      [0]
    } else {
      r.take(n)
    }
  }
  if types.contains(0) {
    let n = r.i32()
    if n < 0 || n > opt.max_text {
      raise Limit("security failure reason")
    }
    ignore(r.take(n))
    raise AuthenticationFailed
  }
  if opt.password is Some(_) && types.contains(2) {
    return 2
  }
  if opt.allow_none && types.contains(1) {
    return 1
  }
  raise AuthenticationFailed
}

///|
fn read_screen(r : Reader, opt : Options) -> Screen raise RfbError {
  let width = r.u16()
  let height = r.u16()
  if width == 0 || height == 0 || width > opt.max_pixels / height {
    raise Limit("framebuffer")
  }
  let format = read_format(r)
  let n = r.i32()
  if n < 0 || n > opt.max_text {
    raise Limit("desktop name")
  }
  { width, height, format, name: r.take(n), }
}

///|
/// One handshake transition; caller commits only after the entire transition parses.
fn handshake_step(
  r : Reader,
  phase : Phase,
  opt : Options,
) -> (Phase, Array[Int], Screen?) raise RfbError {
  match phase {
    Version => {
      let minor = parse_version(r)
      (Security(minor), banner(minor), None)
    }
    Security(minor) => {
      let kind = choose_security(r, minor, opt)
      let out = if minor == 3 { [] } else { [kind] }
      if kind == 2 {
        (Challenge(minor), out, None)
      } else if minor == 8 {
        (SecurityResult(minor), out, None)
      } else {
        out.push(if opt.shared { 1 } else { 0 })
        (Init, out, None)
      }
    }
    Challenge(minor) => {
      let challenge = r.take(16)
      match opt.password {
        Some(p) => (SecurityResult(minor), vnc_response(p, challenge), None)
        None => raise AuthenticationFailed
      }
    }
    SecurityResult(minor) => {
      let result = r.i32()
      if result != 0 {
        if minor == 8 {
          let n = r.i32()
          if n < 0 || n > opt.max_text {
            raise Limit("authentication reason")
          }
          ignore(r.take(n))
        }
        raise AuthenticationFailed
      }
      (Init, [if opt.shared { 1 } else { 0 }], None)
    }
    Init => {
      let screen = read_screen(r, opt)
      (Running, [], Some(screen))
    }
    _ => raise Invalid("not in handshake")
  }
}
