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

public class ApplicationManagementServlet extends HttpServlet {
    
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
                listApplications(request, response);
                break;
            case "delete":
                deleteApplication(request, response);
                break;
            case "withdraw":
                withdrawApplication(request, response);
                break;
            default:
                listApplications(request, response);
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
        }
    }
    
    private void listApplications(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            int userDep = (Integer) session.getAttribute("user_dep");
            
            String sql;
            PreparedStatement ps;
            
            if (userDep == 1) { // HR poate vedea toate aplicările
                sql = "SELECT a.*, u.nume, u.prenume, u.email, j.titlu, j.dom, j.subdom, d.nume_dep " +
                      "FROM aplicari a " +
                      "JOIN useri u ON a.id_ang = u.id " +
                      "JOIN joburi j ON a.job_id = j.id " +
                      "JOIN departament d ON j.departament = d.id_dep " +
                      "ORDER BY a.data_apl DESC";
                ps = conn.prepareStatement(sql);
            } else { // Utilizatorii normali văd doar aplicările lor
                sql = "SELECT a.*, j.titlu, j.dom, j.subdom, d.nume_dep " +
                      "FROM aplicari a " +
                      "JOIN joburi j ON a.job_id = j.id " +
                      "JOIN departament d ON j.departament = d.id_dep " +
                      "WHERE a.id_ang = ? " +
                      "ORDER BY a.data_apl DESC";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, userId);
            }
            
            ResultSet rs = ps.executeQuery();
            request.setAttribute("applications", rs);
            request.setAttribute("isHR", userDep == 1);
            
            request.getRequestDispatcher("application-management.jsp").forward(request, response);
            
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
            
            // Verifică dacă utilizatorul a aplicat deja
            String checkSql = "SELECT COUNT(*) FROM aplicari WHERE job_id = ? AND id_ang = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, jobId);
            checkPs.setInt(2, userId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                response.sendRedirect("JobsServlet?action=detail&id=" + jobId + "&error=already_applied");
                return;
            }
            
            // Adaugă aplicarea
            String sql = "INSERT INTO aplicari (job_id, id_ang, data_apl) VALUES (?, ?, CURDATE())";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, userId);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("JobsServlet?action=detail&id=" + jobId + "&success=true");
            } else {
                response.sendRedirect("JobsServlet?action=detail&id=" + jobId + "&error=failed");
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
    
    private void deleteApplication(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            int applicationId = Integer.parseInt(request.getParameter("id"));
            HttpSession session = request.getSession();
            int userDep = (Integer) session.getAttribute("user_dep");
            
            // Doar HR poate șterge aplicări
            if (userDep != 1) {
                response.sendRedirect("ApplicationManagementServlet?error=unauthorized");
                return;
            }
            
            String sql = "DELETE FROM aplicari WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, applicationId);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                response.sendRedirect("ApplicationManagementServlet?success=deleted");
            } else {
                response.sendRedirect("ApplicationManagementServlet?error=delete_failed");
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
    
    private void withdrawApplication(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Connection conn = null;
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection using DriverManager
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            
            int applicationId = Integer.parseInt(request.getParameter("id"));
            HttpSession session = request.getSession();
            int userId = (Integer) session.getAttribute("user_id");
            
            // Verifică dacă aplicarea aparține utilizatorului curent
            String checkSql = "SELECT id_ang FROM aplicari WHERE id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setInt(1, applicationId);
            ResultSet checkRs = checkPs.executeQuery();
            
            if (checkRs.next() && checkRs.getInt("id_ang") == userId) {
                // Șterge aplicarea
                String sql = "DELETE FROM aplicari WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, applicationId);
                
                int result = ps.executeUpdate();
                
                if (result > 0) {
                    response.sendRedirect("ApplicationManagementServlet?success=withdrawn");
                } else {
                    response.sendRedirect("ApplicationManagementServlet?error=withdraw_failed");
                }
            } else {
                response.sendRedirect("ApplicationManagementServlet?error=unauthorized");
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
}