package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class GetPozitiiDepartamentServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        int idDep = Integer.parseInt(request.getParameter("id_dep"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            // Căutăm pozițiile care sunt potrivite pentru departamentul selectat
            String sql = "SELECT t.tip, COALESCE(dp.denumire_completa, t.denumire) as denumire_afisata " +
                        "FROM tipuri t " +
                        "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND dp.id_dep = ? " +
                        "WHERE t.departament_specific = ? OR t.departament_specific = 20 " +
                        "ORDER BY t.ierarhie, t.denumire";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idDep);
            pstmt.setInt(2, idDep);
            ResultSet rs = pstmt.executeQuery();
            
            out.println("<option value=''>-- Selectați --</option>");
            while (rs.next()) {
                out.println("<option value='" + rs.getInt("tip") + "'>" + 
                           rs.getString("denumire_afisata") + "</option>");
            }
            
            rs.close();
            pstmt.close();
            
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<option value=''>Eroare la încărcarea pozițiilor</option>");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            out.println("<option value=''>Eroare la încărcarea driverului JDBC</option>");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}