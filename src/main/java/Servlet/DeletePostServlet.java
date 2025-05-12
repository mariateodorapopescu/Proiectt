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
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

public class DeletePostServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
        int idPost = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            
            // Începem o tranzacție pentru a asigura consistența
            conn.setAutoCommit(false);
            
            // Verifică dacă există aplicări pentru acest post
            String checkAplicari = "SELECT COUNT(*) as count FROM aplicari WHERE job_id = ?";
            PreparedStatement pstmtCheck = conn.prepareStatement(checkAplicari);
            pstmtCheck.setInt(1, idPost);
            ResultSet rsCheck = pstmtCheck.executeQuery();
            
            if (rsCheck.next() && rsCheck.getInt("count") > 0) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge un post care are aplicări!");
                rsCheck.close();
                pstmtCheck.close();
                out.print(json.toString());
                return;
            }
            rsCheck.close();
            pstmtCheck.close();
            
            // Obținem ID-ul locației asociate postului
            String getLocatie = "SELECT id_locatie FROM joburi WHERE id = ?";
            PreparedStatement pstmtLoc = conn.prepareStatement(getLocatie);
            pstmtLoc.setInt(1, idPost);
            ResultSet rsLoc = pstmtLoc.executeQuery();
            
            Integer idLocatie = null;
            if (rsLoc.next()) {
                idLocatie = rsLoc.getInt("id_locatie");
            }
            rsLoc.close();
            pstmtLoc.close();
            
            // Șterge postul
            String sqlDeleteJob = "DELETE FROM joburi WHERE id = ?";
            PreparedStatement pstmtJob = conn.prepareStatement(sqlDeleteJob);
            pstmtJob.setInt(1, idPost);
            
            int rowsAffected = pstmtJob.executeUpdate();
            pstmtJob.close();
            
            if (rowsAffected > 0) {
                // Șterge locația asociată, dacă există și dacă nu mai este folosită de alte posturi
                if (idLocatie != null) {
                    // Verifică dacă locația mai este folosită de alte posturi
                    String checkLocation = "SELECT COUNT(*) as count FROM joburi WHERE id_locatie = ?";
                    PreparedStatement pstmtCheckLoc = conn.prepareStatement(checkLocation);
                    pstmtCheckLoc.setInt(1, idLocatie);
                    ResultSet rsCheckLoc = pstmtCheckLoc.executeQuery();
                    
                    if (rsCheckLoc.next() && rsCheckLoc.getInt("count") == 0) {
                        // Locația nu mai este folosită, o ștergem
                        String sqlDeleteLoc = "DELETE FROM locatii_joburi WHERE id_locatie = ?";
                        PreparedStatement pstmtDeleteLoc = conn.prepareStatement(sqlDeleteLoc);
                        pstmtDeleteLoc.setInt(1, idLocatie);
                        pstmtDeleteLoc.executeUpdate();
                        pstmtDeleteLoc.close();
                    }
                    rsCheckLoc.close();
                    pstmtCheckLoc.close();
                }
                
                json.put("success", true);
                json.put("message", "Postul a fost șters cu succes!");
            } else {
                json.put("success", false);
                json.put("message", "Postul nu a fost găsit!");
            }
            
            // Confirmăm tranzacția
            conn.commit();
            
        } catch (SQLException e) {
            // Rollback în caz de eroare
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la ștergerea postului!");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la încărcarea driverului JDBC!");
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { 
                    e.printStackTrace(); 
                }
            }
        }
        
        out.print(json.toString());
        out.flush();
    }
}