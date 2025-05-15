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
 * Servlet pentru obținerea locațiilor sediului și adresei de acasă a utilizatorului
 */
public class GetSediuToHomeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToHomeServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locația sediului și adresei de acasă a utilizatorului
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
            // Obținem locațiile sediului și adresei de acasă a utilizatorului
            Map<String, Object> result = getUserSediuAndHomeLocations(userId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_sediu_location") || !result.containsKey("user_home_location")) {
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
     * Obține locațiile sediului și adresei de acasă a utilizatorului din baza de date
     */
    private Map<String, Object> getUserSediuAndHomeLocations(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului și sediului său
            String userSediuSql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep, u.id_sediu, " +
                              "u.adresa as adresa_user, " +
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
                        userInfo.put("adresa", rs.getString("adresa_user"));
                        
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
            
            // Obținem adresa de acasă a utilizatorului din locatii_useri
            String userHomeSql = "SELECT id_locatie, id_user, strada, longitudine, latitudine, cod, oras, judet, tara " +
                                "FROM locatii_useri " +
                                "WHERE id_user = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> userHomeLocation = new HashMap<>();
            boolean foundHomeLocation = false;
            
            try (PreparedStatement stmt = conn.prepareStatement(userHomeSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        foundHomeLocation = true;
                        
                        userHomeLocation.put("id_locatie", rs.getInt("id_locatie"));
                        userHomeLocation.put("strada", rs.getString("strada"));
                        userHomeLocation.put("longitudine", rs.getDouble("longitudine"));
                        userHomeLocation.put("latitudine", rs.getDouble("latitudine"));
                        userHomeLocation.put("cod", rs.getString("cod"));
                        userHomeLocation.put("oras", rs.getString("oras"));
                        userHomeLocation.put("judet", rs.getString("judet"));
                        userHomeLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă a domiciliului utilizatorului
                        String adresaCompletaHome = rs.getString("strada") + ", " + 
                                                 rs.getString("oras") + ", " + 
                                                 rs.getString("judet") + ", " + 
                                                 rs.getString("tara");
                        userHomeLocation.put("adresa_completa", adresaCompletaHome);
                        
                        // Calculăm distanța dintre sediul utilizatorului și domiciliul său
                        double userSediuLat = (double) userSediuLocation.get("latitudine");
                        double userSediuLon = (double) userSediuLocation.get("longitudine");
                        double userHomeLat = rs.getDouble("latitudine");
                        double userHomeLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userSediuLat, userSediuLon, userHomeLat, userHomeLon);
                        userHomeLocation.put("distanta_km", distanta);
                    }
                }
            }
            
            // Dacă nu găsim locația de acasă în locatii_useri, folosim adresa din tabelul useri și
            // încercăm să obținem coordonatele dintr-o altă locație similară
            if (!foundHomeLocation) {
                // Extragem componentele adresei din adresa utilizatorului (dacă există)
                String adresaUser = (String) userInfo.get("adresa");
                
                if (adresaUser != null && !adresaUser.trim().isEmpty()) {
                    userHomeLocation.put("adresa", adresaUser);
                    
                    // Încercăm să găsim o locație similară în baza de date
                    String[] adresaParts = adresaUser.split("[,\\s]+");
                    
                    // Construim un query pentru a căuta locații cu componente similare în adresă
                    StringBuilder queryBuilder = new StringBuilder(
                        "SELECT strada, longitudine, latitudine, cod, oras, judet, tara " +
                        "FROM (" +
                        "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_concedii " +
                        "    UNION ALL " +
                        "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_departamente " +
                        "    UNION ALL " +
                        "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_useri " +
                        "    UNION ALL " +
                        "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM sedii " +
                        ") AS all_locations " +
                        "WHERE latitudine IS NOT NULL AND longitudine IS NOT NULL AND ("
                    );
                    
                    // Adăugăm condiții de căutare pentru fiecare componentă a adresei
                    boolean firstCondition = true;
                    for (String part : adresaParts) {
                        if (part.length() >= 3) { // Ignorăm cuvintele prea scurte
                            if (!firstCondition) {
                                queryBuilder.append(" OR ");
                            }
                            queryBuilder.append("strada LIKE ? OR oras LIKE ? OR judet LIKE ?");
                            firstCondition = false;
                        }
                    }
                    
                    queryBuilder.append(") LIMIT 1");
                    
                    try (PreparedStatement stmt = conn.prepareStatement(queryBuilder.toString())) {
                        // Setăm parametrii pentru query
                        int paramIndex = 1;
                        for (String part : adresaParts) {
                            if (part.length() >= 3) { // Ignorăm cuvintele prea scurte
                                stmt.setString(paramIndex++, "%" + part + "%");
                                stmt.setString(paramIndex++, "%" + part + "%");
                                stmt.setString(paramIndex++, "%" + part + "%");
                            }
                        }
                        
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                foundHomeLocation = true;
                                
                                userHomeLocation.put("strada", rs.getString("strada"));
                                userHomeLocation.put("longitudine", rs.getDouble("longitudine"));
                                userHomeLocation.put("latitudine", rs.getDouble("latitudine"));
                                userHomeLocation.put("cod", rs.getString("cod"));
                                userHomeLocation.put("oras", rs.getString("oras"));
                                userHomeLocation.put("judet", rs.getString("judet"));
                                userHomeLocation.put("tara", rs.getString("tara"));
                                
                                // Construim adresa completă aproximativă
                                String adresaCompletaAprox = rs.getString("strada") + ", " + 
                                                          rs.getString("oras") + ", " + 
                                                          rs.getString("judet") + ", " + 
                                                          rs.getString("tara");
                                userHomeLocation.put("adresa_completa", adresaCompletaAprox);
                                userHomeLocation.put("adresa_aproximativa", true);
                                
                                // Calculăm distanța între sediu și locația aproximativă
                                double userSediuLat = (double) userSediuLocation.get("latitudine");
                                double userSediuLon = (double) userSediuLocation.get("longitudine");
                                double userHomeLat = rs.getDouble("latitudine");
                                double userHomeLon = rs.getDouble("longitudine");
                                
                                double distanta = calculateDistance(userSediuLat, userSediuLon, userHomeLat, userHomeLon);
                                userHomeLocation.put("distanta_km", distanta);
                            }
                        }
                    }
                }
            }
            
            // Dacă tot nu am găsit o locație, folosim un punct din același oraș ca sediul
            if (!foundHomeLocation) {
                String fallbackLocationSql = 
                    "SELECT strada, longitudine, latitudine, cod, oras, judet, tara " +
                    "FROM (" +
                    "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_useri " +
                    "    UNION ALL " +
                    "    SELECT strada, longitudine, latitudine, cod, oras, judet, tara FROM locatii_concedii " +
                    ") AS all_locations " +
                    "WHERE oras = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                    "AND (latitudine <> ? OR longitudine <> ?) " +
                    "LIMIT 1";
                
                try (PreparedStatement stmt = conn.prepareStatement(fallbackLocationSql)) {
                    stmt.setString(1, (String) userSediuLocation.get("oras")); // Același oraș ca sediul
                    stmt.setDouble(2, (double) userSediuLocation.get("latitudine")); // Excludem sediul
                    stmt.setDouble(3, (double) userSediuLocation.get("longitudine"));
                    
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            foundHomeLocation = true;
                            
                            userHomeLocation.put("strada", rs.getString("strada"));
                            userHomeLocation.put("longitudine", rs.getDouble("longitudine"));
                            userHomeLocation.put("latitudine", rs.getDouble("latitudine"));
                            userHomeLocation.put("cod", rs.getString("cod"));
                            userHomeLocation.put("oras", rs.getString("oras"));
                            userHomeLocation.put("judet", rs.getString("judet"));
                            userHomeLocation.put("tara", rs.getString("tara"));
                            
                            // Construim adresa completă aproximativă
                            String adresaCompletaAprox = rs.getString("strada") + ", " + 
                                                      rs.getString("oras") + ", " + 
                                                      rs.getString("judet") + ", " + 
                                                      rs.getString("tara");
                            userHomeLocation.put("adresa_completa", adresaCompletaAprox);
                            userHomeLocation.put("adresa_aproximativa", true);
                            userHomeLocation.put("adresa_foarte_aproximativa", true); // Marcăm că este o aproximare foarte vagă
                            
                            // Calculăm distanța între sediu și locația aproximativă
                            double userSediuLat = (double) userSediuLocation.get("latitudine");
                            double userSediuLon = (double) userSediuLocation.get("longitudine");
                            double userHomeLat = rs.getDouble("latitudine");
                            double userHomeLon = rs.getDouble("longitudine");
                            
                            double distanta = calculateDistance(userSediuLat, userSediuLon, userHomeLat, userHomeLon);
                            userHomeLocation.put("distanta_km", distanta);
                        }
                    }
                }
            }
            
            if (!foundHomeLocation) {
                throw new SQLException("Nu s-a găsit adresa de acasă sau coordonatele acesteia pentru utilizatorul cu ID-ul " + userId + ".");
            }
            
            result.put("user_home_location", userHomeLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("User sediu location: " + userSediuLocation);
            System.out.println("User home location: " + userHomeLocation);
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