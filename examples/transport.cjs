// Minimal Node TCP transport: every protocol decision is made by MoonBit.
'use strict';
const net = require('node:net');
const path = require('node:path');
const rfb = require(path.join(__dirname, '../_build/js/debug/build/bridge/bridge.js'));
const ints = bytes => Int32Array.from(bytes);
function connect({host='127.0.0.1',port,password,allowNone=false,feedChunkBytes=65536,onEvent=()=>{}}) {
  if(!Number.isSafeInteger(feedChunkBytes)||feedChunkBytes<1)throw new Error('invalid feed chunk limit');
  const client = rfb.create(allowNone,ints(Buffer.from(password ?? '', 'utf8')),password !== undefined);
  const socket = net.createConnection({host,port});
  let completed = false;
  const done = new Promise((resolve,reject) => {
    socket.setTimeout(10000,()=>socket.destroy(new Error('VNC timeout')));
    socket.on('error',reject);
    socket.on('data',chunk=> {
      try {
        for(let offset=0;offset<chunk.length;offset+=feedChunkBytes) {
        const error = rfb.feed(client,ints(chunk.subarray(offset,offset+feedChunkBytes)));
        const output = rfb.outgoing(client);
        if(output.length) socket.write(Buffer.from(output));
        const events = rfb.events(client);
        for(const event of events) onEvent(event,{client,socket,rfb});
        if(error) throw new Error(error);
        }
      } catch(e) {socket.destroy(e);}
    });
    socket.on('end',()=> {
      const error = rfb.finish(client);
      if(error) reject(new Error(error)); else {completed=true;resolve(client);}
    });
    socket.on('close',()=> {if(!completed) reject(new Error('VNC closed before EOF'));});
  });
  return {client,socket,done};
}
module.exports={rfb,ints,connect};
