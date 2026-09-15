'use strict';
// Independent TRLE encoder supplies expected pixels rather than copying decoder logic.
const assert=require('node:assert/strict');const {rfb,ints}=require('../examples/transport.cjs');
const fs=require('node:fs');const path=require('node:path');
const cp=p=>[p&255,(p>>8)&255,(p>>16)&255];
let seed=6143;const rand=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed;};
let cases=0,pixels=0,negative=0;
function verify(data,w,h,expected){assert.deepEqual(Array.from(rfb.trle(ints(data),w,h)),expected);cases++;pixels+=w*h;}
for(let size=2;size<=16;size++)for(let w=1;w<=16;w++){
 const h=1+rand()%16,palette=Array.from({length:size},()=>rand()&0xffffff),bits=size===2?1:size<=4?2:4;
 const indices=Array.from({length:w*h},()=>rand()%size);const wire=[size,...palette.flatMap(cp)];
 for(let y=0;y<h;y++){let byte=0,filled=0;for(let x=0;x<w;x++){byte=(byte<<bits)|indices[y*w+x];filled+=bits;if(filled===8){wire.push(byte);filled=0;byte=0;}}if(filled)wire.push(byte<<(8-filled));}
 verify(wire,w,h,indices.map(i=>palette[i]));
}
for(let i=0;i<100;i++){
 const w=1+rand()%16,h=1+rand()%16,n=w*h,color=rand()&0xffffff;
 let left=n-1;const run=[];while(left>=255){run.push(255);left-=255;}run.push(left);
 verify([128,...cp(color),...run],w,h,Array(n).fill(color));
 const a=rand()&0xffffff,b=rand()&0xffffff;
 verify([130,...cp(a),...cp(b),129,...run],w,h,Array(n).fill(b));
}
// Packed palette reused across tiles, including through an intervening solid tile.
verify([2,...cp(0),...cp(0xffffff),0,0,1,...cp(1),127,128],33,1,[...Array(16).fill(0),...Array(16).fill(1),0xffffff]);
// Reused RLE palette, first tile 16 pixels, second one pixel.
verify([130,...cp(2),...cp(3),128,15,129,1],17,1,[...Array(16).fill(2),3]);
for(const data of [[17],[126],[127,0],[129,0],[128,0,0,0,255,255],[3,...cp(0),...cp(1),...cp(2),192]]){
 assert.deepEqual(Array.from(rfb.trle(ints(data),1,1)),[]);negative++;
}
const result={reference:'independently generated RFC 6143 TRLE fixtures',seed:6143,cases,pixels,malformedCases:negative,mismatches:0};
fs.mkdirSync(path.join(__dirname,'../output'),{recursive:true});fs.writeFileSync(path.join(__dirname,'../output/trle-corpus.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
