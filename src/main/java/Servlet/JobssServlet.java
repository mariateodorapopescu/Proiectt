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

public class JobssServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        String action = request.getParameter("action");
        if (action == null) action = "list";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver neidentificat!", e);
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver neidentificat!", e);
        }

        if ("apply".equals(action)) {
            applyForJob(request, response);
        } else if ("schedule".equals(action)) {
            scheduleInterview(request, response);
        } else {
            response.sendRedirect("JobsServlet");
        }
    }

    private void listJobs(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sql =
            "SELECT j.id, j.titlu, j.req, j.resp, j.dom, j.subdom, d.nume_dep, t.denumire, " +
            "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie, " +
            "j.start, j.end, j.ore, j.tip " +
            "FROM joburi j " +
            "JOIN departament d ON j.departament = d.id_dep " +
            "JOIN tipuri t ON j.pozitie = t.tip " +
            "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
            "WHERE j.activ = true AND j.end >= CURDATE()";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            request.setAttribute("jobs", rs);
            request.getRequestDispatcher("jobs.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void showJobDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int jobId = Integer.parseInt(request.getParameter("id"));
        String sqlDetail =
            "SELECT j.*, d.nume_dep, t.denumire, " +
            "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
            "FROM joburi j " +
            "JOIN departament d ON j.departament = d.id_dep " +
            "JOIN tipuri t ON j.pozitie = t.tip " +
            "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
            "WHERE j.id = ?";
        String sqlCheck =
            "SELECT * FROM aplicari WHERE job_id = ? AND id_ang = ?";

        HttpSession session = request.getSession();
        int userId = ((MyUser)session.getAttribute("currentUser")).getId();

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {

            psDetail.setInt(1, jobId);
            try (ResultSet rs = psDetail.executeQuery()) {
                if (!rs.next()) {
                    response.sendRedirect("JobsServlet");
                    return;
                }
                request.setAttribute("job", rs);

                try (PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {
                    psCheck.setInt(1, jobId);
                    psCheck.setInt(2, userId);
                    try (ResultSet appliedRs = psCheck.executeQuery()) {
                        request.setAttribute("alreadyApplied", appliedRs.next());
                    }
                }

                request.getRequestDispatcher("job-detail.jsp")
                       .forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void applyForJob(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        int userId = ((MyUser)session.getAttribute("currentUser")).getId();
        int jobId  = Integer.parseInt(request.getParameter("job_id"));

        String sqlCheck = "SELECT COUNT(*) FROM aplicari WHERE job_id = ? AND id_ang = ?";
        String sqlInsert= "INSERT INTO aplicari (job_id, id_ang, data_apl) VALUES (?, ?, CURDATE())";

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement psCheck = conn.prepareStatement(sqlCheck)) {

            psCheck.setInt(1, jobId);
            psCheck.setInt(2, userId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    request.setAttribute("error", "Ați aplicat deja pentru acest job.");
                    showJobDetail(request, response);
                    return;
                }
            }

            try (PreparedStatement psInsert = conn.prepareStatement(sqlInsert)) {
                psInsert.setInt(1, jobId);
                psInsert.setInt(2, userId);
                psInsert.executeUpdate();
            }

            // notifyHR(jobId, userId);
            request.setAttribute("success", "Aplicarea a fost înregistrată cu succes!");
            showJobDetail(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void listMyApplications(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String sql =
            "SELECT a.*, j.titlu, j.dom, j.subdom, d.nume_dep, t.denumire, " +
            "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
            "FROM aplicari a " +
            "JOIN joburi j ON a.job_id = j.id " +
            "JOIN departament d ON j.departament = d.id_dep " +
            "JOIN tipuri t ON j.pozitie = t.tip " +
            "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
            "WHERE a.id_ang = ? ORDER BY a.data_apl DESC";

        HttpSession session = request.getSession();
        int userId = ((MyUser)session.getAttribute("currentUser")).getId();

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                request.setAttribute("applications", rs);
                request.getRequestDispatcher("my-applications.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void viewApplicationsForHR(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        String sql =
            "SELECT a.*, u.nume, u.prenume, u.email, u.telefon, j.titlu, j.dom, j.subdom, " +
            "d.nume_dep, t.denumire, " +
            "CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as locatie " +
            "FROM aplicari a " +
            "JOIN useri u ON a.id_ang = u.id " +
            "JOIN joburi j ON a.job_id = j.id " +
            "JOIN departament d ON j.departament = d.id_dep " +
            "JOIN tipuri t ON j.pozitie = t.tip " +
            "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
            "ORDER BY a.data_apl DESC";

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            request.setAttribute("applications", rs);
            request.getRequestDispatcher("hr-applications.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }

    private void scheduleInterview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // implementare programare interviu
        response.sendRedirect("interview-schedule.jsp");
    }
}
