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

public class AdaugaDenumireServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int tipPozitie = Integer.parseInt(request.getParameter("tip_pozitie"));
        int idDep = Integer.parseInt(request.getParameter("id_dep"));
        String denumireCompleta = request.getParameter("denumire_completa");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "INSERT INTO denumiri_pozitii (tip_pozitie, id_dep, denumire_completa, activ) " +
                        "VALUES (?, ?, ?, 1)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, tipPozitie);
            pstmt.setInt(2, idDep);
            pstmt.setString(3, denumireCompleta);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            response.sendRedirect("administrare_pozitii.jsp?success=true");
            
        } catch (SQLException e) {
            if (e.getMessage().contains("Duplicate")) {
                response.sendRedirect("administrare_pozitii.jsp?error=duplicate");
            } else {
                e.printStackTrace();
                response.sendRedirect("administrare_pozitii.jsp?error=true");
            }
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