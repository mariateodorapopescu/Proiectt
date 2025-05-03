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

public class CVServlet extends HttpServlet {
    
    // Database connection parameters
    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "student";
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) action = "view";
        
        switch(action) {
            case "view":
                viewCV(request, response);
                break;
            case "edit":
                editCV(request, response);
                break;
            case "create":
                createCV(request, response);
                break;
            default:
                viewCV(request, response);
        }
    }
    
    private void createCV(HttpServletRequest request, HttpServletResponse response) {
        // TODO Auto-generated method stub
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if ("save".equals(action)) {
            saveCV(request, response);
        } else if ("addExperience".equals(action)) {
            addExperience(request, response);
        } else if ("addEducation".equals(action)) {
            addEducation(request, response);
        } else if ("addLanguage".equals(action)) {
            addLanguage(request, response);
        } else if ("addProject".equals(action)) {
            addProject(request, response);
        }
    }
    
    private void viewCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId;
            
            // Dacă este HR și vede CV-ul unui candidat
            if (request.getParameter("id") != null && (Integer)session.getAttribute("user_dep") == 1) {
                userId = Integer.parseInt(request.getParameter("id"));
            } else {
                userId = (Integer) session.getAttribute("user_id");
            }
            
            // Date personale
            String sql = "SELECT u.*, d.nume_dep, t.denumire " +
                         "FROM useri u " +
                         "LEFT JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN tipuri t ON u.tip = t.tip " +
                         "WHERE u.id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet userRs = ps.executeQuery();
            
            // CV data
            sql = "SELECT * FROM cv WHERE id_ang = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet cvRs = ps.executeQuery();
            
            // Experiență
            sql = "SELECT e.*, t.denumire as tip_denumire, d.nume_dep " +
                  "FROM experienta e " +
                  "LEFT JOIN tipuri t ON e.tip = t.tip " +
                  "LEFT JOIN departament d ON e.id_dep = d.id_dep " +
                  "WHERE e.id_ang = ? ORDER BY e.start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet experienceRs = ps.executeQuery();
            
            // Educație
            sql = "SELECT s.*, c.semnificatie as ciclu_denumire " +
                  "FROM studii s " +
                  "LEFT JOIN cicluri c ON s.ciclu = c.id " +
                  "WHERE s.id_ang = ? ORDER BY s.start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet educationRs = ps.executeQuery();
            
            // Limbi străine
            sql = "SELECT la.*, l.limba, n.semnificatie as nivel_denumire " +
                  "FROM limbi_ang la " +
                  "JOIN limbi l ON la.id_limba = l.id " +
                  "JOIN nivel n ON la.nivel = n.id " +
                  "WHERE la.id_ang = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet languagesRs = ps.executeQuery();
            
            // Proiecte
            sql = "SELECT * FROM proiecte2 WHERE id_ang = ? ORDER BY start DESC";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet projectsRs = ps.executeQuery();
            
            request.setAttribute("user", userRs);
            request.setAttribute("cv", cvRs);
            request.setAttribute("experience", experienceRs);
            request.setAttribute("education", educationRs);
            request.setAttribute("languages", languagesRs);
            request.setAttribute("projects", projectsRs);
            
            request.getRequestDispatcher("view-cv.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void editCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Similar cu viewCV dar încarcă date pentru editare
        viewCV(request, response);
    }
    
    private void saveCV(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            String calitati = request.getParameter("calitati");
            String interese = request.getParameter("interese");
            
            // Verifică dacă există deja un CV
            String checkSql = "SELECT COUNT(*) FROM cv WHERE id_ang = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, userId);
            ResultSet checkRs = checkPs.executeQuery();
            checkRs.next();
            
            if (checkRs.getInt(1) > 0) {
                // Update
                String sql = "UPDATE cv SET calitati = ?, interese = ? WHERE id_ang = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, calitati);
                ps.setString(2, interese);
                ps.setInt(3, userId);
                ps.executeUpdate();
            } else {
                // Insert
                String sql = "INSERT INTO cv (id_ang, calitati, interese) VALUES (?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, userId);
                ps.setString(2, calitati);
                ps.setString(3, interese);
                ps.executeUpdate();
            }
            
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addExperience(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            String den_job = request.getParameter("den_job");
            String instit = request.getParameter("instit");
            int tip = Integer.parseInt(request.getParameter("tip"));
            int id_dep = Integer.parseInt(request.getParameter("id_dep"));
            String domeniu = request.getParameter("domeniu");
            String subdomeniu = request.getParameter("subdomeniu");
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            String descriere = request.getParameter("descriere");
            
            String sql = "INSERT INTO experienta (den_job, instit, tip, id_dep, domeniu, subdomeniu, start, end, descriere, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, den_job);
            ps.setString(2, instit);
            ps.setInt(3, tip);
            ps.setInt(4, id_dep);
            ps.setString(5, domeniu);
            ps.setString(6, subdomeniu);
            ps.setString(7, start);
            ps.setString(8, end);
            ps.setString(9, descriere);
            ps.setInt(10, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addEducation(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            String facultate = request.getParameter("facultate");
            String universitate = request.getParameter("universitate");
            int ciclu = Integer.parseInt(request.getParameter("ciclu"));
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            
            String sql = "INSERT INTO studii (facultate, universitate, ciclu, start, end, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, facultate);
            ps.setString(2, universitate);
            ps.setInt(3, ciclu);
            ps.setString(4, start);
            ps.setString(5, end);
            ps.setInt(6, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addLanguage(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            int id_limba = Integer.parseInt(request.getParameter("id_limba"));
            int nivel = Integer.parseInt(request.getParameter("nivel"));
            
            String sql = "INSERT INTO limbi_ang (id_limba, nivel, id_ang) VALUES (?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id_limba);
            ps.setInt(2, nivel);
            ps.setInt(3, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void addProject(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            String nume = request.getParameter("nume");
            String descriere = request.getParameter("descriere");
            String start = request.getParameter("start");
            String end = request.getParameter("end");
            
            String sql = "INSERT INTO proiecte2 (nume, descriere, start, end, id_ang) " +
                         "VALUES (?, ?, ?, ?, ?)";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, nume);
            ps.setString(2, descriere);
            ps.setString(3, start);
            ps.setString(4, end);
            ps.setInt(5, userId);
            
            ps.executeUpdate();
            response.sendRedirect("CVServlet?action=view");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}