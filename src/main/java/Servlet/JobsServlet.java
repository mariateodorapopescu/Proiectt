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

public class JobsServlet extends HttpServlet {
    
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
        if (action == null) action = "list";
        
        switch(action) {
            case "list":
                listJobs(request, response);
                break;
            case "detail":
                showJobDetail(request, response);
                break;
            case "myapplications":
                listMyApplications(request, response);
                break;
            case "hrview":
                viewApplicationsForHR(request, response);
                break;
            default:
                listJobs(request, response);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if ("apply".equals(action)) {
            applyForJob(request, response);
        } else if ("schedule".equals(action)) {
            scheduleInterview(request, response);
        }
    }
    
    private void listJobs(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            String sql = "SELECT j.id, j.titlu, j.req, j.resp, j.dom, j.subdom, d.nume_dep, t.denumire, " +
                         "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie, " +
                         "j.start, j.end, j.ore, j.tip " +
                         "FROM joburi j " +
                         "JOIN departament d ON j.departament = d.id_dep " +
                         "JOIN tipuri t ON j.pozitie = t.tip " +
                         "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                         "WHERE j.activ = true AND j.end >= CURDATE()";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            request.setAttribute("jobs", rs);
            request.getRequestDispatcher("jobs.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void showJobDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            int jobId = Integer.parseInt(request.getParameter("id"));
            
            // Get job details
            String sql = "SELECT j.*, d.nume_dep, t.denumire, " +
                         "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
                         "FROM joburi j " +
                         "JOIN departament d ON j.departament = d.id_dep " +
                         "JOIN tipuri t ON j.pozitie = t.tip " +
                         "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                         "WHERE j.id = ?";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                request.setAttribute("job", rs);
                
                // Check if user already applied
                HttpSession session = request.getSession();
                int userId = (Integer) session.getAttribute("user_id");
                
                sql = "SELECT * FROM aplicari WHERE job_id = ? AND id_ang = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, jobId);
                ps.setInt(2, userId);
                ResultSet appliedRs = ps.executeQuery();
                
                request.setAttribute("alreadyApplied", appliedRs.next());
                request.getRequestDispatcher("job-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect("JobsServlet");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void applyForJob(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            int jobId = Integer.parseInt(request.getParameter("job_id"));
            
            // Check if already applied
            String checkSql = "SELECT COUNT(*) FROM aplicari WHERE job_id = ? AND id_ang = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, jobId);
            checkPs.setInt(2, userId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                request.setAttribute("error", "Ați aplicat deja pentru acest job.");
                showJobDetail(request, response);
                return;
            }
            
            // Insert application
            String sql = "INSERT INTO aplicari (job_id, id_ang, data_apl) VALUES (?, ?, CURDATE())";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, userId);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // Notify HR about the application
                notifyHR(jobId, userId);
                request.setAttribute("success", "Aplicarea a fost înregistrată cu succes!");
            } else {
                request.setAttribute("error", "Eroare la înregistrarea aplicării.");
            }
            
            showJobDetail(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void notifyHR(int jobId, int userId) {
        // Send notification to HR department (could be email or internal notification)
        // This would be implemented based on your notification system
    }
    
    private void listMyApplications(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            String sql = "SELECT a.*, j.titlu, j.dom, j.subdom, d.nume_dep, t.denumire, " +
                         "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
                         "FROM aplicari a " +
                         "JOIN joburi j ON a.job_id = j.id " +
                         "JOIN departament d ON j.departament = d.id_dep " +
                         "JOIN tipuri t ON j.pozitie = t.tip " +
                         "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                         "WHERE a.id_ang = ? " +
                         "ORDER BY a.data_apl DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            request.setAttribute("applications", rs);
            request.getRequestDispatcher("my-applications.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void viewApplicationsForHR(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userType = (Integer) session.getAttribute("user_type");
            int userDep = (Integer) session.getAttribute("user_dep");
            
            // Check if user is HR or has appropriate permissions
            if (userDep != 1) { // HR department
                response.sendRedirect("index.jsp");
                return;
            }
            
            String sql = "SELECT a.*, u.nume, u.prenume, u.email, u.telefon, j.titlu, j.dom, j.subdom, " +
                         "d.nume_dep, t.denumire, " +
                         "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
                         "FROM aplicari a " +
                         "JOIN useri u ON a.id_ang = u.id " +
                         "JOIN joburi j ON a.job_id = j.id " +
                         "JOIN departament d ON j.departament = d.id_dep " +
                         "JOIN tipuri t ON j.pozitie = t.tip " +
                         "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                         "ORDER BY a.data_apl DESC";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            request.setAttribute("applications", rs);
            request.getRequestDispatcher("hr-applications.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    private void scheduleInterview(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation for scheduling interviews
        // This would be extended based on your requirements
    }
}