package Servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
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

public class CVManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 1) sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
                // rol/ierarhie
                try (PreparedStatement psRole = conn.prepareStatement(
                        "SELECT t.ierarhie, t.denumire AS functie FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE u.id = ?")) {
                    psRole.setInt(1, currentUser.getId());
                    try (ResultSet rs = psRole.executeQuery()) {
                        if (!rs.next()) {
                            response.sendRedirect("login.jsp");
                            return;
                        }
                        int ierarhie = rs.getInt("ierarhie");
                        String functie = rs.getString("functie");
                        boolean isDirector = (ierarhie < 3);
                        if (!isDirector) {
                            // redirect după rol
                            if ("Administrator".equals(functie))      response.sendRedirect("adminok.jsp");
                            else if (ierarhie >= 4 && ierarhie <=5)  response.sendRedirect("sefok.jsp");
                            else if (ierarhie >= 10)                 response.sendRedirect("tip2ok.jsp");
                            else                                     response.sendRedirect("tip1ok.jsp");
                            return;
                        }
                    }
                }

                // dispatch acțiune
                String action = request.getParameter("action");
                if (action == null) action = "view";
                switch (action) {
                    case "view":
                        viewCV(request, response, conn, currentUser.getId());
                        break;
                    case "edit":
                        editCV(request, response, conn, currentUser.getId());
                        break;
                    case "delete":
                        deleteCV(request, response, conn, currentUser.getId());
                        break;
                    case "deleteExperience":
                        deleteExperience(request, response, conn);
                        break;
                    case "deleteEducation":
                        deleteEducation(request, response, conn);
                        break;
                    case "deleteLanguage":
                        deleteLanguage(request, response, conn);
                        break;
                    case "deleteProject":
                        deleteProject(request, response, conn);
                        break;
                    default:
                        viewCV(request, response, conn, currentUser.getId());
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new ServletException("Eroare la gestionarea CV-ului: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 1) sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
                String action = request.getParameter("action");
                switch (action) {
                    case "save":
                        saveCV(request, response, conn, currentUser.getId());
                        break;
                    case "addExperience":
                        addExperience(request, response, conn, currentUser.getId());
                        break;
                    case "updateExperience":
                        updateExperience(request, response, conn);
                        break;
                    case "addEducation":
                        addEducation(request, response, conn, currentUser.getId());
                        break;
                    case "updateEducation":
                        updateEducation(request, response, conn);
                        break;
                    case "addLanguage":
                        addLanguage(request, response, conn, currentUser.getId());
                        break;
                    case "updateLanguage":
                        updateLanguage(request, response, conn);
                        break;
                    case "addProject":
                        addProject(request, response, conn, currentUser.getId());
                        break;
                    case "updateProject":
                        updateProject(request, response, conn);
                        break;
                    default:
                        response.sendRedirect("CVManagementServlet");
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            throw new ServletException("Eroare la procesarea cererii CV: " + e.getMessage(), e);
        }
    }

    // === viewCV: încarcă datele și forward ===
    private void viewCV(HttpServletRequest request, HttpServletResponse response,
                        Connection conn, int userId)
            throws ServletException, IOException, SQLException {
        // date personale
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT u.*, d.nume_dep, t.denumire AS pozitie " +
                "FROM useri u " +
                "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                "LEFT JOIN tipuri t ON u.tip = t.tip " +
                "WHERE u.id = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("userRs", rs);
                // notă: jsp va parcurge ResultSet
            }
        }
        // experienta
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM experienta WHERE id_ang = ? ORDER BY start DESC")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("expRs", rs);
            }
        }
        // educatie
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM studii WHERE id_ang = ? ORDER BY start DESC")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("eduRs", rs);
            }
        }
        // limbi
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT la.*, l.limba, n.semnificatie AS nivel_denumire " +
                "FROM limbi_ang la " +
                "JOIN limbi l ON la.id_limba = l.id " +
                "JOIN nivel n ON la.nivel = n.id " +
                "WHERE la.id_ang = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("langRs", rs);
            }
        }
        // proiecte
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM proiecte2 WHERE id_ang = ? ORDER BY start DESC")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("projRs", rs);
            }
        }
        // calitati/interese
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM cv WHERE id_ang = ?")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("cvRs", rs);
            }
        }

        request.getRequestDispatcher("cv-management.jsp").forward(request, response);
    }

    // === saveCV ===
    private void saveCV(HttpServletRequest request, HttpServletResponse response,
                        Connection conn, int userId)
            throws ServletException, IOException, SQLException {
        String calitati = request.getParameter("calitati");
        String interese = request.getParameter("interese");
        // dacă există, update, altfel insert
        try (PreparedStatement ps = conn.prepareStatement(
                "REPLACE INTO cv (id_ang, calitati, interese) VALUES (?, ?, ?)")) {
            ps.setInt(1, userId);
            ps.setString(2, calitati);
            ps.setString(3, interese);
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    // === CRUD Experienta ===
    private void addExperience(HttpServletRequest request, HttpServletResponse response,
                               Connection conn, int userId)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO experienta (den_job, instit, tip, id_dep, domeniu, subdomeniu, start, end, descriere, id_ang) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            ps.setString(1, request.getParameter("den_job"));
            ps.setString(2, request.getParameter("instit"));
            ps.setInt(3, Integer.parseInt(request.getParameter("tip")));
            ps.setInt(4, Integer.parseInt(request.getParameter("id_dep")));
            ps.setString(5, request.getParameter("domeniu"));
            ps.setString(6, request.getParameter("subdomeniu"));
            ps.setDate(7, Date.valueOf(request.getParameter("start")));
            ps.setDate(8, Date.valueOf(request.getParameter("end")));
            ps.setString(9, request.getParameter("descriere"));
            ps.setInt(10, userId);
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void updateExperience(HttpServletRequest request, HttpServletResponse response,
                                  Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE experienta SET den_job=?, instit=?, tip=?, id_dep=?, domeniu=?, subdomeniu=?, start=?, end=?, descriere=? " +
                "WHERE id = ?")) {
            ps.setString(1, request.getParameter("den_job"));
            ps.setString(2, request.getParameter("instit"));
            ps.setInt(3, Integer.parseInt(request.getParameter("tip")));
            ps.setInt(4, Integer.parseInt(request.getParameter("id_dep")));
            ps.setString(5, request.getParameter("domeniu"));
            ps.setString(6, request.getParameter("subdomeniu"));
            ps.setDate(7, Date.valueOf(request.getParameter("start")));
            ps.setDate(8, Date.valueOf(request.getParameter("end")));
            ps.setString(9, request.getParameter("descriere"));
            ps.setInt(10, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void deleteExperience(HttpServletRequest request, HttpServletResponse response,
                                  Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM experienta WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    // === CRUD Studii ===
    private void addEducation(HttpServletRequest request, HttpServletResponse response,
                              Connection conn, int userId)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO studii (institutie, ciclu, specializare, start, end, id_ang) VALUES (?, ?, ?, ?, ?, ?)")) {
            ps.setString(1, request.getParameter("institutie"));
            ps.setInt(2, Integer.parseInt(request.getParameter("ciclu")));
            ps.setString(3, request.getParameter("specializare"));
            ps.setDate(4, Date.valueOf(request.getParameter("start")));
            ps.setDate(5, Date.valueOf(request.getParameter("end")));
            ps.setInt(6, userId);
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void updateEducation(HttpServletRequest request, HttpServletResponse response,
                                 Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE studii SET institutie=?, ciclu=?, specializare=?, start=?, end=? WHERE id = ?")) {
            ps.setString(1, request.getParameter("institutie"));
            ps.setInt(2, Integer.parseInt(request.getParameter("ciclu")));
            ps.setString(3, request.getParameter("specializare"));
            ps.setDate(4, Date.valueOf(request.getParameter("start")));
            ps.setDate(5, Date.valueOf(request.getParameter("end")));
            ps.setInt(6, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void deleteEducation(HttpServletRequest request, HttpServletResponse response,
                                 Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM studii WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    // === CRUD Limbi ===
    private void addLanguage(HttpServletRequest request, HttpServletResponse response,
                             Connection conn, int userId)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO limbi_ang (id_limba, nivel, id_ang) VALUES (?, ?, ?)")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id_limba")));
            ps.setInt(2, Integer.parseInt(request.getParameter("nivel")));
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void updateLanguage(HttpServletRequest request, HttpServletResponse response,
                                Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE limbi_ang SET id_limba=?, nivel=? WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id_limba")));
            ps.setInt(2, Integer.parseInt(request.getParameter("nivel")));
            ps.setInt(3, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void deleteLanguage(HttpServletRequest request, HttpServletResponse response,
                                Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM limbi_ang WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    // === CRUD Proiecte ===
    private void addProject(HttpServletRequest request, HttpServletResponse response,
                            Connection conn, int userId)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO proiecte2 (titlu, descriere, start, end, id_ang) VALUES (?, ?, ?, ?, ?)")) {
            ps.setString(1, request.getParameter("titlu"));
            ps.setString(2, request.getParameter("descriere"));
            ps.setDate(3, Date.valueOf(request.getParameter("start")));
            ps.setDate(4, Date.valueOf(request.getParameter("end")));
            ps.setInt(5, userId);
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void updateProject(HttpServletRequest request, HttpServletResponse response,
                               Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "UPDATE proiecte2 SET titlu=?, descriere=?, start=?, end=? WHERE id = ?")) {
            ps.setString(1, request.getParameter("titlu"));
            ps.setString(2, request.getParameter("descriere"));
            ps.setDate(3, Date.valueOf(request.getParameter("start")));
            ps.setDate(4, Date.valueOf(request.getParameter("end")));
            ps.setInt(5, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    private void deleteProject(HttpServletRequest request, HttpServletResponse response,
                               Connection conn)
            throws IOException, SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM proiecte2 WHERE id = ?")) {
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }
        response.sendRedirect("CVManagementServlet?action=view&success=true");
    }

    // === editCV: forward la pagina de edit ===
    private void editCV(HttpServletRequest request, HttpServletResponse response,
                        Connection conn, int userId)
            throws ServletException, IOException, SQLException {
        // încarcă datele existente EXACT ca viewCV și forward la edit JSP
        viewCV(request, response, conn, userId);
        request.getRequestDispatcher("cv-edit.jsp").forward(request, response);
    }

    // === deleteCV: entire CV deletion ===
    private void deleteCV(HttpServletRequest request, HttpServletResponse response,
                          Connection conn, int userId)
            throws ServletException, IOException, SQLException {
        String[] tables = {"cv","experienta","studii","limbi_ang","proiecte2"};
        for (String t: tables) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM " + t + " WHERE id_ang = ?")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
        }
        response.sendRedirect("CVManagementServlet?action=view&deleted=true");
    }
}
