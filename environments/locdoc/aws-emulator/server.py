"""Loopback-only TLS adapter; forwards signed requests without changing auth.

Connect to the private Service, verifying the emulator certificate for 127.0.0.1.
The projected CA is reloaded per request, so session refresh needs no Pod patch.
"""
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import socket
import ssl

MAX_BODY = 64 * 1024 * 1024


class Upstream(http.client.HTTPSConnection):
    def connect(self):
        context = ssl.create_default_context(cafile='/aws-session/ca.pem')
        raw = socket.create_connection(('aws-emulator.aws-emulator.svc.cluster.local', 9297), timeout=30)
        self.sock = context.wrap_socket(raw, server_hostname='127.0.0.1')


class Proxy(BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def forward(self):
        self.connection.settimeout(30)
        conn = None
        try:
            body = b''
            if self.headers.get('Transfer-Encoding', '').lower() == 'chunked':
                pieces = []
                total = 0
                while True:
                    line = self.rfile.readline(8192)
                    length = int(line.strip().split(b';')[0], 16)
                    if length < 0 or total + length > MAX_BODY:
                        self.send_error(413)
                        return
                    pieces.append(line)
                    if length == 0:
                        while True:
                            trailer = self.rfile.readline(8192)
                            if not trailer:
                                raise ValueError('short trailer')
                            pieces.append(trailer)
                            if trailer == b'\r\n':
                                break
                        break
                    chunk = self.rfile.read(length + 2)
                    if len(chunk) != length + 2:
                        raise ValueError('short body')
                    pieces.append(chunk)
                    total += length
                body = b''.join(pieces)
            else:
                length = int(self.headers.get('Content-Length', '0'))
                if length < 0 or length > MAX_BODY:
                    self.send_error(413)
                    return
                body = self.rfile.read(length)
                if len(body) != length:
                    raise ValueError('short body')
            headers = {k: v for k, v in self.headers.items() if k.lower() not in ['connection', 'proxy-connection']}
            conn = Upstream('aws-emulator.aws-emulator.svc.cluster.local', 9297, timeout=30)
            conn.request(self.command, self.path, body=body, headers=headers)
            response = conn.getresponse()
            data = response.read(MAX_BODY + 1)
            if len(data) > MAX_BODY:
                self.send_error(502)
                return
            # Preserve the upstream Date exactly once. Duplicating it causes
            # JavaScript AWS SDK clock-skew correction to produce an invalid date.
            self.send_response_only(response.status)
            for key, value in response.getheaders():
                if key.lower() not in ['transfer-encoding', 'connection', 'content-length']:
                    self.send_header(key, value)
            length = response.getheader('Content-Length', '0') if self.command == 'HEAD' else str(len(data))
            self.send_header('Content-Length', length)
            self.end_headers()
            if self.command != 'HEAD':
                self.wfile.write(data)
        except (OSError, ValueError, http.client.HTTPException):
            self.send_error(502)
        finally:
            if conn:
                conn.close()

    do_GET = do_HEAD = do_POST = do_PUT = do_DELETE = do_PATCH = forward


if __name__ == '__main__':
    ThreadingHTTPServer(('127.0.0.1', 19097), Proxy).serve_forever()
