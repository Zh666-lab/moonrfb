'use strict';
// Controlled test server, not a production VNC server. Binds loopback only.
const net=require('node:net');
const assert=require('node:assert/strict');
const u16=n=>[(n>>8)&255,n&255];
const u32=n=>[(n>>>24)&255,(n>>>16)&255,(n>>>8)&255,n&255];
const format=[32,24,0,1,0,255,0,255,0,255,16,8,0,0,0,0];
const init=(w=2,h=2)=>Buffer.from([...u16(w),...u16(h),...format,...u32(7),...Buffer.from('fixture')]);
const rectangle=(x,y,w,h,encoding,payload)=>[...u16(x),...u16(y),...u16(w),...u16(h),...u32(encoding),...payload];
const frame=rects=>Buffer.from([0,0,...u16(rects.length),...rects.flat()]);
const raw=frame([rectangle(0,0,2,2,0,[0,0,255,0,0,255,0,0,255,0,0,0,255,255,255,0])]);
async function start({onInput=()=>{},onRequest=(s)=>s.end(raw)}={}) {
  const sockets=new Set(); const received=[];
  let rejectFailure;
  const failure=new Promise((_,reject)=>{rejectFailure=reject;});
  // Attach rejection consumer immediately; caller still races the original promise.
  failure.catch(()=>{});
  const server=net.createServer(socket=>{
    sockets.add(socket);socket.on('close',()=>sockets.delete(socket));
    socket.on('error',rejectFailure); socket.write('RFB 003.008\n');
    let phase=0,buffer=Buffer.alloc(0),requested=false;
    socket.on('data',chunk=>{
      buffer=Buffer.concat([buffer,chunk]);
      try {
        while(buffer.length) {
          let n;
          if(phase===0) {if(buffer.length<12)return;assert.equal(buffer.subarray(0,12).toString(),'RFB 003.008\n');n=12;phase=1;socket.write(Buffer.from([1,1]));}
          else if(phase===1) {assert.equal(buffer[0],1);n=1;phase=2;socket.write(Buffer.from([0,0,0,0]));}
          else if(phase===2) {assert.ok(buffer[0]===0||buffer[0]===1);n=1;phase=3;socket.write(init());}
          else {
            const tag=buffer[0];
            if(tag===0)n=20;
            else if(tag===2){if(buffer.length<4)return;n=4+buffer.readUInt16BE(2)*4;}
            else if(tag===3)n=10;
            else if(tag===4)n=8;
            else if(tag===5)n=6;
            else if(tag===6){if(buffer.length<8)return;n=8+buffer.readUInt32BE(4);}
            else throw new Error('unexpected client type '+tag);
            if(buffer.length<n)return;
            const packet=Buffer.from(buffer.subarray(0,n));received.push(packet);
            if(tag===0)assert.deepEqual([...packet.subarray(4)],format);
            onInput(packet,socket);
            if(tag===3&&!requested){requested=true;onRequest(socket);}
          }
          buffer=buffer.subarray(n);
        }
      }catch(e){rejectFailure(e);socket.destroy();}
    });
  });
  await new Promise((resolve,reject)=>{server.once('error',reject);server.listen(0,'127.0.0.1',resolve);});
  return {port:server.address().port,received,failure,close:()=>new Promise(resolve=>{for(const s of sockets)s.destroy();server.close(resolve);})};
}
module.exports={start,init,raw,frame,rectangle,u16,u32};
