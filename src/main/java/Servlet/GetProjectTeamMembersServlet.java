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

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

public class GetProjectTeamMembersServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Database connection parameters
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        
        PrintWriter out = response.getWriter();
        ObjectMapper mapper = new ObjectMapper();
        
        try {
            // Obține parametrii din request
            String projectIdStr = request.getParameter("projectId");
            String userIerarhieStr = request.getParameter("userIerarhie");
            String userIdStr = request.getParameter("userId");
            
            if (projectIdStr == null || projectIdStr.trim().isEmpty()) {
                sendErrorResponse(out, mapper, "Project ID is required");
                return;
            }
            
            int projectId = Integer.parseInt(projectIdStr);
            int userIerarhie = userIerarhieStr != null ? Integer.parseInt(userIerarhieStr) : 999;
            int userId = userIdStr != null ? Integer.parseInt(userIdStr) : 0;
            
            // Obține membrii echipei pentru proiect
            List<Map<String, Object>> teamMembers = getProjectTeamMembers(projectId, userIerarhie, userId);
            Map<String, Object> projectInfo = getProjectInfo(projectId);
            
            // Construiește răspunsul JSON
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("projectId", projectId);
            responseData.put("members", teamMembers);
            responseData.put("memberCount", teamMembers.size());
            responseData.put("projectInfo", projectInfo);
            responseData.put("timestamp", System.currentTimeMillis());
            
            out.print(mapper.writeValueAsString(responseData));
            
        } catch (NumberFormatException e) {
            sendErrorResponse(out, mapper, "Invalid numeric parameter: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(out, mapper, "Database error: " + e.getMessage());
        } finally {
            out.flush();
        }
    }
    
    /**
     * Obține membrii echipei pentru un proiect specific
     */
    private List<Map<String, Object>> getProjectTeamMembers(int projectId, int userIerarhie, int userId) 
            throws SQLException {
        
        List<Map<String, Object>> members = new ArrayList<>();
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            
            // Strategia 1: Încearcă să găsești membrii prin echipe
            String sql1 = "SELECT DISTINCT u.id, u.nume, u.prenume, u.email, " +
                         "t.denumire AS functie, d.nume_dep AS departament, " +
                         "t.ierarhie, e.nume AS nume_echipa, e.id AS id_echipa " +
                         "FROM useri u " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN echipe e ON u.id_team = e.id " +
                         "WHERE e.id_prj = ? " +
                         "AND u.tip <> 34 " +
                         "AND t.ierarhie >= ? " +
                         "ORDER BY " +
                         "CASE WHEN u.id = ? THEN 0 ELSE 1 END, " +
                         "t.ierarhie ASC, u.nume ASC";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql1)) {
                pstmt.setInt(1, projectId);
                pstmt.setInt(2, userIerarhie);
                pstmt.setInt(3, userId);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> member = new HashMap<>();
                        member.put("id", rs.getInt("id"));
                        member.put("nume", rs.getString("nume"));
                        member.put("prenume", rs.getString("prenume"));
                        member.put("email", rs.getString("email"));
                        member.put("functie", rs.getString("functie"));
                        member.put("departament", rs.getString("departament"));
                        member.put("ierarhie", rs.getInt("ierarhie"));
                        member.put("nume_echipa", rs.getString("nume_echipa"));
                        member.put("id_echipa", rs.getInt("id_echipa"));
                        member.put("isCurrentUser", rs.getInt("id") == userId);
                        
                        members.add(member);
                    }
                }
            }
            
            // Strategia 2: Dacă nu s-au găsit membri prin echipe, caută prin tasks existente
            if (members.isEmpty() || (members.size() == 1 && members.get(0).get("isCurrentUser").equals(true))) {
                String sql2 = "SELECT DISTINCT u.id, u.nume, u.prenume, u.email, " +
                             "t.denumire AS functie, d.nume_dep AS departament, " +
                             "t.ierarhie " +
                             "FROM useri u " +
                             "JOIN tipuri t ON u.tip = t.tip " +
                             "JOIN departament d ON u.id_dep = d.id_dep " +
                             "JOIN tasks tk ON u.id = tk.id_ang " +
                             "WHERE tk.id_prj = ? " +
                             "AND u.tip <> 34 " +
                             "AND t.ierarhie >= ? " +
                             "ORDER BY " +
                             "CASE WHEN u.id = ? THEN 0 ELSE 1 END, " +
                             "t.ierarhie ASC, u.nume ASC";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql2)) {
                    pstmt.setInt(1, projectId);
                    pstmt.setInt(2, userIerarhie);
                    pstmt.setInt(3, userId);
                    
                    try (ResultSet rs = pstmt.executeQuery()) {
                        // Clear previous results if we're doing fallback
                        if (members.size() <= 1) {
                            members.clear();
                        }
                        
                        while (rs.next()) {
                            Map<String, Object> member = new HashMap<>();
                            member.put("id", rs.getInt("id"));
                            member.put("nume", rs.getString("nume"));
                            member.put("prenume", rs.getString("prenume"));
                            member.put("email", rs.getString("email"));
                            member.put("functie", rs.getString("functie"));
                            member.put("departament", rs.getString("departament"));
                            member.put("ierarhie", rs.getInt("ierarhie"));
                            member.put("nume_echipa", "Echipă din task-uri");
                            member.put("id_echipa", 0);
                            member.put("isCurrentUser", rs.getInt("id") == userId);
                            member.put("source", "tasks");
                            
                            members.add(member);
                        }
                    }
                }
            }
            
            // Strategia 3: Dacă încă nu avem membri, adaugă utilizatori generali
            if (members.isEmpty()) {
                addFallbackMembers(conn, projectId, userIerarhie, userId, members);
            }
            
            // Asigură-te că utilizatorul curent este întotdeauna inclus
            boolean currentUserExists = members.stream()
                .anyMatch(m -> m.get("isCurrentUser").equals(true));
            
            if (!currentUserExists) {
                addCurrentUser(conn, userId, members);
            }
        }
        
        return members;
    }
    
    /**
     * Adaugă membri suplimentari dacă echipa proiectului este goală
     */
    private void addFallbackMembers(Connection conn, int projectId, int userIerarhie, int userId, 
                                   List<Map<String, Object>> existingMembers) throws SQLException {
        
        // Dacă nu avem membri sau avem doar utilizatorul curent, adaugă TOȚI utilizatorii
        String fallbackSql = "SELECT DISTINCT u.id, u.nume, u.prenume, u.email, " +
                            "t.denumire AS functie, d.nume_dep AS departament, " +
                            "t.ierarhie " +
                            "FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "WHERE u.tip <> 34 " +  // Exclude doar admin accounts
                            "ORDER BY " +
                            "CASE WHEN u.id = ? THEN 0 ELSE 1 END, " +  // Current user first
                            "t.ierarhie ASC, u.nume ASC";  // Apoi toți ceilalți sortați
        
        try (PreparedStatement pstmt = conn.prepareStatement(fallbackSql)) {
            pstmt.setInt(1, userId);  // Pentru ORDER BY
            
            try (ResultSet rs = pstmt.executeQuery()) {
                // Verifică dacă utilizatorul curent există deja
                boolean currentUserExists = existingMembers.stream()
                    .anyMatch(m -> m.get("isCurrentUser").equals(true));
                
                while (rs.next()) {
                    int memberId = rs.getInt("id");
                    
                    // Evită duplicatele
                    boolean alreadyExists = existingMembers.stream()
                        .anyMatch(m -> ((Integer) m.get("id")).equals(memberId));
                    
                    if (!alreadyExists) {
                        Map<String, Object> member = new HashMap<>();
                        member.put("id", memberId);
                        member.put("nume", rs.getString("nume"));
                        member.put("prenume", rs.getString("prenume"));
                        member.put("email", rs.getString("email"));
                        member.put("functie", rs.getString("functie"));
                        member.put("departament", rs.getString("departament"));
                        member.put("ierarhie", rs.getInt("ierarhie"));
                        member.put("nume_echipa", "Toți angajații");
                        member.put("id_echipa", 0);
                        member.put("isCurrentUser", memberId == userId);
                        member.put("isFallback", true);
                        
                        existingMembers.add(member);
                    }
                }
            }
        }
    }
    
    /**
     * Obține informații despre proiect
     */
    private Map<String, Object> getProjectInfo(int projectId) throws SQLException {
        Map<String, Object> projectInfo = new HashMap<>();
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            String sql = "SELECT p.id, p.nume, p.descriere, p.start, p.end, " +
                        "u.nume AS manager_nume, u.prenume AS manager_prenume, " +
                        "COUNT(DISTINCT e.id) AS num_echipe, " +
                        "COUNT(DISTINCT t.id) AS num_taskuri " +
                        "FROM proiecte p " +
                        "LEFT JOIN useri u ON p.supervizor = u.id " +
                        "LEFT JOIN echipe e ON p.id = e.id_prj " +
                        "LEFT JOIN tasks t ON p.id = t.id_prj " +
                        "WHERE p.id = ? " +
                        "GROUP BY p.id, p.nume, p.descriere, p.start, p.end, " +
                        "u.nume, u.prenume";
            
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, projectId);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        projectInfo.put("id", rs.getInt("id"));
                        projectInfo.put("nume", rs.getString("nume"));
                        projectInfo.put("descriere", rs.getString("descriere"));
                        projectInfo.put("start", rs.getDate("start"));
                        projectInfo.put("end", rs.getDate("end"));
                        
                        String managerNume = rs.getString("manager_nume");
                        String managerPrenume = rs.getString("manager_prenume");
                        if (managerNume != null && managerPrenume != null) {
                            projectInfo.put("manager", managerNume + " " + managerPrenume);
                        } else {
                            projectInfo.put("manager", "Nespecificat");
                        }
                        
                        projectInfo.put("num_echipe", rs.getInt("num_echipe"));
                        projectInfo.put("num_taskuri", rs.getInt("num_taskuri"));
                    }
                }
            }
        }
        
        return projectInfo;
    }
    
    /**
     * Adaugă utilizatorul curent în lista de membri
     */
    private void addCurrentUser(Connection conn, int userId, List<Map<String, Object>> members) 
            throws SQLException {
        
        String sql = "SELECT u.id, u.nume, u.prenume, u.email, " +
                    "t.denumire AS functie, d.nume_dep AS departament, " +
                    "t.ierarhie " +
                    "FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "WHERE u.id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> member = new HashMap<>();
                    member.put("id", rs.getInt("id"));
                    member.put("nume", rs.getString("nume"));
                    member.put("prenume", rs.getString("prenume"));
                    member.put("email", rs.getString("email"));
                    member.put("functie", rs.getString("functie"));
                    member.put("departament", rs.getString("departament"));
                    member.put("ierarhie", rs.getInt("ierarhie"));
                    member.put("nume_echipa", "Auto-inclus");
                    member.put("id_echipa", 0);
                    member.put("isCurrentUser", true);
                    member.put("source", "current_user");
                    
                    // Adaugă la început
                    members.add(0, member);
                }
            }
        }
    }
    private void sendErrorResponse(PrintWriter out, ObjectMapper mapper, String errorMessage) 
            throws IOException {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("error", errorMessage);
        errorResponse.put("members", new ArrayList<>());
        errorResponse.put("memberCount", 0);
        errorResponse.put("timestamp", System.currentTimeMillis());
        
        out.print(mapper.writeValueAsString(errorResponse));
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}