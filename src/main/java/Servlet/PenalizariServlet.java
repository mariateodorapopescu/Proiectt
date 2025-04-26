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

public class PenalizariServlet extends HttpServlet {
    
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
            String sql = "UPDATE useri SET penalizari = ? WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, tipPenalizare);
            pstmt.setInt(2, idAng);
            
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
                
                response.sendRedirect("penalizari.jsp?success=true");
            } else {
                response.sendRedirect("penalizari.jsp?error=true");
            }
            
            pstmt.close();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("penalizari.jsp?error=driverError");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("penalizari.jsp?error=true");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}