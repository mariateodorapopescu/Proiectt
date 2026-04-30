# #!/usr/bin/env python3
# """
# Complete Enhanced Flask AI + QueryServlet Integration - WORKING VERSION
# Combines advanced NLP with proper connection handling
# """

# from flask import Flask, jsonify, request
# from flask_cors import CORS
# import json
# import requests
# from datetime import datetime, date
# import logging
# import traceback
# import re
# import os
# import subprocess

# # Configure logging
# logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(name)s:%(message)s')
# logger = logging.getLogger(__name__)

# # Create Flask app
# app = Flask(__name__)

# # Enable CORS with comprehensive settings
# CORS(app, resources={
#     r"/*": {
#         "origins": "*",
#         "methods": ["GET", "POST", "OPTIONS"],
#         "allow_headers": ["Content-Type", "Authorization", "X-Requested-With"]
#     }
# })

# @app.after_request
# def after_request(response):
#     """Ensure CORS headers are added to all responses"""
#     response.headers.add('Access-Control-Allow-Origin', '*')
#     response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Requested-With')
#     response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
#     return response

# # WSL Detection and Configuration
# def get_windows_ip():
#     """Get Windows IP from WSL"""
#     try:
#         with open('/etc/resolv.conf', 'r') as f:
#             for line in f:
#                 if 'nameserver' in line:
#                     return line.split()[1]
#     except:
#         pass
    
#     try:
#         result = subprocess.run(['ip', 'route', 'show'], capture_output=True, text=True)
#         for line in result.stdout.split('\n'):
#             if 'default' in line:
#                 return line.split()[2]
#     except:
#         pass
    
#     return '172.25.0.1'

# # Detect environment
# IS_WSL = os.path.exists('/proc/version') and 'microsoft' in open('/proc/version').read().lower()

# if IS_WSL:
#     WINDOWS_IP = get_windows_ip()
#     logger.info(f"🔍 WSL detected! Using Windows IP: {WINDOWS_IP}")
#     BASE_URL = f'http://{WINDOWS_IP}:9999'
# else:
#     BASE_URL = 'http://localhost:9999'

# # QueryServlet Configuration
# QUERY_SERVLET_CONFIG = {
#     'base_url': BASE_URL,
#     'project_path': '/Proiect',
#     'servlet_path': '/QueryServlet',
#     'timeout': 30
# }

# QUERY_SERVLET_URL = (
#     f"{QUERY_SERVLET_CONFIG['base_url']}"
#     f"{QUERY_SERVLET_CONFIG['project_path']}"
#     f"{QUERY_SERVLET_CONFIG['servlet_path']}"
# )

# # Enhanced NLP Configuration
# NLP_CONFIG = {
#     'confidence_threshold': 0.6,
#     'max_results': 100
# }

# class EnhancedNLPProcessor:
#     """Enhanced NLP processor with advanced Romanian language support"""
    
#     def __init__(self):
#         # Department mappings
#         self.department_mappings = {
#             'hr': ['hr', 'resurse umane', 'human resources', 'personal', 'rh'],
#             'it': ['it', 'informatica', 'tehnologie', 'programare', 'software', 'tech'],
#             'finante': ['finante', 'financiar', 'contabilitate', 'accounting', 'finance'],
#             'juridic': ['juridic', 'legal', 'drept', 'lege'],
#             'marketing': ['marketing', 'publicitate', 'promovare', 'reclama'],
#             'management': ['management', 'conducere', 'directori', 'manageri']
#         }
        
#         # Position mappings
#         self.position_mappings = {
#             'director': ['director', 'ceo', 'manager general', 'chief'],
#             'manager': ['manager', 'sef', 'șef', 'supervisor', 'coordonator'],
#             'specialist': ['specialist', 'expert', 'consultant', 'analist'],
#             'programator': ['programator', 'developer', 'programmer', 'dev'],
#             'designer': ['designer', 'graphic designer', 'ui', 'ux'],
#             'contabil': ['contabil', 'accountant', 'bookkeeper'],
#             'secretar': ['secretar', 'secretară', 'assistant', 'admin'],
#             'tehnician': ['tehnician', 'technician', 'support'],
#             'inginer': ['inginer', 'engineer', 'ing']
#         }
        
#         # Temporal patterns
#         self.temporal_patterns = {
#             'today': ['astazi', 'astăzi', 'azi', 'today'],
#             'this_month': ['luna aceasta', 'luna asta', 'this month'],
#             'this_year': ['anul acesta', 'anul asta', 'this year'],
#             'current': ['curent', 'actual', 'current', 'prezent']
#         }
        
#         # Query patterns with priority
#         self.query_patterns = {
#             'salary_info': [
#                 'salariu', 'salarii', 'salary', 'venit', 'venituri',
#                 'mari', 'mici', 'top', 'cel mai mare', 'cel mai mic',
#                 'maxim', 'minim', 'highest', 'lowest'
#             ],
#             'leave_info': [
#                 'concedii', 'concediu', 'vacanta', 'vacanță', 'leave',
#                 'cine este in concediu', 'cine este în concediu'
#             ],
#             'employee_count': [
#                 'cati angajati', 'câți angajați', 'numarul angajatilor',
#                 'numar angajati', 'employee count'
#             ],
#             'employee_list': [
#                 'angajati din', 'angajați din', 'lista angajati',
#                 'show employees', 'afiseaza angajati'
#             ],
#             'department_info': [
#                 'departamente', 'departament', 'sectii', 'departments'
#             ],
#             'project_info': [
#                 'proiecte', 'proiect', 'tasks', 'sarcini'
#             ]
#         }
    
#     def analyze_query(self, query):
#         """Enhanced query analysis"""
#         query_lower = query.lower().strip()
        
#         # Detect query type with priority
#         query_type = self._detect_query_type(query_lower)
        
#         # Extract entities
#         entities = self._extract_entities(query_lower)
        
#         # Generate SQL
#         sql_query = self._generate_sql(query_type, entities, query_lower)
        
#         # Calculate confidence
#         confidence = self._calculate_confidence(query_type, entities, query_lower)
        
#         return {
#             'query_type': query_type,
#             'entities': entities,
#             'sql_query': sql_query,
#             'confidence': confidence,
#             'original_query': query
#         }
    
#     def _detect_query_type(self, query_lower):
#         """Enhanced query type detection with priority"""
        
#         # Check salary queries first (highest priority)
#         if any(pattern in query_lower for pattern in self.query_patterns['salary_info']):
#             return 'salary_info'
        
#         # Check leave queries
#         if any(pattern in query_lower for pattern in self.query_patterns['leave_info']):
#             return 'leave_info'
        
#         # Check count queries
#         if any(pattern in query_lower for pattern in self.query_patterns['employee_count']):
#             return 'employee_count'
        
#         # Check list queries
#         if any(pattern in query_lower for pattern in self.query_patterns['employee_list']):
#             return 'employee_list'
        
#         # Check department queries
#         if any(pattern in query_lower for pattern in self.query_patterns['department_info']):
#             return 'department_info'
        
#         # Check project queries
#         if any(pattern in query_lower for pattern in self.query_patterns['project_info']):
#             return 'project_info'
        
#         return 'general_search'
    
#     def _extract_entities(self, query_lower):
#         """Enhanced entity extraction"""
#         entities = {
#             'departments': [],
#             'positions': [],
#             'temporal': [],
#             'salary_keywords': []
#         }
        
#         # Extract departments
#         for dept_key, dept_variations in self.department_mappings.items():
#             for variation in dept_variations:
#                 if variation in query_lower:
#                     entities['departments'].append(dept_key.upper())
#                     break
        
#         # Extract positions
#         for pos_key, pos_variations in self.position_mappings.items():
#             for variation in pos_variations:
#                 if variation in query_lower:
#                     entities['positions'].append(pos_key)
#                     break
        
#         # Extract temporal expressions
#         for temp_type, patterns in self.temporal_patterns.items():
#             for pattern in patterns:
#                 if pattern in query_lower:
#                     entities['temporal'].append(temp_type)
        
