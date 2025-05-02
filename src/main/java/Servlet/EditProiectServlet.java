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
import java.sql.Date;

public class EditProiectServlet extends HttpServlet {
    // Database connection constants
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        
        // Obține parametrii din formular
        int idProiect = Integer.parseInt(request.getParameter("id"));
        String nume = request.getParameter("nume");
        String descriere = request.getParameter("descriere");
        Date dataStart = Date.valueOf(request.getParameter("start"));
        Date dataEnd = Date.valueOf(request.getParameter("end"));
        int supervizor = Integer.parseInt(request.getParameter("supervizor"));

        // Validări de bază
        if (nume == null || nume.trim().isEmpty() || 
            descriere == null || descriere.trim().isEmpty() ||
            dataStart == null || dataEnd == null) {
            response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=invalidData");
            return;
        }

        // Verifică dacă data de început este înainte de data de sfârșit
        if (dataStart.after(dataEnd)) {
            response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=invalidDates");
            return;
        }

        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish the connection using DriverManager
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                
                String sql = "UPDATE proiecte SET nume = ?, descriere = ?, start = ?, end = ?, supervizor = ? WHERE id = ?";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, nume);
                    pstmt.setString(2, descriere);
                    pstmt.setDate(3, dataStart);
                    pstmt.setDate(4, dataEnd);
                    pstmt.setInt(5, supervizor);
                    pstmt.setInt(6, idProiect);

                    int rowsAffected = pstmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        response.sendRedirect("administrare_proiecte.jsp?action=list&success=true");
                    } else {
                        response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=updateFailed");
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            // Log the error
            getServletContext().log("JDBC Driver not found", e);
            response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=driverNotFound");
        } catch (SQLException e) {
            // Log the error
            getServletContext().log("Database error", e);
            response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=databaseError");
        } catch (Exception e) {
            // Log the error
            getServletContext().log("Unexpected error", e);
            response.sendRedirect("administrare_proiecte.jsp?action=edit&id=" + idProiect + "&error=unexpectedError");
        }
    }
}