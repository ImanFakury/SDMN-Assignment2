import json
from http.server import BaseHTTPRequestHandler, HTTPServer

current_status = "OK"

class StatusHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/api/v1/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
           
            response = {"status": current_status}
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        global current_status
        if self.path == '/api/v1/status':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
           
            try:
                data = json.loads(post_data.decode('utf-8'))
                if "status" in data:
                    current_status = data["status"] 
            except json.JSONDecodeError:
                pass            
            self.send_response(201)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
           
            response = {"status": current_status}
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    server_address = ('0.0.0.0', 8000)
    httpd = HTTPServer(server_address, StatusHandler)
    print("Server listening on port 8000...")
    httpd.serve_forever()