#         # Extract salary keywords
#         salary_keywords = ['mari', 'mici', 'top', 'maxim', 'minim']
#         for keyword in salary_keywords:
#             if keyword in query_lower:
#                 entities['salary_keywords'].append(keyword)
        
#         return entities
    
#     def _generate_sql(self, query_type, entities, query_lower):
#         """Enhanced SQL generation"""
        
#         if query_type == 'salary_info':
#             return self._generate_salary_sql(entities, query_lower)
#         elif query_type == 'employee_count':
#             return self._generate_employee_count_sql(entities)
#         elif query_type == 'employee_list':
#             return self._generate_employee_list_sql(entities)
#         elif query_type == 'leave_info':
#             return self._generate_leave_sql(entities, query_lower)
#         elif query_type == 'department_info':
#             return self._generate_department_sql()
#         elif query_type == 'project_info':
#             return self._generate_project_sql()
#         else:
#             return self._generate_general_search_sql(entities)
    
#     def _generate_salary_sql(self, entities, query_lower):
#         """Generate SQL for salary queries with intelligent filtering"""
#         sql = """
#         SELECT u.nume, u.prenume, 
#                d.nume_dep as departament, 
#                t.denumire as functie,
#                t.salariu
#         FROM useri u 
#         LEFT JOIN departament d ON u.id_dep = d.id_dep
#         LEFT JOIN tipuri t ON u.tip = t.tip
#         WHERE u.username != 'test' AND t.salariu IS NOT NULL
#         """
        
#         # Department filter
#         if entities['departments']:
#             dept_conditions = []
#             for dept in entities['departments']:
#                 dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
#             sql += f" AND ({' OR '.join(dept_conditions)})"
        
#         # Position filter
#         if entities['positions']:
#             pos_conditions = []
#             for pos in entities['positions']:
#                 pos_conditions.append(f"LOWER(t.denumire) LIKE '%{pos.lower()}%'")
#             sql += f" AND ({' OR '.join(pos_conditions)})"
        
#         # Ordering based on keywords
#         if any(keyword in entities['salary_keywords'] for keyword in ['mari', 'top', 'maxim']):
#             sql += " ORDER BY t.salariu DESC LIMIT 3"
#         elif any(keyword in entities['salary_keywords'] for keyword in ['mici', 'minim']):
#             sql += " ORDER BY t.salariu ASC LIMIT 3"
#         else:
#             sql += " ORDER BY t.salariu DESC LIMIT 20"
        
#         return sql
    
#     def _generate_employee_count_sql(self, entities):
#         """Generate SQL for counting employees"""
#         sql = "SELECT COUNT(*) as total_angajati FROM useri u LEFT JOIN departament d ON u.id_dep = d.id_dep WHERE u.username != 'test'"
        
#         if entities['departments']:
#             dept_conditions = []
#             for dept in entities['departments']:
#                 dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
#             sql += f" AND ({' OR '.join(dept_conditions)})"
        
#         return sql
    
#     def _generate_employee_list_sql(self, entities):
#         """Generate SQL for listing employees"""
#         sql = """
#         SELECT u.nume, u.prenume, u.email, u.telefon,
#                d.nume_dep as departament, t.denumire as functie
#         FROM useri u 
#         LEFT JOIN departament d ON u.id_dep = d.id_dep
#         LEFT JOIN tipuri t ON u.tip = t.tip
#         WHERE u.username != 'test'
#         """
        
#         # Department filter
#         if entities['departments']:
#             dept_conditions = []
#             for dept in entities['departments']:
#                 dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
#             sql += f" AND ({' OR '.join(dept_conditions)})"
        
#         sql += " ORDER BY d.nume_dep, u.nume, u.prenume LIMIT 50"
#         return sql
    
#     def _generate_leave_sql(self, entities, query_lower):
#         """Generate SQL for leave information with proper temporal filtering"""
#         sql = """
#         SELECT CONCAT(u.nume, ' ', u.prenume) as angajat,
#                COALESCE(tc.motiv, 'Concediu') as tip_concediu,
#                c.start_c as data_start,
#                c.end_c as data_end,
#                CASE c.status
#                    WHEN 0 THEN 'Pending'
#                    WHEN 1 THEN 'Aprobat Partial'
#                    WHEN 2 THEN 'Aprobat'
#                    WHEN -1 THEN 'Respins'
#                    ELSE 'Aprobat'
#                END as status,
#                COALESCE(c.locatie, '-') as locatie
#         FROM concedii c
#         JOIN useri u ON c.id_ang = u.id
#         LEFT JOIN tipcon tc ON c.tip = tc.tip
#         WHERE u.username != 'test'
#         """
        
#         # Enhanced temporal filters
#         if 'today' in entities['temporal']:
#             sql += " AND CURDATE() BETWEEN c.start_c AND c.end_c"
#         elif 'this_month' in entities['temporal']:
#             sql += " AND MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())"
#         elif 'this_year' in entities['temporal']:
#             sql += " AND YEAR(c.start_c) = YEAR(CURDATE())"
#         elif 'current' in entities['temporal']:
#             sql += " AND CURDATE() BETWEEN c.start_c AND c.end_c"
        
#         # Status filters
#         if 'aprobat' in query_lower:
#             sql += " AND c.status IN (1, 2)"
#         elif 'pending' in query_lower:
#             sql += " AND c.status = 0"
        
#         sql += " ORDER BY c.start_c DESC LIMIT 50"
#         return sql
    
#     def _generate_department_sql(self):
#         """Generate SQL for department information"""
#         return """
#         SELECT d.nume_dep as departament,
#                COUNT(u.id) as nr_angajati
#         FROM departament d
#         LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.username != 'test'
#         GROUP BY d.id_dep, d.nume_dep
#         ORDER BY nr_angajati DESC
#         """
    
#     def _generate_project_sql(self):
#         """Generate SQL for project information"""
#         return """
#         SELECT p.nume as nume_proiect,
#                p.descriere,
#                DATE(p.start) as data_start,
#                DATE(p.end) as deadline,
#                CONCAT(u.nume, ' ', u.prenume) as supervizor
#         FROM proiecte p
#         LEFT JOIN useri u ON p.supervizor = u.id
#         ORDER BY p.end ASC
#         LIMIT 20
#         """
    
#     def _generate_general_search_sql(self, entities):
#         """Generate SQL for general search"""
#         return """
#         SELECT CONCAT(u.nume, ' ', u.prenume) as nume_complet,
#                d.nume_dep as departament,
#                t.denumire as functie
#         FROM useri u
#         LEFT JOIN departament d ON u.id_dep = d.id_dep
#         LEFT JOIN tipuri t ON u.tip = t.tip
#         WHERE u.username != 'test'
#         ORDER BY u.nume, u.prenume
#         LIMIT 20
#         """
    
#     def _calculate_confidence(self, query_type, entities, query_lower):
#         """Calculate confidence score"""
#         confidence = 0.5
        
#         if query_type != 'general_search':
#             confidence += 0.3
        
#         if entities['departments']:
#             confidence += 0.15
        
#         if entities['positions']:
#             confidence += 0.10
        
#         if entities['temporal']:
#             confidence += 0.10
        
#         return min(confidence, 1.0)

# # Initialize NLP processor
# nlp_processor = EnhancedNLPProcessor()

# def test_query_servlet_connection():
#     """Test connection to QueryServlet"""
#     try:
#         logger.info(f"🔗 Testing QueryServlet: {QUERY_SERVLET_URL}")
#         response = requests.get(QUERY_SERVLET_URL, timeout=10)
#         return response.status_code == 200
#     except Exception as e:
#         logger.error(f"❌ Connection failed: {e}")
#         return False

# def execute_query_servlet(sql_query):
#     """Execute SQL query via QueryServlet"""
#     try:
#         logger.info(f"📤 Executing SQL: {sql_query[:50]}...")
        
#         payload = {
#             "query": sql_query,
#             "source": "flask_ai",
#             "timestamp": datetime.now().isoformat()
#         }
        
