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
 * Servlet pentru obținerea concediilor utilizatorului și a locațiilor acestora
 */
public class GetUserConcediiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetUserConcediiServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna concediile utilizatorului
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
        
        // Verificăm dacă s-a cerut un concediu specific
        String concediuIdStr = request.getParameter("concediuId");
        
        try {
            if (concediuIdStr != null) {
                int concediuId = Integer.parseInt(concediuIdStr);
                
                // Obținem concediul specific
                Map<String, Object> concediu = getConcediuById(userId, concediuId);
                
                if (concediu.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Concediul specificat nu a fost găsit sau nu are o locație definită.\"}");
                    return;
                }
                
                // Obținem locația utilizatorului
                Map<String, Object> userLocation = getUserLocation(userId);
                
                if (userLocation.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Locația utilizatorului nu a fost găsită.\"}");
                    return;
                }
                
                // Construim rezultatul
                Map<String, Object> result = new HashMap<>();
                result.put("user_info", getUserInfo(userId));
                result.put("user_location", userLocation);
                result.put("concediu", concediu);
                
                // Convertim rezultatul în JSON și îl trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(result));
            } else {
                // Obținem toate concediile utilizatorului
                List<Map<String, Object>> concedii = getUserConcedii(userId);
                
                if (concedii.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Nu s-au găsit concedii pentru utilizatorul specificat.\"}");
                    return;
                }
                
                // Obținem locația utilizatorului
                Map<String, Object> userLocation = getUserLocation(userId);
                
                if (userLocation.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Locația utilizatorului nu a fost găsită.\"}");
                    return;
                }
                
                // Construim rezultatul
                Map<String, Object> result = new HashMap<>();
                result.put("user_info", getUserInfo(userId));
                result.put("user_location", userLocation);
                result.put("concedii", concedii);
                
                // Convertim rezultatul în JSON și îl trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(result));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID concediu invalid.\"}");
            return;
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține informații despre un utilizator
     */
    private Map<String, Object> getUserInfo(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> userInfo = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            String sql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep FROM useri u " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "WHERE u.id = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        userInfo.put("id", rs.getInt("id"));
                        userInfo.put("nume", rs.getString("nume"));
                        userInfo.put("prenume", rs.getString("prenume"));
                        userInfo.put("id_dep", rs.getInt("id_dep"));
                        userInfo.put("nume_dep", rs.getString("nume_dep"));
                    }
                }
            }
        }
        
        return userInfo;
    }
    
    /**
     * Obține locația unui utilizator
     */
    private Map<String, Object> getUserLocation(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> userLocation = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            String sql = "SELECT id_locatie, strada, longitudine, latitudine, cod, oras, judet, tara " +
                         "FROM locatii_useri " +
                         "WHERE id_user = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
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
                    }
                }
            }
        }
        
        return userLocation;
    }
    
    /**
     * Obține toate concediile unui utilizator cu locațiile acestora
     */
    private List<Map<String, Object>> getUserConcedii(int userId) throws SQLException, ClassNotFoundException {
        List<Map<String, Object>> concedii = new ArrayList<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            String sql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, c.status, c.tip, c.durata, " +
                         "s.nume_status, tc.motiv as tip_concediu, " +
                         "lc.strada, lc.longitudine, lc.latitudine, lc.cod, lc.oras, lc.judet, lc.tara " +
                         "FROM concedii c " +
                         "JOIN statusuri s ON c.status = s.status " +
                         "JOIN tipcon tc ON c.tip = tc.tip " +
                         "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                         "WHERE c.id_ang = ? " +
                         "AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL " +
                         "ORDER BY c.start_c DESC";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> concediu = new HashMap<>();
                        concediu.put("id", rs.getInt("id"));
                        concediu.put("start_c", rs.getString("start_c"));
                        concediu.put("end_c", rs.getString("end_c"));
                        concediu.put("motiv", rs.getString("motiv"));
                        concediu.put("locatie", rs.getString("locatie"));
                        concediu.put("status", rs.getInt("status"));
                        concediu.put("status_text", rs.getString("nume_status"));
                        concediu.put("tip", rs.getInt("tip"));
                        concediu.put("tip_text", rs.getString("tip_concediu"));
                        concediu.put("durata", rs.getInt("durata"));
                        
                        // Adăugăm locația concediului
                        concediu.put("strada", rs.getString("strada"));
                        concediu.put("longitudine", rs.getDouble("longitudine"));
                        concediu.put("latitudine", rs.getDouble("latitudine"));
                        concediu.put("cod", rs.getString("cod"));
                        concediu.put("oras", rs.getString("oras"));
                        concediu.put("judet", rs.getString("judet"));
                        concediu.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        concediu.put("adresa_completa", adresaCompleta);
                        
                        concedii.add(concediu);
                    }
                }
            }
            
            // Calculăm distanța de la locația utilizatorului la fiecare concediu
            Map<String, Object> userLocation = getUserLocation(userId);
            if (!userLocation.isEmpty() && !concedii.isEmpty()) {
                double userLat = (double) userLocation.get("latitudine");
                double userLon = (double) userLocation.get("longitudine");
                
                for (Map<String, Object> concediu : concedii) {
                    double concediuLat = (double) concediu.get("latitudine");
                    double concediuLon = (double) concediu.get("longitudine");
                    
                    double distanta = calculateDistance(userLat, userLon, concediuLat, concediuLon);
                    concediu.put("distanta_km", distanta);
                }
            }
        }
        
        return concedii;
    }
    
    /**
     * Obține un concediu specific după ID-ul său
     */
    private Map<String, Object> getConcediuById(int userId, int concediuId) throws SQLException, ClassNotFoundException {
        Map<String, Object> concediu = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            String sql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, c.status, c.tip, c.durata, " +
                         "s.nume_status, tc.motiv as tip_concediu, " +
                         "lc.strada, lc.longitudine, lc.latitudine, lc.cod, lc.oras, lc.judet, lc.tara " +
                         "FROM concedii c " +
                         "JOIN statusuri s ON c.status = s.status " +
                         "JOIN tipcon tc ON c.tip = tc.tip " +
                         "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                         "WHERE c.id_ang = ? AND c.id = ? " +
                         "AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, concediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        concediu.put("id", rs.getInt("id"));
                        concediu.put("start_c", rs.getString("start_c"));
                        concediu.put("end_c", rs.getString("end_c"));
                        concediu.put("motiv", rs.getString("motiv"));
                        concediu.put("locatie", rs.getString("locatie"));
                        concediu.put("status", rs.getInt("status"));
                        concediu.put("status_text", rs.getString("nume_status"));
                        concediu.put("tip", rs.getInt("tip"));
                        concediu.put("tip_text", rs.getString("tip_concediu"));
                        concediu.put("durata", rs.getInt("durata"));
                        
                        // Adăugăm locația concediului
                        concediu.put("strada", rs.getString("strada"));
                        concediu.put("longitudine", rs.getDouble("longitudine"));
                        concediu.put("latitudine", rs.getDouble("latitudine"));
                        concediu.put("cod", rs.getString("cod"));
                        concediu.put("oras", rs.getString("oras"));
                        concediu.put("judet", rs.getString("judet"));
                        concediu.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        concediu.put("adresa_completa", adresaCompleta);
                        
                        // Calculăm distanța de la locația utilizatorului
                        Map<String, Object> userLocation = getUserLocation(userId);
                        if (!userLocation.isEmpty()) {
                            double userLat = (double) userLocation.get("latitudine");
                            double userLon = (double) userLocation.get("longitudine");
                            double concediuLat = rs.getDouble("latitudine");
                            double concediuLon = rs.getDouble("longitudine");
                            
                            double distanta = calculateDistance(userLat, userLon, concediuLat, concediuLon);
                            concediu.put("distanta_km", distanta);
                        }
                    }
                }
            }
        }
        
        return concediu;
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