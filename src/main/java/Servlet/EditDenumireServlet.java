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
import jakarta.servlet.http.HttpSession;

public class EditDenumireServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//        Integer userDep = (Integer) session.getAttribute("userDep");
//        
//        // Verificare permisiuni - doar Admin HR sau Director
//        if (userTip == null || (userTip != 0 && (userTip != 3 && userDep != 1))) {
//            response.sendRedirect("Access.jsp?error=accessDenied");
//            return;
//        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        int tipPozitie = Integer.parseInt(request.getParameter("tip_pozitie"));
        int idDep = Integer.parseInt(request.getParameter("id_dep"));
        String denumireCompleta = request.getParameter("denumire_completa");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "UPDATE denumiri_pozitii SET tip_pozitie = ?, id_dep = ?, denumire_completa = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, tipPozitie);
            pstmt.setInt(2, idDep);
            pstmt.setString(3, denumireCompleta);
            pstmt.setInt(4, id);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("administrare_pozitii.jsp?success=updated");
            
        } catch (SQLException e) {
            if (e.getMessage().contains("Duplicate")) {
                response.sendRedirect("administrare_pozitii.jsp?error=duplicate");
            } else {
                e.printStackTrace();
                response.sendRedirect("administrare_pozitii.jsp?error=updateFailed");
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