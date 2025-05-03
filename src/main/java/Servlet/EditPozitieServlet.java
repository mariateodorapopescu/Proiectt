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

public class EditPozitieServlet extends HttpServlet {
    
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
        
        int tipId = Integer.parseInt(request.getParameter("tip_id"));
        String denumire = request.getParameter("denumire");
        int salariu = Integer.parseInt(request.getParameter("salariu"));
        int ierarhie = Integer.parseInt(request.getParameter("ierarhie"));
        
        // Handling potentially null departament_specific parameter
        int departamentSpecific = 20; // Default to General department (20)
        String departamentSpecificParam = request.getParameter("departament_specific");
        if (departamentSpecificParam != null && !departamentSpecificParam.isEmpty()) {
            departamentSpecific = Integer.parseInt(departamentSpecificParam);
        }
        
        String descriere = request.getParameter("descriere");
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "UPDATE tipuri SET denumire = ?, salariu = ?, ierarhie = ?, departament_specific = ?, descriere = ? WHERE tip = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, denumire);
            pstmt.setInt(2, salariu);
            pstmt.setInt(3, ierarhie);
            pstmt.setInt(4, departamentSpecific);
            pstmt.setString(5, descriere);
            pstmt.setInt(6, tipId);
            
            pstmt.executeUpdate();
            
            response.sendRedirect("administrare_pozitii.jsp?success=updated");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_pozitii.jsp?error=updateFailed");
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