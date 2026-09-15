///|
/// Transport-independent session. All mutable buffers are owned by the session.
pub struct Client {
  priv options : Options
  priv mut phase : Phase
  priv mut pending : Array[Int]
  priv outgoing : Array[Int]
  priv events : Array[Event]
  priv mut fb : Framebuffer?
  priv mut format : PixelFormat
  priv mut queued_cost : Int
}

///|
pub fn client(options? : Options = default_options()) -> Client raise RfbError {
  if options.max_pixels <= 0 ||
    options.max_pixels > 16777216 ||
    options.max_buffer < 1024 ||
    options.max_buffer > 67108864 ||
    options.max_text < 0 ||
    options.max_text > options.max_buffer {
    raise Invalid("resource limits")
  }
  let password = match options.password {
    Some(p) => Some(checked_bytes(p))
    None => None
  }
  {
    options: { ..options, password, },
    phase: Version,
    pending: [],
    outgoing: [],
    events: [],
    fb: None,
    format: rgb32(),
    queued_cost: 0,
  }
}

///|
pub fn Client::is_ready(self : Client) -> Bool {
  self.phase == Running
}

///|
pub fn Client::is_failed(self : Client) -> Bool {
  self.phase == Failed
}

///|
pub fn Client::take_output(self : Client) -> Array[Int] {
  let result = self.outgoing.copy()
  self.outgoing.clear()
  result
}

///|
pub fn Client::take_events(self : Client) -> Array[Event] {
  let result = self.events.copy()
  self.events.clear()
  self.queued_cost = 0
  result
}

///|
pub fn Client::snapshot(self : Client) -> Array[Int] raise RfbError {
  match self.fb {
    Some(f) => f.snapshot()
    None => raise Invalid("not initialized")
  }
}

///|
pub fn Client::size(self : Client) -> (Int, Int) raise RfbError {
  match self.fb {
    Some(f) => f.size()
    None => raise Invalid("not initialized")
  }
}

///| Feed arbitrary byte fragments. Malformed input poisons the session.

///|
/// Take events/output even if a later message in this feed fails.
pub fn Client::feed(self : Client, data : Array[Int]) -> Unit raise RfbError {
  if self.phase == Failed || self.phase == Closed {
    raise Invalid("session closed or failed")
  }
  errdefer {
    self.phase = Failed
    self.pending.clear()
  }
  if data.length() > self.options.max_buffer - self.pending.length() {
    raise Limit("receive buffer")
  }
  self.pending.append(checked_bytes(data))
  let mut offset = 0
  while offset < self.pending.length() {
    let r = { data: self.pending, pos: offset, }
    let complete = try {
      if self.phase == Running {
        let (w, h) = self.size()
        let msg = server_message(r, self.format, w, h, self.options)
        self.apply_message(msg)
      } else {
        let (next, output, screen) = handshake_step(r, self.phase, self.options)
        self.phase = next
        self.outgoing.append(output)
        match screen {
          Some(s) => {
            self.fb = Some(
              framebuffer(s.width, s.height, max_pixels=self.options.max_pixels),
            )
            self.events.push(Ready(s))
            self.format = rgb32()
            self.outgoing.append(set_pixel_format(self.format))
            self.outgoing.append(set_encodings())
            self.outgoing.append(update_request(0, 0, s.width, s.height, false))
          }
          None => ()
        }
      }
      true
    } catch {
      NeedMore => false
      e => raise e
    }
    if !complete {
      break
    }
    offset = r.pos
  }
  self.pending = self.pending[offset:].to_owned()
}

///|
/// EOF at a partial handshake/message is an error, not silent success.
pub fn Client::finish(self : Client) -> Unit raise RfbError {
  if self.phase != Running || !self.pending.is_empty() {
    self.phase = Failed
    self.pending.clear()
    raise Invalid("truncated session")
  }
  self.phase = Closed
}

///|
fn Client::apply_message(
  self : Client,
  msg : ServerMessage,
) -> Unit raise RfbError {
  let (count, cost) = match msg {
    Ring => (1, 1)
    Text(bytes) => (1, bytes.length() + 1)
    Frame(updates) => {
      let mut cost = updates.length() + 1
      for u in updates {
        if u is SetCursor(c) {
          cost += c.pixels.length() * 2
        }
      }
      (updates.length() + 1, cost)
    }
  }
  if count > 8192 - self.events.length() ||
    cost > self.options.max_buffer / 4 - self.queued_cost {
    raise Limit("event queue: drain events")
  }
  self.queued_cost += cost
  match msg {
    Ring => self.events.push(Bell)
    Text(bytes) => self.events.push(Clipboard(bytes))
    Frame(updates) => {
      let fb = match self.fb {
        Some(f) => f
        None => raise Invalid("not initialized")
      }
      for update in updates {
        match update {
          Paint(rect, pixels) => {
            fb.paint(rect, pixels)
            self.events.push(Painted(rect))
          }
          Copy(rect, x, y) => {
            fb.copy_rect(rect, x, y)
            self.events.push(Copied(rect, x, y))
          }
          Resize(w, h) => {
            fb.resize(w, h)
            self.events.push(Resized(w, h))
          }
          SetCursor(cursor) => self.events.push(CursorChanged(cursor))
        }
      }
      self.events.push(UpdateComplete)
    }
  }
}
