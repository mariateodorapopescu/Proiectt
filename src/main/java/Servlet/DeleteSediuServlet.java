package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

public class DeleteSediuServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        int idSediu = Integer.parseInt(request.getParameter("id_sediu"));
        
        Connection conn = null;
        try {
            // Utilizare DriverManager în locul DBConn
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Verifică dacă este sediul principal
            String checkPrincipal = "SELECT tip_sediu FROM sedii WHERE id_sediu = ?";
            PreparedStatement pstmtCheck = conn.prepareStatement(checkPrincipal);
            pstmtCheck.setInt(1, idSediu);
            ResultSet rsCheck = pstmtCheck.executeQuery();
            
            if (rsCheck.next() && "principal".equals(rsCheck.getString("tip_sediu"))) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge sediul principal!");
                rsCheck.close();
                pstmtCheck.close();
                out.print(json.toString());
                return;
            }
            rsCheck.close();
            pstmtCheck.close();
            
            // Verifică dacă sediul are angajați
            String checkAngajati = "SELECT COUNT(*) as count FROM locatii_useri " +
                                  "WHERE id_sediu = ?";
            PreparedStatement pstmtAngajati = conn.prepareStatement(checkAngajati);
            pstmtAngajati.setInt(1, idSediu);
            ResultSet rsAngajati = pstmtAngajati.executeQuery();
            
            if (rsAngajati.next() && rsAngajati.getInt("count") > 0) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge un sediu care are angajați!");
                rsAngajati.close();
                pstmtAngajati.close();
                out.print(json.toString());
                return;
            }
            rsAngajati.close();
            pstmtAngajati.close();
            
            // Șterge sediul
            String sql = "DELETE FROM sedii WHERE id_sediu = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idSediu);
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                json.put("success", true);
                json.put("message", "Sediul a fost șters cu succes!");
            } else {
                json.put("success", false);
                json.put("message", "Sediul nu a fost găsit!");
            }
            
            pstmt.close();
            
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la ștergerea sediului!");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
}