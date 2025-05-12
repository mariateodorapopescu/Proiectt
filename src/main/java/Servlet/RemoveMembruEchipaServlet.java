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

public class RemoveMembruEchipaServlet extends HttpServlet {
    // Database connection constants
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        int idMembru = Integer.parseInt(request.getParameter("id"));

        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection to delete the member from membrii_echipe
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                // Delete the record from membrii_echipe
                String sql = "DELETE FROM membrii_echipe WHERE id = ?";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idMembru);
                    
                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Returnează un răspuns JSON de succes
                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");
                        response.getWriter().write("{\"success\": true, \"message\": \"Membrul a fost eliminat cu succes din echipă.\"}");
                        getServletContext().log("Membru eliminat cu succes: " + idMembru);
                    } else {
                        // Returnează un răspuns JSON de eroare
                        response.setContentType("application/json");
                        response.setCharacterEncoding("UTF-8");
                        response.getWriter().write("{\"success\": false, \"message\": \"Nu s-a putut elimina membrul din echipă.\"}");
                        getServletContext().log("Eroare la eliminarea membrului: " + idMembru + " - niciun rând afectat");
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            // Log the error
            getServletContext().log("JDBC Driver not found", e);
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare la încărcarea driver-ului JDBC.\"}");
        } catch (SQLException e) {
            // Log the error
            getServletContext().log("Database error", e);
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare la baza de date: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            // Log the error
            getServletContext().log("Unexpected error", e);
            
            // Returnează un răspuns JSON de eroare
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": false, \"message\": \"Eroare neașteptată: " + e.getMessage() + "\"}");
        }
    }
}