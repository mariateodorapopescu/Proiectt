package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
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
    
    private void processQuery(String query, MyUser currentUser, PrintWriter out) {
        String lowerQuery = query.toLowerCase();
        
        // Check if it's a follow-up question (user confirming they want to see details)
        if (lowerQuery.equals("da") || lowerQuery.contains("detalii") || lowerQuery.contains("arata") || lowerQuery.contains("arată")) {
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
        
        // Check for different types of queries
        if (lowerQuery.contains("angajat") || lowerQuery.contains("angajați") || lowerQuery.contains("personal")) {
            processEmployeeQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("departament")) {
            processDepartmentQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("concediu") || lowerQuery.contains("concedii") || lowerQuery.contains("vacanță") || lowerQuery.contains("vacanta")) {
            processLeaveQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("adeverință") || lowerQuery.contains("adeverinta") || lowerQuery.contains("adeverințe") || lowerQuery.contains("adeverinte")) {
            processCertificateQuery(lowerQuery, currentUser, out);
        } else if (lowerQuery.contains("proiect") || lowerQuery.contains("proiecte")) {
            processProjectQuery(lowerQuery, currentUser, out);
        } else {
            // Default response for unrecognized queries
            sendSimpleTextResponse(out, "Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.");
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