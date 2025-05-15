package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Servlet pentru obținerea locației utilizatorului și a sediului selectat
 */
public class GetUserToSediuAnyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetUserToSediuAnyServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile utilizatorului și sediului selectat
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului și ID-ul sediului din parametrii cererii
        String userIdStr = request.getParameter("userId");
        String sediuIdStr = request.getParameter("sediuId");
        
        if (userIdStr == null || userIdStr.isEmpty() || sediuIdStr == null || sediuIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID sediu lipsă\"}");
            return;
        }
        
        int userId, sediuId;
        try {
            userId = Integer.parseInt(userIdStr);
            sediuId = Integer.parseInt(sediuIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID sediu invalid\"}");
            return;
        }
        
        try {
            // Obținem locațiile utilizatorului și sediului
            Map<String, Object> result = getUserAndSediuLocations(userId, sediuId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_location") || !result.containsKey("sediu_location")) {
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
     * Obține locațiile utilizatorului și sediului din baza de date
     */
    private Map<String, Object> getUserAndSediuLocations(int userId, int sediuId) throws SQLException, ClassNotFoundException {
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
                        throw new SQLException("Utilizatorul cu ID-ul " + userId + " nu a fost găsit.");
                    }
                }
            }
            
            result.put("user_info", userInfo);
            
            // Obținem informațiile sediului selectat
            String sediuSql = "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, telefon, email " +
                              "FROM sedii WHERE id_sediu = ?";
            Map<String, Object> sediuInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(sediuSql)) {
                stmt.setInt(1, sediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        sediuInfo.put("id_sediu", rs.getInt("id_sediu"));
                        sediuInfo.put("nume_sediu", rs.getString("nume_sediu"));
                        sediuInfo.put("tip_sediu", rs.getString("tip_sediu"));
                        sediuInfo.put("strada", rs.getString("strada"));
                        sediuInfo.put("oras", rs.getString("oras"));
                        sediuInfo.put("judet", rs.getString("judet"));
                        sediuInfo.put("tara", rs.getString("tara"));
                        sediuInfo.put("telefon", rs.getString("telefon"));
                        sediuInfo.put("email", rs.getString("email"));
                    } else {
                        throw new SQLException("Sediul cu ID-ul " + sediuId + " nu a fost găsit.");
                    }
                }
            }
            
            result.put("sediu_info", sediuInfo);
            
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
                        throw new SQLException("Nu s-a găsit locația pentru utilizatorul cu ID-ul " + userId + ".");
                    }
                }
            }
            
            result.put("user_location", userLocation);
            
            // Obținem locația sediului selectat
            String sediuLocationSql = "SELECT id_sediu, strada, longitudine, latitudine, cod, oras, judet, tara " +
                                     "FROM sedii " +
                                     "WHERE id_sediu = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> sediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(sediuLocationSql)) {
                stmt.setInt(1, sediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        sediuLocation.put("id_sediu", rs.getInt("id_sediu"));
                        sediuLocation.put("strada", rs.getString("strada"));
                        sediuLocation.put("longitudine", rs.getDouble("longitudine"));
                        sediuLocation.put("latitudine", rs.getDouble("latitudine"));
                        sediuLocation.put("cod", rs.getString("cod"));
                        sediuLocation.put("oras", rs.getString("oras"));
                        sediuLocation.put("judet", rs.getString("judet"));
                        sediuLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        sediuLocation.put("adresa_completa", adresaCompleta);
                        
                        // Calculăm distanța dintre locația utilizatorului și sediu
                        double userLat = (double) userLocation.get("latitudine");
                        double userLon = (double) userLocation.get("longitudine");
                        double sediuLat = rs.getDouble("latitudine");
                        double sediuLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userLat, userLon, sediuLat, sediuLon);
                        sediuLocation.put("distanta_km", distanta);
                    } else {
                        throw new SQLException("Nu s-a găsit locația pentru sediul cu ID-ul " + sediuId + " sau coordonatele lipsesc.");
                    }
                }
            }
            
            result.put("sediu_location", sediuLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + " și sediul " + sediuId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("Sediu info: " + sediuInfo);
            System.out.println("User location: " + userLocation);
            System.out.println("Sediu location: " + sediuLocation);
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