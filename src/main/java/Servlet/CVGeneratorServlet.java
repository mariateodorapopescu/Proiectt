package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.MyUser;

public class CVGeneratorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // === 1) Verificare sesiune și autentificare ===
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        // === 2) Încarcă driver-ul JDBC și deschide conexiunea ===
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver neidentificat!", e);
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // === 3) Preluare ierarhie și departament al utilizatorului ===
            String roleSql = 
                "SELECT t.ierarhie, t.denumire AS functie, u.id_dep " +
                "FROM useri u " +
                "JOIN tipuri t ON u.tip = t.tip " +
                "WHERE u.id = ?";
            int userIerarhie, userDep;
            String userFunctie;
            try (PreparedStatement rolePs = conn.prepareStatement(roleSql)) {
                rolePs.setInt(1, currentUser.getId());
                try (ResultSet rs = rolePs.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    userIerarhie = rs.getInt("ierarhie");
                    userFunctie  = rs.getString("functie");
                    userDep      = rs.getInt("id_dep");
                }
            }

            boolean isDirector = userIerarhie < 3;
            boolean isHR       = (userDep == 1);   // departamentul 1 = HR
            // === 4) Determinare userId de încărcat ===
            int targetUserId;
            if (request.getParameter("id") != null && (isDirector || isHR)) {
                // directorul sau HR poate vedea CV-uri ale altor utilizatori
                targetUserId = Integer.parseInt(request.getParameter("id"));
            } else {
                // altfel, generează doar propriul CV
                targetUserId = currentUser.getId();
            }

            // === 5) Colectare date din baza de date ===
            // 5.1 Date personale
            String sql = "SELECT u.*, d.nume_dep, t.denumire AS pozitie " +
                         "FROM useri u " +
                         "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN tipuri t ON u.tip = t.tip " +
                         "WHERE u.id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet userRs = ps.executeQuery()) {
                    request.setAttribute("userRs", userRs);  // pasăm ResultSet pe request
                    // Nota: JSP-ul va trebui să itereze pe acest ResultSet pentru a extrage datele
                }
            }

            // 5.2 Calități și interese din cv
            sql = "SELECT * FROM cv WHERE id_ang = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet cvRs = ps.executeQuery()) {
                    request.setAttribute("cvRs", cvRs);
                }
            }

            // 5.3 Educație
            sql = "SELECT s.*, c.semnificatie AS ciclu_denumire " +
                  "FROM studii s " +
                  "LEFT JOIN cicluri c ON s.ciclu = c.id " +
                  "WHERE s.id_ang = ? ORDER BY s.start DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet eduRs = ps.executeQuery()) {
                    request.setAttribute("eduRs", eduRs);
                }
            }

            // 5.4 Experiență
            sql = "SELECT e.*, t.denumire AS tip_denumire, d.nume_dep " +
                  "FROM experienta e " +
                  "LEFT JOIN tipuri t ON e.tip = t.tip " +
                  "LEFT JOIN departament d ON e.id_dep = d.id_dep " +
                  "WHERE e.id_ang = ? ORDER BY e.start DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet expRs = ps.executeQuery()) {
                    request.setAttribute("expRs", expRs);
                }
            }

            // 5.5 Proiecte personale
            sql = "SELECT * FROM proiecte2 WHERE id_ang = ? ORDER BY start DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet projRs = ps.executeQuery()) {
                    request.setAttribute("projRs", projRs);
                }
            }

            // 5.6 Limbi
            sql = "SELECT la.*, l.limba, n.semnificatie AS nivel_denumire " +
                  "FROM limbi_ang la " +
                  "JOIN limbi l ON la.id_limba = l.id " +
                  "JOIN nivel n ON la.nivel = n.id " +
                  "WHERE la.id_ang = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet langRs = ps.executeQuery()) {
                    request.setAttribute("langRs", langRs);
                }
            }

            // === 6) Forward către JSP-ul de generare CV ===
            request.getRequestDispatcher("generated-cv.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Eroare la conexiunea cu baza de date: " + e.getMessage(), e);
        }
    }
}
