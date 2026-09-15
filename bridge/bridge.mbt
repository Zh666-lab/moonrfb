///|
fn error_text(e : @rfb.RfbError) -> String {
  match e {
    NeedMore => "NeedMore"
    Invalid(s) => "Invalid: " + s
    Limit(s) => "Limit: " + s
    Unsupported(n) => "Unsupported: " + n.to_string()
    AuthenticationFailed => "AuthenticationFailed"
  }
}

///|
pub fn create(
  allow_none : Bool,
  password : Array[Int],
  use_password : Bool,
) -> @rfb.Client {
  @rfb.client(options={
    ..@rfb.default_options(),
    allow_none,
    password: if use_password {
      Some(password)
    } else {
      None
    },
  }) catch {
    _ => abort("invalid client options")
  }
}

///|
pub fn feed(c : @rfb.Client, data : Array[Int]) -> String {
  try {
    c.feed(data)
    ""
  } catch {
    e => error_text(e)
  }
}

///|
pub fn finish(c : @rfb.Client) -> String {
  try {
    c.finish()
    ""
  } catch {
    e => error_text(e)
  }
}

///|
pub fn ready(c : @rfb.Client) -> Bool {
  c.is_ready()
}

///|
pub fn outgoing(c : @rfb.Client) -> Array[Int] {
  c.take_output()
}

///|
pub fn events(c : @rfb.Client) -> Array[String] {
  c
  .take_events()
  .map(e => {
    match e {
      Ready(_) => "ready"
      Painted(_) => "paint"
      Copied(_, _, _) => "copy"
      Resized(_, _) => "resize"
      CursorChanged(_) => "cursor"
      Bell => "bell"
      Clipboard(_) => "clipboard"
      UpdateComplete => "frame"
    }
  })
}

///|
pub fn pixels(c : @rfb.Client) -> Array[Int] {
  c.snapshot() catch {
    _ => []
  }
}

///|
pub fn width(c : @rfb.Client) -> Int {
  let (w, _) = c.size() catch { _ => (0, 0) }
  w
}

///|
pub fn height(c : @rfb.Client) -> Int {
  let (_, h) = c.size() catch { _ => (0, 0) }
  h
}

///|
pub fn key(sym : Int, down : Bool) -> Array[Int] {
  @rfb.key_event(sym.reinterpret_as_uint(), down)
}

///|
pub fn pointer(x : Int, y : Int, buttons : Int) -> Array[Int] {
  @rfb.pointer_event(x, y, buttons) catch {
    _ => []
  }
}

///|
pub fn cut_text(text : Array[Int]) -> Array[Int] {
  @rfb.client_cut_text(text) catch {
    _ => []
  }
}

///|
pub fn refresh(w : Int, h : Int) -> Array[Int] {
  @rfb.update_request(0, 0, w, h, true) catch {
    _ => []
  }
}

///|
pub fn raw(data : Array[Int], w : Int, h : Int) -> Array[Int] {
  @rfb.decode_raw(data, @rfb.rgb32(), w, h) catch {
    _ => []
  }
}

///|
pub fn trle(data : Array[Int], w : Int, h : Int) -> Array[Int] {
  @rfb.decode_trle(data, @rfb.rgb32(), w, h) catch {
    _ => []
  }
}

///|
pub fn auth(password : Array[Int], challenge : Array[Int]) -> Array[Int] {
  @rfb.vnc_response(password, challenge) catch {
    _ => []
  }
}
