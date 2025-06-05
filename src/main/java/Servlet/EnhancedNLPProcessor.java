package Servlet;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * Enhanced NLP Components to be added to the existing NaturalLanguageToSQLTranslator
 * These components add advanced tokenization and semantic understanding capabilities
 */
public class EnhancedNLPProcessor {
    
    // Advanced tokenization patterns for Romanian language
    private static final Pattern WORD_PATTERN = Pattern.compile("\\b\\w+\\b");
    private static final Pattern NUMBER_PATTERN = Pattern.compile("\\b\\d+\\b");
    private static final Pattern YEAR_PATTERN = Pattern.compile("\\b(19|20)\\d{2}\\b");
    private static final Pattern DATE_PATTERN = Pattern.compile("\\b\\d{1,2}[./\\-]\\d{1,2}[./\\-]\\d{2,4}\\b");
    private static final Pattern PHONE_PATTERN = Pattern.compile("\\b0\\d{9}\\b");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("\\b[\\w._%+-]+@[\\w.-]+\\.[A-Z|a-z]{2,}\\b");
    
    // Semantic role patterns for better understanding
    private static final Map<String, List<String>> ENHANCED_SEMANTIC_ROLES = new HashMap<>();
    static {
        // Intent indicators (expanded)
        ENHANCED_SEMANTIC_ROLES.put("QUERY_INTENT", Arrays.asList(
            "cati", "cate", "care", "ce", "cum", "cand", "unde", "de ce", "pentru ce",
            "arata", "afiseaza", "listeaza", "gaseste", "cauta", "verifica", "spune",
            "da-mi", "vreau", "doresc", "as dori", "mi-ar placea", "sunt curios",
            "ma intereseaza", "vreau sa stiu", "vreau sa aflu", "poti sa", "ai putea sa",
            "este posibil sa", "se poate sa", "exista", "ai", "aveti", "avem"
        ));
        
        // Quantifiers and comparatives (expanded)
        ENHANCED_SEMANTIC_ROLES.put("QUANTIFIER", Arrays.asList(
            "toti", "toate", "fiecare", "unii", "unele", "multi", "multe", "putini", "putine",
            "mai multi", "mai putini", "cei mai multi", "cele mai multe", "primul", "ultimul",
            "maxim", "minim", "cel mai mare", "cel mai mic", "top", "bottom", "mai mare",
            "mai mic", "peste", "sub", "intre", "aproximativ", "cam", "circa", "exact"
        ));
        
        // Enhanced time expressions
        ENHANCED_SEMANTIC_ROLES.put("TIME_EXPR", Arrays.asList(
            "astazi", "ieri", "maine", "alaltaieri", "poimaine",
            "saptamana aceasta", "saptamana trecuta", "saptamana viitoare",
            "luna aceasta", "luna trecuta", "luna viitoare", 
            "anul acesta", "anul trecut", "anul viitor",
            "acum", "curent", "actual", "recent", "demult", "devreme", "tarziu",
            "in trecut", "in viitor", "inainte", "dupa", "din", "pana", "de la", "catre",
            "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie",
            "iulie", "august", "septembrie", "octombrie", "noiembrie", "decembrie",
            "primavara", "vara", "toamna", "iarna", "sarbatori", "craciun", "paste", "revelion"
        ));
        
        // Status indicators (expanded)
        ENHANCED_SEMANTIC_ROLES.put("STATUS", Arrays.asList(
            "activ", "inactiv", "aprobat", "neaprobat", "respins", "in asteptare", "finalizat",
            "in progres", "terminat", "neterminat", "complet", "incomplet", "disponibil",
            "ocupat", "liber", "suspendat", "anulat", "confirmat", "planificat", "programat",
            "urgent", "normal", "scazut", "ridicat", "critic", "optional"
        ));
        
        // Relationship indicators (expanded)
        ENHANCED_SEMANTIC_ROLES.put("RELATION", Arrays.asList(
            "din", "in", "de la", "pana la", "cu", "fara", "pentru", "despre", "asupra",
            "printre", "intre", "langa", "peste", "sub", "inainte de", "dupa", "conform",
            "potrivit", "referitor la", "in legatura cu", "privind", "vizavi de"
        ));
        
        // Position/hierarchy indicators
        ENHANCED_SEMANTIC_ROLES.put("HIERARCHY", Arrays.asList(
            "director", "manager", "sef", "coordonator", "responsabil", "supervizor",
            "lider", "administrator", "specialist", "expert", "consultant", "analist",
            "asistent", "intern", "stagiar", "trainee", "junior", "senior", "principal",
            "executiv", "adjunct", "vicepresedinte", "presedinte", "ceo", "cto", "cfo"
        ));
        
        // Department-specific terms
        ENHANCED_SEMANTIC_ROLES.put("DEPT_SPECIFIC", Arrays.asList(
            "dezvoltare", "programare", "testare", "analiza", "design", "arhitectura",
            "contabilitate", "buget", "facturare", "incasari", "plati", "audit",
            "recrutare", "selecție", "formare", "evaluare", "salarizare", "beneficii",
            "promovare", "publicitate", "vanzari", "clienti", "relatii publice",
            "productie", "calitate", "logistica", "transport", "depozitare"
        ));
    }
    
