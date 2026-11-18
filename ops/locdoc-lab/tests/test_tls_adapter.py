"""Exercise real HTTP framing around the adapter with a bounded fake upstream."""
import http.client
import importlib.util
from pathlib import Path
import threading
import unittest

path = Path(__file__).resolve().parents[3]/'environments/locdoc/aws-emulator/server.py'
spec = importlib.util.spec_from_file_location('tls_adapter', path)
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
DATE = 'Mon, 16 Nov 2026 17:00:00 GMT'


class Response:
    status = 200
    body = b'fixture'
    headers = [('Date', DATE), ('Content-Type', 'text/plain'), ('Content-Length', '7')]

    def read(self, _limit):
        return self.body

    def getheaders(self):
        return self.headers

    def getheader(self, name, default=None):
        return next((v for k, v in self.headers if k.lower() == name.lower()), default)


class Upstream:
    last_request = None

    def __init__(self, *_args, **_kwargs):
        pass

    def request(self, method, path, body, headers):
        type(self).last_request = (method, path, body, headers)

    def getresponse(self):
        return Response()

    def close(self):
        pass


class AdapterTests(unittest.TestCase):
    def setUp(self):
        adapter.Upstream = Upstream
        Response.body = b'fixture'
        Response.headers = [('Date', DATE), ('Content-Length', '7')]
        self.server = adapter.ThreadingHTTPServer(('127.0.0.1', 0), adapter.Proxy)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.client = http.client.HTTPConnection(*self.server.server_address, timeout=3)

    def tearDown(self):
        self.client.close()
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)

    def test_upstream_date_is_forwarded_once(self):
        self.client.request('GET', '/bucket/object')
        response = self.client.getresponse()
        self.assertEqual([v for k, v in response.getheaders() if k.lower() == 'date'], [DATE])
        self.assertEqual(response.read(), b'fixture')

    def test_head_keeps_upstream_object_length_without_a_body(self):
        Response.body = b''
        Response.headers = [('Date', DATE), ('Content-Length', '1024')]
        self.client.request('HEAD', '/bucket/object')
        response = self.client.getresponse()
        self.assertEqual(response.getheader('Content-Length'), '1024')
        self.assertEqual(response.read(), b'')

    def test_chunk_framing_and_signature_headers_are_preserved(self):
        body = b'3\r\nabc\r\n0\r\n\r\n'
        self.client.request('PUT', '/bucket/object?part=1', body=body,
                            headers={'Host':'127.0.0.1:19097', 'Transfer-Encoding':'chunked',
                                     'Authorization':'fixture-signature'})
        response = self.client.getresponse()
        self.assertEqual(response.status, 200)
        response.read()
        method, path, actual, headers = Upstream.last_request
        self.assertEqual((method, path, actual), ('PUT', '/bucket/object?part=1', body))
        self.assertEqual(headers['Host'], '127.0.0.1:19097')
        self.assertEqual(headers['Authorization'], 'fixture-signature')

    def test_oversized_request_is_rejected_before_forwarding(self):
        Upstream.last_request = None
        self.client.request('POST', '/', body=b'', headers={'Content-Length':str(adapter.MAX_BODY+1)})
        response = self.client.getresponse()
        self.assertEqual(response.status, 413)
        response.read()
        self.assertIsNone(Upstream.last_request)


if __name__ == '__main__':
    unittest.main()
