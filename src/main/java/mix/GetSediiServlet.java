package mix;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet pentru preluarea informațiilor despre sedii din baza de date
 */
public class GetSediiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // citim parametrii, dacă e cazul
        int userId = -1;
        String idParam = request.getParameter("id");
        if (idParam != null) {
            try {
                userId = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                // id invalid -> rămâne -1
            }
        }
        
        JSONArray sediiArray = new JSONArray();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(new JSONObject().put("error", "Driver JDBC MySQL nu a fost găsit").toString());
            return;
        }
        
        String url = "jdbc:mysql://localhost:3306/test?useSSL=false&serverTimezone=UTC";
        String user = "root";
        String pass = "student";
        
        String sql = "SELECT * FROM sedii ORDER BY tip_sediu, nume_sediu";
        
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
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
                sediiArray.put(sediu);
            }
            out.print(sediiArray.toString());
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "Eroare la Baza de date: " + e.getMessage());
            out.print(error.toString());
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
