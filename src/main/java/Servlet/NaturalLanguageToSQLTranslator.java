package Servlet;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Improved translator for converting natural language questions to SQL queries
 * Based on the original NaturalLanguageToSQLTranslator with enhanced capabilities
 */
public class NaturalLanguageToSQLTranslator {
    
    // Inquiry keywords - expressions indicating a request/question
    private static final Set<String> INQUIRY_KEYWORDS = new HashSet<>(Arrays.asList(
        "da-mi", "da mi", "sa-mi dai", "sa mi dai", "arata-mi", "arata mi", 
        "sa-mi arati", "sa mi arati", "afiseaza-mi", "afiseaza mi", "sa-mi afisezi", 
        "sa mi afisezi", "scrie-mi", "scrie mi", "sa-mi scrii", "sa mi scrii", 
        "spune-mi", "spune mi", "sa-mi spui", "sa mi spui", "te rog sa", "as dori ca", 
        "as dori sa", "vreau sa stiu", "vreau sa aflu", "as dori sa stiu", 
        "as dori sa aflu", "mi-ar placea sa stiu", "sa faci", "fa", "da", "exista",
        "gaseste", "gaseste-mi", "determina", "calculeaza", "cauta", "cauta-mi"
    ));
    
    // Follow-up keywords - expressions indicating a follow-up to a previous question
    private static final Set<String> FOLLOWUP_KEYWORDS = new HashSet<>(Arrays.asList(
        "da, te rog", "da", "te rog", "vreau", "doresc", "mi-ar placea sa stiu", 
        "mi-ar placea sa aflu", "ai o idee buna", "buna idee", 
        "nu m-am gandit la asta", "nu m-am gandit la asta, asa ca te rog sa",
        "sigur", "bineinteles", "desigur", "arata-mi", "mai multe", "mai mult",
        "detalii", "detaliat", "continua", "mai departe", "inteleg"
    ));
    
    // Stop keywords - expressions indicating a request to stop the conversation
    private static final Set<String> STOP_KEYWORDS = new HashSet<>(Arrays.asList(
        "nu", "suficient", "e suficient", "nu e nevoie", "nu, mersi", "nu, multumesc",
        "gata", "stop", "opreste", "inchide", "am terminat", "ajunge", "multumesc"
    ));
    
    // Count keywords - expressions indicating a request for counting
    private static final Set<String> COUNT_KEYWORDS = new HashSet<>(Arrays.asList(
        "cati", "cate", "numarul", "numar", "numara", "cat la suta", "cate procente", 
        "ce procent", "cati sunt", "cate sunt", "count", "statistica", "statistici",
        "total", "suma", "cati angajati", "cate persoane", "cate concedii"
    ));
    
    // MinMax keywords - expressions indicating a request for minimum/maximum values
    private static final Set<String> MINMAX_KEYWORDS = new HashSet<>(Arrays.asList(
        "maxim", "minim", "cel mai mare", "cea mai mare", "cel mai mic", "cea mai mica", 
        "cei mai multi", "cei mai putini", "cele mai multe", "cele mai putine",
        "top", "primii", "primele", "ultimii", "ultimele", "maximul", "minimul",
        "mai mult", "mai putin", "mai mare", "mai mic", "record", "limita"
    ));
    
    // List keywords - expressions indicating a request for listing items
    private static final Set<String> LIST_KEYWORDS = new HashSet<>(Arrays.asList(
        "care", "lista", "ce", "detalii", "detaliaza", "descrie", "prezinta", "arata",
        "informatii", "date", "tabel", "listare", "listeaza", "evidenta", "rezultate",
        "toate", "toti", "informeaza-ma", "spune-mi despre", "vezi", "gaseste"
    ));
    
    // Department keywords
    private static final Set<String> DEPARTMENT_KEYWORDS = new HashSet<>(Arrays.asList(
        "departament", "departamente", "departamentul", "divizie", "divizia", "sectie",
        "sector", "echipa", "team", "directie", "biroul", "compartiment", "group"
    ));
    
    // Firm/company keywords
    private static final Set<String> FIRM_KEYWORDS = new HashSet<>(Arrays.asList(
        "firma", "toata firma", "compania", "organizatia", "societatea", "peste tot", 
        "intreprinderea", "in general", "companie", "toti", "toate", "global", "overall"
    ));
    
    // Employee keywords
    private static final Set<String> EMPLOYEE_KEYWORDS = new HashSet<>(Arrays.asList(
        "angajat", "angajati", "personal", "om", "oameni", "persoana", "persoane", 
        "salariat", "salariati", "muncitor", "muncitori", "lucrator", "lucratori",
        "coleg", "colegi", "colectiv", "resursa umana", "resurse umane", "staff"
    ));
    
    // Leave/vacation keywords
    private static final Set<String> LEAVE_KEYWORDS = new HashSet<>(Arrays.asList(
        "concediu", "concedii", "vacanta", "absenta", "absente", "vacant", "liber",
        "zi libera", "zile libere", "odihna", "medical", "maternitate", "paternitate",
        "invoiri", "invoire", "time off", "absence", "lipsa", "inlocuire"
    ));
    
    // Location keywords
    private static final Set<String> LOCATION_KEYWORDS = new HashSet<>(Arrays.asList(
        "locatie", "locatii", "adresa", "adrese", "oras", "tara", "judet", "strada", 
        "locul", "zona", "regiune", "cartier", "localitate", "spatiu", "cladire",
        "cod postal", "coordonate", "amplasare", "sediul", "punctul de lucru", "location"
    ));
    
    // Office/headquarters keywords
    private static final Set<String> OFFICE_KEYWORDS = new HashSet<>(Arrays.asList(
        "sediu", "sedii", "cladire", "cladiri", "pavilion", "birouri", "birou", 
        "centru", "punct de lucru", "sucursala", "filiala", "reprezentanta",
        "headquarters", "hq", "building", "office"
    ));
    
    // Certificate/document keywords
    private static final Set<String> CERTIFICATE_KEYWORDS = new HashSet<>(Arrays.asList(
        "adeverinta", "adeverinte", "document", "documente", "certificat", "certificate",
        "act", "acte", "fisa", "dosar", "atestat", "diploma", "formular", "legitimatie",
        "carte", "documente oficiale", "hartii", "dovada", "dovezi"
    ));
    
    // Position/role keywords
    private static final Set<String> POSITION_KEYWORDS = new HashSet<>(Arrays.asList(
        "functie", "functii", "post", "posturi", "pozitie", "pozitii", "job", "joburi",
        "rol", "roluri", "tip", "tipuri", "specializare", "ocupatie", "meserie", "nivel",
        "rank", "ierarhie", "titlu", "responsabilitate", "statut"
    ));
    
    // Salary keywords
    private static final Set<String> SALARY_KEYWORDS = new HashSet<>(Arrays.asList(
        "salariu", "salarii", "remuneratie", "venit", "venituri", "castig", "castiguri",
        "plata", "compensatie", "recompensa", "leafă", "bani", "sume", "compensare",
        "income", "retributie", "tarif", "onorariu", "valoare"
    ));
    
    // Language keywords
    private static final Set<String> LANGUAGE_KEYWORDS = new HashSet<>(Arrays.asList(
        "limba", "limbi", "limbaj", "limbaje", "limbile", "language", "languages",
        "straina", "strain", "native", "materna", "competenta lingvistica"
    ));
    
    // Education keywords
    private static final Set<String> EDUCATION_KEYWORDS = new HashSet<>(Arrays.asList(
        "studii", "studiu", "ciclu", "cicluri", "facultate", "facultati", "specializare", 
        "specializari", "universitate", "universitati", "scoala", "liceu", "educatie",
        "calificare", "diploma", "certificare", "absolvent", "academic", "invatamant"
    ));
    
    // Seniority/experience keywords
    private static final Set<String> SENIORITY_KEYWORDS = new HashSet<>(Arrays.asList(
        "vechime", "experienta", "ani de vechime", "ani de experienta", "senioritate",
        "stagiu", "practica", "xp", "exp", "background", "cariera", "istoric", "cv",
        "durata", "timp", "perioada", "termen", "senior", "junior", "mid"
    ));
    
