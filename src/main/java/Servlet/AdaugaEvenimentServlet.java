package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;
import java.sql.Time;

public class AdaugaEvenimentServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userTip = (Integer) session.getAttribute("userTip");
        Integer userDep = (Integer) session.getAttribute("userDep");
        
        // Verificare permisiuni - doar HR
        if (userTip == null || (userTip != 3 && userTip != 1 && userDep != 1)) {
            response.sendRedirect("Access.jsp?error=accessDenied");
            return;
        }
        
        String nume = request.getParameter("nume");
        int tip = Integer.parseInt(request.getParameter("tip"));
        Date dataStart = Date.valueOf(request.getParameter("data_start"));
        Time oraStart = Time.valueOf(request.getParameter("ora_start") + ":00");
        int locuriMax = Integer.parseInt(request.getParameter("locuri_max"));
        String descriere = request.getParameter("descriere");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "INSERT INTO evenimente (nume, tip, data_start, ora_start, locuri_max, descriere) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nume);
            pstmt.setInt(2, tip);
            pstmt.setDate(3, dataStart);
            pstmt.setTime(4, oraStart);
            pstmt.setInt(5, locuriMax);
            pstmt.setString(6, descriere);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            response.sendRedirect("training_conferinte.jsp?success=true");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("training_conferinte.jsp?error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("training_conferinte.jsp?error=true");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}