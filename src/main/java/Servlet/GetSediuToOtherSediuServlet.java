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
 * Servlet pentru obținerea locațiilor sediului utilizatorului și sediului selectat
 */
public class GetSediuToOtherSediuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetSediuToOtherSediuServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile sediului utilizatorului și sediului selectat
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului și ID-ul sediului selectat din parametrii cererii
        String userIdStr = request.getParameter("userId");
        String selectedSediuIdStr = request.getParameter("selectedSediuId");
        
        if (userIdStr == null || userIdStr.isEmpty() || selectedSediuIdStr == null || selectedSediuIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID sediu lipsă\"}");
            return;
        }
        
        int userId, selectedSediuId;
        try {
            userId = Integer.parseInt(userIdStr);
            selectedSediuId = Integer.parseInt(selectedSediuIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID sediu invalid\"}");
            return;
        }
        
        try {
            // Obținem locațiile sediului utilizatorului și sediului selectat
            Map<String, Object> result = getUserAndSelectedSediuLocations(userId, selectedSediuId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_sediu_location") || !result.containsKey("selected_sediu_location")) {
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
     * Obține locațiile sediului utilizatorului și sediului selectat din baza de date
     */
    private Map<String, Object> getUserAndSelectedSediuLocations(int userId, int selectedSediuId) throws SQLException, ClassNotFoundException {
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
            
            // Obținem informațiile sediului selectat
            String selectedSediuSql = "SELECT id_sediu, nume_sediu, tip_sediu, strada, oras, judet, tara, " +
                                    "telefon, email, latitudine, longitudine " +
                                    "FROM sedii " +
                                    "WHERE id_sediu = ?";
            
            Map<String, Object> selectedSediuInfo = new HashMap<>();
            Map<String, Object> selectedSediuLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(selectedSediuSql)) {
                stmt.setInt(1, selectedSediuId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        // Informații sediu selectat
                        selectedSediuInfo.put("id_sediu", rs.getInt("id_sediu"));
                        selectedSediuInfo.put("nume_sediu", rs.getString("nume_sediu"));
                        selectedSediuInfo.put("tip_sediu", rs.getString("tip_sediu"));
                        selectedSediuInfo.put("telefon", rs.getString("telefon"));
                        selectedSediuInfo.put("email", rs.getString("email"));
                        
                        // Informații locație sediu selectat
                        selectedSediuLocation.put("id_sediu", rs.getInt("id_sediu"));
                        selectedSediuLocation.put("nume_sediu", rs.getString("nume_sediu"));
                        selectedSediuLocation.put("tip_sediu", rs.getString("tip_sediu"));
                        selectedSediuLocation.put("strada", rs.getString("strada"));
                        selectedSediuLocation.put("oras", rs.getString("oras"));
                        selectedSediuLocation.put("judet", rs.getString("judet"));
                        selectedSediuLocation.put("tara", rs.getString("tara"));
                        
                        // Verificăm dacă există coordonate pentru sediul selectat
                        if (rs.getObject("latitudine") != null && rs.getObject("longitudine") != null) {
                            selectedSediuLocation.put("latitudine", rs.getDouble("latitudine"));
                            selectedSediuLocation.put("longitudine", rs.getDouble("longitudine"));
                            
                            // Construim adresa completă a sediului selectat
                            String adresaCompletaSelectedSediu = rs.getString("strada") + ", " + 
                                                              rs.getString("oras") + ", " + 
                                                              rs.getString("judet") + ", " + 
                                                              rs.getString("tara");
                            selectedSediuLocation.put("adresa_completa", adresaCompletaSelectedSediu);
                            
                            // Calculăm distanța dintre sediul utilizatorului și sediul selectat
                            double userSediuLat = (double) userSediuLocation.get("latitudine");
                            double userSediuLon = (double) userSediuLocation.get("longitudine");
                            double selectedSediuLat = rs.getDouble("latitudine");
                            double selectedSediuLon = rs.getDouble("longitudine");
                            
                            double distanta = calculateDistance(userSediuLat, userSediuLon, selectedSediuLat, selectedSediuLon);
                            selectedSediuLocation.put("distanta_km", distanta);
                        } else {
                            throw new SQLException("Sediul selectat cu ID-ul " + selectedSediuId + " nu are coordonate geografice configurate.");
                        }
                    } else {
                        throw new SQLException("Sediul cu ID-ul " + selectedSediuId + " nu a fost găsit.");
                    }
                }
            }
            
            result.put("selected_sediu_info", selectedSediuInfo);
            result.put("selected_sediu_location", selectedSediuLocation);
            
            // Adăugăm un log pentru a verifica ce date au fost returnate
            System.out.println("Date returnate pentru utilizatorul " + userId + " și sediul " + selectedSediuId + ":");
            System.out.println("User info: " + userInfo);
            System.out.println("User sediu location: " + userSediuLocation);
            System.out.println("Selected sediu info: " + selectedSediuInfo);
            System.out.println("Selected sediu location: " + selectedSediuLocation);
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