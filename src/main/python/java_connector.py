import requests
import json
from typing import Optional, Dict, Any
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class JavaAppConnector:
    """Gestionează comunicarea cu QueryServlet Java/Tomcat pentru execuția SQL-urilor"""
    
    def __init__(self, base_url: str):
        """
        Inițializează connector-ul pentru Java backend
        
        Args:
            base_url: URL-ul de bază (ex: http://172.25.0.1:9999/Proiect)
        """
        self.base_url = base_url.rstrip('/')  # Remove trailing slash
        self.session = requests.Session()
        self.session.timeout = 30  # Timeout mai mare pentru query-uri complexe
        
        # Headers comune
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'Python-Flask-AI-System/1.0',
            'Accept': 'application/json'
        })
        
        logger.info(f"🔧 Java Connector initialized for {self.base_url}")
    
    def test_connection(self) -> bool:
        """Testează conexiunea cu QueryServlet"""
        try:
            url = f"{self.base_url}/QueryServlet"
            logger.info(f"🔍 Testing connection to QueryServlet: {url}")
            
            # GET request pentru status
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            
            result = response.json()
            
            if result.get("servlet") == "QueryServlet" and result.get("status") == "active":
                logger.info(f"✅ QueryServlet connection successful")
                
                # Log database info dacă este disponibilă
                db_connection = result.get("databaseConnection", "unknown")
                db_product = result.get("databaseProduct", "unknown")
                logger.info(f"📊 Database: {db_product}, Status: {db_connection}")
                
                return True
            else:
                logger.warning(f"⚠️ QueryServlet response unexpected: {result}")
                return False
                
        except requests.exceptions.ConnectionError:
            logger.error(f"❌ Connection refused to QueryServlet at {url}")
            return False
        except requests.exceptions.Timeout:
            logger.error(f"⏰ Connection timeout to QueryServlet")
            return False
        except requests.exceptions.RequestException as e:
            logger.error(f"💥 Request error: {e}")
            return False
        except json.JSONDecodeError:
            logger.error(f"📄 Non-JSON response from QueryServlet")
            return False
        except Exception as e:
            logger.error(f"💥 Unexpected error: {e}")
            return False
    
    def execute_query(self, sql_query: str) -> Optional[Dict]:
        """
        Execută un query SQL prin QueryServlet
        
        Args:
            sql_query: Query-ul SQL de executat
            
        Returns:
            Rezultatele query-ului sau None în caz de eroare
        """
        try:
            url = f"{self.base_url}/QueryServlet"
            
            # Payload-ul pentru QueryServlet
            payload = {
                "query": sql_query,
                "source": "flask_ai_system",
                "timestamp": self._get_timestamp()
            }
            
            logger.info(f"📤 Sending SQL query to QueryServlet")
            logger.info(f"🔍 Query: {sql_query[:100]}{'...' if len(sql_query) > 100 else ''}")
            
            # Trimite request-ul POST
            response = self.session.post(url, json=payload)
            response.raise_for_status()
            
            result = response.json()
            
            # Verifică dacă query-ul a fost executat cu succes
            if result.get("success", False):
                logger.info(f"✅ Query executed successfully")
                logger.info(f"📊 Rows returned: {result.get('rowCount', 0)}")
                logger.info(f"⏱️ Execution time: {result.get('executionTime', 'unknown')}")
                
                # Log column info
                columns = result.get("columns", [])
                if columns:
                    logger.info(f"📋 Columns: {', '.join(columns)}")
                
                return result
                
            else:
                # Query a eșuat
                error_msg = result.get("error", "Unknown database error")
                logger.error(f"❌ SQL query failed: {error_msg}")
                logger.error(f"🔍 Failed query: {sql_query}")
                
                return {
                    "success": False,
                    "error": error_msg,
                    "data": [],
                    "rowCount": 0,
                    "columnCount": 0,
                    "columns": [],
                    "message": "Query execution failed"
                }
            
        except requests.exceptions.ConnectionError:
            logger.error(f"❌ Cannot connect to QueryServlet at {url}")
            logger.error("💡 Make sure Tomcat server is running and QueryServlet is deployed")
            return self._create_error_response("Connection refused to QueryServlet")
            
        except requests.exceptions.Timeout:
            logger.error(f"⏰ Query execution timeout (>{self.session.timeout}s)")
            logger.error(f"🔍 Timeout query: {sql_query}")
            return self._create_error_response("Query execution timeout")
            
        except requests.exceptions.HTTPError as e:
            logger.error(f"🚫 HTTP Error {e.response.status_code}")
            try:
                error_response = e.response.json()
                error_msg = error_response.get("error", e.response.text)
            except:
                error_msg = e.response.text
            
            logger.error(f"📄 Error response: {error_msg}")
            return self._create_error_response(f"HTTP {e.response.status_code}: {error_msg}")
            
        except json.JSONDecodeError:
            logger.error(f"📄 Invalid JSON response from QueryServlet")
            return self._create_error_response("Invalid JSON response from server")
            
        except Exception as e:
            logger.error(f"💥 Unexpected error executing query: {e}")
            logger.error(f"🔍 Error query: {sql_query}")
            return self._create_error_response(f"Unexpected error: {str(e)}")
    
    def _create_error_response(self, error_message: str) -> Dict:
        """Creează un răspuns de eroare standardizat"""
        return {
            "success": False,
            "error": error_message,
            "data": [],
            "rowCount": 0,
            "columnCount": 0,
            "columns": [],
            "executionTime": "0ms",
            "message": "Query execution failed",
            "timestamp": self._get_timestamp()
        }
    
    def get_database_schema(self) -> Optional[Dict]:
        """Obține informații despre schema bazei de date"""
        try:
            # Query pentru a obține lista tabelelor
            tables_query = """
            SELECT TABLE_NAME, TABLE_COMMENT, TABLE_ROWS 
            FROM information_schema.TABLES 
            WHERE TABLE_SCHEMA = DATABASE()
            ORDER BY TABLE_NAME
            """
            
            tables_result = self.execute_query(tables_query)
            
            if not tables_result or not tables_result.get("success"):
                return None
            
            schema_info = {
                "database": "current_database",
                "tables": [],
                "timestamp": self._get_timestamp()
            }
            
            # Pentru fiecare tabel, obține coloanele
            for table_data in tables_result.get("data", []):
                table_name = table_data.get("TABLE_NAME", "")
                
                if table_name:
                    columns_query = f"""
                    SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT
                    FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '{table_name}'
                    ORDER BY ORDINAL_POSITION
                    """
                    
                    columns_result = self.execute_query(columns_query)
                    
                    table_info = {
                        "name": table_name,
                        "comment": table_data.get("TABLE_COMMENT", ""),
                        "rows": table_data.get("TABLE_ROWS", 0),
                        "columns": columns_result.get("data", []) if columns_result and columns_result.get("success") else []
                    }
                    
                    schema_info["tables"].append(table_info)
            
            return schema_info
            
        except Exception as e:
            logger.error(f"⚠️ Cannot retrieve database schema: {e}")
            return None
    
    def validate_query(self, sql_query: str) -> Dict:
        """
        Validează un query SQL fără a-l executa
        Folosește EXPLAIN pentru validare
        """
        try:
            # Pentru SELECT queries, folosește EXPLAIN
            if sql_query.strip().upper().startswith("SELECT"):
                explain_query = f"EXPLAIN {sql_query}"
                result = self.execute_query(explain_query)
                
                if result and result.get("success"):
                    return {
                        "valid": True,
                        "message": "Query syntax is valid",
                        "explain_plan": result.get("data", []),
                        "estimated_rows": sum(row.get("rows", 0) for row in result.get("data", []))
                    }
                else:
                    return {
                        "valid": False,
                        "error": result.get("error", "EXPLAIN failed") if result else "Query validation failed",
                        "suggestion": "Check query syntax and table/column names"
                    }
            else:
                # Pentru alte tipuri de query-uri, doar verificare de bază
                return {
                    "valid": True,
                    "message": "Basic validation passed (non-SELECT query)",
                    "note": "Full validation only available for SELECT queries"
                }
                
        except Exception as e:
            logger.error(f"⚠️ Query validation failed: {e}")
            return {
                "valid": False,
                "error": str(e),
                "suggestion": "Check query syntax"
            }
    
    def get_system_status(self) -> Dict:
        """Obține statusul sistemului QueryServlet"""
        try:
            url = f"{self.base_url}/QueryServlet"
            
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            
            servlet_status = response.json()
            
            # Adaugă informații suplimentare
            servlet_status["connection_test"] = self.test_connection()
            servlet_status["connector_version"] = "1.0.0"
            servlet_status["last_check"] = self._get_timestamp()
            
            return servlet_status
            
        except Exception as e:
            return {
                "status": "error",
                "message": f"Cannot reach QueryServlet: {e}",
                "servlet_url": f"{self.base_url}/QueryServlet",
                "connection_test": False,
                "last_check": self._get_timestamp()
            }
    
    def send_feedback(self, query: str, intent: Dict, success: bool, user_feedback: str = None) -> bool:
        """
        Trimite feedback pentru îmbunătățirea sistemului
        (Implementare viitoare - poate fi salvat în baza de date)
        """
        try:
            feedback_data = {
                "original_query": query,
                "detected_intent": intent,
                "execution_success": success,
                "user_feedback": user_feedback,
                "timestamp": self._get_timestamp()
            }
            
            # Pentru moment, doar log feedback-ul
            logger.info(f"📝 Feedback received: {feedback_data}")
            
            # În viitor, poate fi salvat în tabel de feedback
            # feedback_query = "INSERT INTO query_feedback (query, intent, success, feedback, timestamp) VALUES (?, ?, ?, ?, ?)"
            
            return True
            
        except Exception as e:
            logger.error(f"⚠️ Failed to send feedback: {e}")
            return False
    
    def get_query_history(self, limit: int = 10) -> Optional[list]:
        """
        Obține istoricul query-urilor executate
        (Implementare viitoare - poate fi salvat în baza de date)
        """
        try:
            # În viitor, poate fi implementat cu un tabel de audit
            history_query = f"""
            SELECT 
                'Sample query' as query,
                NOW() as timestamp,
                'SELECT' as query_type,
                'flask_ai_system' as source
            LIMIT {limit}
            """
            
            result = self.execute_query(history_query)
            
            if result and result.get("success"):
                return result.get("data", [])
            else:
                logger.warning("⚠️ Cannot retrieve query history")
                return None
                
        except Exception as e:
            logger.error(f"⚠️ Cannot retrieve query history: {e}")
            return None
    
    def _get_timestamp(self) -> str:
        """Generează timestamp curent în format ISO"""
        return datetime.now().isoformat()
    
    def __str__(self) -> str:
        return f"JavaAppConnector(base_url='{self.base_url}')"
    
    def __repr__(self) -> str:
        return self.__str__()