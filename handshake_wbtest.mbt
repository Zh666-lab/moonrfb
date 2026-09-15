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
