"""
Enterprise-Grade Natural Language Processing System for HR/Company Queries
Replaces Java regex pattern matching with AI/ML approaches

This system handles complex queries like:
- Employee queries with multiple filters
- Department-specific searches  
- Leave/vacation queries with temporal constraints
- Certificate/document requests
- Project and task management queries
- Policy and procedure questions
"""

import torch
from transformers import AutoTokenizer, AutoModel, pipeline
import spacy
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
import re
import json
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple, Any
from datetime import datetime, timedelta
import logging
from enum import Enum

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class QueryComplexity(Enum):
    SIMPLE = "simple"
    INTERMEDIATE = "intermediate" 
    COMPLEX = "complex"
    EXPERT = "expert"

class QueryCategory(Enum):
    EMPLOYEE = "employee"
    DEPARTMENT = "department"
    LEAVE = "leave"
    CERTIFICATE = "certificate"
    PROJECT = "project"
    TASK = "task"
    POLICY = "policy"
    GENERAL = "general"
    FOLLOWUP = "followup"

@dataclass
class TemporalContext:
    """Represents temporal information extracted from queries"""
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    year: Optional[int] = None
    month: Optional[str] = None
    relative_time: Optional[str] = None  # "anul acesta", "luna trecută"
    time_range: Optional[str] = None     # "între", "de la...până la"

@dataclass
class EntityContext:
    """Represents extracted entities and their context"""
    persons: List[str] = field(default_factory=list)
    departments: List[str] = field(default_factory=list)
    positions: List[str] = field(default_factory=list)
    locations: List[str] = field(default_factory=list)
    numbers: List[int] = field(default_factory=list)
    emails: List[str] = field(default_factory=list)
    phone_numbers: List[str] = field(default_factory=list)

@dataclass
class QueryIntent:
    """Advanced query intent with full context"""
    category: QueryCategory
    intent_type: str  # count, list, filter, aggregate, update, delete
    entities: EntityContext
    temporal: TemporalContext
    filters: Dict[str, Any]
    attributes: List[str]
    confidence: float
    complexity: QueryComplexity
    semantic_similarity: float
    conversational_context: Optional[str] = None
    followup_type: Optional[str] = None
    reasoning: str = ""

