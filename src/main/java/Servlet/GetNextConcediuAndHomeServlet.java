package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Servlet pentru obținerea celui mai apropiat concediu ca dată și locația utilizatorului
 */
public class GetNextConcediuAndHomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetNextConcediuAndHomeServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locația utilizatorului și cel mai apropiat concediu ca dată
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
            // Obținem locația de acasă a utilizatorului și cel mai apropiat concediu
            Map<String, Object> result = getUserHomeAndNextConcediu(userId);
            
            // Verificăm dacă am găsit datele necesare
            if (result.isEmpty() || !result.containsKey("user_location") || !result.containsKey("next_concediu")) {
                if (result.containsKey("error")) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"" + result.get("error") + "\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Nu s-au găsit locațiile necesare.\"}");
                }
                return;
            }
            
            // Convertim rezultatul în JSON și îl trimitem ca răspuns
            ObjectMapper objectMapper = new ObjectMapper();
            out.print(objectMapper.writeValueAsString(result));
            
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține locația de acasă a utilizatorului și cel mai apropiat concediu ca dată
     */
    private Map<String, Object> getUserHomeAndNextConcediu(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului
            String userSql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep FROM useri u " +
                             "JOIN departament d ON u.id_dep = d.id_dep " +
                             "WHERE u.id = ?";
            
            Map<String, Object> userInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(userSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        userInfo.put("id", rs.getInt("id"));
                        userInfo.put("nume", rs.getString("nume"));
                        userInfo.put("prenume", rs.getString("prenume"));
                        userInfo.put("id_dep", rs.getInt("id_dep"));
                        userInfo.put("nume_dep", rs.getString("nume_dep"));
                    } else {
                        result.put("error", "Utilizatorul nu a fost găsit.");
                        return result;
                    }
                }
            }
            
            result.put("user_info", userInfo);
            
            // Obținem locația utilizatorului (adresa de acasă)
            String userLocationSql = "SELECT id_locatie, strada, longitudine, latitudine, cod, oras, judet, tara " +
                                    "FROM locatii_useri " +
                                    "WHERE id_user = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> userLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(userLocationSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        userLocation.put("id_locatie", rs.getInt("id_locatie"));
                        userLocation.put("strada", rs.getString("strada"));
                        userLocation.put("longitudine", rs.getDouble("longitudine"));
                        userLocation.put("latitudine", rs.getDouble("latitudine"));
                        userLocation.put("cod", rs.getString("cod"));
                        userLocation.put("oras", rs.getString("oras"));
                        userLocation.put("judet", rs.getString("judet"));
                        userLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        userLocation.put("adresa_completa", adresaCompleta);
                    } else {
                        result.put("error", "Locația utilizatorului nu a fost găsită.");
                        return result;
                    }
                }
            }
            
            result.put("user_location", userLocation);
            
            // Obținem cel mai apropiat concediu ca dată
            // Data curentă în format SQL
            String currentDate = LocalDate.now().toString();
            
            String concediuSql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, c.status, c.tip, c.durata, " +
                                 "s.nume_status, tc.motiv as tip_concediu, " +
                                 "lc.strada, lc.longitudine, lc.latitudine, lc.cod, lc.oras, lc.judet, lc.tara " +
                                 "FROM concedii c " +
                                 "JOIN statusuri s ON c.status = s.status " +
                                 "JOIN tipcon tc ON c.tip = tc.tip " +
                                 "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                                 "WHERE c.id_ang = ? " +
                                 "AND c.start_c >= ? " +   // Doar concedii viitoare sau care încep astăzi
                                 "AND (c.status = 1 OR c.status = 2) " +  // Doar concedii aprobate de șef sau director
                                 "AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL " +
                                 "ORDER BY c.start_c ASC " +  // Cel mai apropiat concediu
                                 "LIMIT 1";                  // Doar primul rezultat
            
            Map<String, Object> nextConcediu = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuSql)) {
                stmt.setInt(1, userId);
                stmt.setString(2, currentDate);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        nextConcediu.put("id", rs.getInt("id"));
                        nextConcediu.put("start_c", rs.getString("start_c"));
                        nextConcediu.put("end_c", rs.getString("end_c"));
                        nextConcediu.put("motiv", rs.getString("motiv"));
                        nextConcediu.put("locatie", rs.getString("locatie"));
                        nextConcediu.put("status", rs.getInt("status"));
                        nextConcediu.put("status_text", rs.getString("nume_status"));
                        nextConcediu.put("tip", rs.getInt("tip"));
                        nextConcediu.put("tip_text", rs.getString("tip_concediu"));
                        nextConcediu.put("durata", rs.getInt("durata"));
                        
                        // Adăugăm locația concediului
                        nextConcediu.put("strada", rs.getString("strada"));
                        nextConcediu.put("longitudine", rs.getDouble("longitudine"));
                        nextConcediu.put("latitudine", rs.getDouble("latitudine"));
                        nextConcediu.put("cod", rs.getString("cod"));
                        nextConcediu.put("oras", rs.getString("oras"));
                        nextConcediu.put("judet", rs.getString("judet"));
                        nextConcediu.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        nextConcediu.put("adresa_completa", adresaCompleta);
                        
                        // Calculăm distanța de la locația utilizatorului
                        double userLat = (double) userLocation.get("latitudine");
                        double userLon = (double) userLocation.get("longitudine");
                        double concediuLat = rs.getDouble("latitudine");
                        double concediuLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userLat, userLon, concediuLat, concediuLon);
                        nextConcediu.put("distanta_km", distanta);
                        
                        // Calculăm zilele rămase până la concediu
                        LocalDate startDate = LocalDate.parse(rs.getString("start_c"));
                        LocalDate today = LocalDate.now();
                        long daysUntil = java.time.temporal.ChronoUnit.DAYS.between(today, startDate);
                        
                        nextConcediu.put("zile_ramase", daysUntil);
                    } else {
                        result.put("error", "Nu s-a găsit niciun concediu viitor pentru utilizator.");
                        return result;
                    }
                }
            }
            
            result.put("next_concediu", nextConcediu);
        }
        
        return result;
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