    // Bonus/incentive keywords 
    private static final Set<String> BONUS_KEYWORDS = new HashSet<>(Arrays.asList(
        "spor", "sporuri", "bonus", "bonusuri", "beneficiu", "beneficii", "prima",
        "prime", "stimulent", "stimulente", "avantaj", "compensare", "extra",
        "supliment", "recompensa", "incentive", "facilitate", "premiu"
    ));
    
    // Penalty/sanction keywords
    private static final Set<String> PENALTY_KEYWORDS = new HashSet<>(Arrays.asList(
        "penalizare", "penalizari", "sanctiune", "sanctiuni", "pedeapsa", "pedepse",
        "amenda", "amenzi", "avertisment", "disciplinar", "disciplina", "retinere",
        "taiere", "reducere", "suspendare", "restrictie", "sanctionare"
    ));
    
    // Resignation keywords
    private static final Set<String> RESIGNATION_KEYWORDS = new HashSet<>(Arrays.asList(
        "demisie", "demisii", "plecare", "plecari", "renuntare", "parasire", "retragere",
        "incheierea contractului", "terminarea contractului", "preaviz", "notificare",
        "renuntare", "abandon", "despartire", "exit", "quit"
    ));
    
    // Firing/termination keywords
    private static final Set<String> FIRING_KEYWORDS = new HashSet<>(Arrays.asList(
        "concediere", "concedieri", "desfacere", "terminare", "incetare", "incetari", 
        "disponibilizare", "eliberare", "excludere", "eliminare", "restructurare",
        "reducere", "renuntare", "destituire", "inlaturare", "dizolvare"
    ));
    
    // Project keywords
    private static final Set<String> PROJECT_KEYWORDS = new HashSet<>(Arrays.asList(
        "proiect", "proiecte", "initiativa", "initiativă", "lucrare", "campanie", 
        "program", "task", "taskuri", "obiectiv", "milestone", "dezvoltare", "implementare",
        "constructie", "plan", "strategie", "misiune", "activitate"
    ));
    
    // Team keywords
    private static final Set<String> TEAM_KEYWORDS = new HashSet<>(Arrays.asList(
        "echipa", "echipe", "grup", "grupuri", "formatie", "divizie", "unitate", 
        "celula", "department", "sectie", "colectiv", "staff", "personal", "membri",
        "colaboratori", "coechipieri", "squad", "tribu"
    ));
    
    // Status keywords
    private static final Set<String> STATUS_KEYWORDS = new HashSet<>(Arrays.asList(
        "status", "stare", "situatie", "situația", "etapa", "faza", "stagiu", "progres",
        "evolutie", "stadiu", "conditie", "nivel", "categorie", "clasificare", "starea",
        "pozitie", "rang", "statut", "starea actuala", "etapa curenta"
    ));
    
    // Time-related keywords
    private static final Set<String> TIME_KEYWORDS = new HashSet<>(Arrays.asList(
        "an", "ani", "luna", "luni", "saptamana", "saptamani", "zi", "zile", "data",
        "perioada", "durata", "termen", "interval", "moment", "calendar", "cronologie",
        "istoric", "trecut", "prezent", "viitor", "actual", "curent", "recent"
    ));
    
    // Known department names for direct matching
    private static final Map<String, String> KNOWN_DEPARTMENTS = new HashMap<>();
    static {
        KNOWN_DEPARTMENTS.put("hr", "HR");
        KNOWN_DEPARTMENTS.put("resurse umane", "HR");
        KNOWN_DEPARTMENTS.put("it", "IT");
        KNOWN_DEPARTMENTS.put("tehnologia informatiei", "IT");
        KNOWN_DEPARTMENTS.put("informatica", "IT");
        KNOWN_DEPARTMENTS.put("finante", "Finante");
        KNOWN_DEPARTMENTS.put("financiar", "Finante");
        KNOWN_DEPARTMENTS.put("contabilitate", "Finante");
        KNOWN_DEPARTMENTS.put("marketing", "Marketing");
        KNOWN_DEPARTMENTS.put("vanzari", "Vanzari");
        KNOWN_DEPARTMENTS.put("juridic", "Juridic");
        KNOWN_DEPARTMENTS.put("legal", "Juridic");
        KNOWN_DEPARTMENTS.put("productie", "Productie");
        KNOWN_DEPARTMENTS.put("logistica", "Logistica");
        KNOWN_DEPARTMENTS.put("achizitii", "Achizitii");
        KNOWN_DEPARTMENTS.put("cercetare", "Cercetare si Dezvoltare");
        KNOWN_DEPARTMENTS.put("dezvoltare", "Cercetare si Dezvoltare");
        KNOWN_DEPARTMENTS.put("cercetare si dezvoltare", "Cercetare si Dezvoltare");
        KNOWN_DEPARTMENTS.put("customer support", "Customer Support");
        KNOWN_DEPARTMENTS.put("suport clienti", "Customer Support");
        KNOWN_DEPARTMENTS.put("administrativ", "Administrativ");
        KNOWN_DEPARTMENTS.put("comunicare", "Comunicare");
        KNOWN_DEPARTMENTS.put("pr", "Comunicare");
        KNOWN_DEPARTMENTS.put("training", "Training");
        KNOWN_DEPARTMENTS.put("formare", "Training");
        KNOWN_DEPARTMENTS.put("instruire", "Training");
        KNOWN_DEPARTMENTS.put("security", "Security");
        KNOWN_DEPARTMENTS.put("securitate", "Security");
        KNOWN_DEPARTMENTS.put("management", "Management");
        KNOWN_DEPARTMENTS.put("conducere", "Management");
        KNOWN_DEPARTMENTS.put("business intelligence", "Business Intelligence");
        KNOWN_DEPARTMENTS.put("control intern", "Control Intern");
        KNOWN_DEPARTMENTS.put("servicii generale", "Servicii Generale");
    }

    /**
     * Translate a natural language query to SQL
     * @param naturalLanguageQuery The query in natural language
     * @return QueryInfo object containing SQL query and metadata
     */
    public QueryInfo translateToSQL(String naturalLanguageQuery) {
        // Normalize the text for easier processing
        String normalizedQuery = normalizeText(naturalLanguageQuery);
        
        QueryInfo queryInfo = new QueryInfo();
        
        // Check if this is a follow-up question
        if (isFollowUp(normalizedQuery)) {
            queryInfo.setFollowUp(true);
            return queryInfo;
        }
        
        // Check if this is a stop request
        if (isStopRequest(normalizedQuery)) {
            queryInfo.setStopRequest(true);
            return queryInfo;
        }
        
        // Identify the query type (COUNT, MINMAX, LIST)
        queryInfo.setQueryType(identifyQueryType(normalizedQuery));
        
        // Identify entities mentioned in the query
        Map<String, String> entities = identifyEntities(normalizedQuery);
        queryInfo.setEntities(entities);
        
        // Identify requested attributes
        List<String> requestedAttributes = identifyRequestedAttributes(normalizedQuery);
        queryInfo.setRequestedAttributes(requestedAttributes);
        
        // Generate SQL query based on entities and query type
        String sqlQuery = generateSQLQuery(queryInfo);
        queryInfo.setSqlQuery(sqlQuery);
        
        return queryInfo;
    }
    
    /**
     * Normalize text for processing (lowercase, remove diacritics, standardize separators)
     */
    private String normalizeText(String text) {
        String result = text.toLowerCase().trim();
        
        // Remove diacritics
        result = result.replace("ă", "a")
                       .replace("â", "a")
                       .replace("î", "i")
                       .replace("ș", "s")
                       .replace("ș", "s")
                       .replace("ț", "t")
                       .replace("ț", "t");
        
        // Standardize separators (-, ., _)
        result = result.replace("-", " ")
                       .replace(".", " ")
                       .replace("_", " ")
                       .replace(",", " ")
                       .replace(":", " ")
                       .replace(";", " ")
                       .replace("?", " ")
                       .replace("!", " ");
        
        // Replace multiple spaces with a single space
        result = result.replaceAll("\\s+", " ");
        
        return result;
    }
    
