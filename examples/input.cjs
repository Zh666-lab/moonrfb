'use strict';
const assert=require('node:assert/strict'); const fixture=require('./fixture-server.cjs');const {connect,ints}=require('./transport.cjs');
(async()=>{
 const input=[];
 const expected=[[4,1,0,0,0,0,255,13],[4,0,0,0,0,0,255,13],[5,1,0,1,0,1],[5,0,0,1,0,1],[6,0,0,0,0,0,0,2,79,75]];
 const server=await fixture.start({onRequest:()=>{},onInput:(packet,socket)=>{
   if(packet[0]>=4){input.push([...packet]);if(input.length===expected.length){assert.deepEqual(input,expected);socket.end(fixture.raw);}}
 }});
 try {
  const {done}=connect({port:server.port,allowNone:true,onEvent:(event,{socket,rfb})=>{
   if(event==='ready')for(const bytes of [rfb.key(0xff0d,true),rfb.key(0xff0d,false),rfb.pointer(1,1,1),rfb.pointer(1,1,0),rfb.cut_text(ints([79,75]))])socket.write(Buffer.from(bytes));
  }});
  await Promise.race([done,server.failure]);assert.deepEqual(input,expected);
  console.log(JSON.stringify({example:'input',transport:'TCP loopback',verifiedMessages:input.length,verifiedBytes:input.reduce((n,p)=>n+p.length,0)}));
 }finally{await server.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
