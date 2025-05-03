package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.google.gson.Gson;

/**
 * HRChatServlet - Backend for the HR Chat Assistant
 * Handles natural language queries about HR data and transforms them into SQL
 */
public class HRChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "password";
    
    // Keywords for entity recognition
    private static final String[] DEPARTMENT_KEYWORDS = {
        "hr", "finante", "it", "juridic", "marketing", "vanzari", "logistica", 
        "productie", "achizitii", "cercetare", "dezvoltare", "customer support", 
        "administrativ", "comunicare", "training", "security", "management", 
        "business intelligence", "contabilitate", "control intern", "servicii generale"
    };
    
    private static final String[] DATE_KEYWORDS = {
        "astazi", "azi", "ieri", "saptamana", "luna", "an", "anul", 
        "craciun", "paste", "revelion", "vacanta de iarna", "vacanta de vara",
        "1 decembrie", "1 mai", "8 martie", "ziua națională"
    };
    
    private static final String[] STATUS_KEYWORDS = {
        "activ", "inactiv", "concediu", "disponibil", "indisponibil", 
        "aprobat", "neaprobat", "respins", "asteptare", "finalizat", "terminat"
    };
    
    // Response class for JSON
    private class ChatResponse {
        private String message;
        private String type;
        private List<Map<String, Object>> data;
        
        public ChatResponse(String message) {
            this.message = message;
            this.type = "text";
        }
        
        public ChatResponse(String message, List<Map<String, Object>> data) {
            this.message = message;
            this.type = "table";
            this.data = data;
        }

        public String getMessage() {
            return message;
        }

        public String getType() {
            return type;
        }

        public List<Map<String, Object>> getData() {
            return data;
        }
    }
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public HRChatServlet() {
        super();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            // Get query from request
            String query = request.getParameter("query");
            if (query == null || query.trim().isEmpty()) {
                sendErrorResponse(response, "Empty query");
                return;
            }
            
            // Get session for maintaining conversation context
            HttpSession session = request.getSession();
            String lastQueryType = (String) session.getAttribute("lastQueryType");
            List<Map<String, Object>> lastQueryData = (List<Map<String, Object>>) session.getAttribute("lastQueryData");
            
            // Process the query
            ChatResponse chatResponse;
            
            // Check if it's a follow-up question
            if (isFollowUp(query) && lastQueryType != null) {
                chatResponse = handleFollowUp(lastQueryType, lastQueryData);
            } else {
                // Process new query
                chatResponse = processQuery(query);
                
                // Save context for follow-up questions
                if (chatResponse.getType().equals("table")) {
                    session.setAttribute("lastQueryType", determineQueryType(query));
                    session.setAttribute("lastQueryData", chatResponse.getData());
                } else {
                    session.setAttribute("lastQueryType", null);
                    session.setAttribute("lastQueryData", null);
                }
            }
            
            // Convert to JSON and send response
            Gson gson = new Gson();
            String jsonResponse = gson.toJson(chatResponse);
            response.getWriter().write(jsonResponse);
            
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(response, "An error occurred: " + e.getMessage());
        }
    }
    
    /**
     * Sends an error response in JSON format
     */
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        ChatResponse errorResponse = new ChatResponse("Îmi pare rău, a apărut o eroare: " + message);
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(errorResponse);
        response.getWriter().write(jsonResponse);
    }
    
    /**
     * Determines if a query is a follow-up question
     */
    private boolean isFollowUp(String query) {
        String normalizedQuery = query.toLowerCase().trim();
        return normalizedQuery.equals("da") || 
               normalizedQuery.equals("sigur") || 
               normalizedQuery.equals("bineînțeles") || 
               normalizedQuery.equals("bineinteles") || 
               normalizedQuery.equals("te rog") || 
               normalizedQuery.equals("vreau") || 
               normalizedQuery.matches("da[,.]? .*") || 
               normalizedQuery.matches("vreau .*detalii.*") || 
               normalizedQuery.matches("arata[-]mi .*detalii.*") || 
               normalizedQuery.matches("arata[-]mi .*mai mult.*");
    }
    
    /**
     * Handles follow-up questions based on the previous query type
     */
    private ChatResponse handleFollowUp(String lastQueryType, List<Map<String, Object>> lastQueryData) {
        if (lastQueryData == null || lastQueryData.isEmpty()) {
            return new ChatResponse("Nu am date anterioare pentru a vă oferi mai multe detalii.");
        }
        
        // Based on the previous query type, provide more detailed information
        switch (lastQueryType) {
            case "christmas_leave":
                return new ChatResponse("Iată mai multe detalii despre angajații în concediu de Crăciun:", lastQueryData);
                
            case "employee":
                return new ChatResponse("Iată informații detaliate despre angajați:", lastQueryData);
                
            case "department":
                return new ChatResponse("Iată informații detaliate despre departamente:", lastQueryData);
                
            case "leave":
                return new ChatResponse("Iată informații detaliate despre concedii:", lastQueryData);
                
            case "document":
                return new ChatResponse("Iată informații detaliate despre adeverințe:", lastQueryData);
                
            case "project":
                return new ChatResponse("Iată informații detaliate despre proiecte:", lastQueryData);
                
            default:
                return new ChatResponse("Nu am înțeles ce informații suplimentare doriți. Vă rog să fiți mai specific.");
        }
    }
    
    /**
     * Main function to process a query
     */
    private ChatResponse processQuery(String query) {
        String normalizedQuery = query.toLowerCase();
        
        // Check for greeting or help request
        if (containsGreeting(normalizedQuery)) {
            return new ChatResponse("Bună ziua! Cu ce vă pot ajuta astăzi? Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
        }
        
        if (normalizedQuery.contains("ajutor") || normalizedQuery.contains("help") || normalizedQuery.contains("ajuta")) {
            return new ChatResponse("Vă pot ajuta cu informații despre angajați, departamente, concedii, adeverințe și proiecte. De exemplu, puteți întreba:\n\n" +
                                   "- \"Câți angajați au luat concediu de Crăciun?\"\n" +
                                   "- \"Arată-mi lista departamentelor\"\n" +
                                   "- \"Cine este în concediu astăzi?\"\n" +
                                   "- \"Ce adeverințe sunt în așteptare?\"\n" +
                                   "- \"Care sunt proiectele active?\"\n\n" +
                                   "După ce primiți un răspuns, puteți cere detalii suplimentare spunând simplu \"Da\" sau \"Arată-mi mai multe detalii\".");
        }
        
        // Determine query type and execute appropriate handler
        String queryType = determineQueryType(normalizedQuery);
        
        try {
            switch (queryType) {
                case "christmas_leave":
                    return handleChristmasLeaveQuery();
                    
                case "employee":
                    return handleEmployeeQuery(normalizedQuery);
                    
                case "department":
                    return handleDepartmentQuery(normalizedQuery);
                    
                case "leave":
                    return handleLeaveQuery(normalizedQuery);
                    
                case "document":
                    return handleDocumentQuery(normalizedQuery);
                    
                case "project":
                    return handleProjectQuery(normalizedQuery);
                    
                default:
                    return new ChatResponse("Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return new ChatResponse("A apărut o eroare în procesarea interogării: " + e.getMessage());
        }
    }

	/**
     * Determines the type of query based on keywords
     */
    private String determineQueryType(String query) {
        // Check for Christmas leave query
        if (query.contains("concediu") && (query.contains("craciun") || query.contains("crăciun"))) {
            return "christmas_leave";
        }
        
        // Check for employee queries
        if (query.contains("angajat") || query.contains("angajați") || query.contains("angajati") || 
            query.contains("personal") || query.contains("salariat") || query.contains("salariati") || 
            query.contains("personal") || query.contains("colegi")) {
            return "employee";
        }
        
        // Check for department queries
        if (query.contains("departament") || query.contains("departamente") || 
            query.contains("structura") || query.contains("divizie") || 
            query.contains("divizii") || query.contains("echipe")) {
            return "department";
        }
        
        // Check for leave queries
        if (query.contains("concediu") || query.contains("concedii") || 
            query.contains("vacanta") || query.contains("vacanță") || 
            query.contains("liber") || query.contains("absenta") || 
            query.contains("absență") || query.contains("zi libera")) {
            return "leave";
        }
        
        // Check for document queries
        if (query.contains("adeverinta") || query.contains("adeverință") || 
            query.contains("adeverinte") || query.contains("adeverințe") || 
            query.contains("document") || query.contains("documente") || 
            query.contains("formular") || query.contains("formulare")) {
            return "document";
        }
        
        // Check for project queries
        if (query.contains("proiect") || query.contains("proiecte") || 
            query.contains("task") || query.contains("taskuri") || 
            query.contains("sarcina") || query.contains("sarcini")) {
            return "project";
        }
        
        // Default to employee if no specific category is matched
        return "employee";
    }
    
    /**
     * Handle Christmas leave query
     */
    private ChatResponse handleChristmasLeaveQuery() throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Query to find employees on leave during Christmas (24-25 December)
            String sql = "SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
                        "c.start_c, c.end_c, c.durata, c.motiv, c.locatie, s.nume_status AS status " +
                        "FROM concedii c " +
                        "JOIN useri u ON c.id_ang = u.id " +
                        "JOIN departament d ON u.id_dep = d.id_dep " +
                        "JOIN tipuri t ON u.tip = t.tip " +
                        "JOIN statusuri s ON c.status = s.status " +
                        "WHERE c.start_c <= '2024-12-25' AND c.end_c >= '2024-12-24' " + 
                        "AND c.status >= 0";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("nume", rs.getString("nume"));
                row.put("prenume", rs.getString("prenume"));
                row.put("departament", rs.getString("departament"));
                row.put("functie", rs.getString("functie"));
                row.put("data_inceput", formatDate(rs.getDate("start_c")));
                row.put("data_sfarsit", formatDate(rs.getDate("end_c")));
                row.put("durata", rs.getInt("durata"));
                row.put("motiv", rs.getString("motiv"));
                row.put("locatie", rs.getString("locatie"));
                row.put("status", rs.getString("status"));
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit angajați în concediu în perioada Crăciunului.");
            }
            
            // Initial response, brief information
            return new ChatResponse("Am descoperit că " + results.size() + " angajați au luat concediu care include perioada Crăciunului. Doriți să aflați mai multe detalii?", results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }

	/**
     * Handle employee queries
     */
    private ChatResponse handleEmployeeQuery(String query) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Base SQL for employee queries
            StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
                "u.email, u.telefon, u.data_nasterii, u.adresa, u.salariu_brut " +
                "FROM useri u " +
                "JOIN departament d ON u.id_dep = d.id_dep " +
                "JOIN tipuri t ON u.tip = t.tip " +
                "WHERE 1=1"
            );
            
            // Add filters based on query
            // Department filter
            for (String dept : DEPARTMENT_KEYWORDS) {
                if (query.contains(dept)) {
                    sql.append(" AND d.nume_dep LIKE '%").append(dept).append("%'");
                    break;
                }
            }
            
            // Status filter
            if (query.contains("activ")) {
                sql.append(" AND u.activ = 1");
            } else if (query.contains("inactiv")) {
                sql.append(" AND u.activ = 0");
            }
            
            // Salary filter
            Pattern salaryPattern = Pattern.compile("(salariu|salarii)\\s+(?:mai\\s+)?(mare|mic|peste|sub)\\s+(?:de|decat)?\\s+(\\d+)");
            Matcher salaryMatcher = salaryPattern.matcher(query);
            if (salaryMatcher.find()) {
                String comparison = salaryMatcher.group(2);
                String amount = salaryMatcher.group(3);
                
                if (comparison.equals("mare") || comparison.equals("peste")) {
                    sql.append(" AND u.salariu_brut > ").append(amount);
                } else if (comparison.equals("mic") || comparison.equals("sub")) {
                    sql.append(" AND u.salariu_brut < ").append(amount);
                }
            }
            
            // Finalize SQL
            sql.append(" ORDER BY u.nume, u.prenume");
            
            stmt = conn.prepareStatement(sql.toString());
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("nume", rs.getString("nume"));
                row.put("prenume", rs.getString("prenume"));
                row.put("departament", rs.getString("departament"));
                row.put("functie", rs.getString("functie"));
                row.put("email", rs.getString("email"));
                row.put("telefon", rs.getString("telefon"));
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit angajați care să corespundă criteriilor dvs.");
            }
            
            // Initial response, brief information
            String message = "Am găsit " + results.size() + " angajați";
            
            // Add context to message
            for (String dept : DEPARTMENT_KEYWORDS) {
                if (query.contains(dept)) {
                    message += " în departamentul " + dept.toUpperCase();
                    break;
                }
            }
            
            message += ". Doriți să vedeți lista completă?";
            
            return new ChatResponse(message, results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }
    
    /**
     * Handle department queries
     */
    private ChatResponse handleDepartmentQuery(String query) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Determine if we need department details with employee counts
            String sql;
            if (query.contains("angajati") || query.contains("angajați") || query.contains("numar")) {
                sql = "SELECT d.id_dep, d.nume_dep, COUNT(u.id) AS nr_angajati " +
                      "FROM departament d " +
                      "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                      "GROUP BY d.id_dep, d.nume_dep " +
                      "ORDER BY d.nume_dep";
            } else if (query.contains("locatie") || query.contains("locații") || query.contains("adresa")) {
                sql = "SELECT d.id_dep, d.nume_dep, ld.strada, ld.oras, ld.judet, ld.tara " +
                      "FROM departament d " +
                      "LEFT JOIN locatii_departamente ld ON d.id_dep = ld.id_dep " +
                      "ORDER BY d.nume_dep";
            } else {
                sql = "SELECT d.id_dep, d.nume_dep FROM departament d ORDER BY d.nume_dep";
            }
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id_dep"));
                row.put("nume", rs.getString("nume_dep"));
                
                // Add additional columns based on query type
                if (query.contains("angajati") || query.contains("angajați") || query.contains("numar")) {
                    row.put("nr_angajati", rs.getInt("nr_angajati"));
                } else if (query.contains("locatie") || query.contains("locații") || query.contains("adresa")) {
                    row.put("strada", rs.getString("strada"));
                    row.put("oras", rs.getString("oras"));
                    row.put("judet", rs.getString("judet"));
                    row.put("tara", rs.getString("tara"));
                }
                
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit informații despre departamente.");
            }
            
            return new ChatResponse("Am găsit " + results.size() + " departamente. Doriți să vedeți lista completă?", results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }
    
    /**
     * Handle leave queries
     */
    private ChatResponse handleLeaveQuery(String query) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Base SQL for leave queries
            StringBuilder sql = new StringBuilder(
                "SELECT c.id, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
                "c.start_c, c.end_c, c.durata, c.motiv, c.locatie, s.nume_status AS status, " +
                "ct.motiv as tip_concediu " +
                "FROM concedii c " +
                "JOIN useri u ON c.id_ang = u.id " +
                "JOIN departament d ON u.id_dep = d.id_dep " +
                "JOIN tipuri t ON u.tip = t.tip " +
                "JOIN statusuri s ON c.status = s.status " +
                "JOIN tipcon ct ON c.tip = ct.tip " +
                "WHERE 1=1"
            );
            
            // Add date filters
            if (query.contains("astazi") || query.contains("azi")) {
                sql.append(" AND CURDATE() BETWEEN c.start_c AND c.end_c");
            } else if (query.contains("luna") || query.contains("curent")) {
                sql.append(" AND MONTH(c.start_c) = MONTH(CURDATE()) AND YEAR(c.start_c) = YEAR(CURDATE())");
            } else if (query.contains("an") || query.contains("anul")) {
                sql.append(" AND YEAR(c.start_c) = YEAR(CURDATE())");
            }
            
            // Add status filters
            if (query.contains("aprobat")) {
                sql.append(" AND c.status = 2");
            } else if (query.contains("neaprobat") || query.contains("asteptare")) {
                sql.append(" AND c.status = 0");
            } else if (query.contains("respins")) {
                sql.append(" AND c.status < 0");
            }
            
            // Add department filters
            for (String dept : DEPARTMENT_KEYWORDS) {
                if (query.contains(dept)) {
                    sql.append(" AND d.nume_dep LIKE '%").append(dept).append("%'");
                    break;
                }
            }
            
            // Add leave type filters
            if (query.contains("medical")) {
                sql.append(" AND ct.motiv LIKE '%medical%'");
            } else if (query.contains("odihna")) {
                sql.append(" AND ct.motiv LIKE '%odihna%'");
            } else if (query.contains("fara plata")) {
                sql.append(" AND ct.motiv LIKE '%fara plata%'");
            }
            
            // Finalize SQL
            sql.append(" ORDER BY c.start_c DESC");
            
            stmt = conn.prepareStatement(sql.toString());
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("nume", rs.getString("nume"));
                row.put("prenume", rs.getString("prenume"));
                row.put("departament", rs.getString("departament"));
                row.put("functie", rs.getString("functie"));
                row.put("data_inceput", formatDate(rs.getDate("start_c")));
                row.put("data_sfarsit", formatDate(rs.getDate("end_c")));
                row.put("durata", rs.getInt("durata"));
                row.put("motiv", rs.getString("motiv"));
                row.put("tip_concediu", rs.getString("tip_concediu"));
                row.put("locatie", rs.getString("locatie"));
                row.put("status", rs.getString("status"));
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit concedii care să corespundă criteriilor dvs.");
            }
            
            // Create context-aware message
            String message = "Am găsit " + results.size() + " concedii";
            
            if (query.contains("astazi") || query.contains("azi")) {
                message += " pentru ziua de astăzi";
            } else if (query.contains("luna") || query.contains("curent")) {
                message += " pentru luna curentă";
            } else if (query.contains("an") || query.contains("anul")) {
                message += " pentru anul curent";
            }
            
            for (String dept : DEPARTMENT_KEYWORDS) {
                if (query.contains(dept)) {
                    message += " în departamentul " + dept.toUpperCase();
                    break;
                }
            }
            
            message += ". Doriți să vedeți lista completă?";
            
            return new ChatResponse(message, results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }

	/**
     * Handle document queries
     */
    private ChatResponse handleDocumentQuery(String query) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Base SQL for document queries
            StringBuilder sql = new StringBuilder(
                "SELECT a.id, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, " +
                "a.creare, a.modif " +
                "FROM adeverinte a " +
                "JOIN tip_adev ta ON a.tip = ta.id " +
                "JOIN statusuri s ON a.status = s.status " +
                "WHERE 1=1"
            );
            
            // Add document type filters
            if (query.contains("salariat")) {
                sql.append(" AND ta.denumire LIKE '%salariat%'");
            } else if (query.contains("venit")) {
                sql.append(" AND ta.denumire LIKE '%venit%'");
            } else if (query.contains("medical")) {
                sql.append(" AND ta.denumire LIKE '%medical%'");
            }
            
            // Add status filters
            if (query.contains("aprobat")) {
                sql.append(" AND a.status = 2");
            } else if (query.contains("neaprobat") || query.contains("asteptare")) {
                sql.append(" AND a.status = 0");
            } else if (query.contains("respins")) {
                sql.append(" AND a.status < 0");
            }
            
            // Add date filters
            if (query.contains("astazi") || query.contains("azi")) {
                sql.append(" AND DATE(a.creare) = CURDATE()");
            } else if (query.contains("luna") || query.contains("curent")) {
                sql.append(" AND MONTH(a.creare) = MONTH(CURDATE()) AND YEAR(a.creare) = YEAR(CURDATE())");
            } else if (query.contains("an") || query.contains("anul")) {
                sql.append(" AND YEAR(a.creare) = YEAR(CURDATE())");
            }
            
            // Finalize SQL
            sql.append(" ORDER BY a.creare DESC");
            
            stmt = conn.prepareStatement(sql.toString());
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("tip_adeverinta", rs.getString("tip_adeverinta"));
                row.put("motiv", rs.getInt("id"));
                row.put("tip_adeverinta", rs.getString("tip_adeverinta"));
                row.put("motiv", rs.getString("motiv"));
                row.put("status", rs.getString("status"));
                row.put("data_creare", formatDate(rs.getDate("creare")));
                row.put("data_modificare", formatDate(rs.getDate("modif")));
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit adeverințe care să corespundă criteriilor dvs.");
            }
            
            // Create context-aware message
            String message = "Am găsit " + results.size() + " adeverințe";
            
            if (query.contains("salariat")) {
                message += " de tip salariat";
            } else if (query.contains("venit")) {
                message += " de tip venit";
            } else if (query.contains("medical")) {
                message += " de tip medical";
            }
            
            if (query.contains("aprobat")) {
                message += " aprobate";
            } else if (query.contains("neaprobat") || query.contains("asteptare")) {
                message += " în așteptare";
            } else if (query.contains("respins")) {
                message += " respinse";
            }
            
            message += ". Doriți să vedeți lista completă?";
            
            return new ChatResponse(message, results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }
    
    /**
     * Handle project queries
     */
    private ChatResponse handleProjectQuery(String query) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql;
            
            // Determine project query type
            if (query.contains("echipe") || query.contains("supervizor")) {
                // Projects with teams and supervisors
                sql = "SELECT p.id, p.nume AS nume_proiect, p.descriere, p.start, p.end, " +
                      "e.id AS id_echipa, e.nume AS nume_echipa, u.nume AS nume_supervizor, u.prenume AS prenume_supervizor " +
                      "FROM proiecte p " +
                      "LEFT JOIN echipe e ON p.id = e.id_prj " +
                      "LEFT JOIN useri u ON e.supervizor = u.id " +
                      "ORDER BY p.start DESC";
            } else if (query.contains("taskuri") || query.contains("sarcini")) {
                // Projects with tasks
                sql = "SELECT t.id, t.nume AS nume_task, p.nume AS nume_proiect, " +
                      "u.nume AS nume_angajat, u.prenume AS prenume_angajat, " +
                      "s.procent AS procent_finalizare, t.start, t.end " +
                      "FROM tasks t " +
                      "JOIN proiecte p ON t.id_prj = p.id " +
                      "JOIN useri u ON t.id_ang = u.id " +
                      "JOIN statusuri2 s ON t.status = s.id ";
                
                // Add filter for incomplete/complete tasks
                if (query.contains("neterminate") || query.contains("incomplete")) {
                    sql += "WHERE s.procent < 100 ";
                } else if (query.contains("terminate") || query.contains("complete") || 
                          query.contains("finalizate")) {
                    sql += "WHERE s.procent = 100 ";
                }
                
                sql += "ORDER BY t.end";
            } else if (query.contains("cine") || query.contains("lucreaza")) {
                // Who works on specific projects
                sql = "SELECT u.id, u.nume, u.prenume, d.nume_dep AS departament, " +
                      "p.nume AS nume_proiect, e.nume AS nume_echipa " +
                      "FROM useri u " +
                      "JOIN departament d ON u.id_dep = d.id_dep " +
                      "JOIN tasks t ON t.id_ang = u.id " +
                      "JOIN proiecte p ON t.id_prj = p.id " +
                      "JOIN echipe e ON e.id_prj = p.id " +
                      "GROUP BY u.id, u.nume, u.prenume, d.nume_dep, p.nume, e.nume " +
                      "ORDER BY u.nume, u.prenume";
            } else {
                // Default project list
                sql = "SELECT p.id, p.nume, p.descriere, p.start, p.end, " +
                      "COUNT(DISTINCT e.id) AS nr_echipe, " +
                      "COUNT(DISTINCT t.id) AS nr_taskuri " +
                      "FROM proiecte p " +
                      "LEFT JOIN echipe e ON p.id = e.id_prj " +
                      "LEFT JOIN tasks t ON p.id = t.id_prj " +
                      "GROUP BY p.id, p.nume, p.descriere, p.start, p.end ";
                
                // Add filter for active projects
                if (query.contains("active") || query.contains("curente") || 
                    query.contains("prezent")) {
                    sql += "HAVING p.start <= CURDATE() AND (p.end >= CURDATE() OR p.end IS NULL) ";
                }
                
                sql += "ORDER BY p.start DESC";
            }
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            List<Map<String, Object>> results = new ArrayList<>();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                
                // Add columns based on query type
                if (query.contains("echipe") || query.contains("supervizor")) {
                    row.put("id", rs.getInt("id"));
                    row.put("nume_proiect", rs.getString("nume_proiect"));
                    row.put("descriere", rs.getString("descriere"));
                    row.put("data_inceput", formatDate(rs.getDate("start")));
                    row.put("data_sfarsit", formatDate(rs.getDate("end")));
                    row.put("id_echipa", rs.getInt("id_echipa"));
                    row.put("nume_echipa", rs.getString("nume_echipa"));
                    row.put("nume_supervizor", rs.getString("nume_supervizor"));
                    row.put("prenume_supervizor", rs.getString("prenume_supervizor"));
                } else if (query.contains("taskuri") || query.contains("sarcini")) {
                    row.put("id", rs.getInt("id"));
                    row.put("nume_task", rs.getString("nume_task"));
                    row.put("nume_proiect", rs.getString("nume_proiect"));
                    row.put("nume_angajat", rs.getString("nume_angajat"));
                    row.put("prenume_angajat", rs.getString("prenume_angajat"));
                    row.put("procent_finalizare", rs.getInt("procent_finalizare"));
                    row.put("data_inceput", formatDate(rs.getDate("start")));
                    row.put("data_sfarsit", formatDate(rs.getDate("end")));
                } else if (query.contains("cine") || query.contains("lucreaza")) {
                    row.put("id", rs.getInt("id"));
                    row.put("nume", rs.getString("nume"));
                    row.put("prenume", rs.getString("prenume"));
                    row.put("departament", rs.getString("departament"));
                    row.put("nume_proiect", rs.getString("nume_proiect"));
                    row.put("nume_echipa", rs.getString("nume_echipa"));
                } else {
                    row.put("id", rs.getInt("id"));
                    row.put("nume", rs.getString("nume"));
                    row.put("descriere", rs.getString("descriere"));
                    row.put("data_inceput", formatDate(rs.getDate("start")));
                    row.put("data_sfarsit", formatDate(rs.getDate("end")));
                    row.put("nr_echipe", rs.getInt("nr_echipe"));
                    row.put("nr_taskuri", rs.getInt("nr_taskuri"));
                }
                
                results.add(row);
            }
            
            if (results.isEmpty()) {
                return new ChatResponse("Nu am găsit proiecte care să corespundă criteriilor dvs.");
            }
            
            // Create context-aware message
            String message = "Am găsit " + results.size();
            
            if (query.contains("taskuri") || query.contains("sarcini")) {
                message += " taskuri";
                
                if (query.contains("neterminate") || query.contains("incomplete")) {
                    message += " neterminate";
                } else if (query.contains("terminate") || query.contains("complete") || query.contains("finalizate")) {
                    message += " finalizate";
                }
            } else if (query.contains("cine") || query.contains("lucreaza")) {
                message += " angajați care lucrează la proiecte";
            } else {
                message += " proiecte";
                
                if (query.contains("active") || query.contains("curente") || query.contains("prezent")) {
                    message += " active";
                }
            }
            
            message += ". Doriți să vedeți lista completă?";
            
            return new ChatResponse(message, results);
            
        } finally {
            close(rs, stmt, conn);
        }
    }
    
    /**
     * Helper method to check if query contains greeting
     */
    private boolean containsGreeting(String text) {
        String[] greetings = {"buna", "salut", "hello", "hi", "hey", "bună ziua", "neața", "ziua bună"};
        for (String greeting : greetings) {
            if (text.contains(greeting)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Helper method to format date
     */
    private String formatDate(Date date) {
        if (date == null) {
            return null;
        }
        SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
        return sdf.format(date);
    }
    
    /**
     * Helper method to close database resources
     */
    private void close(ResultSet rs, PreparedStatement stmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}