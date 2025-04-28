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

// @WebServlet("/PenalizariServlet")
public class PenalizariServlet extends HttpServlet {
	protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
	    doPost(request, response);
	}
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int idAng = Integer.parseInt(request.getParameter("id_ang"));
        int tipPenalizare = Integer.parseInt(request.getParameter("tip_penalizare"));
        Date dataStart = Date.valueOf(request.getParameter("data_start"));
        Date dataFinal = Date.valueOf(request.getParameter("data_final"));
        String motiv = request.getParameter("motiv");
        
        Connection conn = null;
        try {
            // Încărcare driver MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Creare conexiune directă
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Actualizare penalizări angajat
            String sql;
            PreparedStatement pstmt;
            
            // Verifică dacă tipPenalizare este 0 și setează valoarea NULL în coloana penalizari
            if (tipPenalizare == 0) {
                sql = "UPDATE useri SET penalizari = NULL WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idAng);
            } else {
                sql = "UPDATE useri SET penalizari = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, tipPenalizare);
                pstmt.setInt(2, idAng);
            }
            
            int result = pstmt.executeUpdate();
            
            if (result > 0) {
                // Înregistrare istoric penalizare
                sql = "INSERT INTO istoric_penalizari (id_ang, tip_penalizare, data_start, data_final, motiv) " +
                      "VALUES (?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, idAng);
                pstmt.setInt(2, tipPenalizare);
                pstmt.setDate(3, dataStart);
                pstmt.setDate(4, dataFinal);
                pstmt.setString(5, motiv);
                pstmt.executeUpdate();
                
                response.setContentType("text/html;charset=UTF-8");
    	        PrintWriter out = response.getWriter();
    	        out.println("<script type='text/javascript'>");
    	        if (tipPenalizare == 0) {
    	            out.println("alert('Penalizare eliminată cu succes!');");
    	        } else {
    	            out.println("alert('Penalizare acordată cu succes!');");
    	        }
    	        out.println("window.location.href = 'viewang.jsp';");
    	        out.println("</script>");
    	        out.close();
    	        return; 
            } else {
            	response.setContentType("text/html;charset=UTF-8");
    	        PrintWriter out = response.getWriter();
    	        out.println("<script type='text/javascript'>");
    	        if (tipPenalizare == 0) {
    	            out.println("alert('Nu s-a putut elimina penalizarea!');");
    	        } else {
    	            out.println("alert('Nu s-a putut adăuga penalizarea!');");
    	        }
    	        out.println("window.location.href = 'viewang.jsp';");
    	        out.println("</script>");
    	        out.close();
    	        return; 
            }
            
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut modifica penalizarea!');");
	        out.println("window.location.href = 'viewang.jsp';");
	        out.println("</script>");
	        out.close();
	        return; 
        } catch (SQLException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut modifica penalizarea!');");
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