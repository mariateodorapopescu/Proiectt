package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.DriverManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Date;

public class IncetareContractServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int idAng = Integer.parseInt(request.getParameter("id_ang"));
        Date dataIncetare = Date.valueOf(request.getParameter("data_incetare"));
        String motivIncetare = request.getParameter("motiv_incetare");
        String observatii = request.getParameter("observatii");
        
        Connection conn = null;
        try {
            // Încărcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directă
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            conn.setAutoCommit(false);
            
            // Dezactivare angajat
            String sql = "UPDATE useri SET activ = 0 WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idAng);
            pstmt.executeUpdate();
            
            // Înregistrare istoric încetare contract
            sql = "INSERT INTO istoric_incetari (id_ang, data_incetare, motiv, observatii) " +
                  "VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idAng);
            pstmt.setDate(2, dataIncetare);
            pstmt.setString(3, motivIncetare);
            pstmt.setString(4, observatii);
            pstmt.executeUpdate();
            
            conn.commit();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('OK');");
	        out.println("window.location.href = 'incetare_contract.jsp?';");
	        out.println("</script>");
	        out.close();
	        return; 
            
            // pstmt.close();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('FAILED');");
	        out.println("window.location.href = 'incetare_contract.jsp?error=true';");
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
	        out.println("alert('FAILED');");
	        out.println("window.location.href = 'incetare_contract.jsp?error=true';");
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