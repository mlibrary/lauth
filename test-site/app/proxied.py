from http.server import HTTPServer, BaseHTTPRequestHandler
from sys import argv

BIND_HOST = '0.0.0.0'
PORT = 8008

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(("%s" % self.headers).encode('utf-8'))

print(f'Listening on http://{BIND_HOST}:{PORT}\n')

httpd = HTTPServer((BIND_HOST, PORT), SimpleHTTPRequestHandler)
httpd.serve_forever()