    // Fuzzy matching algorithms for better recognition
    private static final Map<String, List<String>> FUZZY_DEPARTMENT_VARIANTS = new HashMap<>();
    static {
        FUZZY_DEPARTMENT_VARIANTS.put("HR", Arrays.asList("hr", "h.r", "human resources", "resurse umane", "rh", "personal"));
        FUZZY_DEPARTMENT_VARIANTS.put("IT", Arrays.asList("it", "i.t", "ict", "informatica", "tehnologia informatiei", "tehnologie"));
        FUZZY_DEPARTMENT_VARIANTS.put("Finante", Arrays.asList("finante", "financiar", "contabilitate", "contabile", "fin", "economic"));
        FUZZY_DEPARTMENT_VARIANTS.put("Marketing", Arrays.asList("marketing", "mk", "promovare", "publicitate", "pr", "comunicare"));
        FUZZY_DEPARTMENT_VARIANTS.put("Vanzari", Arrays.asList("vanzari", "sales", "comercial", "vinzari", "vz"));
        FUZZY_DEPARTMENT_VARIANTS.put("Juridic", Arrays.asList("juridic", "legal", "drept", "avocatura", "jur"));
    }
    
 // Enhanced entity patterns with salary-focused detection
    private static final Map<String, EntityPattern> ENHANCED_ENTITY_PATTERNS = new HashMap<>();
    static {
        // NEW: Enhanced SALARY pattern with dedicated detection
        ENHANCED_ENTITY_PATTERNS.put("SALARY", new EntityPattern(
            Arrays.asList(
                // Primary salary terms
                "salariu", "salarii", "salariul", "salariile", "salariatul", "salariații",
                "remuneratie", "remuneratii", "venit", "venituri", "castig", "castiguri",
                "plata", "plati", "compensatie", "leafă", "bani", "sume",
                
                // Salary with MINMAX context - CRITICAL for detection
                "salariu maxim", "salariu minim", "salariul cel mai mare", "salariul cel mai mic",
                "cele mai mari salarii", "cele mai mici salarii", "salarii mari", "salarii mici",
                "venitul maxim", "venitul minim", "castigul maxim", "castigul minim",
                
                // Department + salary patterns
                "salariu departament", "salarii departament", "salariile din",
                "venitul din", "castigul din", "plata din", "remuneratia din",
                
                // Query patterns
                "ce salariu", "care salariu", "cat salariu", "cât salariu",
                "cel mai mare salariu", "cel mai mic salariu", "cea mai mare plată"
            ),
            Arrays.asList("tipuri", "t", "useri", "u"),
            Arrays.asList("salariu", "denumire", "nume", "prenume", "departament"),
            0.95 // Very high confidence for salary queries
        ));
        
        // UPDATED: Enhanced EMPLOYEE pattern with salary context boost
        ENHANCED_ENTITY_PATTERNS.put("EMPLOYEE", new EntityPattern(
            Arrays.asList(
                // Primary employee terms
                "angajat", "angajati", "angajații", "angajatul", "angajata", "angajate",
                "personal", "personalul", "persoanele", "persoana",
                "salariat", "salariati", "salariații", "salariatul", "salariata", "salariate",
                "lucrator", "lucratori", "lucrătorii", "lucrătorul", "lucrătoarea",
                "om", "oameni", "oamenii", "omul",
                "coleg", "colegi", "colegii", "colegul", "colega", "colegele",
                "membru", "membri", "membrii", "membrul", "membra", "membrele",
                "staff", "stafful", "echipa", "echipele",
                
                // Employee with salary context - BOOST for salary queries
                "angajatii cu", "angajații cu", "personalul cu", "salariații cu",
                "cei cu", "persoanele cu", "oamenii cu", "colegii cu",
                "angajat cu salariu", "personal cu salariu", "salariat cu venit",
                
                // Employee query patterns
                "care sunt angajati", "care sunt angajații", "cine sunt angajatii", 
                "cati angajati", "câți angajați", "lista angajati", "lista angajaților",
                "angajatii din", "angajații din", "personalul din", "colegii din",
                "cei din", "persoanele din", "membrii din", "oamenii din",
                "care lucreaza", "care lucrează", "cine lucreaza", "cine lucrează",
                
                // Employment context
                "resursa umana", "resurse umane", "resursele umane",
                "muncitor", "muncitori", "muncitorii", "muncitorul",
                "colaborator", "colaboratori", "colaboratorii", "colaboratorul"
            ),
            Arrays.asList("useri", "u"),
            Arrays.asList("nume", "prenume", "email", "telefon", "data_nasterii", "adresa", "cnp", "data_ang"),
            0.90 // High confidence for employee queries
        ));
        
        // Keep other existing patterns with adjusted priorities
        ENHANCED_ENTITY_PATTERNS.put("POSITION", new EntityPattern(
            Arrays.asList(
                "functie", "functii", "pozitie", "pozitii", "post", "posturi", "rol", "roluri", 
                "job", "joburi", "tip", "tipuri", "specializare", "ocupatie", "meserie",
                "ce functii", "care functii", "cate functii", "functii departament",
                "ierarhie", "nivel", "rang", "grad", "statut", "titlu",
                "director", "manager", "sef", "coordonator", "responsabil", "supervizor"
            ),
            Arrays.asList("tipuri", "t", "denumiri_pozitii", "dp"),
            Arrays.asList("tip", "denumire", "salariu", "ierarhie", "descriere", "denumire_completa"),
            0.85
        ));
        
        ENHANCED_ENTITY_PATTERNS.put("DEPARTMENT", new EntityPattern(
            Arrays.asList(
                "departament", "departamente", "departamentul", "departamentului",
                "divizie", "sectie", "grup", "unitate", "directie",
                "ce departamente", "care departamente", "cate departamente"
            ),
            Arrays.asList("departament", "d"),
            Arrays.asList("nume_dep", "id_dep"),
            0.70
        ));
        
        ENHANCED_ENTITY_PATTERNS.put("LEAVE", new EntityPattern(
            Arrays.asList("concediu", "concedii", "vacanta", "absenta", "invoiri", "zi libera", "odihnă", "medical", "maternitate"),
            Arrays.asList("concedii", "c"),
            Arrays.asList("start_c", "end_c", "motiv", "locatie", "durata", "status", "tip"),
            0.80
        ));
        
        ENHANCED_ENTITY_PATTERNS.put("PROJECT", new EntityPattern(
            Arrays.asList("proiect", "proiecte", "task", "sarcina", "obiectiv", "activitate", "lucrare"),
            Arrays.asList("proiecte", "p", "tasks", "t"),
            Arrays.asList("nume", "descriere", "start", "end", "supervizor"),
            0.70
        ));
    }
    
