package mix;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

public class GetAllSedii extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Configurarea bazei de date
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        JSONArray jsonArray = new JSONArray();
        
        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
            Statement stmt = conn.createStatement();
            String sql = "SELECT * FROM sedii ORDER BY nume_sediu";
            ResultSet rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                JSONObject sediu = new JSONObject();
                sediu.put("id_sediu", rs.getInt("id_sediu"));
                sediu.put("nume_sediu", rs.getString("nume_sediu"));
                sediu.put("tip_sediu", rs.getString("tip_sediu"));
                sediu.put("strada", rs.getString("strada"));
                sediu.put("cod", rs.getString("cod"));
                sediu.put("oras", rs.getString("oras"));
                sediu.put("judet", rs.getString("judet"));
                sediu.put("tara", rs.getString("tara"));
                sediu.put("telefon", rs.getString("telefon"));
                sediu.put("email", rs.getString("email"));
                sediu.put("latitudine", rs.getDouble("latitudine"));
                sediu.put("longitudine", rs.getDouble("longitudine"));
                
                jsonArray.put(sediu);
            }
            
            rs.close();
            stmt.close();
            
            // Setează răspunsul
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(jsonArray.toString());
            
        } catch (Exception e) {
            System.err.println("Eroare la obținerea tuturor sediilor: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}