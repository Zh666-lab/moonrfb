'use strict';
const {spawnSync}=require('node:child_process');const path=require('node:path');const assert=require('node:assert/strict');const fs=require('node:fs');const {rfb,ints}=require('../examples/transport.cjs');
const root=path.join(__dirname,'..');fs.mkdirSync(path.join(root,'output'),{recursive:true});
const binary=path.join(root,'output',process.platform==='win32'?'upstream-des.exe':'upstream-des');
let run=spawnSync('rustc',['--edition=2021',path.join(root,'tools/upstream-des.rs'),'-O','-o',binary],{encoding:'utf8'});
if(run.error)throw run.error;if(run.status!==0)throw new Error(run.stderr);
run=spawnSync(binary,[],{encoding:'utf8'});assert.equal(run.status,0,run.stderr);
let count=0;for(const line of run.stdout.trim().split(/\r?\n/)){
 const [p,c,result]=line.split(' ');
 assert.equal(Buffer.from(rfb.auth(ints(Buffer.from(p,'hex')),ints(Buffer.from(c,'hex')))).toString('hex'),result);count++;
}
assert.equal(count,1000);
const result={reference:'unmodified vnc-rs 0.5.3 DES source compiled by rustc',cases:count,bytes:count*16,mismatches:0};
fs.writeFileSync(path.join(root,'output/upstream-differential.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
