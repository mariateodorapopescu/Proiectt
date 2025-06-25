#!/usr/bin/env python3
"""
Script complet pentru testarea Enterprise Flask AI Application
Testează toate endpoint-urile și funcționalitățile
"""

import requests
import json
import time
import sys
from typing import Dict, Any

class FlaskAppTester:
    def __init__(self, base_url: str = "http://localhost:5000"):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        self.session.headers.update({
            'Content-Type': 'application/json',
            'User-Agent': 'Flask-App-Tester/1.0'
        })
        
        print("🧪 Flask Application Tester initialized")
        print(f"🎯 Target: {self.base_url}")
        
    def test_connection(self) -> bool:
        """Testează dacă aplicația rulează"""
        try:
            response = self.session.get(f"{self.base_url}/", timeout=5)
            if response.status_code == 200:
                print("✅ Connection successful!")
                return True
            else:
                print(f"❌ Connection failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Cannot connect to Flask app: {e}")
            print("💡 Make sure the Flask app is running: python app.py")
            return False
    
    def test_documentation_endpoint(self):
        """Test GET / - API documentation"""
        print("\n📚 Testing API Documentation (GET /)")
        
        try:
            response = self.session.get(f"{self.base_url}/")
            response.raise_for_status()
            
            data = response.json()
            print("✅ Documentation endpoint works!")
            print(f"📋 Title: {data.get('title', 'N/A')}")
            print(f"📊 Version: {data.get('version', 'N/A')}")
            print(f"🔧 Available endpoints: {len(data.get('endpoints', {}))}")
            print(f"🧠 AI Features: {list(data.get('features', {}).keys())}")
            
            return data
            
        except Exception as e:
            print(f"❌ Documentation test failed: {e}")
            return None
    
    def test_health_check(self):
        """Test GET /health"""
        print("\n🏥 Testing Health Check (GET /health)")
        
        try:
            response = self.session.get(f"{self.base_url}/health")
            response.raise_for_status()
            
            data = response.json()
            print(f"✅ Health status: {data.get('overall_status', 'UNKNOWN')}")
            
            components = data.get('components', {})
            for component, status in components.items():
                emoji = "✅" if status == "OK" else "❌" if status == "ERROR" else "⚠️"
                print(f"  {emoji} {component}: {status}")
            
            print(f"🧠 AI Capabilities: {list(data.get('capabilities', {}).keys())}")
            print(f"💬 Active sessions: {data.get('active_sessions', 0)}")
            
            return data
            
        except Exception as e:
            print(f"❌ Health check failed: {e}")
            return None
    
    def test_query_examples(self):
        """Test GET /query-examples"""
        print("\n📋 Testing Query Examples (GET /query-examples)")
        
        try:
            response = self.session.get(f"{self.base_url}/query-examples")
            response.raise_for_status()
            
            data = response.json()
            print("✅ Query examples loaded!")
            
            categories = data.get('categories', {})
            for category, examples in categories.items():
                if isinstance(examples, dict):
                    total_examples = sum(len(v) if isinstance(v, list) else 1 for v in examples.values())
                else:
                    total_examples = len(examples) if isinstance(examples, list) else 1
                print(f"  📂 {category}: {total_examples} examples")
            
            return data
            
        except Exception as e:
            print(f"❌ Query examples test failed: {e}")
            return None
    
    def test_enterprise_query(self, query: str, session_id: str = "test_session"):
        """Test POST /enterprise-query"""
        print(f"\n🧠 Testing Enterprise Query: '{query}'")
        
        payload = {
            "query": query,
            "session_id": session_id,
            "user_context": {"tester": True}
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/enterprise-query",
                json=payload
            )
            response.raise_for_status()
            
            data = response.json()
            
            # Display results
            ai_analysis = data.get('ai_analysis', {})
            print(f"✅ Query processed successfully!")
            print(f"📊 Category: {ai_analysis.get('category', 'N/A')}")
            print(f"🎯 Intent: {ai_analysis.get('intent_type', 'N/A')}")
            print(f"🔍 Complexity: {ai_analysis.get('complexity', 'N/A')}")
            print(f"📈 Confidence: {ai_analysis.get('confidence', 0):.3f}")
            print(f"🏷️ Entities found: {ai_analysis.get('entities_found', {})}")
            
            if data.get('sql_query'):
                print(f"💾 Generated SQL: {data['sql_query'][:100]}...")
            
            conversation = data.get('conversation', {})
            print(f"💬 Session: {conversation.get('session_id')}, Query #{conversation.get('query_number')}")
            
            if data.get('results'):
                print(f"📋 SQL Results: {len(data['results'])} rows returned")
            elif data.get('sql_query', '').startswith("SELECT 'Query category not yet implemented'"):
                print("⚠️ Category not fully implemented yet")
            else:
                print("⚠️ No SQL results (backend connection issue)")
            
            return data
            
        except Exception as e:
            print(f"❌ Enterprise query failed: {e}")
            return None
    
    def test_chat_interface(self, query: str, session_id: str = "test_chat"):
        """Test POST /chat"""
        print(f"\n💬 Testing Chat Interface: '{query}'")
        
        payload = {
            "query": query,
            "session_id": session_id
        }
        
        try:
            response = self.session.post(
                f"{self.base_url}/chat",
                json=payload
            )
            response.raise_for_status()
            
            data = response.json()
            
            if 'response' in data:
                print(f"✅ Chat response: {data['response']}")
                if data.get('conversation_ended'):
                    print("🔚 Conversation ended")
            else:
                # Chat redirected to enterprise query
                ai_analysis = data.get('ai_analysis', {})
                print(f"✅ Chat processed as enterprise query")
                print(f"📊 Category: {ai_analysis.get('category', 'N/A')}")
                print(f"🎯 Response type: {ai_analysis.get('intent_type', 'N/A')}")
            
            return data
            
        except Exception as e:
            print(f"❌ Chat test failed: {e}")
            return None
    
    def test_conversation_context(self, session_id: str = "test_session"):
        """Test conversation context endpoints"""
        print(f"\n💭 Testing Conversation Context for session: {session_id}")
        
        # Get context
        try:
            response = self.session.get(
                f"{self.base_url}/conversation-context",
                params={"session_id": session_id}
            )
            response.raise_for_status()
            
            data = response.json()
            print(f"✅ Context retrieved: {data['total_queries']} queries in history")
            
            if data.get('conversation_history'):
                print("📜 Recent queries:")
                for i, entry in enumerate(data['conversation_history'][-3:], 1):
                    print(f"  {i}. {entry.get('query', 'N/A')}")
            
            return data
            
        except Exception as e:
            print(f"❌ Context retrieval failed: {e}")
            return None
    
    def test_analyze_complexity(self, query: str):
        """Test POST /analyze-complexity"""
        print(f"\n🔍 Testing Complexity Analysis: '{query}'")
        
        payload = {"query": query}
        
        try:
            response = self.session.post(
                f"{self.base_url}/analyze-complexity",
                json=payload
            )
            response.raise_for_status()
            
            data = response.json()
            
            complexity = data.get('complexity_assessment', {})
            print(f"✅ Complexity: {complexity.get('level', 'N/A')}")
            
            factors = complexity.get('factors', {})
            print(f"📊 Word count: {factors.get('word_count', 0)}")
            print(f"🏷️ Entities: {factors.get('entities_found', {})}")
            print(f"📈 Confidence: {data.get('ai_classification', {}).get('confidence', 0):.3f}")
            
            return data
            
        except Exception as e:
            print(f"❌ Complexity analysis failed: {e}")
            return None
    
    def test_benchmark_vs_regex(self, queries: list):
        """Test POST /benchmark-vs-regex"""
        print(f"\n⚖️ Testing AI vs Regex Benchmark ({len(queries)} queries)")
        
        payload = {"queries": queries}
        
        try:
            response = self.session.post(
                f"{self.base_url}/benchmark-vs-regex",
                json=payload
            )
            response.raise_for_status()
            
            data = response.json()
            
            summary = data.get('summary', {})
            print(f"✅ Benchmark completed!")
            print(f"📊 Category accuracy: {summary.get('category_accuracy', 0):.2%}")
            print(f"📈 Average AI confidence: {summary.get('average_ai_confidence', 0):.3f}")
            print(f"🔧 Improvement areas: {len(summary.get('improvement_areas', []))}")
            
            return data
            
        except Exception as e:
            print(f"❌ Benchmark failed: {e}")
            return None
    
    def test_demo_conversation(self):
        """Test POST /demo-conversation"""
        print("\n🎭 Testing Demo Conversation")
        
        try:
            response = self.session.post(f"{self.base_url}/demo-conversation")
            response.raise_for_status()
            
            data = response.json()
            
            print(f"✅ Demo loaded! Title: {data.get('demo_title', 'N/A')}")
            
            flow = data.get('conversation_flow', [])
            print(f"💬 Conversation steps: {len(flow)}")
            
            for i, step in enumerate(flow, 1):
                print(f"  {i}. User: {step.get('user', 'N/A')}")
                print(f"     AI: {step.get('ai_response', 'N/A')[:50]}...")
            
            features = data.get('features_demonstrated', [])
            print(f"🚀 Features demonstrated: {len(features)}")
            
            return data
            
        except Exception as e:
            print(f"❌ Demo conversation failed: {e}")
            return None
    
    def run_comprehensive_tests(self):
        """Rulează toate testele într-o secvență logică"""
        print("🚀 Starting Comprehensive Flask App Testing")
        print("=" * 60)
        
        # 1. Test connection
        if not self.test_connection():
            print("❌ Cannot proceed - Flask app not responding")
            return False
        
        # 2. Basic endpoints
        self.test_documentation_endpoint()
        self.test_health_check()
        self.test_query_examples()
        
        # 3. Core functionality tests
        test_queries = [
            "Angajații din IT",
            "Câți angajați sunt în departamentul HR?",
            "Concediile aprobate din luna martie",
            "Lista programatorilor din companie",
            "Departamentele cu cei mai mulți angajați"
        ]
        
        print("\n" + "=" * 60)
        print("🧠 TESTING CORE AI FUNCTIONALITY")
        print("=" * 60)
        
        for query in test_queries:
            result = self.test_enterprise_query(query)
            if result:
                # Test complexity analysis for the same query
                self.test_analyze_complexity(query)
            time.sleep(1)  # Small delay between tests
        
        # 4. Chat interface tests
        print("\n" + "=" * 60)
        print("💬 TESTING CHAT INTERFACE")
        print("=" * 60)
        
        chat_queries = [
            "Angajații din IT",
            "da, te rog",  # followup
            "mai multe detalii",  # followup
            "nu, suficient"  # exit
        ]
        
        for query in chat_queries:
            self.test_chat_interface(query)
            time.sleep(0.5)
        
        # 5. Conversation context
        self.test_conversation_context()
        
        # 6. Benchmark testing
        benchmark_queries = [
            "angajați din IT",
            "departament HR",
            "concedii aprobate",
            "proiecte active"
        ]
        
        self.test_benchmark_vs_regex(benchmark_queries)
        
        # 7. Demo conversation
        self.test_demo_conversation()
        
        print("\n" + "=" * 60)
        print("✅ COMPREHENSIVE TESTING COMPLETED!")
        print("=" * 60)
        
        return True
    
    def interactive_testing_menu(self):
        """Meniu interactiv pentru testare"""
        while True:
            print("\n" + "=" * 50)
            print("🧪 FLASK APP INTERACTIVE TESTER")
            print("=" * 50)
            print("1. Test Connection & Health")
            print("2. Test Custom Enterprise Query")
            print("3. Test Chat Interface")
            print("4. Run All Comprehensive Tests")
            print("5. Test Specific Endpoint")
            print("6. View Query Examples")
            print("7. Benchmark AI vs Regex")
            print("0. Exit")
            
            choice = input("\n👆 Choose option (0-7): ").strip()
            
            if choice == "0":
                print("👋 Goodbye!")
                break
            elif choice == "1":
                self.test_connection()
                self.test_health_check()
            elif choice == "2":
                query = input("🔍 Enter your query: ").strip()
                if query:
                    self.test_enterprise_query(query)
                    self.test_analyze_complexity(query)
            elif choice == "3":
                query = input("💬 Enter chat message: ").strip()
                if query:
                    self.test_chat_interface(query)
            elif choice == "4":
                self.run_comprehensive_tests()
            elif choice == "5":
                endpoint = input("🎯 Enter endpoint (e.g., /health): ").strip()
                if endpoint:
                    try:
                        response = self.session.get(f"{self.base_url}{endpoint}")
                        print(f"Status: {response.status_code}")
                        print(f"Response: {response.text[:500]}...")
                    except Exception as e:
                        print(f"❌ Error: {e}")
            elif choice == "6":
                self.test_query_examples()
            elif choice == "7":
                queries = input("📝 Enter queries (comma-separated): ").strip().split(",")
                queries = [q.strip() for q in queries if q.strip()]
                if queries:
                    self.test_benchmark_vs_regex(queries)
            else:
                print("❌ Invalid choice, try again")


def main():
    """Funcția principală"""
    if len(sys.argv) > 1:
        base_url = sys.argv[1]
    else:
        base_url = "http://localhost:5000"
    
    tester = FlaskAppTester(base_url)
    
    # Check if Flask app is running
    if not tester.test_connection():
        print("\n💡 To start the Flask app:")
        print("   python app.py")
        return
    
    print("\n🎯 Testing mode:")
    print("1. Comprehensive (automated)")
    print("2. Interactive")
    
    mode = input("Choose mode (1-2): ").strip()
    
    if mode == "1":
        tester.run_comprehensive_tests()
    else:
        tester.interactive_testing_menu()


if __name__ == "__main__":
    main()