    public static class EntityPattern {
        private List<String> keywords;
        private List<String> tableAliases;
        private List<String> attributes;
        private double baseConfidence;
        
        public EntityPattern(List<String> keywords, List<String> tableAliases, List<String> attributes, double baseConfidence) {
            this.keywords = keywords;
            this.tableAliases = tableAliases;
            this.attributes = attributes;
            this.baseConfidence = baseConfidence;
        }
        
        /**
         * Enhanced confidence calculation with salary query boosting
         */
        public double calculateConfidence(String query) {
            double confidence = 0.0;
            int matches = 0;
            
            for (String keyword : keywords) {
                if (query.contains(keyword)) {
                    matches++;
                    
                    // Calculate base keyword score
                    double keywordScore = (keyword.length() / 10.0) * baseConfidence;
                    
                    // SPECIAL BOOST for salary-related keywords
                    if (isSalaryKeyword(keyword)) {
                        keywordScore *= 2.0; // 100% boost for salary keywords
                    }
                    
                    // SPECIAL BOOST for employee-related keywords
                    if (isEmployeeKeyword(keyword)) {
                        keywordScore *= 1.8; // 80% boost for employee keywords
                    }
                    
                    // SPECIAL BOOST for position-related keywords
                    if (isPositionKeyword(keyword)) {
                        keywordScore *= 1.5; // 50% boost for position keywords
                    }
                    
                    // BOOST for multi-word salary patterns
                    if (isSalaryQueryPattern(keyword)) {
                        keywordScore *= 2.5; // 150% boost for clear salary query patterns
                    }
                    
                    // BOOST for multi-word employee patterns
                    if (isEmployeeQueryPattern(keyword)) {
                        keywordScore *= 2.0; // 100% boost for clear employee query patterns
                    }
                    
                    confidence += keywordScore;
                }
            }
            
            // Normalize by number of keywords and add bonus for multiple matches
            if (matches > 0) {
                confidence = (confidence / keywords.size()) + (matches > 1 ? 0.15 : 0.0);
            }
            
            // MAJOR BOOST for salary + department combinations
            if (hasSalaryDepartmentCombination(query)) {
                confidence += 0.6; // Major boost for "salariu departament" type queries
            }
            
            // MAJOR BOOST for salary + minmax combinations
            if (hasSalaryMinMaxCombination(query)) {
                confidence += 0.7; // Huge boost for "salariu minim/maxim" type queries
            }
            
            // MAJOR BOOST for employee + department combinations
            if (hasEmployeeDepartmentCombination(query)) {
                confidence += 0.5; // Major boost for "angajați din departament" type queries
            }
            
            // MAJOR BOOST for position + department combinations
            if (hasPositionDepartmentCombination(query)) {
                confidence += 0.4; // Major boost for "functii departament" type queries
            }
            
            // Boost for temporal expressions
            if (hasTemporalIndicators(query)) {
                confidence += 0.3;
            }
            
            // Boost for numeric expressions
            if (hasNumericIndicators(query)) {
                confidence += 0.2;
            }
            
            return Math.min(confidence, 1.0);
        }
        
        /**
         * Check if keyword is salary-related
         */
        private boolean isSalaryKeyword(String keyword) {
            String[] coreSalaryWords = {
                "salariu", "salarii", "salariul", "venit", "venituri", "castig", "castiguri",
                "plata", "compensatie", "remuneratie", "leafă", "bani"
            };
            
            for (String salWord : coreSalaryWords) {
                if (keyword.contains(salWord)) {
                    return true;
                }
            }
            return false;
        }
        
        /**
         * Check if keyword is a clear salary query pattern
         */
        private boolean isSalaryQueryPattern(String keyword) {
            String[] salaryPatterns = {
                "salariu maxim", "salariu minim", "salariul cel mai mare", "salariul cel mai mic",
                "cele mai mari salarii", "cele mai mici salarii", "salarii mari", "salarii mici",
                "salariu departament", "salarii departament", "venitul maxim", "castigul minim"
            };
            
            for (String pattern : salaryPatterns) {
                if (keyword.equals(pattern)) {
                    return true;
                }
            }
            return false;
        }
        
