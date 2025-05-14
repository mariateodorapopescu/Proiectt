package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Servlet pentru obținerea locației utilizatorului și a locației concediului său
 */
public class GetUserToConcediuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetUserToConcediuServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile utilizatorului și concediului
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului și ID-ul concediului din parametrii cererii
        String userIdStr = request.getParameter("userId");
        String concediuIdStr = request.getParameter("concediuId");
        
        if (userIdStr == null || userIdStr.isEmpty() || concediuIdStr == null || concediuIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID concediu lipsă\"}");
            return;
        }
        
        int userId, concediuId;
        try {
            userId = Integer.parseInt(userIdStr);
            concediuId = Integer.parseInt(concediuIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID concediu invalid\"}");
            return;
        }
        
        try {
            // Obținem locațiile utilizatorului și concediului
            Map<String, Object> result = getUserAndConcediuLocations(userId, concediuId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_location") || !result.containsKey("concediu_location")) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Nu s-au găsit locațiile necesare pentru rută.\"}");
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
     * Obține locațiile utilizatorului și concediului din baza de date
     */
    private Map<String, Object> getUserAndConcediuLocations(int userId, int concediuId) throws SQLException, ClassNotFoundException {
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
                        return result; // Utilizator negăsit
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
                        return result; // Locație utilizator negăsită
                    }
                }
            }
            
            result.put("user_location", userLocation);
            
            // Obținem informațiile despre concediu
            String concediuSql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                                "DATE_FORMAT(c.start_c, '%d.%m.%Y') as start_formatat, " +
                                "DATE_FORMAT(c.end_c, '%d.%m.%Y') as end_formatat " +
                                "FROM concedii c " +
                                "JOIN tipcon tc ON c.tip = tc.tip " +
                                "WHERE c.id = ?";
            
            Map<String, Object> concediuInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuSql)) {
                stmt.setInt(1, concediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        concediuInfo.put("id", rs.getInt("id"));
                        concediuInfo.put("start_c", rs.getDate("start_c").toString());
                        concediuInfo.put("end_c", rs.getDate("end_c").toString());
                        concediuInfo.put("start_formatat", rs.getString("start_formatat"));
                        concediuInfo.put("end_formatat", rs.getString("end_formatat"));
                        concediuInfo.put("motiv", rs.getString("motiv"));
                        concediuInfo.put("locatie", rs.getString("locatie"));
                        concediuInfo.put("tip_concediu", rs.getString("tip_concediu"));
                    } else {
                        return result; // Concediu negăsit
                    }
                }
            }
            
            result.put("concediu_info", concediuInfo);
            
            // Obținem locația concediului
            String concediuLocationSql = "SELECT lc.id_locatie, lc.strada, lc.longitudine, lc.latitudine, lc.cod, lc.oras, lc.judet, lc.tara " +
                                       "FROM locatii_concedii lc " +
                                       "WHERE lc.id_concediu = ? AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL";
            
            Map<String, Object> concediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuLocationSql)) {
                stmt.setInt(1, concediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        concediuLocation.put("id_locatie", rs.getInt("id_locatie"));
                        concediuLocation.put("strada", rs.getString("strada"));
                        concediuLocation.put("longitudine", rs.getDouble("longitudine"));
                        concediuLocation.put("latitudine", rs.getDouble("latitudine"));
                        concediuLocation.put("cod", rs.getString("cod"));
                        concediuLocation.put("oras", rs.getString("oras"));
                        concediuLocation.put("judet", rs.getString("judet"));
                        concediuLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        concediuLocation.put("adresa_completa", adresaCompleta);
                        
                        // Calculăm distanța dintre locația utilizatorului și concediu
                        double userLat = (double) userLocation.get("latitudine");
                        double userLon = (double) userLocation.get("longitudine");
                        double concediuLat = rs.getDouble("latitudine");
                        double concediuLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userLat, userLon, concediuLat, concediuLon);
                        concediuLocation.put("distanta_km", distanta);
                    } else {
                        return result; // Locație concediu negăsită
                    }
                }
            }
            
            result.put("concediu_location", concediuLocation);
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