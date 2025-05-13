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
 * Servlet pentru obținerea listei de departamente și locațiile acestora
 */
public class GetDepartamenteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetDepartamenteServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna lista de departamente sau un departament specific
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Verificăm dacă s-a cerut un departament specific
        String depIdStr = request.getParameter("departamentId");
        
        try {
            if (depIdStr != null) {
                // Convertim ID-ul departamentului
                int depId = Integer.parseInt(depIdStr);
                
                // Obținem departamentul specificat
                Map<String, Object> departament = getDepartamentById(depId, request, response);
                
                // Verificăm dacă am găsit departamentul
                if (departament.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Departamentul nu a fost găsit sau nu are o locație definită.\"}");
                    return;
                }
                
                // Convertim departamentul în JSON și îl trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(departament));
            } else {
                // Obținem toate departamentele
                List<Map<String, Object>> departamente = getAllDepartamente();
                
                // Verificăm dacă am găsit departamente
                if (departamente.isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\": \"Nu s-au găsit departamente.\"}");
                    return;
                }
                
                // Convertim lista de departamente în JSON și o trimitem ca răspuns
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(departamente));
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"ID departament invalid.\"}");
            return;
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține toate departamentele și locațiile lor din baza de date
     */
    private List<Map<String, Object>> getAllDepartamente() throws SQLException, ClassNotFoundException {
        List<Map<String, Object>> departamente = new ArrayList<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Query pentru a obține toate departamentele cu locațiile lor
        String sql = "SELECT d.id_dep, d.nume_dep, ld.strada, ld.longitudine, ld.latitudine, " +
                     "ld.cod, ld.oras, ld.judet, ld.tara " +
                     "FROM departament d " +
                     "JOIN locatii_departamente ld ON d.id_dep = ld.id_dep " +
                     "WHERE ld.latitudine IS NOT NULL AND ld.longitudine IS NOT NULL " +
                     "ORDER BY d.nume_dep";
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> departament = new HashMap<>();
                departament.put("id_dep", rs.getInt("id_dep"));
                departament.put("nume_dep", rs.getString("nume_dep"));
                departament.put("strada", rs.getString("strada"));
                departament.put("cod", rs.getString("cod"));
                departament.put("oras", rs.getString("oras"));
                departament.put("judet", rs.getString("judet"));
                departament.put("tara", rs.getString("tara"));
                departament.put("latitudine", rs.getDouble("latitudine"));
                departament.put("longitudine", rs.getDouble("longitudine"));
                
                // Construim adresa completă
                String adresaCompleta = rs.getString("strada") + ", " + 
                                       rs.getString("oras") + ", " + 
                                       rs.getString("judet") + ", " + 
                                       rs.getString("tara");
                departament.put("adresa_completa", adresaCompleta);
                
                // Adăugăm departamentul în listă
                departamente.add(departament);
            }
        }
        
        return departamente;
    }
    
    /**
     * Obține un departament specific după ID
     */
    private Map<String, Object> getDepartamentById(int depId,HttpServletRequest request, HttpServletResponse response ) throws SQLException, ClassNotFoundException {
        Map<String, Object> departament = new HashMap<>();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Query pentru a obține departamentul specificat
        String sql = "SELECT d.id_dep, d.nume_dep, ld.strada, ld.longitudine, ld.latitudine, " +
                     "ld.cod, ld.oras, ld.judet, ld.tara " +
                     "FROM departament d " +
                     "JOIN locatii_departamente ld ON d.id_dep = ld.id_dep " +
                     "WHERE d.id_dep = ? AND ld.latitudine IS NOT NULL AND ld.longitudine IS NOT NULL";
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, depId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                departament.put("id_dep", rs.getInt("id_dep"));
                departament.put("nume_dep", rs.getString("nume_dep"));
                departament.put("strada", rs.getString("strada"));
                departament.put("cod", rs.getString("cod"));
                departament.put("oras", rs.getString("oras"));
                departament.put("judet", rs.getString("judet"));
                departament.put("tara", rs.getString("tara"));
                departament.put("latitudine", rs.getDouble("latitudine"));
                departament.put("longitudine", rs.getDouble("longitudine"));
                
                // Construim adresa completă
                String adresaCompleta = rs.getString("strada") + ", " + 
                                       rs.getString("oras") + ", " + 
                                       rs.getString("judet") + ", " + 
                                       rs.getString("tara");
                departament.put("adresa_completa", adresaCompleta);
                
                // Calculăm distanța dacă sunt furnizate coordonatele utilizatorului
                String latStr = request.getParameter("lat");
                String lonStr = request.getParameter("lon");
                if (latStr != null && lonStr != null) {
                    try {
                        double userLat = Double.parseDouble(latStr);
                        double userLon = Double.parseDouble(lonStr);
                        double depLat = rs.getDouble("latitudine");
                        double depLon = rs.getDouble("longitudine");
                        
                        double distanta = calculateDistance(userLat, userLon, depLat, depLon);
                        departament.put("distanta_km", distanta);
                    } catch (NumberFormatException e) {
                        // Ignorăm în cazul în care coordonatele nu sunt valide
                    }
                }
            }
        }
        
        return departament;
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