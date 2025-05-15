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
 * Servlet pentru obținerea locațiilor sediului utilizatorului și sediului departamentului
 */
public class GetSediuToDepServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToDepServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile sediului utilizatorului și sediului departamentului
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
            // Obținem locațiile sediului utilizatorului și sediului departamentului
            Map<String, Object> result = getUserAndDepartmentLocations(userId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_sediu_location") || !result.containsKey("dep_sediu_location")) {
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
     * Obține locațiile sediului utilizatorului și sediului departamentului din baza de date
     */
    private Map<String, Object> getUserAndDepartmentLocations(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului și departamentului său
            String userDepSql = "SELECT u.id, u.nume, u.prenume, u.id_dep, d.nume_dep, u.id_sediu, " +
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
            int departmentId = 0;
            
            try (PreparedStatement stmt = conn.prepareStatement(userDepSql)) {
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        // Informații utilizator
                        userInfo.put("id", rs.getInt("id"));
                        userInfo.put("nume", rs.getString("nume"));
                        userInfo.put("prenume", rs.getString("prenume"));
                        departmentId = rs.getInt("id_dep");
                        userInfo.put("id_dep", departmentId);
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
            
            // Obținem informațiile sediului departamentului
            // Mai întâi verificăm dacă există o locație a departamentului în locatii_departamente
            String depLocSql = "SELECT id_dep, strada, longitudine, latitudine, cod, oras, judet, tara " +
                              "FROM locatii_departamente " +
                              "WHERE id_dep = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> depSediuLocation = new HashMap<>();
            boolean hasDepLocation = false;
            
            try (PreparedStatement stmt = conn.prepareStatement(depLocSql)) {
                stmt.setInt(1, departmentId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        hasDepLocation = true;
                        
                        depSediuLocation.put("id_dep", rs.getInt("id_dep"));
                        depSediuLocation.put("strada", rs.getString("strada"));
                        depSediuLocation.put("longitudine", rs.getDouble("longitudine"));
                        depSediuLocation.put("latitudine", rs.getDouble("latitudine"));
                        depSediuLocation.put("cod", rs.getString("cod"));
                        depSediuLocation.put("oras", rs.getString("oras"));
                        depSediuLocation.put("judet", rs.getString("judet"));
                        depSediuLocation.put("tara", rs.getString("tara"));
                        depSediuLocation.put("nume_sediu", userInfo.get("nume_dep") + " - Sediu"); // Numele departamentului ca nume de sediu
                        
                        // Construim adresa completă a locației departamentului
                        String adresaCompletaDepLoc = rs.getString("strada") + ", " + 
                                                      rs.getString("oras") + ", " + 
                                                      rs.getString("judet") + ", " + 
                                                      rs.getString("tara");
                        depSediuLocation.put("adresa_completa", adresaCompletaDepLoc);
                        
                        // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                        double userSediuLat = (double) userSediuLocation.get("latitudine");
                        double userSediuLon = (double) userSediuLocation.get("longitudine");
                        double depLat = rs.getDouble("latitudine");
                        double depLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userSediuLat, userSediuLon, depLat, depLon);
                        depSediuLocation.put("distanta_km", distanta);
                    }
                }
            }
            
            // Dacă nu am găsit locația departamentului în locatii_departamente, căutăm prin alte sedii
            if (!hasDepLocation) {
                // Căutăm sedii care sunt asociate cu departamentul (printr-o regulă de denumire sau altă logică)
                // Exemplu: Căutăm sedii care includ numele departamentului în numele lor
                String depSediuSql = "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, " +
                                    "latitudine, longitudine " +
                                    "FROM sedii " +
                                    "WHERE (nume_sediu LIKE ? OR LOWER(nume_sediu) LIKE ?) " +
                                    "AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                                    "LIMIT 1";
                
                try (PreparedStatement stmt = conn.prepareStatement(depSediuSql)) {
                    String depName = (String) userInfo.get("nume_dep");
                    stmt.setString(1, "%" + depName + "%");
                    stmt.setString(2, "%" + depName.toLowerCase() + "%");
                    
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            depSediuLocation.put("id_sediu", rs.getInt("id_sediu"));
                            depSediuLocation.put("nume_sediu", rs.getString("nume_sediu"));
                            depSediuLocation.put("tip_sediu", rs.getString("tip_sediu"));
                            depSediuLocation.put("strada", rs.getString("strada"));
                            depSediuLocation.put("oras", rs.getString("oras"));
                            depSediuLocation.put("judet", rs.getString("judet"));
                            depSediuLocation.put("tara", rs.getString("tara"));
                            depSediuLocation.put("latitudine", rs.getDouble("latitudine"));
                            depSediuLocation.put("longitudine", rs.getDouble("longitudine"));
                            
                            // Construim adresa completă a sediului departamentului
                            String adresaCompletaDepSediu = rs.getString("strada") + ", " + 
                                                          rs.getString("oras") + ", " + 
                                                          rs.getString("judet") + ", " + 
                                                          rs.getString("tara");
                            depSediuLocation.put("adresa_completa", adresaCompletaDepSediu);
                            
                            // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                            double userSediuLat = (double) userSediuLocation.get("latitudine");
                            double userSediuLon = (double) userSediuLocation.get("longitudine");
                            double depSediuLat = rs.getDouble("latitudine");
                            double depSediuLon = rs.getDouble("longitudine");
                            
                            double distanta = calculateDistance(userSediuLat, userSediuLon, depSediuLat, depSediuLon);
                            depSediuLocation.put("distanta_km", distanta);
                            
                            hasDepLocation = true;
                        }
                    }
                }
                
                // Dacă tot nu am găsit, luăm un sediu principal sau alt sediu relevant
                if (!hasDepLocation) {
                    String fallbackSediuSql = "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, " +
                                             "latitudine, longitudine " +
                                             "FROM sedii " +
                                             "WHERE (tip_sediu = 'principal' OR id_sediu <> ?) " +
                                             "AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                                             "LIMIT 1";
                    
                    try (PreparedStatement stmt = conn.prepareStatement(fallbackSediuSql)) {
                        stmt.setInt(1, (int) userSediuLocation.get("id_sediu")); // Excludem sediul utilizatorului
                        
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                depSediuLocation.put("id_sediu", rs.getInt("id_sediu"));
                                depSediuLocation.put("nume_sediu", rs.getString("nume_sediu") + " (Sediu Departament)");
                                depSediuLocation.put("tip_sediu", rs.getString("tip_sediu"));
                                depSediuLocation.put("strada", rs.getString("strada"));
                                depSediuLocation.put("oras", rs.getString("oras"));
                                depSediuLocation.put("judet", rs.getString("judet"));
                                depSediuLocation.put("tara", rs.getString("tara"));
                                depSediuLocation.put("latitudine", rs.getDouble("latitudine"));
                                depSediuLocation.put("longitudine", rs.getDouble("longitudine"));
                                
                                // Construim adresa completă a sediului departamentului
                                String adresaCompletaDepSediu = rs.getString("strada") + ", " + 
                                                              rs.getString("oras") + ", " + 
                                                              rs.getString("judet") + ", " + 
                                                              rs.getString("tara");
                                depSediuLocation.put("adresa_completa", adresaCompletaDepSediu);
                                
                                // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                                double userSediuLat = (double) userSediuLocation.get("latitudine");
                                double userSediuLon = (double) userSediuLocation.get("longitudine");
                                double depSediuLat = rs.getDouble("latitudine");
                                double depSediuLon = rs.getDouble("longitudine");
                                
                                double distanta = calculateDistance(userSediuLat, userSediuLon, depSediuLat, depSediuLon);
                                depSediuLocation.put("distanta_km", distanta);
                                
                                hasDepLocation = true;
                            }
                        }
                    }
                }
            }
            
            if (!hasDepLocation) {
                throw new SQLException("Nu s-a găsit locația pentru departamentul cu ID-ul " + departmentId + ".");
            }
            
            result.put("dep_sediu_location", depSediuLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("User sediu location: " + userSediuLocation);
            System.out.println("Dep sediu location: " + depSediuLocation);
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