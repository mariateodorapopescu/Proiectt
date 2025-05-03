package Servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

public class ScheduleInterviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Verifică dacă user-ul este din HR
        int userDep = (Integer) session.getAttribute("user_dep");
        if (userDep != 1) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            int appId = Integer.parseInt(request.getParameter("app_id"));
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT a.*, u.nume, u.prenume, u.email, j.titlu " +
                     "FROM aplicari a " +
                     "JOIN useri u ON a.id_ang = u.id " +
                     "JOIN joburi j ON a.job_id = j.id " +
                     "WHERE a.id = ?"
                 )) {

                ps.setInt(1, appId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("application", rs);
                        request.getRequestDispatcher("schedule-interview.jsp")
                               .forward(request, response);
                    } else {
                        response.sendRedirect("JobsServlet?action=hrview");
                    }
                }
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int appId            = Integer.parseInt(request.getParameter("app_id"));
            String interviewDate = request.getParameter("interview_date");
            String interviewTime = request.getParameter("interview_time");
            String location      = request.getParameter("location");
            String notes         = request.getParameter("notes");

            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                     "UPDATE aplicari SET status = 'SCHEDULED', mentiuni = ? WHERE id = ?"
                 )) {

                String mentiuni = String.format(
                    "Interviu programat: %s %s la %s. Note: %s",
                    interviewDate, interviewTime, location, notes
                );
                ps.setString(1, mentiuni);
                ps.setInt(2, appId);

                int result = ps.executeUpdate();
                if (result > 0) {
                    sendInterviewNotification(appId, interviewDate, interviewTime, location, notes);
                }
                response.sendRedirect("JobsServlet?action=hrview");
            }
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void sendInterviewNotification(int appId, String date, String time, String location, String notes) {
        String message = String.format(
            "Interviu programat pentru aplicația #%d: %s %s la %s. Note: %s",
            appId, date, time, location, notes
        );

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            // driver not found; log and return
            e.printStackTrace();
            return;
        }

        String selectSql = 
            "SELECT u.id, u.email FROM aplicari a JOIN useri u ON a.id_ang = u.id WHERE a.id = ?";
        String insertSql = 
            "INSERT INTO notificari (id_ang, tip, mesaj, data_notificare) VALUES (?, 'INTERVIEW', ?, NOW())";

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement psSelect = conn.prepareStatement(selectSql)) {

            psSelect.setInt(1, appId);
            try (ResultSet rs = psSelect.executeQuery()) {
                if (rs.next()) {
                    int candId = rs.getInt("id");
                    // Înregistrează notificarea în baza de date
                    try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                        psInsert.setInt(1, candId);
                        psInsert.setString(2, message);
                        psInsert.executeUpdate();
                    }
                    // Aici ai putea adăuga și trimis email folosind JavaMail, de ex.
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
