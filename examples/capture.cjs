'use strict';
const fs=require('node:fs'); const path=require('node:path'); const assert=require('node:assert/strict');
const {connect,rfb}=require('./transport.cjs');const fixture=require('./fixture-server.cjs');
(async()=>{
 const server=await fixture.start();
 try {
  const {done}=connect({port:server.port,allowNone:true});
  const client=await Promise.race([done,server.failure]);
  const pixels=Array.from(rfb.pixels(client));assert.deepEqual(pixels,[0xff0000,0x00ff00,255,0xffffff]);
  const image=Buffer.concat([Buffer.from('P6\n2 2\n255\n'),Buffer.from(pixels.flatMap(p=>[(p>>16)&255,(p>>8)&255,p&255]))]);
  const out=path.join(__dirname,'../output');fs.mkdirSync(out,{recursive:true});fs.writeFileSync(path.join(out,'desktop.ppm'),image);
  console.log(JSON.stringify({example:'capture',transport:'TCP loopback',width:rfb.width(client),height:rfb.height(client),verifiedPixels:pixels.length,output:'output/desktop.ppm'}));
 }finally{await server.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
