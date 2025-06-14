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
    
 // Employee keywords - ENHANCED VERSION with better detection
    private static final Set<String> EMPLOYEE_KEYWORDS = new HashSet<>(Arrays.asList(
        // Primary employee terms
        "angajat", "angajati", "angajații", "angajatul", 
        "personal", "personalul", "persoanele", "persoana",
        "salariat", "salariati", "salariații", "salariatul",
        "lucrator", "lucratori", "lucrătorii", "lucrătorul",
        "om", "oameni", "oamenii", 
        "coleg", "colegi", "colegii", "colegul",
        "membru", "membri", "membrii", "membrul",
        "staff", "stafful", "echipa", "echipele",
        
        // Employment status terms
        "activ", "activi", "activii", "activul",
        "inactiv", "inactivi", "inactivii", "inactivul",
        "angajat", "angajata", "angajate", "angajatul",
        
        // Job-related terms
        "muncitor", "muncitori", "muncitorii", "muncitorul",
        "colaborator", "colaboratori", "colaboratorii", "colaboratorul",
        "resursa umana", "resurse umane", "resursele umane",
        
        // Query patterns for employees
        "cine sunt", "care sunt", "cati sunt", "care persoane",
        "cine lucreaza", "cine lucrează", "care lucreaza", "care lucrează",
        "lista angajati", "lista personalului", "toti angajatii",
        "personalul din", "angajatii din", "colegii din",
        "membrii din", "oamenii din", "cei din"
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
        "cod postal", "coordonate", "amplasare", "sediul", "punctul de lucru", "location", 
        "locatii", "locația", "locațiile", "unde", "unde se afla", "unde se află",
        "adresa", "adrese", "amplasare", "amplasament", "pozitie geografica", "poziție geografică"
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
    
 // Position/role keywords - ENHANCED VERSION
    private static final Set<String> POSITION_KEYWORDS = new HashSet<>(Arrays.asList(
        // Primary position words
        "functie", "functii", "post", "posturi", "pozitie", "pozitii", "job", "joburi",
        "rol", "roluri", "tip", "tipuri", "specializare", "ocupatie", "meserie", "nivel",
        
        // Hierarchy terms
        "rank", "ierarhie", "titlu", "responsabilitate", "statut", "grad", "rang",
        
        // Specific role types
        "director", "manager", "sef", "coordonator", "responsabil", "supervizor",
        "lider", "administrator", "specialist", "expert", "consultant", "analist",
        "asistent", "intern", "stagiar", "trainee", "junior", "senior", "principal",
        "executiv", "adjunct", "vicepresedinte", "presedinte", "ceo", "cto", "cfo",
        
        // Job-related terms
        "munca", "lucru", "activitate", "profesie", "cariera", "domeniu",
        "competenta", "calificare", "experienta", "abilitate", "skill",
        
        // Organizational terms
        "structura", "organizare", "echipa", "grup", "colectiv", "personal",
        "formatie", "unitate", "celula", "compartiment",
        
        // Employment types
        "angajare", "contract", "colaborare", "prestatii", "servicii", "consultanta",
        "freelance", "part-time", "full-time", "temporar", "permanent",
        
        // Position queries
        "ce functii", "ce pozitii", "ce tipuri", "ce roluri", "care functii",
        "care pozitii", "care tipuri", "care roluri", "cate functii", "cati pe functii",
        "structura organizatorica", "organigramma", "ierarhie organizationala"
    ));
    
    // Salary keywords
 // Enhanced Salary keywords with comprehensive detection patterns
    private static final Set<String> SALARY_KEYWORDS = new HashSet<>(Arrays.asList(
        // Primary salary terms
        "salariu", "salarii", "salariul", "salariile", "salariatul", "salariații",
        "remuneratie", "remuneratii", "remuneratia", "remuneratiile",
        "venit", "venituri", "venitul", "veniturile", "veniturile", "venitul",
        "castig", "castiguri", "castigul", "castigurile", "câștig", "câștiguri",
        "plata", "plati", "plăți", "plata", "compensatie", "compensatii",
        "recompensa", "recompense", "leafă", "bani", "sume", "compensare",
        
        // Salary with modifiers
        "salariu mare", "salariu mic", "salarii mari", "salarii mici",
        "salariu maxim", "salariu minim", "salariul cel mai mare", "salariul cel mai mic",
        "salariul maxim", "salariul minim", "salarii maxime", "salarii minime",
        "venitul maxim", "venitul minim", "venituri mari", "venituri mici",
        "castigul maxim", "castigul minim", "castiguri mari", "castiguri mici",
        
        // Salary query patterns
        "ce salariu", "care salariu", "cat salariu", "cât salariu",
        "salariile din", "salarii departament", "salariu departament",
        "cel mai mare salariu", "cel mai mic salariu", "cea mai mare plată",
        "cele mai mari salarii", "cele mai mici salarii",
        
        // Income-related terms
        "income", "retributie", "retribuții", "tarif", "onorariu", "valoare",
        "suma de bani", "sumele de bani", "banii", "banilor",
        
        // Comparative salary terms
        "salariu superior", "salariu inferior", "salarii competitive",
        "plata buna", "plata mică", "remunerare bună", "remunerare scăzută",
        
        // Salary ranges and levels
        "intervalul salarial", "gama salariala", "nivelul salarial",
        "banda salariala", "categoria salariala", "scara salariala"
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
    
 // 1. KEYWORDS EXTENDED PENTRU TODO QUERIES
    private static final Set<String> PROJECT_STATUS_KEYWORDS = new HashSet<>(Arrays.asList(
        "active", "activ", "activa", "activi", "inactive", "inactiv", "inactiva", "inactivi",
        "in prezent", "în prezent", "curent", "curente", "acum", "momentan", "moment",
        "in desfasurare", "în desfășurare", "ongoing", "running", "live"
    ));

    private static final Set<String> CERTIFICATE_STATUS_KEYWORDS = new HashSet<>(Arrays.asList(
        "in asteptare", "în așteptare", "asteptare", "așteptare", "pending",
        "neaprobat", "neaprobate", "respins", "respinse", "aprobat", "aprobate",
        "cu statusul", "cu status", "status", "stare", "situatie", "situația"
    ));

    private static final Set<String> PERSONAL_KEYWORDS = new HashSet<>(Arrays.asList(
        "cate zile de concediu am", "câte zile de concediu am", "concedii am", "zile am",
        "cate concedii mai am", "câte concedii mai am", "mai am", "imi mai raman",
        "îmi mai rămân", "pot sa mi iau", "pot să-mi iau", "e ok daca", "e ok dacă",
        "salariul meu", "salariul meu net", "cati bani iau", "câți bani iau",
        "superiorul meu", "managerul meu", "șeful meu", "seful meu", "seful din departamentul meu"
    ));

    private static final Set<String> AVERAGE_KEYWORDS = new HashSet<>(Arrays.asList(
        "salariu mediu", "salariul mediu", "media salariilor", "media salariala",
        "medie", "mediu", "average", "în medie", "in medie", "per total"
    ));

    private static final Set<String> TASK_KEYWORDS = new HashSet<>(Arrays.asList(
        "task", "taskuri", "sarcina", "sarcini", "de finalizat", "pentru astazi", "pentru azi",
        "deadline", "termen limita", "termen limită", "scadent", "scadente",
        "de terminat", "neterminate", "incomplete", "in progres", "în progres"
    ));

    private static final Set<String> AVAILABILITY_KEYWORDS = new HashSet<>(Arrays.asList(
        "disponibil", "disponibile", "vacant", "vacante", "liber", "libere",
        "deschis", "deschise", "open", "posturi", "pozitii", "poziții", "joburi"
    ));

    private static final Set<String> WORK_MODE_KEYWORDS = new HashSet<>(Arrays.asList(
        "remote", "de acasa", "de acasă", "la distanta", "la distanță", "online",
        "hibrid", "fizic", "la birou", "on-site", "telecomanda", "telecomunca"
    ));

    // 2. ENHANCED TEMPORAL KEYWORDS pentru TODO queries
    private static final Set<String> ENHANCED_TIME_KEYWORDS = new HashSet<>(Arrays.asList(
        "azi", "astazi", "astăzi", "maine", "mâine", "poimaine", "poimâine",
        "ieri", "alaltaieri", "alaltăieri",
        "saptamana aceasta", "săptămâna aceasta", "saptamana viitoare", "săptămâna viitoare",
        "saptamana trecuta", "săptămâna trecută", "luna aceasta", "luna viitoare", "luna trecuta", "luna trecută",
        "anul acesta", "anul trecut", "anul viitor",
        "de craciun", "de crăciun", "de revelion", "de anul nou", "de boboteaza", "de bobotează",
        "de paste", "de paște", "de 1 mai", "de 1 iunie",
        "ultimele", "ultimii", "ultimul", "ultima", "in ultimele", "în ultimele"
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
    
 // 1. KEYWORDS ÎMBUNĂTĂȚITE PENTRU MINMAX
    private static final Set<String> ENHANCED_MINMAX_KEYWORDS = new HashSet<>(Arrays.asList(
        // Superlative indicators
        "cel mai mare", "cea mai mare", "cei mai mari", "cele mai mari",
        "cel mai mic", "cea mai mica", "cei mai mici", "cele mai mici", 
        
        // Direct comparatives
        "mai mare", "mai mari", "mai mic", "mai mici",
        "maxim", "minim", "maximum", "minimum", "maximul", "minimul",
        
        // TOP indicators - IMPORTANT ADDITION
        "top", "primul", "prima", "primii", "primele", "primului", "primei",
        "ultimul", "ultima", "ultimii", "ultimele", "ultimului", "ultimei",
        
        // Quantity-based TOP indicators
        "top 1", "top 3", "top 5", "top 10", "primii 3", "primele 3",
        "cei mai buni", "cele mai bune", "cei mai slabi", "cele mai slabe",
        
        // Ranking indicators
        "clasament", "ierarhie", "rangul", "locul", "pozitia",
        "pe primul loc", "pe ultimul loc", "pe primele locuri",
        
        // Extremes
        "extrem", "extreme", "record", "recordul", "varf", "varful",
        "cel putin", "cel mult", "maximal", "minimal",
        
        // Performance indicators
        "performanta", "performante", "cel mai bun", "cea mai buna",
        "cei mai buni", "cele mai bune", "exceptional", "exceptionala"
    ));

 // 1. EXTENDED KEYWORDS pentru Semi-FAQ
    private static final Set<String> CALENDAR_KEYWORDS = new HashSet<>(Arrays.asList(
        "zi libera", "zi liberă", "zile libere", "zile libera", "zile liberă",
        "urmatoarea zi libera", "următoarea zi liberă", "proxima zi libera", "următoarea zi liberă",
        "sarbatoare", "sărbătoare", "sarbatori", "sărbători", "libera de la stat", "liberă de la stat",
        "zi nationala", "zi națională", "calendar", "calendarul"
    ));

    private static final Set<String> TASK_MANAGEMENT_KEYWORDS = new HashSet<>(Arrays.asList(
        "programeaza", "programează", "programeaza task", "programează task",
        "programeaza meet", "programează meet", "programeaza meeting", "programează meeting",
        "pune task", "pune meeting", "creeaza task", "creează task", "nou task", "task nou",
        "intalnire", "întâlnire", "meeting", "sedinta", "ședință", "task", "sarcina", "sarcină"
    ));

    private static final Set<String> MONTH_DAYS_KEYWORDS = new HashSet<>(Arrays.asList(
        "cate zile are", "câte zile are", "cate zile are luna", "câte zile are luna",
        "zile in luna", "zile în luna", "numarul de zile", "numărul de zile",
        "durata lunii", "lungimea lunii", "calendar luna", "calendar pentru luna"
    ));

    private static final Set<String> LEGAL_HOLIDAYS_KEYWORDS = new HashSet<>(Arrays.asList(
        "zile libere legale", "sarbatori legale", "sărbători legale", "zile de sarbatoare", "zile de sărbătoare",
        "concedii legale", "zile nationale", "zile naționale", "libere de la stat", "libera de la stat",
        "cate zile libere", "câte zile libere", "numarul zilelor libere", "numărul zilelor libere"
    ));
    
    // 2. PATTERNS PENTRU DETECTAREA CANTITĂȚII (TOP 3, etc.)
    private static final Pattern TOP_NUMBER_PATTERN = Pattern.compile(
        "\\b(top|primii|primele|cei mai|cele mai|ultimii|ultimele)\\s+(\\d+)\\b",
        Pattern.CASE_INSENSITIVE
    );

    private static final Pattern LIMIT_NUMBER_PATTERN = Pattern.compile(
        "\\b(\\d+)\\s+(angajati|angajați|rezultate|persoane|oameni|concedii|pozitii|poziții)\\b",
        Pattern.CASE_INSENSITIVE
    );

    /**
     * Enhanced method to check for position-related queries
     */
    private boolean isPositionQuery(String text) {
        // Direct keyword match
        if (containsAny(text, POSITION_KEYWORDS)) {
            return true;
        }
        
        // Pattern-based detection
        String[] positionPatterns = {
            "ce .*functii.*", "care .*functii.*", "cate .*functii.*",
            "ce .*pozitii.*", "care .*pozitii.*", "cate .*pozitii.*",
            "ce .*tipuri.*", "care .*tipuri.*", "cate .*tipuri.*",
            "ce .*roluri.*", "care .*roluri.*", "cate .*roluri.*",
            "structura.*departament.*", "ierarhia.*departament.*",
            "functii.*departament.*", "pozitii.*departament.*",
            "tipuri.*departament.*", "roluri.*departament.*"
        };
        
        for (String pattern : positionPatterns) {
            if (text.matches(".*" + pattern + ".*")) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Helper method to determine if query has salary focus
     */
    private boolean hasSalaryFocus(String text) {
        // Direct salary keywords
        if (containsAny(text, SALARY_KEYWORDS)) {
            return true;
        }
        
        // Salary patterns with MINMAX indicators
        String[] salaryMinMaxPatterns = {
            ".*salariu.*maxim.*", ".*salariu.*minim.*",
            ".*cele mai.*salar.*", ".*cel mai.*salar.*",
            ".*mari.*salar.*", ".*mici.*salar.*",
            ".*venit.*mare.*", ".*venit.*mic.*"
        };
        
        for (String pattern : salaryMinMaxPatterns) {
            if (text.matches(pattern)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Enhanced method to distinguish between department and position queries
     */
    private boolean isDepartmentVsPositionQuery(String text) {
        // If both department and position keywords are present, 
        // determine the primary intent
        
        boolean hasPositionKeywords = containsAny(text, POSITION_KEYWORDS);
        boolean hasDepartmentKeywords = containsAny(text, DEPARTMENT_KEYWORDS);
        
        if (hasPositionKeywords && hasDepartmentKeywords) {
            // Look for indicators that suggest positions are the main focus
            String[] positionFocusIndicators = {
                "functii", "pozitii", "tipuri", "roluri", "specializari",
                "ce functii", "care functii", "cate functii",
                "ce pozitii", "care pozitii", "cate pozitii"
            };
            
            for (String indicator : positionFocusIndicators) {
                if (text.contains(indicator)) {
                    return false; // This is a position query, not department
                }
            }
            
            // Look for indicators that suggest departments are the main focus
            String[] departmentFocusIndicators = {
                "ce departamente", "care departamente", "cate departamente",
                "departamentul", "in departament", "din departament"
            };
            
            for (String indicator : departmentFocusIndicators) {
                if (text.contains(indicator)) {
                    return true; // This is a department query
                }
            }
        }
        
        // Default: if position keywords are present, treat as position query
        return !hasPositionKeywords;
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
    
 // 3. METODA ÎMBUNĂTĂȚITĂ PENTRU IDENTIFICAREA QUERY TYPE
    private QueryType identifyQueryType(String text) {
        System.out.println("DEBUG: ===== QUERY TYPE IDENTIFICATION =====");
        System.out.println("DEBUG: Analyzing text: \"" + text + "\"");
        
        // PRIORITY 1: Check for MINMAX indicators first
        boolean hasMinMaxKeywords = containsAny(text, ENHANCED_MINMAX_KEYWORDS);
        boolean hasTopPattern = TOP_NUMBER_PATTERN.matcher(text).find();
        boolean hasSuperlatives = text.contains("cel mai") || text.contains("cea mai") || 
                                 text.contains("cei mai") || text.contains("cele mai");
        
        System.out.println("DEBUG: - Has MINMAX keywords: " + hasMinMaxKeywords);
        System.out.println("DEBUG: - Has TOP pattern: " + hasTopPattern);
        System.out.println("DEBUG: - Has superlatives: " + hasSuperlatives);
        
        // If any MINMAX indicator is present, this is a MINMAX query
        if (hasMinMaxKeywords || hasTopPattern || hasSuperlatives) {
            System.out.println("DEBUG: ✅ DETECTED: MINMAX query type");
            return QueryType.MINMAX;
        }
        
        // PRIORITY 2: Check for COUNT indicators
        boolean hasCountKeywords = containsAny(text, COUNT_KEYWORDS);
        System.out.println("DEBUG: - Has COUNT keywords: " + hasCountKeywords);
        
        if (hasCountKeywords) {
            System.out.println("DEBUG: ✅ DETECTED: COUNT query type");
            return QueryType.COUNT;
        }
        
        // PRIORITY 3: Default to LIST
        System.out.println("DEBUG: ✅ DETECTED: LIST query type (default)");
        return QueryType.LIST;
    }

 // 4. METODA PENTRU EXTRAGEREA NUMĂRULUI DIN TOP QUERIES
    private int extractTopNumber(String text) {
        System.out.println("DEBUG: Extracting TOP number from: \"" + text + "\"");
        
        // Check for explicit TOP patterns
        Matcher topMatcher = TOP_NUMBER_PATTERN.matcher(text);
        if (topMatcher.find()) {
            int number = Integer.parseInt(topMatcher.group(2));
            System.out.println("DEBUG: Found TOP number via pattern: " + number);
            return number;
        }
        
        // Check for limit patterns
        Matcher limitMatcher = LIMIT_NUMBER_PATTERN.matcher(text);
        if (limitMatcher.find()) {
            int number = Integer.parseInt(limitMatcher.group(1));
            System.out.println("DEBUG: Found LIMIT number via pattern: " + number);
            return number;
        }
        
        // Default based on superlatives
        if (text.contains("primul") || text.contains("prima") || 
            text.contains("cel mai") || text.contains("cea mai")) {
            System.out.println("DEBUG: Superlative detected - returning 1");
            return 1;
        }
        
        // Default for general queries
        System.out.println("DEBUG: No specific number found - returning default 5");
        return 5;
    }

    
    /**
     * Check if text contains temporal expressions
     */
    private boolean containsTemporalExpression(String text) {
        String[] temporalExpressions = {
            "astazi", "azi", "ieri", "maine",
            "luna aceasta", "luna trecuta", "luna viitoare",
            "anul acesta", "anul trecut", "anul viitor", 
            "saptamana aceasta", "saptamana trecuta", "saptamana viitoare",
            "decembrie", "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie",
            "iulie", "august", "septembrie", "octombrie", "noiembrie",
            "craciun", "paste", "vara", "iarna", "primavara", "toamna"
        };
        
        for (String expr : temporalExpressions) {
            if (text.contains(expr)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Extract specific temporal expression from text
     */
    private String extractTemporalExpression(String text) {
        String[] temporalExpressions = {
            "luna aceasta", "luna trecuta", "luna viitoare",
            "anul acesta", "anul trecut", "anul viitor",
            "saptamana aceasta", "saptamana trecuta", "saptamana viitoare",
            "astazi", "azi", "ieri", "maine",
            "decembrie", "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie",
            "iulie", "august", "septembrie", "octombrie", "noiembrie",
            "craciun", "paste", "vara", "iarna", "primavara", "toamna"
        };
        
        // Sort by length descending to match longer expressions first
        Arrays.sort(temporalExpressions, (a, b) -> b.length() - a.length());
        
        for (String expr : temporalExpressions) {
            if (text.contains(expr)) {
                return expr;
            }
        }
        return null;
    }
    
 // 2. MONTH MAPPING pentru calcularea zilelor
    private static final Map<String, Integer> MONTH_MAPPING = new HashMap<>();
    static {
        MONTH_MAPPING.put("ianuarie", 1);
        MONTH_MAPPING.put("ianuarie", 1);
        MONTH_MAPPING.put("februarie", 2);
        MONTH_MAPPING.put("martie", 3);
        MONTH_MAPPING.put("aprilie", 4);
        MONTH_MAPPING.put("mai", 5);
        MONTH_MAPPING.put("iunie", 6);
        MONTH_MAPPING.put("iulie", 7);
        MONTH_MAPPING.put("august", 8);
        MONTH_MAPPING.put("septembrie", 9);
        MONTH_MAPPING.put("octombrie", 10);
        MONTH_MAPPING.put("noiembrie", 11);
        MONTH_MAPPING.put("decembrie", 12);
    }
    
 // 3. ENHANCED identifyEntities METHOD pentru TODO queries
    private Map<String, String> identifyEntities(String text) {
        Map<String, String> entities = new HashMap<>();
        
        System.out.println("DEBUG: ===== ENHANCED ENTITY DETECTION =====");
        System.out.println("DEBUG: Analyzing text: \"" + text + "\"");
        
        // PRIORITY 1: PERSONAL QUERIES (about current user)
        if (containsAny(text, PERSONAL_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Personal query");
            entities.put("entity", "personal");
            
            if (text.contains("concediu") || text.contains("concedii") || text.contains("zile")) {
                entities.put("personal_type", "leave_balance");
            } else if (text.contains("salariu") || text.contains("bani") || text.contains("net")) {
                entities.put("personal_type", "salary");
            } else if (text.contains("superior") || text.contains("manager") || text.contains("sef") || text.contains("șef")) {
                entities.put("personal_type", "hierarchy");
            }
            
            extractDepartmentName(text, entities);
            return entities;
        }
        
        // PRIORITY 2: PROJECT STATUS QUERIES
        if (containsAny(text, PROJECT_KEYWORDS) && containsAny(text, PROJECT_STATUS_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Project status query");
            entities.put("entity", "project");
            
            if (text.contains("activ") || text.contains("prezent") || text.contains("curent") || 
                text.contains("desfasurare") || text.contains("desfășurare")) {
                entities.put("project_status", "active");
            } else if (text.contains("inactiv") || text.contains("terminat") || text.contains("finalizat")) {
                entities.put("project_status", "inactive");
            }
            
            return entities;
        }
        
        // PRIORITY 3: CERTIFICATE STATUS QUERIES
        if (containsAny(text, CERTIFICATE_KEYWORDS) && containsAny(text, CERTIFICATE_STATUS_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Certificate status query");
            entities.put("entity", "certificate");
            
            if (text.contains("asteptare") || text.contains("așteptare") || text.contains("pending")) {
                entities.put("certificate_status", "pending");
            } else if (text.contains("aprobat") || text.contains("aprobate")) {
                entities.put("certificate_status", "approved");
            } else if (text.contains("respins") || text.contains("respinse")) {
                entities.put("certificate_status", "rejected");
            }
            
            return entities;
        }
        
        // PRIORITY 4: LOCATION QUERIES
        if (containsAny(text, LOCATION_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Location query");
            entities.put("entity", "location");
            
            if (containsAny(text, DEPARTMENT_KEYWORDS)) {
                entities.put("location_type", "department");
                extractDepartmentName(text, entities);
            } else if (containsAny(text, OFFICE_KEYWORDS)) {
                entities.put("location_type", "office");
            } else if (containsAny(text, EMPLOYEE_KEYWORDS)) {
                entities.put("location_type", "employee");
            }
            
            return entities;
        }
        
        // PRIORITY 5: AVERAGE/STATISTICAL QUERIES
        if (containsAny(text, AVERAGE_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Average/statistical query");
            entities.put("entity", "average");
            
            if (containsAny(text, SALARY_KEYWORDS)) {
                entities.put("average_type", "salary");
                extractDepartmentName(text, entities);
                
                // Check if it's for a specific position
                if (containsAny(text, POSITION_KEYWORDS)) {
                    entities.put("average_scope", "position");
                } else if (containsAny(text, DEPARTMENT_KEYWORDS)) {
                    entities.put("average_scope", "department");
                } else if (text.contains("per total") || text.contains("total") || text.contains("general")) {
                    entities.put("average_scope", "company");
                }
            }
            
            return entities;
        }
        
        // PRIORITY 6: TASK QUERIES with temporal context
        if (containsAny(text, TASK_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Task query");
            entities.put("entity", "task");
            
            if (text.contains("finalizat") || text.contains("terminat") || text.contains("deadline")) {
                entities.put("task_status", "deadline");
            } else if (text.contains("progres") || text.contains("lucru")) {
                entities.put("task_status", "in_progress");
            }
            
            // Enhanced temporal detection for tasks
            if (containsTemporalExpression(text)) {
                entities.put("has_temporal", "true");
                String temporal = extractTemporalExpression(text);
                if (temporal != null) {
                    entities.put("temporal_filter", temporal);
                }
            }
            
            return entities;
        }
        
        // PRIORITY 7: AVAILABILITY QUERIES
        if (containsAny(text, AVAILABILITY_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Availability query");
            entities.put("entity", "availability");
            
            if (containsAny(text, POSITION_KEYWORDS) || text.contains("post") || text.contains("job")) {
                entities.put("availability_type", "position");
            }
            
            return entities;
        }
        
        // PRIORITY 8: WORK MODE QUERIES
        if (containsAny(text, WORK_MODE_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Work mode query");
            entities.put("entity", "work_mode");
            
            if (text.contains("remote") || text.contains("acasa") || text.contains("acasă") || text.contains("distanta") || text.contains("distanță")) {
                entities.put("work_mode_type", "remote");
            } else if (text.contains("hibrid")) {
                entities.put("work_mode_type", "hybrid");
            } else if (text.contains("fizic") || text.contains("birou") || text.contains("on-site")) {
                entities.put("work_mode_type", "physical");
            }
            
            return entities;
        }
        
        // PRIORITY 9: ENHANCED LEAVE QUERIES with temporal context
        if (containsAny(text, LEAVE_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Enhanced leave query");
            entities.put("entity", "leave");
            
            // Check for "who is on leave" queries
            if (text.contains("cine e") || text.contains("cine este") || text.contains("exista angajati") || text.contains("există angajați")) {
                entities.put("leave_query_type", "who_is_on_leave");
            }
            
            // Enhanced temporal detection
            if (containsTemporalExpression(text)) {
                entities.put("has_temporal", "true");
                String temporal = extractTemporalExpression(text);
                if (temporal != null) {
                    entities.put("temporal_filter", temporal);
                }
            }
            
            // Check for specific leave types
            if (text.contains("medical")) {
                entities.put("leave_type", "medical");
            } else if (text.contains("odihna") || text.contains("odihnă")) {
                entities.put("leave_type", "vacation");
            } else if (text.contains("maternitate")) {
                entities.put("leave_type", "maternity");
            }
            
            extractDepartmentName(text, entities);
            return entities;
        } else if (containsAny(text, POSITION_KEYWORDS)) {
            entities.put("entity", "position");
        } else if (containsAny(text, SALARY_KEYWORDS)) {
            entities.put("entity", "salary");
        }
        
        extractDepartmentName(text, entities);
        
     // 1. TASK/MEETING SCHEDULING
        if (containsAny(text, TASK_MANAGEMENT_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Task/Meeting scheduling query");
            Map<String, String> entities1 = new HashMap<>();
            entities1.put("entity", "task_scheduling");
            
            if (text.contains("task") || text.contains("sarcina") || text.contains("sarcină")) {
                entities1.put("scheduling_type", "task");
            } else if (text.contains("meet") || text.contains("intalnire") || text.contains("întâlnire") || 
                       text.contains("sedinta") || text.contains("ședință")) {
                entities1.put("scheduling_type", "meeting");
            }
            
            // Extract person name if mentioned
            String personName = extractPersonName(text);
            if (personName != null) {
                entities1.put("target_person", personName);
            }
            
            return entities1;
        }
        
        // 2. NEXT FREE DAY QUERIES
        if (containsAny(text, CALENDAR_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Calendar/free day query");
            Map<String, String> entities1 = new HashMap<>();
            entities1.put("entity", "calendar");
            
            if (text.contains("urmatoarea") || text.contains("următoarea") || text.contains("proxima")) {
                entities1.put("calendar_type", "next_free_day");
            } else if (text.contains("toate") || text.contains("lista") || text.contains("care sunt")) {
                entities1.put("calendar_type", "all_holidays");
            }
            
            return entities1;
        }
        
        // 3. LEGAL HOLIDAYS COUNT
        if (containsAny(text, LEGAL_HOLIDAYS_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Legal holidays query");
            Map<String, String> entities1 = new HashMap<>();
            entities1.put("entity", "legal_holidays");
            entities1.put("calendar_type", "count_legal_holidays");
            
            // Check for specific year
            String year = extractYear(text);
            if (year != null) {
                entities1.put("target_year", year);
            }
            
            return entities1;
        }
        
        // 4. MONTH DAYS QUERIES
        if (containsAny(text, MONTH_DAYS_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Month days query");
            Map<String, String> entities1 = new HashMap<>();
            entities1.put("entity", "month_days");
            
            String monthName = extractMonthName(text);
            if (monthName != null) {
                entities1.put("target_month", monthName);
            }
            
            String year = extractYear(text);
            if (year != null) {
                entities1.put("target_year", year);
            } else {
                entities1.put("target_year", String.valueOf(java.time.LocalDate.now().getYear()));
            }
            
            return entities1;
        }
        
        // FALL BACK to existing logic
        return identifyEntities1(text);
    }
    
 // 4. HELPER METHODS pentru Semi-FAQ

    /**
     * Extract person name from scheduling queries
     */
    private String extractPersonName(String text) {
        // Pattern: "programeaza task/meet cu [name]"
        Pattern pattern = Pattern.compile("cu\\s+([a-zA-ZăâîșțĂÂÎȘȚ]+(?:\\s+[a-zA-ZăâîșțĂÂÎȘȚ]+)?)", 
                                         Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(text);
        
        if (matcher.find()) {
            String name = matcher.group(1).trim();
            System.out.println("DEBUG: Extracted person name: " + name);
            return name;
        }
        
        return null;
    }

    /**
     * Extract month name from text
     */
    private String extractMonthName(String text) {
        for (String month : MONTH_MAPPING.keySet()) {
            if (text.contains(month)) {
                System.out.println("DEBUG: Extracted month: " + month);
                return month;
            }
        }
        return null;
    }

    /**
     * Extract year from text
     */
    private String extractYear(String text) {
        Pattern yearPattern = Pattern.compile("\\b(20\\d{2})\\b");
        Matcher matcher = yearPattern.matcher(text);
        
        if (matcher.find()) {
            String year = matcher.group(1);
            System.out.println("DEBUG: Extracted year: " + year);
            return year;
        }
        
        return null;
    }

    // 6. QUERY GENERATORS pentru Semi-FAQ

    /**
     * Generate task scheduling queries
     */
    private String generateTaskSchedulingQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String schedulingType = entities.getOrDefault("scheduling_type", "");
        String targetPerson = entities.get("target_person");
        
        if (targetPerson != null) {
            // Find the person first
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
            sql.append("t.denumire AS functie, u.email, u.telefon, ");
            sql.append("'Pentru programarea unui ");
            
            if ("task".equals(schedulingType)) {
                sql.append("task");
            } else if ("meeting".equals(schedulingType)) {
                sql.append("meeting");
            } else {
                sql.append("task/meeting");
            }
            
            sql.append(", contactați această persoană direct sau folosiți sistemul intern de task-uri.' AS instructiuni ");
            sql.append("FROM useri u ");
            sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
            sql.append("WHERE (LOWER(u.nume) LIKE LOWER('%").append(targetPerson).append("%') ");
            sql.append("OR LOWER(u.prenume) LIKE LOWER('%").append(targetPerson).append("%') ");
            sql.append("OR LOWER(CONCAT(u.nume, ' ', u.prenume)) LIKE LOWER('%").append(targetPerson).append("%')) ");
            sql.append("AND u.activ = 1 ");
            sql.append("ORDER BY u.nume, u.prenume");
            
            return sql.toString();
        } else {
            // General scheduling guidance
            return "SELECT 'Pentru programarea de task-uri sau meeting-uri, " +
                   "specificați numele persoanei cu care doriți să programați. " +
                   "Exemplu: \"programează meeting cu Ion Popescu\"' AS ghid_programare";
        }
    }

    /**
     * Generate calendar queries (next free day)
     */
    private String generateCalendarQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String calendarType = entities.getOrDefault("calendar_type", "");
        
        switch (calendarType) {
            case "next_free_day":
                // Find next free day (weekend or holiday)
                return "SELECT " +
                       "CASE " +
                       "  WHEN EXISTS (SELECT 1 FROM sarbatori WHERE zi > CURDATE() ORDER BY zi LIMIT 1) THEN " +
                       "    (SELECT zi FROM sarbatori WHERE zi > CURDATE() ORDER BY zi LIMIT 1) " +
                       "  WHEN EXISTS (SELECT 1 FROM libere WHERE zi > CURDATE() ORDER BY zi LIMIT 1) THEN " +
                       "    (SELECT zi FROM libere WHERE zi > CURDATE() ORDER BY zi LIMIT 1) " +
                       "  ELSE " +
                       "    CASE DAYOFWEEK(CURDATE()) " +
                       "      WHEN 1 THEN DATE_ADD(CURDATE(), INTERVAL 6 DAY) " + // Sunday -> next Saturday
                       "      WHEN 7 THEN DATE_ADD(CURDATE(), INTERVAL 1 DAY) " + // Saturday -> Sunday
                       "      ELSE DATE_ADD(CURDATE(), INTERVAL (7 - DAYOFWEEK(CURDATE()) + 1) DAY) " + // Weekday -> next Saturday
                       "    END " +
                       "END AS urmatoarea_zi_libera, " +
                       "CASE " +
                       "  WHEN EXISTS (SELECT 1 FROM sarbatori WHERE zi > CURDATE() ORDER BY zi LIMIT 1) THEN " +
                       "    (SELECT nume FROM sarbatori WHERE zi > CURDATE() ORDER BY zi LIMIT 1) " +
                       "  WHEN EXISTS (SELECT 1 FROM libere WHERE zi > CURDATE() ORDER BY zi LIMIT 1) THEN " +
                       "    (SELECT nume FROM libere WHERE zi > CURDATE() ORDER BY zi LIMIT 1) " +
                       "  ELSE 'Weekend' " +
                       "END AS tip_zi_libera";
                       
            case "all_holidays":
                // List all holidays this year
                return "SELECT zi AS data_sarbatoare, nume AS denumire_sarbatoare, " +
                       "'Sărbătoare legală' AS tip " +
                       "FROM sarbatori " +
                       "WHERE YEAR(zi) = YEAR(CURDATE()) AND zi >= CURDATE() " +
                       "UNION ALL " +
                       "SELECT zi AS data_sarbatoare, nume AS denumire_sarbatoare, " +
                       "'Zi liberă suplimentară' AS tip " +
                       "FROM libere " +
                       "WHERE YEAR(zi) = YEAR(CURDATE()) AND zi >= CURDATE() " +
                       "ORDER BY data_sarbatoare";
                       
            default:
                return "SELECT 'Tip interogare calendar nerecunoscut' AS mesaj";
        }
    }

    /**
     * Generate legal holidays count query
     */
    private String generateLegalHolidaysQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String targetYear = entities.getOrDefault("target_year", String.valueOf(java.time.LocalDate.now().getYear()));
        
        return "SELECT " +
               "COUNT(s.zi) AS zile_libere_legale, " +
               "COUNT(l.zi) AS zile_libere_suplimentare, " +
               "(COUNT(s.zi) + COUNT(l.zi)) AS total_zile_libere, " +
               "'" + targetYear + "' AS anul " +
               "FROM sarbatori s " +
               "FULL OUTER JOIN libere l ON YEAR(s.zi) = YEAR(l.zi) " +
               "WHERE (YEAR(s.zi) = " + targetYear + " OR YEAR(l.zi) = " + targetYear + ")";
    }

    /**
     * Generate month days query
     */
    private String generateMonthDaysQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String targetMonth = entities.get("target_month");
        String targetYear = entities.getOrDefault("target_year", String.valueOf(java.time.LocalDate.now().getYear()));
        
        if (targetMonth != null) {
            Integer monthNumber = MONTH_MAPPING.get(targetMonth.toLowerCase());
            
            if (monthNumber != null) {
                return "SELECT " +
                       "DAY(LAST_DAY('" + targetYear + "-" + String.format("%02d", monthNumber) + "-01')) AS zile_in_luna, " +
                       "'" + targetMonth + "' AS luna, " +
                       "'" + targetYear + "' AS anul, " +
                       "CASE " +
                       "  WHEN " + monthNumber + " = 2 AND (" + targetYear + " % 4 = 0 AND (" + targetYear + " % 100 != 0 OR " + targetYear + " % 400 = 0)) THEN 'An bisect' " +
                       "  ELSE 'An normal' " +
                       "END AS tip_an";
            }
        }
        
        return "SELECT 'Luna specificată nu este validă. Folosiți numele lunii în română (ianuarie, februarie, etc.)' AS mesaj";
    }

    // 7. CALENDAR UTILITY METHODS

    /**
     * Calculate days in month considering leap years
     */
    private int calculateDaysInMonth(int month, int year) {
        switch (month) {
            case 1: case 3: case 5: case 7: case 8: case 10: case 12:
                return 31;
            case 4: case 6: case 9: case 11:
                return 30;
            case 2:
                return isLeapYear(year) ? 29 : 28;
            default:
                return 0;
        }
    }

    /**
     * Check if year is leap year
     */
    private boolean isLeapYear(int year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }

    /**
     * Get next weekend date
     */
    private String getNextWeekend() {
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.DayOfWeek dayOfWeek = today.getDayOfWeek();
        
        int daysUntilSaturday = 6 - dayOfWeek.getValue(); // Saturday is 6
        if (daysUntilSaturday <= 0) {
            daysUntilSaturday += 7; // Next week's Saturday
        }
        
        return today.plusDays(daysUntilSaturday).toString();
    }

    // 8. RESPONSE HELPERS pentru Semi-FAQ

    /**
     * Format task scheduling response
     */
    private String formatTaskSchedulingResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo) {
        String schedulingType = queryInfo.getEntities().getOrDefault("scheduling_type", "task/meeting");
        String targetPerson = queryInfo.getEntities().get("target_person");
        
        if (resultList.isEmpty()) {
            return "Nu am găsit nicio persoană cu numele \"" + targetPerson + "\". " +
                   "Verificați numele și încercați din nou, sau căutați în directorul de angajați.";
        } else if (resultList.size() == 1) {
            Map<String, Object> person = resultList.get(0);
            return String.format(
                "**Pentru programarea unui %s cu %s %s:**\n\n" +
                "👤 **Nume:** %s %s\n" +
                "🏢 **Departament:** %s\n" +
                "👔 **Funcția:** %s\n" +
                "📧 **Email:** %s\n" +
                "📞 **Telefon:** %s\n\n" +
                "💡 **Opțiuni de programare:**\n" +
                "• Contactați direct prin email sau telefon\n" +
                "• Folosiți sistemul intern de task-uri/calendar\n" +
                "• Verificați disponibilitatea în calendar-ul companiei",
                schedulingType,
                person.get("nume"), person.get("prenume"),
                person.get("nume"), person.get("prenume"),
                person.get("departament"),
                person.get("functie"),
                person.get("email"),
                person.get("telefon")
            );
        } else {
            return "Am găsit " + resultList.size() + " persoane cu numele \"" + targetPerson + "\". " +
                   "Iată lista pentru a alege persoana corectă:";
        }
    }

    /**
     * Format calendar response
     */
    private String formatCalendarResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo) {
        String calendarType = queryInfo.getEntities().getOrDefault("calendar_type", "");
        
        if ("next_free_day".equals(calendarType) && resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            String nextFreeDay = (String) result.get("urmatoarea_zi_libera");
            String tipZi = (String) result.get("tip_zi_libera");
            
            return String.format(
                "**Următoarea zi liberă:**\n\n" +
                "📅 **Data:** %s\n" +
                "🎉 **Tipul:** %s\n\n" +
                "ℹ️ *Aceasta este următoarea zi în care nu se lucrează conform calendarului oficial.*",
                nextFreeDay, tipZi
            );
        }
        
        return "Iată informațiile de calendar solicitate:";
    }

    /**
     * Format legal holidays count response
     */
    private String formatLegalHolidaysResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo) {
        if (resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            int zileLegale = ((Number) result.getOrDefault("zile_libere_legale", 0)).intValue();
            int zileSuplimentare = ((Number) result.getOrDefault("zile_libere_suplimentare", 0)).intValue();
            int total = ((Number) result.getOrDefault("total_zile_libere", 0)).intValue();
            String anul = (String) result.get("anul");
            
            return String.format(
                "**Zile libere legale pentru anul %s:**\n\n" +
                "🏛️ **Sărbători legale:** %d zile\n" +
                "📅 **Zile libere suplimentare:** %d zile\n" +
                "📊 **Total zile libere:** %d zile\n\n" +
                "ℹ️ *Aceste zile sunt stabilite prin lege și calendar oficial.*",
                anul, zileLegale, zileSuplimentare, total
            );
        }
        
        return "Nu am putut calcula zilele libere legale pentru anul specificat.";
    }

    /**
     * Format month days response
     */
    private String formatMonthDaysResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo) {
        if (resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            int zileInLuna = ((Number) result.get("zile_in_luna")).intValue();
            String luna = (String) result.get("luna");
            String anul = (String) result.get("anul");
            String tipAn = (String) result.get("tip_an");
            
            return String.format(
                "**Luna %s %s:**\n\n" +
                "📅 **Numărul de zile:** %d zile\n" +
                "📊 **Tipul anului:** %s\n\n" +
                "ℹ️ *%s",
                luna, anul, zileInLuna, tipAn,
                "An bisect".equals(tipAn) ? 
                    "Februarie are 29 de zile în anii biseţi." : 
                    "Anul normal - februarie are 28 de zile."
            );
        }
        
        return "Nu am putut calcula zilele pentru luna specificată.";
    }
    
    /**
     * Enhanced entity identification with better temporal support
     */
    private Map<String, String> identifyEntities1(String text) {
        Map<String, String> entities = new HashMap<>();
        
        System.out.println("DEBUG: ===== ENHANCED ENTITY DETECTION =====");
        System.out.println("DEBUG: Analyzing text: \"" + text + "\"");
        
        // Detect all keyword types first
        boolean hasEmployeeKeywords = containsAny(text, EMPLOYEE_KEYWORDS);
        boolean hasPositionKeywords = containsAny(text, POSITION_KEYWORDS);
        boolean hasDepartmentKeywords = containsAny(text, DEPARTMENT_KEYWORDS);
        boolean hasLeaveKeywords = containsAny(text, LEAVE_KEYWORDS);
        boolean hasCountKeywords = containsAny(text, COUNT_KEYWORDS);
        boolean hasTemporalKeywords = containsTemporalExpression(text);
        boolean hasSalaryKeywords = containsAny(text, SALARY_KEYWORDS); // IMPORTANT!
        
        System.out.println("DEBUG: Keyword analysis:");
        System.out.println("DEBUG: - Employee keywords: " + hasEmployeeKeywords);
        System.out.println("DEBUG: - Position keywords: " + hasPositionKeywords);
        System.out.println("DEBUG: - Department keywords: " + hasDepartmentKeywords);
        System.out.println("DEBUG: - Leave keywords: " + hasLeaveKeywords);
        System.out.println("DEBUG: - Count keywords: " + hasCountKeywords);
        System.out.println("DEBUG: - Temporal keywords: " + hasTemporalKeywords);
        System.out.println("DEBUG: - Salary keywords: " + hasSalaryKeywords);
        
        // ========================================================================
        // PRIORITY 1: TEMPORAL + ENTITY combinations
        // ========================================================================
        
        if (hasTemporalKeywords) {
            System.out.println("DEBUG: Processing temporal expressions...");
            
            if (hasLeaveKeywords) {
                entities.put("entity", "leave");
                entities.put("has_temporal", "true");
                
                String temporal = extractTemporalExpression(text);
                if (temporal != null) {
                    entities.put("temporal_filter", temporal);
                }
                
                extractDepartmentName(text, entities);
                
                System.out.println("DEBUG: 🎯 DETECTED: Temporal leave query: " + entities);
                return entities;
            }
            
            if (hasEmployeeKeywords) {
                entities.put("entity", "employee");
                entities.put("has_temporal", "true");
                
                String temporal = extractTemporalExpression(text);
                if (temporal != null) {
                    entities.put("temporal_filter", temporal);
                }
                
                extractDepartmentName(text, entities);
                
                System.out.println("DEBUG: 🎯 DETECTED: Temporal employee query: " + entities);
                return entities;
            }
        }
        
        // ========================================================================
        // PRIORITY 2: SALARY QUERIES - CRITICAL FIX!
        // ========================================================================
        
        // CASE: "salariu minim/maxim departament X" - Salary-focused query
        if (hasSalaryKeywords && (hasDepartmentKeywords || hasEmployeeKeywords)) {
            System.out.println("DEBUG: 🎯 DETECTED: Salary query with context");
            
            // For salary queries, we want to show employees with their salaries
            entities.put("entity", "employee");
            entities.put("focus", "salary"); // Add focus indicator
            
            extractDepartmentName(text, entities);
            
            System.out.println("DEBUG: Final entities: " + entities);
            return entities;
        }
        
        // ========================================================================
        // PRIORITY 3: SPECIFIC ENTITY COMBINATIONS (order is critical!)
        // ========================================================================
        
        // CASE 1: "Care sunt angajații din departamentul X" - Employee query with department filter
        if (hasEmployeeKeywords && hasDepartmentKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Employee query with department context");
            entities.put("entity", "employee");
            extractDepartmentName(text, entities);
            
            System.out.println("DEBUG: Final entities: " + entities);
            return entities;
        }
        
        // CASE 2: "Funcții/poziții din departamentul X" - Position query with department context
        if (hasPositionKeywords && hasDepartmentKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Position query with department context");
            entities.put("entity", "tipuri_pozitii");
            extractDepartmentName(text, entities);
            
            System.out.println("DEBUG: Final entities: " + entities);
            return entities;
        }
        
        // CASE 3: "Concedii din departamentul X" - Leave query with department context
        if (hasLeaveKeywords && hasDepartmentKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Leave query with department context");
            entities.put("entity", "leave");
            extractDepartmentName(text, entities);
            
            System.out.println("DEBUG: Final entities: " + entities);
            return entities;
        }
        
        // ========================================================================
        // PRIORITY 4: COUNT-based queries (what are we counting?)
        // ========================================================================
        
        if (hasCountKeywords) {
            System.out.println("DEBUG: Processing count-based query...");
            
            if (hasEmployeeKeywords) {
                System.out.println("DEBUG: 🎯 DETECTED: Count employees query");
                entities.put("entity", "employee");
                extractDepartmentName(text, entities);
                return entities;
                
            } else if (hasPositionKeywords) {
                System.out.println("DEBUG: 🎯 DETECTED: Count positions query");
                entities.put("entity", "tipuri_pozitii");
                extractDepartmentName(text, entities);
                return entities;
                
            } else if (hasLeaveKeywords) {
                entities.put("entity", "leave");
                extractDepartmentName(text, entities);
                return entities;
                
            } else if (hasDepartmentKeywords) {
                entities.put("entity", "department");
                extractDepartmentName(text, entities);
                return entities;
                
            } else if (containsAny(text, PROJECT_KEYWORDS)) {
                entities.put("entity", "project");
                return entities;
            }
        }
        
        // ========================================================================
        // PRIORITY 5: LOCATION-based queries
        // ========================================================================
        
        if (containsAny(text, LOCATION_KEYWORDS)) {
            if (hasDepartmentKeywords) {
                entities.put("entity", "locatii_departamente");
                extractDepartmentName(text, entities);
                return entities;
            } else if (hasEmployeeKeywords) {
                entities.put("entity", "locatii_useri");
                extractDepartmentName(text, entities);
                return entities;
            } else if (hasLeaveKeywords) {
                entities.put("entity", "locatii_concedii");
                extractDepartmentName(text, entities);
                return entities;
            }
        }
        
        // ========================================================================
        // PRIORITY 6: SINGLE ENTITY DETECTION (in priority order)
        // ========================================================================
        
        // Salary queries should be treated as employee queries with salary focus
        if (hasSalaryKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Salary query");
            entities.put("entity", "employee");
            entities.put("focus", "salary");
            extractDepartmentName(text, entities);
            
        } else if (hasEmployeeKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Employee query");
            entities.put("entity", "employee");
            extractDepartmentName(text, entities);
            
        } else if (hasPositionKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Position query");
            entities.put("entity", "tipuri_pozitii");
            extractDepartmentName(text, entities);
            
        } else if (hasLeaveKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Leave query");
            entities.put("entity", "leave");
            
            // Check for leave periods
            if (text.contains("craciun") || text.contains("crăciun")) {
                entities.put("period", "christmas");
            } else if (text.contains("vara") || text.contains("vară")) {
                entities.put("period", "summer");
            } else if (text.contains("iarna") || text.contains("iarnă")) {
                entities.put("period", "winter");
            } else if (text.contains("paste") || text.contains("paște")) {
                entities.put("period", "easter");
            }
            
            extractDepartmentName(text, entities);
            
        } else if (containsAny(text, CERTIFICATE_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Certificate query");
            entities.put("entity", "adeverinte");
            extractDepartmentName(text, entities);
            
        } else if (containsAny(text, PROJECT_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Project query");
            entities.put("entity", "proiecte");
            
            if (text.contains("active") || text.contains("curente") || 
                text.contains("actuale") || text.contains("in desfasurare") ||
                text.contains("în desfășurare")) {
                entities.put("status", "active");
            }
            
        } else if (containsAny(text, OFFICE_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Office query");
            entities.put("entity", "sedii");
            
        } else if (containsAny(text, TEAM_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Team query");
            entities.put("entity", "echipa");
            
        } else if (containsAny(text, FIRM_KEYWORDS)) {
            System.out.println("DEBUG: 🎯 DETECTED: Firm-wide query");
            entities.put("entity", "useri");
            
        } else if (hasDepartmentKeywords) {
            System.out.println("DEBUG: 🎯 DETECTED: Department query");
            entities.put("entity", "department");
            extractDepartmentName(text, entities);
            
        } else {
            // Default fallback
            System.out.println("DEBUG: 🎯 DETECTED: Default to employee query");
            entities.put("entity", "employee");
            extractDepartmentName(text, entities);
        }
        
        System.out.println("DEBUG: Final detected entities: " + entities);
        System.out.println("DEBUG: ===== ENTITY DETECTION COMPLETE =====");
        
        return entities;
    }

    // ===================================================================
    // HELPER METHOD pentru extragerea numelui departamentului
    // ===================================================================

    /**
     * Helper method to extract department name from text
     */
    private void extractDepartmentName(String text, Map<String, String> entities) {
        for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
            if (text.contains(entry.getKey())) {
                entities.put("department_name", entry.getValue());
                System.out.println("DEBUG: Found department: " + entry.getKey() + " -> " + entry.getValue());
                return;
            }
        }
        
        // Try regex pattern if direct match fails
        Pattern pattern = Pattern.compile("departament(?:ul)?\\s+([a-z0-9]+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(text);
        
        if (matcher.find()) {
            String deptName = matcher.group(1).toUpperCase();
            entities.put("department_name", deptName);
            System.out.println("DEBUG: Found department via regex: " + deptName);
        }
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
            case "personal":
                return generatePersonalQuery(queryInfo);
           
            case "location":
                return generateLocationQuery(queryInfo);
            case "average":
                return generateAverageQuery(queryInfo);
            case "task":
                return generateTaskQuery(queryInfo);
            case "availability":
                return generateAvailabilityQuery(queryInfo);
            case "work_mode":
                return generateWorkModeQuery(queryInfo);
            case "task_scheduling":
                return generateTaskSchedulingQuery(queryInfo);
            case "calendar":
                return generateCalendarQuery(queryInfo);
            case "legal_holidays":
                return generateLegalHolidaysQuery(queryInfo);
            case "month_days":
                return generateMonthDaysQuery(queryInfo);
            default:
                return generateGenericQuery(queryInfo);
        }
    }
    
 // 5. NEW QUERY GENERATORS for TODO items

    /**
     * Generate personal queries (about current user)
     */
    private String generatePersonalQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String personalType = entities.getOrDefault("personal_type", "");
        
        switch (personalType) {
            case "leave_balance":
                // "cate zile de concediu am?"
                return "SELECT u.zileramase AS zile_ramase, u.zilecons AS zile_consumate, " +
                       "u.conramase AS concedii_ramase, u.conluate AS concedii_luate " +
                       "FROM useri u WHERE u.id = ?"; // Will be replaced with current user condition
                       
            case "salary":
                // "salariul meu net"
                return "SELECT t.salariu AS salariu_brut, " +
                       "ROUND(t.salariu * 0.585, 2) AS salariu_net_aproximativ, " +
                       "t.denumire AS functie, d.nume_dep AS departament " +
                       "FROM useri u " +
                       "LEFT JOIN tipuri t ON u.tip = t.tip " +
                       "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                       "WHERE u.id = ?";
                       
            case "hierarchy":
                // "cine este superiorul meu?"
                return "SELECT sup.nume, sup.prenume, sup_t.denumire AS functie_superior, " +
                       "sup_d.nume_dep AS departament_superior " +
                       "FROM useri u " +
                       "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                       "LEFT JOIN tipuri t ON u.tip = t.tip " +
                       "LEFT JOIN useri sup ON (sup.id_dep = d.id_dep AND sup_t.ierarhie < t.ierarhie) " +
                       "LEFT JOIN tipuri sup_t ON sup.tip = sup_t.tip " +
                       "LEFT JOIN departament sup_d ON sup.id_dep = sup_d.id_dep " +
                       "WHERE u.id = ? ORDER BY sup_t.ierarhie ASC LIMIT 1";
                       
            default:
                return "SELECT 'Tip interogare personală nerecunoscut' AS mesaj";
        }
    }

    /**
     * Generate project queries with status
     */
    private String generateProjectQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String projectStatus = entities.getOrDefault("project_status", "");
        QueryType queryType = queryInfo.getQueryType();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_proiecte FROM proiecte p WHERE 1=1 ");
                break;
            case LIST:
            default:
                sql.append("SELECT p.id, p.nume, p.descriere, p.start AS data_inceput, ");
                sql.append("p.end AS data_sfarsit, u.nume AS supervizor_nume, u.prenume AS supervizor_prenume ");
                sql.append("FROM proiecte p ");
                sql.append("LEFT JOIN useri u ON p.supervizor = u.id ");
                sql.append("WHERE 1=1 ");
        }
        
        // Add status filter
        if ("active".equals(projectStatus)) {
            sql.append("AND p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL) ");
        } else if ("inactive".equals(projectStatus)) {
            sql.append("AND (p.end < CURDATE() OR p.start > CURDATE()) ");
        }
        
        if (queryType == QueryType.LIST) {
            sql.append("ORDER BY p.start DESC");
        }
        
        return sql.toString();
    }

    /**
     * Generate certificate queries with status
     */
    private String generateCertificateQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String certificateStatus = entities.getOrDefault("certificate_status", "");
        QueryType queryType = queryInfo.getQueryType();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_adeverinte FROM adeverinte a WHERE 1=1 ");
                break;
            case LIST:
            default:
                sql.append("SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, ");
                sql.append("s.nume_status AS status, a.creare AS data_creare, ");
                sql.append("u.nume, u.prenume, d.nume_dep AS departament ");
                sql.append("FROM adeverinte a ");
                sql.append("LEFT JOIN tip_adev ta ON a.tip = ta.id ");
                sql.append("LEFT JOIN statusuri s ON a.status = s.status ");
                sql.append("LEFT JOIN useri u ON a.id_ang = u.id ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("WHERE 1=1 ");
        }
        
        // Add status filter
        if ("pending".equals(certificateStatus)) {
            sql.append("AND a.status = 0 ");
        } else if ("approved".equals(certificateStatus)) {
            sql.append("AND a.status > 0 ");
        } else if ("rejected".equals(certificateStatus)) {
            sql.append("AND a.status < 0 ");
        }
        
        if (queryType == QueryType.LIST) {
            sql.append("ORDER BY a.creare DESC");
        }
        
        return sql.toString();
    }

    /**
     * Generate location queries
     */
    private String generateLocationQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String locationType = entities.getOrDefault("location_type", "");
        String departmentName = entities.get("department_name");
        
        switch (locationType) {
            case "department":
                StringBuilder sql = new StringBuilder();
                sql.append("SELECT d.nume_dep AS departament, ld.strada, ld.oras, ld.judet, ld.tara ");
                sql.append("FROM departament d ");
                sql.append("LEFT JOIN locatii_departamente ld ON d.id_dep = ld.id_dep ");
                sql.append("WHERE 1=1 ");
                
                if (departmentName != null) {
                    sql.append("AND UPPER(d.nume_dep) LIKE UPPER('%").append(departmentName).append("%') ");
                }
                
                sql.append("ORDER BY d.nume_dep");
                return sql.toString();
                
            case "office":
                return "SELECT nume_sediu, tip_sediu, strada, oras, judet, tara, telefon " +
                       "FROM sedii ORDER BY tip_sediu, nume_sediu";
                       
            case "employee":
                return "SELECT u.nume, u.prenume, d.nume_dep AS departament, " +
                       "lu.strada, lu.oras, lu.judet, lu.tara " +
                       "FROM useri u " +
                       "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                       "LEFT JOIN locatii_useri lu ON u.id = lu.id_user " +
                       "ORDER BY d.nume_dep, u.nume";
                       
            default:
                return "SELECT 'Tip locație nerecunoscut' AS mesaj";
        }
    }

    /**
     * Generate average/statistical queries
     */
    private String generateAverageQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String averageType = entities.getOrDefault("average_type", "");
        String averageScope = entities.getOrDefault("average_scope", "");
        String departmentName = entities.get("department_name");
        
        if ("salary".equals(averageType)) {
            StringBuilder sql = new StringBuilder();
            
            switch (averageScope) {
                case "department":
                    sql.append("SELECT d.nume_dep AS departament, AVG(t.salariu) AS salariu_mediu, ");
                    sql.append("COUNT(u.id) AS numar_angajati ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                    sql.append("WHERE 1=1 ");
                    
                    if (departmentName != null) {
                        sql.append("AND UPPER(d.nume_dep) LIKE UPPER('%").append(departmentName).append("%') ");
                    }
                    
                    sql.append("GROUP BY d.id_dep, d.nume_dep ORDER BY AVG(t.salariu) DESC");
                    break;
                    
                case "position":
                    sql.append("SELECT t.denumire AS pozitie, AVG(t.salariu) AS salariu_mediu, ");
                    sql.append("COUNT(u.id) AS numar_angajati ");
                    sql.append("FROM tipuri t ");
                    sql.append("LEFT JOIN useri u ON t.tip = u.tip ");
                    
                    if (departmentName != null) {
                        sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                        sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(departmentName).append("%') ");
                    } else {
                        sql.append("WHERE 1=1 ");
                    }
                    
                    sql.append("GROUP BY t.tip, t.denumire ORDER BY AVG(t.salariu) DESC");
                    break;
                    
                case "company":
                default:
                    sql.append("SELECT AVG(t.salariu) AS salariu_mediu_general, ");
                    sql.append("COUNT(u.id) AS total_angajati ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN tipuri t ON u.tip = t.tip");
                    break;
            }
            
            return sql.toString();
        }
        
        return "SELECT 'Tip medie nerecunoscut' AS mesaj";
    }

    /**
     * Generate task queries with temporal context
     */
    private String generateTaskQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String taskStatus = entities.getOrDefault("task_status", "");
        String temporalFilter = entities.get("temporal_filter");
        QueryType queryType = queryInfo.getQueryType();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_taskuri FROM tasks t WHERE 1=1 ");
                break;
            case LIST:
            default:
                sql.append("SELECT t.id, t.nume AS nume_task, p.nume AS nume_proiect, ");
                sql.append("u.nume, u.prenume, s.procent AS progres, ");
                sql.append("t.start AS data_inceput, t.end AS data_sfarsit ");
                sql.append("FROM tasks t ");
                sql.append("LEFT JOIN proiecte p ON t.id_prj = p.id ");
                sql.append("LEFT JOIN useri u ON t.id_ang = u.id ");
                sql.append("LEFT JOIN statusuri2 s ON t.status = s.id ");
                sql.append("WHERE 1=1 ");
        }
        
        // Add status filter
        if ("deadline".equals(taskStatus)) {
            sql.append("AND t.end = CURDATE() ");
        } else if ("in_progress".equals(taskStatus)) {
            sql.append("AND s.procent < 100 AND t.start <= CURDATE() AND t.end >= CURDATE() ");
        }
        
        // Add temporal filter
        if (temporalFilter != null) {
            String temporalCondition = generateTemporalCondition(temporalFilter, "t.end");
            if (temporalCondition != null) {
                sql.append("AND ").append(temporalCondition).append(" ");
            }
        }
        
        if (queryType == QueryType.LIST) {
            sql.append("ORDER BY t.end ASC");
        }
        
        return sql.toString();
    }

    /**
     * Generate availability queries
     */
    private String generateAvailabilityQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String availabilityType = entities.getOrDefault("availability_type", "");
        
        if ("position".equals(availabilityType)) {
            return "SELECT j.id, j.titlu, j.req AS cerinte, j.resp AS responsabilitati, " +
                   "d.nume_dep AS departament, t.denumire AS pozitie, " +
                   "j.start AS data_publicare, j.end AS data_expirare " +
                   "FROM joburi j " +
                   "LEFT JOIN departament d ON j.departament = d.id_dep " +
                   "LEFT JOIN tipuri t ON j.pozitie = t.tip " +
                   "WHERE j.activ = 1 AND (j.end >= CURDATE() OR j.end IS NULL) " +
                   "ORDER BY j.start DESC";
        }
        
        return "SELECT 'Tip disponibilitate nerecunoscut' AS mesaj";
    }

    /**
     * Generate work mode queries
     */
    private String generateWorkModeQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String workModeType = entities.getOrDefault("work_mode_type", "");
        QueryType queryType = queryInfo.getQueryType();
        
        StringBuilder sql = new StringBuilder();
        
        // Note: This assumes you have a work_mode column in your database
        // If not, you might need to add this functionality
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_angajati FROM useri u ");
                sql.append("LEFT JOIN joburi j ON u.tip = j.pozitie WHERE 1=1 ");
                break;
            case LIST:
            default:
                sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie ");
                sql.append("FROM useri u ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                sql.append("WHERE 1=1 ");
        }
        
        // For now, return a placeholder query since work mode isn't in the schema
        if ("remote".equals(workModeType)) {
            sql.append("-- AND work_mode = 'remote' -- Column not yet implemented");
        }
        
        if (queryType == QueryType.LIST) {
            sql.append("ORDER BY d.nume_dep, u.nume");
        }
        
        return sql.toString();
    }

    /**
     * Enhanced leave query with better temporal support
     */
    private String generateEnhancedLeaveQuery(QueryInfo queryInfo) {
        Map<String, String> entities = queryInfo.getEntities();
        String leaveQueryType = entities.getOrDefault("leave_query_type", "");
        String temporalFilter = entities.get("temporal_filter");
        String departmentName = entities.get("department_name");
        String leaveType = entities.get("leave_type");
        QueryType queryType = queryInfo.getQueryType();
        
        StringBuilder sql = new StringBuilder();
        
        if ("who_is_on_leave".equals(leaveQueryType)) {
            // "cine e in concediu azi/astazi"
            sql.append("SELECT u.nume, u.prenume, d.nume_dep AS departament, ");
            sql.append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, ");
            sql.append("tc.motiv AS tip_concediu, c.durata ");
            sql.append("FROM concedii c ");
            sql.append("LEFT JOIN useri u ON c.id_ang = u.id ");
            sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
            sql.append("LEFT JOIN tipcon tc ON c.tip = tc.tip ");
            sql.append("WHERE c.status >= 1 "); // Approved leaves only
            
            // Add temporal filter
            if (temporalFilter != null) {
                String temporalCondition = generateTemporalCondition(temporalFilter, "c.start_c", "c.end_c");
                if (temporalCondition != null) {
                    sql.append("AND ").append(temporalCondition).append(" ");
                }
            } else {
                // Default to today if no temporal filter
                sql.append("AND CURDATE() BETWEEN c.start_c AND c.end_c ");
            }
            
            // Add department filter
            if (departmentName != null) {
                sql.append("AND UPPER(d.nume_dep) LIKE UPPER('%").append(departmentName).append("%') ");
            }
            
            // Add leave type filter
            if (leaveType != null) {
                sql.append("AND LOWER(tc.motiv) LIKE LOWER('%").append(leaveType).append("%') ");
            }
            
            sql.append("ORDER BY c.start_c DESC");
            
        } else {
            // Default leave query (existing logic)
            return generateLeaveQuery(queryInfo);
        }
        
        return sql.toString();
    }

    /**
     * Enhanced temporal condition generator for leave queries
     */
    private String generateTemporalCondition(String temporal, String startColumn, String endColumn) {
        if (temporal == null) {
            return generateTemporalCondition(temporal, startColumn);
        }
        
        switch (temporal.toLowerCase()) {
            case "astazi":
            case "azi":
                return "CURDATE() BETWEEN " + startColumn + " AND " + endColumn;
                
            case "maine":
                return "DATE_ADD(CURDATE(), INTERVAL 1 DAY) BETWEEN " + startColumn + " AND " + endColumn;
                
            case "saptamana aceasta":
                return "(" + startColumn + " <= DATE_ADD(CURDATE(), INTERVAL (7 - DAYOFWEEK(CURDATE())) DAY) " +
                       "AND " + endColumn + " >= DATE_SUB(CURDATE(), INTERVAL (DAYOFWEEK(CURDATE()) - 1) DAY))";
                       
            case "saptamana viitoare":
                return "(" + startColumn + " <= DATE_ADD(CURDATE(), INTERVAL (14 - DAYOFWEEK(CURDATE())) DAY) " +
                       "AND " + endColumn + " >= DATE_ADD(CURDATE(), INTERVAL (8 - DAYOFWEEK(CURDATE())) DAY))";
                       
            case "luna aceasta":
                return "(" + startColumn + " <= LAST_DAY(CURDATE()) " +
                       "AND " + endColumn + " >= DATE_FORMAT(CURDATE(), '%Y-%m-01'))";
                       
            case "luna viitoare":
                return "(" + startColumn + " <= LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 1 MONTH)) " +
                       "AND " + endColumn + " >= DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01'))";
                       
            case "de craciun":
            case "de crăciun":
                return "(" + startColumn + " <= '2025-12-26' AND " + endColumn + " >= '2025-12-24')";
                
            case "de revelion":
                return "(" + startColumn + " <= '2025-01-02' AND " + endColumn + " >= '2024-12-31') " +
                       "OR (" + startColumn + " <= '2026-01-02' AND " + endColumn + " >= '2025-12-31')";
                       
            default:
                return generateTemporalCondition(temporal, startColumn);
        }
    }
    
    /**
     * Enhanced leave query generation with better temporal support
     */
    private String generateLeaveQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_concedii FROM concedii c");
                
                // Add joins if needed
                boolean needsUserJoin = entities.containsKey("department_name") || entities.containsKey("has_temporal");
                if (needsUserJoin) {
                    sql.append(" LEFT JOIN useri u ON c.id_ang = u.id");
                }
                
                if (entities.containsKey("department_name")) {
                    sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                }
                
                // Build WHERE clause
                List<String> whereConditions = new ArrayList<>();
                
                if (entities.containsKey("department_name")) {
                    whereConditions.add("UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%')");
                }
                
                // Enhanced temporal filtering
                if (entities.containsKey("temporal_filter")) {
                    String temporal = entities.get("temporal_filter");
                    String temporalCondition = generateTemporalCondition(temporal, "c.start_c");
                    if (temporalCondition != null) {
                        whereConditions.add(temporalCondition);
                    }
                }
                
                // Add WHERE clause if we have conditions
                if (!whereConditions.isEmpty()) {
                    sql.append(" WHERE ").append(String.join(" AND ", whereConditions));
                }
                
                return sql.toString();
                
            case LIST:
                sql.append("SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, ");
                sql.append("s.nume_status AS status, c.durata, tc.motiv AS tip_concediu ");
                sql.append("FROM concedii c ");
                sql.append("LEFT JOIN useri u ON c.id_ang = u.id ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                sql.append("LEFT JOIN statusuri s ON c.status = s.status ");
                sql.append("LEFT JOIN tipcon tc ON c.tip = tc.tip ");
                
                // Build WHERE clause
                List<String> whereConditions2 = new ArrayList<>();
                
                if (entities.containsKey("department_name")) {
                    whereConditions2.add("UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%')");
                }
                
                // Enhanced temporal filtering
                if (entities.containsKey("temporal_filter")) {
                    String temporal = entities.get("temporal_filter");
                    String temporalCondition = generateTemporalCondition(temporal, "c.start_c");
                    if (temporalCondition != null) {
                        whereConditions2.add(temporalCondition);
                    }
                }
                
                // Add WHERE clause if we have conditions
                if (!whereConditions2.isEmpty()) {
                    sql.append("WHERE ").append(String.join(" AND ", whereConditions2));
                }
                
                sql.append(" ORDER BY c.start_c DESC");
                return sql.toString();
                
            default:
                // Default to list of current leaves
                return "SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.durata FROM concedii c LEFT JOIN useri u ON c.id_ang = u.id LEFT JOIN departament d ON u.id_dep = d.id_dep LEFT JOIN tipuri t ON u.tip = t.tip WHERE CURDATE() BETWEEN c.start_c AND c.end_c ORDER BY c.start_c DESC";
        }
    }
    
    /**
     * ADAUGĂ această metodă pentru debug temporal în translator
     */
    private void debugTemporalDetection(String query) {
        System.out.println("DEBUG: ===== TEMPORAL DETECTION ANALYSIS =====");
        System.out.println("DEBUG: Query: \"" + query + "\"");
        
        // Check individual temporal words
        String[] temporalWords = {
            "luna aceasta", "luna trecuta", "astazi", "azi", "ieri", "maine",
            "anul acesta", "anul trecut", "saptamana aceasta", "decembrie", 
            "ianuarie", "februarie", "martie", "aprilie", "mai", "iunie",
            "iulie", "august", "septembrie", "octombrie", "noiembrie"
        };
        
        for (String temporal : temporalWords) {
            if (query.contains(temporal)) {
                System.out.println("DEBUG: Found temporal expression: \"" + temporal + "\"");
            }
        }
        
        // Check entity words
        String[] leaveWords = {"concediu", "concedii", "vacanta", "absenta"};
        for (String leave : leaveWords) {
            if (query.contains(leave)) {
                System.out.println("DEBUG: Found leave keyword: \"" + leave + "\"");
            }
        }
        
        String[] employeeWords = {"angajat", "angajati", "personal", "salariat"};
        for (String emp : employeeWords) {
            if (query.contains(emp)) {
                System.out.println("DEBUG: Found employee keyword: \"" + emp + "\"");
            }
        }
        
        System.out.println("DEBUG: ===== TEMPORAL DETECTION COMPLETE =====");
    }


    /**
     * Generate SQL temporal condition based on temporal expression
     */
    private String generateTemporalCondition(String temporal, String columnName) {
        if (temporal == null || columnName == null) {
            return null;
        }
        
        switch (temporal.toLowerCase()) {
            case "astazi":
            case "azi":
                return "DATE(" + columnName + ") = CURDATE()";
                
            case "ieri":
                return "DATE(" + columnName + ") = DATE_SUB(CURDATE(), INTERVAL 1 DAY)";
                
            case "maine":
                return "DATE(" + columnName + ") = DATE_ADD(CURDATE(), INTERVAL 1 DAY)";
                
            case "luna aceasta":
                return "MONTH(" + columnName + ") = MONTH(CURDATE()) AND YEAR(" + columnName + ") = YEAR(CURDATE())";
                
            case "luna trecuta":
                return "MONTH(" + columnName + ") = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) AND YEAR(" + columnName + ") = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))";
                
            case "luna viitoare":
                return "MONTH(" + columnName + ") = MONTH(DATE_ADD(CURDATE(), INTERVAL 1 MONTH)) AND YEAR(" + columnName + ") = YEAR(DATE_ADD(CURDATE(), INTERVAL 1 MONTH))";
                
            case "anul acesta":
                return "YEAR(" + columnName + ") = YEAR(CURDATE())";
                
            case "anul trecut":
                return "YEAR(" + columnName + ") = YEAR(CURDATE()) - 1";
                
            case "anul viitor":
                return "YEAR(" + columnName + ") = YEAR(CURDATE()) + 1";
                
            case "saptamana aceasta":
                return "YEARWEEK(" + columnName + ") = YEARWEEK(CURDATE())";
                
            case "saptamana trecuta":
                return "YEARWEEK(" + columnName + ") = YEARWEEK(DATE_SUB(CURDATE(), INTERVAL 1 WEEK))";
                
            case "saptamana viitoare":
                return "YEARWEEK(" + columnName + ") = YEARWEEK(DATE_ADD(CURDATE(), INTERVAL 1 WEEK))";
                
            // Specific months
            case "decembrie":
                return "MONTH(" + columnName + ") = 12";
            case "ianuarie":
                return "MONTH(" + columnName + ") = 1";
            case "februarie":
                return "MONTH(" + columnName + ") = 2";
            case "martie":
                return "MONTH(" + columnName + ") = 3";
            case "aprilie":
                return "MONTH(" + columnName + ") = 4";
            case "mai":
                return "MONTH(" + columnName + ") = 5";
            case "iunie":
                return "MONTH(" + columnName + ") = 6";
            case "iulie":
                return "MONTH(" + columnName + ") = 7";
            case "august":
                return "MONTH(" + columnName + ") = 8";
            case "septembrie":
                return "MONTH(" + columnName + ") = 9";
            case "octombrie":
                return "MONTH(" + columnName + ") = 10";
            case "noiembrie":
                return "MONTH(" + columnName + ") = 11";
                
            // Seasons
            case "iarna":
                return "MONTH(" + columnName + ") IN (12, 1, 2)";
            case "primavara":
                return "MONTH(" + columnName + ") IN (3, 4, 5)";
            case "vara":
                return "MONTH(" + columnName + ") IN (6, 7, 8)";
            case "toamna":
                return "MONTH(" + columnName + ") IN (9, 10, 11)";
                
            // Holidays
            case "craciun":
                return "(" + columnName + " BETWEEN '2023-12-24' AND '2023-12-26' OR " +
                       columnName + " BETWEEN '2024-12-24' AND '2024-12-26' OR " +
                       columnName + " BETWEEN '2025-12-24' AND '2025-12-26')";
                       
            default:
                return null;
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
                System.out.println("DEBUG: 🎯 Generating MINMAX query for employees");
                
                // Enhanced MINMAX query for employees with salary focus
                sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie, t.salariu ");
                
                // Check if we're looking for seniority/experience
                if (queryInfo.toString().contains("vechime") || queryInfo.toString().contains("experienta")) {
                    sql.append(", TIMESTAMPDIFF(YEAR, u.data_ang, CURDATE()) AS ani_vechime ");
                }
                
                sql.append("FROM useri u ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                
                // Build WHERE clause
                List<String> whereConditions = new ArrayList<>();
                
                // Add department filter if specified
                if (entities.containsKey("department_name")) {
                    whereConditions.add("UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%')");
                }
                
                // Add active employee filter
                whereConditions.add("u.activ = 1");
                
                // Add WHERE clause if we have conditions
                if (!whereConditions.isEmpty()) {
                    sql.append("WHERE ").append(String.join(" AND ", whereConditions)).append(" ");
                }
                
                // Enhanced ordering logic based on what's being asked
                String queryString = queryInfo.toString().toLowerCase();
                
                // Check if it's a salary-focused query
                boolean isSalaryQuery = entities.containsKey("focus") && "salary".equals(entities.get("focus")) ||
                                       queryString.contains("salariu") || queryString.contains("salarii");
                
                if (isSalaryQuery) {
                    // Salary-based MINMAX
                    if (queryString.contains("mic") || queryString.contains("minim") || 
                        queryString.contains("putin") || queryString.contains("putini")) {
                        System.out.println("DEBUG: Ordering by MINIMUM salary");
                        sql.append("ORDER BY t.salariu ASC ");
                    } else {
                        System.out.println("DEBUG: Ordering by MAXIMUM salary");
                        sql.append("ORDER BY t.salariu DESC ");
                    }
                } else if (queryString.contains("vechime") || queryString.contains("experienta")) {
                    // Seniority-based MINMAX
                    if (queryString.contains("mic") || queryString.contains("putin") || 
                        queryString.contains("recent") || queryString.contains("nou")) {
                        System.out.println("DEBUG: Ordering by LEAST seniority");
                        sql.append("ORDER BY u.data_ang DESC "); // Most recent hires first
                    } else {
                        System.out.println("DEBUG: Ordering by MOST seniority");
                        sql.append("ORDER BY u.data_ang ASC "); // Oldest hires first
                    }
                } else {
                    // Default to salary ordering
                    if (queryString.contains("mic") || queryString.contains("minim") || 
                        queryString.contains("putin") || queryString.contains("putini")) {
                        System.out.println("DEBUG: Default ordering by MINIMUM salary");
                        sql.append("ORDER BY t.salariu ASC ");
                    } else {
                        System.out.println("DEBUG: Default ordering by MAXIMUM salary");
                        sql.append("ORDER BY t.salariu DESC ");
                    }
                }
                
                // Limit results for MINMAX (typically want top/bottom results)
                int limit = 5; // Default to top 5
                if (queryString.contains("primul") || queryString.contains("prima") || 
                    queryString.contains("cel mai") || queryString.contains("cea mai")) {
                    limit = 1; // Just the top result
                } else if (queryString.contains("top 10") || queryString.contains("primii 10")) {
                    limit = 10;
                }
                
                sql.append("LIMIT ").append(limit);
                
                System.out.println("DEBUG: Generated MINMAX SQL: " + sql.toString());
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
    
    private String generateEmployeeQuery(QueryInfo queryInfo) {
        QueryType queryType = queryInfo.getQueryType();
        Map<String, String> entities = queryInfo.getEntities();
        String originalQuery = queryInfo.toString().toLowerCase();
        
        System.out.println("DEBUG: ===== GENERATING EMPLOYEE QUERY =====");
        System.out.println("DEBUG: Query type: " + queryType);
        System.out.println("DEBUG: Original query: " + originalQuery);
        
        StringBuilder sql = new StringBuilder();
        
        int limitNumber = 1;
		switch (queryType) {
        case MINMAX:
            System.out.println("DEBUG: 🎯 Generating MINMAX query for employees");
            
            // Enhanced MINMAX query for employees with salary focus
            sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
            sql.append("t.denumire AS functie, t.salariu ");
            
            // Check if we're looking for seniority/experience
            if (queryInfo.toString().contains("vechime") || queryInfo.toString().contains("experienta")) {
                sql.append(", TIMESTAMPDIFF(YEAR, u.data_ang, CURDATE()) AS ani_vechime ");
            }
            
            sql.append("FROM useri u ");
            sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
            
            // Build WHERE clause
            List<String> whereConditions = new ArrayList<>();
            
            // Add department filter if specified
            if (entities.containsKey("department_name")) {
                whereConditions.add("UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%')");
                System.out.println("DEBUG: Added department filter: " + entities.get("department_name"));
            }
            
            // Add active employee filter
            whereConditions.add("u.activ = 1");
            
            // Add WHERE clause if we have conditions
            if (!whereConditions.isEmpty()) {
                sql.append("WHERE ").append(String.join(" AND ", whereConditions)).append(" ");
            }
            
            // CRITICAL FIX: Enhanced MIN/MAX detection logic
            String originalQuery1 = queryInfo.toString().toLowerCase();
            System.out.println("DEBUG: ===== MIN/MAX DETECTION ANALYSIS =====");
            System.out.println("DEBUG: Original query for analysis: \"" + originalQuery1 + "\"");
            
            // STEP 1: Detect if it's explicitly a MINIMUM query
            boolean isMinimumQuery = false;
            String[] minimumIndicators = {
                "minim", "minimum", "minimul", "minimele", "minimele",
                "cel mai mic", "cea mai mica", "cei mai mici", "cele mai mici",
                "mai mic", "mai mici", "mai putin", "mai putini", "mai putine",
                "cel mai putin", "cea mai putina", "cei mai putini", "cele mai putine",
                "ultimul", "ultima", "ultimii", "ultimele", "sfarsit", "coada",
                "salariu minim", "salarii mici", "cele mai mici salarii",
                "salariul cel mai mic", "venitul cel mai mic", "castigul cel mai mic"
            };
            
            for (String indicator : minimumIndicators) {
                if (originalQuery1.contains(indicator)) {
                    isMinimumQuery = true;
                    System.out.println("DEBUG: 🔍 FOUND MINIMUM indicator: \"" + indicator + "\"");
                    break;
                }
            }
            
            // STEP 2: Double-check for maximum indicators (should override if present)
            boolean isMaximumQuery = false;
            String[] maximumIndicators = {
                "maxim", "maximum", "maximul", "maximele",
                "cel mai mare", "cea mai mare", "cei mai mari", "cele mai mari",
                "mai mare", "mai mari", "mai mult", "mai multe", "mai bine",
                "cel mai mult", "cea mai multa", "cei mai multi", "cele mai multe",
                "primul", "prima", "primii", "primele", "inceput", "frunte", "top",
                "salariu maxim", "salarii mari", "cele mai mari salarii",
                "salariul cel mai mare", "venitul cel mai mare", "castigul cel mai mare"
            };
            
            for (String indicator : maximumIndicators) {
                if (originalQuery1.contains(indicator)) {
                    isMaximumQuery = true;
                    System.out.println("DEBUG: 🔍 FOUND MAXIMUM indicator: \"" + indicator + "\"");
                    break;
                }
            }
            
            // STEP 3: Determine final ordering
            boolean orderAscending = false; // Default to descending (maximum first)
            
            if (isMinimumQuery && !isMaximumQuery) {
                orderAscending = true;
                System.out.println("DEBUG: ✅ DECISION: MINIMUM query detected -> ORDER BY ASC");
            } else if (isMaximumQuery && !isMinimumQuery) {
                orderAscending = false;
                System.out.println("DEBUG: ✅ DECISION: MAXIMUM query detected -> ORDER BY DESC");
            } else if (isMinimumQuery && isMaximumQuery) {
                // Both found - prioritize the last one mentioned
                int minIndex = originalQuery1.lastIndexOf("minim");
                int maxIndex = originalQuery1.lastIndexOf("maxim");
                if (minIndex > maxIndex) {
                    orderAscending = true;
                    System.out.println("DEBUG: ✅ DECISION: Both found, MINIMUM appears last -> ORDER BY ASC");
                } else {
                    orderAscending = false;
                    System.out.println("DEBUG: ✅ DECISION: Both found, MAXIMUM appears last -> ORDER BY DESC");
                }
            } else {
                // Neither explicitly found - default to maximum (descending)
                orderAscending = false;
                System.out.println("DEBUG: ✅ DECISION: No clear indicator -> DEFAULT TO MAXIMUM (ORDER BY DESC)");
            }
            
            // STEP 4: Apply ordering based on what we're comparing
            if (originalQuery1.contains("salariu") || originalQuery1.contains("salarii") || 
                entities.containsKey("focus") && "salary".equals(entities.get("focus"))) {
                // Salary-based ordering
                if (orderAscending) {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY t.salariu ASC (MINIMUM salary)");
                    sql.append("ORDER BY t.salariu ASC ");
                } else {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY t.salariu DESC (MAXIMUM salary)");
                    sql.append("ORDER BY t.salariu DESC ");
                }
            } else if (originalQuery1.contains("vechime") || originalQuery1.contains("experienta")) {
                // Seniority-based ordering
                if (orderAscending) {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY u.data_ang DESC (LEAST seniority - newest hires)");
                    sql.append("ORDER BY u.data_ang DESC "); // Most recent hires first (least seniority)
                } else {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY u.data_ang ASC (MOST seniority - oldest hires)");
                    sql.append("ORDER BY u.data_ang ASC "); // Oldest hires first (most seniority)
                }
            } else {
                // Default to salary ordering
                if (orderAscending) {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY t.salariu ASC (DEFAULT - MINIMUM)");
                    sql.append("ORDER BY t.salariu ASC ");
                } else {
                    System.out.println("DEBUG: 🎯 APPLYING: ORDER BY t.salariu DESC (DEFAULT - MAXIMUM)");
                    sql.append("ORDER BY t.salariu DESC ");
                }
            }
            
            // STEP 5: Determine limit
            int limit = 5; // Default to top 5
            if (originalQuery1.contains("primul") || originalQuery1.contains("prima") || 
                originalQuery1.contains("cel mai") || originalQuery1.contains("cea mai")) {
                limit = 1; // Just the top result for superlatives
                System.out.println("DEBUG: 🎯 LIMIT: 1 (superlative detected)");
            } else if (originalQuery1.contains("top 10") || originalQuery1.contains("primii 10")) {
                limit = 10;
                System.out.println("DEBUG: 🎯 LIMIT: 10 (top 10 requested)");
            } else {
                System.out.println("DEBUG: 🎯 LIMIT: 5 (default)");
            }
            
            sql.append("LIMIT ").append(limit);
            
            System.out.println("DEBUG: ===== MIN/MAX DETECTION COMPLETE =====");
            System.out.println("DEBUG: Generated MINMAX SQL: " + sql.toString());
            return sql.toString();
         
            case COUNT:
                sql.append("SELECT COUNT(*) AS numar_angajati FROM useri u");
                
                if (entities.containsKey("department_name")) {
                    sql.append(" LEFT JOIN departament d ON u.id_dep = d.id_dep");
                    sql.append(" WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                } else if (queryInfo.toString().contains("activ")) {
                    sql.append(" WHERE u.activ = 1");
                } else if (queryInfo.toString().contains("inactiv")) {
                    sql.append(" WHERE u.activ = 0");
                }
                
                System.out.println("DEBUG: Generated COUNT SQL: " + sql.toString());
                return sql.toString();
                
		case LIST:
                // LIST logic remains the same but with reasonable limit
                sql.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sql.append("t.denumire AS functie, u.email, u.telefon, t.salariu ");
                sql.append("FROM useri u ");
                sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                
                List<String> whereConditions2 = new ArrayList<>();
                if (entities.containsKey("department_name")) {
                    whereConditions2.add("UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%')");
                }
                
                if (!whereConditions2.isEmpty()) {
                    sql.append("WHERE ").append(String.join(" AND ", whereConditions2)).append(" ");
                }
                
                sql.append("ORDER BY u.nume, u.prenume ");
                
                // Add reasonable limit for LIST queries too
                if (originalQuery.contains("top") || LIMIT_NUMBER_PATTERN.matcher(originalQuery).find()) {
                    limitNumber = extractTopNumber(originalQuery);
                    sql.append("LIMIT ").append(limitNumber);
                }
                
                return sql.toString();
        
            default:
                // Default employee query
                String defaultSQL = "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, u.email, u.telefon " +
                                   "FROM useri u " +
                                   "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                                   "LEFT JOIN tipuri t ON u.tip = t.tip ";
                
                if (entities.containsKey("department_name")) {
                    defaultSQL += "WHERE UPPER(d.nume_dep) LIKE UPPER('%" + entities.get("department_name") + "%') ";
                }
                
                defaultSQL += "ORDER BY u.nume, u.prenume";
                
                return defaultSQL;
        }
    }
    
    /**
     * Helper method for debugging MIN/MAX detection
     */
    private void debugMinMaxDetection(String query) {
        System.out.println("DEBUG: ===== MIN/MAX DEBUG ANALYSIS =====");
        System.out.println("DEBUG: Original query: \"" + query + "\"");
        
        // Check for minimum indicators
        String[] minIndicators = {"minim", "cel mai mic", "cea mai mica", "mai mic", "mai mici"};
        System.out.println("DEBUG: Minimum indicators found:");
        for (String min : minIndicators) {
            if (query.contains(min)) {
                System.out.println("DEBUG: - FOUND: \"" + min + "\"");
            }
        }
        
        // Check for maximum indicators  
        String[] maxIndicators = {"maxim", "cel mai mare", "cea mai mare", "mai mare", "mai mari"};
        System.out.println("DEBUG: Maximum indicators found:");
        for (String max : maxIndicators) {
            if (query.contains(max)) {
                System.out.println("DEBUG: - FOUND: \"" + max + "\"");
            }
        }
        
        System.out.println("DEBUG: ===== MIN/MAX DEBUG COMPLETE =====");
    }

    
    /**
     * Generate SQL query for leave-related questions
     */
    private String generateLeaveQuery2(QueryInfo queryInfo) {
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
        
        System.out.println("DEBUG: ===== GENERATING POSITION QUERY =====");
        System.out.println("DEBUG: Query type: " + queryType);
        System.out.println("DEBUG: Entities: " + entities);
        
        StringBuilder sql = new StringBuilder();
        
        switch (queryType) {
            case COUNT:
                if (entities.containsKey("department_name")) {
                    System.out.println("DEBUG: Generating COUNT query for positions in department: " + entities.get("department_name"));
                    sql.append("SELECT COUNT(DISTINCT t.tip) AS numar_pozitii ");
                    sql.append("FROM useri u ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN tipuri t ON u.tip = t.tip ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%')");
                } else {
                    sql.append("SELECT COUNT(DISTINCT tip) AS numar_pozitii FROM tipuri");
                }
                
                System.out.println("DEBUG: Generated COUNT SQL: " + sql.toString());
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
                if (queryInfo.toString().contains("putin") || queryInfo.toString().contains("mic") || 
                    queryInfo.toString().contains("min") || queryInfo.toString().contains("minim") || 
                    queryInfo.toString().contains("putini") || queryInfo.toString().contains("putine")) {
                    sql.append(" ORDER BY t.salariu ASC");
                } else {
                    sql.append(" ORDER BY t.salariu DESC");
                }
                
                sql.append(" LIMIT 1");
                return sql.toString();
                
            case LIST:
                // Enhanced LIST query for positions
                if (entities.containsKey("department_name")) {
                    System.out.println("DEBUG: Generating LIST query for positions in department: " + entities.get("department_name"));
                    
                    sql.append("SELECT DISTINCT t.tip, t.denumire AS pozitie, t.salariu, t.ierarhie, ");
                    sql.append("d.nume_dep AS departament, ");
                    sql.append("dp.denumire_completa AS denumire_specifica, ");
                    sql.append("COUNT(u.id) AS numar_angajati ");
                    sql.append("FROM tipuri t ");
                    sql.append("LEFT JOIN useri u ON t.tip = u.tip ");
                    sql.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sql.append("LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep ");
                    sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER('%").append(entities.get("department_name")).append("%') ");
                    sql.append("GROUP BY t.tip, t.denumire, t.salariu, t.ierarhie, d.nume_dep, dp.denumire_completa ");
                    sql.append("ORDER BY t.ierarhie ASC, t.salariu DESC");
                    
                } else {
                    System.out.println("DEBUG: Generating LIST query for all positions");
                    
                    sql.append("SELECT t.tip, t.denumire AS pozitie, t.salariu, t.ierarhie, ");
                    sql.append("d.nume_dep AS departament_specific, ");
                    sql.append("(SELECT COUNT(*) FROM useri WHERE tip = t.tip) AS numar_angajati ");
                    sql.append("FROM tipuri t ");
                    sql.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                    sql.append("ORDER BY t.ierarhie ASC, t.salariu DESC");
                }
                
                System.out.println("DEBUG: Generated LIST SQL: " + sql.toString());
                return sql.toString();
                
            default:
                // Default to a list of all positions
                return "SELECT tip, denumire AS pozitie, salariu, ierarhie FROM tipuri ORDER BY ierarhie ASC, denumire";
        }
    }
    /*
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
    */
    /**
     * Enhanced debugging for entity detection
     */
    private void debugEntityDetection(String query) {
        System.out.println("DEBUG: ===== ENTITY DETECTION DEBUG =====");
        System.out.println("DEBUG: Query: \"" + query + "\"");
        
        // Check each keyword set
        System.out.println("DEBUG: Position keywords found: " + containsAny(query, POSITION_KEYWORDS));
        System.out.println("DEBUG: Department keywords found: " + containsAny(query, DEPARTMENT_KEYWORDS));
        System.out.println("DEBUG: Employee keywords found: " + containsAny(query, EMPLOYEE_KEYWORDS));
        System.out.println("DEBUG: Leave keywords found: " + containsAny(query, LEAVE_KEYWORDS));
        System.out.println("DEBUG: Count keywords found: " + containsAny(query, COUNT_KEYWORDS));
        
        // Check for specific position words
        String[] positionWords = {"functie", "functii", "pozitie", "pozitii", "post", "posturi", "rol", "roluri", "tip", "tipuri"};
        for (String word : positionWords) {
            if (query.contains(word)) {
                System.out.println("DEBUG: Found position word: \"" + word + "\"");
            }
        }
        
        // Check for department names
        for (Map.Entry<String, String> entry : KNOWN_DEPARTMENTS.entrySet()) {
            if (query.contains(entry.getKey())) {
                System.out.println("DEBUG: Found department: \"" + entry.getKey() + "\" -> " + entry.getValue());
            }
        }
        
        System.out.println("DEBUG: ===== ENTITY DETECTION DEBUG COMPLETE =====");
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
    public enum QueryType() {
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