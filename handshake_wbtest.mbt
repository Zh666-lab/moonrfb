test "version negotiation and downgrade" {
  for v in [3,7,8,9] { assert_eq(parse_version(Reader::new(banner(v))),if v == 9 {8} else {v}) }
  let opt = { ..default_options(), allow_none:true }
  assert_eq(choose_security(Reader::new([0,0,0,1]),3,opt),1)
  assert_eq(choose_security(Reader::new([2,19,1]),8,opt),1)
  let auth = { ..opt,password:Some([65]) }
  assert_eq(choose_security(Reader::new([2,1,2]),8,auth),2)
}
test "security fails closed by default" {
  try choose_security(Reader::new([1,1]),8,default_options()) catch {
    e => assert_eq(e, AuthenticationFailed)
  } noraise { _ => fail("accepted no authentication") }
}
test "3.3 and 3.7 none have no security result" {
  for minor in [3,7] {
    let bytes = if minor == 3 {[0,0,0,1]} else {[1,1]}
    let (phase,out,_) = handshake_step(Reader::new(bytes),Security(minor),{..default_options(),allow_none:true})
    assert_eq(phase,Init)
    assert_eq(out,if minor == 3 {[1]} else {[1,1]})
  }
}
test "3.8 VNC challenge then security result" {
  let opt = {..default_options(),password:Some([112,97,115,115])}
  let (phase,response,_) = handshake_step(Reader::new(Array::make(16,0)),Challenge(8),opt)
  assert_eq(phase,SecurityResult(8)); assert_eq(response.length(),16)
  let (phase,out,_) = handshake_step(Reader::new([0,0,0,0]),phase,opt)
  assert_eq(phase,Init); assert_eq(out,[1])
}