class EnterpriseNLPProcessor:
    """Enterprise-grade NLP processor for complex HR queries"""
    
    def __init__(self):
        logger.info("🚀 Initializing Enterprise NLP Processor...")
        
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        logger.info(f"📱 Device: {self.device}")
        
        # Load models
        self._load_models()
        
        # Initialize knowledge bases
        self._initialize_knowledge_bases()
        
        # Pre-compute embeddings
        self._precompute_embeddings()
        
        # Initialize conversation context
        self.conversation_history = []
        self.last_query_context = None
        
        logger.info("✅ Enterprise NLP Processor ready!")
    
    def _load_models(self):
        """Load all AI models"""
        try:
            # Romanian BERT model
            logger.info("📚 Loading RoBERT (Romanian BERT)...")
            self.robert_tokenizer = AutoTokenizer.from_pretrained(
                "dumitrescustefan/bert-base-romanian-cased-v1"
            )
            self.robert_model = AutoModel.from_pretrained(
                "dumitrescustefan/bert-base-romanian-cased-v1"
            ).to(self.device)
            
            # SpaCy Romanian model
            logger.info("🌐 Loading spaCy Romanian model...")
            try:
                self.nlp_ro = spacy.load("ro_core_news_sm")
            except OSError:
                logger.warning("⚠️ Installing Romanian spaCy model...")
                import subprocess
                subprocess.run(["python", "-m", "spacy", "download", "ro_core_news_sm"])
                self.nlp_ro = spacy.load("ro_core_news_sm")
            
            # Text classification pipeline
            logger.info("🏷️ Loading text classification...")
            self.classifier = pipeline(
                "text-classification",
                model="nlptown/bert-base-multilingual-uncased-sentiment",
                device=0 if torch.cuda.is_available() else -1
            )
            
        except Exception as e:
            logger.error(f"❌ Error loading models: {e}")
            self._load_fallback_models()
    
    def _load_fallback_models(self):
        """Load simpler fallback models"""
        logger.info("🔄 Loading fallback models...")
        try:
            self.robert_tokenizer = AutoTokenizer.from_pretrained("bert-base-multilingual-cased")
            self.robert_model = AutoModel.from_pretrained("bert-base-multilingual-cased").to(self.device)
            self.nlp_ro = None
            self.classifier = None
        except Exception as e:
            logger.error(f"❌ Critical error: {e}")
            raise
    
    def _initialize_knowledge_bases(self):
        """Initialize comprehensive knowledge bases for enterprise queries"""
        
        # Department mapping with variations
        self.departments = {
            "hr": ["hr", "resurse umane", "human resources", "personal", "resurse", "oameni"],
            "it": ["it", "informatica", "tehnologia informatiei", "computer", "tech", "tehnologie"],
            "finante": ["finante", "finanțe", "financiar", "contabilitate", "accounting", "finance"],
            "juridic": ["juridic", "legal", "drept", "avocat", "consilier juridic"],
            "marketing": ["marketing", "publicitate", "promovare", "advertising", "promo"],
            "vanzari": ["vanzari", "vânzări", "sales", "comercial", "business"],
            "logistica": ["logistica", "logistică", "transport", "expediere", "shipping"],
            "productie": ["productie", "producție", "manufacturing", "fabricație", "uzina"],
            "achizitii": ["achizitii", "achiziții", "procurement", "aprovizionare", "cumparari"],
            "cercetare": ["cercetare", "dezvoltare", "research", "development", "r&d", "rd"]
        }
        
        # Position/role mapping
        self.positions = {
            "director": ["director", "ceo", "manager general", "chief", "director general"],
            "manager": ["manager", "sef", "șef", "supervisor", "team lead", "lead"],
            "specialist": ["specialist", "expert", "consultant", "analist", "analyst"],
            "programator": ["programator", "developer", "programmer", "software engineer", "dev"],
            "designer": ["designer", "graphic designer", "ui", "ux", "creative"],
            "contabil": ["contabil", "accountant", "bookkeeper", "financial analyst"],
            "secretar": ["secretar", "secretară", "assistant", "administrator", "admin"],
            "tehnician": ["tehnician", "technician", "tech support", "support", "helpdesk"]
        }
        
        # Leave/vacation types
        self.leave_types = {
            "odihna": ["odihna", "odihnă", "vacation", "holiday", "concediu de odihna"],
            "medical": ["medical", "concediu medical", "sick leave", "boala", "bolnav"],
            "maternitate": ["maternitate", "maternal", "maternity", "nastere", "naștere"],
            "formare": ["formare", "training", "curs", "educatie", "educație", "learning"],
            "fara_plata": ["fara plata", "fără plată", "unpaid", "neplatit", "personal"]
        }
        
        # Certificate/document types
        self.certificate_types = {
            "venit": ["venit", "income", "salary", "salariu", "financial", "adeverinta venit"],
            "vechime": ["vechime", "seniority", "experience", "ani lucru", "employment"],
            "conducere": ["conducere", "management", "leadership", "pozitie", "poziție"],
            "medical": ["medical", "health", "sanatate", "sănătate", "fitness"]
        }
        
        # Inquiry keywords (from Java code)
        self.inquiry_keywords = {
            "request": ["da-mi", "da mi", "arata-mi", "arata mi", "afiseaza-mi", "afiseaza mi"],
            "want": ["vreau sa stiu", "vreau sa aflu", "as dori sa", "mi-ar placea sa"],
            "ask": ["spune-mi", "spune mi", "te rog sa", "poti sa"],
            "search": ["gaseste", "gaseste-mi", "cauta", "cauta-mi", "determina", "calculeaza"]
        }
        
        # Followup keywords
        self.followup_keywords = {
            "positive": ["da", "te rog", "vreau", "doresc", "sigur", "bineinteles", "desigur"],
            "continue": ["arata-mi", "mai multe", "mai mult", "detalii", "continua", "mai departe"],
            "negative": ["nu", "suficient", "gata", "stop", "opreste", "multumesc", "ajunge"]
        }
        
        # Complex query patterns based on Java regex patterns
        self.complex_patterns = {
            "employee_with_filters": [
                r"angajat(ii|ii)?\s+(din|cu|care|având)\s+(.+)",
                r"personal(ul)?\s+(din|cu|care|având)\s+(.+)",
                r"(lista|afiseaza|arata)\s+angajat(ii|ii)?\s+(.+)"
            ],
            "department_queries": [
                r"departament(ul|ele)?\s+(.+)",
                r"(lista|afiseaza|arata)\s+departament(ele|ului)?\s*(.+)?"
            ],
            "leave_complex": [
                r"concedi(i|u|uri)?\s+(din|care|pentru|cu)\s+(.+)",
                r"vacant(a|e|ele)?\s+(din|care|pentru|cu)\s+(.+)"
            ],
            "temporal_queries": [
                r"(anul|luna|ziua)\s+(acesta|aceasta|trecut|trecuta|viitor|viitoare)",
                r"(din|de la|pana la|intre)\s+(\d{1,2})[./\-](\d{1,2})[./\-](\d{2,4})",
                r"(2019|2020|2021|2022|2023|2024|2025|2026)"
            ]
        }
    
    def _precompute_embeddings(self):
        """Pre-compute embeddings for all knowledge base entries"""
        logger.info("🧮 Pre-computing enterprise embeddings...")
        
        self.category_embeddings = {}
        self.intent_embeddings = {}
        
        # Category examples for better classification
        category_examples = {
            QueryCategory.EMPLOYEE: [
                "angajații din IT cu experiență în Python",
                "lista programatorilor din echipa de dezvoltare",
                "cine sunt managerii din departamentul financiar",
                "contactele directorilor din toate departamentele"
            ],
            QueryCategory.DEPARTMENT: [
                "care sunt departamentele companiei",
                "informații despre departamentul HR",
                "structura organizatorică a firmei"
            ],
            QueryCategory.LEAVE: [
                "concediile aprobate din luna martie",
                "cine este în vacanță săptămâna aceasta",
                "solicitări de concediu pentru anul viitor"
            ],
            QueryCategory.CERTIFICATE: [
                "adeverință de venit pentru împrumut bancar",
                "certificat de vechime în muncă",
                "confirmare poziție pentru aplicare job"
            ],
            QueryCategory.PROJECT: [
                "proiectele active din departamentul IT",
                "statusul proiectelor pentru clientul X",
                "deadline-urile pentru proiectele Q4"
            ],
            QueryCategory.TASK: [
                "task-urile mele pentru săptămâna aceasta",
                "sarcinile neterminate din echipa de dezvoltare",
                "programarea unei întâlniri cu managerul"
            ]
        }
        
        # Compute embeddings for each category
        for category, examples in category_examples.items():
            embeddings = []
            for example in examples:
                embedding = self._get_sentence_embedding(example)
                embeddings.append(embedding)
            self.category_embeddings[category] = np.mean(embeddings, axis=0)
        
        # Intent type embeddings
        intent_examples = {
            "count": ["câți", "cate", "numărul", "total", "suma"],
            "list": ["lista", "afișează", "arată", "care sunt"],
            "filter": ["cu", "care au", "din", "având"],
            "aggregate": ["media", "maxim", "minim", "statistici"],
            "update": ["modifică", "actualizează", "schimbă"],
            "delete": ["șterge", "elimină", "anulează"]
        }
        
        for intent, examples in intent_examples.items():
            embeddings = []
            for example in examples:
                embedding = self._get_sentence_embedding(example)
                embeddings.append(embedding)
            self.intent_embeddings[intent] = np.mean(embeddings, axis=0)
        
        logger.info("✅ Enterprise embeddings computed!")
    
    def _get_sentence_embedding(self, text: str) -> np.ndarray:
        """Get sentence embedding using RoBERT"""
        try:
            inputs = self.robert_tokenizer(
                text, 
                return_tensors="pt", 
                max_length=512, 
                truncation=True,
                padding=True
            ).to(self.device)
            
            with torch.no_grad():
                outputs = self.robert_model(**inputs)
                embeddings = outputs.last_hidden_state.mean(dim=1)
                return embeddings.cpu().numpy().flatten()
        except Exception as e:
            logger.warning(f"Embedding error: {e}")
            return self._get_tfidf_embedding(text)
    
    def _get_tfidf_embedding(self, text: str) -> np.ndarray:
        """Fallback TF-IDF embedding"""
        if not hasattr(self, 'tfidf_vectorizer'):
            all_examples = []
            for dept_names in self.departments.values():
                all_examples.extend(dept_names)
            for pos_names in self.positions.values():
                all_examples.extend(pos_names)
            
            self.tfidf_vectorizer = TfidfVectorizer(max_features=300, ngram_range=(1, 3))
            self.tfidf_vectorizer.fit(all_examples)
        
        return self.tfidf_vectorizer.transform([text]).toarray().flatten()
    
    def process_enterprise_query(self, query: str, conversation_context: Optional[Dict] = None) -> QueryIntent:
        """Process complex enterprise query with full AI analysis"""
        logger.info(f"🧠 Processing enterprise query: {query}")
        
        # 1. Advanced preprocessing
        processed = self._advanced_preprocessing(query)
        
        # 2. Check if it's a followup query
        followup_type = self._detect_followup(query, conversation_context)
        
        # 3. Classify query category with AI
        category, category_confidence = self._classify_query_category(query)
        
        # 4. Determine intent type
        intent_type, intent_confidence = self._classify_intent_type(query)
        
        # 5. Extract entities with advanced NER
        entities = self._extract_enterprise_entities(query, processed)
        
        # 6. Extract temporal context
        temporal = self._extract_temporal_context(query, processed)
        
        # 7. Build filters based on category and entities
        filters = self._build_enterprise_filters(query, category, entities, temporal)
        
        # 8. Determine attributes to return
        attributes = self._determine_output_attributes(query, category, entities)
        
        # 9. Assess query complexity
        complexity = self._assess_query_complexity(query, entities, temporal, filters)
        
        # 10. Calculate overall confidence
        confidence = (category_confidence + intent_confidence) / 2
        
        # 11. Semantic similarity
        semantic_sim = self._calculate_semantic_similarity(query, category)
        
        # 12. Generate reasoning
        reasoning = self._generate_enterprise_reasoning(query, category, intent_type, entities, filters)
        
        intent = QueryIntent(
            category=category,
            intent_type=intent_type,
            entities=entities,
            temporal=temporal,
            filters=filters,
            attributes=attributes,
            confidence=confidence,
            complexity=complexity,
            semantic_similarity=semantic_sim,
            conversational_context=conversation_context,
            followup_type=followup_type,
            reasoning=reasoning
        )
        
        # Store for conversation context
        self.last_query_context = intent
        self.conversation_history.append({
            "query": query,
            "intent": intent,
            "timestamp": datetime.now()
        })
        
        logger.info(f"✅ Query processed - Category: {category}, Intent: {intent_type}, Confidence: {confidence:.3f}")
        
        return intent
    
    def _advanced_preprocessing(self, text: str) -> Dict:
        """Advanced preprocessing with spaCy and custom logic"""
        if not self.nlp_ro:
            return {"tokens": text.split(), "entities": [], "pos_tags": []}
        
        doc = self.nlp_ro(text)
        
        return {
            "tokens": [token.text for token in doc],
            "lemmas": [token.lemma_ for token in doc],
            "pos_tags": [token.pos_ for token in doc],
            "entities": [(ent.text, ent.label_) for ent in doc.ents],
            "dependencies": [(token.text, token.dep_, token.head.text) for token in doc],
            "noun_phrases": [chunk.text for chunk in doc.noun_chunks],
            "sentences": [sent.text for sent in doc.sents]
        }
    
    def _detect_followup(self, query: str, context: Optional[Dict]) -> Optional[str]:
        """Detect if this is a followup query"""
        query_lower = query.lower()
        
        # Check for explicit followup keywords
        for followup_type, keywords in self.followup_keywords.items():
            if any(keyword in query_lower for keyword in keywords):
                return followup_type
        
        # Check if query is very short and context exists
        if len(query.split()) <= 3 and context and self.last_query_context:
            return "implicit_followup"
        
        return None
    
    def _classify_query_category(self, query: str) -> Tuple[QueryCategory, float]:
        """Classify query category using AI embeddings"""
        query_embedding = self._get_sentence_embedding(query)
        
        similarities = {}
        for category, category_embedding in self.category_embeddings.items():
            similarity = cosine_similarity([query_embedding], [category_embedding])[0][0]
            similarities[category] = similarity
        
        # Apply keyword bonuses for better accuracy
        query_lower = query.lower()
        
        # Employee query indicators
        if any(word in query_lower for word in ["angajat", "angajati", "personal", "utilizator", "om", "persoana"]):
            similarities[QueryCategory.EMPLOYEE] += 0.3
        
        # Department query indicators  
        if any(word in query_lower for word in ["departament", "secție", "echipa", "divizie"]):
            similarities[QueryCategory.DEPARTMENT] += 0.3
        
        # Leave query indicators
        if any(word in query_lower for word in ["concediu", "concedii", "vacanta", "odihna", "absenta"]):
            similarities[QueryCategory.LEAVE] += 0.3
        
        # Certificate query indicators
        if any(word in query_lower for word in ["adeverinta", "certificat", "confirmare", "document"]):
            similarities[QueryCategory.CERTIFICATE] += 0.3
        
        # Project query indicators
        if any(word in query_lower for word in ["proiect", "proiecte", "project"]):
            similarities[QueryCategory.PROJECT] += 0.3
        
        # Task query indicators
        if any(word in query_lower for word in ["task", "sarcina", "sarcini", "programare", "intalnire"]):
            similarities[QueryCategory.TASK] += 0.3
        
        best_category = max(similarities, key=similarities.get)
        confidence = similarities[best_category]
        
        return best_category, confidence
    
    def _classify_intent_type(self, query: str) -> Tuple[str, float]:
        """Classify intent type (count, list, filter, etc.)"""
        query_embedding = self._get_sentence_embedding(query)
        
        similarities = {}
        for intent, intent_embedding in self.intent_embeddings.items():
            similarity = cosine_similarity([query_embedding], [intent_embedding])[0][0]
            similarities[intent] = similarity
        
        # Keyword-based bonuses
        query_lower = query.lower()
        
        if any(word in query_lower for word in ["câți", "cate", "numărul", "numarul", "total", "count"]):
            similarities["count"] += 0.4
        elif any(word in query_lower for word in ["lista", "afișează", "arata", "care sunt", "show", "list"]):
            similarities["list"] += 0.4
        elif any(word in query_lower for word in ["media", "suma", "maxim", "minim", "statistici"]):
            similarities["aggregate"] += 0.4
        elif any(word in query_lower for word in ["cu", "care au", "din", "având", "filter"]):
            similarities["filter"] += 0.2
        
        best_intent = max(similarities, key=similarities.get)
        confidence = similarities[best_intent]
        
        return best_intent, confidence
    
    def _extract_enterprise_entities(self, query: str, processed: Dict) -> EntityContext:
        """Extract all relevant entities using advanced NER and patterns"""
        entities = EntityContext()
        
        # Extract from spaCy NER
        for entity_text, entity_label in processed.get("entities", []):
            if entity_label == "PERSON":
                entities.persons.append(entity_text)
            elif entity_label == "ORG":
                # Could be department
                entities.departments.append(entity_text)
            elif entity_label == "LOC":
                entities.locations.append(entity_text)
        
        # Extract departments using knowledge base
        query_lower = query.lower()
        for dept_key, dept_variations in self.departments.items():
            for variation in dept_variations:
                if variation in query_lower:
                    entities.departments.append(dept_key)
                    break
        
        # Extract positions
        for pos_key, pos_variations in self.positions.items():
            for variation in pos_variations:
                if variation in query_lower:
                    entities.positions.append(pos_key)
                    break
        
        # Extract numbers
        number_pattern = r'\b\d+\b'
        numbers = re.findall(number_pattern, query)
        entities.numbers = [int(num) for num in numbers]
        
        # Extract emails
        email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
        entities.emails = re.findall(email_pattern, query)
        
        # Extract phone numbers
        phone_pattern = r'\b0\d{9}\b'
        entities.phone_numbers = re.findall(phone_pattern, query)
        
        return entities
    
    def _extract_temporal_context(self, query: str, processed: Dict) -> TemporalContext:
        """Extract comprehensive temporal information"""
        temporal = TemporalContext()
        
        # Extract years
        year_pattern = r'\b(19|20)\d{2}\b'
        years = re.findall(year_pattern, query)
        if years:
            temporal.year = int(years[0])
        
        # Extract dates
        date_pattern = r'\b\d{1,2}[./\-]\d{1,2}[./\-]\d{2,4}\b'
        dates = re.findall(date_pattern, query)
        if dates:
            temporal.start_date = dates[0]
            if len(dates) > 1:
                temporal.end_date = dates[1]
        
        # Extract relative time expressions
        relative_patterns = {
            "anul acesta": "current_year",
            "luna aceasta": "current_month", 
            "săptămâna aceasta": "current_week",
            "anul trecut": "last_year",
            "luna trecută": "last_month",
            "săptămâna trecută": "last_week"
        }
        
        query_lower = query.lower()
        for pattern, meaning in relative_patterns.items():
            if pattern in query_lower:
                temporal.relative_time = meaning
                break
        
        # Extract month names
        months_ro = {
            "ianuarie": 1, "februarie": 2, "martie": 3, "aprilie": 4,
            "mai": 5, "iunie": 6, "iulie": 7, "august": 8,
            "septembrie": 9, "octombrie": 10, "noiembrie": 11, "decembrie": 12
        }
        
        for month_name, month_num in months_ro.items():
            if month_name in query_lower:
                temporal.month = month_name
                break
        
        return temporal
    
    def _build_enterprise_filters(self, query: str, category: QueryCategory, 
                                 entities: EntityContext, temporal: TemporalContext) -> Dict[str, Any]:
        """Build comprehensive filters based on extracted information"""
        filters = {}
        
        # Department filters
        if entities.departments:
            filters["departament"] = entities.departments[0]  # Take first match
        
        # Position filters
        if entities.positions:
            filters["pozitie"] = entities.positions[0]
        
        # Temporal filters
        if temporal.year:
            filters["an"] = temporal.year
        elif temporal.relative_time:
            filters["perioada"] = temporal.relative_time
        
        if temporal.month:
            filters["luna"] = temporal.month
        
        if temporal.start_date:
            filters["data_start"] = temporal.start_date
        if temporal.end_date:
            filters["data_end"] = temporal.end_date
        
        # Category-specific filters
        if category == QueryCategory.LEAVE:
            query_lower = query.lower()
            
            # Leave status
            if any(word in query_lower for word in ["aprobat", "aprobate", "approved"]):
                filters["status"] = "aprobat"
            elif any(word in query_lower for word in ["respins", "respinse", "rejected"]):
                filters["status"] = "respins"
            elif any(word in query_lower for word in ["pending", "asteptare", "neaprobat"]):
                filters["status"] = "pending"
            
            # Leave type
            for leave_type, keywords in self.leave_types.items():
                if any(keyword in query_lower for keyword in keywords):
                    filters["tip_concediu"] = leave_type
                    break
        
        elif category == QueryCategory.CERTIFICATE:
            query_lower = query.lower()
            
            # Certificate type
            for cert_type, keywords in self.certificate_types.items():
                if any(keyword in query_lower for keyword in keywords):
                    filters["tip_certificat"] = cert_type
                    break
        
        # Numeric filters
        if entities.numbers:
            if any(word in query.lower() for word in ["peste", "mai mult", ">"]):
                filters["minim"] = entities.numbers[0]
            elif any(word in query.lower() for word in ["sub", "mai putin", "<"]):
                filters["maxim"] = entities.numbers[0]
        
        return filters
    
    def _determine_output_attributes(self, query: str, category: QueryCategory, 
                                   entities: EntityContext) -> List[str]:
        """Determine what attributes to return based on query and category"""
        attributes = []
        query_lower = query.lower()
        
        # Always include basic identifiers
        if category == QueryCategory.EMPLOYEE:
            attributes.extend(["nume", "prenume"])
            
            # Additional attributes based on query content
            if any(word in query_lower for word in ["email", "mail", "contact"]):
                attributes.append("email")
            if any(word in query_lower for word in ["telefon", "phone", "contact"]):
                attributes.append("telefon")
            if any(word in query_lower for word in ["departament", "secție", "echipa"]):
                attributes.append("departament")
            if any(word in query_lower for word in ["funcție", "pozitie", "rol", "job"]):
                attributes.append("functie")
            if any(word in query_lower for word in ["detalii", "informații", "complet"]):
                attributes.extend(["departament", "functie", "email", "telefon"])
        
        elif category == QueryCategory.LEAVE:
            attributes.extend(["nume", "prenume"])
            
            if any(word in query_lower for word in ["data", "perioada", "când", "cand"]):
                attributes.extend(["start_c", "end_c"])
            if any(word in query_lower for word in ["motiv", "reason"]):
                attributes.append("motiv")
            if any(word in query_lower for word in ["status", "aprobare"]):
                attributes.append("status")
            if any(word in query_lower for word in ["zile", "durată", "durata"]):
                attributes.append("durata")
        
        elif category == QueryCategory.DEPARTMENT:
            attributes.extend(["nume_dep"])
            if any(word in query_lower for word in ["angajați", "personal", "oameni"]):
                attributes.append("numar_angajati")
        
        # Default attributes if none specified
        if not attributes:
            if category == QueryCategory.EMPLOYEE:
                attributes = ["nume", "prenume", "departament", "functie"]
            elif category == QueryCategory.LEAVE:
                attributes = ["nume", "prenume", "start_c", "end_c", "status"]
            elif category == QueryCategory.DEPARTMENT:
                attributes = ["nume_dep", "numar_angajati"]
            else:
                attributes = ["*"]
        
        return attributes
    
    def _assess_query_complexity(self, query: str, entities: EntityContext, 
                                temporal: TemporalContext, filters: Dict) -> QueryComplexity:
        """Assess the complexity of the query"""
        complexity_score = 0
        
        # Base complexity from query length
        word_count = len(query.split())
        if word_count > 15:
            complexity_score += 2
        elif word_count > 8:
            complexity_score += 1
        
        # Entity complexity
        total_entities = (len(entities.persons) + len(entities.departments) + 
                         len(entities.positions) + len(entities.locations))
        complexity_score += min(total_entities, 3)
        
        # Temporal complexity
        if temporal.start_date and temporal.end_date:
            complexity_score += 2
        elif temporal.year or temporal.month or temporal.relative_time:
            complexity_score += 1
        
        # Filter complexity
        complexity_score += min(len(filters), 3)
        
        # Assign complexity level
        if complexity_score >= 8:
            return QueryComplexity.EXPERT
        elif complexity_score >= 5:
            return QueryComplexity.COMPLEX
        elif complexity_score >= 3:
            return QueryComplexity.INTERMEDIATE
        else:
            return QueryComplexity.SIMPLE
    
    def _calculate_semantic_similarity(self, query: str, category: QueryCategory) -> float:
        """Calculate semantic similarity with category examples"""
        if category not in self.category_embeddings:
            return 0.0
        
        query_embedding = self._get_sentence_embedding(query)
        category_embedding = self.category_embeddings[category]
        
        similarity = cosine_similarity([query_embedding], [category_embedding])[0][0]
        return similarity
    
    def _generate_enterprise_reasoning(self, query: str, category: QueryCategory, 
                                     intent_type: str, entities: EntityContext, 
                                     filters: Dict) -> str:
        """Generate detailed reasoning for the interpretation"""
        reasoning_parts = []
        
        reasoning_parts.append(f"Query '{query}' classified as {category.value} with {intent_type} intent.")
        
        if entities.departments:
            reasoning_parts.append(f"Department context: {', '.join(entities.departments)}")
        
        if entities.positions:
            reasoning_parts.append(f"Position context: {', '.join(entities.positions)}")
        
        if filters:
            filter_desc = ", ".join([f"{k}={v}" for k, v in filters.items()])
            reasoning_parts.append(f"Applied filters: {filter_desc}")
        
        reasoning_parts.append("Analysis uses Romanian BERT + spaCy + enterprise knowledge base.")
        
        return " ".join(reasoning_parts)


