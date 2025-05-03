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

import bean.MyUser;

public class InscriereEvenimentServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JSONObject json = new JSONObject();

        // 1) Verificare sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null) {
            json.put("success", false);
            json.put("message", "Nu e nicio sesiune activa!");
            out.print(json.toString());
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            json.put("success", false);
            json.put("message", "Utilizator neautentificat!");
            out.print(json.toString());
            return;
        }
        int userId = currentUser.getId();

        int eventId = Integer.parseInt(request.getParameter("event_id"));

        Connection conn = null;
        try {
            // 2) Încarcă driver-ul JDBC și deschide conexiunea cu DriverManager
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);

            // 3) Verifică dacă mai sunt locuri disponibile
            String sql = 
                "SELECT e.locuri_max, " +
                "  (SELECT COUNT(*) FROM participanti_evenimente WHERE id_event = e.id) AS nr_inscrisi " +
                "FROM evenimente e WHERE e.id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, eventId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (!rs.next()) {
                        json.put("success", false);
                        json.put("message", "Evenimentul nu există!");
                        conn.rollback();
                        out.print(json.toString());
                        return;
                    }
                    int locuriMax = rs.getInt("locuri_max");
                    int nrInscrisi = rs.getInt("nr_inscrisi");

                    if (nrInscrisi >= locuriMax) {
                        json.put("success", false);
                        json.put("message", "Nu mai sunt locuri disponibile!");
                        conn.rollback();
                        out.print(json.toString());
                        return;
                    }
                }
            }

            // 4) Înscrie utilizatorul
            sql = "INSERT INTO participanti_evenimente (id_event, id_ang) VALUES (?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, eventId);
                pstmt.setInt(2, userId);
                pstmt.executeUpdate();
            }

            conn.commit();
            json.put("success", true);
            json.put("message", "Înscriere realizată cu succes!");

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            json.put("success", false);
            json.put("message", "Driver JDBC neidentificat!");
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            if (e.getMessage().toLowerCase().contains("duplicate")) {
                json.put("success", false);
                json.put("message", "Sunteți deja înscris la acest eveniment!");
            } else {
                e.printStackTrace();
                json.put("success", false);
                json.put("message", "Eroare la înscriere: " + e.getMessage());
            }
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
