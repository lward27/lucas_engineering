#!/usr/bin/env python3
"""Stateful synthetic Stripe subset; unsupported routes use the schema-only mock."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, parse_qs
import http.client, json, sqlite3, uuid
DB='/data/payments.db'
with sqlite3.connect(DB) as db:
    db.execute('CREATE TABLE IF NOT EXISTS objects (id TEXT PRIMARY KEY, kind TEXT NOT NULL, body TEXT NOT NULL)')
def store(obj):
    with sqlite3.connect(DB) as db: db.execute('INSERT OR REPLACE INTO objects(id,kind,body) VALUES(?,?,?)',(obj['id'],obj['object'],json.dumps(obj)))
def load(key, kind):
    with sqlite3.connect(DB) as db: row=db.execute('SELECT body FROM objects WHERE id=? AND kind=?',(key,kind)).fetchone()
    return json.loads(row[0]) if row else None
class Handler(BaseHTTPRequestHandler):
    def log_message(self,*args): pass
    def reply(self,status,obj):
        data=json.dumps(obj).encode(); self.send_response(status); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(data))); self.end_headers(); self.wfile.write(data)
    def permitted(self):
        if self.headers.get('Authorization') != 'Bearer sk_test_123': self.reply(401,{'error':{'message':'Fixture key required','type':'invalid_request_error'}}); return False
        return True
    def params(self):
        n=int(self.headers.get('Content-Length','0'))
        if n>1048576: raise ValueError('body too large')
        return {k:v[-1] for k,v in parse_qs(self.rfile.read(n).decode()).items()}
    def fallback(self):
        n=int(self.headers.get('Content-Length','0')); body=self.rfile.read(n) if n else None
        conn=http.client.HTTPConnection('oms-stripe-mock',12111,timeout=10); conn.request(self.command,self.path,body=body,headers={k:v for k,v in self.headers.items() if k.lower() not in ('host','connection')}); r=conn.getresponse(); data=r.read(); self.send_response(r.status)
        for k,v in r.getheaders():
            if k.lower() not in ('connection','transfer-encoding','content-length'): self.send_header(k,v)
        self.send_header('Content-Length',str(len(data))); self.end_headers(); self.wfile.write(data)
    def do_GET(self):
        u=urlsplit(self.path)
        if u.path=='/health': return self.reply(200,{'mock':True})
        if not self.permitted():return
        if u.path=='/v1/customers':return self.reply(200,{'object':'list','data':[],'has_more':False,'url':'/v1/customers'})
        for prefix,kind in (('/v1/customers/','customer'),('/v1/payment_intents/','payment_intent')):
            if u.path.startswith(prefix):
                obj=load(u.path[len(prefix):],kind)
                return self.reply(200,obj) if obj else self.reply(404,{'error':{'message':'No such mock object','type':'invalid_request_error'}})
        return self.fallback()
    def do_POST(self):
        u=urlsplit(self.path)
        if not self.permitted():return
        if u.path not in ('/v1/customers','/v1/payment_intents') and not (u.path.startswith('/v1/payment_intents/') and u.path.endswith(('/confirm','/capture'))): return self.fallback()
        try: p=self.params()
        except ValueError: return self.reply(400,{'error':{'message':'Invalid input','type':'invalid_request_error'}})
        if u.path=='/v1/customers':
            obj={'id':'cus_mock'+uuid.uuid4().hex,'object':'customer','email':p.get('email'),'name':p.get('name'),'metadata':{}}; store(obj);return self.reply(200,obj)
        if u.path=='/v1/payment_intents':
            try: amount=int(p.get('amount','0'))
            except ValueError: amount=0
            if amount<=0:return self.reply(400,{'error':{'message':'Invalid amount','type':'invalid_request_error'}})
            ident='pi_mock'+uuid.uuid4().hex; metadata={k[9:-1]:v for k,v in p.items() if k.startswith('metadata[') and k.endswith(']')}
            obj={'id':ident,'object':'payment_intent','amount':amount,'currency':p.get('currency','usd'),'customer':p.get('customer'),'metadata':metadata,'status':'requires_confirmation','payment_method':None,'payment_method_types':['card'],'client_secret':ident+'_secret_mock','livemode':False};store(obj);return self.reply(200,obj)
        ident=u.path.split('/')[3];obj=load(ident,'payment_intent')
        if not obj:return self.reply(404,{'error':{'message':'No such mock intent','type':'invalid_request_error'}})
        obj['status']='succeeded';store(obj);return self.reply(200,obj)
ThreadingHTTPServer(('0.0.0.0',12111),Handler).serve_forever()