#         # Try JSON first, then form data
#         try:
#             response = requests.post(
#                 QUERY_SERVLET_URL,
#                 json=payload,
#                 headers={'Content-Type': 'application/json'},
#                 timeout=30
#             )
#         except:
#             response = requests.post(
#                 QUERY_SERVLET_URL,
#                 data=payload,
#                 timeout=30
#             )
        
#         if response.status_code == 200:
#             try:
#                 result = response.json()
#                 return {
#                     'success': True,
#                     'data': result.get('data', []),
#                     'row_count': len(result.get('data', []))
#                 }
#             except:
#                 return {
#                     'success': False,
#                     'error': 'Invalid JSON response',
#                     'data': []
#                 }
#         else:
#             return {
#                 'success': False,
#                 'error': f'HTTP {response.status_code}',
#                 'data': []
#             }
            
#     except Exception as e:
#         logger.error(f"💥 Query execution error: {e}")
#         return {
#             'success': False,
#             'error': str(e),
#             'data': []
#         }

# def format_response_data(data, query_type, entities):
#     """Format response data intelligently"""
    
#     if not data:
#         return {
#             'type': 'empty_result',
#             'message': 'Nu am găsit rezultate pentru cererea ta.',
#             'data': [],
#             'count': 0
#         }
    
#     if query_type == 'salary_info':
#         if any(keyword in entities.get('salary_keywords', []) for keyword in ['mari', 'top', 'maxim']):
#             formatted_data = []
#             for i, emp in enumerate(data, 1):
#                 formatted_data.append({
#                     'pozitie': i,
#                     'nume_complet': f"{emp.get('nume', '')} {emp.get('prenume', '')}".strip(),
#                     'departament': emp.get('departament', 'N/A'),
#                     'functie': emp.get('functie', 'N/A'),
#                     'salariu': emp.get('salariu', 0)
#                 })
            
#             return {
#                 'type': 'top_salaries',
#                 'message': f'Top {len(formatted_data)} salarii:',
#                 'data': formatted_data,
#                 'count': len(formatted_data)
#             }
#         else:
#             return {
#                 'type': 'salary_list',
#                 'message': f'Informații salarii ({len(data)}):',
#                 'data': data,
#                 'count': len(data)
#             }
    
#     elif query_type == 'leave_info':
#         if 'today' in entities.get('temporal', []):
#             return {
#                 'type': 'active_leaves',
#                 'message': f'Angajați în concediu astăzi ({len(data)}):',
#                 'data': data,
#                 'count': len(data)
#             }
#         else:
#             return {
#                 'type': 'leave_list',
#                 'message': f'Concedii găsite ({len(data)}):',
#                 'data': data,
#                 'count': len(data)
#             }
    
#     elif query_type == 'employee_count':
#         total = data[0].get('total_angajati', 0) if data else 0
#         return {
#             'type': 'count_result',
#             'message': f'Numărul total de angajați: {total}',
#             'count': total,
#             'data': data
#         }
    
#     else:
#         return {
#             'type': 'general_result',
#             'message': f'Rezultate găsite ({len(data)}):',
#             'data': data,
#             'count': len(data)
#         }

# def process_ai_query(query, session_id=None):
#     """Process query using enhanced AI"""
    
#     # Handle greetings
#     if any(word in query.lower() for word in ['hello', 'hi', 'salut', 'buna']):
#         return {
#             'type': 'text',
#             'message': '🤖 Salut! Sunt asistentul HR cu AI îmbunătățit.\n\n🎯 Pot să te ajut cu:\n• Informații despre angajați\n• Concedii și absențe\n• Salarii și poziții\n• Departamente și proiecte\n\n💡 Exemple:\n• "Câți angajați sunt în IT?"\n• "Cine este în concediu astăzi?"\n• "Angajații cu cele mai mari salarii"',
#             'timestamp': datetime.now().isoformat()
#         }
    
#     try:
#         # AI analysis
#         logger.info(f"🧠 Analyzing query: {query}")
#         analysis = nlp_processor.analyze_query(query)
        
#         logger.info(f"🎯 Query type: {analysis['query_type']} (confidence: {analysis['confidence']:.2f})")
        
#         # Check confidence
#         if analysis['confidence'] < NLP_CONFIG['confidence_threshold']:
#             return {
#                 'type': 'text',
#                 'message': f'🤔 Nu sunt foarte sigur despre cererea: "{query}"\n\n💡 Încearcă să fii mai specific:\n• "Lista angajaților din IT"\n• "Cine este în concediu astăzi?"\n• "Top 3 salarii din companie"',
#                 'timestamp': datetime.now().isoformat()
#             }
        
#         # Execute query
#         logger.info("📤 Executing SQL query...")
#         servlet_result = execute_query_servlet(analysis['sql_query'])
        
#         if not servlet_result['success']:
#             return {
#                 'type': 'error',
#                 'message': f'Eroare la executarea query-ului: {servlet_result["error"]}',
#                 'timestamp': datetime.now().isoformat()
#             }
        
#         # Format results
#         formatted_result = format_response_data(
#             servlet_result['data'], 
#             analysis['query_type'], 
#             analysis['entities']
#         )
        
#         return {
#             'type': 'success',
#             'query': query,
#             'result': formatted_result,
#             'ai_analysis': {
#                 'query_type': analysis['query_type'],
#                 'confidence': analysis['confidence'],
#                 'entities': analysis['entities'],
#                 'sql_query': analysis['sql_query']
#             },
#             'timestamp': datetime.now().isoformat()
#         }
        
#     except Exception as e:
#         logger.error(f"💥 AI processing error: {e}")
#         logger.error(traceback.format_exc())
#         return {
#             'type': 'error',
#             'message': f'Eroare în procesarea AI: {str(e)}',
#             'timestamp': datetime.now().isoformat()
#         }

# # FLASK ROUTES
# @app.route('/', methods=['GET'])
# def index():
#     """API documentation"""
#     logger.info("📍 GET / called")
#     return jsonify({
#         "title": "🤖 Enhanced Flask AI + QueryServlet Integration",
#         "description": "AI-powered HR assistant with advanced Romanian NLP",
#         "version": "6.0.0",
#         "status": "ready",
#         "features": [
#             "Advanced Romanian NLP processing",
#             "Intelligent entity extraction",
#             "Temporal query understanding",
#             "Top-N salary queries",
#             "Smart response formatting"
#         ],
#         "endpoints": {
#             "GET /": "This documentation",
#             "POST /query": "Main AI query endpoint",
#             "POST /chat": "Legacy chat endpoint",
#             "GET /health": "Health check"
#         },
#         "queryservlet_url": QUERY_SERVLET_URL,
#         "timestamp": datetime.now().isoformat()
#     })

# @app.route('/health', methods=['GET'])
# def health_check():
#     """Health check endpoint"""
#     logger.info("📍 GET /health called")
#     servlet_status = test_query_servlet_connection()
    
#     return jsonify({
#         'status': 'healthy' if servlet_status else 'degraded',
#         'components': {
#             'flask_app': 'healthy',
#             'nlp_processor': 'healthy',
#             'query_servlet': 'healthy' if servlet_status else 'unhealthy'
#         },
#         'version': '6.0.0',
#         'timestamp': datetime.now().isoformat(),
#         'query_servlet_url': QUERY_SERVLET_URL
#     })

# @app.route('/query', methods=['POST', 'OPTIONS'])
# def query_endpoint():
#     """Main AI query processing endpoint"""
    
#     if request.method == 'OPTIONS':
#         logger.info("📍 OPTIONS /query called (CORS preflight)")
#         return '', 200
    
#     logger.info("📍 POST /query called")
    
#     try:
#         # Get query from request
#         if request.is_json:
#             data = request.get_json()
#             query = data.get('query', '') if data else ''
#         else:
#             query = request.form.get('query', '') or request.form.get('message', '')
        
#         session_id = request.form.get('session_id', 'default')
        
