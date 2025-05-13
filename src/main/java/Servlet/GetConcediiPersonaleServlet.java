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

/**
 * Servlet pentru obținerea concediilor personale ale unui utilizator, inclusiv informații despre locația geografică
 */

public class GetConcediiPersonaleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetConcediiPersonaleServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna lista de concedii personale ale unui utilizator
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului din parametrii cererii
        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator lipsă\"}");
            return;
        }
        
        int userId;
        try {
            userId = Integer.parseInt(userIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator invalid\"}");
            return;
        }
        
        try {
            List<Map<String, Object>> concedii = getConcediiPersonale(userId);
            
            // Convertim lista de concedii în JSON și o trimitem ca răspuns
            ObjectMapper objectMapper = new ObjectMapper();
            out.print(objectMapper.writeValueAsString(concedii));
            
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține lista de concedii personale ale unui utilizator din baza de date
     */
    private List<Map<String, Object>> getConcediiPersonale(int userId) throws SQLException, ClassNotFoundException {
        List<Map<String, Object>> concedii = new ArrayList<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Query pentru a obține concediile utilizatorului împreună cu locațiile lor geografice
        String sql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                     "s.nume_status as status, lc.latitudine, lc.longitudine, " +
                     "CONCAT(lc.strada, ', ', lc.oras, ', ', lc.judet, ', ', lc.tara) as adresa_completa " +
                     "FROM concedii c " +
                     "JOIN tipcon tc ON c.tip = tc.tip " +
                     "JOIN statusuri s ON c.status = s.status " +
                     "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                     "WHERE c.id_ang = ? " +
                     "ORDER BY c.start_c DESC";
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> concediu = new HashMap<>();
                    
                    concediu.put("id", rs.getInt("id"));
                    concediu.put("start_c", rs.getString("start_c"));
                    concediu.put("end_c", rs.getString("end_c"));
                    concediu.put("motiv", rs.getString("motiv"));
                    concediu.put("locatie", rs.getString("locatie"));
                    concediu.put("tip", rs.getString("tip_concediu"));
                    concediu.put("status", rs.getString("status"));
                    
                    // Adăugăm coordonatele geografice dacă există
                    double lat = rs.getDouble("latitudine");
                    double lon = rs.getDouble("longitudine");
                    
                    if (!rs.wasNull() && lat != 0 && lon != 0) {
                        concediu.put("latitudine", lat);
                        concediu.put("longitudine", lon);
                        concediu.put("adresa_completa", rs.getString("adresa_completa"));
                    }
                    
                    concedii.add(concediu);
                }
            }
        }
        System.out.println(concedii);
        return concedii;
    }
}