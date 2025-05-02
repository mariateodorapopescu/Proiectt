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

public class AdaugaMembruEchipaServlet extends HttpServlet {
    // Database connection constants
    private static final String DB_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "student";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userTip = (Integer) session.getAttribute("userTip");

        // Verificare permisiuni
        if (userTip == null || (userTip != 0 && userTip != 3 && userTip != 10)) {
            response.sendRedirect("Access.jsp?error=accessDenied");
            return;
        }

        int idEchipa = Integer.parseInt(request.getParameter("id_echipa"));
        int idProiect = Integer.parseInt(request.getParameter("id_prj"));
        String[] membri = request.getParameterValues("membri");

        // Verifică dacă există membri selectați
        if (membri == null || membri.length == 0) {
            response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                    + "&id_prj=" + idProiect + "&error=noMembersSelected");
            return;
        }

        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Disable auto-commit for transaction
            conn.setAutoCommit(false);

            // Adaugă membri în echipă - actualizăm câmpul id_echipa din tabela useri
            String sql = "UPDATE useri SET id_echipa = ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                for (String idMembru : membri) {
                    pstmt.setInt(1, idEchipa);
                    pstmt.setInt(2, Integer.parseInt(idMembru));
                    pstmt.addBatch();
                }
                
                int[] results = pstmt.executeBatch();
                boolean allSuccessful = true;
                
                for (int result : results) {
                    if (result <= 0) {
                        allSuccessful = false;
                        break;
                    }
                }
                
                if (!allSuccessful) {
                    conn.rollback();
                    response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                            + "&id_prj=" + idProiect + "&error=insertFailed");
                    return;
                }
            }

            // Commit transaction
            conn.commit();
            getServletContext().log("Membri adăugați cu succes la echipa: " + idEchipa);
            response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                    + "&id_prj=" + idProiect + "&success=true");

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
            
            response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                    + "&id_prj=" + idProiect + "&error=driverNotFound");
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
            
            response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                    + "&id_prj=" + idProiect + "&error=databaseError");
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
            
            response.sendRedirect("administrare_proiecte.jsp?action=members&id_echipa=" + idEchipa 
                    + "&id_prj=" + idProiect + "&error=unexpectedError");
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