    /**
     * Check if the text is a follow-up question
     */
    private boolean isFollowUp(String text) {
        for (String keyword : FOLLOWUP_KEYWORDS) {
            if (text.equals(keyword) || text.startsWith(keyword + " ") || 
                text.contains(" " + keyword + " ")) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Check if the text is a request to stop
     */
    private boolean isStopRequest(String text) {
        for (String keyword : STOP_KEYWORDS) {
            if (text.equals(keyword) || text.startsWith(keyword + " ") || 
                text.contains(" " + keyword + " ")) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Identify the type of query (COUNT, MINMAX, LIST)
     */
    private QueryType identifyQueryType(String text) {
        // Check for COUNT type queries
        for (String keyword : COUNT_KEYWORDS) {
            if (text.contains(keyword)) {
                return QueryType.COUNT;
            }
        }
        
        // Check for MINMAX type queries
        for (String keyword : MINMAX_KEYWORDS) {
            if (text.contains(keyword)) {
                return QueryType.MINMAX;
            }
        }
        
        // Check for LIST type queries (default to this if no other type matches)
        for (String keyword : LIST_KEYWORDS) {
            if (text.contains(keyword)) {
                return QueryType.LIST;
            }
        }
        
        // Default to LIST type
        return QueryType.LIST;
    }
    
    /**
     * Identify entities mentioned in the query with improved context-awareness and question pattern recognition
     */
    private Map<String, String> identifyEntities(String text) {
        Map<String, String> entities = new HashMap<>();
        
        // Detectare pentru întrebări de tipul "Care departament are cei mai mulți angajați?"
        // Evitând confuzia dintre verbul "are" și numele unui departament
        Pattern careDepartamentPattern = Pattern.compile("care\\s+departament(e)?\\s+are", Pattern.CASE_INSENSITIVE);
        Matcher careDepartamentMatcher = careDepartamentPattern.matcher(text);
        
        if (careDepartamentMatcher.find() && containsAny(text, EMPLOYEE_KEYWORDS)) {
            // Este o întrebare despre care departament are cei mai mulți angajați
            entities.put("entity", "department");
            entities.put("question_type", "max_employees");
            return entities;
        }
        
        // Detectare pentru întrebări de tipul "Care sediu are cei mai mulți angajați?"
        Pattern careSediuPattern = Pattern.compile("care\\s+sediu(ri)?\\s+are", Pattern.CASE_INSENSITIVE);
        Matcher careSediuMatcher = careSediuPattern.matcher(text);
        
        if (careSediuMatcher.find() && containsAny(text, EMPLOYEE_KEYWORDS)) {
            entities.put("entity", "office");
            entities.put("question_type", "max_employees");
            return entities;
        }
        
        // Detectare pentru întrebări de tipul "Care angajat are cele mai multe concedii?"
        Pattern careAngajatPattern = Pattern.compile("care\\s+angajat(i)?\\s+are", Pattern.CASE_INSENSITIVE);
        Matcher careAngajatMatcher = careAngajatPattern.matcher(text);
        
        if (careAngajatMatcher.find() && containsAny(text, LEAVE_KEYWORDS)) {
            entities.put("entity", "employee");
            entities.put("question_type", "max_leaves");
            return entities;
        }
        
        // First, check for specific combinations that should be prioritized
        
        // Case: "angajați în/din departamentul X" - Employee in Department context
        if ((containsAny(text, EMPLOYEE_KEYWORDS) && containsAny(text, DEPARTMENT_KEYWORDS)) &&
            (text.contains("in departament") || text.contains("din departament") || 
             text.contains("departamentul") || text.contains("din cadrul"))) {
            
            entities.put("entity", "employee");
            
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            // If no specific department found, try regex pattern
            if (!entities.containsKey("department_name")) {
                Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(text);
                
                if (matcher.find()) {
                    entities.put("department_name", matcher.group(1));
                }
            }
            
            return entities;
        }
        
        // Case: "concedii în/din departamentul X" - Leave in Department context
        if ((containsAny(text, LEAVE_KEYWORDS) && containsAny(text, DEPARTMENT_KEYWORDS)) &&
            (text.contains("in departament") || text.contains("din departament") || 
             text.contains("departamentul") || text.contains("din cadrul"))) {
            
            entities.put("entity", "leave");
            
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            return entities;
        }
        
        // After handling special contexts, proceed with regular entity identification
        
        // Check for counting queries about specific entities
        if (containsAny(text, COUNT_KEYWORDS)) {
            if (containsAny(text, EMPLOYEE_KEYWORDS)) {
                entities.put("entity", "employee");
                
                // Check for specific department mention
                for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                    if (text.contains(entry.getKey())) {
                        entities.put("department_name", entry.getValue());
                        break;
                    }
                }
                return entities;
            } else if (containsAny(text, LEAVE_KEYWORDS)) {
                entities.put("entity", "leave");
                
                // Check for specific department mention
                for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                    if (text.contains(entry.getKey())) {
                        entities.put("department_name", entry.getValue());
                        break;
                    }
                }
                return entities;
            } else if (containsAny(text, PROJECT_KEYWORDS)) {
                entities.put("entity", "project");
                return entities;
            }
        }
        
     // Detectare pentru interogări despre locațiile departamentelor
        if (containsAny(text, LOCATION_KEYWORDS) && containsAny(text, DEPARTMENT_KEYWORDS)) {
            entities.put("entity", "locatii_departamente");
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            // If no specific department found, try regex pattern
            if (!entities.containsKey("department_name")) {
                Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(text);
                
                if (matcher.find()) {
                    entities.put("department_name", matcher.group(1));
                }
            }
         
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } 
            
            
        
     // Detectare pentru interogări despre locațiile departamentelor
        if (containsAny(text, LOCATION_KEYWORDS) && containsAny(text, EMPLOYEE_KEYWORDS)) {
            entities.put("entity", "locatii_useri");
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            // If no specific department found, try regex pattern
            if (!entities.containsKey("department_name")) {
                Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(text);
                
                if (matcher.find()) {
                    entities.put("department_name", matcher.group(1));
                }
            }
         
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        }
        
     // Detectare pentru interogări despre locațiile departamentelor
        if (containsAny(text, LOCATION_KEYWORDS) && containsAny(text, LEAVE_KEYWORDS)) {
            entities.put("entity", "locatii_concedii");
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            // If no specific department found, try regex pattern
            if (!entities.containsKey("department_name")) {
                Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(text);
                
                if (matcher.find()) {
                    entities.put("department_name", matcher.group(1));
                }
            }
         
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        }
        
        // Standard entity detection (unchanged from original)
        if (containsAny(text, DEPARTMENT_KEYWORDS)) {
            entities.put("entity", "department");
            
            // Try to identify specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
            
            // If no specific department found, try regex pattern
            if (!entities.containsKey("department_name")) {
                Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
                Matcher matcher = pattern.matcher(text);
                
                if (matcher.find()) {
                    entities.put("department_name", matcher.group(1));
                }
            }
        } else if (containsAny(text, EMPLOYEE_KEYWORDS)) {
            entities.put("entity", "employee");
            
            // Check for specific department mention
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } else if (containsAny(text, LEAVE_KEYWORDS)) {
            entities.put("entity", "leave");
            
            // Identify leave period if mentioned
            if (text.contains("craciun") || text.contains("crăciun")) {
                entities.put("period", "christmas");
            } else if (text.contains("vara") || text.contains("vară")) {
                entities.put("period", "summer");
            } else if (text.contains("iarna") || text.contains("iarnă")) {
                entities.put("period", "winter");
            } else if (text.contains("paste") || text.contains("paște")) {
                entities.put("period", "easter");
            }
            
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } else if (containsAny(text, POSITION_KEYWORDS)) {
            entities.put("entity", "tipuri_pozitii");
            
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } else if (containsAny(text, SALARY_KEYWORDS)) {
            entities.put("entity", "tipuri");
            
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } else if (containsAny(text, CERTIFICATE_KEYWORDS)) {
            entities.put("entity", "adeverinte");
            
            // Check for specific department
            for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
                if (text.contains(entry.getKey())) {
                    entities.put("department_name", entry.getValue());
                    break;
                }
            }
        } else if (containsAny(text, OFFICE_KEYWORDS)) {
            entities.put("entity", "sedii");
        } else if (containsAny(text, PROJECT_KEYWORDS)) {
            entities.put("entity", "proiecte");
            
            // Check if active/current projects are requested
            if (text.contains("active") || text.contains("curente") || 
                text.contains("actuale") || text.contains("in desfasurare") ||
                text.contains("în desfășurare")) {
                entities.put("status", "active");
            }
        } else if (containsAny(text, TEAM_KEYWORDS)) {
            entities.put("entity", "echipa");
        } else if (containsAny(text, FIRM_KEYWORDS)) {
            entities.put("entity", "useri");
        } else {
            // Default to employee if no specific entity is identified
            entities.put("entity", "useri");
        }
        
        return entities;
    }
    
    /**
     * Identify attributes specifically requested in the query
     */
    private List<String> identifyRequestedAttributes(String text) {
        List<String> attributes = new ArrayList<>();
        
        // Common attributes to look for
        Map<String, String> attributeMap = new HashMap<>();
        attributeMap.put("nume", "nume");
        attributeMap.put("prenume", "prenume");
        attributeMap.put("data nasterii", "data_nasterii");
        attributeMap.put("data nașterii", "data_nasterii");
        attributeMap.put("data de nastere", "data_nasterii");
        attributeMap.put("email", "email");
        attributeMap.put("mail", "email");
        attributeMap.put("telefon", "telefon");
        attributeMap.put("numar telefon", "telefon");
        attributeMap.put("numar de telefon", "telefon");
        attributeMap.put("adresa", "adresa");
        attributeMap.put("strada", "strada");
        attributeMap.put("oras", "oras");
        attributeMap.put("oraș", "oras");
        attributeMap.put("judet", "judet");
        attributeMap.put("județ", "judet");
        attributeMap.put("tara", "tara");
        attributeMap.put("țara", "tara");
        attributeMap.put("functie", "functie");
        attributeMap.put("funcție", "functie");
        attributeMap.put("pozitie", "functie");
        attributeMap.put("poziție", "functie");
        attributeMap.put("rol", "functie");
        attributeMap.put("departament", "departament");
        attributeMap.put("salariu", "salariu");
        attributeMap.put("venit", "salariu");
        attributeMap.put("castig", "salariu");
        attributeMap.put("câștig", "salariu");
        attributeMap.put("data angajarii", "data_ang");
        attributeMap.put("data angajării", "data_ang");
        attributeMap.put("data de angajare", "data_ang");
        attributeMap.put("sediu", "sediu");
        attributeMap.put("echipa", "echipa");
        attributeMap.put("echipă", "echipa");
        attributeMap.put("status", "status");
        attributeMap.put("stare", "status");
        
        // Check for each attribute in the normalized text
        for (Map.Entry<String, String> entry : attributeMap.entrySet()) {
            if (text.contains(entry.getKey())) {
                // Add unique attribute names only (avoid duplicates)
                if (!attributes.contains(entry.getValue())) {
                    attributes.add(entry.getValue());
                }
            }
        }
        
        return attributes;
    }
    
    /**
     * Generate SQL query based on identified entities and query type
     */
    private String generateSQLQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String entityType = entities.getOrDefault("entity", "");
        
        // Delegate to specific entity handlers
        switch (entityType) {
            case "department":
                return generateDepartmentQuery(queryInfo);
            case "employee":
                return generateEmployeeQuery(queryInfo);
            case "leave":
                return generateLeaveQuery(queryInfo);
            case "position":
                return generatePositionQuery(queryInfo);
            case "salary":
                return generateSalaryQuery(queryInfo);
            case "certificate":
                return generateCertificateQuery(queryInfo);
            case "office":
                return generateOfficeQuery(queryInfo);
            case "project":
                return generateProjectQuery(queryInfo);
            case "team":
                return generateTeamQuery(queryInfo);
            case "firm":
                return generateFirmQuery(queryInfo);
            default:
                return generateGenericQuery(queryInfo);
        }
    }
    