class EnterpriseQueryProcessor:
    """Main processor that converts AI intents to executable queries"""
    
    def __init__(self):
        self.nlp_processor = EnterpriseNLPProcessor()
    
    def process_query(self, query: str, conversation_context: Optional[Dict] = None) -> Dict[str, Any]:
        """Process a query and return complete analysis + SQL"""
        
        # Get AI analysis
        intent = self.nlp_processor.process_enterprise_query(query, conversation_context)
        
        # Generate SQL based on intent
        sql_query = self._generate_enterprise_sql(intent)
        
        return {
            "original_query": query,
            "intent": {
                "intent_type": intent.intent_type,
                "semantic_similarity": intent.semantic_similarity,
                "filters": intent.filters,
                "attributes": intent.attributes,
                "followup_type": intent.followup_type,
                "conversational_context": intent.conversational_context
            },
            "sql_query": sql_query,
            "complexity": intent.complexity.value,
            "confidence": intent.confidence,
            "category": intent.category.value,
            "entities_found": {
                "departments": intent.entities.departments,
                "positions": intent.entities.positions,
                "persons": intent.entities.persons,
                "locations": intent.entities.locations,
                "numbers": intent.entities.numbers,
                "emails": intent.entities.emails,
                "phone_numbers": intent.entities.phone_numbers,
                "temporal": {
                    "start_date": intent.temporal.start_date,
                    "end_date": intent.temporal.end_date,
                    "year": intent.temporal.year,
                    "month": intent.temporal.month,
                    "relative_time": intent.temporal.relative_time,
                    "time_range": intent.temporal.time_range
                }
            },
            "reasoning": intent.reasoning,
            "timestamp": datetime.now().isoformat(),
            "followup_detected": intent.followup_type is not None
        }
    
    def _generate_enterprise_sql(self, intent: QueryIntent) -> str:
        """Generate SQL query based on AI intent analysis"""
        
        if intent.category == QueryCategory.EMPLOYEE:
            return self._generate_employee_sql(intent)
        elif intent.category == QueryCategory.DEPARTMENT:
            return self._generate_department_sql(intent)
        elif intent.category == QueryCategory.LEAVE:
            return self._generate_leave_sql(intent)
        elif intent.category == QueryCategory.CERTIFICATE:
            return self._generate_certificate_sql(intent)
        elif intent.category == QueryCategory.PROJECT:
            return self._generate_project_sql(intent)
        elif intent.category == QueryCategory.TASK:
            return self._generate_task_sql(intent)
        else:
            return "SELECT 'Query category not yet implemented' as message"
    
    def _generate_employee_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for employee queries"""
        
        # Build SELECT clause
        if intent.intent_type == "count":
            select_clause = "SELECT COUNT(*) as total"
        else:
            columns = []
            for attr in intent.attributes:
                if attr == "nume":
                    columns.append("u.nume")
                elif attr == "prenume":
                    columns.append("u.prenume")
                elif attr == "email":
                    columns.append("u.email")
                elif attr == "telefon":
                    columns.append("u.telefon")
                elif attr == "departament":
                    columns.append("d.nume_dep as departament")
                elif attr == "functie":
                    columns.append("t.denumire as functie")
            
            if not columns:
                columns = ["u.nume", "u.prenume", "d.nume_dep as departament", "t.denumire as functie"]
            
            select_clause = "SELECT " + ", ".join(columns)
        
        # FROM clause with JOINs
        from_clause = """
        FROM useri u 
        LEFT JOIN departament d ON u.id_dep = d.id_dep
        LEFT JOIN tipuri t ON u.tip = t.tip
        """
        
        # WHERE conditions
        conditions = ["u.username != 'test'"]  # Exclude test users
        
        # Apply filters
        if "departament" in intent.filters:
            dept = intent.filters["departament"]
            # Map to actual department names in DB
            dept_mapping = {
                "it": "IT", "hr": "HR", "finante": "Finante",
                "marketing": "Marketing", "juridic": "Juridic"
            }
            actual_dept = dept_mapping.get(dept, dept)
            conditions.append(f"d.nume_dep = '{actual_dept}'")
        
        if "pozitie" in intent.filters:
            pos = intent.filters["pozitie"]
            # Map to tip IDs - this would need actual mapping from your DB
            pos_mapping = {
                "director": 23, "manager": 25, "specialist": 26,
                "programator": 36, "analist": 31
            }
            if pos in pos_mapping:
                conditions.append(f"u.tip = {pos_mapping[pos]}")
        
        # Temporal filters
        if "an" in intent.filters:
            conditions.append(f"YEAR(u.data_ang) = {intent.filters['an']}")
        
        where_clause = "WHERE " + " AND ".join(conditions)
        
        # Combine all parts
        full_query = f"{select_clause} {from_clause} {where_clause}"
        
        return full_query
    
    def _generate_department_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for department queries"""
        
        if intent.intent_type == "count":
            return "SELECT COUNT(*) as total FROM departament"
        
        return """
        SELECT d.nume_dep as departament, COUNT(u.id) as numar_angajati
        FROM departament d
        LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.username != 'test'
        GROUP BY d.id_dep, d.nume_dep
        ORDER BY numar_angajati DESC
        """
    
    def _generate_leave_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for leave/vacation queries"""
        
        # Build SELECT
        if intent.intent_type == "count":
            select_clause = "SELECT COUNT(*) as total"
        else:
            columns = ["u.nume", "u.prenume"]
            for attr in intent.attributes:
                if attr == "start_c":
                    columns.append("c.start_c")
                elif attr == "end_c":
                    columns.append("c.end_c")
                elif attr == "motiv":
                    columns.append("c.motiv")
                elif attr == "status":
                    columns.append("s.nume_status as status")
                elif attr == "durata":
                    columns.append("c.durata")
            
            select_clause = "SELECT " + ", ".join(columns)
        
        from_clause = """
        FROM concedii c
        JOIN useri u ON c.id_ang = u.id
        JOIN departament d ON u.id_dep = d.id_dep
        JOIN statusuri s ON c.status = s.status
        JOIN tipcon ct ON c.tip = ct.tip
        """
        
        conditions = ["u.username != 'test'"]
        
        # Status filters
        if "status" in intent.filters:
            status = intent.filters["status"]
            if status == "aprobat":
                conditions.append("c.status = 2")
            elif status == "respins":
                conditions.append("c.status < 0")
            elif status == "pending":
                conditions.append("c.status = 0")
        
        # Temporal filters
        if "an" in intent.filters:
            conditions.append(f"YEAR(c.start_c) = {intent.filters['an']}")
        elif "perioada" in intent.filters:
            if intent.filters["perioada"] == "current_year":
                conditions.append("YEAR(c.start_c) = YEAR(CURDATE())")
            elif intent.filters["perioada"] == "current_month":
                conditions.append("YEAR(c.start_c) = YEAR(CURDATE()) AND MONTH(c.start_c) = MONTH(CURDATE())")
        
        if "departament" in intent.filters:
            dept = intent.filters["departament"]
            conditions.append(f"d.nume_dep = '{dept}'")
        
        where_clause = "WHERE " + " AND ".join(conditions)
        
        return f"{select_clause} {from_clause} {where_clause}"
    
    def _generate_certificate_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for certificate queries"""
        # This would typically return guidance or document templates
        cert_type = intent.filters.get("tip_certificat", "general")
        
        return f"""
        SELECT 
            'Pentru solicitarea unei adeverințe de tip {cert_type}, 
             contactați departamentul HR la extensia 101 sau 
             completați formularul online din sistemul intern.' as instructiuni,
            'hr@company.com' as contact_email,
            '101' as extensie_telefon
        """
    
    def _generate_project_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for project queries"""
        
        if intent.intent_type == "count":
            return "SELECT COUNT(*) as total FROM proiecte WHERE activ = 1"
        
        base_query = """
        SELECT p.nume as nume_proiect, p.descriere, p.deadline,
               COUNT(t.id) as numar_taskuri,
               AVG(s.procent) as progres_mediu
        FROM proiecte p
        LEFT JOIN tasks t ON p.id = t.id_prj
        LEFT JOIN statusuri2 s ON t.status = s.id
        WHERE p.activ = 1
        """
        
        conditions = []
        
        if "departament" in intent.filters:
            conditions.append(f"p.departament = '{intent.filters['departament']}'")
        
        if conditions:
            base_query += " AND " + " AND ".join(conditions)
        
        base_query += " GROUP BY p.id, p.nume, p.descriere, p.deadline ORDER BY p.deadline"
        
        return base_query
    
    def _generate_task_sql(self, intent: QueryIntent) -> str:
        """Generate SQL for task queries"""
        
        if intent.intent_type == "count":
            return "SELECT COUNT(*) as total FROM tasks WHERE activ = 1"
        
        return """
        SELECT t.nume as nume_task, p.nume as nume_proiect,
               u.nume, u.prenume, s.procent as progres,
               t.start as data_start, t.end as data_end
        FROM tasks t
        JOIN proiecte p ON t.id_prj = p.id
        JOIN useri u ON t.id_ang = u.id
        JOIN statusuri2 s ON t.status = s.id
        WHERE t.activ = 1
        ORDER BY t.end ASC
        """
#!/usr/bin/env python3
"""
Enhanced NLP Processor for Enterprise HR AI Assistant
Inspirat din EnhancedNLPProcessor.java, NaturalLanguageToSQLTranslator.java, CompanyPolicyProcessor.java

