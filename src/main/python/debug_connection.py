#!/usr/bin/env python3
"""
Debug Flask App - Minimal version pentru a testa conexiunea
Rulează cu: python3 debug_app.py
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import logging
from datetime import datetime

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Enable CORS with very permissive settings
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "X-Requested-With"]
    }
})

@app.after_request
def after_request(response):
    """Add CORS headers to every response"""
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Requested-With')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/', methods=['GET'])
def index():
    """Test endpoint - should work"""
    logger.info("📍 GET / called")
    return jsonify({
        "status": "Flask is running!",
        "message": "🚀 Flask server is working correctly",
        "timestamp": datetime.now().isoformat(),
        "endpoints": {
            "GET /": "This test endpoint",
            "GET /health": "Health check",
            "POST /query": "Main query endpoint",
            "POST /chat": "Legacy chat endpoint (if needed)"
        }
    })

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    logger.info("📍 GET /health called")
    return jsonify({
        "status": "healthy",
        "message": "Flask server is running",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/query', methods=['POST', 'OPTIONS'])
def query():
    """Main query endpoint"""
    
    if request.method == 'OPTIONS':
        logger.info("📍 OPTIONS /query called (CORS preflight)")
        return '', 200
    
    logger.info("📍 POST /query called")
    
    try:
        # Get data from request
        if request.is_json:
            data = request.get_json()
            logger.info(f"📦 JSON data received: {data}")
        else:
            data = request.form.to_dict()
            logger.info(f"📦 Form data received: {data}")
        
        query_text = data.get('query', '') if data else ''
        
        if not query_text:
            return jsonify({
                "type": "error",
                "error": "No query provided",
                "message": "Te rog să introduci o întrebare."
            }), 400
        
        # Simple test response
        return jsonify({
            "type": "success",
            "message": f"🎉 Flask a primit query-ul: '{query_text}'",
            "query": query_text,
            "timestamp": datetime.now().isoformat(),
            "note": "Conexiunea funcționează! Acum poți să înlocuiești cu app.py complet."
        })
        
    except Exception as e:
        logger.error(f"💥 Error in /query: {e}")
        return jsonify({
            "type": "error",
            "error": str(e),
            "message": f"Eroare: {str(e)}"
        }), 500

@app.route('/chat', methods=['POST', 'OPTIONS'])
def chat():
    """Legacy chat endpoint for compatibility"""
    
    if request.method == 'OPTIONS':
        logger.info("📍 OPTIONS /chat called (CORS preflight)")
        return '', 200
    
    logger.info("📍 POST /chat called (legacy endpoint)")
    
    try:
        # Get data from request
        if request.is_json:
            data = request.get_json()
            message = data.get('message', '')
        else:
            message = request.form.get('message', '') or request.form.get('query', '')
        
        if not message:
            return jsonify({
                "type": "error",
                "error": "No message provided"
            }), 400
        
        # Simple test response
        return jsonify({
            "type": "text",
            "message": f"🎉 Chat endpoint funcționează! Ai trimis: '{message}'",
            "timestamp": datetime.now().isoformat()
        })
        
    except Exception as e:
        logger.error(f"💥 Error in /chat: {e}")
        return jsonify({
            "type": "error",
            "error": str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    logger.error(f"📍 404 Error: {request.method} {request.path}")
    return jsonify({
        "error": "Endpoint not found",
        "method": request.method,
        "path": request.path,
        "available_endpoints": ["/", "/health", "/query", "/chat"]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"📍 500 Error: {error}")
    return jsonify({
        "error": "Internal server error",
        "details": str(error)
    }), 500

if __name__ == '__main__':
    print("🔧 Starting DEBUG Flask Server")
    print("🎯 Purpose: Test connection between frontend and Flask")
    print("🌐 URL: http://localhost:5000")
    print("📍 Available endpoints:")
    print("   GET  /       - Test endpoint")
    print("   GET  /health - Health check")
    print("   POST /query  - Main endpoint")
    print("   POST /chat   - Legacy endpoint")
    print()
    print("🧪 Quick tests:")
    print("   curl http://localhost:5000/")
    print("   curl http://localhost:5000/health")
    print('   curl -X POST http://localhost:5000/query -H "Content-Type: application/json" -d \'{"query":"test"}\'')
    print()
    print("="*60)
    
    # Run Flask with debug mode
    app.run(
        host='0.0.0.0',  # Accept connections from any IP
        port=5000,       # Standard port
        debug=True,      # Enable debug mode
        threaded=True    # Enable threading
    )