    /**
     * Generate SQL query for department-related questions
     */
    private String generateDepartmentQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        List<String> attributes = queryInfo.getRequestedAttributes();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_departamente FROM departament");
                
                // Add filters if any specific department is mentioned
                if (entities.containsKey("department_name")) {
                    sql.append(" WHERE UPPER(nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show departments with most/least employees
                sql.append("SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati ");
                sql.append("FROM departament d ");
                sql.append("LEFT JOIN useri u ON d.id_dep = u.id_dep ");
                sql.append("GROUP BY d.nume_dep, d.id_dep ");
                
                // Add filters if needed
                if (entities.containsKey("department_name")) {
                    sql.append("HAVING UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                }
                
                // Order by employee count (ascending or descending based on keywords)
                if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || 
                    queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                    sql.append("ORDER BY COUNT(u.id) ASC");
                } else {
                    sql.append("ORDER BY COUNT(u.id) DESC");
                }
                
                return sql.toString();
                
            case LIST:
                // For LIST, show department details
                if (attributes.isEmpty()) {
                    // Default attributes if none specifically requested
                    sql.append("SELECT d.id_dep, d.nume_dep AS departament, COUNT(u.id) AS numar_angajati ");
                } else {
                    sql.append("SELECT d.id_dep, d.nume_dep AS departament");
                    
                    // Add requested attributes
                    for (String attribute : attributes) {
                        if (!attribute.equals("nume_dep") && !attribute.equals("departament")) {
                            // Handle special attributes for departament entity
                            if (attribute.equals("adresa")) {
                                sql.append(", CONCAT(ld.strada, ', ', ld.oras, ', ', ld.judet, ', ', ld.tara) AS adresa");
                            } else if (attribute.equals("strada") || attribute.equals("oras") || 
                                       attribute.equals("judet") || attribute.equals("tara")) {
                                sql.append(", ld.").append(attribute).append(" AS ").append(attribute);
                            }
                        }
                    }
                    
                    // Always include employee count if not explicitly requested
                    if (!attributes.contains("numar_angajati")) {
                        sql.append(", COUNT(u.id) AS numar_angajati");
                    }
                }
                
                sql.append(" FROM departament d ");
                sql.append("LEFT JOIN useri u ON d.id_dep = u.id_dep ");
                
                // Add location data join if needed
                if (attributes.contains("adresa") || attributes.contains("strada") || 
                    attributes.contains("oras") || attributes.contains("judet") || 
                    attributes.contains("tara")) {
                    sql.append("LEFT JOIN locatii_departamente ld ON d.id_dep = ld.id_dep ");
                }
                
                // Add filters
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                }
                
                sql.append("GROUP BY d.id_dep, d.nume_dep");
                
                // Add location columns to GROUP BY if needed
                if (attributes.contains("adresa") || attributes.contains("strada") || 
                    attributes.contains("oras") || attributes.contains("judet") || 
                    attributes.contains("tara")) {
                    sql.append(", ld.strada, ld.oras, ld.judet, ld.tara");
                }
                
                sql.append(" ORDER BY d.nume_dep");
                
                return sql.toString();
                
            default:
                // Default to a simple list of departments
                return "SELECT id_dep, nume_dep AS departament FROM departament ORDER BY nume_dep";
        }
    }
    
    /**
     * Generate SQL query for employee-related questions
     */
    private String generateEmployeeQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        List<String> attributes = queryInfo.getRequestedAttributes();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_angajati FROM useri u");
                
                // Add joins and filters if needed
                if (entities.containsKey("department_name")) {
                    sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                    sql.append(" WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                } else if (queryInfo.toString().contains("activ")) {
                    sql.append(" WHERE u.activ = 1");
                } else if (queryInfo.toString().contains("inactiv")) {
                    sql.append(" WHERE u.activ = 0");
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show employees with highest/lowest salaries, seniority, etc.
                sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie, t.salariu, ");
                
                // Include data based on what's being asked (salary, seniority, etc.)
                if (queryInfo.toString().contains("vechime") || queryInfo.toString().contains("experienta")) {
                    sql.append("TIMESTAMPDIFF(YEAR, u.data_ang, CURDATE()) AS ani_vechime ");
                } else {
                    sql.append("t.salariu ");
                }
                
                sql.append("FROM useri u ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                
                // Add filters if needed
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                }
                
                // Order based on criteria
                if (queryInfo.toString().contains("vechime") || queryInfo.toString().contains("experienta")) {
                    // Order by seniority
                    if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || queryInfo.toString().contains("min") || queryInfo.toString().contains("minim") || queryInfo.toString().contains("minimul") ||  
                            queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine") ||
                        queryInfo.toString().contains("recent")) {
                        sql.append("ORDER BY u.data_ang DESC "); // most recent hires first
                    } else {
                        sql.append("ORDER BY u.data_ang ASC "); // oldest hires first
                    }
                } else {
                    // Default to ordering by salary
                    if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || 
                        queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                        sql.append("ORDER BY t.salariu ASC ");
                    } else {
                        sql.append("ORDER BY t.salariu DESC ");
                    }
                }
                
