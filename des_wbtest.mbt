test "DES upstream FIPS known answer" {
  assert_eq(des_block(0x0123456789abcdefUL,0x133457799bbcdff1UL),0x85e813540f0ab405UL)
  assert_eq(vnc_response([],Array::make(16,0)),[140,166,77,233,193,177,35,167,140,166,77,233,193,177,35,167])
}
test "VNC password truncation" {
  let c = Array::makei(16,i => i)
  assert_eq(vnc_response([1,2,3,4,5,6,7,8,9],c),vnc_response([1,2,3,4,5,6,7,8],c))
}
