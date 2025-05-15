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
 * Servlet pentru obținerea locației sediului utilizatorului și a celui mai apropiat concediu ca dată
 */
public class GetSediuToNextConcediuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToNextConcediuServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile sediului utilizatorului și următorului concediu
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
            // Obținem locațiile sediului utilizatorului și următorului concediu
            Map<String, Object> result = getUserSediuAndNextConcediuLocations(userId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_sediu_location") || !result.containsKey("next_concediu_location")) {
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
     * Obține locațiile sediului utilizatorului și a următorului concediu din baza de date
     */
    private Map<String, Object> getUserSediuAndNextConcediuLocations(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului și sediului său
            String userSediuSql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep, u.id_sediu, " +
                              "su.id_sediu as user_sediu_id, su.nume_sediu as user_sediu_nume, " +
                              "su.tip_sediu as user_sediu_tip, su.strada as user_sediu_strada, " +
                              "su.oras as user_sediu_oras, su.judet as user_sediu_judet, " +
                              "su.tara as user_sediu_tara, su.latitudine as user_sediu_lat, " +
                              "su.longitudine as user_sediu_long " +
                              "FROM useri u " +
                              "JOIN departament d ON u.id_dep = d.id_dep " +
                              "JOIN sedii su ON u.id_sediu = su.id_sediu " +
                              "WHERE u.id = ?";
            
            Map<String, Object> userInfo = new HashMap<>();
            Map<String, Object> userSediuLocation = new HashMap<>();
            
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
                        
                        // Informații sediu utilizator
                        userSediuLocation.put("id_sediu", rs.getInt("user_sediu_id"));
                        userSediuLocation.put("nume_sediu", rs.getString("user_sediu_nume"));
                        userSediuLocation.put("tip_sediu", rs.getString("user_sediu_tip"));
                        userSediuLocation.put("strada", rs.getString("user_sediu_strada"));
                        userSediuLocation.put("oras", rs.getString("user_sediu_oras"));
                        userSediuLocation.put("judet", rs.getString("user_sediu_judet"));
                        userSediuLocation.put("tara", rs.getString("user_sediu_tara"));
                        userSediuLocation.put("latitudine", rs.getDouble("user_sediu_lat"));
                        userSediuLocation.put("longitudine", rs.getDouble("user_sediu_long"));
                        
                        // Construim adresa completă a sediului utilizator
                        String adresaCompletaUserSediu = rs.getString("user_sediu_strada") + ", " + 
                                                    rs.getString("user_sediu_oras") + ", " + 
                                                    rs.getString("user_sediu_judet") + ", " + 
                                                    rs.getString("user_sediu_tara");
                        userSediuLocation.put("adresa_completa", adresaCompletaUserSediu);
                    } else {
                        throw new SQLException("Utilizatorul cu ID-ul " + userId + " nu a fost găsit sau nu are un sediu asociat.");
                    }
                }
            }
            
            result.put("user_info", userInfo);
            result.put("user_sediu_location", userSediuLocation);
            
            // Obținem informațiile despre următorul concediu al utilizatorului
            String nextConcediuSql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                                    "s.nume_status, c.status as status_id " +
                                    "FROM concedii c " +
                                    "JOIN statusuri s ON c.status = s.status " +
                                    "JOIN tipcon tc ON c.tip = tc.tip " +
                                    "WHERE c.id_ang = ? AND c.start_c >= CURDATE() AND c.status >= 0 " +
                                    "ORDER BY c.start_c ASC " +
                                    "LIMIT 1";
            
            Map<String, Object> nextConcediuInfo = new HashMap<>();
            int nextConcediuId = 0;
            
            try (PreparedStatement stmt = conn.prepareStatement(nextConcediuSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        nextConcediuId = rs.getInt("id");
                        nextConcediuInfo.put("id", nextConcediuId);
                        nextConcediuInfo.put("start_c", rs.getString("start_c"));
                        nextConcediuInfo.put("end_c", rs.getString("end_c"));
                        nextConcediuInfo.put("motiv", rs.getString("motiv"));
                        nextConcediuInfo.put("locatie", rs.getString("locatie"));
                        nextConcediuInfo.put("tip_concediu", rs.getString("tip_concediu"));
                        nextConcediuInfo.put("nume_status", rs.getString("nume_status"));
                        nextConcediuInfo.put("status_id", rs.getInt("status_id"));
                    } else {
                        // Dacă nu avem un concediu viitor, încercăm să luăm ultimul concediu din trecut
                        String lastConcediuSql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                                                "s.nume_status, c.status as status_id " +
                                                "FROM concedii c " +
                                                "JOIN statusuri s ON c.status = s.status " +
                                                "JOIN tipcon tc ON c.tip = tc.tip " +
                                                "WHERE c.id_ang = ? AND c.status >= 0 " +
                                                "ORDER BY c.start_c DESC " +
                                                "LIMIT 1";
                        
                        try (PreparedStatement stmt2 = conn.prepareStatement(lastConcediuSql)) {
                            stmt2.setInt(1, userId);
                            
                            try (ResultSet rs2 = stmt2.executeQuery()) {
                                if (rs2.next()) {
                                    nextConcediuId = rs2.getInt("id");
                                    nextConcediuInfo.put("id", nextConcediuId);
                                    nextConcediuInfo.put("start_c", rs2.getString("start_c"));
                                    nextConcediuInfo.put("end_c", rs2.getString("end_c"));
                                    nextConcediuInfo.put("motiv", rs2.getString("motiv"));
                                    nextConcediuInfo.put("locatie", rs2.getString("locatie"));
                                    nextConcediuInfo.put("tip_concediu", rs2.getString("tip_concediu"));
                                    nextConcediuInfo.put("nume_status", rs2.getString("nume_status"));
                                    nextConcediuInfo.put("status_id", rs2.getInt("status_id"));
                                    nextConcediuInfo.put("is_past", true); // Marcăm că este un concediu din trecut
                                } else {
                                    throw new SQLException("Nu s-a găsit niciun concediu pentru utilizatorul cu ID-ul " + userId + ".");
                                }
                            }
                        }
                    }
                }
            }
            
            result.put("next_concediu_info", nextConcediuInfo);
            
            // Obținem locația următorului concediu
            String concediuLocationSql = "SELECT lc.id_concediu, lc.strada, lc.longitudine, lc.latitudine, lc.cod, " +
                                        "lc.oras, lc.judet, lc.tara " +
                                        "FROM locatii_concedii lc " +
                                        "WHERE lc.id_concediu = ? AND lc.latitudine IS NOT NULL AND lc.longitudine IS NOT NULL";
            
            Map<String, Object> nextConcediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(concediuLocationSql)) {
                stmt.setInt(1, nextConcediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        nextConcediuLocation.put("id_concediu", rs.getInt("id_concediu"));
                        nextConcediuLocation.put("strada", rs.getString("strada"));
                        nextConcediuLocation.put("longitudine", rs.getDouble("longitudine"));
                        nextConcediuLocation.put("latitudine", rs.getDouble("latitudine"));
                        nextConcediuLocation.put("cod", rs.getString("cod"));
                        nextConcediuLocation.put("oras", rs.getString("oras"));
                        nextConcediuLocation.put("judet", rs.getString("judet"));
                        nextConcediuLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă a locației concediului
                        String adresaCompletaConcediu = rs.getString("strada") + ", " + 
                                                      rs.getString("oras") + ", " + 
                                                      rs.getString("judet") + ", " + 
                                                      rs.getString("tara");
                        nextConcediuLocation.put("adresa_completa", adresaCompletaConcediu);
                        
                        // Calculăm distanța dintre sediul utilizatorului și locația concediului
                        double userSediuLat = (double) userSediuLocation.get("latitudine");
                        double userSediuLon = (double) userSediuLocation.get("longitudine");
                        double concediuLat = rs.getDouble("latitudine");
                        double concediuLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userSediuLat, userSediuLon, concediuLat, concediuLon);
                        nextConcediuLocation.put("distanta_km", distanta);
                    } else {
                        // Dacă nu găsim locația concediului, înseamnă că nu are coordonate înregistrate
                        // Încercăm să găsim o locație apropiată de numele locației concediului
                        String locationName = (String) nextConcediuInfo.get("locatie");
                        
                        // Încercăm să căutăm în locatii_atractii dacă există o atracție turistică cu același nume sau în același oraș
                        String atractiiSql = "SELECT id_locatie, nume, strada, longitudine, latitudine, cod, oras, judet, tara " +
                                          "FROM locatii_atractii " +
                                          "WHERE nume LIKE ? OR oras LIKE ? " +
                                          "AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                                          "LIMIT 1";
                        
                        boolean foundLocation = false;
                        
                        try (PreparedStatement stmt2 = conn.prepareStatement(atractiiSql)) {
                            stmt2.setString(1, "%" + locationName + "%");
                            stmt2.setString(2, "%" + locationName + "%");
                            
                            try (ResultSet rs2 = stmt2.executeQuery()) {
                                if (rs2.next()) {
                                    foundLocation = true;
                                    
                                    nextConcediuLocation.put("nume", rs2.getString("nume"));
                                    nextConcediuLocation.put("strada", rs2.getString("strada"));
                                    nextConcediuLocation.put("longitudine", rs2.getDouble("longitudine"));
                                    nextConcediuLocation.put("latitudine", rs2.getDouble("latitudine"));
                                    nextConcediuLocation.put("cod", rs2.getString("cod"));
                                    nextConcediuLocation.put("oras", rs2.getString("oras"));
                                    nextConcediuLocation.put("judet", rs2.getString("judet"));
                                    nextConcediuLocation.put("tara", rs2.getString("tara"));
                                    
                                    // Construim adresa completă a locației concediului
                                    String adresaCompletaConcediu = rs2.getString("strada") + ", " + 
                                                                  rs2.getString("oras") + ", " + 
                                                                  rs2.getString("judet") + ", " + 
                                                                  rs2.getString("tara");
                                    nextConcediuLocation.put("adresa_completa", adresaCompletaConcediu);
                                    
                                    // Calculăm distanța dintre sediul utilizatorului și locația concediului
                                    double userSediuLat = (double) userSediuLocation.get("latitudine");
                                    double userSediuLon = (double) userSediuLocation.get("longitudine");
                                    double concediuLat = rs2.getDouble("latitudine");
                                    double concediuLon = rs2.getDouble("longitudine");
                                    
                                    double distanta = calculateDistance(userSediuLat, userSediuLon, concediuLat, concediuLon);
                                    nextConcediuLocation.put("distanta_km", distanta);
                                }
                            }
                        }
                        
                        // Dacă tot nu am găsit, căutăm coordonate pentru oraș în oricare altă locație
                        if (!foundLocation) {
                            String citySearchSql = "SELECT strada, longitudine, latitudine, cod, oras, judet, tara " +
                                               "FROM (" +
                                               "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_concedii " +
                                               "    UNION ALL " +
                                               "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_departamente " +
                                               "    UNION ALL " +
                                               "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_useri " +
                                               "    UNION ALL " +
                                               "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM sedii " +
                                               ") AS all_locations " +
                                               "WHERE (oras LIKE ? OR judet LIKE ? OR tara LIKE ?) " +
                                               "AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                                               "LIMIT 1";
                            
                            try (PreparedStatement stmt3 = conn.prepareStatement(citySearchSql)) {
                                stmt3.setString(1, "%" + locationName + "%");
                                stmt3.setString(2, "%" + locationName + "%");
                                stmt3.setString(3, "%" + locationName + "%");
                                
                                try (ResultSet rs3 = stmt3.executeQuery()) {
                                    if (rs3.next()) {
                                        foundLocation = true;
                                        
                                        nextConcediuLocation.put("strada", rs3.getString("strada"));
                                        nextConcediuLocation.put("longitudine", rs3.getDouble("longitudine"));
                                        nextConcediuLocation.put("latitudine", rs3.getDouble("latitudine"));
                                        nextConcediuLocation.put("cod", rs3.getString("cod"));
                                        nextConcediuLocation.put("oras", rs3.getString("oras"));
                                        nextConcediuLocation.put("judet", rs3.getString("judet"));
                                        nextConcediuLocation.put("tara", rs3.getString("tara"));
                                        
                                        // Construim adresa completă a locației concediului
                                        String adresaCompletaConcediu = rs3.getString("strada") + ", " + 
                                                                      rs3.getString("oras") + ", " + 
                                                                      rs3.getString("judet") + ", " + 
                                                                      rs3.getString("tara");
                                        nextConcediuLocation.put("adresa_completa", adresaCompletaConcediu);
                                        
                                        // Calculăm distanța dintre sediul utilizatorului și locația concediului
                                        double userSediuLat = (double) userSediuLocation.get("latitudine");
                                        double userSediuLon = (double) userSediuLocation.get("longitudine");
                                        double concediuLat = rs3.getDouble("latitudine");
                                        double concediuLon = rs3.getDouble("longitudine");
                                        
                                        double distanta = calculateDistance(userSediuLat, userSediuLon, concediuLat, concediuLon);
                                        nextConcediuLocation.put("distanta_km", distanta);
                                    }
                                }
                            }
                        }
                        
                        if (!foundLocation) {
                            throw new SQLException("Nu s-a găsit locația pentru concediul cu ID-ul " + nextConcediuId + " sau nu are coordonate configurate.");
                        }
                    }
                }
            }
            
            result.put("next_concediu_location", nextConcediuLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("User sediu location: " + userSediuLocation);
            System.out.println("Next concediu info: " + nextConcediuInfo);
            System.out.println("Next concediu location: " + nextConcediuLocation);
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