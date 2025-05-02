package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class DeleteProiectServlet extends HttpServlet {
    // Database connection constants
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
//        HttpSession session = request.getSession();
//        Integer userTip = (Integer) session.getAttribute("userTip");
//
//        // Verificare permisiuni
//        if (userTip == null || (userTip != 0 && userTip != 3 && userTip != 10)) {
//            response.setContentType("application/json");
//            response.setCharacterEncoding("UTF-8");
//            response.getWriter().write("{\"success\": false, \"message\": \"Nu aveți permisiunile necesare.\"}");
//            return;
//        }

        int idProiect = Integer.parseInt(request.getParameter("id"));
        getServletContext().log("Început procesul de ștergere pentru proiectul ID: " + idProiect);

        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Disable auto-commit for transaction
            conn.setAutoCommit(false);
            getServletContext().log("Conexiune stabilită și autocommit dezactivat");

            // 1. Actualizează membrii echipelor pentru a elimina relația cu echipele din acest proiect
            String sqlUpdateMembri = 
                "UPDATE useri SET id_echipa = NULL " +
                "WHERE id_echipa IN (SELECT id FROM echipe WHERE id_prj = ?)";
                
            try (PreparedStatement pstmtUpdateMembri = conn.prepareStatement(sqlUpdateMembri)) {
                pstmtUpdateMembri.setInt(1, idProiect);
                int affectedMembers = pstmtUpdateMembri.executeUpdate();
                getServletContext().log("Membrii echipelor actualizați: " + affectedMembers);
            }

            // 2. Șterge echipele asociate proiectului
            String sqlDeleteEchipe = "DELETE FROM echipe WHERE id_prj = ?";
            try (PreparedStatement pstmtDeleteEchipe = conn.prepareStatement(sqlDeleteEchipe)) {
                pstmtDeleteEchipe.setInt(1, idProiect);
                int affectedTeams = pstmtDeleteEchipe.executeUpdate();
                getServletContext().log("Echipe șterse: " + affectedTeams);
            }

            // 3. Șterge task-urile asociate proiectului (dacă există)
            String sqlDeleteTasks = "DELETE FROM tasks WHERE id_prj = ?";
            try {
                PreparedStatement pstmtDeleteTasks = conn.prepareStatement(sqlDeleteTasks);
                pstmtDeleteTasks.setInt(1, idProiect);
                int affectedTasks = pstmtDeleteTasks.executeUpdate();
                pstmtDeleteTasks.close();
                getServletContext().log("Task-uri șterse: " + affectedTasks);
            } catch (SQLException e) {
                // Ignorăm eroarea dacă tabela nu există
                getServletContext().log("Info: tabela tasks probabil nu există: " + e.getMessage());
            }

            // 4. În final, șterge proiectul
            String sqlDeleteProiect = "DELETE FROM proiecte WHERE id = ?";
            try (PreparedStatement pstmtDeleteProiect = conn.prepareStatement(sqlDeleteProiect)) {
                pstmtDeleteProiect.setInt(1, idProiect);
                int rowsAffected = pstmtDeleteProiect.executeUpdate();
                
                if (rowsAffected > 0) {
                    conn.commit();
                    getServletContext().log("Tranzacția a fost confirmată, proiectul a fost șters cu succes");
                    
                    // Returnează un răspuns JSON de succes
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\": true, \"message\": \"Proiectul a fost șters cu succes.\"}");
                } else {
                    conn.rollback();
                    getServletContext().log("Proiectul nu a fost găsit, tranzacția a fost anulată");
                    
                    // Returnează un răspuns JSON de eroare
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\": false, \"message\": \"Nu s-a putut șterge proiectul. Proiectul nu a fost găsit.\"}");
                }
            }
        } catch (ClassNotFoundException e) {
            // Log the error
            getServletContext().log("JDBC Driver not found", e);
            
            // Rollback transaction if needed
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                getServletContext().log("Error during rollback", ex);
            }
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare la încărcarea driver-ului JDBC.\"}");
        } catch (SQLException e) {
            // Log the error
            getServletContext().log("Database error", e);
            
            // Rollback transaction
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                getServletContext().log("Error during rollback", ex);
            }
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare la baza de date: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            // Log the error
            getServletContext().log("Unexpected error", e);
            
            // Rollback transaction
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                getServletContext().log("Error during rollback", ex);
            }
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare neașteptată: " + e.getMessage() + "\"}");
        } finally {
            // Reset auto-commit and close connection
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                    getServletContext().log("Conexiune închisă");
                } catch (SQLException e) {
                    getServletContext().log("Error closing connection", e);
                }
            }
        }
    }
}