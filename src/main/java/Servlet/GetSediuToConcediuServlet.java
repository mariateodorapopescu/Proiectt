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
 * Servlet pentru obținerea locațiilor sediului și concediului selectat
 */
public class GetSediuToConcediuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToConcediuServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile sediului și concediului selectat
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
            // Obținem locațiile sediului și concediului
            Map<String, Object> result = getSediuAndConcediuLocations(userId, concediuId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("sediu_location") || !result.containsKey("concediu_location")) {
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
     * Obține locațiile sediului și concediului din baza de date
     */
    private Map<String, Object> getSediuAndConcediuLocations(int userId, int concediuId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului și sediului său
            String userSediuSql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep, u.id_sediu, s.nume_sediu, " +
                                  "s.tip_sediu, s.strada as sediu_strada, s.oras as sediu_oras, s.judet as sediu_judet, " +
                                  "s.tara as sediu_tara, s.latitudine as sediu_lat, s.longitudine as sediu_long " +
                                  "FROM useri u " +
                                  "JOIN departament d ON u.id_dep = d.id_dep " +
                                  "JOIN sedii s ON u.id_sediu = s.id_sediu " +
                                  "WHERE u.id = ?";
            
            Map<String, Object> userInfo = new HashMap<>();
            Map<String, Object> sediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(userSediuSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        // Informații utilizator
                        userInfo.put("id", rs.getInt("id"));
                        userInfo.put("nume", rs.getString("nume"));
                        userInfo.put("prenume", rs.getString("prenume"));
                        userInfo.put("id_dep", rs.getInt("id_dep"));
                        userInfo.put("nume_dep", rs.getString("nume_dep"));
                        userInfo.put("id_sediu", rs.getInt("id_sediu"));
                        
                        // Informații sediu
                        sediuLocation.put("id_sediu", rs.getInt("id_sediu"));
                        sediuLocation.put("nume_sediu", rs.getString("nume_sediu"));
                        sediuLocation.put("tip_sediu", rs.getString("tip_sediu"));
                        sediuLocation.put("strada", rs.getString("sediu_strada"));
                        sediuLocation.put("oras", rs.getString("sediu_oras"));
                        sediuLocation.put("judet", rs.getString("sediu_judet"));
                        sediuLocation.put("tara", rs.getString("sediu_tara"));
                        sediuLocation.put("latitudine", rs.getDouble("sediu_lat"));
                        sediuLocation.put("longitudine", rs.getDouble("sediu_long"));
                        
                        // Construim adresa completă a sediului
                        String adresaCompletaSediu = rs.getString("sediu_strada") + ", " + 
                                                    rs.getString("sediu_oras") + ", " + 
                                                    rs.getString("sediu_judet") + ", " + 
                                                    rs.getString("sediu_tara");
                        sediuLocation.put("adresa_completa", adresaCompletaSediu);
                    } else {
                        throw new SQLException("Utilizatorul cu ID-ul " + userId + " nu a fost găsit sau nu are un sediu asociat.");
                    }
                }
            }
            
            result.put("user_info", userInfo);
            result.put("sediu_location", sediuLocation);
            
            // Obținem informațiile concediului
            String concediuSql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                                 "s.nume_status FROM concedii c " +
                                 "JOIN statusuri s ON c.status = s.status " +
                                 "JOIN tipcon tc ON c.tip = tc.tip " +
                                 "WHERE c.id = ? AND c.id_ang = ?";
            
            Map<String, Object> concediuInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuSql)) {
                stmt.setInt(1, concediuId);
                stmt.setInt(2, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        concediuInfo.put("id", rs.getInt("id"));
                        concediuInfo.put("start_c", rs.getDate("start_c").toString());
                        concediuInfo.put("end_c", rs.getDate("end_c").toString());
                        concediuInfo.put("motiv", rs.getString("motiv"));
                        concediuInfo.put("locatie", rs.getString("locatie"));
                        concediuInfo.put("tip_concediu", rs.getString("tip_concediu"));
                        concediuInfo.put("nume_status", rs.getString("nume_status"));
                    } else {
                        throw new SQLException("Concediul cu ID-ul " + concediuId + " pentru utilizatorul " + userId + " nu a fost găsit.");
                    }
                }
            }
            
            result.put("concediu_info", concediuInfo);
            
            // Obținem locația concediului
            String concediuLocationSql = "SELECT lc.id_concediu, lc.strada, lc.longitudine, lc.latitudine, lc.cod, " +
                                        "lc.oras, lc.judet, lc.tara " +
                                        "FROM locatii_concedii lc " +
                                        "WHERE lc.id_concediu = ? AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL";
            
            Map<String, Object> concediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuLocationSql)) {
                stmt.setInt(1, concediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        concediuLocation.put("id_concediu", rs.getInt("id_concediu"));
                        concediuLocation.put("strada", rs.getString("strada"));
                        concediuLocation.put("longitudine", rs.getDouble("longitudine"));
                        concediuLocation.put("latitudine", rs.getDouble("latitudine"));
                        concediuLocation.put("cod", rs.getString("cod"));
                        concediuLocation.put("oras", rs.getString("oras"));
                        concediuLocation.put("judet", rs.getString("judet"));
                        concediuLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă a locației concediului
                        String adresaCompletaConcediu = rs.getString("strada") + ", " + 
                                                      rs.getString("oras") + ", " + 
                                                      rs.getString("judet") + ", " + 
                                                      rs.getString("tara");
                        concediuLocation.put("adresa_completa", adresaCompletaConcediu);
                        
                        // Calculăm distanța dintre sediu și locația concediului
                        double sediuLat = (double) sediuLocation.get("latitudine");
                        double sediuLon = (double) sediuLocation.get("longitudine");
                        double concediuLat = rs.getDouble("latitudine");
                        double concediuLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(sediuLat, sediuLon, concediuLat, concediuLon);
                        concediuLocation.put("distanta_km", distanta);
                    } else {
                        throw new SQLException("Nu s-a găsit locația pentru concediul cu ID-ul " + concediuId + " sau coordonatele lipsesc.");
                    }
                }
            }
            
            result.put("concediu_location", concediuLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + " și concediul " + concediuId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("Sediu location: " + sediuLocation);
            System.out.println("Concediu info: " + concediuInfo);
            System.out.println("Concediu location: " + concediuLocation);
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