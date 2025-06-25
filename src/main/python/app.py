from flask import Flask, jsonify, request
import requests
import json
from datetime import datetime

app = Flask(__name__)

class JavaAppConnector:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.timeout = 10
    
    def get_data(self, endpoint):
        try:
            url = f"{self.base_url}/{endpoint}"
            print(f"🔗 WSL→Windows: {url}")
            response = self.session.get(url)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ Error connecting to Windows Tomcat: {e}")
            return None
    
    def send_data(self, endpoint, data):
        try:
            url = f"{self.base_url}/{endpoint}"
            print(f"📤 WSL→Windows POST: {url}")
            headers = {'Content-Type': 'application/json'}
            response = self.session.post(url, json=data, headers=headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"❌ Error sending to Windows Tomcat: {e}")
            return None

# Windows IP specific pentru setup-ul tău
WINDOWS_IP = "172.25.0.1"
java_connector = JavaAppConnector(f"http://{WINDOWS_IP}:9999/Proiect")

@app.route("/test-connection")
def test_connection():
    """Test all possible Windows Tomcat endpoints"""
    test_urls = [
        f"http://{WINDOWS_IP}:9999/",
        f"http://{WINDOWS_IP}:9999/Proiect/",
        f"http://{WINDOWS_IP}:9999/Proiect/DataServlet",
        f"http://{WINDOWS_IP}:8080/Proiect/DataServlet",  # Default Tomcat port
        f"http://{WINDOWS_IP}:8082/Proiect/DataServlet",  # Shutdown port (just in case)
    ]
    
    results = []
    successful_urls = []
    
    for url in test_urls:
        try:
            response = requests.get(url, timeout=5)
            result = {
                "url": url,
                "status": "SUCCESS ✅",
                "status_code": response.status_code,
                "content_type": response.headers.get('content-type', 'unknown'),
                "server": response.headers.get('server', 'unknown'),
                "response_preview": response.text[:150] if response.text else "Empty response"
            }
            results.append(result)
            successful_urls.append(url)
            
        except requests.exceptions.ConnectionError:
            results.append({
                "url": url,
                "status": "CONNECTION REFUSED ❌",
                "error": "Port not accessible"
            })
        except requests.exceptions.Timeout:
            results.append({
                "url": url,
                "status": "TIMEOUT ⏰", 
                "error": "Request timed out"
            })
        except Exception as e:
            results.append({
                "url": url,
                "status": "ERROR 💥",
                "error": str(e)
            })
    
    return jsonify({
        "windows_ip": WINDOWS_IP,
        "successful_connections": len(successful_urls),
        "working_urls": successful_urls,
        "all_test_results": results,
        "next_step": "If DataServlet URL works, try /Proiect endpoint"
    })

@app.route("/Proiect")
def home():
    """Main communication with Java servlet"""
    java_data = java_connector.get_data("DataServlet")
    
    if java_data:
        return jsonify({
            "python_message": "🐍 WSL Python connected to Windows Tomcat!",
            "java_data": java_data,
            "timestamp": datetime.now().isoformat(),
            "connection_info": {
                "from": "WSL (Linux)",
                "to": f"Windows Tomcat at {WINDOWS_IP}:9999",
                "protocol": "HTTP",
                "success": True
            }
        })
    else:
        return jsonify({
            "error": "Failed to connect to Windows Tomcat",
            "debug_info": {
                "windows_ip": WINDOWS_IP,
                "attempted_url": f"http://{WINDOWS_IP}:9999/Proiect/DataServlet",
                "suggestion": "Run /test-connection first to debug"
            },
            "connection_info": {
                "from": "WSL (Linux)", 
                "to": f"Windows Tomcat at {WINDOWS_IP}:9999",
                "success": False
            }
        }), 500

@app.route("/sync-data", methods=['POST'])
def sync_data():
    """Send data from WSL Python to Windows Java"""
    python_data = {
        "source": "WSL_Python",
        "message": "Cross-platform communication test",
        "payload": request.json if request.json else {"default": "test"},
        "timestamp": datetime.now().isoformat(),
        "platform_info": {
            "sender": "WSL Ubuntu",
            "receiver": "Windows Tomcat",
            "bridge_ip": WINDOWS_IP
        }
    }
    
    java_response = java_connector.send_data("DataServlet", python_data)
    
    return jsonify({
        "operation": "WSL→Windows data sync",
        "sent_to_java": python_data,
        "java_response": java_response,
        "success": java_response is not None,
        "timestamp": datetime.now().isoformat()
    })

@app.route("/")
def index():
    return jsonify({
        "title": "🐧 WSL Python ↔ 🖥️ Windows Tomcat Bridge",
        "status": "Running on WSL",
        "windows_target": f"{WINDOWS_IP}:9999",
        "endpoints": {
            "GET /": "This documentation",
            "GET /test-connection": "Test all possible Tomcat connections",
            "GET /Proiect": "Main communication with Java servlet",
            "POST /sync-data": "Send data to Windows Java application"
        },
        "setup_info": {
            "python_location": "WSL Ubuntu",
            "java_location": "Windows",
            "bridge_ip": WINDOWS_IP,
            "note": "Cross-platform communication via IP bridge"
        }
    })

if __name__ == "__main__":
    print("🐧 Starting WSL Python Flask server...")
    print(f"🖥️ Target: Windows Tomcat at {WINDOWS_IP}:9999")
    print("📡 Test URL: http://localhost:5000/test-connection")
    print("🔗 Main endpoint: http://localhost:5000/Proiect")
    app.run(debug=True, port=5000, host='0.0.0.0')