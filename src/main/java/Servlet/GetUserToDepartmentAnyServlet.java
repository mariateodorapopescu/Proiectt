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
 * Servlet pentru obținerea locației utilizatorului și a departamentului selectat
 */
public class GetUserToDepartmentAnyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetUserToDepartmentAnyServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna locațiile utilizatorului și departamentului selectat
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Obținem ID-ul utilizatorului și ID-ul departamentului din parametrii cererii
        String userIdStr = request.getParameter("userId");
        String departmentIdStr = request.getParameter("departmentId");
        
        if (userIdStr == null || userIdStr.isEmpty() || departmentIdStr == null || departmentIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID departament lipsă\"}");
            return;
        }
        
        int userId, departmentId;
        try {
            userId = Integer.parseInt(userIdStr);
            departmentId = Integer.parseInt(departmentIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID utilizator sau ID departament invalid\"}");
            return;
        }
        
        try {
            // Obținem locațiile utilizatorului și departamentului
            Map<String, Object> result = getUserAndDepartmentLocations(userId, departmentId);
            
            // Verificăm dacă am găsit locațiile
            if (result.isEmpty() || !result.containsKey("user_location") || !result.containsKey("department_location")) {
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
     * Obține locațiile utilizatorului și departamentului din baza de date
     */
    private Map<String, Object> getUserAndDepartmentLocations(int userId, int departmentId) throws SQLException, ClassNotFoundException {
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
            
            // Obținem informațiile departamentului selectat
            String departmentSql = "SELECT id_dep, nume_dep FROM departament WHERE id_dep = ?";
            Map<String, Object> departmentInfo = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(departmentSql)) {
                stmt.setInt(1, departmentId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        departmentInfo.put("id_dep", rs.getInt("id_dep"));
                        departmentInfo.put("nume_dep", rs.getString("nume_dep"));
                    } else {
                        return result; // Departament negăsit
                    }
                }
            }
            
            result.put("department_info", departmentInfo);
            
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
            
            // Obținem locația departamentului selectat
            String depLocationSql = "SELECT id_dep, strada, longitudine, latitudine, cod, oras, judet, tara " +
                                   "FROM locatii_departamente " +
                                   "WHERE id_dep = ? AND latitudine IS NOT NULL AND longitudine IS NOT NULL";
            
            Map<String, Object> depLocation = new HashMap<>();
            
            try (PreparedStatement stmt = conn.prepareStatement(depLocationSql)) {
                stmt.setInt(1, departmentId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        depLocation.put("id_dep", rs.getInt("id_dep"));
                        depLocation.put("strada", rs.getString("strada"));
                        depLocation.put("longitudine", rs.getDouble("longitudine"));
                        depLocation.put("latitudine", rs.getDouble("latitudine"));
                        depLocation.put("cod", rs.getString("cod"));
                        depLocation.put("oras", rs.getString("oras"));
                        depLocation.put("judet", rs.getString("judet"));
                        depLocation.put("tara", rs.getString("tara"));
                        
                        // Construim adresa completă
                        String adresaCompleta = rs.getString("strada") + ", " + 
                                              rs.getString("oras") + ", " + 
                                              rs.getString("judet") + ", " + 
                                              rs.getString("tara");
                        depLocation.put("adresa_completa", adresaCompleta);
                        
                        // Calculăm distanța dintre locația utilizatorului și departament
                        double userLat = (double) userLocation.get("latitudine");
                        double userLon = (double) userLocation.get("longitudine");
                        double depLat = rs.getDouble("latitudine");
                        double depLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userLat, userLon, depLat, depLon);
                        depLocation.put("distanta_km", distanta);
                    } else {
                        return result; // Locație departament negăsită
                    }
                }
            }
            
            result.put("department_location", depLocation);
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