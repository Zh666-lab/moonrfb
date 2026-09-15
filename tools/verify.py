#!/usr/bin/env python3
"""Fail-fast local verification. Native runtime/Rust deferral is explicit."""
import argparse,json,pathlib,subprocess,datetime,sys
p=argparse.ArgumentParser();p.add_argument('--defer-native',action='store_true');p.add_argument('--defer-rust',action='store_true');a=p.parse_args()
root=pathlib.Path(__file__).resolve().parent.parent;out=root/'output';out.mkdir(exist_ok=True)
report={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'commands':[],'deferred':[],'passed':False}
def run(cmd):
 print('+ '+' '.join(cmd),flush=True)
 r=subprocess.run(cmd,cwd=str(root),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,encoding='utf8',errors='replace')
 log='verify-%02d.log'%len(report['commands']);(out/log).write_text(r.stdout,encoding='utf8');report['commands'].append({'command':cmd,'exit':r.returncode,'log':log})
 if r.returncode:raise RuntimeError(r.stdout)
 return r.stdout
try:
 report['toolchain']=run(['moon','version','--all'])
 run(['moon','fmt','--check'])
 for t in ['wasm-gc','wasm','js','native']:
  run(['moon','check','--target',t,'--deny-warn'])
  if t=='native' and a.defer_native:report['deferred'].append('native build/test: no local C compiler; required CI job');continue
  run(['moon','build','--target',t,'--deny-warn']);run(['moon','test','--target',t,'--deny-warn'])
 for example in ['capture','input','replay']:run(['node','examples/'+example+'.cjs'])
 for name in ['differential','trle-corpus','benchmark']:run(['node','tools/'+name+'.cjs'])
 if a.defer_rust:report['deferred'].append('compiled original Rust DES oracle: no local rustc; required CI JS job')
 else:run(['node','tools/upstream-differential.cjs'])
 run(['git','diff','--check']);report['passed']=True
except Exception as e:report['error']=str(e);print(e,file=sys.stderr)
finally:(out/'verification-local.json').write_text(json.dumps(report,indent=2),encoding='utf8')
sys.exit(0 if report['passed'] else 1)