Funcționalități avansate:
- Pattern matching avansat pentru limba română
- Entity normalization și confidence scoring
- Temporal expression processing pentru "astăzi", "luna aceasta", etc.
- Department și position mapping inteligent
- Top-N query generation pentru salarii și rankinguri
- Query complexity assessment și semantic similarity
"""

import re
import json
import logging
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional, Any, Tuple, Union
from dataclasses import dataclass, field
from enum import Enum
import unicodedata

# Set up logging
logger = logging.getLogger(__name__)

class QueryCategory(Enum):
    """Query categories inspired by Java implementation"""
    EMPLOYEE = "EMPLOYEE"
    LEAVE = "LEAVE"
    PROJECT = "PROJECT"
    DEPARTMENT = "DEPARTMENT"
    SALARY = "SALARY"
    GENERAL = "GENERAL"
    POLICY = "POLICY"

class IntentType(Enum):
    """Intent types for different query purposes"""
    LIST = "LIST"
    COUNT = "COUNT"
    SEARCH = "SEARCH"
    AGGREGATE = "AGGREGATE"
    TOP_N = "TOP_N"
    TEMPORAL = "TEMPORAL"
    POLICY_CHECK = "POLICY_CHECK"

class QueryComplexity(Enum):
    """Query complexity levels"""
    SIMPLE = "SIMPLE"
    MODERATE = "MODERATE"
    COMPLEX = "COMPLEX"
    VERY_COMPLEX = "VERY_COMPLEX"

@dataclass
class EntityData:
    """Enhanced entity data structure"""
    keywords: List[str] = field(default_factory=list)
    departments: List[str] = field(default_factory=list)
    positions: List[str] = field(default_factory=list)
    persons: List[str] = field(default_factory=list)
    locations: List[str] = field(default_factory=list)
    numbers: List[int] = field(default_factory=list)
    emails: List[str] = field(default_factory=list)
    phone_numbers: List[str] = field(default_factory=list)
    temporal_keywords: List[str] = field(default_factory=list)

@dataclass
class TemporalData:
    """Temporal information extracted from query"""
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    relative_time: Optional[str] = None
    temporal_keywords: List[str] = field(default_factory=list)
    sql_condition: Optional[str] = None

@dataclass
class QueryIntent:
    """Complete query intent analysis"""
    category: QueryCategory
    intent_type: IntentType
    entities: EntityData
    temporal: TemporalData
    filters: Dict[str, Any] = field(default_factory=dict)
    attributes: List[str] = field(default_factory=list)
    confidence: float = 0.0
    complexity: QueryComplexity = QueryComplexity.SIMPLE
    semantic_similarity: float = 0.0
    conversational_context: Optional[Dict] = None
    followup_type: Optional[str] = None
    reasoning: str = ""

class EnhancedEntityExtractor:
    """
    Advanced entity extraction inspired by EnhancedNLPProcessor.java
    """
    
    def __init__(self):
        # Department mappings enhanced cu variante românești
        self.department_mappings = {
            'hr': ['hr', 'resurse umane', 'human resources', 'personal', 'rh'],
            'it': ['it', 'informatica', 'tehnologie', 'programare', 'software', 'tech'],
            'finante': ['finante', 'financiar', 'contabilitate', 'accounting', 'finance'],
            'juridic': ['juridic', 'legal', 'drept', 'lege'],
            'marketing': ['marketing', 'publicitate', 'promovare', 'reclama'],
            'management': ['management', 'conducere', 'directori', 'manageri']
        }
        
        # Position mappings enhanced
        self.position_mappings = {
            'director': ['director', 'ceo', 'manager general', 'chief', 'director general'],
            'manager': ['manager', 'sef', 'șef', 'supervisor', 'team lead', 'lead', 'coordonator'],
            'specialist': ['specialist', 'expert', 'consultant', 'analist', 'analyst'],
            'programator': ['programator', 'developer', 'programmer', 'software engineer', 'dev'],
            'designer': ['designer', 'graphic designer', 'ui', 'ux', 'creative'],
            'contabil': ['contabil', 'accountant', 'bookkeeper', 'financial analyst'],
            'secretar': ['secretar', 'secretară', 'assistant', 'administrator', 'admin'],
            'tehnician': ['tehnician', 'technician', 'tech support', 'support', 'helpdesk'],
            'inginer': ['inginer', 'engineer', 'ing'],
            'sef': ['sef', 'șef', 'chief', 'head', 'lead'],
            'intern': ['intern', 'stagiar', 'stagiara'],
            'new_graduate': ['new graduate', 'absolvent', 'nou absolvent']
        }
        
        # Temporal expressions pentru română
        self.temporal_patterns = {
            'today': ['astazi', 'astăzi', 'azi', 'today'],
            'yesterday': ['ieri', 'yesterday'],
            'tomorrow': ['maine', 'mâine', 'tomorrow'],
            'this_week': ['saptamana aceasta', 'săptămâna aceasta', 'this week'],
            'this_month': ['luna aceasta', 'luna asta', 'this month'],
            'this_year': ['anul acesta', 'anul asta', 'this year'],
            'last_month': ['luna trecuta', 'luna trecută', 'last month'],
            'last_year': ['anul trecut', 'last year'],
            'now': ['acum', 'now', 'in prezent'],
            'current': ['curent', 'actual', 'current', 'prezent']
        }
        
        # Salary and ranking keywords
        self.salary_keywords = [
            'salariu', 'salarii', 'salary', 'venit', 'venituri', 'income',
            'remuneratie', 'remunerație', 'plata', 'plată', 'bani',
            'mari', 'mici', 'top', 'cel mai mare', 'cel mai mic',
            'maxim', 'minim', 'highest', 'lowest', 'biggest', 'smallest'
        ]
        
        # Compiled regex patterns
        self.email_pattern = re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        self.phone_pattern = re.compile(r'\b0\d{9}\b')
        self.number_pattern = re.compile(r'\b\d+\b')
    
    def extract_entities(self, query: str) -> EntityData:
        """Extract all entities from query with enhanced pattern matching"""
        query_lower = query.lower().strip()
        
        entities = EntityData()
        entities.keywords = self._extract_keywords(query_lower)
        entities.departments = self._extract_departments(query_lower)
        entities.positions = self._extract_positions(query_lower)
        entities.persons = self._extract_persons(query)
        entities.locations = self._extract_locations(query_lower)
        entities.numbers = self._extract_numbers(query)
        entities.emails = self._extract_emails(query)
        entities.phone_numbers = self._extract_phone_numbers(query)
        entities.temporal_keywords = self._extract_temporal_keywords(query_lower)
        
        return entities
    
    def _extract_keywords(self, query: str) -> List[str]:
        """Extract main keywords from query"""
        words = query.split()
        # Remove common stop words
        stop_words = {'si', 'și', 'cu', 'de', 'la', 'in', 'în', 'pe', 'pentru', 'care', 'ce', 'cine', 'unde', 'cand', 'când'}
        keywords = [word for word in words if word not in stop_words and len(word) > 2]
        return keywords
    
    def _extract_departments(self, query: str) -> List[str]:
        """Extract department mentions with fuzzy matching"""
        departments = []
        
        for dept_key, dept_variants in self.department_mappings.items():
            for variant in dept_variants:
                if variant in query:
                    departments.append(dept_key.upper())
                    break
        
        # Direct department name matching
        if 'departament' in query:
            # Look for specific department names
            dept_names = ['hr', 'it', 'finante', 'juridic', 'marketing', 'management']
            for dept in dept_names:
                if dept in query:
                    departments.append(dept.upper())
        
        return list(set(departments))  # Remove duplicates
    
    def _extract_positions(self, query: str) -> List[str]:
        """Extract position/function mentions"""
        positions = []
        
        for pos_key, pos_variants in self.position_mappings.items():
            for variant in pos_variants:
                if variant in query:
                    positions.append(pos_key)
                    break
        
        return list(set(positions))
    
    def _extract_persons(self, query: str) -> List[str]:
        """Extract person names (simple capitalized word detection)"""
        # Look for capitalized words that might be names
        words = query.split()
        persons = []
        
        for word in words:
            # Simple heuristic: capitalized word that's not a common word
            if (word[0].isupper() and len(word) > 2 and 
                word.lower() not in ['care', 'cine', 'unde', 'departament', 'angajat']):
                persons.append(word)
        
        return persons
    
    def _extract_locations(self, query: str) -> List[str]:
        """Extract location mentions"""
        location_keywords = ['bucuresti', 'bucurești', 'cluj', 'timisoara', 'timișoara', 'iasi', 'iași', 'constanta', 'constanța']
        locations = []
        
        for location in location_keywords:
            if location in query:
                locations.append(location.title())
        
        return locations
    
    def _extract_numbers(self, query: str) -> List[int]:
        """Extract numbers from query"""
        numbers = []
        matches = self.number_pattern.findall(query)
        
        for match in matches:
            try:
                numbers.append(int(match))
            except ValueError:
                continue
        
        return numbers
    
    def _extract_emails(self, query: str) -> List[str]:
        """Extract email addresses"""
        return self.email_pattern.findall(query)
    
    def _extract_phone_numbers(self, query: str) -> List[str]:
        """Extract phone numbers"""
        return self.phone_pattern.findall(query)
    
    def _extract_temporal_keywords(self, query: str) -> List[str]:
        """Extract temporal expressions"""
        temporal_keywords = []
        
        for temp_key, temp_variants in self.temporal_patterns.items():
            for variant in temp_variants:
                if variant in query:
                    temporal_keywords.append(temp_key)
                    break
        
        return temporal_keywords

class EnhancedTemporalProcessor:
    """Advanced temporal processing for date/time expressions"""
    
    @staticmethod
    def process_temporal_expressions(entities: EntityData) -> TemporalData:
        """Process temporal keywords into SQL conditions"""
        temporal = TemporalData()
        temporal.temporal_keywords = entities.temporal_keywords
        
        today = date.today()
        
        for keyword in entities.temporal_keywords:
            if keyword == 'today':
                temporal.start_date = today.isoformat()
                temporal.end_date = today.isoformat()
                temporal.sql_condition = f"DATE(start_c) <= '{today}' AND DATE(end_c) >= '{today}'"
                temporal.relative_time = 'today'
            
            elif keyword == 'this_month':
                start_of_month = today.replace(day=1)
                if today.month == 12:
                    end_of_month = today.replace(year=today.year + 1, month=1, day=1) - timedelta(days=1)
                else:
                    end_of_month = today.replace(month=today.month + 1, day=1) - timedelta(days=1)
                
                temporal.start_date = start_of_month.isoformat()
                temporal.end_date = end_of_month.isoformat()
                temporal.sql_condition = f"MONTH(start_c) = {today.month} AND YEAR(start_c) = {today.year}"
                temporal.relative_time = 'this_month'
            
            elif keyword == 'this_year':
                temporal.start_date = f"{today.year}-01-01"
                temporal.end_date = f"{today.year}-12-31"
                temporal.sql_condition = f"YEAR(start_c) = {today.year}"
                temporal.relative_time = 'this_year'
        
        return temporal

class EnhancedSQLGenerator:
    """Advanced SQL generation with intelligent query building"""
    
    def __init__(self):
        # Table and column mappings
        self.table_mappings = {
            'employees': {
                'table': 'useri u LEFT JOIN departament d ON u.id_dep = d.id_dep LEFT JOIN tipuri t ON u.tip = t.tip',
                'columns': {
                    'nume': 'u.nume',
                    'prenume': 'u.prenume',
                    'departament': 'd.nume_dep',
                    'functie': 't.denumire',
                    'salariu': 't.salariu',
                    'telefon': 'u.telefon',
                    'email': 'u.email',
                    'data_angajare': 'u.data_ang'
                }
            },
            'leave': {
                'table': 'concedii c LEFT JOIN useri u ON c.id_ang = u.id LEFT JOIN tipcon tc ON c.tip = tc.tip',
                'columns': {
                    'angajat': "CONCAT(u.nume, ' ', u.prenume)",
                    'tip_concediu': 'tc.motiv',
                    'data_start': 'c.start_c',
                    'data_end': 'c.end_c',
                    'status': 'c.status',
                    'locatie': 'c.locatie',
                    'durata': 'c.durata'
                }
            },
            'departments': {
                'table': 'departament d LEFT JOIN useri u ON d.id_dep = u.id_dep',
                'columns': {
                    'nume_departament': 'd.nume_dep',
                    'numar_angajati': 'COUNT(u.id)'
                }
            }
        }
    
    def generate_employee_query(self, entities: EntityData, temporal: TemporalData, intent_type: IntentType) -> str:
        """Generate employee-related SQL queries"""
        table_info = self.table_mappings['employees']
        
        if intent_type == IntentType.COUNT:
            sql = f"SELECT COUNT(u.id) as total_angajati FROM {table_info['table']}"
        elif intent_type == IntentType.TOP_N and any(word in entities.keywords for word in ['mari', 'top', 'maxim']):
            # Top salarii query
            sql = f"""
            SELECT {table_info['columns']['nume']} as nume,
                   {table_info['columns']['prenume']} as prenume,
                   {table_info['columns']['departament']} as departament,
                   {table_info['columns']['functie']} as functie,
                   {table_info['columns']['salariu']} as salariu
            FROM {table_info['table']}
            """
        else:
            # Regular list query
            sql = f"""
            SELECT {table_info['columns']['nume']} as nume,
                   {table_info['columns']['prenume']} as prenume,
                   {table_info['columns']['departament']} as departament,
                   {table_info['columns']['functie']} as functie
            FROM {table_info['table']}
            """
        
        # Add WHERE conditions
        where_conditions = ["u.username != 'test'"]
        
        # Department filter
        if entities.departments:
            dept_conditions = []
            for dept in entities.departments:
                if dept == 'IT':
                    dept_conditions.append("UPPER(d.nume_dep) = 'IT'")
                elif dept == 'HR':
                    dept_conditions.append("UPPER(d.nume_dep) = 'HR'")
                elif dept == 'FINANTE':
                    dept_conditions.append("UPPER(d.nume_dep) = 'FINANTE'")
                else:
                    dept_conditions.append(f"UPPER(d.nume_dep) = '{dept}'")
            
            if dept_conditions:
                where_conditions.append(f"({' OR '.join(dept_conditions)})")
        
        # Position filter
        if entities.positions:
            position_conditions = []
            for pos in entities.positions:
                position_conditions.append(f"LOWER(t.denumire) LIKE '%{pos.lower()}%'")
            
            if position_conditions:
                where_conditions.append(f"({' OR '.join(position_conditions)})")
        
        # Add WHERE clause
        if where_conditions:
            sql += f" WHERE {' AND '.join(where_conditions)}"
        
        # Add ORDER BY for salary queries
        if intent_type == IntentType.TOP_N or 'salariu' in entities.keywords:
            sql += " ORDER BY t.salariu DESC"
            
            # Limit for top queries
            if any(word in entities.keywords for word in ['mari', 'top']):
                sql += " LIMIT 3"
        else:
            sql += f" ORDER BY {table_info['columns']['departament']}, {table_info['columns']['nume']}"
        
        sql += " LIMIT 100"
        return sql
    
    def generate_leave_query(self, entities: EntityData, temporal: TemporalData, intent_type: IntentType) -> str:
        """Generate leave/vacation related SQL queries"""
        table_info = self.table_mappings['leave']
        
        sql = f"""
        SELECT {table_info['columns']['angajat']} as angajat,
               {table_info['columns']['tip_concediu']} as tip_concediu,
               {table_info['columns']['data_start']} as data_start,
               {table_info['columns']['data_end']} as data_end,
               {table_info['columns']['locatie']} as locatie,
               CASE c.status
                   WHEN 0 THEN 'Pending'
                   WHEN 1 THEN 'Aprobat Partial'
                   WHEN 2 THEN 'Aprobat'
                   WHEN -1 THEN 'Respins'
                   ELSE 'Necunoscut'
               END as status
        FROM {table_info['table']}
        """
        
        where_conditions = ["u.username != 'test'"]
        
        # Temporal conditions
        if 'today' in temporal.temporal_keywords:
            where_conditions.append("CURDATE() BETWEEN c.start_c AND c.end_c")
        elif 'this_month' in temporal.temporal_keywords:
            where_conditions.append("MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())")
        elif 'this_year' in temporal.temporal_keywords:
            where_conditions.append("YEAR(c.start_c) = YEAR(CURDATE())")
        
        # Status filters
        if 'aprobat' in entities.keywords:
            where_conditions.append("c.status = 2")
        elif 'pending' in entities.keywords or 'asteptare' in entities.keywords:
            where_conditions.append("c.status = 0")
        
        # Add WHERE clause
        if where_conditions:
            sql += f" WHERE {' AND '.join(where_conditions)}"
        
        sql += " ORDER BY c.start_c DESC LIMIT 50"
        return sql
    
    def generate_department_query(self, entities: EntityData, intent_type: IntentType) -> str:
        """Generate department-related SQL queries"""
        if intent_type == IntentType.COUNT:
            sql = """
            SELECT d.nume_dep as departament,
                   COUNT(u.id) as numar_angajati
            FROM departament d 
            LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.username != 'test'
            GROUP BY d.id_dep, d.nume_dep
            ORDER BY numar_angajati DESC
            """
        else:
            sql = """
            SELECT d.nume_dep as departament
            FROM departament d
            ORDER BY d.nume_dep
            """
        
        return sql
    
    def process_query(self, query: str, conversation_context: Optional[Dict] = None) -> Dict[str, Any]:
        """Process a query and return complete analysis + SQL"""
        
        logger.info(f"🧠 Processing enterprise query: {query}")
        
        # 1. Extract entities
        entities = self.entity_extractor.extract_entities(query)
        
        # 2. Process temporal expressions
        temporal = EnhancedTemporalProcessor.process_temporal_expressions(entities)
        
        # 3. Classify query category and intent
        category = self._classify_query_category(query, entities)
        intent_type = self._classify_intent_type(query, entities)
        
        # 4. Generate SQL based on category and intent
        sql_query = self._generate_sql_query(query, entities, temporal, category, intent_type)
        
        # 5. Calculate confidence
        confidence = self._calculate_confidence(query, entities, category)
        
        # 6. Assess complexity
        complexity = self._assess_complexity(query, entities, temporal)
        
        # Store in conversation history
        self.conversation_history.append({
            "query": query,
            "category": category.value,
            "intent_type": intent_type.value,
            "timestamp": datetime.now()
        })
        
        return {
            "original_query": query,
            "intent": {
                "intent_type": intent_type.value,
                "semantic_similarity": 0.8,  # Placeholder
                "filters": {},
                "attributes": [],
                "followup_type": None,
                "conversational_context": conversation_context
            },
            "sql_query": sql_query,
            "complexity": complexity.value,
            "confidence": confidence,
            "category": category.value,
            "entities_found": {
                "departments": entities.departments,
                "positions": entities.positions,
                "persons": entities.persons,
                "locations": entities.locations,
                "numbers": entities.numbers,
                "emails": entities.emails,
                "phone_numbers": entities.phone_numbers,
                "temporal": {
                    "start_date": temporal.start_date,
                    "end_date": temporal.end_date,
                    "keywords": temporal.temporal_keywords
                }
            }
        }
    
    def _classify_query_category(self, query: str, entities: EntityData) -> QueryCategory:
        """Classify the main category of the query"""
        query_lower = query.lower()
        
        # Check for leave/vacation keywords
        leave_keywords = ['concediu', 'concedii', 'vacanta', 'absenta', 'liber', 'odihna']
        if any(keyword in query_lower for keyword in leave_keywords):
            return QueryCategory.LEAVE
        
        # Check for salary keywords
        salary_keywords = ['salariu', 'salarii', 'venit', 'plata', 'remuneratie']
        if any(keyword in query_lower for keyword in salary_keywords):
            return QueryCategory.SALARY
        
        # Check for department keywords
        department_keywords = ['departament', 'departamente', 'sectie', 'divizie']
        if any(keyword in query_lower for keyword in department_keywords):
            return QueryCategory.DEPARTMENT
        
        # Check for project keywords
        project_keywords = ['proiect', 'proiecte', 'task', 'sarcina']
        if any(keyword in query_lower for keyword in project_keywords):
            return QueryCategory.PROJECT
        
        # Default to employee category
        return QueryCategory.EMPLOYEE
    
    def _classify_intent_type(self, query: str, entities: EntityData) -> IntentType:
        """Classify the intent type of the query"""
        query_lower = query.lower()
        
        # Count queries
        count_keywords = ['cati', 'câți', 'numar', 'număr', 'count']
        if any(keyword in query_lower for keyword in count_keywords):
            return IntentType.COUNT
        
        # Top/ranking queries
        top_keywords = ['mari', 'top', 'cel mai', 'maxim', 'minim', 'highest', 'biggest']
        if any(keyword in query_lower for keyword in top_keywords):
            return IntentType.TOP_N
        
        # Temporal queries
        if entities.temporal_keywords:
            return IntentType.TEMPORAL
        
        # Default to list
        return IntentType.LIST
    
    def _generate_sql_query(self, query: str, entities: EntityData, temporal: TemporalData, 
                           category: QueryCategory, intent_type: IntentType) -> str:
        """Generate appropriate SQL query based on analysis"""
        
        if category == QueryCategory.EMPLOYEE or category == QueryCategory.SALARY:
            return self.sql_generator.generate_employee_query(entities, temporal, intent_type)
        elif category == QueryCategory.LEAVE:
            return self.sql_generator.generate_leave_query(entities, temporal, intent_type)
        elif category == QueryCategory.DEPARTMENT:
            return self.sql_generator.generate_department_query(entities, intent_type)
        else:
            # Default employee query
            return self.sql_generator.generate_employee_query(entities, temporal, intent_type)
    
    def _calculate_confidence(self, query: str, entities: EntityData, category: QueryCategory) -> float:
        """Calculate confidence score for the query analysis"""
        confidence = 0.5  # Base confidence
        
        # Boost confidence for recognized entities
        if entities.departments:
            confidence += 0.15
        if entities.positions:
            confidence += 0.10
        if entities.temporal_keywords:
            confidence += 0.10
        
        # Boost for clear category indicators
        query_lower = query.lower()
        category_keywords = {
            QueryCategory.EMPLOYEE: ['angajat', 'angajati', 'personal'],
            QueryCategory.LEAVE: ['concediu', 'concedii', 'vacanta'],
            QueryCategory.SALARY: ['salariu', 'salarii', 'venit'],
            QueryCategory.DEPARTMENT: ['departament', 'departamente'],
            QueryCategory.PROJECT: ['proiect', 'proiecte']
        }
        
        if category in category_keywords:
            for keyword in category_keywords[category]:
                if keyword in query_lower:
                    confidence += 0.05
                    break
        
        return min(confidence, 1.0)
    
    def _assess_complexity(self, query: str, entities: EntityData, temporal: TemporalData) -> QueryComplexity:
        """Assess the complexity of the query"""
        complexity_score = 0
        
        # Basic query structure
        complexity_score += len(query.split()) * 0.02
        
        # Entity complexity
        if entities.departments:
            complexity_score += 0.1
        if entities.positions:
            complexity_score += 0.1
        if entities.temporal_keywords:
            complexity_score += 0.15
        if entities.numbers:
            complexity_score += 0.05
        
        # Multiple filters
        total_entities = (len(entities.departments) + len(entities.positions) + 
                         len(entities.temporal_keywords) + len(entities.numbers))
        if total_entities > 2:
            complexity_score += 0.2
        
        # Determine complexity level
        if complexity_score < 0.3:
            return QueryComplexity.SIMPLE
        elif complexity_score < 0.6:
            return QueryComplexity.MODERATE
        elif complexity_score < 0.8:
            return QueryComplexity.COMPLEX
        else:
            return QueryComplexity.VERY_COMPLEX