#         if not query.strip():
#             return jsonify({
#                 'type': 'error',
#                 'error': 'Query is required',
#                 'message': 'Te rog să introduci o întrebare.'
#             }), 400
        
#         logger.info(f"🤖 Processing query: '{query}'")
        
#         # Process with AI
#         response_data = process_ai_query(query, session_id)
        
#         logger.info(f"✅ AI response ready: {response_data.get('type')}")
        
#         return jsonify(response_data)
        
#     except Exception as e:
#         logger.error(f"💥 Error in /query: {e}")
#         logger.error(traceback.format_exc())
        
#         return jsonify({
#             'type': 'error',
#             'error': str(e),
#             'message': f'Eroare în procesarea cererii: {str(e)}',
#             'timestamp': datetime.now().isoformat()
#         }), 500

# @app.route('/chat', methods=['POST', 'OPTIONS'])
# def chat_endpoint():
#     """Legacy chat endpoint for backward compatibility"""
    
#     if request.method == 'OPTIONS':
#         logger.info("📍 OPTIONS /chat called (CORS preflight)")
#         return '', 200
    
#     logger.info("📍 POST /chat called (legacy)")
    
#     try:
#         # Get message from request
#         if request.is_json:
#             data = request.get_json()
#             message = data.get('message', '') if data else ''
#         else:
#             message = request.form.get('message', '') or request.form.get('query', '')
        
#         if not message.strip():
#             return jsonify({
#                 'type': 'error',
#                 'error': 'Message is required'
#             }), 400
        
#         # Process as query
#         response_data = process_ai_query(message)
        
#         return jsonify(response_data)
        
#     except Exception as e:
#         logger.error(f"💥 Error in /chat: {e}")
#         return jsonify({
#             'type': 'error',
#             'error': str(e)
#         }), 500

# @app.errorhandler(404)
# def not_found(error):
#     logger.error(f"📍 404 Error: {request.method} {request.path}")
#     return jsonify({
#         'type': 'error',
#         'error': 'Endpoint not found',
#         'message': f'Endpoint-ul {request.path} nu există.',
#         'available_endpoints': ['/', '/health', '/query', '/chat']
#     }), 404

# @app.errorhandler(500)
# def internal_error(error):
#     logger.error(f"📍 500 Error: {error}")
#     return jsonify({
#         'type': 'error',
#         'error': 'Internal server error',
#         'message': 'Eroare internă server.'
#     }), 500

# if __name__ == '__main__':
#     print("🚀 Starting Complete Enhanced Flask AI + QueryServlet Integration")
#     print("🤖 Architecture: JSP → Flask (Enhanced AI/NLP) → QueryServlet (SQL) → MySQL")
#     print(f"🔗 QueryServlet URL: {QUERY_SERVLET_URL}")
#     print("🌐 Frontend connects to: http://localhost:5000")
#     print()
#     print("📍 Available endpoints:")
#     print("   GET  /       - API documentation")
#     print("   GET  /health - Health check")
#     print("   POST /query  - Main AI query endpoint")
#     print("   POST /chat   - Legacy chat endpoint")
#     print()
    
#     # Test connection
#     if test_query_servlet_connection():
#         print("✅ QueryServlet connection: SUCCESS")
#         print("🧠 Enhanced AI NLP processor: READY")
#     else:
#         print("❌ QueryServlet connection: FAILED")
#         print("💡 Will work without QueryServlet (test mode)")
    
#     print("\n" + "="*80)
#     print("🤖 Complete Enhanced AI-Powered HR Assistant Ready!")
#     print("🎯 Features: Advanced Romanian NLP, Smart Responses, Perfect Integration")
#     print("="*80)
    
#     # Run Flask
#     app.run(
#         host='0.0.0.0',
#         port=5000,
#         debug=True,
#         threaded=True
#     )


"""
Flask HR Assistant - app.py (versiunea nouă)
============================================
Arhitectura nouă:
  chat.jsp (browser)
      ↓  POST JSON {message, user_id}
  Flask /chat (acest fișier, port 5000)
      ↓  NLQEngine.process()
  nlq_engine_v2.py  →  SQL generat
      ↓  mysql.connector
  MySQL direct  →  date reale
      ↓  {type, message, data}
  chat.jsp (răspuns afișat)

CE S-A SCHIMBAT față de versiunea veche:
  ❌ Scos:  EnterpriseNLPProcessor (regex simplist)
  ❌ Scos:  send_sql_to_query_servlet() (Java QueryServlet)
  ✅ Adăugat: NLQEngine din nlq_engine_v2.py (TF-IDF + QuestionWordAnalyzer)
  ✅ Adăugat: execute_sql() cu mysql.connector (direct la MySQL)

Instalare dependențe:
  pip install flask flask-cors mysql-connector-python scikit-learn numpy
"""

import sys
import os
import json
import logging
import traceback
import mysql.connector
from datetime import datetime, date

from flask import Flask, jsonify, request
from flask_cors import CORS

# ─── Importăm NLQEngine din nlq_engine_v2.py ─────────────────────────────────
# nlq_engine_v2.py trebuie să fie în ACELAȘI folder cu app.py
# Dacă e în alt folder, schimbă calea de mai jos.
try:
    from nlq_engine_v2 import NLQEngine
    nlq_engine = NLQEngine()
    NLQ_AVAILABLE = True
    print("✅ NLQEngine v2 încărcat cu succes")
except ImportError as e:
    NLQ_AVAILABLE = False
    nlq_engine = None
    print(f"❌ NLQEngine v2 nu a putut fi importat: {e}")
    print("   Asigură-te că nlq_engine_v2.py este în același folder cu app.py")

# ─── Configurare logging ──────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# ─── Flask app ────────────────────────────────────────────────────────────────
app = Flask(__name__)
CORS(app, origins=["*"], methods=['GET', 'POST', 'OPTIONS'])

# ─── Configurare MySQL ────────────────────────────────────────────────────────
# SCHIMBĂ credențialele aici dacă diferă la tine!
DB_CONFIG = {
    'host':     'localhost',
    'port':     3306,
    'database': 'test',        # numele bazei de date
    'user':     'root',
    'password': 'student',
    'charset':  'utf8mb4',
    'use_pure': True,          # compatibilitate mai bună cu WSL
}


# ══════════════════════════════════════════════════════════════════════════════
# FUNCȚII UTILITARE
# ══════════════════════════════════════════════════════════════════════════════

def get_db_connection():
    """
    Deschide o conexiune la MySQL și o returnează.

    De ce nu facem o conexiune globală?
    - Conexiunile MySQL expiră dacă stau inactive prea mult timp
    - Mai sigur să deschidem + închidem per-request (connection-per-request pattern)
    - mysql.connector e rapid, overhead-ul e minim

    Returnează:
        (conexiune, None)  dacă a funcționat
        (None, "mesaj eroare")  dacă a picat
    """
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn, None
    except mysql.connector.Error as e:
        logger.error(f"Eroare conexiune MySQL: {e}")
        return None, str(e)


def serialize_row(row: dict) -> dict:
    """
    Convertim tipurile Python care nu sunt serializabile în JSON la tipuri simple.

    Problema: mysql.connector returnează date/datetime ca obiecte Python speciale.
    json.dumps() nu știe să le convertească, deci trebuie noi să le transformăm.

    Exemple:
        datetime(2024, 3, 15) → "15/03/2024"   (format românesc)
        date(2024, 3, 15)     → "15/03/2024"
        Decimal('5000.00')    → 5000.0
        None                  → ""              (null → string gol, mai ușor în JS)
    """
    clean = {}
    for key, val in row.items():
        if isinstance(val, (datetime,)):
            clean[key] = val.strftime('%d/%m/%Y %H:%M')
        elif isinstance(val, date):
            clean[key] = val.strftime('%d/%m/%Y')
        elif val is None:
            clean[key] = ""
        else:
            # Decimal, int, float, str → le lăsăm cum sunt
            # json.dumps le va serializa corect
            clean[key] = val
    return clean