        /**
         * Check for salary + department combinations
         */
        private boolean hasSalaryDepartmentCombination(String query) {
            String[] salaryWords = {
                "salariu", "salarii", "venit", "venituri", "castig", "castiguri",
                "plata", "compensatie", "remuneratie", "leafă"
            };
            
            String[] departmentWords = {
                "departament", "departamentul", "din departament",
                "it", "hr", "finante", "marketing", "juridic"
            };
            
            boolean hasSalary = false;
            boolean hasDepartment = false;
            
            for (String sal : salaryWords) {
                if (query.contains(sal)) {
                    hasSalary = true;
                    break;
                }
            }
            
            for (String dept : departmentWords) {
                if (query.contains(dept)) {
                    hasDepartment = true;
                    break;
                }
            }
            
            return hasSalary && hasDepartment;
        }
        
        /**
         * Check for salary + minmax combinations
         */
        private boolean hasSalaryMinMaxCombination(String query) {
            String[] salaryWords = {
                "salariu", "salarii", "venit", "venituri", "castig", "castiguri"
            };
            
            String[] minMaxWords = {
                "maxim", "minim", "cel mai mare", "cel mai mic", "cea mai mare", "cea mai mica",
                "mari", "mici", "mare", "mic", "maximum", "minimum"
            };
            
            boolean hasSalary = false;
            boolean hasMinMax = false;
            
            for (String sal : salaryWords) {
                if (query.contains(sal)) {
                    hasSalary = true;
                    break;
                }
            }
            
            for (String minMax : minMaxWords) {
                if (query.contains(minMax)) {
                    hasMinMax = true;
                    break;
                }
            }
            
            return hasSalary && hasMinMax;
        }
        
        // Keep existing methods unchanged...
        private boolean isEmployeeKeyword(String keyword) {
            String[] coreEmployeeWords = {
                "angajat", "angajati", "angajații", "personalul", "personal",
                "salariat", "salariati", "salariații", "lucrator", "lucratori",
                "om", "oameni", "coleg", "colegi", "membru", "membri", "staff"
            };
            
            for (String empWord : coreEmployeeWords) {
                if (keyword.contains(empWord)) {
                    return true;
                }
            }
            return false;
        }
        
        private boolean isEmployeeQueryPattern(String keyword) {
            String[] employeePatterns = {
                "care sunt angajati", "care sunt angajații", "cine sunt angajatii",
                "angajatii din", "angajații din", "personalul din", "colegii din",
                "cei din", "persoanele din", "membrii din", "oamenii din",
                "care lucreaza", "care lucrează", "cine lucreaza", "cine lucrează"
            };
            
            for (String pattern : employeePatterns) {
                if (keyword.equals(pattern)) {
                    return true;
                }
            }
            return false;
        }
        
        private boolean hasEmployeeDepartmentCombination(String query) {
            String[] employeeWords = {
                "angajat", "angajati", "angajații", "personal", "personalul",
                "salariat", "salariati", "salariații", "lucrator", "lucratori",
                "om", "oameni", "coleg", "colegi", "membru", "membri", "staff",
                "care sunt", "cine sunt", "cei din", "persoanele din"
            };
            
            String[] departmentWords = {
                "departament", "departamentul", "din departament",
                "it", "hr", "finante", "marketing", "juridic"
            };
            
            boolean hasEmployee = false;
            boolean hasDepartment = false;
            
            for (String emp : employeeWords) {
                if (query.contains(emp)) {
                    hasEmployee = true;
                    break;
                }
            }
            
            for (String dept : departmentWords) {
                if (query.contains(dept)) {
                    hasDepartment = true;
                    break;
                }
            }
            
            return hasEmployee && hasDepartment;
        }
        
        
        
        /**
         * Check if keyword is position-related
         */
        private boolean isPositionKeyword(String keyword) {
            String[] corePositionWords = {
                "functie", "functii", "pozitie", "pozitii", "post", "posturi", 
                "rol", "roluri", "tip", "tipuri", "specializare", "ierarhie",
                "director", "manager", "sef", "specialist", "expert", "consultant"
            };
            
            for (String posWord : corePositionWords) {
                if (keyword.contains(posWord)) {
                    return true;
                }
            }
            return false;
        }
        
        /**
         * Check for position + department combinations
         */
        private boolean hasPositionDepartmentCombination(String query) {
            String[] positionWords = {"functii", "pozitii", "tipuri", "roluri", "specializari"};
            String[] departmentWords = {"departament", "it", "hr", "finante", "marketing"};
            
            boolean hasPosition = false;
            boolean hasDepartment = false;
            
            for (String pos : positionWords) {
                if (query.contains(pos)) {
                    hasPosition = true;
                    break;
                }
            }
            
            for (String dept : departmentWords) {
                if (query.contains(dept)) {
                    hasDepartment = true;
                    break;
                }
            }
            
            return hasPosition && hasDepartment;
        }

