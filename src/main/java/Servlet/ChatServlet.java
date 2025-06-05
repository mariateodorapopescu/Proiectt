package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.sql.ResultSetMetaData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.MyUser;
import Servlet.NaturalLanguageToSQLTranslator;
import Servlet.NaturalLanguageToSQLTranslator.QueryInfo;
import Servlet.NaturalLanguageToSQLTranslator.QueryType;

import Servlet.EnhancedNLPProcessor;
import Servlet.EnhancedNLPProcessor.AdvancedTokenization;
import Servlet.EnhancedNLPProcessor.TemporalExpression;
import Servlet.EnhancedNLPProcessor.NumericExpression;

import Servlet.CompanyPolicyProcessor;
import Servlet.CompanyPolicyProcessor.PolicyResponse;
import Servlet.CompanyPolicyProcessor.PolicyResult;

public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    private NaturalLanguageToSQLTranslator translator;
    
 // NEW: Enhanced NLP processing flag
    private boolean useEnhancedNLP = true;
    
    // NEW: Confidence threshold for query acceptance
    private double confidenceThreshold = 0.3;
    
    // NEW: Cache for recently processed queries
    private Map<String, EnhancedNLPProcessor.AdvancedTokenization> queryCache = new HashMap<>();
    private int maxCacheSize = 100;
    
    @Override
    public void init() throws ServletException {
        super.init();
        translator = new NaturalLanguageToSQLTranslator();
        System.out.println("DEBUG: ChatServlet initialized with translator");
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get query from the request
        String query = request.getParameter("query");
        
        System.out.println("DEBUG: Received query from frontend: \"" + query + "\"");
        
        if (query == null || query.isEmpty()) {
            System.out.println("DEBUG: Empty query received");
            sendErrorResponse(out, "Query parameter is missing");
            return;
        }
        
        // Get current user from session
        HttpSession session = request.getSession(false);
        if (session == null) {
            System.out.println("DEBUG: No active session found");
            sendErrorResponse(out, "No active session");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            System.out.println("DEBUG: No user logged in");
            sendErrorResponse(out, "User not logged in");
            return;
        }
        
        System.out.println("DEBUG: Processing query for user: " + currentUser.getUsername());
        
        // Process the query and generate a response
        try {
            processQuery(query, currentUser, out, session);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("DEBUG: Error processing query: " + e.getMessage());
            sendErrorResponse(out, "Error processing query: " + e.getMessage());
        }
    }

    /**
     * Configuration methods for tuning the enhanced system
     */

    /**
     * Enable/disable enhanced NLP processing
     */
    public void setEnhancedNLPEnabled(boolean enabled) {
        this.useEnhancedNLP = enabled;
        System.out.println("DEBUG: Enhanced NLP processing " + (enabled ? "enabled" : "disabled"));
    }

    /**
     * Set confidence threshold for query acceptance
     */
    public void setConfidenceThreshold(double threshold) {
        this.confidenceThreshold = Math.max(0.0, Math.min(1.0, threshold));
        System.out.println("DEBUG: Confidence threshold set to " + this.confidenceThreshold);
    }

    /**
     * Clear query cache
     */
    public void clearQueryCache() {
        this.queryCache.clear();
        System.out.println("DEBUG: Query cache cleared");
    }

    /**
     * Get cache statistics
     */
    public Map<String, Object> getCacheStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("cacheSize", queryCache.size());
        stats.put("maxCacheSize", maxCacheSize);
        stats.put("cacheHitRate", calculateCacheHitRate());
        return stats;
    }

    private double cacheHitCount = 0;
    private double totalQueryCount = 0;

    private double calculateCacheHitRate() {
        if (totalQueryCount == 0) return 0.0;
        return cacheHitCount / totalQueryCount;
    }
    
   
    /**
     * Main method to process natural language queries
     */
    /*
    private void processQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        String lowerQuery = query.toLowerCase();
        
        System.out.println("DEBUG: Processing normalized query: \"" + lowerQuery + "\"");
        
        // First check if it's a follow-up question or greeting to avoid unnecessary processing
        
        // Check if it's a follow-up question
        if (isFollowUpQuestion(lowerQuery)) {
            System.out.println("DEBUG: Detected follow-up question");
            // Process follow-up questions by retrieving previous results from session
            List<Map<String, Object>> lastQueryData = (List<Map<String, Object>>) session.getAttribute("lastQueryData");
            String lastQueryContext = (String) session.getAttribute("lastQueryContext");
            
            System.out.println("DEBUG: Last query context: " + lastQueryContext);
            System.out.println("DEBUG: Last query had " + (lastQueryData != null ? lastQueryData.size() : 0) + " results");
            
            if (lastQueryData != null && !lastQueryData.isEmpty()) {
                sendTableResponse(out, "Iată detaliile solicitate" + 
                        (lastQueryContext != null ? " despre " + lastQueryContext : "") + ":", 
                        lastQueryData);
            } else {
                sendSimpleTextResponse(out, "Îmi pare rău, nu am date anterioare pentru a vă oferi mai multe detalii. Vă rog să reformulați întrebarea specifică.");
            }
            return;
        }
        
        // Handle greetings
        if (isGreeting(lowerQuery)) {
            System.out.println("DEBUG: Detected greeting");
            sendSimpleTextResponse(out, "Bună ziua! Cu ce vă pot ajuta astăzi? Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
            return;
        }
        
        // Handle help requests
        if (isHelpRequest(lowerQuery)) {
            System.out.println("DEBUG: Detected help request");
            sendSimpleTextResponse(out, generateHelpResponse());
            return;
        }
        
        // Use translator to convert natural language query to SQL
        try {
            System.out.println("DEBUG: Using translator to convert query to SQL");
            QueryInfo queryInfo = translator.translateToSQL(query);
            
            System.out.println("DEBUG: Translator result: ");
            System.out.println("DEBUG: - Query type: " + queryInfo.getQueryType());
            System.out.println("DEBUG: - Entities: " + queryInfo.getEntities());
            System.out.println("DEBUG: - Requested attributes: " + queryInfo.getRequestedAttributes());
            System.out.println("DEBUG: - Is follow-up: " + queryInfo.isFollowUp());
            System.out.println("DEBUG: - Is stop request: " + queryInfo.isStopRequest());
            
            // Handle special cases first
            if (queryInfo.isFollowUp()) {
                System.out.println("DEBUG: Translator detected follow-up question");
                // Similar logic as above for follow-up questions
                List<Map<String, Object>> lastQueryData = (List<Map<String, Object>>) session.getAttribute("lastQueryData");
                String lastQueryContext = (String) session.getAttribute("lastQueryContext");
                
                if (lastQueryData != null && !lastQueryData.isEmpty()) {
                    sendTableResponse(out, "Iată detaliile solicitate" + 
                            (lastQueryContext != null ? " despre " + lastQueryContext : "") + ":", 
                            lastQueryData);
                } else {
                    sendSimpleTextResponse(out, "Îmi pare rău, nu am date anterioare pentru a vă oferi mai multe detalii. Vă rog să reformulați întrebarea specifică.");
                }
                return;
            }
            
            if (queryInfo.isStopRequest()) {
                System.out.println("DEBUG: Translator detected stop request");
                sendSimpleTextResponse(out, "Am înțeles, nu mai este nevoie de alte informații. Cu ce altceva vă pot ajuta?");
                session.removeAttribute("lastQueryData");
                session.removeAttribute("lastQueryContext");
                return;
            }
            
            // If we have a valid SQL query, execute it
            String sqlQuery = queryInfo.getSqlQuery();
            
            if (sqlQuery != null && !sqlQuery.isEmpty()) {
                System.out.println("DEBUG: Generated SQL query: " + sqlQuery);
                executeSQLQuery(sqlQuery, queryInfo, out, session);
                return;
            } else {
                System.out.println("DEBUG: No SQL query was generated by translator");
            }
        } catch (Exception e) {
            // Log the error but continue with legacy processing
            System.out.println("DEBUG: Error using translator: " + e.getMessage());
            e.printStackTrace();
        }
        
        // If translation failed or didn't produce a valid SQL query, fall back to legacy processing
        System.out.println("DEBUG: Falling back to legacy processing");
        
        if (lowerQuery.contains("angajat") || lowerQuery.contains("angajați") || lowerQuery.contains("personal")) {
            System.out.println("DEBUG: Legacy - processing employee query");
            processEmployeeQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("departament")) {
            System.out.println("DEBUG: Legacy - processing department query");
            processDepartmentQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("concediu") || lowerQuery.contains("concedii") || 
                   lowerQuery.contains("vacanță") || lowerQuery.contains("vacanta")) {
            System.out.println("DEBUG: Legacy - processing leave query");
            processLeaveQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("adeverință") || lowerQuery.contains("adeverinta") || 
                   lowerQuery.contains("adeverințe") || lowerQuery.contains("adeverinte")) {
            System.out.println("DEBUG: Legacy - processing certificate query");
            processCertificateQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("proiect") || lowerQuery.contains("proiecte")) {
            System.out.println("DEBUG: Legacy - processing project query");
            processProjectQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("tipuri") || lowerQuery.contains("pozitii") || 
                   lowerQuery.contains("poziții") || lowerQuery.contains("functii") || 
                   lowerQuery.contains("funcții")) {
            System.out.println("DEBUG: Legacy - processing positions query");
            processPositionsQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("salariu") || lowerQuery.contains("salarii") || 
                   lowerQuery.contains("venit") || lowerQuery.contains("venituri")) {
            System.out.println("DEBUG: Legacy - processing salary query");
            processSalaryQuery(lowerQuery, currentUser, out, session);
        } else {
            // Default response for unrecognized queries
            System.out.println("DEBUG: No recognizable query type found");
            sendSimpleTextResponse(out, "Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte. De exemplu: \"Câți angajați sunt în departamentul HR?\" sau \"Ce tipuri de poziții există în departamentul IT?\"");
        }
    }
    */
    
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
     * Send regulation summary response
     */
    private void sendRegulationSummaryResponse(PrintWriter out, String summary) {
        JSONObject response = new JSONObject();
        response.put("type", "regulation_summary");
        response.put("message", summary);
        response.put("timestamp", System.currentTimeMillis());
        
        JSONArray suggestions = new JSONArray();
        suggestions.put("Pot să lucrez de acasă conform regulamentului?");
        suggestions.put("Am voie să fac ore suplimentare?");
        suggestions.put("Ce beneficii am ca angajat?");
        suggestions.put("Cum se evaluează performanța?");
        
        response.put("followUpSuggestions", suggestions);
        
        out.println(response.toString());
    }

    /**
     * Send policy check response
     */
    private void sendPolicyCheckResponse(PrintWriter out, String originalQuery, PolicyResponse policyResponse) {
        JSONObject response = new JSONObject();
        response.put("type", "policy_check");
        response.put("originalQuery", originalQuery);
        response.put("result", policyResponse.getSimpleAnswer());
        response.put("message", policyResponse.getFormattedResponse());
        response.put("timestamp", System.currentTimeMillis());
        
        // Adaugă context vizual
        JSONObject context = new JSONObject();
        switch (policyResponse.getResult()) {
            case YES:
                context.put("status", "allowed");
                context.put("icon", "✅");
                context.put("color", "green");
                break;
            case NO:
                context.put("status", "forbidden");
                context.put("icon", "❌");
                context.put("color", "red");
                break;
            case CONDITIONAL:
                context.put("status", "conditional");
                context.put("icon", "⚠️");
                context.put("color", "orange");
                break;
            case UNCLEAR:
                context.put("status", "unclear");
                context.put("icon", "❓");
                context.put("color", "gray");
                break;
        }
        
        response.put("context", context);
        
        out.println(response.toString());
    }
    
    /**
     * Enhanced main method to process natural language queries
     * REPLACE YOUR EXISTING processQuery() METHOD WITH THIS COMPLETE VERSION
     */
    private void processQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        String lowerQuery = query.toLowerCase();
        
        System.out.println("DEBUG: Processing enhanced query: \"" + lowerQuery + "\"");
        
        // First check if it's a follow-up question or greeting to avoid unnecessary processing
        if (isFollowUpQuestion(lowerQuery)) {
            System.out.println("DEBUG: Detected follow-up question");
            handleFollowUpQuestion(out, session);
            return;
        }
        
        if (isGreeting(lowerQuery)) {
            System.out.println("DEBUG: Detected greeting");
            sendSimpleTextResponse(out, "Bună ziua! Cu ce vă pot ajuta astăzi? Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
            return;
        }
        
        if (isHelpRequest(lowerQuery)) {
            System.out.println("DEBUG: Detected help request");
            sendSimpleTextResponse(out, generateEnhancedHelpResponse());
            return;
        }
        
     // Check for regulation summary requests
        if (lowerQuery.contains("regulament") && 
            (lowerQuery.contains("rezumat") || lowerQuery.contains("introducere") || 
             lowerQuery.contains("politici") || lowerQuery.contains("sumar"))) {
            System.out.println("DEBUG: Detected regulation summary request");
            String summary = CompanyPolicyProcessor.generateRegulationSummary();
            sendRegulationSummaryResponse(out, summary);
            return;
        }

        // Check for policy permission requests
        if (lowerQuery.contains("pot sa") || lowerQuery.contains("pot să") || 
            lowerQuery.contains("am voie") || lowerQuery.contains("este permis")) {
            System.out.println("DEBUG: Detected policy permission request");
            PolicyResponse policyResponse = CompanyPolicyProcessor.checkPolicyPermission(query);
            sendPolicyCheckResponse(out, query, policyResponse);
            return;
        }
        
     // NEW: Enhanced NLP preprocessing
        EnhancedNLPProcessor.AdvancedTokenization tokenization = null;
        if (useEnhancedNLP) {
            // Add temporal detection debug
            debugTemporalDetection(query);
            
            tokenization = preprocessQuery(query);
            
            // Enhanced confidence analysis
            String confidenceLevel = EnhancedNLPProcessor.classifyQueryWithConfidence(
                tokenization.getEntityConfidences(), confidenceThreshold);
            
            // SPECIAL CASE: If we detect temporal expressions, boost confidence
            boolean hasTemporalExpressions = tokenization != null && !tokenization.getTemporalExpressions().isEmpty();
            boolean hasRecognizedEntities = tokenization != null && !tokenization.getEntityConfidences().isEmpty();
            boolean hasLeaveKeywords = query.contains("concediu") || query.contains("concedii");
            boolean hasEmployeeKeywords = query.contains("angajat") || query.contains("angajati");
            
            System.out.println("DEBUG: ===== CONFIDENCE ANALYSIS =====");
            System.out.println("DEBUG: Base confidence level: " + confidenceLevel);
            System.out.println("DEBUG: Has temporal expressions: " + hasTemporalExpressions);
            System.out.println("DEBUG: Has recognized entities: " + hasRecognizedEntities);
            System.out.println("DEBUG: Has leave keywords: " + hasLeaveKeywords);
            System.out.println("DEBUG: Has employee keywords: " + hasEmployeeKeywords);
            
            // FORCE PROCEED if we have temporal + entity combination
            boolean shouldProceed = hasRecognizedEntities || 
                                   (hasTemporalExpressions && (hasLeaveKeywords || hasEmployeeKeywords));
            
            System.out.println("DEBUG: Should proceed with translation: " + shouldProceed);
            System.out.println("DEBUG: =====================================");
            
            // Only show low confidence if we should NOT proceed
            if ("LOW_CONFIDENCE".equals(confidenceLevel) && !shouldProceed) {
                System.out.println("DEBUG: Showing low confidence suggestions");
                handleLowConfidenceQuery(query, tokenization, out);
                return;
            }
            
            if (shouldProceed) {
                System.out.println("DEBUG: ✅ PROCEEDING with enhanced translation");
            }
        
        // Use enhanced translator to convert natural language query to SQL
        try {
            System.out.println("DEBUG: Using translator to convert query to SQL");
            QueryInfo queryInfo = translator.translateToSQL(query);
            
            // NEW: Enhance queryInfo with advanced tokenization results
            if (tokenization != null) {
                enhanceQueryInfoWithTokenization(queryInfo, tokenization);
            }
            
            System.out.println("DEBUG: Translator result: ");
            System.out.println("DEBUG: - Query type: " + queryInfo.getQueryType());
            System.out.println("DEBUG: - Entities: " + queryInfo.getEntities());
            System.out.println("DEBUG: - Requested attributes: " + queryInfo.getRequestedAttributes());
            System.out.println("DEBUG: - Is follow-up: " + queryInfo.isFollowUp());
            System.out.println("DEBUG: - Is stop request: " + queryInfo.isStopRequest());
            
            // Handle special cases first
            if (queryInfo.isFollowUp()) {
                System.out.println("DEBUG: Translator detected follow-up question");
                handleFollowUpQuestion(out, session);
                return;
            }
            
            if (queryInfo.isStopRequest()) {
                System.out.println("DEBUG: Translator detected stop request");
                sendSimpleTextResponse(out, "Am înțeles, nu mai este nevoie de alte informații. Cu ce altceva vă pot ajuta?");
                session.removeAttribute("lastQueryData");
                session.removeAttribute("lastQueryContext");
                return;
            }
            
            // NEW: Enhanced SQL generation with temporal and numeric expressions
            String sqlQuery = queryInfo.getSqlQuery();
            if (tokenization != null) {
                sqlQuery = enhanceSQLWithTokenization(sqlQuery, tokenization, queryInfo);
            }
            
            if (sqlQuery != null && !sqlQuery.isEmpty()) {
                System.out.println("DEBUG: Enhanced SQL query: " + sqlQuery);
                executeEnhancedSQLQuery(sqlQuery, queryInfo, tokenization, out, session);
                return;
            } else {
                System.out.println("DEBUG: No SQL query was generated by translator");
            }
        } catch (Exception e) {
            // Log the error but continue with legacy processing
            System.out.println("DEBUG: Error using enhanced translator: " + e.getMessage());
            e.printStackTrace();
        }
        
        // If translation failed or didn't produce a valid SQL query, fall back to legacy processing
        System.out.println("DEBUG: Falling back to legacy processing");
        
        // ORIGINAL LEGACY PROCESSING CODE - PRESERVED EXACTLY AS IS
        if (lowerQuery.contains("angajat") || lowerQuery.contains("angajați") || lowerQuery.contains("personal")) {
            System.out.println("DEBUG: Legacy - processing employee query");
            processEmployeeQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("departament")) {
            System.out.println("DEBUG: Legacy - processing department query");
            processDepartmentQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("concediu") || lowerQuery.contains("concedii") || 
                   lowerQuery.contains("vacanță") || lowerQuery.contains("vacanta")) {
            System.out.println("DEBUG: Legacy - processing leave query");
            processLeaveQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("adeverință") || lowerQuery.contains("adeverinta") || 
                   lowerQuery.contains("adeverințe") || lowerQuery.contains("adeverinte")) {
            System.out.println("DEBUG: Legacy - processing certificate query");
            processCertificateQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("proiect") || lowerQuery.contains("proiecte")) {
            System.out.println("DEBUG: Legacy - processing project query");
            processProjectQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("tipuri") || lowerQuery.contains("pozitii") || 
                   lowerQuery.contains("poziții") || lowerQuery.contains("functii") || 
                   lowerQuery.contains("funcții")) {
            System.out.println("DEBUG: Legacy - processing positions query");
            processPositionsQuery(lowerQuery, currentUser, out, session);
        } else if (lowerQuery.contains("salariu") || lowerQuery.contains("salarii") || 
                   lowerQuery.contains("venit") || lowerQuery.contains("venituri")) {
            System.out.println("DEBUG: Legacy - processing salary query");
            processSalaryQuery(lowerQuery, currentUser, out, session);
        } else {
            // Enhanced default response with suggestions
            System.out.println("DEBUG: No recognizable query type found, providing enhanced suggestions");
            if (tokenization != null) {
                handleUnrecognizedQueryWithSuggestions(query, tokenization, out);
            } else {
                // Default response for unrecognized queries
                sendSimpleTextResponse(out, "Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte. De exemplu: \"Câți angajați sunt în departamentul HR?\" sau \"Ce tipuri de poziții există în departamentul IT?\"");
            }
        }
        }
    }
    
    /**
     * Enhanced follow-up question handling
     * REPLACE YOUR EXISTING handleFollowUpQuestion() calls with this if you have them, 
     * OR ADD THIS NEW METHOD
     */
    private void handleFollowUpQuestion(PrintWriter out, HttpSession session) {
        List<Map<String, Object>> lastQueryData = (List<Map<String, Object>>) session.getAttribute("lastQueryData");
        String lastQueryContext = (String) session.getAttribute("lastQueryContext");
        EnhancedNLPProcessor.AdvancedTokenization lastTokenization = 
            (EnhancedNLPProcessor.AdvancedTokenization) session.getAttribute("lastTokenization");
        
        System.out.println("DEBUG: Enhanced follow-up - Context: " + lastQueryContext);
        System.out.println("DEBUG: Enhanced follow-up - Data rows: " + (lastQueryData != null ? lastQueryData.size() : 0));
        
        if (lastQueryData != null && !lastQueryData.isEmpty()) {
            // If you already have a simple handleFollowUpQuestion method, this enhances it
            // Otherwise, this provides enhanced table response with additional context
            JSONObject response = new JSONObject();
            response.put("type", "table");
            response.put("message", "Iată toate detaliile" + 
                    (lastQueryContext != null ? " pentru " + lastQueryContext : "") + ":");
            response.put("data", new JSONArray(lastQueryData));
            response.put("rowCount", lastQueryData.size());
            response.put("isFollowUp", true);
            response.put("timestamp", System.currentTimeMillis());
            
            // Add enhanced metadata if available
            if (lastTokenization != null) {
                JSONObject metadata = new JSONObject();
                metadata.put("entityConfidences", lastTokenization.getEntityConfidences());
                metadata.put("temporalExpressions", lastTokenization.getTemporalExpressions().size());
                metadata.put("numericExpressions", lastTokenization.getNumericExpressions().size());
                response.put("metadata", metadata);
            }
            
            out.println(response.toString());
        } else {
            sendSimpleTextResponse(out, "Îmi pare rău, nu am date anterioare pentru a vă oferi mai multe detalii. " +
                    "Vă rog să reformulați întrebarea specifică.");
        }
    }

 // ====================================================================
 // ALL HELPER METHODS - ADD THESE TO YOUR ChatServlet CLASS
 // ====================================================================

 /**
  * Enhanced query preprocessing with advanced NLP
  */
 private EnhancedNLPProcessor.AdvancedTokenization preprocessQuery(String query) {
     System.out.println("DEBUG: Starting enhanced preprocessing for: \"" + query + "\"");
     
     // Check cache first
     if (queryCache.containsKey(query)) {
         System.out.println("DEBUG: Using cached tokenization");
         return queryCache.get(query);
     }
     
     // Perform advanced tokenization
     EnhancedNLPProcessor.AdvancedTokenization tokenization = 
         EnhancedNLPProcessor.performAdvancedTokenization(query);
     
     // Add to cache (with size limit)
     if (queryCache.size() >= maxCacheSize) {
         // Remove oldest entry (simple FIFO)
         String firstKey = queryCache.keySet().iterator().next();
         queryCache.remove(firstKey);
     }
     queryCache.put(query, tokenization);
     
     System.out.println("DEBUG: Enhanced preprocessing completed:");
     System.out.println("DEBUG: - Original tokens: " + tokenization.getOriginalTokens());
     System.out.println("DEBUG: - Semantic tokens: " + tokenization.getSemanticTokens());
     System.out.println("DEBUG: - Entity confidences: " + tokenization.getEntityConfidences());
     System.out.println("DEBUG: - Temporal expressions: " + tokenization.getTemporalExpressions().size());
     System.out.println("DEBUG: - Numeric expressions: " + tokenization.getNumericExpressions().size());
     
     return tokenization;
 }

 /**
  * Handle low confidence queries with smart suggestions
  */
 private void handleLowConfidenceQuery(String query, EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     JSONObject response = new JSONObject();
     response.put("type", "low_confidence_suggestion");
     response.put("message", "Nu sunt sigur că am înțeles corect întrebarea. Poate v-ați referit la:");
     
     JSONArray suggestions = new JSONArray();
     
     // Generate suggestions based on detected entities
     List<String> enhancedSuggestions = EnhancedNLPProcessor.generateEnhancedSuggestions(
         query, tokenization.getEntityConfidences());
     
     for (String suggestion : enhancedSuggestions) {
         suggestions.put(suggestion);
     }
     
     // Add department-specific suggestions if department detected
     String detectedDept = EnhancedNLPProcessor.detectDepartmentWithFuzzyMatching(query);
     if (detectedDept != null) {
         suggestions.put("Câți angajați sunt în departamentul " + detectedDept + "?");
         suggestions.put("Ce funcții există în departamentul " + detectedDept + "?");
     }
     
     response.put("suggestions", suggestions);
     response.put("confidence_info", tokenization.getEntityConfidences());
     out.println(response.toString());
 }

 /**
  * Handle unrecognized queries with enhanced suggestions
  */
 private void handleUnrecognizedQueryWithSuggestions(String query, EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     JSONObject response = new JSONObject();
     response.put("type", "unrecognized_with_suggestions");
     response.put("message", "Nu am putut înțelege această întrebare. Iată câteva exemple de întrebări pe care le pot procesa:");
     
     JSONArray examples = new JSONArray();
     
     // Generate contextual examples based on detected patterns
     if (!tokenization.getEntityConfidences().isEmpty()) {
         List<String> suggestions = EnhancedNLPProcessor.generateEnhancedSuggestions(
             query, tokenization.getEntityConfidences());
         for (String suggestion : suggestions) {
             examples.put(suggestion);
         }
     } else {
         // Default examples
         examples.put("Câți angajați sunt în departamentul IT?");
         examples.put("Arată-mi concediile aprobate din această lună");
         examples.put("Care este salariul mediu în firmă?");
         examples.put("Ce tipuri de adeverințe au fost solicitate?");
     }
     
     response.put("examples", examples);
     out.println(response.toString());
 }

 /**
  * Enhance QueryInfo with advanced tokenization results
  */
 private void enhanceQueryInfoWithTokenization(QueryInfo queryInfo, EnhancedNLPProcessor.AdvancedTokenization tokenization) {
     // Add enhanced entity information
     Map<String, String> existingEntities = queryInfo.getEntities();
     
     // Add entity confidences as a special entity
     if (!tokenization.getEntityConfidences().isEmpty()) {
         // Find the most confident entity
         String topEntity = tokenization.getEntityConfidences().entrySet().stream()
             .max(Map.Entry.comparingByValue())
             .map(Map.Entry::getKey)
             .orElse(null);
         
         if (topEntity != null && !existingEntities.containsKey("entity")) {
             existingEntities.put("entity", topEntity.toLowerCase());
         }
     }
     
     // Add detected department with fuzzy matching
     String detectedDept = EnhancedNLPProcessor.detectDepartmentWithFuzzyMatching(
         String.join(" ", tokenization.getNormalizedTokens()));
     if (detectedDept != null && !existingEntities.containsKey("department_name")) {
         existingEntities.put("department_name", detectedDept);
     }
     
     // Add temporal information
     if (!tokenization.getTemporalExpressions().isEmpty()) {
         EnhancedNLPProcessor.TemporalExpression firstTemporal = tokenization.getTemporalExpressions().get(0);
         existingEntities.put("temporal_expression", firstTemporal.getNormalizedText());
         existingEntities.put("temporal_type", firstTemporal.getTemporalType());
     }
     
     // Add numeric information
     if (!tokenization.getNumericExpressions().isEmpty()) {
         EnhancedNLPProcessor.NumericExpression firstNumeric = tokenization.getNumericExpressions().get(0);
         existingEntities.put("numeric_value", firstNumeric.getValue().toString());
         existingEntities.put("numeric_operator", firstNumeric.getOperator());
         existingEntities.put("numeric_context", firstNumeric.getContext());
     }
 }

 /**
  * Enhance SQL with temporal and numeric expressions
  */
 private String enhanceSQLWithTokenization(String sqlQuery, EnhancedNLPProcessor.AdvancedTokenization tokenization, QueryInfo queryInfo) {
     if (sqlQuery == null || sqlQuery.trim().isEmpty()) {
         return sqlQuery;
     }
     
     StringBuilder enhancedSQL = new StringBuilder(sqlQuery);
     
     // Add temporal filters
     for (EnhancedNLPProcessor.TemporalExpression temporal : tokenization.getTemporalExpressions()) {
         String sqlCondition = temporal.getSqlCondition();
         if (sqlCondition != null) {
             // Determine appropriate column based on entity type
             String columnName = getTemporalColumnForEntity(queryInfo.getEntities().get("entity"));
             if (columnName != null) {
                 sqlCondition = sqlCondition.replace("column_name", columnName);
                 
                 // Add WHERE clause or append to existing WHERE
                 if (enhancedSQL.toString().toLowerCase().contains("where")) {
                     enhancedSQL.append(" AND ").append(sqlCondition);
                 } else {
                     enhancedSQL.append(" WHERE ").append(sqlCondition);
                 }
             }
         }
     }
     
     // Add numeric filters
     for (EnhancedNLPProcessor.NumericExpression numeric : tokenization.getNumericExpressions()) {
         String columnName = getNumericColumnForContext(numeric.getContext());
         if (columnName != null) {
             String condition = columnName + " " + numeric.getOperator() + " " + numeric.getValue();
             
             // Add WHERE clause or append to existing WHERE
             if (enhancedSQL.toString().toLowerCase().contains("where")) {
                 enhancedSQL.append(" AND ").append(condition);
             } else {
                 enhancedSQL.append(" WHERE ").append(condition);
             }
         }
     }
     
     return enhancedSQL.toString();
 }

 /**
  * Get appropriate temporal column for entity type
  */
 private String getTemporalColumnForEntity(String entityType) {
     if (entityType == null) return null;
     
     switch (entityType.toLowerCase()) {
         case "employee":
             return "u.data_ang";
         case "leave":
             return "c.start_c";
         case "certificate":
             return "a.creare";
         case "project":
             return "p.start";
         default:
             return null;
     }
 }

 /**
  * Get appropriate numeric column for context
  */
 private String getNumericColumnForContext(String context) {
     if (context == null) return null;
     
     switch (context.toLowerCase()) {
         case "salary":
             return "t.salariu";
         case "age":
             return "TIMESTAMPDIFF(YEAR, u.data_nasterii, CURDATE())";
         case "count":
             return "COUNT(*)";
         default:
             return null;
     }
 }

 /**
  * Generate enhanced context from query info and tokenization
  */
 private String generateEnhancedContextFromQueryInfo(QueryInfo queryInfo, EnhancedNLPProcessor.AdvancedTokenization tokenization) {
     StringBuilder context = new StringBuilder();
     
     // Base entity context
     String entity = queryInfo.getEntities().getOrDefault("entity", "");
     switch (entity) {
         case "employee":
             context.append("angajați");
             break;
         case "department":
             context.append("departamente");
             break;
         case "leave":
             context.append("concedii");
             break;
         case "position":
             context.append("poziții");
             break;
         case "project":
             context.append("proiecte");
             break;
         case "certificate":
             context.append("adeverințe");
             break;
         default:
             context.append("rezultate");
     }
     
     // Add department context
     String department = queryInfo.getEntities().get("department_name");
     if (department != null) {
         context.append(" din departamentul ").append(department);
     }
     
     // Add temporal context
     if (tokenization != null && !tokenization.getTemporalExpressions().isEmpty()) {
         EnhancedNLPProcessor.TemporalExpression temporal = tokenization.getTemporalExpressions().get(0);
         context.append(" (").append(temporal.getNormalizedText()).append(")");
     }
     
     // Add numeric context
     if (tokenization != null && !tokenization.getNumericExpressions().isEmpty()) {
         EnhancedNLPProcessor.NumericExpression numeric = tokenization.getNumericExpressions().get(0);
         context.append(" (").append(numeric.getOperator()).append(" ").append(numeric.getValue()).append(")");
     }
     
     return context.toString();
 }

 /**
  * Handle empty results with enhanced suggestions
  */
 private void handleEmptyResultsWithSuggestions(QueryInfo queryInfo, EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     JSONObject response = new JSONObject();
     response.put("type", "empty_with_suggestions");
     
     String entity = queryInfo.getEntities().getOrDefault("entity", "");
     String department = queryInfo.getEntities().get("department_name");
     
     String message = "Nu am găsit rezultate pentru această căutare";
     if (department != null) {
         message += " în departamentul " + department;
     }
     message += ".";
     
     response.put("message", message);
     
     // Generate contextual suggestions
     JSONArray suggestions = new JSONArray();
     
     switch (entity) {
         case "employee":
             suggestions.put("Arată-mi toți angajații din firmă");
             if (department != null) {
                 suggestions.put("Ce departamente sunt similare cu " + department + "?");
             }
             suggestions.put("Câți angajați sunt în fiecare departament?");
             break;
             
         case "department":
             suggestions.put("Ce departamente există în firmă?");
             suggestions.put("Care sunt toate departamentele disponibile?");
             break;
             
         case "leave":
             suggestions.put("Cine este în concediu în acest moment?");
             suggestions.put("Arată-mi toate concediile din această lună");
             if (department != null) {
                 suggestions.put("Ce concedii sunt în alte departamente?");
             }
             break;
             
         default:
             suggestions.put("Arată-mi informații generale despre firmă");
             suggestions.put("Ce departamente există?");
             suggestions.put("Câți angajați sunt în total?");
     }
     
     response.put("suggestions", suggestions);
     out.println(response.toString());
 }

 /**
  * Format enhanced response based on query type and tokenization
  */
 private void formatEnhancedResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                   EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     
     // Determine response format based on query type and result size
     switch (queryInfo.getQueryType()) {
         case COUNT:
             handleCountResponseEnhanced(resultList, queryInfo, tokenization, out);
             break;
             
         case MINMAX:
             handleMinMaxResponseEnhanced(resultList, queryInfo, tokenization, out);
             break;
             
         case LIST:
         default:
             handleListResponseEnhanced(resultList, queryInfo, tokenization, out);
             break;
     }
 }

 /**
  * Handle count responses with enhanced formatting
  */
 private void handleCountResponseEnhanced(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                        EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     if (resultList.size() == 1 && resultList.get(0).size() == 1) {
         // Simple count result
         Object countResult = resultList.get(0).values().iterator().next();
         String message = formatEnhancedCountMessage(countResult, queryInfo, tokenization);
         sendEnhancedTextResponse(out, message, queryInfo, tokenization);
     } else {
         // Complex count result - show as table
         String context = generateEnhancedContextFromQueryInfo(queryInfo, tokenization);
         sendEnhancedTableResponse(out, "Iată rezultatele numărării pentru " + context + ":", 
                                 resultList, queryInfo, tokenization);
     }
 }

 /**
  * Handle min/max responses with enhanced formatting
  */
 private void handleMinMaxResponseEnhanced(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                         EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     String context = generateEnhancedContextFromQueryInfo(queryInfo, tokenization);
     
     boolean isMinQuery = false;
     if (tokenization != null) {
         List<String> tokens = tokenization.getNormalizedTokens();
         isMinQuery = tokens.contains("mic") || tokens.contains("minim") || tokens.contains("putin");
     }
     
     String message = "Iată " + (isMinQuery ? "cele mai mici" : "cele mai mari") + 
                     " valori pentru " + context + ":";
     
     sendEnhancedTableResponseWithConfirmation(out, message, resultList, queryInfo, tokenization);
 }

 /**
  * Handle list responses with enhanced formatting
  */
 private void handleListResponseEnhanced(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                       EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
     String context = generateEnhancedContextFromQueryInfo(queryInfo, tokenization);
     
     if (resultList.size() > 15) {
         // Large result set - offer confirmation
         sendEnhancedTableResponseWithConfirmation(out, 
                 "Am găsit " + resultList.size() + " rezultate pentru " + context + ". " + 
                 "Doriți să vedeți toate detaliile?", resultList, queryInfo, tokenization);
     } else {
         // Normal result set
         sendEnhancedTableResponse(out, "Iată rezultatele pentru " + context + ":", 
                                 resultList, queryInfo, tokenization);
     }
 }

 /**
  * Format enhanced count message
  */
 private String formatEnhancedCountMessage(Object countResult, QueryInfo queryInfo, 
                                         EnhancedNLPProcessor.AdvancedTokenization tokenization) {
     int count = 0;
     
     // Convert the count result to an integer
     if (countResult instanceof Number) {
         count = ((Number) countResult).intValue();
     } else {
         try {
             count = Integer.parseInt(countResult.toString());
         } catch (NumberFormatException e) {
             return "Am găsit " + countResult + " rezultate.";
         }
     }
     
     String entity = queryInfo.getEntities().getOrDefault("entity", "");
     String department = queryInfo.getEntities().get("department_name");
     
     // Enhanced context from tokenization
     String additionalContext = "";
     if (tokenization != null) {
         if (!tokenization.getTemporalExpressions().isEmpty()) {
             additionalContext += " " + tokenization.getTemporalExpressions().get(0).getNormalizedText();
         }
         if (!tokenization.getNumericExpressions().isEmpty()) {
             EnhancedNLPProcessor.NumericExpression numeric = tokenization.getNumericExpressions().get(0);
             additionalContext += " (cu " + numeric.getContext() + " " + numeric.getOperator() + " " + numeric.getValue() + ")";
         }
     }
     
     // Format based on entity type
     switch (entity) {
         case "employee":
             return "Am găsit " + count + " angajați" + 
                     (department != null ? " în departamentul " + department : "") + 
                     additionalContext + ".";
         case "department":
             return "În firmă există " + count + " departamente" + additionalContext + ".";
         case "leave":
             return "Am găsit " + count + " concedii" + 
                     (department != null ? " în departamentul " + department : "") + 
                     additionalContext + ".";
         case "position":
             return "Există " + count + " tipuri de poziții" + 
                     (department != null ? " în departamentul " + department : "") + 
                     additionalContext + ".";
         case "certificate":
             return "Am găsit " + count + " adeverințe" + 
                     (department != null ? " pentru angajații din departamentul " + department : "") + 
                     additionalContext + ".";
         case "project":
             return "Există " + count + " proiecte" + 
                     (department != null ? " în departamentul " + department : "") + 
                     additionalContext + ".";
         default:
             return "Am găsit " + count + " rezultate" + additionalContext + ".";
     }
 }
 
 private void sendEnhancedTableResponse(PrintWriter out, String message, List<Map<String, Object>> data,
                                      QueryInfo queryInfo, EnhancedNLPProcessor.AdvancedTokenization tokenization) {
     System.out.println("DEBUG: Sending enhanced table response with " + data.size() + " rows");
     
     JSONObject response = new JSONObject();
     response.put("type", "table");
     response.put("message", message);
     response.put("data", new JSONArray(data));
     response.put("rowCount", data.size());
     response.put("timestamp", System.currentTimeMillis());
     
     // Add enhanced metadata
     if (tokenization != null) {
         JSONObject metadata = new JSONObject();
         metadata.put("queryType", queryInfo.getQueryType().toString());
         metadata.put("entityConfidences", tokenization.getEntityConfidences());
         metadata.put("semanticTokens", tokenization.getSemanticTokens());
         response.put("metadata", metadata);
     }
     
     out.println(response.toString());
 }

 private void sendEnhancedTableResponseWithConfirmation(PrintWriter out, String message, List<Map<String, Object>> data,
                                                       QueryInfo queryInfo, EnhancedNLPProcessor.AdvancedTokenization tokenization) {
     System.out.println("DEBUG: Sending enhanced table response with confirmation");
     
     JSONObject response = new JSONObject();
     response.put("type", "table");
     response.put("message", message);
     response.put("data", new JSONArray(data));
     response.put("needsConfirmation", true);
     response.put("rowCount", data.size());
     response.put("timestamp", System.currentTimeMillis());
     
     // Add enhanced metadata
     if (tokenization != null) {
         JSONObject metadata = new JSONObject();
         metadata.put("queryType", queryInfo.getQueryType().toString());
         metadata.put("entityConfidences", tokenization.getEntityConfidences());
         metadata.put("isLargeResultSet", true);
         response.put("metadata", metadata);
     }
     
     out.println(response.toString());
 }
    
    /**
     * Enhanced result set formatting with better data types
     * ADD THIS NEW METHOD OR REPLACE YOUR EXISTING resultSetToList() calls with resultSetToListEnhanced()
     */
    private List<Map<String, Object>> resultSetToListEnhanced(ResultSet rs) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        ResultSetMetaData md = rs.getMetaData();
        int columnCount = md.getColumnCount();
        
        System.out.println("DEBUG: Converting enhanced ResultSet with " + columnCount + " columns");
        
        int rowCount = 0;
        while (rs.next()) {
            rowCount++;
            Map<String, Object> row = new HashMap<>();
            for (int i = 1; i <= columnCount; i++) {
                String columnName = md.getColumnLabel(i);
                Object value = rs.getObject(i);
                
                // Enhanced formatting based on column type and name
                if (value instanceof java.sql.Date) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
                    value = sdf.format(value);
                } else if (value instanceof java.sql.Timestamp) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm");
                    value = sdf.format(value);
                } else if (value instanceof java.sql.Time) {
                    SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
                    value = sdf.format(value);
                }
                
                // Enhanced currency and numeric formatting
                if (columnName.toLowerCase().contains("salariu") && value instanceof Number) {
                    double salary = ((Number) value).doubleValue();
                    if (salary >= 1000) {
                        value = String.format("%.0f RON", salary);
                    } else {
                        value = String.format("%.2f RON", salary);
                    }
                } else if (columnName.toLowerCase().contains("procent") && value instanceof Number) {
                    value = String.format("%.1f%%", ((Number) value).doubleValue());
                } else if (columnName.toLowerCase().contains("durata") && value instanceof Number) {
                    int days = ((Number) value).intValue();
                    if (days == 1) {
                        value = "1 zi";
                    } else {
                        value = days + " zile";
                    }
                }
                
                // Handle null values more gracefully
                if (value == null) {
                    value = "-";
                }
                
                row.put(columnName, value);
            }
            list.add(row);
            
            if (rowCount <= 3) {
                System.out.println("DEBUG: Enhanced sample row " + rowCount + ": " + row);
            }
        }
        
        System.out.println("DEBUG: Enhanced conversion completed - " + rowCount + " rows total");
        return list;
    }
    
    /**
     * Execute a SQL query and format the result
     */
    private void executeSQLQuery(String sqlQuery, QueryInfo queryInfo, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            System.out.println("DEBUG: Executing SQL query: " + sqlQuery);
            
            PreparedStatement stmt = conn.prepareStatement(sqlQuery);
            ResultSet rs = stmt.executeQuery();
            
            // Print result set metadata
            ResultSetMetaData metaData = rs.getMetaData();
            int columnCount = metaData.getColumnCount();
            
            System.out.println("DEBUG: Result set has " + columnCount + " columns:");
            for (int i = 1; i <= columnCount; i++) {
                System.out.println("DEBUG: Column " + i + ": " + metaData.getColumnName(i) + 
                                  " (Type: " + metaData.getColumnTypeName(i) + ")");
            }
            
            // Convert the result to a list of maps
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            System.out.println("DEBUG: Query returned " + resultList.size() + " rows");
            
            if (resultList.size() > 0) {
                // Print sample of result data (first row)
                System.out.println("DEBUG: Sample result data (first row):");
                Map<String, Object> firstRow = resultList.get(0);
                for (Map.Entry<String, Object> entry : firstRow.entrySet()) {
                    System.out.println("DEBUG: " + entry.getKey() + " = " + entry.getValue());
                }
            }
            
            // Save the result in session for possible follow-up questions
            session.setAttribute("lastQueryData", resultList);
            
            // Identify the main entity for context in follow-up questions
            Map<String, String> entities = queryInfo.getEntities();
            String entityType = entities.getOrDefault("entity", "");
            String entityName = entities.getOrDefault("department_name", "");
            String context = getContextFromEntity(entityType, entityName);
            session.setAttribute("lastQueryContext", context);
            
            System.out.println("DEBUG: Context for follow-up: " + context);
            
            if (resultList.isEmpty()) {
                System.out.println("DEBUG: No results found");
                sendSimpleTextResponse(out, "Nu am găsit rezultate care să corespundă criteriilor dvs.");
                return;
            }
            
            // Format the response based on query type
            switch (queryInfo.getQueryType()) {
                case COUNT:
                    System.out.println("DEBUG: Formatting as COUNT response");
                    // For COUNT, we usually have a single value
                    if (resultList.size() == 1 && resultList.get(0).size() == 1) {
                        // Get the first (and only) value
                        Object countResult = resultList.get(0).values().iterator().next();
                        System.out.println("DEBUG: Count result: " + countResult);
                        
                        // Format the response based on entity type
                        String message = formatCountResponse(countResult, entityType, entityName);
                        sendSimpleTextResponse(out, message);
                    } else {
                        // If it's not a simple count, show the result as a table
                        sendTableResponse(out, "Iată rezultatele numărării pentru " + context + ":", resultList);
                    }
                    break;
                    
                case MINMAX:
                    System.out.println("DEBUG: Formatting as MINMAX response");
                    // For MINMAX queries, show the results with a confirmation option for more details
                    String minMaxMessage = "Iată " + 
                            (queryInfo.toString().contains("mare") || queryInfo.toString().contains("max") ? 
                            "cele mai mari valori" : "cele mai mici valori") + 
                            " pentru " + context + ". Doriți să vedeți toate detaliile?";
                    sendTableResponseWithConfirmation(out, minMaxMessage, resultList);
                    break;
                    
                case LIST:
                    System.out.println("DEBUG: Formatting as LIST response");
                    // For LIST queries, check the size of the result
                    if (resultList.size() > 10) {
                        // For large result sets, show with confirmation
                        sendTableResponseWithConfirmation(out, 
                                "Am găsit " + resultList.size() + " rezultate pentru " + context + ". " + 
                                "Doriți să vedeți toate detaliile?", resultList);
                    } else {
                        // For smaller result sets, show immediately
                        sendTableResponse(out, "Iată rezultatele pentru " + context + ":", resultList);
                    }
                    break;
                    
                default:
                    System.out.println("DEBUG: Formatting as default response");
                    // Default to a simple table response
                    sendTableResponse(out, "Iată rezultatele pentru " + context + ":", resultList);
                    break;
            }
        } catch (SQLException e) {
            System.out.println("DEBUG: SQL Exception: " + e.getMessage());
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la executarea interogării SQL: " + e.getMessage());
        }
    }
    
    /**
     * Format a count response based on entity type
     */
    private String formatCountResponse(Object countResult, String entityType, String entityName) {
        int count = 0;
        
        // Convert the count result to an integer
        if (countResult instanceof Number) {
            count = ((Number) countResult).intValue();
        } else {
            try {
                count = Integer.parseInt(countResult.toString());
            } catch (NumberFormatException e) {
                // If conversion fails, return a generic message
                System.out.println("DEBUG: Failed to convert count result to number: " + countResult);
                return "Am găsit " + countResult + " rezultate.";
            }
        }
        
        System.out.println("DEBUG: Formatting count response for entity type: " + entityType + 
                          ", entity name: " + entityName + ", count: " + count);
        
        // Format based on entity type
        switch (entityType) {
            case "employee":
                return "Am găsit " + count + " angajați" + 
                        (entityName != null && !entityName.isEmpty() ? " în departamentul " + entityName : "") + ".";
                
            case "department":
                return "În firmă există " + count + " departamente" + 
                        (entityName != null && !entityName.isEmpty() ? " incluzând departamentul " + entityName : "") + ".";
                
            case "leave":
                return "Am găsit " + count + " concedii" + 
                        (entityName != null && !entityName.isEmpty() ? " în departamentul " + entityName : "") + ".";
                
            case "position":
                return "Există " + count + " tipuri de poziții" + 
                        (entityName != null && !entityName.isEmpty() ? " în departamentul " + entityName : "") + ".";
                
            case "certificate":
                return "Am găsit " + count + " adeverințe" + 
                        (entityName != null && !entityName.isEmpty() ? " pentru angajații din departamentul " + entityName : "") + ".";
                
            case "office":
                return "Compania are " + count + " sedii.";
                
            case "project":
                return "Există " + count + " proiecte" + 
                        (entityName != null && !entityName.isEmpty() ? " în departamentul " + entityName : "") + ".";
                
            default:
                return "Am găsit " + count + " rezultate.";
        }
    }
    
    // Additional methods (getContextFromEntity, isFollowUpQuestion, etc.) remain the same...
    
    /**
     * Get a context string based on entity type and name
     */
    private String getContextFromEntity(String entityType, String entityName) {
        switch (entityType) {
            case "employee":
                return "angajați" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "department":
                return "departamente" + (entityName != null && !entityName.isEmpty() ? " (inclusiv " + entityName + ")" : "");
                
            case "leave":
                return "concedii" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "position":
                return "poziții" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "salary":
                return "salarii" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "certificate":
                return "adeverințe" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "office":
                return "sedii";
                
            case "project":
                return "proiecte" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "team":
                return "echipe" + (entityName != null && !entityName.isEmpty() ? " din departamentul " + entityName : "");
                
            case "firm":
                return "companie";
                
            default:
                return "rezultate";
        }
    }
    
    /**
     * Check if a message is a follow-up question
     */
    private boolean isFollowUpQuestion(String text) {
        // Simple patterns for follow-up questions
        boolean isFollowUp = text.equals("da") || 
               text.equals("sigur") || 
               text.equals("bineințeles") || 
               text.equals("bineinteles") || 
               text.equals("te rog") || 
               text.equals("vreau") || 
               text.startsWith("da, ") || 
               text.contains("mai multe detalii") ||
               text.contains("arata-mi detalii") ||
               text.contains("arată-mi detalii") ||
               text.contains("vreau sa vad") ||
               text.contains("vreau să văd");
               
        System.out.println("DEBUG: Checking if follow-up question: " + text + " -> " + isFollowUp);
        return isFollowUp;
    }
    
 // ÎMBUNĂTĂȚIRI PENTRU ChatServlet.java - TODO Query Support

    /**
     * Enhanced executeEnhancedSQLQuery pentru TODO queries
     * ADD this method or REPLACE your existing one
     */
    private void executeEnhancedSQLQuery(String sqlQuery, QueryInfo queryInfo, 
                                       EnhancedNLPProcessor.AdvancedTokenization tokenization, 
                                       PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            System.out.println("DEBUG: Executing enhanced SQL query: " + sqlQuery);
            
            // Handle personal queries that need current user ID
            String entityType = queryInfo.getEntities().getOrDefault("entity", "");
            if ("personal".equals(entityType)) {
                sqlQuery = handlePersonalQuery(sqlQuery, session);
            }
            
            PreparedStatement stmt = conn.prepareStatement(sqlQuery);
            ResultSet rs = stmt.executeQuery();
            
            // Convert the result to a list of maps with enhanced formatting
            List<Map<String, Object>> resultList = resultSetToListEnhanced(rs);
            
            System.out.println("DEBUG: Enhanced query returned " + resultList.size() + " rows");
            
            // Save the result in session for possible follow-up questions
            session.setAttribute("lastQueryData", resultList);
            session.setAttribute("lastQueryInfo", queryInfo);
            session.setAttribute("lastTokenization", tokenization);
            
            // Generate enhanced context for follow-up questions
            String context = generateEnhancedContextFromQueryInfo(queryInfo, tokenization);
            session.setAttribute("lastQueryContext", context);
            
            if (resultList.isEmpty()) {
                handleEmptyResultsWithSuggestions(queryInfo, tokenization, out);
                return;
            }
            
            // Enhanced response formatting based on entity type
            formatTODOResponse(resultList, queryInfo, tokenization, out);
            
        } catch (SQLException e) {
            System.out.println("DEBUG: Enhanced SQL Exception: " + e.getMessage());
            e.printStackTrace();
            handleSQLError(e, queryInfo, tokenization, out);
        }
    }

    /**
     * Handle personal queries by replacing placeholder with current user identifier
     */
    private String handlePersonalQuery(String sqlQuery, HttpSession session) {
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser != null) {
            // Since we use username, we need to modify the query to use username instead of ID
            if (sqlQuery.contains("WHERE u.id = ?")) {
                sqlQuery = sqlQuery.replace("WHERE u.id = ?", "WHERE u.username = '" + currentUser.getUsername() + "'");
            } else if (sqlQuery.contains("u.id = ?")) {
                sqlQuery = sqlQuery.replace("u.id = ?", "u.username = '" + currentUser.getUsername() + "'");
            }
            System.out.println("DEBUG: Personal query for username: " + currentUser.getUsername());
        }
        return sqlQuery;
    }

    /**
     * Enhanced response formatting for TODO queries
     */
    private void formatTODOResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                  EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
        
        String entityType = queryInfo.getEntities().getOrDefault("entity", "");
        System.out.println("DEBUG: Formatting TODO response for entity: " + entityType);
        
        switch (entityType) {
            case "personal":
                handlePersonalResponse(resultList, queryInfo, out);
                break;
            case "project":
                handleProjectResponse(resultList, queryInfo, out);
                break;
            case "certificate":
                handleCertificateResponse(resultList, queryInfo, out);
                break;
            case "location":
                handleLocationResponse(resultList, queryInfo, out);
                break;
            case "average":
                handleAverageResponse(resultList, queryInfo, out);
                break;
            case "task":
                handleTaskResponse(resultList, queryInfo, out);
                break;
            case "availability":
                handleAvailabilityResponse(resultList, queryInfo, out);
                break;
            case "work_mode":
                handleWorkModeResponse(resultList, queryInfo, out);
                break;
            case "leave":
                handleEnhancedLeaveResponse(resultList, queryInfo, tokenization, out);
                break;
                // NEW: Semi-FAQ cases
            case "task_scheduling":
                handleTaskSchedulingResponse(resultList, queryInfo, out);
                break;
            case "calendar":
                handleCalendarResponse(resultList, queryInfo, out);
                break;
            case "legal_holidays":
                handleLegalHolidaysResponse(resultList, queryInfo, out);
                break;
            case "month_days":
                handleMonthDaysResponse(resultList, queryInfo, out);
            case "regulation_summary":
                handleRegulationSummaryResponse(resultList, queryInfo, out);
                break;
            case "policy_check":
                handlePolicyCheckResponse(resultList, queryInfo, out);
                break;
            default:
                // Fall back to existing formatting
                formatEnhancedResponse(resultList, queryInfo, tokenization, out);
        }
    }
    
 // 3. Adaugă aceste metode în ChatServlet:

    /**
     * Handle regulation summary responses
     */
    private void handleRegulationSummaryResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        System.out.println("DEBUG: Handling regulation summary request");
        
        // Generează rezumatul regulamentului
        String summary = CompanyPolicyProcessor.generateRegulationSummary();
        
        JSONObject response = new JSONObject();
        response.put("type", "regulation_summary");
        response.put("message", summary);
        response.put("timestamp", System.currentTimeMillis());
        
        // Adaugă sugestii pentru întrebări de follow-up
        JSONArray followUpSuggestions = new JSONArray();
        followUpSuggestions.put("Pot să lucrez de acasă conform regulamentului?");
        followUpSuggestions.put("Am voie să fac ore suplimentare?");
        followUpSuggestions.put("Ce beneficii am ca angajat?");
        followUpSuggestions.put("Cum se evaluează performanța?");
        followUpSuggestions.put("Ce sancțiuni există pentru întârzieri?");
        
        response.put("followUpSuggestions", followUpSuggestions);
        
        // Adaugă link către regulamentul complet
        JSONObject additionalInfo = new JSONObject();
        additionalInfo.put("regulation_type", "company_internal");
        additionalInfo.put("last_updated", "2025-01-01");
        additionalInfo.put("full_document", "Disponibil în sistemul intern al companiei");
        
        response.put("additionalInfo", additionalInfo);
        
        out.println(response.toString());
    }

    /**
     * Handle policy check responses (pot să fac X?)
     */
    private void handlePolicyCheckResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        Map<String, String> entities = queryInfo.getEntities();
        String requestedAction = entities.getOrDefault("requested_action", "");
        
        System.out.println("DEBUG: Handling policy check for action: " + requestedAction);
        
        // Construiește query-ul original pentru procesare
        String originalQuery = "pot sa " + requestedAction;
        
        // Verifică permisiunea folosind procesorul de politici
        PolicyResponse policyResponse = CompanyPolicyProcessor.checkPolicyPermission(originalQuery);
        
        JSONObject response = new JSONObject();
        response.put("type", "policy_check");
        response.put("requestedAction", requestedAction);
        response.put("result", policyResponse.getSimpleAnswer());
        response.put("message", policyResponse.getFormattedResponse());
        response.put("timestamp", System.currentTimeMillis());
        
        // Adaugă contextul pentru diferite tipuri de răspuns
        JSONObject context = new JSONObject();
        switch (policyResponse.getResult()) {
            case YES:
                context.put("status", "allowed");
                context.put("icon", "✅");
                context.put("color", "green");
                break;
            case NO:
                context.put("status", "forbidden");
                context.put("icon", "❌");
                context.put("color", "red");
                break;
            case CONDITIONAL:
                context.put("status", "conditional");
                context.put("icon", "⚠️");
                context.put("color", "orange");
                break;
            case UNCLEAR:
                context.put("status", "unclear");
                context.put("icon", "❓");
                context.put("color", "gray");
                break;
        }
        
        response.put("context", context);
        
        // Adaugă sugestii relevante
        JSONArray suggestions = new JSONArray();
        if (policyResponse.getResult() == PolicyResult.UNCLEAR || 
            policyResponse.getResult() == PolicyResult.CONDITIONAL) {
            suggestions.put("Contactează departamentul HR pentru clarificări");
            suggestions.put("Verifică regulamentul intern complet");
            suggestions.put("Discută cu managerul direct");
        } else {
            suggestions.put("Pot să lucrez de acasă 3 zile pe săptămână?");
            suggestions.put("Am voie să fac ore suplimentare?");
            suggestions.put("Pot să urmez cursuri de formare?");
            suggestions.put("Este permis programul flexibil?");
        }
        
        response.put("suggestions", suggestions);
        
        // Adaugă informații despre contact HR pentru cazuri unclear
        if (policyResponse.getResult() == PolicyResult.UNCLEAR) {
            JSONObject hrContact = new JSONObject();
            hrContact.put("department", "Resurse Umane");
            hrContact.put("email", "hr@companie.ro");
            hrContact.put("phone", "extensia 100");
            hrContact.put("schedule", "Luni-Vineri 09:00-17:00");
            
            response.put("hrContact", hrContact);
        }
        
        out.println(response.toString());
    }

    /**
     * Handle task scheduling responses
     */
    private void handleTaskSchedulingResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String schedulingType = queryInfo.getEntities().getOrDefault("scheduling_type", "task/meeting");
        String targetPerson = queryInfo.getEntities().get("target_person");
        
        if (targetPerson == null) {
            // General guidance
            JSONObject response = new JSONObject();
            response.put("type", "guidance");
            response.put("message", "Pentru programarea de task-uri sau meeting-uri, specificați numele persoanei cu care doriți să programați.");
            
            JSONArray examples = new JSONArray();
            examples.put("programează meeting cu Ion Popescu");
            examples.put("programează task cu Maria Ionescu");
            examples.put("pune întâlnire cu directorul IT");
            
            JSONArray suggestions = new JSONArray();
            suggestions.put("Căutați în directorul de angajați");
            suggestions.put("Verificați lista echipelor");
            suggestions.put("Contactați secretariatul pentru informații");
            
            response.put("examples", examples);
            response.put("suggestions", suggestions);
            
            out.println(response.toString());
            return;
        }
        
        if (resultList.isEmpty()) {
            JSONObject response = new JSONObject();
            response.put("type", "not_found_with_suggestions");
            response.put("message", "Nu am găsit nicio persoană cu numele \"" + targetPerson + "\".");
            
            JSONArray suggestions = new JSONArray();
            suggestions.put("Verificați ortografia numelui");
            suggestions.put("Încercați doar prenumele sau numele de familie");
            suggestions.put("Căutați în lista tuturor angajaților");
            suggestions.put("Contactați departamentul HR pentru asistență");
            
            response.put("suggestions", suggestions);
            out.println(response.toString());
            return;
        }
        
        if (resultList.size() == 1) {
            // Single person found - provide detailed contact info
            Map<String, Object> person = resultList.get(0);
            
            JSONObject response = new JSONObject();
            response.put("type", "contact_info");
            response.put("schedulingType", schedulingType);
            response.put("targetPerson", targetPerson);
            
            JSONObject contactInfo = new JSONObject();
            contactInfo.put("nume", person.get("nume"));
            contactInfo.put("prenume", person.get("prenume"));
            contactInfo.put("departament", person.get("departament"));
            contactInfo.put("functie", person.get("functie"));
            contactInfo.put("email", person.get("email"));
            contactInfo.put("telefon", person.get("telefon"));
            
            response.put("contactInfo", contactInfo);
            
            String message = String.format(
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
            
            response.put("message", message);
            
            JSONArray nextSteps = new JSONArray();
            nextSteps.put("Trimiteți un email pentru a stabili ora");
            nextSteps.put("Sunați pentru programare urgentă");
            nextSteps.put("Verificați calendar-ul pentru disponibilitate");
            nextSteps.put("Folosiți platforma internă de task-uri");
            
            response.put("nextSteps", nextSteps);
            
            out.println(response.toString());
        } else {
            // Multiple people found
            JSONObject response = new JSONObject();
            response.put("type", "multiple_contacts");
            response.put("message", "Am găsit " + resultList.size() + " persoane cu numele \"" + targetPerson + "\". Alegeți persoana corectă:");
            response.put("data", new JSONArray(resultList));
            response.put("schedulingType", schedulingType);
            
            out.println(response.toString());
        }
    }

    /**
     * Handle calendar responses (next free day, holidays)
     */
    private void handleCalendarResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String calendarType = queryInfo.getEntities().getOrDefault("calendar_type", "");
        
        JSONObject response = new JSONObject();
        response.put("type", "calendar_info");
        response.put("calendarType", calendarType);
        
        if ("next_free_day".equals(calendarType) && resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            String nextFreeDay = (String) result.get("urmatoarea_zi_libera");
            String tipZi = (String) result.get("tip_zi_libera");
            
            response.put("nextFreeDay", nextFreeDay);
            response.put("dayType", tipZi);
            
            String message = String.format(
                "**Următoarea zi liberă:**\n\n" +
                "📅 **Data:** %s\n" +
                "🎉 **Tipul:** %s\n\n" +
                "ℹ️ *Aceasta este următoarea zi în care nu se lucrează conform calendarului oficial.*",
                formatDate(nextFreeDay), tipZi
            );
            
            response.put("message", message);
            
            // Add related suggestions
            JSONArray suggestions = new JSONArray();
            suggestions.put("Vezi toate sărbătorile din acest an");
            suggestions.put("Câte zile libere legale sunt?");
            suggestions.put("Calendar complet pentru luna aceasta");
            
            response.put("suggestions", suggestions);
            
        } else if ("all_holidays".equals(calendarType)) {
            response.put("message", "Iată toate zilele libere din acest an:");
            response.put("data", new JSONArray(resultList));
            
            if (resultList.size() > 0) {
                response.put("totalHolidays", resultList.size());
            }
        }
        
        out.println(response.toString());
    }

    /**
     * Handle legal holidays count response
     */
    private void handleLegalHolidaysResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        JSONObject response = new JSONObject();
        response.put("type", "holidays_count");
        
        if (resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            int zileLegale = ((Number) result.getOrDefault("zile_libere_legale", 0)).intValue();
            int zileSuplimentare = ((Number) result.getOrDefault("zile_libere_suplimentare", 0)).intValue();
            int total = ((Number) result.getOrDefault("total_zile_libere", 0)).intValue();
            String anul = (String) result.get("anul");
            
            JSONObject holidayStats = new JSONObject();
            holidayStats.put("zileLegale", zileLegale);
            holidayStats.put("zileSuplimentare", zileSuplimentare);
            holidayStats.put("total", total);
            holidayStats.put("anul", anul);
            
            response.put("holidayStats", holidayStats);
            
            String message = String.format(
                "**Zile libere legale pentru anul %s:**\n\n" +
                "🏛️ **Sărbători legale:** %d zile\n" +
                "📅 **Zile libere suplimentare:** %d zile\n" +
                "📊 **Total zile libere:** %d zile\n\n" +
                "ℹ️ *Aceste zile sunt stabilite prin lege și calendar oficial.*",
                anul, zileLegale, zileSuplimentare, total
            );
            
            response.put("message", message);
            
            JSONArray suggestions = new JSONArray();
            suggestions.put("Vezi lista detaliată a sărbătorilor");
            suggestions.put("Următoarea zi liberă de la stat");
            suggestions.put("Calendar complet pentru " + anul);
            
            response.put("suggestions", suggestions);
            
        } else {
            response.put("message", "Nu am putut calcula zilele libere legale pentru anul specificat.");
        }
        
        out.println(response.toString());
    }

    /**
     * Handle month days response
     */
    private void handleMonthDaysResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        JSONObject response = new JSONObject();
        response.put("type", "month_info");
        
        if (resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            
            // Handle case where message indicates error
            if (result.containsKey("mesaj")) {
                response.put("message", result.get("mesaj"));
                response.put("error", true);
                
                JSONArray suggestions = new JSONArray();
                suggestions.put("Câte zile are februarie?");
                suggestions.put("Câte zile are decembrie?");
                suggestions.put("Luna aceasta câte zile are?");
                
                response.put("suggestions", suggestions);
            } else {
                int zileInLuna = ((Number) result.get("zile_in_luna")).intValue();
                String luna = (String) result.get("luna");
                String anul = (String) result.get("anul");
                String tipAn = (String) result.get("tip_an");
                
                JSONObject monthInfo = new JSONObject();
                monthInfo.put("zileInLuna", zileInLuna);
                monthInfo.put("luna", luna);
                monthInfo.put("anul", anul);
                monthInfo.put("tipAn", tipAn);
                monthInfo.put("isLeapYear", "An bisect".equals(tipAn));
                
                response.put("monthInfo", monthInfo);
                
                String message = String.format(
                    "**Luna %s %s:**\n\n" +
                    "📅 **Numărul de zile:** %d zile\n" +
                    "📊 **Tipul anului:** %s\n\n" +
                    "ℹ️ *%s*",
                    luna, anul, zileInLuna, tipAn,
                    "An bisect".equals(tipAn) ? 
                        "Februarie are 29 de zile în anii biseţi." : 
                        "Anul normal - februarie are 28 de zile."
                );
                
                response.put("message", message);
                
                JSONArray suggestions = new JSONArray();
                suggestions.put("Câte zile are luna viitoare?");
                suggestions.put("Este " + anul + " an bisect?");
                suggestions.put("Calendar complet pentru " + luna);
                
                response.put("suggestions", suggestions);
            }
        } else {
            response.put("message", "Nu am putut calcula zilele pentru luna specificată.");
            response.put("error", true);
        }
        
        out.println(response.toString());
    }

    /**
     * Helper method to format dates nicely
     */
    private String formatDate(String dateString) {
        try {
            java.time.LocalDate date = java.time.LocalDate.parse(dateString);
            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd MMMM yyyy", 
                                                                                                          java.util.Locale.forLanguageTag("ro"));
            return date.format(formatter);
        } catch (Exception e) {
            return dateString; // Return original if parsing fails
        }
    }

    /**
     * Enhanced help response that includes Semi-FAQ examples
     */
    private String generateEnhancedHelpResponse() {
        return "Sunt asistentul virtual al companiei și pot să vă ajut cu informații din baza de date. " +
               "Pot înțelege întrebări în limbaj natural despre:\n\n" +
               
               "🧑‍💼 **Angajați**: \"Câți angajați sunt în departamentul IT?\", \"Arată-mi angajații din HR\", " +
               "\"Care angajat are cel mai mare salariu?\", \"Cine a fost angajat anul acesta?\"\n\n" +
               
               "🏢 **Departamente**: \"Ce departamente există?\", \"Care departament are cei mai mulți angajați?\", " +
               "\"Unde se află departamentul Marketing?\"\n\n" +
               
               "🏖️ **Concedii**: \"Cine este în concediu astăzi?\", \"Câte concedii au fost aprobate luna aceasta?\", " +
               "\"Arată-mi concediile de vară\", \"Ce concedii medicale avem?\"\n\n" +
               
               "💼 **Poziții**: \"Ce funcții există în IT?\", \"Care sunt cele mai bine plătite poziții?\", " +
               "\"Câți manageri avem?\", \"Ce specializări există?\"\n\n" +
               
               "💰 **Salarii**: \"Care este salariul mediu?\", \"Cine are cel mai mic salariu?\", " +
               "\"Arată-mi salariile peste 8000 RON\"\n\n" +
               
               "📄 **Adeverințe**: \"Câte adeverințe sunt în așteptare?\", \"Arată-mi adeverințele aprobate\"\n\n" +
               
               "🎯 **Proiecte**: \"Ce proiecte active avem?\", \"Cine lucrează la proiectul ERP?\"\n\n" +
               
               "👤 **Informații personale**: \"Câte zile de concediu am?\", \"Care este salariul meu?\", " +
               "\"Cine este superiorul meu?\"\n\n" +
               
               "📅 **Calendar și programare**: \"Programează meeting cu Ion Popescu\", \"Următoarea zi liberă de la stat?\", " +
               "\"Câte zile libere legale sunt?\", \"Câte zile are luna februarie?\"\n\n" +
               
               "**Funcționalități avansate:**\n" +
               "• **Întrebări cu numere**: \"Angajații cu salariul peste 10000\", \"Concedii mai lungi de 5 zile\"\n" +
               "• **Întrebări temporale**: \"Concedii din decembrie\", \"Angajați din ultimul an\"\n" +
               "• **Comparații**: \"Departamentul cu cei mai mulți angajați\", \"Cel mai bine plătit post\"\n" +
               "• **Căutare fuzzy**: Înțeleg și abrevieri (\"IT\", \"HR\", \"fin\" pentru \"finante\")\n" +
               "• **Programare**: \"Programează task cu Maria Ionescu\", \"Meeting cu directorul IT\"\n\n" +
               
               "**Sfaturi pentru întrebări mai bune:**\n" +
               "• Folosiți fraze complete: \"Câți angajați din IT?\" în loc de \"IT angajați\"\n" +
               "• Specificați perioada: \"concedii din această lună\" sau \"anul trecut\"\n" +
               "• Pentru programări: \"programează meeting cu [numele persoanei]\"\n" +
               "• Pentru calendar: \"următoarea zi liberă\", \"câte zile are martie\"\n\n" +
               
               "Încercați o întrebare și vă voi ajuta!";
    }
    
    /**
     * Handle personal query responses
     */
    private void handlePersonalResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String personalType = queryInfo.getEntities().getOrDefault("personal_type", "");
        
        if (resultList.isEmpty()) {
            sendSimpleTextResponse(out, "Nu am putut găsi informațiile personale solicitate.");
            return;
        }
        
        Map<String, Object> result = resultList.get(0);
        
        switch (personalType) {
            case "leave_balance":
                int zileRamase = ((Number) result.getOrDefault("zile_ramase", 0)).intValue();
                int zileConsumate = ((Number) result.getOrDefault("zile_consumate", 0)).intValue();
                int concediiRamase = ((Number) result.getOrDefault("concedii_ramase", 0)).intValue();
                int concediiLuate = ((Number) result.getOrDefault("concedii_luate", 0)).intValue();
                
                String message = String.format(
                    "**Situația dumneavoastră privind concediile:**\n\n" +
                    "🗓️ **Zile de concediu:** %d zile rămase din total (%d zile consumate)\n" +
                    "📋 **Cereri de concediu:** %d cereri rămase din 3 (%d cereri folosite)\n\n" +
                    "💡 Puteți solicita concediu atât timp cât aveți zile și cereri disponibile.",
                    zileRamase, zileConsumate, concediiRamase, concediiLuate
                );
                
                sendEnhancedTextResponse(out, message, queryInfo, null);
                break;
                
            case "salary":
                Object salariuBrut = result.get("salariu_brut");
                Object salariuNet = result.get("salariu_net_aproximativ");
                String functie = (String) result.get("functie");
                String departament = (String) result.get("departament");
                
                String salaryMessage = String.format(
                    "**Informații salariale:**\n\n" +
                    "💰 **Salariu brut:** %s RON\n" +
                    "💳 **Salariu net (aproximativ):** %s RON\n" +
                    "👔 **Funcția:** %s\n" +
                    "🏢 **Departamentul:** %s\n\n" +
                    "ℹ️ *Salariul net este calculat aproximativ (58.5% din brutul de bază).*",
                    salariuBrut, salariuNet, functie, departament
                );
                
                sendEnhancedTextResponse(out, salaryMessage, queryInfo, null);
                break;
                
            case "hierarchy":
                String numeSupervizor = (String) result.get("nume");
                String prenumeSupervizor = (String) result.get("prenume");
                String functieSupervizor = (String) result.get("functie_superior");
                
                if (numeSupervizor != null) {
                    String hierarchyMessage = String.format(
                        "**Superiorul dumneavoastră direct:**\n\n" +
                        "👤 **Nume:** %s %s\n" +
                        "👔 **Funcția:** %s\n\n" +
                        "📞 Pentru contactare, verificați directorul de angajați.",
                        numeSupervizor, prenumeSupervizor, functieSupervizor
                    );
                    sendEnhancedTextResponse(out, hierarchyMessage, queryInfo, null);
                } else {
                    sendSimpleTextResponse(out, "Nu am putut identifica superiorul dumneavoastră direct în structura organizațională.");
                }
                break;
                
            default:
                sendTableResponse(out, "Informații personale:", resultList);
        }
    }

    /**
     * Handle project response
     */
    private void handleProjectResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String projectStatus = queryInfo.getEntities().getOrDefault("project_status", "");
        QueryType queryType = queryInfo.getQueryType();
        
        if (queryType == QueryType.COUNT && resultList.size() == 1) {
            int count = ((Number) resultList.get(0).values().iterator().next()).intValue();
            String statusText = "active".equals(projectStatus) ? "active" : 
                               "inactive".equals(projectStatus) ? "inactive/finalizate" : "";
            
            String message = String.format("În prezent există %d proiecte %s în sistem.", count, statusText);
            sendSimpleTextResponse(out, message);
        } else {
            String statusText = "active".equals(projectStatus) ? " active" : 
                               "inactive".equals(projectStatus) ? " finalizate" : "";
            sendTableResponse(out, "Iată proiectele" + statusText + " din sistem:", resultList);
        }
    }

    /**
     * Handle certificate response
     */
    private void handleCertificateResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String certificateStatus = queryInfo.getEntities().getOrDefault("certificate_status", "");
        QueryType queryType = queryInfo.getQueryType();
        
        if (queryType == QueryType.COUNT && resultList.size() == 1) {
            int count = ((Number) resultList.get(0).values().iterator().next()).intValue();
            
            String statusText = "";
            switch (certificateStatus) {
                case "pending": statusText = "în așteptare"; break;
                case "approved": statusText = "aprobate"; break;
                case "rejected": statusText = "respinse"; break;
                default: statusText = "";
            }
            
            String message = String.format("Există %d adeverințe %s în sistem.", count, statusText);
            sendSimpleTextResponse(out, message);
        } else {
            String statusText = "";
            switch (certificateStatus) {
                case "pending": statusText = " în așteptare"; break;
                case "approved": statusText = " aprobate"; break;
                case "rejected": statusText = " respinse"; break;
            }
            
            sendTableResponse(out, "Iată adeverințele" + statusText + ":", resultList);
        }
    }

    /**
     * Handle location response
     */
    private void handleLocationResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String locationType = queryInfo.getEntities().getOrDefault("location_type", "");
        String departmentName = queryInfo.getEntities().get("department_name");
        
        String message = "Iată informațiile de locație ";
        
        switch (locationType) {
            case "department":
                message += departmentName != null ? 
                    "pentru departamentul " + departmentName + ":" : 
                    "pentru departamente:";
                break;
            case "office":
                message += "pentru sediile companiei:";
                break;
            case "employee":
                message += "pentru angajați:";
                break;
            default:
                message += "solicitate:";
        }
        
        sendTableResponse(out, message, resultList);
    }

    /**
     * Handle average/statistical response
     */
    private void handleAverageResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String averageType = queryInfo.getEntities().getOrDefault("average_type", "");
        String averageScope = queryInfo.getEntities().getOrDefault("average_scope", "");
        String departmentName = queryInfo.getEntities().get("department_name");
        
        if ("salary".equals(averageType) && resultList.size() == 1) {
            Map<String, Object> result = resultList.get(0);
            
            if ("company".equals(averageScope)) {
                Object salariuMediu = result.get("salariu_mediu_general");
                Object totalAngajati = result.get("total_angajati");
                
                String message = String.format(
                    "**Salariul mediu în companie:**\n\n" +
                    "💰 **Media generală:** %.2f RON\n" +
                    "👥 **Calculat pe baza a:** %s angajați\n\n" +
                    "ℹ️ *Aceasta include toate pozițiile și departamentele.*",
                    ((Number) salariuMediu).doubleValue(),
                    totalAngajati
                );
                
                sendEnhancedTextResponse(out, message, queryInfo, null);
                return;
            }
        }
        
        // For other cases, show as table
        String contextMessage = "Iată statisticile salariale ";
        
        if (departmentName != null) {
            contextMessage += "pentru departamentul " + departmentName + ":";
        } else {
            switch (averageScope) {
                case "department": contextMessage += "pe departamente:"; break;
                case "position": contextMessage += "pe poziții:"; break;
                default: contextMessage += "solicitate:";
            }
        }
        
        sendTableResponse(out, contextMessage, resultList);
    }

    /**
     * Handle task response
     */
    private void handleTaskResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String taskStatus = queryInfo.getEntities().getOrDefault("task_status", "");
        String temporalFilter = queryInfo.getEntities().get("temporal_filter");
        QueryType queryType = queryInfo.getQueryType();
        
        if (queryType == QueryType.COUNT && resultList.size() == 1) {
            int count = ((Number) resultList.get(0).values().iterator().next()).intValue();
            
            String statusText = "";
            if ("deadline".equals(taskStatus)) {
                statusText = temporalFilter != null ? 
                    "cu deadline " + temporalFilter : 
                    "cu deadline astăzi";
            } else if ("in_progress".equals(taskStatus)) {
                statusText = "în progres";
            }
            
            String message = String.format("Există %d task-uri %s.", count, statusText);
            sendSimpleTextResponse(out, message);
        } else {
            String statusText = "";
            if ("deadline".equals(taskStatus)) {
                statusText = temporalFilter != null ? 
                    " cu deadline " + temporalFilter : 
                    " cu deadline astăzi";
            } else if ("in_progress".equals(taskStatus)) {
                statusText = " în progres";
            }
            
            sendTableResponse(out, "Iată task-urile" + statusText + ":", resultList);
        }
    }

    /**
     * Handle availability response
     */
    private void handleAvailabilityResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String availabilityType = queryInfo.getEntities().getOrDefault("availability_type", "");
        
        if ("position".equals(availabilityType)) {
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "În acest moment nu există poziții deschise în companie.");
            } else {
                sendTableResponse(out, "Iată pozițiile disponibile în companie:", resultList);
            }
        } else {
            sendTableResponse(out, "Iată informațiile de disponibilitate:", resultList);
        }
    }

    /**
     * Handle work mode response
     */
    private void handleWorkModeResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, PrintWriter out) {
        String workModeType = queryInfo.getEntities().getOrDefault("work_mode_type", "");
        QueryType queryType = queryInfo.getQueryType();
        
        // Since work mode isn't fully implemented in the schema yet
        sendSimpleTextResponse(out, "Funcționalitatea pentru modurile de lucru (remote/hibrid/fizic) " +
                                   "este în curs de implementare. Vă rugăm să contactați departamentul HR " +
                                   "pentru informații despre angajații care lucrează remote.");
    }

    /**
     * Enhanced leave response with better temporal context
     */
    private void handleEnhancedLeaveResponse(List<Map<String, Object>> resultList, QueryInfo queryInfo, 
                                          EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
        String leaveQueryType = queryInfo.getEntities().getOrDefault("leave_query_type", "");
        String temporalFilter = queryInfo.getEntities().get("temporal_filter");
        String departmentName = queryInfo.getEntities().get("department_name");
        
        if ("who_is_on_leave".equals(leaveQueryType)) {
            if (resultList.isEmpty()) {
                String timeContext = temporalFilter != null ? temporalFilter : "în acest moment";
                String deptContext = departmentName != null ? " din departamentul " + departmentName : "";
                
                String message = String.format("Nu există angajați în concediu %s%s.", timeContext, deptContext);
                sendSimpleTextResponse(out, message);
            } else {
                String timeContext = temporalFilter != null ? " " + temporalFilter : " în acest moment";
                String deptContext = departmentName != null ? " din departamentul " + departmentName : "";
                
                String message = String.format("Iată angajații în concediu%s%s:", timeContext, deptContext);
                sendTableResponse(out, message, resultList);
            }
        } else {
            // Fall back to existing leave response handling
            handleListResponseEnhanced(resultList, queryInfo, tokenization, out);
        }
    }

    /**
     * Enhanced SQL error handling with helpful suggestions
     */
    private void handleSQLError(SQLException e, QueryInfo queryInfo, 
                              EnhancedNLPProcessor.AdvancedTokenization tokenization, PrintWriter out) {
        String entityType = queryInfo.getEntities().getOrDefault("entity", "");
        
        JSONObject response = new JSONObject();
        response.put("type", "error_with_suggestions");
        
        String helpfulMessage = "A apărut o problemă la procesarea întrebării. ";
        
        // Provide specific help based on entity type
        switch (entityType) {
            case "personal":
                helpfulMessage += "Pentru întrebări personale, încercați: \"Câte zile de concediu am?\" sau \"Care este salariul meu?\"";
                break;
            case "project":
                helpfulMessage += "Pentru proiecte, încercați: \"Ce proiecte active avem?\" sau \"Câte proiecte sunt în curs?\"";
                break;
            case "certificate":
                helpfulMessage += "Pentru adeverințe, încercați: \"Adeverințe în așteptare\" sau \"Câte adeverințe au fost aprobate?\"";
                break;
            case "task":
                helpfulMessage += "Pentru task-uri, încercați: \"Task-uri pentru astăzi\" sau \"Ce task-uri sunt de finalizat?\"";
                break;
            case "leave":
                helpfulMessage += "Pentru concedii, încercați: \"Cine e în concediu astăzi?\" sau \"Concedii din departamentul IT\"";
                break;
            default:
                helpfulMessage += "Încercați să reformulați întrebarea sau să folosiți termeni mai simpli.";
        }
        
        response.put("message", helpfulMessage);
        
        // Add example queries based on detected entities
        if (tokenization != null && !tokenization.getEntityConfidences().isEmpty()) {
            JSONArray suggestions = new JSONArray();
            List<String> helpSuggestions = EnhancedNLPProcessor.generateEnhancedSuggestions(
                String.join(" ", tokenization.getNormalizedTokens()), tokenization.getEntityConfidences());
            for (String suggestion : helpSuggestions) {
                suggestions.put(suggestion);
            }
            response.put("suggestions", suggestions);
        }
        
        out.println(response.toString());
    }

    /**
     * Enhanced text response for TODO queries
     */
    private void sendEnhancedTextResponse(PrintWriter out, String message, QueryInfo queryInfo, 
                                        EnhancedNLPProcessor.AdvancedTokenization tokenization) {
        JSONObject response = new JSONObject();
        response.put("type", "enhanced_text");
        response.put("message", message);
        response.put("timestamp", System.currentTimeMillis());
        response.put("entityType", queryInfo.getEntities().getOrDefault("entity", ""));
        
        // Add follow-up suggestions for personal queries
        String entityType = queryInfo.getEntities().getOrDefault("entity", "");
        if ("personal".equals(entityType)) {
            JSONArray followUpSuggestions = new JSONArray();
            String personalType = queryInfo.getEntities().getOrDefault("personal_type", "");
            
            switch (personalType) {
                case "leave_balance":
                    followUpSuggestions.put("Pot să-mi iau concediu săptămâna viitoare?");
                    followUpSuggestions.put("Cine este superiorul meu?");
                    break;
                case "salary":
                    followUpSuggestions.put("Care este salariul mediu în departamentul meu?");
                    followUpSuggestions.put("Câte zile de concediu am?");
                    break;
                case "hierarchy":
                    followUpSuggestions.put("Ce funcții sunt disponibile pentru promovare?");
                    followUpSuggestions.put("Care este salariul mediu pentru funcția mea?");
                    break;
            }
            
            if (followUpSuggestions.length() > 0) {
                response.put("followUpSuggestions", followUpSuggestions);
            }
        }
        
        out.println(response.toString());
    }
    
    /**
     * Check if a message is a greeting
     */
    private boolean isGreeting(String text) {
        String[] greetings = {
            "buna", "salut", "hello", "hi", "hey", "bună ziua", "neața", 
            "ziua bună", "servus", "bine ai venit", "ce faci", "ce mai faci"
        };
        
        for (String greeting : greetings) {
            if (text.contains(greeting)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Check if a message is a help request
     */
    private boolean isHelpRequest(String text) {
        String[] helpTerms = {
            "ajuta-ma", "ajută-mă", "ajutor", "help", "nu inteleg", "nu înțeleg",
            "cum sa", "cum să", "ce pot sa", "ce pot să", "instructiuni", "instrucțiuni",
            "ghid", "tutorial", "cum functioneaza", "cum funcționează"
        };
        
        for (String term : helpTerms) {
            if (text.contains(term)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Generate a help response
     */
    private String generateHelpResponse() {
        return "Vă pot ajuta cu informații din baza de date a companiei. Puteți să-mi adresați întrebări în limbaj natural despre:\n\n" +
               "1. Angajați - ex: \"Câți angajați sunt în departamentul HR?\" sau \"Arată-mi angajații din IT.\"\n" +
               "2. Departamente - ex: \"Ce departamente există în firmă?\" sau \"Câți angajați are fiecare departament?\"\n" +
               "3. Concedii - ex: \"Cine este în concediu astăzi?\" sau \"Arată-mi concediile de Crăciun.\"\n" +
               "4. Poziții/roluri - ex: \"Ce tipuri de poziții există în departamentul IT?\" sau \"Care sunt cele mai bine plătite funcții?\"\n" +
               "5. Salarii - ex: \"Care este salariul mediu în firmă?\" sau \"Care sunt salariile pozițiilor din HR?\"\n" +
               "6. Adeverințe - ex: \"Câte adeverințe sunt în așteptare?\" sau \"Arată-mi adeverințele aprobate.\"\n" +
               "7. Proiecte - ex: \"Ce proiecte active avem?\" sau \"Cine lucrează la proiectul X?\"\n\n" +
               "După ce primiți un răspuns, puteți solicita detalii suplimentare spunând simplu \"Da\" sau \"Arată-mi mai multe detalii\".";
    }
    
    /**
     * Convert a ResultSet to a List of Maps
     */
    private List<Map<String, Object>> resultSetToList(ResultSet rs) throws SQLException {
        List<Map<String, Object>> list = new ArrayList<>();
        ResultSetMetaData md = rs.getMetaData();
        int columnCount = md.getColumnCount();
        
        System.out.println("DEBUG: Converting ResultSet to List<Map<String, Object>> with " + columnCount + " columns");
        
        int rowCount = 0;
        while (rs.next()) {
            rowCount++;
            Map<String, Object> row = new HashMap<>();
            for (int i = 1; i <= columnCount; i++) {
                String columnName = md.getColumnLabel(i);
                Object value = rs.getObject(i);
                
                // Format dates if present
                if (value instanceof java.sql.Date) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
                    value = sdf.format(value);
                } else if (value instanceof java.sql.Timestamp) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy HH:mm:ss");
                    value = sdf.format(value);
                }
                
                row.put(columnName, value);
            }
            list.add(row);
            
            // Print only first 5 rows for debugging
            if (rowCount <= 5) {
                System.out.println("DEBUG: Row " + rowCount + ": " + row);
            }
        }
        
        System.out.println("DEBUG: Converted " + rowCount + " rows to List<Map<String, Object>>");
        
        return list;
    }
    
    // Legacy methods for processing different types of queries...
    // (These remain largely unchanged except for added debugging statements)
    
    /**
     * Legacy method: Process employee queries
     */
    private void processEmployeeQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, ");
            sqlBuilder.append("u.email, u.telefon ");
            sqlBuilder.append("FROM useri u ");
            sqlBuilder.append("JOIN tipuri t ON u.tip = t.tip ");
            sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Department filter
            if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                sqlBuilder.append("AND d.nume_dep = 'HR' ");
            } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                sqlBuilder.append("AND d.nume_dep = 'IT' ");
            } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                sqlBuilder.append("AND d.nume_dep = 'Finante' ");
            } else if (query.contains("juridic")) {
                sqlBuilder.append("AND d.nume_dep = 'Juridic' ");
            } else if (query.contains("marketing")) {
                sqlBuilder.append("AND d.nume_dep = 'Marketing' ");
            }
            
            // Position filter
            if (query.contains("director")) {
                sqlBuilder.append("AND t.denumire LIKE '%Director%' ");
            } else if (query.contains("intern")) {
                sqlBuilder.append("AND t.denumire LIKE '%Intern%' ");
            } else if (query.contains("sef") || query.contains("șef")) {
                sqlBuilder.append("AND t.denumire LIKE '%Sef%' ");
            } else if (query.contains("manager")) {
                sqlBuilder.append("AND t.denumire LIKE '%Manager%' ");
            }
            
            // Order by department and name
            sqlBuilder.append("ORDER BY d.nume_dep, u.nume, u.prenume");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            // Convert results to list of maps
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            
            // Determine if we need to show count or details
            String departmentName = "";
            if (query.contains("hr")) departmentName = "HR";
            else if (query.contains("it")) departmentName = "IT";
            else if (query.contains("finante") || query.contains("finanțe")) departmentName = "Finante";
            else if (query.contains("juridic")) departmentName = "Juridic";
            else if (query.contains("marketing")) departmentName = "Marketing";
            
            session.setAttribute("lastQueryContext", "angajați" + 
                    (departmentName.isEmpty() ? "" : " din departamentul " + departmentName));
            
            boolean showCount = query.contains("câți") || query.contains("cati") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit niciun angajat care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " angajați care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următorii angajați care corespund criteriilor dvs.:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process department queries
     */
    private void processDepartmentQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT d.id_dep, d.nume_dep AS departament, COUNT(u.id) as numar_angajati ");
            sqlBuilder.append("FROM departament d ");
            sqlBuilder.append("LEFT JOIN useri u ON d.id_dep = u.id_dep ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Specific department filter
            if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                sqlBuilder.append("AND d.nume_dep = 'HR' ");
            } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                sqlBuilder.append("AND d.nume_dep = 'IT' ");
            } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                sqlBuilder.append("AND d.nume_dep = 'Finante' ");
            } else if (query.contains("juridic")) {
                sqlBuilder.append("AND d.nume_dep = 'Juridic' ");
            } else if (query.contains("marketing")) {
                sqlBuilder.append("AND d.nume_dep = 'Marketing' ");
            }
            
            sqlBuilder.append("GROUP BY d.id_dep, d.nume_dep ");
            sqlBuilder.append("ORDER BY d.nume_dep");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            session.setAttribute("lastQueryContext", "departamente");
            
            boolean showCount = query.contains("câte") || query.contains("cate") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit niciun departament care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "Am găsit " + resultList.size() + 
                        " departamente care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele departamente:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process leave queries
     */
    private void processLeaveQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT c.id AS nr_crt, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, ");
            sqlBuilder.append("t.denumire AS functie, c.start_c AS data_inceput, c.end_c AS data_sfarsit, ");
            sqlBuilder.append("c.motiv, c.locatie, s.nume_status AS status, ");
            sqlBuilder.append("c.durata, tc.motiv AS tip_concediu ");
            sqlBuilder.append("FROM concedii c ");
            sqlBuilder.append("JOIN useri u ON u.id = c.id_ang ");
            sqlBuilder.append("JOIN tipuri t ON u.tip = t.tip ");
            sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sqlBuilder.append("JOIN statusuri s ON c.status = s.status ");
            sqlBuilder.append("JOIN tipcon tc ON c.tip = tc.tip ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Time period filters
            if (query.contains("craciun") || query.contains("crăciun")) {
                // Christmas period (24-25 December of the current year)
                sqlBuilder.append("AND ((c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24')) ");
            } else if (query.contains("decembrie") || query.contains("decembr")) {
                sqlBuilder.append("AND (MONTH(c.start_c) = 12 OR MONTH(c.end_c) = 12) ");
            } else if (query.contains("ianuarie") || query.contains("ianuar")) {
                sqlBuilder.append("AND (MONTH(c.start_c) = 1 OR MONTH(c.end_c) = 1) ");
            } else if (query.contains("astazi") || query.contains("azi") || 
                       query.contains("astăzi") || query.contains("acum")) {
                sqlBuilder.append("AND (CURDATE() BETWEEN c.start_c AND c.end_c) ");
            } else if (query.contains("luna ") || query.contains("luna") || 
                       query.contains("curent") || query.contains("luna aceasta")) {
                sqlBuilder.append("AND (MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())) ");
            } else if (query.contains("an") || query.contains("anul") || 
                       query.contains("anul acesta") || query.contains("acest an")) {
                sqlBuilder.append("AND YEAR(c.start_c) = YEAR(CURDATE()) ");
            }
            
            // Department filters
            if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                sqlBuilder.append("AND d.nume_dep = 'HR' ");
            } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                sqlBuilder.append("AND d.nume_dep = 'IT' ");
            } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                sqlBuilder.append("AND d.nume_dep = 'Finante' ");
            } else if (query.contains("juridic")) {
                sqlBuilder.append("AND d.nume_dep = 'Juridic' ");
            } else if (query.contains("marketing")) {
                sqlBuilder.append("AND d.nume_dep = 'Marketing' ");
            }
            
            // Status filters
            if (query.contains("aprobat")) {
                sqlBuilder.append("AND c.status IN (1, 2) ");
            } else if (query.contains("neaprobat")) {
                sqlBuilder.append("AND c.status = 0 ");
            } else if (query.contains("respins") || query.contains("dezaprobat")) {
                sqlBuilder.append("AND c.status IN (-1, -2) ");
            }
            
            // Type filters
            if (query.contains("medical")) {
                sqlBuilder.append("AND tc.motiv LIKE '%medical%' ");
            } else if (query.contains("odihna")) {
                sqlBuilder.append("AND tc.motiv LIKE '%odihna%' ");
            }
            
            sqlBuilder.append("ORDER BY c.start_c DESC");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            
            // Determine context for follow-up
            String contextTime = "";
            if (query.contains("craciun") || query.contains("crăciun")) contextTime = " de Crăciun";
            else if (query.contains("decembrie") || query.contains("decembr")) contextTime = " din decembrie";
            else if (query.contains("ianuarie") || query.contains("ianuar")) contextTime = " din ianuarie";
            else if (query.contains("astazi") || query.contains("azi") || 
                     query.contains("astăzi") || query.contains("acum")) contextTime = " de astăzi";
            else if (query.contains("luna") || query.contains("curent")) contextTime = " din luna curentă";
            else if (query.contains("an") || query.contains("anul")) contextTime = " din anul curent";
            
            String contextDepartment = "";
            if (query.contains("hr")) contextDepartment = " din departamentul HR";
            else if (query.contains("it")) contextDepartment = " din departamentul IT";
            else if (query.contains("finante") || query.contains("finanțe")) 
                contextDepartment = " din departamentul Finante";
            else if (query.contains("juridic")) contextDepartment = " din departamentul Juridic";
            else if (query.contains("marketing")) contextDepartment = " din departamentul Marketing";
            
            session.setAttribute("lastQueryContext", "concedii" + contextTime + contextDepartment);
            
            boolean showCount = query.contains("câte") || query.contains("cate") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit niciun concediu care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " concedii care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele concedii:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process certificate queries
     */
    private void processCertificateQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, ");
            sqlBuilder.append("a.creare AS data_creare, a.modif AS data_modificare, ");
            sqlBuilder.append("u.nume, u.prenume, d.nume_dep AS departament ");
            sqlBuilder.append("FROM adeverinte a ");
            sqlBuilder.append("JOIN tip_adev ta ON a.tip = ta.id ");
            sqlBuilder.append("JOIN statusuri s ON a.status = s.status ");
            sqlBuilder.append("JOIN useri u ON a.id_ang = u.id ");
            sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Type filters
            if (query.contains("salariat")) {
                sqlBuilder.append("AND ta.denumire LIKE '%salariat%' ");
            } else if (query.contains("venit")) {
                sqlBuilder.append("AND ta.denumire LIKE '%venit%' ");
            } else if (query.contains("medical")) {
                sqlBuilder.append("AND ta.denumire LIKE '%medical%' ");
            }
            
            // Status filters
            if (query.contains("aprobat")) {
                sqlBuilder.append("AND a.status = 2 ");
            } else if (query.contains("neaprobat") || query.contains("asteptare") || 
                       query.contains("în așteptare") || query.contains("in asteptare")) {
                sqlBuilder.append("AND a.status = 0 ");
            } else if (query.contains("respins")) {
                sqlBuilder.append("AND a.status < 0 ");
            }
            
            // Department filters
            if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                sqlBuilder.append("AND d.nume_dep = 'HR' ");
            } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                sqlBuilder.append("AND d.nume_dep = 'IT' ");
            } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                sqlBuilder.append("AND d.nume_dep = 'Finante' ");
            } else if (query.contains("juridic")) {
                sqlBuilder.append("AND d.nume_dep = 'Juridic' ");
            } else if (query.contains("marketing")) {
                sqlBuilder.append("AND d.nume_dep = 'Marketing' ");
            }
            
            // Time period filters
            if (query.contains("luna") || query.contains("curent")) {
                sqlBuilder.append("AND (MONTH(a.creare) = MONTH(CURDATE()) AND YEAR(a.creare) = YEAR(CURDATE())) ");
            } else if (query.contains("an") || query.contains("anul")) {
                sqlBuilder.append("AND YEAR(a.creare) = YEAR(CURDATE()) ");
            }
            
            sqlBuilder.append("ORDER BY a.creare DESC");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            session.setAttribute("lastQueryContext", "adeverințe");
            
            boolean showCount = query.contains("câte") || query.contains("cate") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit nicio adeverință care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " adeverințe care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele adeverințe:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process project queries
     */
    private void processProjectQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            
            // Determine which type of project query
            if (query.contains("task") || query.contains("taskuri") || 
                query.contains("sarcina") || query.contains("sarcini")) {
                
                // Query for tasks
                sqlBuilder.append("SELECT t.id, t.nume AS nume_task, p.nume AS nume_proiect, ");
                sqlBuilder.append("u.nume, u.prenume, s.procent AS progres, ");
                sqlBuilder.append("t.start AS data_inceput, t.end AS data_sfarsit ");
                sqlBuilder.append("FROM tasks t ");
                sqlBuilder.append("JOIN proiecte p ON t.id_prj = p.id ");
                sqlBuilder.append("JOIN useri u ON t.id_ang = u.id ");
                sqlBuilder.append("JOIN statusuri2 s ON t.status = s.id ");
                sqlBuilder.append("WHERE 1=1 ");
                
                // Filter for incomplete/complete tasks
                if (query.contains("neterminate") || query.contains("incomplete") || 
                    query.contains("în progres") || query.contains("in progres")) {
                    sqlBuilder.append("AND s.procent < 100 ");
                } else if (query.contains("terminate") || query.contains("complete") || 
                          query.contains("finalizate")) {
                    sqlBuilder.append("AND s.procent = 100 ");
                }
                
                sqlBuilder.append("ORDER BY t.end");
                
            } else if (query.contains("cine") || query.contains("lucreaza") || 
                       query.contains("lucrează") || query.contains("angajat")) {
                
                // Query for who works on projects
                sqlBuilder.append("SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, ");
                sqlBuilder.append("p.nume AS nume_proiect, e.nume AS nume_echipa ");
                sqlBuilder.append("FROM useri u ");
                sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
                sqlBuilder.append("JOIN tasks t ON t.id_ang = u.id ");
                sqlBuilder.append("JOIN proiecte p ON t.id_prj = p.id ");
                sqlBuilder.append("JOIN echipe e ON e.id_prj = p.id ");
                sqlBuilder.append("GROUP BY u.id, u.nume, u.prenume, d.nume_dep, p.nume, e.nume ");
                sqlBuilder.append("ORDER BY u.nume, u.prenume");
                
            } else {
                // Default project list
                sqlBuilder.append("SELECT p.id, p.nume, p.descriere, p.start AS data_inceput, p.end AS data_sfarsit, ");
                sqlBuilder.append("COUNT(DISTINCT e.id) AS numar_echipe, ");
                sqlBuilder.append("COUNT(DISTINCT t.id) AS numar_taskuri, ");
                sqlBuilder.append("u.nume AS supervizor_nume, u.prenume AS supervizor_prenume ");
                sqlBuilder.append("FROM proiecte p ");
                sqlBuilder.append("LEFT JOIN echipe e ON p.id = e.id_prj ");
                sqlBuilder.append("LEFT JOIN tasks t ON p.id = t.id_prj ");
                sqlBuilder.append("LEFT JOIN useri u ON p.supervizor = u.id ");
                sqlBuilder.append("GROUP BY p.id, p.nume, p.descriere, p.start, p.end, u.nume, u.prenume ");
                
                // Add filter for active projects
                if (query.contains("active") || query.contains("curente") || 
                    query.contains("prezent") || query.contains("in desfasurare") || 
                    query.contains("în desfășurare")) {
                    sqlBuilder.append("HAVING p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL) ");
                }
                
                sqlBuilder.append("ORDER BY p.start DESC");
            }
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            
            // Set context based on query type
            if (query.contains("task") || query.contains("taskuri") || 
                query.contains("sarcina") || query.contains("sarcini")) {
                session.setAttribute("lastQueryContext", "taskuri");
            } else if (query.contains("cine") || query.contains("lucreaza") || 
                       query.contains("lucrează") || query.contains("angajat")) {
                session.setAttribute("lastQueryContext", "angajați și proiecte");
            } else {
                session.setAttribute("lastQueryContext", "proiecte");
            }
            
            boolean showCount = query.contains("câte") || query.contains("cate") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit niciun rezultat care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " rezultate care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele rezultate:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process position/role queries
     */
    private void processPositionsQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            
            if (query.contains("departament")) {
                // Positions in a specific department
                sqlBuilder.append("SELECT DISTINCT t.tip, t.denumire, t.salariu, t.ierarhie, ");
                sqlBuilder.append("dp.denumire_completa AS denumire_specifica ");
                sqlBuilder.append("FROM useri u ");
                sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
                sqlBuilder.append("JOIN tipuri t ON u.tip = t.tip ");
                sqlBuilder.append("LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep ");
                sqlBuilder.append("WHERE 1=1 ");
                
                // Department filter
                if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                    sqlBuilder.append("AND d.nume_dep = 'HR' ");
                } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                    sqlBuilder.append("AND d.nume_dep = 'IT' ");
                } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                    sqlBuilder.append("AND d.nume_dep = 'Finante' ");
                } else if (query.contains("juridic")) {
                    sqlBuilder.append("AND d.nume_dep = 'Juridic' ");
                } else if (query.contains("marketing")) {
                    sqlBuilder.append("AND d.nume_dep = 'Marketing' ");
                }
                
                sqlBuilder.append("ORDER BY t.ierarhie, t.denumire");
            } else {
                // All positions
                sqlBuilder.append("SELECT t.tip, t.denumire, t.salariu, t.ierarhie, ");
                sqlBuilder.append("d.nume_dep AS departament_specific ");
                sqlBuilder.append("FROM tipuri t ");
                sqlBuilder.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                
                // Ordering
                if (query.contains("salariu") || query.contains("salarii") || 
                    query.contains("platite") || query.contains("plătite")) {
                    sqlBuilder.append("ORDER BY t.salariu DESC");
                } else {
                    sqlBuilder.append("ORDER BY t.ierarhie, t.denumire");
                }
            }
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            
            // Set context based on query
            String departmentName = "";
            if (query.contains("hr")) departmentName = "HR";
            else if (query.contains("it")) departmentName = "IT";
            else if (query.contains("finante") || query.contains("finanțe")) departmentName = "Finante";
            else if (query.contains("juridic")) departmentName = "Juridic";
            else if (query.contains("marketing")) departmentName = "Marketing";
            
            session.setAttribute("lastQueryContext", "poziții" + 
                    (departmentName.isEmpty() ? "" : " din departamentul " + departmentName));
            
            boolean showCount = query.contains("câte") || query.contains("cate") || 
                               query.contains("număr") || query.contains("numar") || 
                               query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit nicio poziție care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " poziții care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele poziții:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Legacy method: Process salary queries
     */
    private void processSalaryQuery(String query, MyUser currentUser, PrintWriter out, HttpSession session) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            
            if (query.contains("medie") || query.contains("mediu") || query.contains("average") || 
                query.contains("media") || query.contains("în medie") || query.contains("in medie")) {
                
                // Average salary
                sqlBuilder.append("SELECT AVG(t.salariu) AS salariu_mediu ");
                sqlBuilder.append("FROM tipuri t ");
                
                // Department filter
                if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'HR' ");
                } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'IT' ");
                } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'Finante' ");
                }
                
            } else if (query.contains("maxim") || query.contains("max") || 
                       query.contains("cel mai mare") || query.contains("cea mai mare") || 
                       query.contains("top") || query.contains("cele mai mari")) {
                
                // Maximum salaries
                sqlBuilder.append("SELECT t.denumire, t.salariu, d.nume_dep AS departament_specific ");
                sqlBuilder.append("FROM tipuri t ");
                sqlBuilder.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                
                // Department filter
                if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'HR' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'IT' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'Finante' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                }
                
                sqlBuilder.append("ORDER BY t.salariu DESC ");
                sqlBuilder.append("LIMIT 10");
                
            } else if (query.contains("minim") || query.contains("min") || 
                       query.contains("cel mai mic") || query.contains("cea mai mica") || 
                       query.contains("cele mai mici")) {
                
                // Minimum salaries
                sqlBuilder.append("SELECT t.denumire, t.salariu, d.nume_dep AS departament_specific ");
                sqlBuilder.append("FROM tipuri t ");
                sqlBuilder.append("LEFT JOIN departament d ON t.departament_specific = d.id_dep ");
                
                // Department filter
                if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'HR' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'IT' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                    sqlBuilder.append("JOIN useri u ON t.tip = u.tip ");
                    sqlBuilder.append("JOIN departament d2 ON u.id_dep = d2.id_dep ");
                    sqlBuilder.append("WHERE d2.nume_dep = 'Finante' ");
                    sqlBuilder.append("GROUP BY t.denumire, t.salariu, d.nume_dep ");
                }
                
                sqlBuilder.append("ORDER BY t.salariu ASC ");
                sqlBuilder.append("LIMIT 10");
                
            } else {
                // All salaries
                sqlBuilder.append("SELECT t.denumire, t.salariu, COUNT(u.id) AS numar_angajati ");
                sqlBuilder.append("FROM tipuri t ");
                sqlBuilder.append("LEFT JOIN useri u ON t.tip = u.tip ");
                
                // Department filter
                if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                    sqlBuilder.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'HR' ");
                } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                    sqlBuilder.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'IT' ");
                } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                    sqlBuilder.append("LEFT JOIN departament d ON u.id_dep = d.id_dep ");
                    sqlBuilder.append("WHERE d.nume_dep = 'Finante' ");
                }
                
                sqlBuilder.append("GROUP BY t.denumire, t.salariu ");
                sqlBuilder.append("ORDER BY t.salariu DESC");
            }
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = resultSetToList(rs);
            
            // Save results in session for possible follow-up
            session.setAttribute("lastQueryData", resultList);
            
            // Set context based on query
            String departmentName = "";
            if (query.contains("hr")) departmentName = "HR";
            else if (query.contains("it")) departmentName = "IT";
            else if (query.contains("finante") || query.contains("finanțe")) departmentName = "Finante";
            
            session.setAttribute("lastQueryContext", "salarii" + 
                    (departmentName.isEmpty() ? "" : " din departamentul " + departmentName));
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit date salariale care să corespundă criteriilor dvs.");
            } else if (query.contains("medie") || query.contains("mediu") || query.contains("average")) {
                // Special format for average salary
                double avgSalary = ((Number) resultList.get(0).get("salariu_mediu")).doubleValue();
                sendSimpleTextResponse(out, String.format("Salariul mediu%s este de %.2f lei.", 
                        (departmentName.isEmpty() ? "" : " în departamentul " + departmentName),
                        avgSalary));
            } else {
                sendTableResponse(out, "Iată informațiile salariale" + 
                        (departmentName.isEmpty() ? "" : " pentru departamentul " + departmentName) + ":", 
                        resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    /**
     * Send a simple text response
     */
    private void sendSimpleTextResponse(PrintWriter out, String message) {
        System.out.println("DEBUG: Sending simple text response: " + message);
        
        JSONObject response = new JSONObject();
        response.put("type", "text");
        response.put("message", message);
        out.println(response.toString());
    }
    
    /**
     * Send a table response
     */
    private void sendTableResponse(PrintWriter out, String message, List<Map<String, Object>> data) {
        System.out.println("DEBUG: Sending table response with " + data.size() + " rows");
        System.out.println("DEBUG: Table message: " + message);
        
        JSONObject response = new JSONObject();
        response.put("type", "table");
        response.put("message", message);
        response.put("data", new JSONArray(data));
        out.println(response.toString());
    }
    
    /**
     * Send a table response with confirmation option
     */
    private void sendTableResponseWithConfirmation(PrintWriter out, String message, List<Map<String, Object>> data) {
        System.out.println("DEBUG: Sending table response with confirmation. Message: " + message);
        
        JSONObject response = new JSONObject();
        response.put("type", "table");
        response.put("message", message);
        response.put("data", new JSONArray(data));
        response.put("needsConfirmation", true);
        out.println(response.toString());
    }
    
    /**
     * Send an error response
     */
    private void sendErrorResponse(PrintWriter out, String errorMessage) {
        System.out.println("DEBUG: Sending error response: " + errorMessage);
        
        JSONObject response = new JSONObject();
        response.put("type", "error");
        response.put("message", "Îmi pare rău, a apărut o eroare: " + errorMessage);
        out.println(response.toString());
    }
    
    /**
     * Get a database connection
     */
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("DEBUG: MySQL JDBC Driver not found");
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        
        System.out.println("DEBUG: Getting database connection");
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }
}