                // Limit to 10 results by default
                sql.append("LIMIT 1");
                
                return sql.toString();
                
            case LIST:
                // For LIST, show employee details
                sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie");
                
                // Add requested attributes
                if (!attributes.isEmpty()) {
                    // Check for each possible attribute
                    if (attributes.contains("email") || queryInfo.toString().contains("mail")) {
                        sql.append(", u.email");
                    }
                    if (attributes.contains("telefon")) {
                        sql.append(", u.telefon");
                    }
                    if (attributes.contains("data_nasterii")) {
                        sql.append(", u.data_nasterii");
                    }
                    if (attributes.contains("data_ang")) {
                        sql.append(", u.data_ang AS data_angajare");
                    }
                    if (attributes.contains("adresa")) {
                        sql.append(", u.adresa");
                    }
                    if (attributes.contains("salariu")) {
                        sql.append(", t.salariu");
                    }
                    if (attributes.contains("sediu")) {
                        sql.append(", s.nume_sediu AS sediu");
                    }
                    if (attributes.contains("echipa")) {
                        sql.append(", e.nume AS echipa");
                    }
                } else {
                    // Default to including basic contact info
                    sql.append(", u.email, u.telefon");
                }
                
                sql.append(" FROM useri u");
                sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                sql.append(" LEFT JOIN tipuri t ON u.tip = t.tip");
                
                // Add additional joins if needed
                if (attributes.contains("sediu")) {
                    sql.append(" LEFT JOIN sedii s ON u.id_sediu = s.id_sediu");
                }
                if (attributes.contains("echipa")) {
                    sql.append(" LEFT JOIN echipe e ON u.id_echipa = e.id");
                }
                
                // Add filters
                boolean hasWhere = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append(" WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                    hasWhere = true;
                }
                
                if (queryInfo.toString().contains("activ")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("u.activ = 1");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("inactiv")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("u.activ = 0");
                    hasWhere = true;
                }
                
                // Position filters
                if (queryInfo.toString().contains("director")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("LOWER(t.denumire) LIKE '%director%'");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("manager")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("LOWER(t.denumire) LIKE '%manager%'");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("sef") || queryInfo.toString().contains("șef")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("LOWER(t.denumire) LIKE '%sef%'");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("intern")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("LOWER(t.denumire) LIKE '%intern%'");
                    hasWhere = true;
                }
                
                // Order by name
                sql.append(" ORDER BY u.nume, u.prenume");
                
                return sql.toString();
                
