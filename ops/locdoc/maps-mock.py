#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args): pass
    def do_GET(self):
        if self.path == '/health': body={'mock':True}
        elif self.path == '/distance': body={'status':'OK','distance':{'text':'1 mi (simulated)','value':1609},'duration':{'text':'3 min (simulated)','value':180}}
        else:
            self.send_error(404);return
        data=json.dumps(body).encode();self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
HTTPServer(('0.0.0.0',8080),Handler).serve_forever()
