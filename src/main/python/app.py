#!/usr/bin/env python3
"""
Complete Enhanced Flask AI + QueryServlet Integration - WORKING VERSION
Combines advanced NLP with proper connection handling
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import json
import requests
from datetime import datetime, date
import logging
import traceback
import re
import os
import subprocess

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(name)s:%(message)s')
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)

# Enable CORS with comprehensive settings
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "X-Requested-With"]
    }
})

@app.after_request
def after_request(response):
    """Ensure CORS headers are added to all responses"""
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Requested-With')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

# WSL Detection and Configuration
def get_windows_ip():
    """Get Windows IP from WSL"""
    try:
        with open('/etc/resolv.conf', 'r') as f:
            for line in f:
                if 'nameserver' in line:
                    return line.split()[1]
    except:
        pass
    
    try:
        result = subprocess.run(['ip', 'route', 'show'], capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'default' in line:
                return line.split()[2]
    except:
        pass
    
    return '172.25.0.1'

# Detect environment
IS_WSL = os.path.exists('/proc/version') and 'microsoft' in open('/proc/version').read().lower()

if IS_WSL:
    WINDOWS_IP = get_windows_ip()
    logger.info(f"🔍 WSL detected! Using Windows IP: {WINDOWS_IP}")
    BASE_URL = f'http://{WINDOWS_IP}:9999'
else:
    BASE_URL = 'http://localhost:9999'

# QueryServlet Configuration
QUERY_SERVLET_CONFIG = {
    'base_url': BASE_URL,
    'project_path': '/Proiect',
    'servlet_path': '/QueryServlet',
    'timeout': 30
}

QUERY_SERVLET_URL = (
    f"{QUERY_SERVLET_CONFIG['base_url']}"
    f"{QUERY_SERVLET_CONFIG['project_path']}"
    f"{QUERY_SERVLET_CONFIG['servlet_path']}"
)

# Enhanced NLP Configuration
NLP_CONFIG = {
    'confidence_threshold': 0.6,
    'max_results': 100
}

class EnhancedNLPProcessor:
    """Enhanced NLP processor with advanced Romanian language support"""
    
    def __init__(self):
        # Department mappings
        self.department_mappings = {
            'hr': ['hr', 'resurse umane', 'human resources', 'personal', 'rh'],
            'it': ['it', 'informatica', 'tehnologie', 'programare', 'software', 'tech'],
            'finante': ['finante', 'financiar', 'contabilitate', 'accounting', 'finance'],
            'juridic': ['juridic', 'legal', 'drept', 'lege'],
            'marketing': ['marketing', 'publicitate', 'promovare', 'reclama'],
            'management': ['management', 'conducere', 'directori', 'manageri']
        }
        
        # Position mappings
        self.position_mappings = {
            'director': ['director', 'ceo', 'manager general', 'chief'],
            'manager': ['manager', 'sef', 'șef', 'supervisor', 'coordonator'],
            'specialist': ['specialist', 'expert', 'consultant', 'analist'],
            'programator': ['programator', 'developer', 'programmer', 'dev'],
            'designer': ['designer', 'graphic designer', 'ui', 'ux'],
            'contabil': ['contabil', 'accountant', 'bookkeeper'],
            'secretar': ['secretar', 'secretară', 'assistant', 'admin'],
            'tehnician': ['tehnician', 'technician', 'support'],
            'inginer': ['inginer', 'engineer', 'ing']
        }
        
        # Temporal patterns
        self.temporal_patterns = {
            'today': ['astazi', 'astăzi', 'azi', 'today'],
            'this_month': ['luna aceasta', 'luna asta', 'this month'],
            'this_year': ['anul acesta', 'anul asta', 'this year'],
            'current': ['curent', 'actual', 'current', 'prezent']
        }
        
        # Query patterns with priority
        self.query_patterns = {
            'salary_info': [
                'salariu', 'salarii', 'salary', 'venit', 'venituri',
                'mari', 'mici', 'top', 'cel mai mare', 'cel mai mic',
                'maxim', 'minim', 'highest', 'lowest'
            ],
            'leave_info': [
                'concedii', 'concediu', 'vacanta', 'vacanță', 'leave',
                'cine este in concediu', 'cine este în concediu'
            ],
            'employee_count': [
                'cati angajati', 'câți angajați', 'numarul angajatilor',
                'numar angajati', 'employee count'
            ],
            'employee_list': [
                'angajati din', 'angajați din', 'lista angajati',
                'show employees', 'afiseaza angajati'
            ],
            'department_info': [
                'departamente', 'departament', 'sectii', 'departments'
            ],
            'project_info': [
                'proiecte', 'proiect', 'tasks', 'sarcini'
            ]
        }
    
    def analyze_query(self, query):
        """Enhanced query analysis"""
        query_lower = query.lower().strip()
        
        # Detect query type with priority
        query_type = self._detect_query_type(query_lower)
        
        # Extract entities
        entities = self._extract_entities(query_lower)
        
        # Generate SQL
        sql_query = self._generate_sql(query_type, entities, query_lower)
        
        # Calculate confidence
        confidence = self._calculate_confidence(query_type, entities, query_lower)
        
        return {
            'query_type': query_type,
            'entities': entities,
            'sql_query': sql_query,
            'confidence': confidence,
            'original_query': query
        }
    
    def _detect_query_type(self, query_lower):
        """Enhanced query type detection with priority"""
        
        # Check salary queries first (highest priority)
        if any(pattern in query_lower for pattern in self.query_patterns['salary_info']):
            return 'salary_info'
        
        # Check leave queries
        if any(pattern in query_lower for pattern in self.query_patterns['leave_info']):
            return 'leave_info'
        
        # Check count queries
        if any(pattern in query_lower for pattern in self.query_patterns['employee_count']):
            return 'employee_count'
        
        # Check list queries
        if any(pattern in query_lower for pattern in self.query_patterns['employee_list']):
            return 'employee_list'
        
        # Check department queries
        if any(pattern in query_lower for pattern in self.query_patterns['department_info']):
            return 'department_info'
        
        # Check project queries
        if any(pattern in query_lower for pattern in self.query_patterns['project_info']):
            return 'project_info'
        
        return 'general_search'
    
    def _extract_entities(self, query_lower):
        """Enhanced entity extraction"""
        entities = {
            'departments': [],
            'positions': [],
            'temporal': [],
            'salary_keywords': []
        }
        
        # Extract departments
        for dept_key, dept_variations in self.department_mappings.items():
            for variation in dept_variations:
                if variation in query_lower:
                    entities['departments'].append(dept_key.upper())
                    break
        
        # Extract positions
        for pos_key, pos_variations in self.position_mappings.items():
            for variation in pos_variations:
                if variation in query_lower:
                    entities['positions'].append(pos_key)
                    break
        
        # Extract temporal expressions
        for temp_type, patterns in self.temporal_patterns.items():
            for pattern in patterns:
                if pattern in query_lower:
                    entities['temporal'].append(temp_type)
        
        # Extract salary keywords
        salary_keywords = ['mari', 'mici', 'top', 'maxim', 'minim']
        for keyword in salary_keywords:
            if keyword in query_lower:
                entities['salary_keywords'].append(keyword)
        
        return entities
    
    def _generate_sql(self, query_type, entities, query_lower):
        """Enhanced SQL generation"""
        
        if query_type == 'salary_info':
            return self._generate_salary_sql(entities, query_lower)
        elif query_type == 'employee_count':
            return self._generate_employee_count_sql(entities)
        elif query_type == 'employee_list':
            return self._generate_employee_list_sql(entities)
        elif query_type == 'leave_info':
            return self._generate_leave_sql(entities, query_lower)
        elif query_type == 'department_info':
            return self._generate_department_sql()
        elif query_type == 'project_info':
            return self._generate_project_sql()
        else:
            return self._generate_general_search_sql(entities)
    
    def _generate_salary_sql(self, entities, query_lower):
        """Generate SQL for salary queries with intelligent filtering"""
        sql = """
        SELECT u.nume, u.prenume, 
               d.nume_dep as departament, 
               t.denumire as functie,
               t.salariu
        FROM useri u 
        LEFT JOIN departament d ON u.id_dep = d.id_dep
        LEFT JOIN tipuri t ON u.tip = t.tip
        WHERE u.username != 'test' AND t.salariu IS NOT NULL
        """
        
        # Department filter
        if entities['departments']:
            dept_conditions = []
            for dept in entities['departments']:
                dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
            sql += f" AND ({' OR '.join(dept_conditions)})"
        
        # Position filter
        if entities['positions']:
            pos_conditions = []
            for pos in entities['positions']:
                pos_conditions.append(f"LOWER(t.denumire) LIKE '%{pos.lower()}%'")
            sql += f" AND ({' OR '.join(pos_conditions)})"
        
        # Ordering based on keywords
        if any(keyword in entities['salary_keywords'] for keyword in ['mari', 'top', 'maxim']):
            sql += " ORDER BY t.salariu DESC LIMIT 3"
        elif any(keyword in entities['salary_keywords'] for keyword in ['mici', 'minim']):
            sql += " ORDER BY t.salariu ASC LIMIT 3"
        else:
            sql += " ORDER BY t.salariu DESC LIMIT 20"
        
        return sql
    
    def _generate_employee_count_sql(self, entities):
        """Generate SQL for counting employees"""
        sql = "SELECT COUNT(*) as total_angajati FROM useri u LEFT JOIN departament d ON u.id_dep = d.id_dep WHERE u.username != 'test'"
        
        if entities['departments']:
            dept_conditions = []
            for dept in entities['departments']:
                dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
            sql += f" AND ({' OR '.join(dept_conditions)})"
        
        return sql
    
    def _generate_employee_list_sql(self, entities):
        """Generate SQL for listing employees"""
        sql = """
        SELECT u.nume, u.prenume, u.email, u.telefon,
               d.nume_dep as departament, t.denumire as functie
        FROM useri u 
        LEFT JOIN departament d ON u.id_dep = d.id_dep
        LEFT JOIN tipuri t ON u.tip = t.tip
        WHERE u.username != 'test'
        """
        
        # Department filter
        if entities['departments']:
            dept_conditions = []
            for dept in entities['departments']:
                dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
            sql += f" AND ({' OR '.join(dept_conditions)})"
        
        sql += " ORDER BY d.nume_dep, u.nume, u.prenume LIMIT 50"
        return sql
    
    def _generate_leave_sql(self, entities, query_lower):
        """Generate SQL for leave information with proper temporal filtering"""
        sql = """
        SELECT CONCAT(u.nume, ' ', u.prenume) as angajat,
               COALESCE(tc.motiv, 'Concediu') as tip_concediu,
               c.start_c as data_start,
               c.end_c as data_end,
               CASE c.status
                   WHEN 0 THEN 'Pending'
                   WHEN 1 THEN 'Aprobat Partial'
                   WHEN 2 THEN 'Aprobat'
                   WHEN -1 THEN 'Respins'
                   ELSE 'Aprobat'
               END as status,
               COALESCE(c.locatie, '-') as locatie
        FROM concedii c
        JOIN useri u ON c.id_ang = u.id
        LEFT JOIN tipcon tc ON c.tip = tc.tip
        WHERE u.username != 'test'
        """
        
        # Enhanced temporal filters
        if 'today' in entities['temporal']:
            sql += " AND CURDATE() BETWEEN c.start_c AND c.end_c"
        elif 'this_month' in entities['temporal']:
            sql += " AND MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())"
        elif 'this_year' in entities['temporal']:
            sql += " AND YEAR(c.start_c) = YEAR(CURDATE())"
        elif 'current' in entities['temporal']:
            sql += " AND CURDATE() BETWEEN c.start_c AND c.end_c"
        
        # Status filters
        if 'aprobat' in query_lower:
            sql += " AND c.status IN (1, 2)"
        elif 'pending' in query_lower:
            sql += " AND c.status = 0"
        
        sql += " ORDER BY c.start_c DESC LIMIT 50"
        return sql
    
    def _generate_department_sql(self):
        """Generate SQL for department information"""
        return """
        SELECT d.nume_dep as departament,
               COUNT(u.id) as nr_angajati
        FROM departament d
        LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.username != 'test'
        GROUP BY d.id_dep, d.nume_dep
        ORDER BY nr_angajati DESC
        """
    
    def _generate_project_sql(self):
        """Generate SQL for project information"""
        return """
        SELECT p.nume as nume_proiect,
               p.descriere,
               DATE(p.start) as data_start,
               DATE(p.end) as deadline,
               CONCAT(u.nume, ' ', u.prenume) as supervizor
        FROM proiecte p
        LEFT JOIN useri u ON p.supervizor = u.id
        ORDER BY p.end ASC
        LIMIT 20
        """
    
    def _generate_general_search_sql(self, entities):
        """Generate SQL for general search"""
        return """
        SELECT CONCAT(u.nume, ' ', u.prenume) as nume_complet,
               d.nume_dep as departament,
               t.denumire as functie
        FROM useri u
        LEFT JOIN departament d ON u.id_dep = d.id_dep
        LEFT JOIN tipuri t ON u.tip = t.tip
        WHERE u.username != 'test'
        ORDER BY u.nume, u.prenume
        LIMIT 20
        """
    
    def _calculate_confidence(self, query_type, entities, query_lower):
        """Calculate confidence score"""
        confidence = 0.5
        
        if query_type != 'general_search':
            confidence += 0.3
        
        if entities['departments']:
            confidence += 0.15
        
        if entities['positions']:
            confidence += 0.10
        
        if entities['temporal']:
            confidence += 0.10
        
        return min(confidence, 1.0)

# Initialize NLP processor
nlp_processor = EnhancedNLPProcessor()

def test_query_servlet_connection():
    """Test connection to QueryServlet"""
    try:
        logger.info(f"🔗 Testing QueryServlet: {QUERY_SERVLET_URL}")
        response = requests.get(QUERY_SERVLET_URL, timeout=10)
        return response.status_code == 200
    except Exception as e:
        logger.error(f"❌ Connection failed: {e}")
        return False

def execute_query_servlet(sql_query):
    """Execute SQL query via QueryServlet"""
    try:
        logger.info(f"📤 Executing SQL: {sql_query[:50]}...")
        
        payload = {
            "query": sql_query,
            "source": "flask_ai",
            "timestamp": datetime.now().isoformat()
        }
        
        # Try JSON first, then form data
        try:
            response = requests.post(
                QUERY_SERVLET_URL,
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
        except:
            response = requests.post(
                QUERY_SERVLET_URL,
                data=payload,
                timeout=30
            )
        
        if response.status_code == 200:
            try:
                result = response.json()
                return {
                    'success': True,
                    'data': result.get('data', []),
                    'row_count': len(result.get('data', []))
                }
            except:
                return {
                    'success': False,
                    'error': 'Invalid JSON response',
                    'data': []
                }
        else:
            return {
                'success': False,
                'error': f'HTTP {response.status_code}',
                'data': []
            }
            
    except Exception as e:
        logger.error(f"💥 Query execution error: {e}")
        return {
            'success': False,
            'error': str(e),
            'data': []
        }

def format_response_data(data, query_type, entities):
    """Format response data intelligently"""
    
    if not data:
        return {
            'type': 'empty_result',
            'message': 'Nu am găsit rezultate pentru cererea ta.',
            'data': [],
            'count': 0
        }
    
    if query_type == 'salary_info':
        if any(keyword in entities.get('salary_keywords', []) for keyword in ['mari', 'top', 'maxim']):
            formatted_data = []
            for i, emp in enumerate(data, 1):
                formatted_data.append({
                    'pozitie': i,
                    'nume_complet': f"{emp.get('nume', '')} {emp.get('prenume', '')}".strip(),
                    'departament': emp.get('departament', 'N/A'),
                    'functie': emp.get('functie', 'N/A'),
                    'salariu': emp.get('salariu', 0)
                })
            
            return {
                'type': 'top_salaries',
                'message': f'Top {len(formatted_data)} salarii:',
                'data': formatted_data,
                'count': len(formatted_data)
            }
        else:
            return {
                'type': 'salary_list',
                'message': f'Informații salarii ({len(data)}):',
                'data': data,
                'count': len(data)
            }
    
    elif query_type == 'leave_info':
        if 'today' in entities.get('temporal', []):
            return {
                'type': 'active_leaves',
                'message': f'Angajați în concediu astăzi ({len(data)}):',
                'data': data,
                'count': len(data)
            }
        else:
            return {
                'type': 'leave_list',
                'message': f'Concedii găsite ({len(data)}):',
                'data': data,
                'count': len(data)
            }
    
    elif query_type == 'employee_count':
        total = data[0].get('total_angajati', 0) if data else 0
        return {
            'type': 'count_result',
            'message': f'Numărul total de angajați: {total}',
            'count': total,
            'data': data
        }
    
    else:
        return {
            'type': 'general_result',
            'message': f'Rezultate găsite ({len(data)}):',
            'data': data,
            'count': len(data)
        }

def process_ai_query(query, session_id=None):
    """Process query using enhanced AI"""
    
    # Handle greetings
    if any(word in query.lower() for word in ['hello', 'hi', 'salut', 'buna']):
        return {
            'type': 'text',
            'message': '🤖 Salut! Sunt asistentul HR cu AI îmbunătățit.\n\n🎯 Pot să te ajut cu:\n• Informații despre angajați\n• Concedii și absențe\n• Salarii și poziții\n• Departamente și proiecte\n\n💡 Exemple:\n• "Câți angajați sunt în IT?"\n• "Cine este în concediu astăzi?"\n• "Angajații cu cele mai mari salarii"',
            'timestamp': datetime.now().isoformat()
        }
    
    try:
        # AI analysis
        logger.info(f"🧠 Analyzing query: {query}")
        analysis = nlp_processor.analyze_query(query)
        
        logger.info(f"🎯 Query type: {analysis['query_type']} (confidence: {analysis['confidence']:.2f})")
        
        # Check confidence
        if analysis['confidence'] < NLP_CONFIG['confidence_threshold']:
            return {
                'type': 'text',
                'message': f'🤔 Nu sunt foarte sigur despre cererea: "{query}"\n\n💡 Încearcă să fii mai specific:\n• "Lista angajaților din IT"\n• "Cine este în concediu astăzi?"\n• "Top 3 salarii din companie"',
                'timestamp': datetime.now().isoformat()
            }
        
        # Execute query
        logger.info("📤 Executing SQL query...")
        servlet_result = execute_query_servlet(analysis['sql_query'])
        
        if not servlet_result['success']:
            return {
                'type': 'error',
                'message': f'Eroare la executarea query-ului: {servlet_result["error"]}',
                'timestamp': datetime.now().isoformat()
            }
        
        # Format results
        formatted_result = format_response_data(
            servlet_result['data'], 
            analysis['query_type'], 
            analysis['entities']
        )
        
        return {
            'type': 'success',
            'query': query,
            'result': formatted_result,
            'ai_analysis': {
                'query_type': analysis['query_type'],
                'confidence': analysis['confidence'],
                'entities': analysis['entities'],
                'sql_query': analysis['sql_query']
            },
            'timestamp': datetime.now().isoformat()
        }
        
    except Exception as e:
        logger.error(f"💥 AI processing error: {e}")
        logger.error(traceback.format_exc())
        return {
            'type': 'error',
            'message': f'Eroare în procesarea AI: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }

# FLASK ROUTES
@app.route('/', methods=['GET'])
def index():
    """API documentation"""
    logger.info("📍 GET / called")
    return jsonify({
        "title": "🤖 Enhanced Flask AI + QueryServlet Integration",
        "description": "AI-powered HR assistant with advanced Romanian NLP",
        "version": "6.0.0",
        "status": "ready",
        "features": [
            "Advanced Romanian NLP processing",
            "Intelligent entity extraction",
            "Temporal query understanding",
            "Top-N salary queries",
            "Smart response formatting"
        ],
        "endpoints": {
            "GET /": "This documentation",
            "POST /query": "Main AI query endpoint",
            "POST /chat": "Legacy chat endpoint",
            "GET /health": "Health check"
        },
        "queryservlet_url": QUERY_SERVLET_URL,
        "timestamp": datetime.now().isoformat()
    })

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    logger.info("📍 GET /health called")
    servlet_status = test_query_servlet_connection()
    
    return jsonify({
        'status': 'healthy' if servlet_status else 'degraded',
        'components': {
            'flask_app': 'healthy',
            'nlp_processor': 'healthy',
            'query_servlet': 'healthy' if servlet_status else 'unhealthy'
        },
        'version': '6.0.0',
        'timestamp': datetime.now().isoformat(),
        'query_servlet_url': QUERY_SERVLET_URL
    })

@app.route('/query', methods=['POST', 'OPTIONS'])
def query_endpoint():
    """Main AI query processing endpoint"""
    
    if request.method == 'OPTIONS':
        logger.info("📍 OPTIONS /query called (CORS preflight)")
        return '', 200
    
    logger.info("📍 POST /query called")
    
    try:
        # Get query from request
        if request.is_json:
            data = request.get_json()
            query = data.get('query', '') if data else ''
        else:
            query = request.form.get('query', '') or request.form.get('message', '')
        
        session_id = request.form.get('session_id', 'default')
        
        if not query.strip():
            return jsonify({
                'type': 'error',
                'error': 'Query is required',
                'message': 'Te rog să introduci o întrebare.'
            }), 400
        
        logger.info(f"🤖 Processing query: '{query}'")
        
        # Process with AI
        response_data = process_ai_query(query, session_id)
        
        logger.info(f"✅ AI response ready: {response_data.get('type')}")
        
        return jsonify(response_data)
        
    except Exception as e:
        logger.error(f"💥 Error in /query: {e}")
        logger.error(traceback.format_exc())
        
        return jsonify({
            'type': 'error',
            'error': str(e),
            'message': f'Eroare în procesarea cererii: {str(e)}',
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/chat', methods=['POST', 'OPTIONS'])
def chat_endpoint():
    """Legacy chat endpoint for backward compatibility"""
    
    if request.method == 'OPTIONS':
        logger.info("📍 OPTIONS /chat called (CORS preflight)")
        return '', 200
    
    logger.info("📍 POST /chat called (legacy)")
    
    try:
        # Get message from request
        if request.is_json:
            data = request.get_json()
            message = data.get('message', '') if data else ''
        else:
            message = request.form.get('message', '') or request.form.get('query', '')
        
        if not message.strip():
            return jsonify({
                'type': 'error',
                'error': 'Message is required'
            }), 400
        
        # Process as query
        response_data = process_ai_query(message)
        
        return jsonify(response_data)
        
    except Exception as e:
        logger.error(f"💥 Error in /chat: {e}")
        return jsonify({
            'type': 'error',
            'error': str(e)
        }), 500

@app.errorhandler(404)
def not_found(error):
    logger.error(f"📍 404 Error: {request.method} {request.path}")
    return jsonify({
        'type': 'error',
        'error': 'Endpoint not found',
        'message': f'Endpoint-ul {request.path} nu există.',
        'available_endpoints': ['/', '/health', '/query', '/chat']
    }), 404

@app.errorhandler(500)
def internal_error(error):
    logger.error(f"📍 500 Error: {error}")
    return jsonify({
        'type': 'error',
        'error': 'Internal server error',
        'message': 'Eroare internă server.'
    }), 500

if __name__ == '__main__':
    print("🚀 Starting Complete Enhanced Flask AI + QueryServlet Integration")
    print("🤖 Architecture: JSP → Flask (Enhanced AI/NLP) → QueryServlet (SQL) → MySQL")
    print(f"🔗 QueryServlet URL: {QUERY_SERVLET_URL}")
    print("🌐 Frontend connects to: http://localhost:5000")
    print()
    print("📍 Available endpoints:")
    print("   GET  /       - API documentation")
    print("   GET  /health - Health check")
    print("   POST /query  - Main AI query endpoint")
    print("   POST /chat   - Legacy chat endpoint")
    print()
    
    # Test connection
    if test_query_servlet_connection():
        print("✅ QueryServlet connection: SUCCESS")
        print("🧠 Enhanced AI NLP processor: READY")
    else:
        print("❌ QueryServlet connection: FAILED")
        print("💡 Will work without QueryServlet (test mode)")
    
    print("\n" + "="*80)
    print("🤖 Complete Enhanced AI-Powered HR Assistant Ready!")
    print("🎯 Features: Advanced Romanian NLP, Smart Responses, Perfect Integration")
    print("="*80)
    
    # Run Flask
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
        threaded=True
    )