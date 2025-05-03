package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import org.json.JSONObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class DeletePozitieServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//        Integer userDep = (Integer) session.getAttribute("userDep");
//        
//        // Verificare permisiuni - doar Admin HR sau Director
//        if (userTip == null || (userTip != 0 && (userTip != 3 && userDep != 1))) {
//            json.put("success", false);
//            json.put("message", "Nu aveți permisiuni pentru această operațiune!");
//            out.print(json.toString());
//            return;
//        }
        
        int tipId = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);
            
            // Verifică dacă poziția este folosită de angajați
            String checkUsers = "SELECT COUNT(*) as count FROM useri WHERE tip = ?";
            PreparedStatement pstmtCheckUsers = conn.prepareStatement(checkUsers);
            pstmtCheckUsers.setInt(1, tipId);
            ResultSet rsUsers = pstmtCheckUsers.executeQuery();
            
            if (rsUsers.next() && rsUsers.getInt("count") > 0) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge această poziție deoarece este asociată unor angajați!");
                rsUsers.close();
                pstmtCheckUsers.close();
                out.print(json.toString());
                return;
            }
            
            // Verifică dacă poziția este folosită în istoricul promovărilor
            String checkHistory = "SELECT COUNT(*) as count FROM istoric_promovari WHERE tip_nou = ? OR tip_vechi = ?";
            PreparedStatement pstmtCheckHistory = conn.prepareStatement(checkHistory);
            pstmtCheckHistory.setInt(1, tipId);
            pstmtCheckHistory.setInt(2, tipId);
            ResultSet rsHistory = pstmtCheckHistory.executeQuery();
            
            if (rsHistory.next() && rsHistory.getInt("count") > 0) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge această poziție deoarece este folosită în istoricul angajaților!");
                rsHistory.close();
                pstmtCheckHistory.close();
                out.print(json.toString());
                return;
            }
            
            // Verifică dacă poziția este folosită în joburi
            String checkJobs = "SELECT COUNT(*) as count FROM joburi WHERE pozitie = ?";
            PreparedStatement pstmtCheckJobs = conn.prepareStatement(checkJobs);
            pstmtCheckJobs.setInt(1, tipId);
            ResultSet rsJobs = pstmtCheckJobs.executeQuery();
            
            if (rsJobs.next() && rsJobs.getInt("count") > 0) {
                json.put("success", false);
                json.put("message", "Nu se poate șterge această poziție deoarece este folosită în anunțuri de job!");
                rsJobs.close();
                pstmtCheckJobs.close();
                out.print(json.toString());
                return;
            }
            
            // Șterge denumirile specifice pentru această poziție
            String deleteDenumiri = "DELETE FROM denumiri_pozitii WHERE tip_pozitie = ?";
            PreparedStatement pstmtDeleteDenumiri = conn.prepareStatement(deleteDenumiri);
            pstmtDeleteDenumiri.setInt(1, tipId);
            pstmtDeleteDenumiri.executeUpdate();
            
            // Șterge poziția
            String deletePozitie = "DELETE FROM tipuri WHERE tip = ?";
            PreparedStatement pstmtDeletePozitie = conn.prepareStatement(deletePozitie);
            pstmtDeletePozitie.setInt(1, tipId);
            
            int rowsAffected = pstmtDeletePozitie.executeUpdate();
            
            if (rowsAffected > 0) {
                conn.commit();
                json.put("success", true);
                json.put("message", "Poziția a fost ștearsă cu succes!");
            } else {
                conn.rollback();
                json.put("success", false);
                json.put("message", "Nu s-a putut șterge poziția!");
            }
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la ștergerea poziției: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Eroare la încărcarea driverului JDBC!");
        } finally {
            if (conn != null) {
                try { 
                    conn.setAutoCommit(true);
                    conn.close(); 
                } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        
        out.print(json.toString());
    }
}