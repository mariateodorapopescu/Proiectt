package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

import org.json.JSONArray;
import org.json.JSONObject;

import bean.MyUser;
public class ChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get query from the request
        String query = request.getParameter("query");
        
        if (query == null || query.isEmpty()) {
            sendErrorResponse(out, "Query parameter is missing");
            return;
        }
        
        // Get current user from session
        HttpSession session = request.getSession(false);
        if (session == null) {
            sendErrorResponse(out, "No active session");
            return;
        }
        
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            sendErrorResponse(out, "User not logged in");
            return;
        }
        
        // Process the query and generate a response
        try {
            processQuery(query, currentUser, out);
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(out, "Error processing query: " + e.getMessage());
        }
    }
    
    /**
     * Convertește o întrebare în limbaj natural într-o interogare SQL
     * @param naturalLanguageQuery întrebarea în limbaj natural
     * @return interogarea SQL corespunzătoare sau null dacă nu poate fi procesată
     */
    private String translateToSQL(String naturalLanguageQuery) {
        // Normalizăm textul - lowercase și eliminăm diacriticele pentru ușurință
        String normalizedQuery = normalizeText(naturalLanguageQuery);
        
        // Tipare de bază pentru întrebări comune
        
        // 1. Listare departamente
        if (matchesPattern(normalizedQuery, 
                "ce departamente", 
                "lista departamente", 
                "arata departamente", 
                "care sunt departamentele")) {
            return "SELECT DISTINCT nume_dep FROM departament ORDER BY nume_dep";
        }
        
        // 2. Listare angajați dintr-un departament
        Pattern deptEmployeePattern = Pattern.compile("(angaj[aă][tț]i|persoane|oameni).+(departament[ul]* |din )([a-z0-9]+)", 
                                                     Pattern.CASE_INSENSITIVE);
        Matcher deptMatcher = deptEmployeePattern.matcher(normalizedQuery);
        if (deptMatcher.find()) {
            String department = deptMatcher.group(3);
            return "SELECT u.nume, u.prenume, t.denumire AS functie " +
                   "FROM useri u " +
                   "JOIN departament d ON u.id_dep = d.id_dep " +
                   "JOIN tipuri t ON u.tip = t.tip " +
                   "WHERE UPPER(d.nume_dep) LIKE UPPER('%" + department + "%') " +
                   "ORDER BY u.nume, u.prenume";
        }
        
        // 3. Listare tipuri/poziții într-un departament
        Pattern positionPattern = Pattern.compile("(tipuri|functii|pozitii|posturi).+(departament[ul]* |in )([a-z0-9]+)", 
                                                Pattern.CASE_INSENSITIVE);
        Matcher posMatcher = positionPattern.matcher(normalizedQuery);
        if (posMatcher.find()) {
            String department = posMatcher.group(3);
            return "SELECT DISTINCT t.denumire " +
                   "FROM useri u " +
                   "JOIN departament d ON u.id_dep = d.id_dep " +
                   "JOIN tipuri t ON u.tip = t.tip " +
                   "WHERE UPPER(d.nume_dep) LIKE UPPER('%" + department + "%') " +
                   "ORDER BY t.denumire";
        }
        
        // 4. Concedii într-o perioadă
        if (matchesPattern(normalizedQuery, "concedii craciun", "concediu de craciun")) {
            return "SELECT u.nume, u.prenume, d.nume_dep AS departament, c.start_c, c.end_c, c.motiv " +
                   "FROM concedii c " +
                   "JOIN useri u ON c.id_ang = u.id " +
                   "JOIN departament d ON u.id_dep = d.id_dep " +
                   "WHERE c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24' " +
                   "ORDER BY c.start_c";
        }
        
        // 5. Număr angajați pe departament
        if (matchesPattern(normalizedQuery, "cati angajati", "numar angajati", "numar de angajati")) {
            return "SELECT d.nume_dep, COUNT(u.id) AS numar_angajati " +
                   "FROM departament d " +
                   "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                   "GROUP BY d.nume_dep " +
                   "ORDER BY COUNT(u.id) DESC";
        }
        
        // 6. Salarii
        if (matchesPattern(normalizedQuery, "salarii", "salariu", "cat castiga")) {
            return "SELECT t.denumire, t.salariu " +
                   "FROM tipuri t " +
                   "ORDER BY t.salariu DESC";
        }
        
        // 7. Proiecte active
        if (matchesPattern(normalizedQuery, "proiecte active", "proiecte curente")) {
            return "SELECT p.nume, p.descriere, p.start, p.end " +
                   "FROM proiecte p " +
                   "WHERE p.end >= CURDATE() " +
                   "ORDER BY p.start DESC";
        }
        
        // Nu s-a putut traduce - returnam null
        return null;
    }

    /**
     * Verifică dacă un text conține oricare dintre șabloanele date
     */
    private boolean matchesPattern(String text, String... patterns) {
        for (String pattern : patterns) {
            if (text.contains(pattern)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Normalizează textul - elimină diacritice, face lowercase
     */
    private String normalizeText(String text) {
        // Lowercase
        String result = text.toLowerCase();
        
        // Eliminare diacritice
        result = result.replace("ă", "a")
                       .replace("â", "a")
                       .replace("î", "i")
                       .replace("ș", "s")
                       .replace("ț", "t");
        
        return result;
    }
    
    /**
     * Funcție pentru a genera o interogare SQL bazată pe textul introdus de utilizator
     * @param inputText Textul introdus de utilizator
     * @return QueryInfo obiect care conține interogarea SQL și parametrii
     */
    private QueryInfo parseUserQuery(String inputText) {
        String normalizedText = inputText.toLowerCase().trim();
        QueryInfo queryInfo = new QueryInfo();
        
        // Detectează ce tip de informație solicită utilizatorul
        if (normalizedText.contains("tipuri") || normalizedText.contains("poziții") || normalizedText.contains("functii")) {
            // Interogare pentru tipuri de angajați
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT DISTINCT t.denumire FROM useri u ");
            sql.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sql.append("JOIN tipuri t ON u.tip = t.tip ");
            
            // Verifică dacă se specifică un departament anume
            String departament = extractDepartmentName(normalizedText);
            if (departament != null) {
                sql.append("WHERE UPPER(d.nume_dep) LIKE UPPER(?) ");
                queryInfo.addParameter("%" + departament + "%");
            }
            
            sql.append("ORDER BY t.denumire");
            queryInfo.setSql(sql.toString());
            queryInfo.setResponseFormatter(this::formatPositionList);
        } else if (normalizedText.contains("salariu") || normalizedText.contains("salarii")) {
            // Interogare pentru informații despre salarii
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT t.denumire, t.salariu FROM tipuri t ");
            sql.append("ORDER BY t.salariu DESC");
            queryInfo.setSql(sql.toString());
            queryInfo.setResponseFormatter(this::formatSalaryList);
        } 
        // Poți adăuga mai multe tipuri de interogări aici
        else {
            queryInfo.setInvalid(true);
            queryInfo.setErrorMessage("Nu am putut identifica tipul de interogare dorit.");
        }
        
        return queryInfo;
    }

    /**
     * Extrage numele departamentului din textul de intrare
     */
    private String extractDepartmentName(String text) {
        // Caută mențiuni de departamente folosind regex
        Pattern pattern = Pattern.compile("departament(?:ul)? (\\w+)", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(text);
        
        if (matcher.find()) {
            return matcher.group(1);
        }
        
        // Verifică și alte departamente cunoscute
        String[] knownDepartments = {"HR", "IT", "Finante", "Juridic", "Marketing"};
        for (String dept : knownDepartments) {
            if (text.contains(dept.toLowerCase())) {
                return dept;
            }
        }
        
        return null;
    }

    /**
     * Formatează lista de poziții într-un răspuns clar
     */
    private String formatPositionList(ResultSet rs) throws SQLException {
        List<String> positions = new ArrayList<>();
        while (rs.next()) {
            positions.add(rs.getString("denumire"));
        }
        
        if (positions.isEmpty()) {
            return "Nu am găsit niciun tip de poziție care să corespundă criteriilor.";
        }
        
        return "Am găsit următoarele tipuri de poziții: " + String.join(", ", positions);
    }

    /**
     * Formatează lista de salarii într-un răspuns clar
     */
    private String formatSalaryList(ResultSet rs) throws SQLException {
        StringBuilder response = new StringBuilder("Informații despre salarii:\n\n");
        while (rs.next()) {
            response.append("- ")
                    .append(rs.getString("denumire"))
                    .append(": ")
                    .append(rs.getInt("salariu"))
                    .append(" RON\n");
        }
        
        return response.toString();
    }
    
    private void processQuery(String query, MyUser currentUser, PrintWriter out) {
        String lowerQuery = query.toLowerCase();
        
        // Prima dată verificăm dacă este o întrebare de follow-up sau o salutare
        // pentru a evita analiza inutilă a interogării
        
        // Check if it's a follow-up question
        if (lowerQuery.equals("da") || lowerQuery.contains("detalii") || 
            lowerQuery.contains("arata") || lowerQuery.contains("arată")) {
            // In a real implementation, we'd retrieve the last query from a session variable
            // For now, we'll assume it's a general inquiry
            sendSimpleTextResponse(out, "Îmi pare rău, nu pot accesa detaliile anterioare în acest moment. Vă rog să reformulați întrebarea specifică.");
            return;
        }
        
        // Handle greetings
        if (containsGreeting(lowerQuery)) {
            sendSimpleTextResponse(out, "Bună ziua! Cu ce vă pot ajuta astăzi? Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
            return;
        }
        
        // Apoi încercăm să parsăm query-ul pentru tipuri speciale de interogări
        try {
            // Parsează query-ul pentru a obține informațiile interogării
            QueryInfo queryInfo = parseUserQuery(query);
            
            if (!queryInfo.isInvalid()) {
                // Am găsit un tip valid de interogare, o executăm
                try (Connection conn = getConnection()) {
                    PreparedStatement stmt = conn.prepareStatement(queryInfo.getSql());
                    
                    // Setează parametrii
                    List<Object> params = queryInfo.getParameters();
                    for (int i = 0; i < params.size(); i++) {
                        Object param = params.get(i);
                        if (param instanceof String) {
                            stmt.setString(i + 1, (String) param);
                        } else if (param instanceof Integer) {
                            stmt.setInt(i + 1, (Integer) param);
                        } else if (param instanceof Date) {
                            stmt.setDate(i + 1, new java.sql.Date(((Date) param).getTime()));
                        }
                    }
                    
                    ResultSet rs = stmt.executeQuery();
                    
                    // Formatează și trimite răspunsul
                    String formattedResponse = queryInfo.getFormatter().format(rs);
                    sendSimpleTextResponse(out, formattedResponse);
                    return;
                }
            }
            // Dacă queryInfo e invalid, continuăm cu procesarea standard
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la procesarea query-ului: " + e.getMessage());
            return;
        }
        
        // Dacă nu am putut procesa query-ul ca unul special, continuăm cu tipurile standard
        
        // Check for different types of queries
        if (lowerQuery.contains("angajat") || lowerQuery.contains("angajați") || lowerQuery.contains("personal")) {
            processEmployeeQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("departament")) {
            processDepartmentQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("concediu") || lowerQuery.contains("concedii") || 
                   lowerQuery.contains("vacanță") || lowerQuery.contains("vacanta")) {
            processLeaveQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("adeverință") || lowerQuery.contains("adeverinta") || 
                   lowerQuery.contains("adeverințe") || lowerQuery.contains("adeverinte")) {
            processCertificateQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("proiect") || lowerQuery.contains("proiecte")) {
            processProjectQuery(lowerQuery, currentUser, out);
        } else {
            // Default response for unrecognized queries
            sendSimpleTextResponse(out, "Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
        }
    }

    /**
     * Formatează lista de angajați într-un răspuns clar
     */
    private String formatEmployeeList(ResultSet rs) throws SQLException {
        List<String> employees = new ArrayList<>();
        while (rs.next()) {
            String employee = rs.getString("nume") + " " + rs.getString("prenume") + 
                              " (" + rs.getString("functie") + ")";
            employees.add(employee);
        }
        
        if (employees.isEmpty()) {
            return "Nu am găsit niciun angajat care să corespundă criteriilor.";
        }
        
        return "Am găsit următorii angajați: " + String.join(", ", employees);
    }

    /**
     * Clasă utilă pentru a stoca informații despre interogare
     */
    private static class QueryInfo {
        private String sql;
        private List<Object> parameters = new ArrayList<>();
        private boolean isInvalid = false;
        private String errorMessage;
        private ResultSetFormatter formatter;
        
        public interface ResultSetFormatter {
            String format(ResultSet rs) throws SQLException;
        }
        
        public void setSql(String sql) {
            this.sql = sql;
        }
        
        public String getSql() {
            return sql;
        }
        
        public void addParameter(Object param) {
            parameters.add(param);
        }
        
        public List<Object> getParameters() {
            return parameters;
        }
        
        public void setInvalid(boolean invalid) {
            isInvalid = invalid;
        }
        
        public boolean isInvalid() {
            return isInvalid;
        }
        
        public void setErrorMessage(String message) {
            this.errorMessage = message;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
        
        public void setResponseFormatter(ResultSetFormatter formatter) {
            this.formatter = formatter;
        }
        
        public ResultSetFormatter getFormatter() {
            return formatter;
        }
    }
    
    /**
     * Process query about employee types/positions in a specific department
     */
    private void processEmployeeTypesQuery(String department, PrintWriter out) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT DISTINCT t.denumire FROM useri u ");
            sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sqlBuilder.append("JOIN tipuri t ON u.tip = t.tip ");
            sqlBuilder.append("WHERE 1=1 ");
            
            if (department != null) {
                sqlBuilder.append("AND UPPER(d.nume_dep) LIKE UPPER(?) ");
            }
            
            sqlBuilder.append("ORDER BY t.denumire");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            
            if (department != null) {
                stmt.setString(1, "%" + department + "%");
            }
            
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("functie", rs.getString("denumire"));
                resultList.add(row);
            }
            
            if (resultList.isEmpty()) {
                if (department != null) {
                    sendSimpleTextResponse(out, "Nu am găsit tipuri de angajați în departamentul " + department + ".");
                } else {
                    sendSimpleTextResponse(out, "Nu am găsit tipuri de angajați în baza de date.");
                }
            } else {
                StringBuilder message = new StringBuilder();
                message.append("Am găsit următoarele tipuri de angajați");
                
                if (department != null) {
                    message.append(" în departamentul ").append(department);
                }
                
                message.append(": ");
                
                List<String> positionNames = new ArrayList<>();
                for (Map<String, Object> row : resultList) {
                    positionNames.add((String) row.get("functie"));
                }
                
                message.append(String.join(", ", positionNames));
                
                sendSimpleTextResponse(out, message.toString());
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    private boolean containsGreeting(String text) {
        String[] greetings = {"buna", "salut", "hello", "hi", "hey", "bună ziua", "neața", "ziua bună", "servus"};
        for (String greeting : greetings) {
            if (text.contains(greeting)) {
                return true;
            }
        }
        return false;
    }
    
    private void processEmployeeQuery(String query, MyUser currentUser, PrintWriter out) {
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
            }
            
            // Position filter
            if (query.contains("director")) {
                sqlBuilder.append("AND t.denumire = 'Director' ");
            } else if (query.contains("intern")) {
                sqlBuilder.append("AND t.denumire = 'Intern' ");
            } else if (query.contains("sef") || query.contains("șef")) {
                sqlBuilder.append("AND t.denumire = 'Sef' ");
            }
            
            // Order by department and name
            sqlBuilder.append("ORDER BY d.nume_dep, u.nume, u.prenume");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            // Convert results to JSON
            List<Map<String, Object>> resultList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("nume", rs.getString("nume"));
                row.put("prenume", rs.getString("prenume"));
                row.put("departament", rs.getString("departament"));
                row.put("functie", rs.getString("functie"));
                row.put("email", rs.getString("email"));
                row.put("telefon", rs.getString("telefon"));
                resultList.add(row);
            }
            
            // Check if we need to show count or details
            boolean showCount = query.contains("câți") || query.contains("cati") || query.contains("număr") || query.contains("numar") || query.contains("count");
            
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
    
    private void processDepartmentQuery(String query, MyUser currentUser, PrintWriter out) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT d.id_dep, d.nume_dep, COUNT(u.id) as nr_angajati ");
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
            }
            
            sqlBuilder.append("GROUP BY d.id_dep, d.nume_dep ");
            sqlBuilder.append("ORDER BY d.nume_dep");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id_dep", rs.getInt("id_dep"));
                row.put("nume_dep", rs.getString("nume_dep"));
                row.put("nr_angajati", rs.getInt("nr_angajati"));
                resultList.add(row);
            }
            
            boolean showCount = query.contains("câte") || query.contains("cate") || query.contains("număr") || query.contains("numar") || query.contains("count");
            
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
    
    private void processLeaveQuery(String query, MyUser currentUser, PrintWriter out) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT c.id AS nr_crt, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, ");
            sqlBuilder.append("t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ");
            sqlBuilder.append("DATEDIFF(c.end_c, c.start_c) + 1 AS durata ");
            sqlBuilder.append("FROM concedii c ");
            sqlBuilder.append("JOIN useri u ON u.id = c.id_ang ");
            sqlBuilder.append("JOIN tipuri t ON u.tip = t.tip ");
            sqlBuilder.append("JOIN departament d ON u.id_dep = d.id_dep ");
            sqlBuilder.append("JOIN statusuri s ON c.status = s.status ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Time period filters
            if (query.contains("craciun") || query.contains("crăciun")) {
                // Christmas period (24-25 December of the current year)
                sqlBuilder.append("AND ((c.start_c <= '2025-12-25' AND c.end_c >= '2025-12-24')) ");
            } else if (query.contains("decembrie") || query.contains("decembr")) {
                sqlBuilder.append("AND (MONTH(c.start_c) = 12 OR MONTH(c.end_c) = 12) ");
            } else if (query.contains("ianuarie") || query.contains("ianuar")) {
                sqlBuilder.append("AND (MONTH(c.start_c) = 1 OR MONTH(c.end_c) = 1) ");
            } else if (query.contains("curent") || query.contains("acest an")) {
                sqlBuilder.append("AND YEAR(c.start_c) = YEAR(CURDATE()) ");
            }
            
            // Department filters
            if (query.contains("hr") || query.contains("resurse") || query.contains("resurse umane")) {
                sqlBuilder.append("AND d.nume_dep = 'HR' ");
            } else if (query.contains("it") || query.contains("tehnologia informatiei")) {
                sqlBuilder.append("AND d.nume_dep = 'IT' ");
            } else if (query.contains("finante") || query.contains("finanțe") || query.contains("financiar")) {
                sqlBuilder.append("AND d.nume_dep = 'Finante' ");
            }
            
            // Status filters
            if (query.contains("aprobat")) {
                sqlBuilder.append("AND c.status IN (1, 2) ");
            } else if (query.contains("neaprobat")) {
                sqlBuilder.append("AND c.status = 0 ");
            } else if (query.contains("respins") || query.contains("dezaprobat")) {
                sqlBuilder.append("AND c.status IN (-1, -2) ");
            }
            
            sqlBuilder.append("ORDER BY c.start_c DESC");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("nr_crt", rs.getInt("nr_crt"));
                row.put("nume", rs.getString("nume"));
                row.put("prenume", rs.getString("prenume"));
                row.put("departament", rs.getString("departament"));
                row.put("functie", rs.getString("functie"));
                row.put("start_c", rs.getDate("start_c").toString());
                row.put("end_c", rs.getDate("end_c").toString());
                row.put("durata", rs.getInt("durata"));
                row.put("motiv", rs.getString("motiv"));
                row.put("locatie", rs.getString("locatie"));
                row.put("status", rs.getString("status"));
                resultList.add(row);
            }
            
            boolean showCount = query.contains("câte") || query.contains("cate") || query.contains("număr") || query.contains("numar") || query.contains("count");
            
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
    
    private void processCertificateQuery(String query, MyUser currentUser, PrintWriter out) {
        // Simple response for certificate queries
        sendSimpleTextResponse(out, "Pentru a obține o adeverință, vă rugăm să contactați departamentul HR " +
                "sau să folosiți funcționalitatea dedicată din secțiunea 'Adeverințe' a aplicației.");
    }
    
    private void processProjectQuery(String query, MyUser currentUser, PrintWriter out) {
        try (Connection conn = getConnection()) {
            StringBuilder sqlBuilder = new StringBuilder();
            sqlBuilder.append("SELECT p.id, p.nume, p.descriere, p.start, p.end, ");
            sqlBuilder.append("(SELECT COUNT(*) FROM echipe e WHERE e.id_prj = p.id) AS nr_echipe, ");
            sqlBuilder.append("(SELECT COUNT(*) FROM tasks t WHERE t.id_prj = p.id) AS nr_taskuri ");
            sqlBuilder.append("FROM proiecte p ");
            sqlBuilder.append("WHERE 1=1 ");
            
            // Status filters
            if (query.contains("activ") || query.contains("curent")) {
                sqlBuilder.append("AND p.end >= CURDATE() ");
            } else if (query.contains("complet") || query.contains("încheiat") || query.contains("incheiat") || query.contains("finalizat")) {
                sqlBuilder.append("AND p.end < CURDATE() ");
            }
            
            sqlBuilder.append("ORDER BY p.start DESC");
            
            PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString());
            ResultSet rs = stmt.executeQuery();
            
            List<Map<String, Object>> resultList = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("nume", rs.getString("nume"));
                row.put("descriere", rs.getString("descriere"));
                if (rs.getDate("start") != null) row.put("start", rs.getDate("start").toString());
                if (rs.getDate("end") != null) row.put("end", rs.getDate("end").toString());
                row.put("nr_echipe", rs.getInt("nr_echipe"));
                row.put("nr_taskuri", rs.getInt("nr_taskuri"));
                resultList.add(row);
            }
            
            boolean showCount = query.contains("câte") || query.contains("cate") || query.contains("număr") || query.contains("numar") || query.contains("count");
            
            if (resultList.isEmpty()) {
                sendSimpleTextResponse(out, "Nu am găsit niciun proiect care să corespundă criteriilor dvs.");
            } else if (showCount) {
                sendTableResponseWithConfirmation(out, "În urma analizei, am găsit " + resultList.size() + 
                        " proiecte care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?", resultList);
            } else {
                sendTableResponse(out, "Am găsit următoarele proiecte:", resultList);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendErrorResponse(out, "Eroare la interogarea bazei de date: " + e.getMessage());
        }
    }
    
    private void sendSimpleTextResponse(PrintWriter out, String message) {
        JSONObject response = new JSONObject();
        response.put("type", "text");
        response.put("message", message);
        out.println(response.toString());
    }
    
    private void sendTableResponse(PrintWriter out, String message, List<Map<String, Object>> data) {
        JSONObject response = new JSONObject();
        response.put("type", "table");
        response.put("message", message);
        response.put("data", new JSONArray(data));
        out.println(response.toString());
    }
    
    private void sendTableResponseWithConfirmation(PrintWriter out, String message, List<Map<String, Object>> data) {
        JSONObject response = new JSONObject();
        response.put("type", "table");
        response.put("message", message);
        response.put("data", new JSONArray(data));
        out.println(response.toString());
    }
    
    private void sendErrorResponse(PrintWriter out, String errorMessage) {
        JSONObject response = new JSONObject();
        response.put("type", "error");
        response.put("message", "Îmi pare rău, a apărut o eroare: " + errorMessage);
        out.println(response.toString());
    }
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
    }
}