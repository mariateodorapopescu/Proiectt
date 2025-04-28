package Servlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class AdaugaSediuServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String numeSediu = request.getParameter("nume_sediu");
        String tipSediu = request.getParameter("tip_sediu");
        String strada = request.getParameter("strada");
        String cod = request.getParameter("cod");
        String oras = request.getParameter("oras");
        String judet = request.getParameter("judet");
        String tara = request.getParameter("tara");
        String telefon = request.getParameter("telefon");
        String email = request.getParameter("email");
        
        Double latitudine = null;
        Double longitudine = null;
        try {
            if (request.getParameter("latitudine") != null && !request.getParameter("latitudine").isEmpty()) {
                latitudine = Double.parseDouble(request.getParameter("latitudine"));
            }
            if (request.getParameter("longitudine") != null && !request.getParameter("longitudine").isEmpty()) {
                longitudine = Double.parseDouble(request.getParameter("longitudine"));
            }
        } catch (NumberFormatException e) {
            // Ignore invalid coordinates
        }
        
        Connection conn = null;
        try {
            // Utilizare DriverManager în locul DBConn
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            String sql = "INSERT INTO sedii (nume_sediu, tip_sediu, strada, cod, oras, judet, tara, " +
                        "telefon, email, latitudine, longitudine) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, numeSediu);
            pstmt.setString(2, tipSediu);
            pstmt.setString(3, strada);
            pstmt.setString(4, cod);
            pstmt.setString(5, oras);
            pstmt.setString(6, judet);
            pstmt.setString(7, tara);
            pstmt.setString(8, telefon);
            pstmt.setString(9, email);
            
            if (latitudine != null) {
                pstmt.setDouble(10, latitudine);
            } else {
                pstmt.setNull(10, java.sql.Types.DOUBLE);
            }
            
            if (longitudine != null) {
                pstmt.setDouble(11, longitudine);
            } else {
                pstmt.setNull(11, java.sql.Types.DOUBLE);
            }
            
            pstmt.executeUpdate();
            pstmt.close();
            
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Adaugare sediu cu succes!');");
	        out.println("window.location.href = 'administrare_sedii.jsp?success=true';");
	        out.println("</script>");
	        out.close();
	        return;      
            
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut adauga sediul!');");
	        out.println("window.location.href = 'administrare_sedii.jsp?success=true';");
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