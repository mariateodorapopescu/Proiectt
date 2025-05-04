package mix;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONObject;

public class GetSediuDetails extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Configurarea bazei de date
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Obține detaliile sediului pentru editare
        String idSediuStr = request.getParameter("id_sediu");
        
        if (idSediuStr == null || idSediuStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("ID-ul sediului lipsește");
            return;
        }
        
        try {
            int idSediu = Integer.parseInt(idSediuStr);
            
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                PreparedStatement stmt = conn.prepareStatement(
                    "SELECT * FROM sedii WHERE id_sediu = ?"
                );
                stmt.setInt(1, idSediu);
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    JSONObject jsonResponse = new JSONObject();
                    jsonResponse.put("id_sediu", rs.getInt("id_sediu"));
                    jsonResponse.put("nume_sediu", rs.getString("nume_sediu"));
                    jsonResponse.put("tip_sediu", rs.getString("tip_sediu"));
                    jsonResponse.put("strada", rs.getString("strada"));
                    jsonResponse.put("cod", rs.getString("cod"));
                    jsonResponse.put("oras", rs.getString("oras"));
                    jsonResponse.put("judet", rs.getString("judet"));
                    jsonResponse.put("tara", rs.getString("tara"));
                    jsonResponse.put("telefon", rs.getString("telefon"));
                    jsonResponse.put("email", rs.getString("email"));
                    jsonResponse.put("latitudine", rs.getDouble("latitudine"));
                    jsonResponse.put("longitudine", rs.getDouble("longitudine"));
                    
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write(jsonResponse.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("Sediul cu ID-ul specificat nu a fost găsit");
                }
                
                rs.close();
                stmt.close();
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("ID-ul sediului nu este valid");
        } catch (Exception e) {
            System.err.println("Eroare la obținerea detaliilor sediului: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Eroare la procesarea cererii: " + e.getMessage());
        }
    }
}