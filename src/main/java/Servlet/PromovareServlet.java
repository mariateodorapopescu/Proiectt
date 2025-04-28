package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import jakarta.servlet.ServletException;  // SCHIMBĂ DIN javax.servlet
import jakarta.servlet.http.HttpServlet;  // SCHIMBĂ DIN javax.servlet
import jakarta.servlet.http.HttpServletRequest;  // SCHIMBĂ DIN javax.servlet
import jakarta.servlet.http.HttpServletResponse;  // SCHIMBĂ DIN javax.servlet
import jakarta.servlet.http.HttpSession;  // SCHIMBĂ DIN javax.servlet
import java.sql.Date;

public class PromovareServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String tipPromovare = request.getParameter("tip_promovare");
        String[] angajatiId = request.getParameterValues("angajat_id");
        
        if (angajatiId == null || angajatiId.length == 0) {
            response.sendRedirect("promovare.jsp?error=noSelection");
            return;
        }
        
        Connection conn = null;
        try {
            // Încărcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directă
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            for (String idStr : angajatiId) {
                int idAng = Integer.parseInt(idStr);
                int functieNoua = Integer.parseInt(request.getParameter("functie_noua_" + idStr));
                
                // Actualizare funcție angajat
                String sql = "UPDATE useri SET tip = ?, data_modif = CURDATE() WHERE id = ?";
                PreparedStatement pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, functieNoua);
                pstmt.setInt(2, idAng);
                pstmt.executeUpdate();
                
                // Înregistrare istoric promovare
                sql = "INSERT INTO istoric_promovari (id_ang, tip_vechi, tip_nou, tip_promovare, data_promovare) " +
                      "SELECT id, tip, ?, ?, CURDATE() FROM useri WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, functieNoua);
                pstmt.setString(2, tipPromovare);
                pstmt.setInt(3, idAng);
                pstmt.executeUpdate();
                
                pstmt.close();
            }
            
            conn.commit();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Promovare cu succes!');");
	        out.println("window.location.href = 'promovare.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut promova!');");
	        out.println("window.location.href = 'promovare.jsp?error=driverError';");
	        out.println("</script>");
	        out.close();
	        return; 
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut promova!');");
	        out.println("window.location.href = 'promovare.jsp?error=true';");
	        out.println("</script>");
	        out.close();
	        return; 
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}