package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import org.json.JSONObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class GetDenumireServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "SELECT * FROM denumiri_pozitii WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                json.put("success", true);
                json.put("id", rs.getInt("id"));
                json.put("tip_pozitie", rs.getInt("tip_pozitie"));
                json.put("id_dep", rs.getInt("id_dep"));
                json.put("denumire_completa", rs.getString("denumire_completa"));
                json.put("activ", rs.getBoolean("activ"));
            } else {
                json.put("success", false);
                json.put("message", "Denumirea nu a fost găsită!");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la obținerea datelor denumirii: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la încărcarea driverului JDBC!");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
    }
}