# QA server that behaves like GitHub Pages: gzips text responses, and answers missing paths with /404.html and status 404.
# Usage (repo root): python3 -I scripts/qa/serve.py 8781
import gzip, http.server, os, sys
TEXT = (".html", ".css", ".js", ".json", ".svg", ".xml")
class H(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path) and self.path.split("?")[0].endswith("/"):
            path = os.path.join(path, "index.html")
        if not (os.path.isfile(path) and path.endswith(TEXT) and "gzip" in self.headers.get("Accept-Encoding", "")):
            return super().do_GET()  # binary file, directory redirect, no gzip asked, or 404
        body = gzip.compress(open(path, "rb").read(), 6)
        self.send_response(200); self.send_header("Content-Type", self.guess_type(path)); self.send_header("Content-Encoding", "gzip"); self.send_header("Content-Length", str(len(body))); self.end_headers()
        self.wfile.write(body)
    def send_error(self, code, message=None, explain=None):
        if code == 404 and os.path.exists("404.html"):
            body = open("404.html", "rb").read()
            self.send_response(404); self.send_header("Content-Type", "text/html; charset=utf-8"); self.send_header("Content-Length", str(len(body))); self.end_headers()
            if self.command != "HEAD": self.wfile.write(body)
        else:
            super().send_error(code, message, explain)
    def log_message(self, *a): pass
http.server.ThreadingHTTPServer(("0.0.0.0", int(sys.argv[1])), H).serve_forever()
