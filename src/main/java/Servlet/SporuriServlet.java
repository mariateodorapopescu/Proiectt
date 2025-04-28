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

// @WebServlet("/SporuriServlet")  // nu "/Project/SporuriServlet"
public class SporuriServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
	doPost(request, response);
	}
    
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
            String sql;
            PreparedStatement pstmt;
            
            // Verifică dacă tipSpor este 0 și setează valoarea NULL în coloana sporuri
            if (tipSpor == 0) {
                sql = "UPDATE useri SET sporuri = NULL WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idAng);
            } else {
                sql = "UPDATE useri SET sporuri = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, tipSpor);
                pstmt.setInt(2, idAng);
            }
            
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
                
                response.setContentType("text/html;charset=UTF-8");
    	        PrintWriter out = response.getWriter();
    	        out.println("<script type='text/javascript'>");
    	        if (tipSpor == 0) {
    	            out.println("alert('Spor eliminat cu succes!');");
    	        } else {
    	            out.println("alert('Acordare spor cu succes!');");
    	        }
    	        out.println("window.location.href = 'viewang.jsp';");
    	        out.println("</script>");
    	        out.close();
    	        return; 
            } else {
            	response.setContentType("text/html;charset=UTF-8");
    	        PrintWriter out = response.getWriter();
    	        out.println("<script type='text/javascript'>");
    	        if (tipSpor == 0) {
    	            out.println("alert('Nu s-a putut elimina sporul!');");
    	        } else {
    	            out.println("alert('Nu s-a putut adauga sporul!');");
    	        }
    	        out.println("window.location.href = 'viewang.jsp';");
    	        out.println("</script>");
    	        out.close();
    	        return; 
            }
            
            // pstmt.close();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut modifica sporul!');");
	        out.println("window.location.href = 'viewang.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut modifica sporul!');");
	        out.println("window.location.href = 'viewang.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
        } finally {
        	 
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}