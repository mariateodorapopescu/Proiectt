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
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String username = currentUser.getUsername();

        // === 2) Încarcă driver-ul JDBC și deschide conexiunea ===
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver neidentificat!", e);
        } catch (InstantiationException | IllegalAccessException e) {
            throw new ServletException("Eroare la inițializarea driver-ului JDBC!", e);
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            
            // === 3) Preluare date utilizator curent din baza de date folosind username ===
            String userSql = "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie, " +
                            "dp.denumire_completa AS denumire FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?";
            
            int userId;
            int userIerarhie;
            int userDep;
            String userFunctie;
            
            try (PreparedStatement preparedStatement = conn.prepareStatement(userSql)) {
                preparedStatement.setString(1, username);
                try (ResultSet rs = preparedStatement.executeQuery()) {
                    if (!rs.next()) {
                        // Utilizator negăsit în baza de date
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    
                    // Extrag date despre userul curent
                    userId = rs.getInt("id");
                    userIerarhie = rs.getInt("ierarhie");
                    userFunctie = rs.getString("functie");
                    userDep = rs.getInt("id_dep");
                    
                    // Setez toate datele utilizatorului pentru JSP
                    request.setAttribute("currentUserData", rs);
                }
            }

            // === 4) Determinare privilegi utilizator ===
            boolean isDirector = (userIerarhie < 3);
            boolean isSef = (userIerarhie >= 4 && userIerarhie <= 5);
            boolean isIncepator = (userIerarhie >= 10);
            boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
            boolean isAdmin = (userFunctie != null && userFunctie.compareTo("Administrator") == 0);
            boolean isHR = (userDep == 1);   // departamentul 1 = HR
            
            // === 5) Determinare userId de încărcat (pentru directori/HR care pot vedea alte CV-uri) ===
            int targetUserId;
            if (request.getParameter("id") != null && (isDirector || isHR)) {
                // directorul sau HR poate vedea CV-uri ale altor utilizatori
                try {
                    targetUserId = Integer.parseInt(request.getParameter("id"));
                } catch (NumberFormatException e) {
                    targetUserId = userId; // fallback la propriul CV
                }
            } else {
                // altfel, generează doar propriul CV
                targetUserId = userId;
            }

            // === 6) Colectare date din baza de date pentru CV ===
            
            // 6.1 Date personale pentru targetUser
            String sql = "SELECT u.*, d.nume_dep, t.denumire AS pozitie " +
                         "FROM useri u " +
                         "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN tipuri t ON u.tip = t.tip " +
                         "WHERE u.id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet userRs = ps.executeQuery()) {
                    request.setAttribute("userRs", userRs);
                }
            }

            // 6.2 Calități și interese din cv
            sql = "SELECT * FROM cv WHERE id_ang = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet cvRs = ps.executeQuery()) {
                    request.setAttribute("cvRs", cvRs);
                }
            }

            // 6.3 Educație
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

            // 6.4 Experiență
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

            // 6.5 Proiecte personale - COMENTAT pentru că nu există id_ang în proiecte2
            /*
            sql = "SELECT * FROM proiecte2 WHERE id_ang = ? ORDER BY start DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, targetUserId);
                try (ResultSet projRs = ps.executeQuery()) {
                    request.setAttribute("projRs", projRs);
                }
            }
            */
            
            // ALTERNATIVA: Dacă vrei să afișezi toate proiectele (fără filtrare pe user)
            // Decomentează liniile de mai jos dacă vrei asta:
            /*
            sql = "SELECT * FROM proiecte2 ORDER BY start DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                try (ResultSet projRs = ps.executeQuery()) {
                    request.setAttribute("projRs", projRs);
                }
            }
            */
            
            // Pentru moment, setăm un ResultSet gol pentru proiecte
            request.setAttribute("projRs", null);

            // 6.6 Limbi
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

            // === 7) Setez informații suplimentare pentru JSP ===
            request.setAttribute("isDirector", isDirector);
            request.setAttribute("isSef", isSef);
            request.setAttribute("isIncepator", isIncepator);
            request.setAttribute("isUtilizatorNormal", isUtilizatorNormal);
            request.setAttribute("isHR", isHR);
            request.setAttribute("isAdmin", isAdmin);
            request.setAttribute("targetUserId", targetUserId);
            request.setAttribute("currentUserId", userId);
            request.setAttribute("currentUsername", username);

            // === 8) Forward către JSP-ul de generare CV ===
            request.getRequestDispatcher("generatedcv.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Eroare la conexiunea cu baza de date: " + e.getMessage(), e);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}