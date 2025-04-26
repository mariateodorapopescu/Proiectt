package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.sql.Date;

public class SporuriServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int idAng = Integer.parseInt(request.getParameter("id_ang"));
        int tipSpor = Integer.parseInt(request.getParameter("tip_spor"));
        Date dataStart = Date.valueOf(request.getParameter("data_start"));
        Date dataFinal = Date.valueOf(request.getParameter("data_final"));
        String motiv = request.getParameter("motiv");
        
        Connection conn = null;
        try {
            // Încărcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directă
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Actualizare sporuri angajat
            String sql = "UPDATE useri SET sporuri = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, tipSpor);
            pstmt.setInt(2, idAng);
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // Înregistrare istoric spor
                sql = "INSERT INTO istoric_sporuri (id_ang, tip_spor, data_start, data_final, motiv) " +
                      "VALUES (?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idAng);
                pstmt.setInt(2, tipSpor);
                pstmt.setDate(3, dataStart);
                pstmt.setDate(4, dataFinal);
                pstmt.setString(5, motiv);
                pstmt.executeUpdate();
                
                response.sendRedirect("sporuri.jsp?success=true");
            } else {
                response.sendRedirect("sporuri.jsp?error=true");
            }
            
            pstmt.close();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("sporuri.jsp?error=driverError");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("sporuri.jsp?error=true");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}