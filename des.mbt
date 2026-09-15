// Copyright (c) 2016 Boucher, Antoni <bouanto@zoho.com>
// MIT licensed; permission notice reproduced in vendor/DES-LICENSE.
// Ported from vnc-rs 0.5.3 src/client/security/des.rs.
// Tables retained; arithmetic is right-aligned rather than upstream left-aligned.

///|
fn des_ip() -> Array[Int] {
  [
    58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4, 62, 54, 46, 38,
    30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8, 57, 49, 41, 33, 25, 17, 9, 1, 59,
    51, 43, 35, 27, 19, 11, 3, 61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31,
    23, 15, 7,
  ]
}

///|
fn des_fp() -> Array[Int] {
  [
    40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31, 38, 6, 46, 14,
    54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29, 36, 4, 44, 12, 52, 20, 60, 28,
    35, 3, 43, 11, 51, 19, 59, 27, 34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49,
    17, 57, 25,
  ]
}

///|
fn des_e() -> Array[Int] {
  [
    32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9, 8, 9, 10, 11, 12, 13, 12, 13, 14, 15, 16,
    17, 16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25, 24, 25, 26, 27, 28, 29, 28,
    29, 30, 31, 32, 1,
  ]
}

///|
fn des_p() -> Array[Int] {
  [
    16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24, 14, 32,
    27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25,
  ]
}

///|
fn des_pc1() -> Array[Int] {
  [
    57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26, 18, 10, 2, 59, 51, 43, 35,
    27, 19, 11, 3, 60, 52, 44, 36, 63, 55, 47, 39, 31, 23, 15, 7, 62, 54, 46, 38,
    30, 22, 14, 6, 61, 53, 45, 37, 29, 21, 13, 5, 28, 20, 12, 4,
  ]
}

///|
fn des_pc2() -> Array[Int] {
  [
    14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4, 26, 8, 16, 7, 27,
    20, 13, 2, 41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48, 44, 49, 39, 56, 34,
    53, 46, 42, 50, 36, 29, 32,
  ]
}

///|
fn des_boxes() -> Array[Array[Array[Int]]] {
  [
    [
      [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
      [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
      [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
      [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13],
    ],
    [
      [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
      [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
      [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
      [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9],
    ],
    [
      [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
      [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
      [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
      [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12],
    ],
    [
      [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
      [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
      [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
      [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14],
    ],
    [
      [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
      [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
      [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
      [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3],
    ],
    [
      [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
      [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
      [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
      [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13],
    ],
    [
      [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
      [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
      [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
      [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12],
    ],
    [
      [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
      [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
      [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
      [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11],
    ],
  ]
}

///|
fn permute(value : UInt64, width : Int, table : Array[Int]) -> UInt64 {
  let mut out = 0UL
  for bit in table {
    out = (out << 1) | ((value >> (width - bit)) & 1UL)
  }
  out
}

///|
fn des_block(block : UInt64, key : UInt64) -> UInt64 {
  let k = permute(key, 64, des_pc1())
  let mut c = k >> 28
  let mut d = k & 0xfffffffUL
  let subkeys = []
  for shift in [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1] {
    c = ((c << shift) | (c >> (28 - shift))) & 0xfffffffUL
    d = ((d << shift) | (d >> (28 - shift))) & 0xfffffffUL
    subkeys.push(permute((c << 28) | d, 56, des_pc2()))
  }
  let start = permute(block, 64, des_ip())
  let mut left = start >> 32
  let mut right = start & 0xffffffffUL
  let boxes = des_boxes()
  for subkey in subkeys {
    let expanded = permute(right, 32, des_e()) ^ subkey
    let mut s = 0UL
    for i in 0..<8 {
      let bits = ((expanded >> (42 - i * 6)) & 63UL).to_int()
      let row = ((bits >> 4) & 2) | (bits & 1)
      let col = (bits >> 1) & 15
      s = (s << 4) | boxes[i][row][col].to_uint64()
    }
    let next = left ^ permute(s, 32, des_p())
    left = right
    right = next
  }
  permute((right << 32) | left, 64, des_fp())
}

///| Classic VNC authentication is legacy DES, NOT secure transport encryption.

///|
/// Password is bytes; first eight bytes are used by the protocol.
pub fn vnc_response(
  password : Array[Int],
  challenge : Array[Int],
) -> Array[Int] raise RfbError {
  if challenge.length() != 16 {
    raise Invalid("challenge must be 16 bytes")
  }
  ignore(checked_bytes(password))
  ignore(checked_bytes(challenge))
  let mut key = 0UL
  for i in 0..<8 {
    let b = if i < password.length() { password[i] } else { 0 }
    let mut reversed = 0
    for bit in 0..<8 {
      reversed = (reversed << 1) | ((b >> bit) & 1)
    }
    key = (key << 8) | reversed.to_uint64()
  }
  let out = []
  for base in [0, 8] {
    let mut block = 0UL
    for i in 0..<8 {
      block = (block << 8) | challenge[base + i].to_uint64()
    }
    let cipher = des_block(block, key)
    for i in 0..<8 {
      out.push(((cipher >> (56 - i * 8)) & 255UL).to_int())
    }
  }
  out
}
