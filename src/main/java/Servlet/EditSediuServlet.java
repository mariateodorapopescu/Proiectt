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

public class EditSediuServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int idSediu = Integer.parseInt(request.getParameter("id_sediu"));
        String numeSediu = request.getParameter("nume_sediu");
        String tipSediu = request.getParameter("tip_sediu");
        
        String telefon = request.getParameter("telefon");
        String email = request.getParameter("email");
        
        Connection conn = null;
        try {
            // Utilizare DriverManager în locul DBConn
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            String sql = "UPDATE sedii SET nume_sediu = ?, tip_sediu = ?, " +
                        " telefon = ?, email = ? " +
                        " WHERE id_sediu = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, numeSediu);
            pstmt.setString(2, tipSediu);
           
            pstmt.setString(3, telefon);
            pstmt.setString(4, email);
            
            pstmt.setInt(12, idSediu);
            
            pstmt.executeUpdate();
            pstmt.close();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Editare sediu cu succes!');");
	        out.println("window.location.href = 'administrare_sedii.jsp?success=true';");
	        out.println("</script>");
	        out.close();
	        return;            
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
	        PrintWriter out = response.getWriter();
	        out.println("<script type='text/javascript'>");
	        out.println("alert('Nu s-a putut edita sediul!');");
	        out.println("window.location.href = 'administrare_sedii.jsp?error=true';");
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