def execute_sql(sql: str) -> tuple:
    """
    Execută un query SQL direct pe MySQL și returnează rezultatele.

    Pași:
      1. Deschidem conexiunea
      2. Executăm query-ul cu cursor(dictionary=True)
         → dictionary=True înseamnă că fiecare rând e un dict {"coloana": "valoare"}
         → fără asta am primi tuple-uri fără nume de coloane
      3. Fetch-uim toate rândurile
      4. Le serializăm (date → string etc.)
      5. Închidem conexiunea

    Returnează:
        (lista_randuri, None)    dacă a funcționat
        (None, "mesaj eroare")   dacă a picat
    """
    conn, err = get_db_connection()
    if err:
        return None, f"Nu mă pot conecta la baza de date: {err}"

    try:
        cursor = conn.cursor(dictionary=True)  # rânduri ca dict-uri, nu tuple-uri
        logger.info(f"Execut SQL: {sql[:120]}...")
        cursor.execute(sql)
        rows = cursor.fetchall()
        # Serializăm fiecare rând (convertim date, None etc.)
        rows_clean = [serialize_row(dict(row)) for row in rows]
        cursor.close()
        conn.close()
        return rows_clean, None

    except mysql.connector.Error as e:
        logger.error(f"Eroare SQL: {e}")
        conn.close()
        return None, str(e)
    except Exception as e:
        logger.error(f"Eroare neașteptată: {e}")
        conn.close()
        return None, str(e)


# ══════════════════════════════════════════════════════════════════════════════
# FUNCȚIA PRINCIPALĂ DE PROCESARE
# ══════════════════════════════════════════════════════════════════════════════

