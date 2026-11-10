# QA server that behaves like GitHub Pages for missing paths: answers with /404.html and status 404.
# Usage (repo root): python3 -I scripts/qa/serve.py 8781
import http.server, os, sys
class H(http.server.SimpleHTTPRequestHandler):
    def send_error(self, code, message=None, explain=None):
        if code == 404 and os.path.exists("404.html"):
            body = open("404.html", "rb").read()
            self.send_response(404); self.send_header("Content-Type", "text/html; charset=utf-8"); self.send_header("Content-Length", str(len(body))); self.end_headers()
            if self.command != "HEAD": self.wfile.write(body)
        else:
            super().send_error(code, message, explain)
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(("0.0.0.0", int(sys.argv[1])), H).serve_forever()