        /**
         * Check if query has temporal indicators
         */
        private boolean hasTemporalIndicators(String query) {
            String[] temporalWords = {
                "astazi", "azi", "ieri", "maine", "luna", "an", "anul", "saptamana",
                "aceasta", "acesta", "trecuta", "trecut", "viitoare", "viitor",
                "decembrie", "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie",
                "iulie", "august", "septembrie", "octombrie", "noiembrie", "craciun", "paste"
            };
            
            for (String temporal : temporalWords) {
                if (query.contains(temporal)) {
                    return true;
                }
            }
            return false;
        }

        /**
         * Check if query has numeric indicators
         */
        private boolean hasNumericIndicators(String query) {
            // Check for numbers
            if (query.matches(".*\\d+.*")) {
                return true;
            }
            
            // Check for comparative words
            String[] numericWords = {"peste", "sub", "mai mare", "mai mic", "minim", "maxim"};
            for (String numeric : numericWords) {
                if (query.contains(numeric)) {
                    return true;
                }
            }
            return false;
        }
    }
    
    /**
     * Generate enhanced suggestions with better position support
     */
    public static List<String> generateEnhancedSuggestions(String query, Map<String, Double> entityConfidences) {
        List<String> suggestions = new ArrayList<>();
        
        // Find the most confident entity
        String topEntity = entityConfidences.entrySet().stream()
            .max(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse(null);
        
        if (topEntity != null) {
            switch (topEntity) {
                case "POSITION":
                    suggestions.add("Ce funcții există în departamentul IT?");
                    suggestions.add("Care sunt pozițiile din departamentul HR?");
                    suggestions.add("Câte tipuri de funcții avem în firmă?");
                    suggestions.add("Care sunt funcțiile cel mai bine plătite?");
                    suggestions.add("Ce specializări există în fiecare departament?");
                    suggestions.add("Arată-mi ierarhia funcțiilor din Marketing");
                    break;
                    
                case "EMPLOYEE":
                    suggestions.add("Câți angajați sunt în departamentul IT?");
                    suggestions.add("Arată-mi angajații cu cel mai mare salariu");
                    suggestions.add("Care angajați au fost angajați anul acesta?");
                    suggestions.add("Ce funcții au angajații din HR?");
                    break;
                    
                case "DEPARTMENT":
                    suggestions.add("Ce departamente există în firmă?");
                    suggestions.add("Care departament are cei mai mulți angajați?");
                    suggestions.add("Unde se află departamentul Marketing?");
                    suggestions.add("Câți manageri sunt în fiecare departament?");
                    break;
                    
                case "LEAVE":
                    suggestions.add("Cine este în concediu astăzi?");
                    suggestions.add("Câte concedii au fost aprobate luna aceasta?");
                    suggestions.add("Care sunt concediile din decembrie?");
                    suggestions.add("Arată-mi concediile medicale din acest an");
                    break;
                    
                case "PROJECT":
                    suggestions.add("Ce proiecte active avem?");
                    suggestions.add("Cine lucrează la proiectul ERP?");
                    suggestions.add("Care proiecte se termină luna aceasta?");
                    suggestions.add("Câte task-uri sunt în progres?");
                    break;
            }
        }
        
        // Add general suggestions if no specific entity detected or for low confidence
        if (suggestions.isEmpty()) {
            suggestions.add("Ce funcții există în departamentul IT?");
            suggestions.add("Câți angajați sunt în firmă?");
            suggestions.add("Ce departamente există?");
            suggestions.add("Cine este în concediu astăzi?");
            suggestions.add("Ce proiecte active avem?");
        }
        
        return suggestions;
    }
    
    /**
     * Advanced tokenization result
     */
    public static class AdvancedTokenization {
        private List<String> originalTokens;
        private List<String> normalizedTokens;
        private List<String> semanticTokens;
        private Map<String, List<String>> semanticRoles;
        private Map<String, Double> entityConfidences;
        private List<TemporalExpression> temporalExpressions;
        private List<NumericExpression> numericExpressions;
        
        public AdvancedTokenization() {
            this.originalTokens = new ArrayList<>();
            this.normalizedTokens = new ArrayList<>();
            this.semanticTokens = new ArrayList<>();
            this.semanticRoles = new HashMap<>();
            this.entityConfidences = new HashMap<>();
            this.temporalExpressions = new ArrayList<>();
            this.numericExpressions = new ArrayList<>();
        }
        
        // Getters and setters
        public List<String> getOriginalTokens() { return originalTokens; }
        public void setOriginalTokens(List<String> originalTokens) { this.originalTokens = originalTokens; }
        
        public List<String> getNormalizedTokens() { return normalizedTokens; }
        public void setNormalizedTokens(List<String> normalizedTokens) { this.normalizedTokens = normalizedTokens; }
        
        public List<String> getSemanticTokens() { return semanticTokens; }
        public void setSemanticTokens(List<String> semanticTokens) { this.semanticTokens = semanticTokens; }
        
        public Map<String, List<String>> getSemanticRoles() { return semanticRoles; }
        public void setSemanticRoles(Map<String, List<String>> semanticRoles) { this.semanticRoles = semanticRoles; }
        
        public Map<String, Double> getEntityConfidences() { return entityConfidences; }
        public void setEntityConfidences(Map<String, Double> entityConfidences) { this.entityConfidences = entityConfidences; }
        
        public List<TemporalExpression> getTemporalExpressions() { return temporalExpressions; }
        public void setTemporalExpressions(List<TemporalExpression> temporalExpressions) { this.temporalExpressions = temporalExpressions; }
        
        public List<NumericExpression> getNumericExpressions() { return numericExpressions; }
        public void setNumericExpressions(List<NumericExpression> numericExpressions) { this.numericExpressions = numericExpressions; }
    }
    
    /**
     * Temporal expression class
     */
    public static class TemporalExpression {
        private String originalText;
        private String normalizedText;
        private String temporalType; // "absolute", "relative", "range"
        private Date specificDate;
        private String sqlCondition;
        
        public TemporalExpression(String originalText, String temporalType) {
            this.originalText = originalText;
            this.temporalType = temporalType;
            this.normalizedText = normalizeTemporalExpression(originalText);
            this.sqlCondition = generateSQLCondition();
        }
        
        private String normalizeTemporalExpression(String expr) {
            expr = expr.toLowerCase();
            // Replace variations
            expr = expr.replace("astăzi", "astazi")
                      .replace("ăsta", "acesta")
                      .replace("ăstă", "aceasta");
            return expr;
        }
        
        private String generateSQLCondition() {
            switch (normalizedText) {
                case "astazi":
                case "azi":
                    return "DATE(column_name) = CURDATE()";
                case "ieri":
                    return "DATE(column_name) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)";
                case "maine":
                    return "DATE(column_name) = DATE_ADD(CURDATE(), INTERVAL 1 DAY)";
                case "saptamana aceasta":
                    return "YEARWEEK(column_name) = YEARWEEK(CURDATE())";
                case "luna aceasta":
                    return "MONTH(column_name) = MONTH(CURDATE()) AND YEAR(column_name) = YEAR(CURDATE())";
                case "anul acesta":
                    return "YEAR(column_name) = YEAR(CURDATE())";
                default:
                    return null;
            }
        }
        
        // Getters
        public String getOriginalText() { return originalText; }
        public String getNormalizedText() { return normalizedText; }
        public String getTemporalType() { return temporalType; }
        public String getSqlCondition() { return sqlCondition; }
    }
    
    /**
     * Numeric expression class
     */
    public static class NumericExpression {
        private String originalText;
        private Integer value;
        private String operator; // ">", "<", "=", ">=", "<=", "BETWEEN"
        private String context; // "salary", "age", "count", etc.
        
        public NumericExpression(String originalText, Integer value, String operator) {
            this.originalText = originalText;
            this.value = value;
            this.operator = operator;
            this.context = inferContext(originalText);
        }
        
        private String inferContext(String text) {
            if (text.contains("salariu") || text.contains("venit") || text.contains("castig")) {
                return "salary";
            } else if (text.contains("varsta") || text.contains("ani") && text.contains("vechi")) {
                return "age";
            } else if (text.contains("cati") || text.contains("cate") || text.contains("numar")) {
                return "count";
            }
            return "unknown";
        }
        
        // Getters
        public String getOriginalText() { return originalText; }
        public Integer getValue() { return value; }
        public String getOperator() { return operator; }
        public String getContext() { return context; }
    }
    
    /**
     * Enhanced text normalization with advanced Romanian language support
     */
    public static String enhancedNormalizeText(String text) {
        if (text == null || text.trim().isEmpty()) {
            return "";
        }
        
        String result = text.toLowerCase().trim();
        
        // Enhanced Romanian diacritics normalization
        Map<String, String> diacritics = new HashMap<>();
        diacritics.put("ă", "a");
        diacritics.put("â", "a");
        diacritics.put("î", "i");
        diacritics.put("ș", "s");
        diacritics.put("ț", "t");
        diacritics.put("Ă", "a");
        diacritics.put("Â", "a");
        diacritics.put("Î", "i");
        diacritics.put("Ș", "s");
        diacritics.put("Ț", "t");
        
        for (Map.Entry<String, String> entry : diacritics.entrySet()) {
            result = result.replace(entry.getKey(), entry.getValue());
        }
        
        // Handle common Romanian contractions and variations
        Map<String, String> contractions = new HashMap<>();
        contractions.put("n-am", "nu am");
        contractions.put("n-are", "nu are");
        contractions.put("n-au", "nu au");
        contractions.put("s-a", "se a");
        contractions.put("m-am", "ma am");
        contractions.put("v-ati", "va ati");
        contractions.put("departamentul", "departament");
        contractions.put("angajatii", "angajati");
        contractions.put("concediile", "concedii");
        contractions.put("salariile", "salarii");
        
        for (Map.Entry<String, String> entry : contractions.entrySet()) {
            result = result.replace(entry.getKey(), entry.getValue());
        }
        
        // Normalize punctuation and separators
        result = result.replaceAll("[\\-_.,:;!?\"']+", " ");
        result = result.replaceAll("\\s+", " ");
        
        return result.trim();
    }
    
    /**
     * Advanced tokenization with semantic analysis
     */
    public static AdvancedTokenization performAdvancedTokenization(String query) {
        AdvancedTokenization result = new AdvancedTokenization();
        
        // Original tokenization
        List<String> originalTokens = extractTokens(query);
        result.setOriginalTokens(originalTokens);
        
        // Normalize the query
        String normalized = enhancedNormalizeText(query);
        List<String> normalizedTokens = extractTokens(normalized);
        result.setNormalizedTokens(normalizedTokens);
        
        // Create semantic tokens (group related words)
        List<String> semanticTokens = createAdvancedSemanticTokens(normalizedTokens);
        result.setSemanticTokens(semanticTokens);
        
        // Identify semantic roles
        Map<String, List<String>> roles = identifyEnhancedSemanticRoles(normalized);
        result.setSemanticRoles(roles);
        
        // Calculate entity confidences
        Map<String, Double> entityConfidences = calculateEntityConfidences(normalized);
        result.setEntityConfidences(entityConfidences);
        
        // Extract temporal expressions
        List<TemporalExpression> temporalExpressions = extractTemporalExpressions(normalized);
        result.setTemporalExpressions(temporalExpressions);
        
        // Extract numeric expressions
        List<NumericExpression> numericExpressions = extractNumericExpressions(normalized);
        result.setNumericExpressions(numericExpressions);
        
        return result;
    }
    
    /**
     * Extract tokens using multiple patterns
     */
    private static List<String> extractTokens(String text) {
        List<String> tokens = new ArrayList<>();
        
        Matcher wordMatcher = WORD_PATTERN.matcher(text);
        while (wordMatcher.find()) {
            tokens.add(wordMatcher.group());
        }
        
        return tokens;
    }
    
    /**
     * Create advanced semantic tokens with better grouping
     */
    private static List<String> createAdvancedSemanticTokens(List<String> tokens) {
        List<String> semanticTokens = new ArrayList<>();
        
        for (int i = 0; i < tokens.size(); i++) {
            String token = tokens.get(i);
            
            // Check for 4-grams first
            if (i < tokens.size() - 3) {
                String fourgram = String.join(" ", tokens.subList(i, i + 4));
                if (isAdvancedSemanticUnit(fourgram)) {
                    semanticTokens.add(fourgram);
                    i += 3;
                    continue;
                }
            }
            
            // Check for trigrams
            if (i < tokens.size() - 2) {
                String trigram = String.join(" ", tokens.subList(i, i + 3));
                if (isAdvancedSemanticUnit(trigram)) {
                    semanticTokens.add(trigram);
                    i += 2;
                    continue;
                }
            }
            
            // Check for bigrams
            if (i < tokens.size() - 1) {
                String bigram = token + " " + tokens.get(i + 1);
                if (isAdvancedSemanticUnit(bigram)) {
                    semanticTokens.add(bigram);
                    i++;
                    continue;
                }
            }
            
            semanticTokens.add(token);
        }
        
        return semanticTokens;
    }
    
    /**
     * Check if a phrase is an advanced semantic unit
     */
    private static boolean isAdvancedSemanticUnit(String phrase) {
        // Enhanced multi-word expressions
        String[] multiWordExpressions = {
            "resurse umane", "tehnologia informatiei", "cercetare si dezvoltare",
            "business intelligence", "control intern", "servicii generale",
            "customer support", "suport clienti", "relatii publice",
            "cel mai mare", "cel mai mic", "cei mai multi", "cele mai multe",
            "mai mare decat", "mai mic decat", "egal cu", "diferit de",
            "saptamana aceasta", "saptamana trecuta", "saptamana viitoare",
            "luna aceasta", "luna trecuta", "luna viitoare",
            "anul acesta", "anul trecut", "anul viitor",
            "in asteptare", "in progres", "zi libera", "ore suplimentare",
            "data angajarii", "data nasterii", "data modificarii",
            "care departament", "cati angajati", "ce functii", "ce tipuri",
            "cum sa", "unde sa", "cand sa", "de ce sa", "pentru ce sa"
        };
        
        for (String expr : multiWordExpressions) {
            if (phrase.equals(expr)) return true;
        }
        
        // Check against known department variants
        for (List<String> variants : FUZZY_DEPARTMENT_VARIANTS.values()) {
            if (variants.contains(phrase)) return true;
        }
        
        return false;
    }
    
    /**
     * Identify enhanced semantic roles
     */
    private static Map<String, List<String>> identifyEnhancedSemanticRoles(String query) {
        Map<String, List<String>> roles = new HashMap<>();
        
        for (Map.Entry<String, List<String>> roleEntry : ENHANCED_SEMANTIC_ROLES.entrySet()) {
            String role = roleEntry.getKey();
            List<String> keywords = roleEntry.getValue();
            List<String> matchedTokens = new ArrayList<>();
            
            for (String keyword : keywords) {
                if (query.contains(keyword)) {
                    matchedTokens.add(keyword);
                }
            }
            
            if (!matchedTokens.isEmpty()) {
                roles.put(role, matchedTokens);
            }
        }
        
        return roles;
    }
    
    /**
     * Calculate entity confidences using enhanced patterns
     */
    private static Map<String, Double> calculateEntityConfidences(String query) {
        Map<String, Double> confidences = new HashMap<>();
        
        for (Map.Entry<String, EntityPattern> entry : ENHANCED_ENTITY_PATTERNS.entrySet()) {
            String entityType = entry.getKey();
            EntityPattern pattern = entry.getValue();
            
            double confidence = pattern.calculateConfidence(query);
            if (confidence > 0.1) { // Only include if above threshold
                confidences.put(entityType, confidence);
            }
        }
        
        return confidences;
    }
    
    /**
     * Extract temporal expressions with advanced parsing
     */
    private static List<TemporalExpression> extractTemporalExpressions(String query) {
        List<TemporalExpression> expressions = new ArrayList<>();
        
        // Predefined temporal expressions
        String[] temporalPatterns = {
            "astazi", "azi", "ieri", "maine", "alaltaieri", "poimaine",
            "saptamana aceasta", "saptamana trecuta", "saptamana viitoare",
            "luna aceasta", "luna trecuta", "luna viitoare",
            "anul acesta", "anul trecut", "anul viitor",
            "primavara", "vara", "toamna", "iarna"
        };
        
        for (String pattern : temporalPatterns) {
            if (query.contains(pattern)) {
                expressions.add(new TemporalExpression(pattern, "relative"));
            }
        }
        
        // Extract date patterns
        Matcher dateMatcher = DATE_PATTERN.matcher(query);
        while (dateMatcher.find()) {
            expressions.add(new TemporalExpression(dateMatcher.group(), "absolute"));
        }
        
        // Extract year patterns
        Matcher yearMatcher = YEAR_PATTERN.matcher(query);
        while (yearMatcher.find()) {
            expressions.add(new TemporalExpression(yearMatcher.group(), "absolute"));
        }
        
        return expressions;
    }
    
    /**
     * Extract numeric expressions with context
     */
    private static List<NumericExpression> extractNumericExpressions(String query) {
        List<NumericExpression> expressions = new ArrayList<>();
        
        // Extract numbers with potential operators
        Matcher numberMatcher = NUMBER_PATTERN.matcher(query);
        while (numberMatcher.find()) {
            String numberStr = numberMatcher.group();
            try {
                Integer value = Integer.parseInt(numberStr);
                
                // Determine operator from context
                String operator = "="; // default
                int start = numberMatcher.start();
                int end = numberMatcher.end();
                
                // Look for operator context around the number
                String before = "";
                String after = "";
                
                if (start > 5) {
                    before = query.substring(Math.max(0, start - 10), start);
                }
                if (end < query.length() - 5) {
                    after = query.substring(end, Math.min(query.length(), end + 10));
                }
                
                String context = before + " " + after;
                
                if (context.contains("peste") || context.contains("mai mare") || context.contains("minim")) {
                    operator = ">";
                } else if (context.contains("sub") || context.contains("mai mic") || context.contains("maxim")) {
                    operator = "<";
                } else if (context.contains("intre")) {
                    operator = "BETWEEN";
                }
                
                expressions.add(new NumericExpression(numberStr, value, operator));
                
            } catch (NumberFormatException e) {
                // Skip invalid numbers
            }
        }
        
        return expressions;
    }
    
    /**
     * Enhanced department detection with fuzzy matching
     */
    public static String detectDepartmentWithFuzzyMatching(String query) {
        // Direct mapping check first
        for (Map.Entry<String, List<String>> entry : FUZZY_DEPARTMENT_VARIANTS.entrySet()) {
            String department = entry.getKey();
            List<String> variants = entry.getValue();
            
            for (String variant : variants) {
                if (query.contains(variant)) {
                    return department;
                }
            }
        }
        
        // Fuzzy matching for partial matches
        for (Map.Entry<String, List<String>> entry : FUZZY_DEPARTMENT_VARIANTS.entrySet()) {
            String department = entry.getKey();
            List<String> variants = entry.getValue();
            
            for (String variant : variants) {
                if (calculateFuzzyMatch(query, variant) > 0.7) {
                    return department;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Calculate fuzzy match score between two strings
     */
    private static double calculateFuzzyMatch(String text1, String text2) {
        if (text1.equals(text2)) return 1.0;
        if (text1.contains(text2) || text2.contains(text1)) return 0.8;
        
        // Simple Levenshtein-based scoring
        int maxLen = Math.max(text1.length(), text2.length());
        if (maxLen == 0) return 1.0;
        
        int distance = calculateLevenshteinDistance(text1, text2);
        return 1.0 - (double) distance / maxLen;
    }
    
    /**
     * Calculate Levenshtein distance between two strings
     */
    private static int calculateLevenshteinDistance(String str1, String str2) {
        int[][] dp = new int[str1.length() + 1][str2.length() + 1];
        
        for (int i = 0; i <= str1.length(); i++) {
            for (int j = 0; j <= str2.length(); j++) {
                if (i == 0) {
                    dp[i][j] = j;
                } else if (j == 0) {
                    dp[i][j] = i;
                } else {
                    dp[i][j] = Math.min(Math.min(
                        dp[i - 1][j] + 1,
                        dp[i][j - 1] + 1),
                        dp[i - 1][j - 1] + (str1.charAt(i - 1) == str2.charAt(j - 1) ? 0 : 1)
                    );
                }
            }
        }
        
        return dp[str1.length()][str2.length()];
    }
    
    
    /**
     * Confidence-based query classification
     */
    public static String classifyQueryWithConfidence(Map<String, Double> entityConfidences, double threshold) {
        double maxConfidence = entityConfidences.values().stream()
            .mapToDouble(Double::doubleValue)
            .max()
            .orElse(0.0);
        
        if (maxConfidence >= threshold) {
            return "HIGH_CONFIDENCE";
        } else if (maxConfidence >= threshold * 0.6) {
            return "MEDIUM_CONFIDENCE";
        } else {
            return "LOW_CONFIDENCE";
        }
    }
}