def _check_hardcoded_faq(msg: str):
    """
    Verifică dacă întrebarea se potrivește cu un răspuns hardcodat (FAQ / politici / UI).
    Returnează dict-ul de răspuns dacă găsește un match, sau None dacă nu.

    Logică:
      - Răspunsurile sunt grupate pe categorii
      - 'ask_hr' = redirecționăm la departamentul HR
      - 'not_implemented' = funcționalitate viitoare
      - calcule dinamice (data plată, zile februarie) se fac în runtime
    """
    from datetime import datetime, date
    import calendar

    now = datetime.now()

    # ── Helper: răspuns "întreabă HR" ─────────────────────────────────────────
    def ask_hr(topic: str = "") -> dict:
        tip = f" despre {topic}" if topic else ""
        return {
            'type': 'text',
            'message': (
                f'Pentru această întrebare{tip} te rog să contactezi direct '
                f'departamentul HR.\n\n'
                f'Ei pot oferi informații actualizate și specifice situației tale. '
                f'Poți trimite un email sau depune o cerere prin sistemul de adeverințe.'
            )
        }

    def not_impl() -> dict:
        return {
            'type': 'text',
            'message': (
                'Această funcționalitate nu este încă implementată în sistem.\n\n'
                'Verifică cu managerul tău sau cu departamentul HR pentru '
                'informații despre orele lucrate.'
            )
        }

    # ── 0. Ghidul angajatului ─────────────────────────────────────────────────
    # Orice întrebare legată de proceduri interne, regulament, ghid
    _guide_msg = (
        'Această informație se găsește în **Ghidul Angajatului**.\n\n'
        'Îl poți accesa direct din aplicație:\n'
        '📍 **Acasă → lângă numele tău → iconița ❓**\n\n'
        'Ghidul conține proceduri detaliate pentru concedii, programare meetinguri, '
        'gestionarea taskurilor, regulamentul intern și multe altele.'
    )

    _guide_triggers = [
        'ghidul angajatului', 'ghidul angajatilor', 'ghid angajat',
        'regulamentul companiei', 'regulamentul intern', 'regulament intern',
        'programeaza un meet', 'programează un meet', 'schedule meet',
        'cerere de concediu', 'cerere concediu', 'cum solicit concediu',
        'cum iau concediu', 'cum imi iau concediu', 'cum îmi iau concediu',
        'cum fac pentru a mi lua', 'cum fac pentru a-mi lua',
        'prelungesc un task', 'prelungesc task', 'extind un task',
        'zile libere cum', 'cum gestionez zilele', 'cum se gestioneaza zilele',
        'concedii medicale si programul', 'program flexibil',
        'zi de concediu cum', 'zi libera cum',
        'cum pot sa imi iau zile', 'cum pot să-mi iau zile',
        'procedura concediu', 'procedura pentru concediu',
    ]

    if any(t in msg for t in _guide_triggers):
        return {'type': 'text', 'message': _guide_msg}

    # ── 1. Localizare salariu în aplicație ───────────────────────────────────
    if any(p in msg for p in ['gasesc salariul', 'găsesc salariul',
                               'vad salariul', 'văd salariul',
                               'unde e salariul', 'unde este salariul',
                               'cum gasesc', 'cum găsesc']):
        return {
            'type': 'text',
            'message': (
                'Salariul tău se găsește în **dashboard**, '
                'în secțiunea "Fluturaș de salariu".\n\n'
                'Acolo poți vedea:\n'
                '- Salariul de bază\n'
                '- Sporuri și penalizări active\n'
                '- Deducerile (CAS, CASS, impozit)\n'
                '- Salariul net de plată\n\n'
                'Poți descărca fluturașul și în format PDF.'
            )
        }

    # ── 2. Funcționalități neimplementate ────────────────────────────────────
    if any(p in msg for p in ['ore pe minus', 'ore suplimentare luna trecuta',
                               'muncit peste program', 'overtime',
                               'am muncit in plus', 'am lucrat in plus']):
        return not_impl()

    if any(p in msg for p in ['ore pe taskuri', 'ore ramase pe taskuri',
                               'ore mai am pe task', 'timp pe task']):
        return not_impl()

    # ── 3. Data de plată ─────────────────────────────────────────────────────
    if any(p in msg for p in ['data de plata', 'data platii', 'când se plătește',
                               'cand se plateste', 'urmatoarea plata',
                               'urmatoarea data de plata', 'ziua de salariu',
                               'cand primesc salariul', 'când primesc salariul']):
        # Logică: dacă suntem înainte de 15 → plata e pe 15 luna curentă
        #         dacă suntem după 15 → plata e pe 15 luna viitoare
        if now.day <= 15:
            pay_date = date(now.year, now.month, 15)
            when = "luna aceasta"
        else:
            if now.month == 12:
                pay_date = date(now.year + 1, 1, 15)
            else:
                pay_date = date(now.year, now.month + 1, 15)
            when = "luna viitoare"
        return {
            'type': 'text',
            'message': (
                f'Următoarea dată de plată este **15 {pay_date.strftime("%B %Y")}** '
                f'({when}).\n\n'
                f'Salariile se virează pe 15 ale fiecărei luni. '
                f'Dacă 15 cade într-un weekend sau sărbătoare legală, '
                f'plata se face în ultima zi lucrătoare anterioară.'
            )
        }

    # ── 4. Zile lună februarie ────────────────────────────────────────────────
    if any(p in msg for p in ['zile are februarie', 'zile are luna februarie',
                               'zile in februarie', 'câte zile are februarie',
                               'cate zile are februarie']):
        year = now.year
        days = 29 if calendar.isleap(year) else 28
        leap_info = "an bisect" if calendar.isleap(year) else "an obișnuit"
        return {
            'type': 'text',
            'message': (
                f'Luna februarie {year} are **{days} zile** ({leap_info}).\n\n'
                f'Februarie are 28 de zile în anii obișnuiți și '
                f'29 de zile în anii bisecți (divizibili cu 4).'
            )
        }

    # ── 5. Zile de concediu legal ─────────────────────────────────────────────
    if any(p in msg for p in ['zile libere legale sunt', 'zile concediu legal',
                               'câte zile de concediu am legal', 'cate zile de concediu am legal',
                               'zile concediu legal', 'zile de concediu am dreptul',
                               'zile de concediu am in total legal']):
        return {
            'type': 'text',
            'message': (
                'Numărul de zile de concediu legal depinde de tipul angajatului:\n\n'
                '- **Angajați standard**: 21 de zile lucrătoare pe an\n'
                '- **Angajați cu condiții speciale** (handicap, vechime >15 ani): '
                '25-30 de zile\n'
                '- **Tineri sub 18 ani**: 24 de zile\n\n'
                'În sistemul nostru, soldul tău actual de zile rămase este vizibil '
                'direct în dashboard. Poți întreba și: "câte zile de concediu mai am?"'
            )
        }

    # ── 6. Expirare zile concediu ─────────────────────────────────────────────
    if any(p in msg for p in ['expira zilele de concediu', 'expiră zilele de concediu',
                               'cand expira concediul', 'când expiră concediul',
                               'pana cand pot lua concediu', 'pana cand e valabil concediul',
                               'expira concediul nefolosit']):
        return {
            'type': 'text',
            'message': (
                f'Zilele de concediu nefolosite din {now.year} expiră la '
                f'**31 decembrie {now.year}** sau, dacă există acord scris '
                f'cu angajatorul, pot fi transferate în primul trimestru din '
                f'{now.year + 1}.\n\n'
                f'Recomandăm să planifici concediile rămase cât mai curând. '
                f'Verifică soldul tău curent întrebând: "câte zile de concediu mai am?"'
            )
        }

    # ── 7. Atmosfera / cultură organizațională ────────────────────────────────
    if any(p in msg for p in ['atmosfera', 'cultura organizationala', 'cultura organizațională',
                               'cum este la munca', 'cum este la muncă',
                               'mediul de lucru', 'spirit de echipa', 'spirit de echipă']):
        return {
            'type': 'text',
            'message': (
                'Atmosfera în companie este una prietenoasă și profesionistă.\n\n'
                'Promovăm o cultură bazată pe:\n'
                '- Colaborare și respect reciproc\n'
                '- Feedback constructiv și comunicare deschisă\n'
                '- Echilibru muncă-viață personală\n'
                '- Dezvoltare profesională continuă\n\n'
                'Dacă ai întrebări specifice despre cultura organizațională, '
                'departamentul HR este cel mai bun punct de contact.'
            )
        }

    # ── 8. Progresie carieră (junior → middle → senior) ─────────────────────
    if any(p in msg for p in ['trec la middle', 'ajung middle', 'devin middle',
                               'promovez la middle', 'middle developer']):
        return {
            'type': 'text',
            'message': (
                'Tranziția la nivelul **Middle** presupune în general:\n\n'
                '- Minim 2-3 ani experiență relevantă\n'
                '- Capacitatea de a lucra independent pe task-uri medii și mari\n'
                '- Contribuție activă la code review și documentație\n'
                '- Bune abilități de comunicare cu echipa\n\n'
                'Vorbește cu managerul tău direct despre un plan de dezvoltare '
                'și obiective clare. Efort și muncă susținută sunt cheia!'
            )
        }

    if any(p in msg for p in ['ajung senior', 'devin senior', 'trec la senior',
                               'promovez la senior', 'senior developer', 'sa fiu senior']):
        return {
            'type': 'text',
            'message': (
                'Nivelul **Senior** vine cu ani de experiență și maturitate tehnică:\n\n'
                '- 5+ ani experiență în domeniu\n'
                '- Capacitate de a conduce proiecte și mentorat colegi\n'
                '- Viziune arhitecturală și decizii tehnice solide\n'
                '- Responsabilitate pentru calitatea soluțiilor livrate\n\n'
                'Nu există o rețetă rapidă — efort constant, curiozitate și '
                'muncă susținută fac diferența pe termen lung.'
            )
        }

    # ── 9. Așteptări în primele luni ─────────────────────────────────────────
    if any(p in msg for p in ['asteptari in primele luni', 'așteptări în primele luni',
                               'ce se asteapta de la mine', 'ce se așteaptă de la mine',
                               'primele luni in firma', 'primele luni la job',
                               'onboarding', 'ce trebuie sa fac la inceput']):
        return {
            'type': 'text',
            'message': (
                'În primele luni, așteptările principale sunt:\n\n'
                '- **Seriozitate și punctualitate** — prezența și respectarea '
                'programului sunt fundamentale\n'
                '- **Dorința de a învăța** — nimeni nu știe totul de la început\n'
                '- **Comunicare deschisă** — dacă ai întrebări sau probleme, '
                'nu ezita să le ridici\n'
                '- **Integrare în echipă** — construiește relații pozitive cu '
                'colegii tăi\n\n'
                'Fii proactiv, pune întrebări și nu te teme să ceri feedback!'
            )
        }

    # ── 10. Cerere echipament (telefon, laptop etc.) ─────────────────────────
    if any(p in msg for p in ['telefon de munca', 'telefon de muncă', 'telefon serviciu',
                               'laptop de munca', 'echipament de munca', 'echipament de muncă',
                               'cer un telefon', 'cer un laptop']):
        return ask_hr('achiziționarea echipamentelor de muncă')

    # ── 11. Recuperare ore ───────────────────────────────────────────────────
    if any(p in msg for p in ['recuper', 'ore pe minus', 'ore in minus',
                               'recuperez orele', 'compensez orele']):
        return ask_hr('recuperarea orelor')

    # ── 12. Politici diverse → HR ─────────────────────────────────────────────
    hr_triggers = [
        # evaluări și promovări
        ('perioada de promotii', 'perioadele de promovare'),
        ('perioadă de promoții', 'perioadele de promovare'),
        ('evaluari de performanta', 'evaluările de performanță'),
        ('evaluări de performanță', 'evaluările de performanță'),
        ('feedback intern', 'procesul de feedback'),
        ('feedback de la manager', 'feedback-ul de la manager'),
        # recrutare
        ('posturi disponibile', 'posturile disponibile în companie'),
        ('posturi vacante', 'posturile vacante'),
        ('aplica pentru un job', 'aplicarea la joburi interne'),
        ('aplici pentru un job', 'aplicarea la joburi interne'),
        ('proces de recrutare', 'procesul de recrutare'),
        ('selectie pentru un post', 'procesul de selecție'),
        ('selectie pentru o pozitie', 'procesul de selecție'),
        ('aplica la mai multe pozitii', 'aplicarea la multiple poziții'),
        ('aplici la mai multe pozitii', 'aplicarea la multiple poziții'),
        # politici
        ('politica firmei', 'politicile companiei'),
        ('politicile companiei', 'politicile companiei'),
        ('tatuaje la munca', 'politica privind tatuajele'),
        ('tatuaje la muncă', 'politica privind tatuajele'),
        ('munca remote', 'politica de muncă remote/hibrid'),
        ('muncă remote', 'politica de muncă remote/hibrid'),
        ('remote sau hibrid', 'politica de muncă remote/hibrid'),
        ('hibrid', 'politica de muncă hibrid'),
        # carieră și HR
        ('schimba departamentul', 'transferul de departament'),
        ('schimb departamentul', 'transferul de departament'),
        ('schimba echipa', 'schimbarea echipei'),
        ('schimb echipa', 'schimbarea echipei'),
        ('fisa postului', 'fișa postului'),
        ('fișa postului', 'fișa postului'),
        ('manual angajat', 'manualul angajatului'),
        ('comportament', 'comportamentele colegilor'),
        ('colegul meu face', 'comportamentul colegilor'),
        ('doare capul', 'problemele de sănătate la locul de muncă'),
        ('mă doare', 'problemele de sănătate'),
        ('ma doare', 'problemele de sănătate'),
        ('oportunitati de promovare', 'oportunitățile de promovare'),
        ('oportunități de promovare', 'oportunitățile de promovare'),
        ('dezvoltare profesionala', 'dezvoltarea profesională'),
        ('negociez salariul', 'negocierea salariului'),
        ('negocieze salariul', 'negocierea salariului'),
        ('negocia salariul', 'negocierea salariului'),
        ('salarii based on performance', 'salariile bazate pe performanță'),
        ('expected salaries', 'așteptările salariale'),
        ('cat de des pot sa imi iau concediu', 'frecvența concediilor'),
    ]

    for trigger, topic in hr_triggers:
        if trigger in msg:
            return ask_hr(topic)

    # ── 13. CV și sfaturi carieră ─────────────────────────────────────────────
    if any(p in msg for p in ['cv in domeniul it', 'cv în domeniul it',
                               'cel mai important la cv', 'sfat cv',
                               'cum fac un cv', 'cum faci un cv']):
        return {
            'type': 'text',
            'message': (
                'Cel mai important lucru într-un CV pentru IT este **claritatea și relevanța**:\n\n'
                '- **Proiecte concrete** cu tehnologiile folosite și impactul lor\n'
                '- **Stack tehnologic** clar și actualizat (nu lista tot ce ai atins)\n'
                '- **GitHub / portfolio** — mai valoros decât 2 pagini de text\n'
                '- **Experiență cuantificabilă** — "am optimizat X cu 30%" bate "am lucrat la X"\n'
                '- **Limbă engleză** — CV-ul în engleză deschide mai multe uși\n\n'
                'Dacă ai întrebări specifice despre carieră sau recrutare, '
                'departamentul HR te poate îndruma mai bine.'
            )
        }

    # Nicio potrivire — lasăm NLQEngine să proceseze
    return None


