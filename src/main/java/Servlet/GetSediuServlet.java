package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

public class GetSediuServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        int idSediu = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        try {
            // Utilizare DriverManager în locul DBConn
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            String sql = "SELECT * FROM sedii WHERE id_sediu = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idSediu);
            
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                json.put("id_sediu", rs.getInt("id_sediu"));
                json.put("nume_sediu", rs.getString("nume_sediu"));
                json.put("tip_sediu", rs.getString("tip_sediu"));
                json.put("strada", rs.getString("strada"));
                json.put("cod", rs.getString("cod"));
                json.put("oras", rs.getString("oras"));
                json.put("judet", rs.getString("judet"));
                json.put("tara", rs.getString("tara"));
                json.put("telefon", rs.getString("telefon"));
                json.put("email", rs.getString("email"));
                json.put("latitudine", rs.getDouble("latitudine"));
                json.put("longitudine", rs.getDouble("longitudine"));
            } else {
                json.put("error", "Sediul nu a fost găsit!");
            }
            
            rs.close();
            pstmt.close();
            
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            json.put("error", "Eroare la obținerea datelor sediului: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
}