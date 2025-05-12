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

public class DeleteEchipaServlet extends HttpServlet {
    // Database connection constants
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
      

        int idEchipa = Integer.parseInt(request.getParameter("id"));

        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Disable auto-commit for transaction
            conn.setAutoCommit(false);

            // Mai întâi ștergem relațiile cu membrii din tabela membrii_echipe
            String sqlDeleteMembri = "DELETE FROM membrii_echipe WHERE id_echipa = ?";
            try (PreparedStatement pstmtDeleteMembri = conn.prepareStatement(sqlDeleteMembri)) {
                pstmtDeleteMembri.setInt(1, idEchipa);
                pstmtDeleteMembri.executeUpdate();
                getServletContext().log("Membrii echipei " + idEchipa + " au fost șterși");
            }

            // Apoi ștergem echipa
            String sqlDeleteEchipa = "DELETE FROM echipe WHERE id = ?";
            try (PreparedStatement pstmtDeleteEchipa = conn.prepareStatement(sqlDeleteEchipa)) {
                pstmtDeleteEchipa.setInt(1, idEchipa);
                int rowsAffected = pstmtDeleteEchipa.executeUpdate();
                
                if (rowsAffected > 0) {
                    conn.commit();
                    getServletContext().log("Echipa " + idEchipa + " a fost ștearsă cu succes");
                    
                    // Returnează un răspuns JSON de succes
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\": true, \"message\": \"Echipa a fost ștearsă cu succes.\"}");
                } else {
                    conn.rollback();
                    getServletContext().log("Eroare la ștergerea echipei " + idEchipa + " - niciun rând afectat");
                    
                    // Returnează un răspuns JSON de eroare
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"success\": false, \"message\": \"Nu s-a putut șterge echipa.\"}");
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
                } catch (SQLException e) {
                    getServletContext().log("Error closing connection", e);
                }
            }
        }
    }
}