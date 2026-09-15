'use strict';
// Measures the complete exported decode_raw operation including owned output allocation.
const {performance}=require('node:perf_hooks');const os=require('node:os');const fs=require('node:fs');const path=require('node:path');const assert=require('node:assert/strict');
const {rfb,ints}=require('../examples/transport.cjs');
const w=640,h=480,iterations=30,wire=Int32Array.from({length:w*h*4},(_,i)=>i%4===3?0:(i*37)&255);
let checksum=0;for(let i=0;i<5;i++){const p=rfb.raw(wire,w,h);checksum^=p[0];}
const timings=[];for(let i=0;i<iterations;i++){const begin=performance.now();const p=rfb.raw(wire,w,h);timings.push(performance.now()-begin);assert.equal(p.length,w*h);checksum^=p[p.length-1];}
timings.sort((a,b)=>a-b);
const result={benchmark:'decode_raw owned RGB output, debug JS build',date:new Date().toISOString(),node:process.version,platform:process.platform,arch:process.arch,cpu:os.cpus()[0]?.model,width:w,height:h,warmup:5,iterations,medianMs:timings[Math.floor(iterations/2)],p95Ms:timings[Math.ceil(iterations*.95)-1],medianMpixPerSecond:(w*h/1e6)/(timings[Math.floor(iterations/2)]/1000),processRssBytes:process.memoryUsage().rss,checksum,notes:'RSS is whole-process resident memory at end, NOT decoder peak. No speedup claim or comparison across different machines/builds.'};
fs.mkdirSync(path.join(__dirname,'../output'),{recursive:true});fs.writeFileSync(path.join(__dirname,'../output/benchmark.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
