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
import java.time.LocalDate;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Servlet pentru obținerea următorului concediu programat pentru un utilizator
 */
public class GetNextConcediuServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Datele de conectare la baza de date
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    public GetNextConcediuServlet() {
        super();
    }
    
    /**
     * Răspunde la cereri GET pentru a returna următorul concediu al unui utilizator
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
            Map<String, Object> nextConcediu = getNextConcediu(userId);
            
            // Verificăm dacă am găsit un concediu
            if (nextConcediu.isEmpty()) {
                // Returnăm un obiect gol, nu null
                out.print("{}");
                return;
            }
            
            // Convertim concediul în JSON și îl trimitem ca răspuns
            ObjectMapper objectMapper = new ObjectMapper();
            out.print(objectMapper.writeValueAsString(nextConcediu));
            
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
    
    /**
     * Obține următorul concediu programat pentru un utilizator din baza de date
     */
    private Map<String, Object> getNextConcediu(int userId) throws SQLException, ClassNotFoundException {
        Map<String, Object> concediu = new HashMap<>();
        
        // Data curentă în format SQL
        String currentDate = LocalDate.now().toString();
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Query pentru a obține următorul concediu al utilizatorului
        String sql = "SELECT c.id, c.start_c, c.end_c, c.motiv, c.locatie, tc.motiv as tip_concediu, " +
                     "s.nume_status as status, lc.latitudine, lc.longitudine, " +
                     "CONCAT(IFNULL(lc.strada, ''), ', ', IFNULL(lc.oras, ''), ', ', IFNULL(lc.judet, ''), ', ', IFNULL(lc.tara, '')) as adresa_completa " +
                     "FROM concedii c " +
                     "JOIN tipcon tc ON c.tip = tc.tip " +
                     "JOIN statusuri s ON c.status = s.status " +
                     "LEFT JOIN locatii_concedii lc ON c.id = lc.id_concediu " +
                     "WHERE c.id_ang = ? " +
                     "AND c.start_c >= ? " +   // Doar concedii viitoare sau care încep astăzi
                     "AND (c.status = 1 OR c.status = 2) " +  // Doar concedii aprobate de șef sau director
                     "ORDER BY c.start_c ASC " +  // Cel mai apropiat concediu
                     "LIMIT 1";                  // Doar primul rezultat
        
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, currentDate);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    concediu.put("id", rs.getInt("id"));
                    concediu.put("start_c", rs.getString("start_c"));
                    concediu.put("end_c", rs.getString("end_c"));
                    concediu.put("motiv", rs.getString("motiv"));
                    concediu.put("locatie", rs.getString("locatie"));
                    concediu.put("tip", rs.getString("tip_concediu"));
                    concediu.put("status", rs.getString("status"));
                    
                    // Adăugăm coordonatele geografice dacă există
                    try {
                        double lat = rs.getDouble("latitudine");
                        double lon = rs.getDouble("longitudine");
                        
                        if (!rs.wasNull() && lat != 0 && lon != 0) {
                            concediu.put("latitudine", lat);
                            concediu.put("longitudine", lon);
                            
                            // Verificăm dacă adresa are conținut real, nu doar virgule
                            String adresaCompleta = rs.getString("adresa_completa");
                            if (adresaCompleta != null && !adresaCompleta.replaceAll("[,\\s]+", "").isEmpty()) {
                                concediu.put("adresa_completa", adresaCompleta);
                            } else if (rs.getString("locatie") != null && !rs.getString("locatie").isEmpty()) {
                                // Folosim locația ca adresă de rezervă
                                concediu.put("adresa_completa", rs.getString("locatie"));
                            }
                        }
                    } catch (SQLException e) {
                        // Gestionăm cazul în care coordonatele nu sunt valide
                        System.out.println("Avertisment: Coordonate invalide pentru concediul cu ID " + rs.getInt("id"));
                    }
                    
                    // Verificăm campurile null și le înlocuim cu valori implicite
                    for (String key : concediu.keySet()) {
                        if (concediu.get(key) == null) {
                            if (key.equals("locatie") || key.equals("adresa_completa")) {
                                concediu.put(key, "Nedefinită");
                            } else if (key.equals("motiv") || key.equals("tip") || key.equals("status")) {
                                concediu.put(key, "Nedefinit");
                            }
                        }
                    }
                }
                // Dacă nu există un concediu viitor, întoarcem un Map gol
            }
        }
        
        return concediu;
    }
}