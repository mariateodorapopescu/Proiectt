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

public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    private NaturalLanguageToSQLTranslator translator;
    
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
     * Main method to process natural language queries
     */
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