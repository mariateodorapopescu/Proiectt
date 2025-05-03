package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;

public class AdaugaTaskServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        
        int id = Integer.parseInt(request.getParameter("id"));
        String nume = request.getParameter("nume");
        String descriere = request.getParameter("descriere");
        int idProiect = Integer.parseInt(request.getParameter("id_prj"));
        int idAngajat = Integer.parseInt(request.getParameter("id_ang"));
        int supervizor = Integer.parseInt(request.getParameter("supervizor"));
        Date dataStart = Date.valueOf(request.getParameter("start"));
        Date dataEnd = Date.valueOf(request.getParameter("end"));
        int status = Integer.parseInt(request.getParameter("status"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "INSERT INTO tasks (id, nume, descriere, id_prj, id_ang, supervizor, start, end, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.setString(2, nume);
            pstmt.setString(3, descriere);
            pstmt.setInt(4, idProiect);
            pstmt.setInt(5, idAngajat);
            pstmt.setInt(6, supervizor);
            pstmt.setDate(7, dataStart);
            pstmt.setDate(8, dataEnd);
            pstmt.setInt(9, status);
            
            pstmt.executeUpdate();
            pstmt.close();
            
            response.sendRedirect("administrare_taskuri_simple.jsp?action=list&success=true");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_taskuri_simple.jsp?action=add&error=true");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("administrare_taskuri_simple.jsp?action=add&error=true");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}