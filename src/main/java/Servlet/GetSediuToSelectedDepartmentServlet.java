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
 * Servlet pentru obținerea locațiilor sediului utilizatorului și sediului unui departament selectat
 */
public class GetSediuToSelectedDepartmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToSelectedDepartmentServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile sediului utilizatorului și sediului departamentului selectat
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului și ID-ul departamentului din parametrii cererii
        String userIdStr = request.getParameter("userId");
        String depIdStr = request.getParameter("depId");
        
        if (userIdStr == null || userIdStr.isEmpty() || depIdStr == null || depIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID departament lipsă\"}");
            return;
        }
        
        int userId, depId;
        try {
            userId = Integer.parseInt(userIdStr);
            depId = Integer.parseInt(depIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID departament invalid\"}");
            return;
        }
        
        try {
            // Obținem locațiile sediului utilizatorului și sediului departamentului
            Map<String, Object> result = getUserAndSelectedDepartmentLocations(userId, depId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_sediu_location") || !result.containsKey("selected_dep_location")) {
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
     * Obține locațiile sediului utilizatorului și sediului departamentului selectat din baza de date
     */
    private Map<String, Object> getUserAndSelectedDepartmentLocations(int userId, int depId) throws SQLException, ClassNotFoundException {
        Map<String, Object> result = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // Obținem informațiile utilizatorului și departamentului său
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
            
            // Obținem informațiile departamentului selectat
            String depSql = "SELECT id_dep, nume_dep FROM departament WHERE id_dep = ?";
            Map<String, Object> selectedDepInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(depSql)) {
                stmt.setInt(1, depId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        selectedDepInfo.put("id_dep", rs.getInt("id_dep"));
                        selectedDepInfo.put("nume_dep", rs.getString("nume_dep"));
                    } else {
                        throw new SQLException("Departamentul cu ID-ul " + depId + " nu a fost găsit.");
                    }
                }
            }
            
            result.put("selected_dep_info", selectedDepInfo);
            
            // Obținem locația departamentului selectat
            // Mai întâi verificăm dacă există o locație a departamentului în locatii_departamente
            String depLocSql = "SELECT id_dep, strada, longitudine, latitudine, cod, oras, judet, tara " +
                              "FROM locatii_departamente " +
                              "WHERE id_dep = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> selectedDepLocation = new HashMap<>();
            boolean hasDepLocation = false;
            
            try (PreparedStatement stmt = conn.prepareStatement(depLocSql)) {
                stmt.setInt(1, depId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        hasDepLocation = true;
                        
                        selectedDepLocation.put("id_dep", rs.getInt("id_dep"));
                        selectedDepLocation.put("strada", rs.getString("strada"));
                        selectedDepLocation.put("longitudine", rs.getDouble("longitudine"));
                        selectedDepLocation.put("latitudine", rs.getDouble("latitudine"));
                        selectedDepLocation.put("cod", rs.getString("cod"));
                        selectedDepLocation.put("oras", rs.getString("oras"));
                        selectedDepLocation.put("judet", rs.getString("judet"));
                        selectedDepLocation.put("tara", rs.getString("tara"));
                        selectedDepLocation.put("nume_sediu", selectedDepInfo.get("nume_dep") + " - Sediu"); // Numele departamentului ca nume de sediu
                        
                        // Construim adresa completă a locației departamentului
                        String adresaCompletaDepLoc = rs.getString("strada") + ", " + 
                                                      rs.getString("oras") + ", " + 
                                                      rs.getString("judet") + ", " + 
                                                      rs.getString("tara");
                        selectedDepLocation.put("adresa_completa", adresaCompletaDepLoc);
                        
                        // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                        double userSediuLat = (double) userSediuLocation.get("latitudine");
                        double userSediuLon = (double) userSediuLocation.get("longitudine");
                        double depLat = rs.getDouble("latitudine");
                        double depLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userSediuLat, userSediuLon, depLat, depLon);
                        selectedDepLocation.put("distanta_km", distanta);
                    }
                }
            }
            
            // Dacă nu am găsit locația departamentului în locatii_departamente, căutăm sedii asociate acestui departament
            if (!hasDepLocation) {
                // Căutăm sedii cu numele departamentului
                String depSediuSql = "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, " +
                                    "latitudine, longitudine " +
                                    "FROM sedii " +
                                    "WHERE (nume_sediu LIKE ? OR LOWER(nume_sediu) LIKE ?) " +
                                    "AND latitudine IS NOT NULL AND longitudine IS NOT NULL " +
                                    "LIMIT 1";
                
                try (PreparedStatement stmt = conn.prepareStatement(depSediuSql)) {
                    String depName = (String) selectedDepInfo.get("nume_dep");
                    stmt.setString(1, "%" + depName + "%");
                    stmt.setString(2, "%" + depName.toLowerCase() + "%");
                    
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            hasDepLocation = true;
                            
                            selectedDepLocation.put("id_sediu", rs.getInt("id_sediu"));
                            selectedDepLocation.put("nume_sediu", rs.getString("nume_sediu"));
                            selectedDepLocation.put("tip_sediu", rs.getString("tip_sediu"));
                            selectedDepLocation.put("strada", rs.getString("strada"));
                            selectedDepLocation.put("oras", rs.getString("oras"));
                            selectedDepLocation.put("judet", rs.getString("judet"));
                            selectedDepLocation.put("tara", rs.getString("tara"));
                            selectedDepLocation.put("latitudine", rs.getDouble("latitudine"));
                            selectedDepLocation.put("longitudine", rs.getDouble("longitudine"));
                            
                            // Construim adresa completă a sediului departamentului
                            String adresaCompletaDepSediu = rs.getString("strada") + ", " + 
                                                          rs.getString("oras") + ", " + 
                                                          rs.getString("judet") + ", " + 
                                                          rs.getString("tara");
                            selectedDepLocation.put("adresa_completa", adresaCompletaDepSediu);
                            
                            // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                            double userSediuLat = (double) userSediuLocation.get("latitudine");
                            double userSediuLon = (double) userSediuLocation.get("longitudine");
                            double depSediuLat = rs.getDouble("latitudine");
                            double depSediuLon = rs.getDouble("longitudine");
                            
                            double distanta = calculateDistance(userSediuLat, userSediuLon, depSediuLat, depSediuLon);
                            selectedDepLocation.put("distanta_km", distanta);
                        }
                    }
                }
                
                // Dacă nu am găsit sediu asociat departamentului, căutăm locații ale angajaților din acest departament
                if (!hasDepLocation) {
                    String depUsersSql = "SELECT lu.strada, lu.longitudine, lu.latitudine, lu.cod, lu.oras, lu.judet, lu.tara " +
                                      "FROM locatii_useri lu " +
                                      "JOIN useri u ON lu.id_user = u.id " +
                                      "WHERE u.id_dep = ? AND lu.latitudine IS NOT NULL AND lu.longitudine IS NOT NULL " +
                                      "LIMIT 1";
                    
                    try (PreparedStatement stmt = conn.prepareStatement(depUsersSql)) {
                        stmt.setInt(1, depId);
                        
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                hasDepLocation = true;
                                
                                selectedDepLocation.put("strada", rs.getString("strada"));
                                selectedDepLocation.put("longitudine", rs.getDouble("longitudine"));
                                selectedDepLocation.put("latitudine", rs.getDouble("latitudine"));
                                selectedDepLocation.put("cod", rs.getString("cod"));
                                selectedDepLocation.put("oras", rs.getString("oras"));
                                selectedDepLocation.put("judet", rs.getString("judet"));
                                selectedDepLocation.put("tara", rs.getString("tara"));
                                selectedDepLocation.put("nume_sediu", selectedDepInfo.get("nume_dep") + " - Locație angajați");
                                
                                // Construim adresa completă a locației angajaților departamentului
                                String adresaCompletaDepUseri = rs.getString("strada") + ", " + 
                                                               rs.getString("oras") + ", " + 
                                                               rs.getString("judet") + ", " + 
                                                               rs.getString("tara");
                                selectedDepLocation.put("adresa_completa", adresaCompletaDepUseri);
                                
                                // Calculăm distanța dintre sediul utilizatorului și locația angajaților departamentului
                                double userSediuLat = (double) userSediuLocation.get("latitudine");
                                double userSediuLon = (double) userSediuLocation.get("longitudine");
                                double depUseriLat = rs.getDouble("latitudine");
                                double depUseriLon = rs.getDouble("longitudine");
                                
                                double distanta = calculateDistance(userSediuLat, userSediuLon, depUseriLat, depUseriLon);
                                selectedDepLocation.put("distanta_km", distanta);
                            }
                        }
                    }
                }
                
                // Dacă tot nu am găsit, folosim un sediu principal sau alt sediu relevant
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
                                hasDepLocation = true;
                                
                                selectedDepLocation.put("id_sediu", rs.getInt("id_sediu"));
                                selectedDepLocation.put("nume_sediu", rs.getString("nume_sediu") + " (" + selectedDepInfo.get("nume_dep") + ")");
                                selectedDepLocation.put("tip_sediu", rs.getString("tip_sediu"));
                                selectedDepLocation.put("strada", rs.getString("strada"));
                                selectedDepLocation.put("oras", rs.getString("oras"));
                                selectedDepLocation.put("judet", rs.getString("judet"));
                                selectedDepLocation.put("tara", rs.getString("tara"));
                                selectedDepLocation.put("latitudine", rs.getDouble("latitudine"));
                                selectedDepLocation.put("longitudine", rs.getDouble("longitudine"));
                                
                                // Construim adresa completă a sediului departamentului
                                String adresaCompletaFallbackSediu = rs.getString("strada") + ", " + 
                                                                   rs.getString("oras") + ", " + 
                                                                   rs.getString("judet") + ", " + 
                                                                   rs.getString("tara");
                                selectedDepLocation.put("adresa_completa", adresaCompletaFallbackSediu);
                                
                                // Calculăm distanța dintre sediul utilizatorului și sediul departamentului
                                double userSediuLat = (double) userSediuLocation.get("latitudine");
                                double userSediuLon = (double) userSediuLocation.get("longitudine");
                                double fallbackSediuLat = rs.getDouble("latitudine");
                                double fallbackSediuLon = rs.getDouble("longitudine");
                                
                                double distanta = calculateDistance(userSediuLat, userSediuLon, fallbackSediuLat, fallbackSediuLon);
                                selectedDepLocation.put("distanta_km", distanta);
                            }
                        }
                    }
                }
            }
            
            if (!hasDepLocation) {
                throw new SQLException("Nu s-a găsit locația pentru departamentul cu ID-ul " + depId + ".");
            }
            
            result.put("selected_dep_location", selectedDepLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + " și departamentul " + depId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("User sediu location: " + userSediuLocation);
            System.out.println("Selected dep info: " + selectedDepInfo);
            System.out.println("Selected dep location: " + selectedDepLocation);
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