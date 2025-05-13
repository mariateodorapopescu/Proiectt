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
 * Servlet pentru obținerea listei de sedii și găsirea celui mai apropiat sediu
 */
public class GetSediiiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediiiServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna lista de sedii sau cel mai apropiat sediu
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Verificăm dacă s-a cerut cel mai apropiat sediu
        String latStr = request.getParameter("lat");
        String lonStr = request.getParameter("lon");
        
        try {
            if (latStr != null && lonStr != null) {
                // Convertim coordonatele
                double lat = Double.parseDouble(latStr);
                double lon = Double.parseDouble(lonStr);
                
                // Găsim cel mai apropiat sediu
                Map<String, Object> nearestSediu = getNearestSediu(lat, lon);
                
                // Verificăm dacă am găsit un sediu
                if (nearestSediu.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Nu s-a găsit niciun sediu.\"}");
                    return;
                }
                
                // Convertim sediul în JSON și îl trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(nearestSediu));
            } else {
                // Obținem toate sediile
                List<Map<String, Object>> sedii = getAllSedii();
                
                // Verificăm dacă am găsit sedii
                if (sedii.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Nu s-au găsit sedii.\"}");
                    return;
                }
                
                // Convertim lista de sedii în JSON și o trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(sedii));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Coordonate invalide.\"}");
            return;
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține toate sediile din baza de date
     */
    private List<Map<String, Object>> getAllSedii() throws SQLException, ClassNotFoundException {
        List<Map<String, Object>> sedii = new ArrayList<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Query pentru a obține toate sediile din baza de date
        String sql = "SELECT * FROM sedii WHERE latitudine IS NOT NULL AND longitudine IS NOT NULL";
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> sediu = new HashMap<>();
                sediu.put("id_sediu", rs.getInt("id_sediu"));
                sediu.put("nume_sediu", rs.getString("nume_sediu"));
                sediu.put("tip_sediu", rs.getString("tip_sediu"));
                sediu.put("strada", rs.getString("strada"));
                sediu.put("cod", rs.getString("cod"));
                sediu.put("oras", rs.getString("oras"));
                sediu.put("judet", rs.getString("judet"));
                sediu.put("tara", rs.getString("tara"));
                sediu.put("telefon", rs.getString("telefon"));
                sediu.put("email", rs.getString("email"));
                sediu.put("latitudine", rs.getDouble("latitudine"));
                sediu.put("longitudine", rs.getDouble("longitudine"));
                
                // Adăugăm sediul în listă
                sedii.add(sediu);
            }
        }
        
        return sedii;
    }
    
    /**
     * Găsește cel mai apropiat sediu de coordonatele date
     */
    private Map<String, Object> getNearestSediu(double lat, double lon) throws SQLException, ClassNotFoundException {
        // Obținem toate sediile
        List<Map<String, Object>> sedii = getAllSedii();
        
        // Verificăm dacă există sedii
        if (sedii.isEmpty()) {
            return new HashMap<>();
        }
        
        // Inițializăm cu primul sediu
        Map<String, Object> nearestSediu = sedii.get(0);
        double minDistance = calculateDistance(lat, lon, 
                                              (double) nearestSediu.get("latitudine"), 
                                              (double) nearestSediu.get("longitudine"));
        
        // Căutăm cel mai apropiat sediu
        for (int i = 1; i < sedii.size(); i++) {
            Map<String, Object> sediu = sedii.get(i);
            double distance = calculateDistance(lat, lon, 
                                               (double) sediu.get("latitudine"), 
                                               (double) sediu.get("longitudine"));
            
            if (distance < minDistance) {
                minDistance = distance;
                nearestSediu = sediu;
            }
        }
        
        // Adăugăm distanța în kilometri
        nearestSediu.put("distanta_km", minDistance);
        
        return nearestSediu;
    }
    
    /**
     * Calculează distanța între două puncte geografice folosind formula Haversine
     * Returnează distanța în kilometri
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // Convertim din grade în radiani
        lat1 = Math.toRadians(lat1);
        lon1 = Math.toRadians(lon1);
        lat2 = Math.toRadians(lat2);
        lon2 = Math.toRadians(lon2);
        
        // Raza Pământului în kilometri
        double R = 6371.0;
        
        // Formula Haversine
        double dlon = lon2 - lon1;
        double dlat = lat2 - lat1;
        double a = Math.pow(Math.sin(dlat / 2), 2) + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon / 2), 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;
        
        // Returnăm distanța rotunjită la 2 zecimale
        return Math.round(distance * 100.0) / 100.0;
    }
}