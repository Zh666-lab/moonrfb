'use strict';
const assert=require('node:assert/strict');const fixture=require('./fixture-server.cjs');const {connect}=require('./transport.cjs');
(async()=>{
 const sequence=[fixture.raw,
  fixture.frame([fixture.rectangle(1,0,1,2,1,[0,0,0,0])]),
  fixture.frame([fixture.rectangle(0,1,2,1,15,[1,0,255,255])])];
 const expected=[[0xff0000,0x00ff00,255,0xffffff],[0xff0000,0xff0000,255,255],[0xff0000,0xff0000,0xffff00,0xffff00]];
 const seen=[];
 const server=await fixture.start({onRequest:async socket=>{
   // Force non-aligned fragments at the transport boundary.
   for(const message of sequence){for(let i=0;i<message.length;i+=3){socket.write(message.subarray(i,i+3));await new Promise(resolve=>setTimeout(resolve,1));}}
   socket.end();
 }});
 try{
  const {done}=connect({port:server.port,allowNone:true,onEvent:(event,{client,rfb})=>{
   if(event==='frame'){const pixels=Array.from(rfb.pixels(client));assert.deepEqual(pixels,expected[seen.length]);seen.push(pixels);}
  }});
  await Promise.race([done,server.failure]);assert.equal(seen.length,3);
  console.log(JSON.stringify({example:'replay',transport:'TCP loopback',verifiedFrames:3,verifiedPixels:12,encodings:['Raw','CopyRect','TRLE'],fragmentBytes:3}));
 }finally{await server.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
