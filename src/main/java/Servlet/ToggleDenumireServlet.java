package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import org.json.JSONObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class ToggleDenumireServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//        Integer userDep = (Integer) session.getAttribute("userDep");
//        
//        // Verificare permisiuni - doar Admin HR sau Director
//        if (userTip == null || (userTip != 0 && (userTip != 3 && userDep != 1))) {
//            json.put("success", false);
//            json.put("message", "Nu aveți permisiuni pentru această operațiune!");
//            out.print(json.toString());
//            return;
//        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        boolean currentStatus = Boolean.parseBoolean(request.getParameter("current_status"));
        boolean newStatus = !currentStatus;
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "UPDATE denumiri_pozitii SET activ = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setBoolean(1, newStatus);
            pstmt.setInt(2, id);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                json.put("success", true);
                json.put("message", "Statusul denumirii a fost actualizat cu succes!");
            } else {
                json.put("success", false);
                json.put("message", "Nu s-a putut actualiza statusul denumirii!");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la actualizarea statusului denumirii: " + e.getMessage());
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