package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class AdaugaPozitieServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String denumire = request.getParameter("denumire");
        int salariu = Integer.parseInt(request.getParameter("salariu"));
        int ierarhie = Integer.parseInt(request.getParameter("ierarhie"));
        int departamentSpecific = Integer.parseInt(request.getParameter("departament_specific"));
        String descriere = request.getParameter("descriere");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "INSERT INTO tipuri (denumire, salariu, ierarhie, departament_specific, descriere) " +
                        "VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, denumire);
            pstmt.setInt(2, salariu);
            pstmt.setInt(3, ierarhie);
            pstmt.setInt(4, departamentSpecific);
            pstmt.setString(5, descriere);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            response.sendRedirect("administrare_pozitii.jsp?success=true");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_pozitii.jsp?error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_pozitii.jsp?error=driverNotFound");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}