            default:
                // Default to a simple list of employees
                return "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, u.email, u.telefon FROM useri u LEFT JOIN departament d ON u.id_dep = d.id_dep LEFT JOIN tipuri t ON u.tip = t.tip ORDER BY u.nume, u.prenume";
        }
    }
    
    /**
     * Generate SQL query for leave-related questions
     */
    private String generateLeaveQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_concedii FROM concedii c");
                
                // Add joins and filters if needed
                boolean hasJoin = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append(" LEFT JOIN useri u ON c.id_ang = u.id");
                    sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                    hasJoin = true;
                }
                
                boolean hasWhere = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append(" WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                    hasWhere = true;
                }
                
                // Time period filters
                if (entities.containsKey("period")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    
                    switch (entities.get("period")) {
                        case "christmas":
                            sql.append("c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24'");
                            break;
                        case "summer":
                            sql.append("(MONTH(c.start_c) BETWEEN 6 AND 8 OR MONTH(c.end_c) BETWEEN 6 AND 8)");
                            break;
                        case "winter":
                            sql.append("(MONTH(c.start_c) IN (12, 1, 2) OR MONTH(c.end_c) IN (12, 1, 2))");
                            break;
                        case "easter":
                            sql.append("(MONTH(c.start_c) = 4 OR MONTH(c.end_c) = 4)");
                            break;
                    }
                    
                    hasWhere = true;
                } else if (queryInfo.toString().contains("astazi") || queryInfo.toString().contains("azi")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("CURDATE() BETWEEN c.start_c AND c.end_c");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("luna") || queryInfo.toString().contains("curent")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("an") || queryInfo.toString().contains("anul")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("YEAR(c.start_c) = YEAR(CURDATE())");
                    hasWhere = true;
                }
                
                // Status filters
                if (queryInfo.toString().contains("aprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status IN (1, 2)");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("neaprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status = 0");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("respins") || queryInfo.toString().contains("dezaprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status IN (-1, -2)");
                    hasWhere = true;
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show longest/shortest leaves
                sql.append("SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("c.start_c, c.end_c, c.motiv, c.durata ");
                sql.append("FROM concedii c ");
                sql.append("LEFT JOIN useri u ON c.id_ang = u.id ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                
                // Add filters
                hasWhere = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                    hasWhere = true;
                }
                
                // Time period filters
                if (entities.containsKey("period")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    
                    switch (entities.get("period")) {
                        case "christmas":
                            sql.append("c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24'");
                            break;
                        case "summer":
                            sql.append("(MONTH(c.start_c) BETWEEN 6 AND 8 OR MONTH(c.end_c) BETWEEN 6 AND 8)");
                            break;
                        case "winter":
                            sql.append("(MONTH(c.start_c) IN (12, 1, 2) OR MONTH(c.end_c) IN (12, 1, 2))");
                            break;
                        case "easter":
                            sql.append("(MONTH(c.start_c) = 4 OR MONTH(c.end_c) = 4)");
                            break;
                    }
                    
                    hasWhere = true;
                } else if (queryInfo.toString().contains("an") || queryInfo.toString().contains("anul")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("YEAR(c.start_c) = YEAR(CURDATE())");
                    hasWhere = true;
                }
                
                // Order by duration (ascending or descending)
                if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || queryInfo.toString().contains("min") || queryInfo.toString().contains("minim") || queryInfo.toString().contains("minimul") ||  
                        queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                    sql.append(" ORDER BY c.durata ASC");
                } else {
                    sql.append(" ORDER BY c.durata DESC");
                }
                
                // Limit to 10 results
                sql.append(" LIMIT 1");
                
                return sql.toString();
                
            case LIST:
                // For LIST, show leave details
                sql.append("SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, ");
                sql.append("s.nume_status AS status, c.durata, tc.motiv AS tip_concediu ");
                sql.append("FROM concedii c ");
                sql.append("LEFT JOIN useri u ON c.id_ang = u.id ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                sql.append("LEFT JOIN statusuri s ON c.status = s.status ");
                sql.append("LEFT JOIN tipcon tc ON c.tip = tc.tip ");
                
                // Add filters
                hasWhere = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                    hasWhere = true;
                }
                
                // Time period filters
                if (entities.containsKey("period")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    
                    switch (entities.get("period")) {
                        case "christmas":
                            sql.append("c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24'");
                            break;
                        case "summer":
                            sql.append("(MONTH(c.start_c) BETWEEN 6 AND 8 OR MONTH(c.end_c) BETWEEN 6 AND 8)");
                            break;
                        case "winter":
                            sql.append("(MONTH(c.start_c) IN (12, 1, 2) OR MONTH(c.end_c) IN (12, 1, 2))");
                            break;
                        case "easter":
                            sql.append("(MONTH(c.start_c) = 4 OR MONTH(c.end_c) = 4)");
                            break;
                    }
                    
                    hasWhere = true;
                } else if (queryInfo.toString().contains("astazi") || queryInfo.toString().contains("azi")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("CURDATE() BETWEEN c.start_c AND c.end_c");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("luna") || queryInfo.toString().contains("curent")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("an") || queryInfo.toString().contains("anul")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("YEAR(c.start_c) = YEAR(CURDATE())");
                    hasWhere = true;
                }
                
                // Status filters
                if (queryInfo.toString().contains("aprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status IN (1, 2)");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("neaprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status = 0");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("respins") || queryInfo.toString().contains("dezaprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("c.status IN (-1, -2)");
                    hasWhere = true;
                }
                
                // Order by start date (most recent first)
                sql.append(" ORDER BY c.start_c DESC");
                
                return sql.toString();
                
            default:
                // Default to a list of ongoing leaves
                return "SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.durata FROM concedii c LEFT JOIN useri u ON c.id_ang = u.id LEFT JOIN departament d ON u.id_dep = d.id_dep LEFT JOIN tipuri t ON u.tip = t.tip WHERE CURDATE() BETWEEN c.start_c AND c.end_c ORDER BY c.start_c DESC";
        }
    }
    
    /**
     * Generate SQL query for position/role-related questions
     */
    private String generatePositionQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                if (entities.containsKey("department_name")) {
                    sql.append("SELECT COUNT(DISTINCT t.tip) AS numar_pozitii ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                } else {
                    sql.append("SELECT COUNT(DISTINCT tip) AS numar_pozitii FROM tipuri");
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show highest/lowest paid positions
                sql.append("SELECT t.tip, t.denumire, t.salariu, d.nume_dep AS departament_specific ");
                sql.append("FROM tipuri t ");
                sql.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                
                // Add filters
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE t.departament_specific IN (SELECT id_dep FROM departament WHERE UPPER(nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%'))");
                }
                
                // Order by salary (ascending or descending)
                if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || queryInfo.toString().contains("min") || queryInfo.toString().contains("minim") || queryInfo.toString().contains("minimul") ||  
                    queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                    sql.append(" ORDER BY t.salariu ASC");
                } else {
                    sql.append(" ORDER BY t.salariu DESC");
                }
                
                // Limit to top 10
                sql.append(" LIMIT 1");
                
                return sql.toString();
                
            case LIST:
                // For LIST, show position details
                if (entities.containsKey("department_name")) {
                    sql.append("SELECT DISTINCT t.tip, t.denumire, t.salariu, t.ierarhie, ");
                    sql.append("d.nume_dep AS departament, dp.denumire_completa ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                    sql.append("LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                    sql.append("ORDER BY t.ierarhie, t.denumire");
                } else {
                    sql.append("SELECT t.tip, t.denumire, t.salariu, t.ierarhie, ");
                    sql.append("d.nume_dep AS departament_specific ");
                    sql.append("FROM tipuri t ");
                    sql.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                    sql.append("ORDER BY t.ierarhie, t.tip");
                }
                
                return sql.toString();
                
            default:
                // Default to a list of all positions
                return "SELECT tip, denumire, salariu, ierarhie FROM tipuri ORDER BY ierarhie, denumire";
        }
    }
    
    /**
     * Generate SQL query for salary-related questions
     */
    private String generateSalaryQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                // For COUNT, calculate average salary
                sql.append("SELECT AVG(t.salariu) AS salariu_mediu ");
                sql.append("FROM tipuri t ");
                
                if (entities.containsKey("department_name")) {
                    sql.append("LEFT JOIN useri u ON t.tip = u.tip ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show highest/lowest salaries
                sql.append("SELECT t.denumire, t.salariu ");
                sql.append("FROM tipuri t ");
                
                // Add filters
                if (entities.containsKey("department_name")) {
                    sql.append("LEFT JOIN useri u ON t.tip = u.tip ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                    sql.append("GROUP BY t.denumire, t.salariu ");
                }
                
                // Order by salary (ascending or descending)
                if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || 
                    queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                    sql.append("ORDER BY t.salariu ASC");
                } else {
                    sql.append("ORDER BY t.salariu DESC");
                }
                
                // Limit to top 10
                sql.append(" LIMIT 1");
                
                return sql.toString();
                
            case LIST:
                // For LIST, show salary details by position
                sql.append("SELECT t.denumire, t.salariu, COUNT(u.id) AS numar_angajati ");
                sql.append("FROM tipuri t ");
                sql.append("LEFT JOIN useri u ON t.tip = u.tip ");
                
                if (entities.containsKey("department_name")) {
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                }
                
                sql.append("GROUP BY t.denumire, t.salariu ");
                sql.append("ORDER BY t.salariu DESC");
                
                return sql.toString();
                
            default:
                // Default to list of positions with salaries
                return "SELECT t.denumire, t.salariu FROM tipuri t ORDER BY t.salariu DESC";
        }
    }
    
   // Continuing from where we left off...

    /**
     * Generate SQL query for certificate/document-related questions (continued)
     */
    private String generateCertificateQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_adeverinte FROM adeverinte a");
                
                // Add joins and filters if needed
                if (entities.containsKey("department_name")) {
                    sql.append(" LEFT JOIN useri u ON a.id_ang = u.id");
                    sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                    sql.append(" WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                }
                
                return sql.toString();
                
            case LIST:
                // For LIST, show certificate details
                sql.append("SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, ");
                sql.append("a.creare AS data_creare, a.modif AS data_modificare, ");
                sql.append("u.nume, u.prenume, d.nume_dep AS departament ");
                sql.append("FROM adeverinte a ");
                sql.append("LEFT JOIN tip_adev ta ON a.tip = ta.id ");
                sql.append("LEFT JOIN statusuri s ON a.status = s.status ");
                sql.append("LEFT JOIN useri u ON a.id_ang = u.id ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                
                // Add filters
                boolean hasWhere = false;
                
                if (entities.containsKey("department_name")) {
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                    hasWhere = true;
                }
                
                // Status filters
                if (queryInfo.toString().contains("aprobat")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("a.status = 2");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("neaprobat") || queryInfo.toString().contains("asteptare")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("a.status = 0");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("respins")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("a.status < 0");
                    hasWhere = true;
                }
                
                // Time filters
                if (queryInfo.toString().contains("astazi") || queryInfo.toString().contains("azi")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("DATE(a.creare) = CURDATE()");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("luna") || queryInfo.toString().contains("luna aceasta")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("MONTH(a.creare) = MONTH(CURDATE()) AND YEAR(a.creare) = YEAR(CURDATE())");
                    hasWhere = true;
                } else if (queryInfo.toString().contains("an") || queryInfo.toString().contains("anul acesta")) {
                    sql.append(hasWhere ? " AND " : " WHERE ");
                    sql.append("YEAR(a.creare) = YEAR(CURDATE())");
                    hasWhere = true;
                }
                
                // Sort by creation date
                sql.append(" ORDER BY a.creare DESC");
                
                return sql.toString();
                
            default:
                return "SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, a.creare AS data_creare, a.modif AS data_modificare, u.nume, u.prenume, d.nume_dep AS departament FROM adeverinte a LEFT JOIN tip_adev ta ON a.tip = ta.id LEFT JOIN statusuri s ON a.status = s.status LEFT JOIN useri u ON a.id_ang = u.id LEFT JOIN departament d ON u.id_dep = d.id_dep ORDER BY a.creare DESC";
        }
    }
    
    /**
     * Generate SQL query for office-related questions
     */
    private String generateOfficeQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_sedii FROM sedii");
                return sql.toString();
                
            case LIST:
                sql.append("SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, ");
                sql.append("telefon, email, data_creare ");
                sql.append("FROM sedii ");
                sql.append("ORDER BY tip_sediu, nume_sediu");
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, perhaps show the oldest/newest offices
                sql.append("SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, ");
                sql.append("telefon, email, data_creare ");
                sql.append("FROM sedii ");
                
                // Order by creation date (newest or oldest first)
                if (queryInfo.toString().contains("vechi") || 
                    queryInfo.toString().contains("primul") || 
                    queryInfo.toString().contains("primul infiintat")) {
                    sql.append("ORDER BY data_creare ASC");
                } else {
                    sql.append("ORDER BY data_creare DESC");
                }
                
                return sql.toString();
                
            default:
                return "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, telefon, email FROM sedii ORDER BY tip_sediu, nume_sediu";
        }
    }
    
    /**
     * Generate SQL query for project-related questions
     */
    private String generateProjectQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_proiecte FROM proiecte");
                
                // Add active filter if requested
                if ("active".equals(entities.get("status"))) {
                    sql.append(" WHERE start <= CURDATE() AND (end >= CURDATE() OR end IS NULL)");
                }
                
                return sql.toString();
                
            case LIST:
                // Check if we're asking about tasks
                if (queryInfo.toString().contains("task") || queryInfo.toString().contains("sarcina") ||
                    queryInfo.toString().contains("sarcini")) {
                    
                    sql.append("SELECT t.id, t.nume AS nume_task, p.nume AS nume_proiect, ");
                    sql.append("u.nume AS nume_angajat, u.prenume AS prenume_angajat, ");
                    sql.append("s.procent AS procent_finalizare, t.start AS data_inceput, t.end AS data_sfarsit ");
                    sql.append("FROM tasks t ");
                    sql.append("LEFT JOIN proiecte p ON t.id_prj = p.id ");
                    sql.append("LEFT JOIN useri u ON t.id_ang = u.id ");
                    sql.append("LEFT JOIN statusuri2 s ON t.status = s.id ");
                    
                    // Filter for incomplete/complete tasks
                    if (queryInfo.toString().contains("neterminat") || 
                        queryInfo.toString().contains("incomplet") || 
                        queryInfo.toString().contains("in progres")) {
                        sql.append("WHERE s.procent < 100 ");
                    } else if (queryInfo.toString().contains("terminat") || 
                              queryInfo.toString().contains("complet") || 
                              queryInfo.toString().contains("finalizat")) {
                        sql.append("WHERE s.procent = 100 ");
                    }
                    
                    sql.append("ORDER BY t.end");
                    
                } else if (queryInfo.toString().contains("cine") || 
                          queryInfo.toString().contains("lucreaza") || 
                          queryInfo.toString().contains("lucrează") || 
                          queryInfo.toString().contains("angajat")) {
                    
                    // Who works on projects
                    sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                    sql.append("p.nume AS nume_proiect, e.nume AS nume_echipa ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN tasks t ON t.id_ang = u.id ");
                    sql.append("LEFT JOIN proiecte p ON t.id_prj = p.id ");
                    sql.append("LEFT JOIN echipe e ON e.id_prj = p.id ");
                    sql.append("GROUP BY u.id, u.nume, u.prenume, d.nume_dep, p.nume, e.nume ");
                    sql.append("ORDER BY u.nume, u.prenume");
                    
                } else {
                    // Default project list
                    sql.append("SELECT p.id, p.nume, p.descriere, p.start AS data_inceput, p.end AS data_sfarsit, ");
                    sql.append("u.nume AS supervizor_nume, u.prenume AS supervizor_prenume, ");
                    sql.append("(SELECT COUNT(*) FROM echipe WHERE id_prj = p.id) AS numar_echipe, ");
                    sql.append("(SELECT COUNT(*) FROM tasks WHERE id_prj = p.id) AS numar_taskuri ");
                    sql.append("FROM proiecte p ");
                    sql.append("LEFT JOIN useri u ON p.supervizor = u.id ");
                    
                    // Add active filter if requested
                    if ("active".equals(entities.get("status"))) {
                        sql.append("WHERE p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL) ");
                    }
                    
                    sql.append("ORDER BY p.start DESC");
                }
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, perhaps show projects with most/least tasks or team members
                sql.append("SELECT p.id, p.nume, p.descriere, p.start AS data_inceput, p.end AS data_sfarsit, ");
                sql.append("(SELECT COUNT(*) FROM echipe WHERE id_prj = p.id) AS numar_echipe, ");
                sql.append("(SELECT COUNT(*) FROM tasks WHERE id_prj = p.id) AS numar_taskuri ");
                sql.append("FROM proiecte p ");
                
                // Add active filter if requested
                if ("active".equals(entities.get("status"))) {
                    sql.append("WHERE p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL) ");
                }
                
                // Order by task count or team count
                if (queryInfo.toString().contains("task") || 
                    queryInfo.toString().contains("sarcina") || 
                    queryInfo.toString().contains("sarcini")) {
                    
                    if (queryInfo.toString().contains("putine") || 
                        queryInfo.toString().contains("putini") || 
                        queryInfo.toString().contains("mic")) {
                        sql.append("ORDER BY numar_taskuri ASC");
                    } else {
                        sql.append("ORDER BY numar_taskuri DESC");
                    }
                    
                } else {
                    if (queryInfo.toString().contains("putine") || 
                        queryInfo.toString().contains("putini") || 
                        queryInfo.toString().contains("mic")) {
                        sql.append("ORDER BY numar_echipe ASC");
                    } else {
                        sql.append("ORDER BY numar_echipe DESC");
                    }
                }
                
                // Limit to top 5
                sql.append(" LIMIT 5");
                
                return sql.toString();
                
            default:
                return "SELECT p.id, p.nume, p.descriere, p.start AS data_inceput, p.end AS data_sfarsit, u.nume AS supervizor_nume, u.prenume AS supervizor_prenume FROM proiecte p LEFT JOIN useri u ON p.supervizor = u.id ORDER BY p.start DESC";
        }
    }
    
    /**
     * Generate SQL query for team-related questions
     */
    private String generateTeamQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_echipe FROM echipe");
                return sql.toString();
                
            case LIST:
                sql.append("SELECT e.id, e.nume AS nume_echipa, p.nume AS nume_proiect, ");
                sql.append("u.nume AS supervizor_nume, u.prenume AS supervizor_prenume, ");
                sql.append("(SELECT COUNT(*) FROM useri WHERE id_echipa = e.id) AS numar_membri ");
                sql.append("FROM echipe e ");
                sql.append("LEFT JOIN proiecte p ON e.id_prj = p.id ");
                sql.append("LEFT JOIN useri u ON e.supervizor = u.id ");
                sql.append("ORDER BY e.nume");
                
                return sql.toString();
                
            case MINMAX:
                // For MIN/MAX, show teams with most/least members
                sql.append("SELECT e.id, e.nume AS nume_echipa, p.nume AS nume_proiect, ");
                sql.append("u.nume AS supervizor_nume, u.prenume AS supervizor_prenume, ");
                sql.append("(SELECT COUNT(*) FROM useri WHERE id_echipa = e.id) AS numar_membri ");
                sql.append("FROM echipe e ");
                sql.append("LEFT JOIN proiecte p ON e.id_prj = p.id ");
                sql.append("LEFT JOIN useri u ON e.supervizor = u.id ");
                
                // Order by member count
                if (queryInfo.toString().contains("putine") || 
                    queryInfo.toString().contains("putini") || 
                    queryInfo.toString().contains("mica") || 
                    queryInfo.toString().contains("mic")) {
                    sql.append("ORDER BY numar_membri ASC");
                } else {
                    sql.append("ORDER BY numar_membri DESC");
                }
                
                // Limit to top 5
                sql.append(" LIMIT 5");
                
                return sql.toString();
                
            default:
                return "SELECT e.id, e.nume AS nume_echipa, p.nume AS nume_proiect, u.nume AS supervizor_nume, u.prenume AS supervizor_prenume FROM echipe e LEFT JOIN proiecte p ON e.id_prj = p.id LEFT JOIN useri u ON e.supervizor = u.id ORDER BY e.nume";
        }
    }
    
    /**
     * Generate SQL query for firm/company-related questions
     */
    private String generateFirmQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        // Check what other entities are mentioned in the query
        String queryText = queryInfo.toString();
        
        if (containsAny(queryText, EMPLOYEE_KEYWORDS)) {
            // Query about employees across the entire company
            switch (queryType) {
                case COUNT:
                    return "SELECT COUNT(*) AS numar_angajati FROM useri";
                case LIST:
                    return "SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                           "FROM departament d " +
                           "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                           "GROUP BY d.nume_dep, d.id_dep " +
                           "ORDER BY COUNT(u.id) DESC";
                case MINMAX:
                    if (queryText.contains("departament")) {
                        // Find departments with most/least employees
                        if (queryText.contains("putin") || queryText.contains("mic") || 
                            queryText.contains("putini") || queryText.contains("putine")) {
                            return "SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                                   "FROM departament d " +
                                   "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                                   "GROUP BY d.nume_dep, d.id_dep " +
                                   "ORDER BY COUNT(u.id) ASC " +
                                   "LIMIT 5";
                        } else {
                            return "SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                                   "FROM departament d " +
                                   "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                                   "GROUP BY d.nume_dep, d.id_dep " +
                                   "ORDER BY COUNT(u.id) DESC " +
                                   "LIMIT 5";
                        }
                    } else {
                        // Find employees with highest/lowest salaries
                        if (queryText.contains("putin") || queryText.contains("mic") || queryText.contains("min") || queryText.contains("minim") || queryText.contains("minimul") ||
                                queryText.contains("putini") || queryText.contains("putine")) {
                            return "SELECT u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
                                   "t.salariu " +
                                   "FROM useri u " +
                                   "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                                   "LEFT JOIN tipuri t ON u.tip = t.tip " +
                                   "ORDER BY t.salariu ASC " +
                                   "LIMIT 1";
                        } else {
                            return "SELECT u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
                                   "t.salariu " +
                                   "FROM useri u " +
                                   "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                                   "LEFT JOIN tipuri t ON u.tip = t.tip " +
                                   "ORDER BY t.salariu DESC " +
                                   "LIMIT 1";
                        }
                    }
                default:
                    return "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie " +
                           "FROM useri u " +
                           "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                           "LEFT JOIN tipuri t ON u.tip = t.tip " +
                           "ORDER BY d.nume_dep, u.nume, u.prenume";
            }
        } else if (containsAny(queryText, DEPARTMENT_KEYWORDS)) {
            // Query about departments
            switch (queryType) {
                case COUNT:
                    return "SELECT COUNT(*) AS numar_departamente FROM departament";
                case LIST:
                    return "SELECT d.id_dep, d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                           "FROM departament d " +
                           "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                           "GROUP BY d.id_dep, d.nume_dep " +
                           "ORDER BY d.nume_dep";
                case MINMAX:
                    if (queryText.contains("angajat")) {
                        // Find departments with most/least employees
                        if (queryText.contains("putin") || queryText.contains("mic") || 
                            queryText.contains("putini") || queryText.contains("putine")) {
                            return "SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                                   "FROM departament d " +
                                   "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                                   "GROUP BY d.nume_dep, d.id_dep " +
                                   "ORDER BY COUNT(u.id) ASC " +
                                   "LIMIT 5";
                        } else {
                            return "SELECT d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                                   "FROM departament d " +
                                   "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                                   "GROUP BY d.nume_dep, d.id_dep " +
                                   "ORDER BY COUNT(u.id) DESC " +
                                   "LIMIT 5";
                        }
                    } else {
                        // Default department list
                        return "SELECT d.id_dep, d.nume_dep AS departament, COUNT(u.id) AS numar_angajati " +
                               "FROM departament d " +
                               "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                               "GROUP BY d.id_dep, d.nume_dep " +
                               "ORDER BY COUNT(u.id) DESC";
                    }
                default:
                    return "SELECT d.id_dep, d.nume_dep AS departament " +
                           "FROM departament d " +
                           "ORDER BY d.nume_dep";
            }
        } else if (containsAny(queryText, SALARY_KEYWORDS)) {
            // Query about salaries
            switch (queryType) {
                case COUNT:
                    return "SELECT AVG(t.salariu) AS salariu_mediu FROM tipuri t";
                case LIST:
                    return "SELECT t.denumire, t.salariu, COUNT(u.id) AS numar_angajati " +
                           "FROM tipuri t " +
                           "LEFT JOIN useri u ON t.tip = u.tip " +
                           "GROUP BY t.denumire, t.salariu " +
                           "ORDER BY t.salariu DESC";
                case MINMAX:
                    if (queryText.contains("putin") || queryText.contains("mic") || queryText.contains("min") || queryText.contains("minim") || queryText.contains("minimul") ||
                        queryText.contains("putini") || queryText.contains("putine")) {
                        return "SELECT t.denumire, t.salariu " +
                               "FROM tipuri t " +
                               "ORDER BY t.salariu ASC " +
                               "LIMIT 1";
                    } else {
                        return "SELECT t.denumire, t.salariu " +
                               "FROM tipuri t " +
                               "ORDER BY t.salariu DESC " +
                               "LIMIT 1";
                    }
                default:
                    return "SELECT d.nume_dep AS departament, AVG(t.salariu) AS salariu_mediu " +
                           "FROM useri u " +
                           "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                           "LEFT JOIN tipuri t ON u.tip = t.tip " +
                           "GROUP BY d.nume_dep " +
                           "ORDER BY AVG(t.salariu) DESC";
            }
        } else {
            // General company information
            return "SELECT COUNT(u.id) AS numar_angajati, " +
                   "COUNT(DISTINCT d.id_dep) AS numar_departamente, " +
                   "(SELECT COUNT(*) FROM proiecte p WHERE p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL)) AS proiecte_active, " +
                   "(SELECT COUNT(*) FROM concedii c WHERE CURDATE() BETWEEN c.start_c AND c.end_c) AS angajati_in_concediu, " +
                   "(SELECT COUNT(*) FROM sedii) AS numar_sedii " +
                   "FROM useri u " +
                   "LEFT JOIN departament d ON u.id_dep = d.id_dep";
        }
    }
    
    /**
     * Generate a generic SQL query when no specific entity is identified
     */
    private String generateGenericQuery(QueryInfo queryInfo) {
        // Check if any specific entity keywords are present
        String queryText = queryInfo.toString();
        
        if (containsAny(queryText, EMPLOYEE_KEYWORDS)) {
            return generateEmployeeQuery(queryInfo);
        } else if (containsAny(queryText, DEPARTMENT_KEYWORDS)) {
            return generateDepartmentQuery(queryInfo);
        } else if (containsAny(queryText, LEAVE_KEYWORDS)) {
            return generateLeaveQuery(queryInfo);
        } else if (containsAny(queryText, POSITION_KEYWORDS)) {
            return generatePositionQuery(queryInfo);
        } else if (containsAny(queryText, SALARY_KEYWORDS)) {
            return generateSalaryQuery(queryInfo);
        } else if (containsAny(queryText, CERTIFICATE_KEYWORDS)) {
            return generateCertificateQuery(queryInfo);
        } else if (containsAny(queryText, OFFICE_KEYWORDS)) {
            return generateOfficeQuery(queryInfo);
        } else if (containsAny(queryText, PROJECT_KEYWORDS)) {
            return generateProjectQuery(queryInfo);
        } else if (containsAny(queryText, TEAM_KEYWORDS)) {
            return generateTeamQuery(queryInfo);
        } else {
            // Default: show general company information
            return "SELECT COUNT(u.id) AS numar_angajati, COUNT(DISTINCT d.id_dep) AS numar_departamente FROM useri u LEFT JOIN departament d ON u.id_dep = d.id_dep";
        }
    }
    
    /**
     * Check if a text contains any of the keywords in a set
     */
    private boolean containsAny(String text, Set<String> keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Enumeration for query types
     */
    public enum QueryType {
        COUNT,  // Count queries (câți/câte)
        MINMAX, // Min/max queries (cel mai mare/mic)
        LIST    // List queries (care, ce, lista)
    }
    
    /**
     * Class to store query information
     */
    public static class QueryInfo {
        private QueryType queryType;
        private Map<String, String> entities;
        private List<String> requestedAttributes;
        private String sqlQuery;
        private boolean isFollowUp;
        private boolean isStopRequest;
        
        public QueryInfo() {
            this.queryType = QueryType.LIST; // Default type
            this.entities = new HashMap<>();
            this.requestedAttributes = new ArrayList<>();
            this.isFollowUp = false;
            this.isStopRequest = false;
        }
        
        public QueryType getQueryType() {
            return queryType;
        }
        
        public void setQueryType(QueryType queryType) {
            this.queryType = queryType;
        }
        
        public Map<String, String> getEntities() {
            return entities;
        }
        
        public void setEntities(Map<String, String> entities) {
            this.entities = entities;
        }
        
        public List<String> getRequestedAttributes() {
            return requestedAttributes;
        }
        
        public void setRequestedAttributes(List<String> requestedAttributes) {
            this.requestedAttributes = requestedAttributes;
        }
        
        public String getSqlQuery() {
            return sqlQuery;
        }
        
        public void setSqlQuery(String sqlQuery) {
            this.sqlQuery = sqlQuery;
        }
        
        public boolean isFollowUp() {
            return isFollowUp;
        }
        
        public void setFollowUp(boolean isFollowUp) {
            this.isFollowUp = isFollowUp;
        }
        
        public boolean isStopRequest() {
            return isStopRequest;
        }
        
        public void setStopRequest(boolean isStopRequest) {
            this.isStopRequest = isStopRequest;
        }
        
        @Override
        public String toString() {
            StringBuilder sb = new StringBuilder();
            sb.append("QueryType: ").append(queryType).append("\n");
            sb.append("Entities: ").append(entities).append("\n");
            sb.append("RequestedAttributes: ").append(requestedAttributes).append("\n");
            
            if (sqlQuery != null) {
                sb.append("SqlQuery: ").append(sqlQuery);
            }
            
            return sb.toString();
        }
    }
}