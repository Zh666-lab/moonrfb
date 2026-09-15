'use strict';
// Compare to unmodified noVNC 1.7.0 modules; deterministic seed recorded below.
const assert=require('node:assert/strict'); const fs=require('node:fs');const path=require('node:path');const {pathToFileURL}=require('node:url');
const {rfb,ints}=require('../examples/transport.cjs');
const fixture=require('../examples/fixture-server.cjs');
let seed=0x42673;const rand=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};
(async()=>{
 const base=path.resolve(__dirname,'../node_modules/@novnc/novnc/core');
 const {DESECBCipher}=await import(pathToFileURL(path.join(base,'crypto/des.js')));
 const {default:Raw}=await import(pathToFileURL(path.join(base,'decoders/raw.js')));
 const {default:Copy}=await import(pathToFileURL(path.join(base,'decoders/copyrect.js')));
 let authBytes=0,rawPixels=0,copyPixels=0;
 for(let i=0;i<1000;i++){
  const password=Uint8Array.from({length:i%17},()=>rand()>>>24),challenge=Uint8Array.from({length:16},()=>rand()>>>24);
  const key=new Uint8Array(8);key.set(password.subarray(0,8));
  const expected=DESECBCipher.importKey(key).encrypt({},challenge);
  assert.deepEqual(Array.from(rfb.auth(ints(password),ints(challenge))),Array.from(expected));authBytes+=16;
 }
 for(let i=0;i<250;i++){
  const w=1+rand()%31,h=1+rand()%19;
  // MoonRFB defaults BGRx; noVNC expects RGBx. Generate equivalent wire images.
  const pixels=Array.from({length:w*h},()=>rand()&0xffffff);
  const bgr=Uint8Array.from(pixels.flatMap(p=>[p&255,(p>>8)&255,p>>16,0]));
  const rgb=Uint8Array.from(pixels.flatMap(p=>[p>>16,(p>>8)&255,p&255,0]));
  let offset=0;const reference=[];
  const socket={rQwait:(_,n)=>rgb.length-offset<n,rQshiftBytes:n=>{const b=rgb.slice(offset,offset+n);offset+=n;return b;}};
  const display={blitImage:(x,y,width,height,data)=>{for(let j=0;j<width;j++)reference.push((data[j*4]<<16)|(data[j*4+1]<<8)|data[j*4+2]);}};
  assert.equal(new Raw().decodeRect(0,0,w,h,socket,display,24),true);
  assert.deepEqual(Array.from(rfb.raw(ints(bgr),w,h)),reference);rawPixels+=pixels.length;
 }
 for(let i=0;i<100;i++){
  const client=rfb.create(true,ints([]),false);
  const init=Buffer.concat([Buffer.from('RFB 003.008\n'),Buffer.from([1,1,0,0,0,0]),fixture.init()]);
  assert.equal(rfb.feed(client,ints(init)), '');rfb.events(client);
  assert.equal(rfb.feed(client,ints(fixture.raw)),'');rfb.events(client);
  const sx=rand()%2,sy=rand()%2,dx=rand()%2,dy=rand()%2;
  const data=[...fixture.u16(sx),...fixture.u16(sy)];let offset=0;
  const reference=Array.from(rfb.pixels(client));
  const socket={rQwait:()=>false,rQshift16:()=>{const n=(data[offset]<<8)|data[offset+1];offset+=2;return n;}};
  let observed;
  new Copy().decodeRect(dx,dy,1,1,socket,{copyImage:(x,y,a,b,w,h)=>{observed=[x,y,a,b,w,h];reference[b*2+a]=reference[y*2+x];}},24);
  assert.deepEqual(observed,[sx,sy,dx,dy,1,1]);
  assert.equal(rfb.feed(client,ints(fixture.frame([fixture.rectangle(dx,dy,1,1,1,data)]))), '');
  assert.deepEqual(Array.from(rfb.pixels(client)),reference);copyPixels+=4;
 }
 const result={reference:'noVNC 1.7.0 unmodified modules',seed:'0x42673',auth:{cases:1000,bytes:authBytes},raw:{cases:250,pixels:rawPixels},copyRect:{cases:100,framebufferPixels:copyPixels},mismatches:0,limitations:'Not a full noVNC GUI interoperability test; Raw equivalent RGB/BGR wire formats; CopyRect display is a test double; TRLE tested separately against generated RFC fixtures.'};
 fs.mkdirSync(path.join(__dirname,'../output'),{recursive:true});fs.writeFileSync(path.join(__dirname,'../output/differential.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
})().catch(e=>{console.error(e);process.exitCode=1;});