def process_query(message: str, user_id=None) -> dict:
    """
    Pipeline complet: text natural → SQL → date → răspuns formatat.

    Pași:
      1. Verificăm dacă e salut/mesaj generic → răspundem direct fără SQL
      2. Folosim NLQEngine să înțeleagă întrebarea și să genereze SQL
      3. Executăm SQL-ul generat direct pe MySQL
      4. Formatăm răspunsul pentru chat.jsp

    Parametri:
        message  - întrebarea utilizatorului în română
        user_id  - ID-ul utilizatorului conectat (din sesiunea JSP)
                   folosit pentru interogări personale ("zilele mele", "taskurile mele")

    Returnează un dict cu structura pe care chat.jsp o așteaptă:
        {type: "text",  message: "..."}                  pentru texte simple
        {type: "table", message: "...", data: [...]}      pentru tabele
        {type: "error", message: "..."}                  pentru erori
    """

    msg_lower = message.lower().strip()

    # ── Pasul 1: Mesaje generice (salut, mulțumesc etc.) ─────────────────────
    # Nu are rost să interogăm baza de date pentru un salut
    if any(w in msg_lower for w in ['salut', 'buna', 'bună', 'hello', 'hi', 'hey']):
        return {
            'type': 'text',
            'message': (
                'Bună! Sunt asistentul HR. Pot să-ți răspund la întrebări despre:\n\n'
                '- Angajați și departamente\n'
                '- Concedii și adeverințe\n'
                '- Proiecte și taskuri\n'
                '- Salarii și poziții\n\n'
                'De exemplu: "câți angajați sunt în IT?" sau "cine e în concediu azi?"'
            )
        }

    if any(w in msg_lower for w in ['multumesc', 'mulțumesc', 'mersi', 'ok', 'bine']):
        return {
            'type': 'text',
            'message': 'Cu plăcere! Mai am alte întrebări la dispoziție.'
        }

    # ── Pasul 1b: Răspunsuri hardcodate (FAQ / politici / UI) ────────────────
    # Aceste întrebări nu necesită query SQL — răspundem direct.
    # Ordinea contează: verificăm pattern-urile mai specifice ÎNAINTE de cele generale.

    hardcoded = _check_hardcoded_faq(msg_lower)
    if hardcoded:
        return hardcoded

    # ── Pasul 2: Verificăm că NLQEngine e disponibil ─────────────────────────
    if not NLQ_AVAILABLE or nlq_engine is None:
        return {
            'type': 'error',
            'message': (
                'NLQEngine v2 nu este disponibil. '
                'Verifică că nlq_engine_v2.py este în același folder cu app.py '
                'și că ai instalat: pip install scikit-learn numpy'
            )
        }

    # ── Pasul 3: NLQEngine procesează întrebarea ─────────────────────────────
    # verbose=False → nu afișăm trace-ul în consolă (pentru producție)
    # verbose=True  → util pentru debugging, afișează tot în terminal
    logger.info(f"Procesez: '{message}' (user_id={user_id})")

    try:
        nlq_result = nlq_engine.process(
            query=message,
            current_user_id=int(user_id) if user_id else None,
            verbose=True   # pune False dacă nu vrei output în terminal
        )
    except Exception as e:
        logger.error(f"Eroare NLQEngine: {e}")
        return {
            'type': 'error',
            'message': f'Eroare la procesarea întrebării: {str(e)}'
        }

    # ── Pasul 4: Verificăm dacă NLQ a înțeles întrebarea ────────────────────
    if not nlq_result.get('success'):
        # NLQ n-a găsit un match suficient de bun → îi spunem utilizatorului
        confidence = nlq_result.get('confidence', 0)
        best_match = nlq_result.get('debug', {}).get('best_match', '—')
        return {
            'type': 'text',
            'message': (
                f'Nu am înțeles exact întrebarea ta.\n\n'
                f'Cel mai apropiat exemplu din baza mea: "{best_match}"\n'
                f'Similaritate: {confidence:.0%}\n\n'
                f'Încearcă să reformulezi. Exemple:\n'
                f'- "câți angajați sunt în IT?"\n'
                f'- "cine e în concediu astăzi?"\n'
                f'- "arată-mi departamentele"'
            )
        }

    # ── Pasul 5: Executăm SQL-ul generat ─────────────────────────────────────
    sql = nlq_result.get('sql')
    if not sql:
        return {
            'type': 'error',
            'message': 'NLQEngine nu a putut genera un query SQL pentru această întrebare.'
        }

    logger.info(f"SQL generat de NLQ: {sql[:150]}...")

    rows, db_error = execute_sql(sql)

    if db_error:
        return {
            'type': 'error',
            'message': f'Eroare la executarea query-ului: {db_error}\n\nSQL: {sql[:200]}...'
        }

    # ── Pasul 6: Formatăm răspunsul ──────────────────────────────────────────
    intent  = nlq_result.get('intent',  'list')
    entity  = nlq_result.get('entity',  '?')
    conf    = nlq_result.get('confidence', 0)
    matched = nlq_result.get('matched_example', '')

    # Câte rezultate am găsit?
    count = len(rows)

    if count == 0:
        # ── Fallback 1: reîncercăm fără filtrul de departament ───────────────
        entities_found = nlq_result.get('entities_found', '')
        had_dept = 'departament=' in entities_found
        import re as _re

        if had_dept:
            logger.info("0 rezultate cu filtru dept → reîncercăm fără departament")
            dept_match = _re.search(r"departament='([^']+)'", entities_found)
            dept_name  = dept_match.group(1) if dept_match else '?'

            sql_fallback = _re.sub(
                r"\s*AND\s+UPPER\(d\.nume_dep\)\s+LIKE\s+UPPER\('[^']*'\)",
                '', sql, flags=_re.IGNORECASE
            )
            sql_fallback = _re.sub(
                r"\s*AND\s+UPPER\(d\.nume_dep\)\s+LIKE\s+'[^']*'",
                '', sql_fallback, flags=_re.IGNORECASE
            )

            if sql_fallback != sql:
                rows_fb, err_fb = execute_sql(sql_fallback)
                if not err_fb and rows_fb:
                    return {
                        'type': 'table',
                        'message': (
                            f'Nu am găsit date pentru departamentul "{dept_name}".\n'
                            f'Îți arăt rezultatele pentru toată firma ({len(rows_fb)} înregistrări):'
                        ),
                        'data': rows_fb
                    }

        # ── Fallback 2: relaxăm filtrul temporal (luni specifice → ±3 luni) ──
        # "Concedii planificate pentru luna aceasta" poate returna 0
        # dacă nu există date pentru luna curentă → extindem la ±3 luni
        has_tight_temporal = any(p in sql for p in [
            'MONTH(c.start_c)=MONTH', 'YEARWEEK(c.start_c)',
            'YEAR(c.start_c)=YEAR(CURDATE())-1'
        ])

        if has_tight_temporal:
            logger.info("0 rezultate cu filtru temporal strict → relaxăm la ±3 luni")
            # Înlocuim filtrul temporal strict cu o fereastră de 3 luni
            sql_relaxed = _re.sub(
                r"MONTH\(c\.start_c\)=MONTH\(CURDATE\(\)\)\s*AND\s*YEAR\(c\.start_c\)=YEAR\(CURDATE\(\)\)",
                "c.start_c BETWEEN CURDATE() - INTERVAL 1 MONTH AND CURDATE() + INTERVAL 3 MONTH",
                sql, flags=_re.IGNORECASE
            )
            sql_relaxed = _re.sub(
                r"YEARWEEK\(c\.start_c\)=YEARWEEK\([^)]+\)",
                "c.start_c BETWEEN CURDATE() - INTERVAL 14 DAY AND CURDATE() + INTERVAL 14 DAY",
                sql_relaxed, flags=_re.IGNORECASE
            )

            if sql_relaxed != sql:
                rows_fb2, err_fb2 = execute_sql(sql_relaxed)
                if not err_fb2 and rows_fb2:
                    return {
                        'type': 'table',
                        'message': (
                            f'Nu am găsit concedii pentru luna exactă.\n'
                            f'Îți arăt concediile din perioada apropiată ({len(rows_fb2)} înregistrări):'
                        ),
                        'data': rows_fb2
                    }

        # Niciun fallback nu a funcționat
        return {
            'type': 'text',
            'message': (
                f'Nu am găsit rezultate pentru: "{message}"\n\n'
                f'Am generat query-ul bazat pe: "{matched}" (similitudine {conf:.0%})\n\n'
                f'Poate că filtrele sunt prea stricte. Încearcă fără restricții de dată sau departament.'
            )
        }

    # Intent COUNT → avem un singur număr, îl afișăm ca text, nu ca tabel
    if intent == 'count' and count == 1:
        # Extragem valoarea numărului din primul (și singurul) rând
        first_row = rows[0]
        # Luăm prima valoare din dict (COUNT(*) AS total_X)
        numeric_value = list(first_row.values())[0]
        column_name   = list(first_row.keys())[0]   # ex: "total_angajati"

        # Facem denumirea mai friendly: "total_angajati" → "Total angajați"
        friendly = column_name.replace('_', ' ').replace('total', 'Total').strip()

        return {
            'type': 'text',
            'message': f'{friendly}: **{numeric_value}**'
        }

    # Intent LIST / DETAIL / AGGREGATE cu date → afișăm tabel
    return {
        'type': 'table',
        'message': f'Am găsit {count} rezultate pentru: "{message}"',
        'data': rows   # lista de dict-uri — chat.jsp știe să le afișeze ca tabel
    }


