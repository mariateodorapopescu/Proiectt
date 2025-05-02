package Servlet;

import java.io.IOException;
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

public class moaradevant extends HttpServlet {
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

        String nume = request.getParameter("nume");
        int idProiect = Integer.parseInt(request.getParameter("id_prj"));
        int supervizor = Integer.parseInt(request.getParameter("supervizor"));
        String[] membri = request.getParameterValues("membri");

        // Validări de bază
        if (nume == null || nume.trim().isEmpty()) {
            response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&error=invalidTeamName");
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

            // Adaugă echipa
            String sql = "INSERT INTO echipe (nume, supervizor, id_prj) VALUES (?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, nume);
            pstmt.setInt(2, supervizor);
            pstmt.setInt(3, idProiect);
            pstmt.executeUpdate();

            // Obține ID-ul echipei nou create
            ResultSet rs = pstmt.getGeneratedKeys();
            int idEchipa = 0;
            if (rs.next()) {
                idEchipa = rs.getInt(1);
            }
            rs.close();
            pstmt.close();

            // Dacă nu s-a creat ID echipă, facem rollback și returnăm eroare
            if (idEchipa == 0) {
                conn.rollback();
                response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&error=teamCreationFailed");
                return;
            }

            // Adaugă membrii în echipă - actualizăm câmpul id_echipa din tabela useri
            if (membri != null && idEchipa > 0) {
                sql = "UPDATE useri SET id_echipa = ? WHERE id = ?";
                pstmt = conn.prepareStatement(sql);

                for (String idMembru : membri) {
                    pstmt.setInt(1, idEchipa);
                    pstmt.setInt(2, Integer.parseInt(idMembru));
                    pstmt.addBatch();
                }

                pstmt.executeBatch();
                pstmt.close();
            }

            // Commit transaction
            conn.commit();
            getServletContext().log("Echipa creată cu succes: " + idEchipa);
            response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&success=true");

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
            
            response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&error=driverNotFound");
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
            
            response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&error=databaseError");
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
            
            response.sendRedirect("administrare_proiecte.jsp?action=teams&id=" + idProiect + "&error=unexpectedError");
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