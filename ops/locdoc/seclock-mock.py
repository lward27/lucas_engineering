#!/usr/bin/env python3
"""Synthetic Seclock-compatible service. It never contacts a supplier."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit, parse_qs
import json, sqlite3, uuid, re
from datetime import datetime, timezone

DB = '/data/orders.db'
PRODUCT = {'uid':'mock-uid-1001','sku':'FX-1001','manufacturer':'Fixture Lock Supply','title':'Fixture Mortise Cylinder','short_description':'Fixture Mortise Cylinder','description':'Synthetic catalog item','image_url':'','sub_type':'Cylinder','msrp':25.0,'pack_weight':1,'pack_height':2,'pack_width':2,'pack_length':4,'unit_of_measure':'Each','unit_of_measure_qty':1}
with sqlite3.connect(DB) as db:
    db.execute('CREATE TABLE IF NOT EXISTS orders (id TEXT PRIMARY KEY, tenant TEXT NOT NULL, body TEXT NOT NULL)')
    if 'tenant' not in {row[1] for row in db.execute('PRAGMA table_info(orders)')}:
        db.execute("ALTER TABLE orders ADD COLUMN tenant TEXT NOT NULL DEFAULT 'legacy'")

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass
    def reply(self, code, body):
        payload=json.dumps(body).encode(); self.send_response(code); self.send_header('Content-Type','application/json'); self.send_header('Content-Length',str(len(payload))); self.end_headers(); self.wfile.write(payload)
    def auth(self):
        token=self.headers.get('Authorization','')
        match=re.fullmatch(r'Bearer mock-([a-f0-9-]{36})',token)
        if not match:
            self.reply(401, {'result':'error','message':'Mock token required'}); return False
        self.tenant=match.group(1)
        return True
    def read_json(self):
        n=int(self.headers.get('Content-Length','0'))
        if n > 1048576: raise ValueError('request too large')
        return json.loads(self.rfile.read(n) or b'{}')
    def do_GET(self):
        u=urlsplit(self.path); q=parse_qs(u.query)
        if u.path == '/health': return self.reply(200,{'status':'ok','mock':True})
        if not self.auth(): return
        if u.path == '/api/items/search':
            query=q.get('query',[''])[0].lower(); items={PRODUCT['uid']:PRODUCT} if query and (query in PRODUCT['sku'].lower() or query in PRODUCT['title'].lower()) else {}
            return self.reply(200,{'result':'success','data':{'items':items}})
        if u.path == '/api/item':
            key=q.get('id',[''])[0]; item=PRODUCT if key.lower() in (PRODUCT['uid'].lower(),PRODUCT['sku'].lower()) else None
            return self.reply(200,{'result':'success','data':{'item':item}})
        if u.path == '/api/orders':
            with sqlite3.connect(DB) as db: orders=[json.loads(row[0]) for row in db.execute('SELECT body FROM orders WHERE tenant=? ORDER BY rowid DESC LIMIT 100',(self.tenant,))]
            return self.reply(200,{'result':'success','data':{'orders':orders}})
        if u.path == '/api/order':
            with sqlite3.connect(DB) as db: row=db.execute('SELECT body FROM orders WHERE id=? AND tenant=?',(q.get('id',[''])[0],self.tenant)).fetchone()
            if not row:return self.reply(404,{'result':'error','message':'Mock order not found'})
            return self.reply(200,{'result':'success','data':json.loads(row[0])})
        self.reply(404,{'result':'error','message':'Unknown mock endpoint'})
    def do_POST(self):
        u=urlsplit(self.path)
        if u.path == '/api/token':
            n=int(self.headers.get('Content-Length','0'))
            if n > 4096: return self.reply(400,{'result':'error'})
            fields=parse_qs(self.rfile.read(n).decode()); match=re.fullmatch(r'fixture\+([a-f0-9-]{36})@example\.invalid',fields.get('email',[''])[0])
            if not match: return self.reply(401,{'result':'error','message':'Mock provider required'})
            return self.reply(200,{'token':'mock-'+match.group(1)})
        if not self.auth(): return
        try: body=self.read_json()
        except (ValueError, json.JSONDecodeError): return self.reply(400,{'result':'error','message':'Invalid request'})
        if u.path == '/api/items/convert-ids':
            items={uid:{'uid':PRODUCT['uid'],'sku':PRODUCT['sku']} for uid in body.get('items',[]) if uid == PRODUCT['uid']}
            return self.reply(200,{'result':'success','data':{'items':items}})
        if u.path == '/api/items/availability':
            values={sku:{'total':25,'warehouse':{'MOCK':25}} for sku in body.get('skus',[]) if sku == PRODUCT['sku']}
            return self.reply(200,{'result':'success','data':{'availability':values}})
        self.reply(404,{'result':'error','message':'Unknown mock endpoint'})
    def do_PUT(self):
        if not self.auth(): return
        if urlsplit(self.path).path != '/api/order': return self.reply(404,{'result':'error'})
        try: body=self.read_json()
        except (ValueError, json.JSONDecodeError): return self.reply(400,{'result':'error','message':'Invalid request'})
        if not body.get('items') or not body.get('shipping'): return self.reply(400,{'result':'error','message':'Items and shipping required'})
        order_id='MOCK-'+uuid.uuid4().hex[:12].upper(); body.update({'id':order_id,'order_id':order_id,'date':datetime.now(timezone.utc).isoformat(),'purchase_order':body.get('po'),'shipping_address':body.get('shipping'),'shipping':0,'subtotal':0,'order_total':0,'status':'Mock submitted','mock':True}); body['items']=[{'sku':item.get('sku'),'ordered':item.get('quantity'),'shipped':0,'backordered':0,'amount':0} for item in body['items']]
        with sqlite3.connect(DB) as db: db.execute('INSERT INTO orders(id,tenant,body) VALUES(?,?,?)',(order_id,self.tenant,json.dumps(body)))
        self.reply(200,{'result':'success','data':{'order_id':order_id},'notices':['Simulated order; no supplier order was placed.']})

ThreadingHTTPServer(('0.0.0.0',8080),Handler).serve_forever()