# ══════════════════════════════════════════════════════════════════════════════
# ENDPOINTS FLASK
# ══════════════════════════════════════════════════════════════════════════════

@app.route('/chat', methods=['POST', 'OPTIONS'])
def chat_endpoint():
    """
    Endpoint principal — primit de chat.jsp.

    Acceptă JSON cu:
        {
          "message": "câți angajați sunt în IT?",
          "user_id": 42
        }

    Returnează JSON cu:
        {type: "text"|"table"|"error", message: "...", data: [...]}

    OPTIONS → CORS preflight (browser-ul trimite asta automat înainte de POST)
    """
    # CORS preflight — browser-ul întreabă mai întâi dacă poate trimite cererea
    if request.method == 'OPTIONS':
        response = jsonify({'status': 'ok'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        response.headers.add('Access-Control-Allow-Methods', 'POST')
        return response

    try:
        # ── Extragem datele din request ───────────────────────────────────────
        # chat.jsp trimite JSON → request.is_json va fi True
        if request.is_json:
            data    = request.get_json()
            message = data.get('message', '').strip()
            user_id = data.get('user_id')
        else:
            # Fallback pentru form-encoded (compatibilitate cu versiunea veche)
            message = request.form.get('message', '') or request.form.get('query', '')
            user_id = request.form.get('user_id')

        logger.info(f"📨 Chat request: '{message[:80]}...' (user_id={user_id})")

        if not message:
            return jsonify({
                'type': 'error',
                'message': 'Mesajul nu poate fi gol.'
            }), 400

        # ── Procesăm ─────────────────────────────────────────────────────────
        result = process_query(message, user_id)

        # Adăugăm timestamp (opțional, chat.jsp nu îl folosește dar e util pentru debug)
        result['timestamp'] = datetime.now().isoformat()

        response = jsonify(result)
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response

    except Exception as e:
        logger.error(f"💥 Eroare neașteptată în /chat: {e}")
        logger.error(traceback.format_exc())
        error_response = jsonify({
            'type': 'error',
            'message': f'Eroare internă server: {str(e)}'
        })
        error_response.headers.add('Access-Control-Allow-Origin', '*')
        return error_response, 500


@app.route('/health', methods=['GET'])
def health_check():
    """
    Verifică că serverul Flask și conexiunea MySQL funcționează.
    Accesează: http://localhost:5000/health
    """
    conn, err = get_db_connection()
    db_ok = err is None
    if conn:
        conn.close()

    return jsonify({
        'status':        'ok',
        'flask':         'running',
        'nlq_engine':    'loaded' if NLQ_AVAILABLE else 'NOT LOADED',
        'mysql':         'connected' if db_ok else f'ERROR: {err}',
        'timestamp':     datetime.now().isoformat(),
        'usage':         'POST /chat cu { "message": "...", "user_id": 1 }'
    })


@app.route('/test-sql', methods=['GET'])
def test_sql():
    """
    Testează conexiunea MySQL cu un query simplu.
    Accesează: http://localhost:5000/test-sql
    Util pentru a verifica că baza de date e accesibilă.
    """
    rows, err = execute_sql("SELECT COUNT(*) as total FROM useri WHERE username != 'test'")
    if err:
        return jsonify({'success': False, 'error': err}), 500
    return jsonify({'success': True, 'result': rows})


@app.route('/', methods=['GET'])
def index():
    """Documentație rapidă la accesarea http://localhost:5000/"""
    return jsonify({
        'title':        'Flask HR Assistant - NLQEngine v2',
        'architecture': 'chat.jsp → Flask /chat → NLQEngine → MySQL',
        'endpoints': {
            'POST /chat':    'Procesează întrebări în română, returnează date',
            'GET  /health':  'Verifică statusul Flask + NLQ + MySQL',
            'GET  /test-sql':'Testează conexiunea la MySQL',
        },
        'example_request': {
            'method':  'POST',
            'url':     'http://localhost:5000/chat',
            'body':    {'message': 'câți angajați sunt în IT?', 'user_id': 1},
            'headers': {'Content-Type': 'application/json'}
        }
    })


@app.errorhandler(404)
def not_found(e):
    return jsonify({'type': 'error', 'message': 'Endpoint inexistent.'}), 404


@app.errorhandler(500)
def server_error(e):
    return jsonify({'type': 'error', 'message': 'Eroare internă.'}), 500


# ══════════════════════════════════════════════════════════════════════════════
# PORNIRE SERVER
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 65)
    print("  Flask HR Assistant — NLQEngine v2 + MySQL Direct")
    print("=" * 65)
    print(f"  NLQEngine:    {'✅ gata' if NLQ_AVAILABLE else '❌ LIPSĂ — verifică nlq_engine_v2.py'}")

    # Testăm MySQL la startup
    conn, err = get_db_connection()
    if conn:
        conn.close()
        print("  MySQL:        ✅ conectat")
    else:
        print(f"  MySQL:        ❌ eroare: {err}")

    print()
    print("  Endpoint:     POST http://localhost:5000/chat")
    print("  Health:       GET  http://localhost:5000/health")
    print("  Test SQL:     GET  http://localhost:5000/test-sql")
    print("=" * 65)
    print()

    app.run(host='0.0.0.0', port=5000, debug=True)