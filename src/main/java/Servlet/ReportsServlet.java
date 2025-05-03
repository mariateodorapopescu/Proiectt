package Servlet;

import java.io.IOException;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import bean.MyUser;

public class ReportsServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1) Verificare sesiune
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");

        // 2) Încarcă driver JDBC
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("JDBC Driver neidentificat!", e);
        }

        // 3) Deschide conexiunea
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // 4) Verificare rol/ierarhie
            int userId = currentUser.getId();
            int userDep, ierarhie;
            String functie;
            try (PreparedStatement psRole = conn.prepareStatement(
                    "SELECT u.id_dep, t.ierarhie, t.denumire AS functie " +
                    "FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE u.id = ?")) {
                psRole.setInt(1, userId);
                try (ResultSet rs = psRole.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    userDep  = rs.getInt("id_dep");
                    ierarhie = rs.getInt("ierarhie");
                    functie  = rs.getString("functie");
                }
            }

            boolean isDirector = ierarhie < 3;
            // doar HR (dep 1) sau management (ierarhie < 3) pot accesa
            if (userDep != 1 && !isDirector) {
                response.sendRedirect("index.jsp");
                return;
            }

            // 5) Alege tip raport
            String reportType = request.getParameter("type");
            if (reportType == null) reportType = "dashboard";

            switch (reportType) {
                case "dashboard":
                    generateDashboard(request, response, conn);
                    break;
                case "recruitment":
                    generateRecruitmentReport(request, response, conn);
                    break;
                case "leave":
                    generateLeaveReport(request, response, conn);
                    break;
                case "employee":
                    generateEmployeeReport(request, response, conn);
                    break;
                case "department":
                    generateDepartmentReport(request, response, conn);
                    break;
                default:
                    generateDashboard(request, response, conn);
            }
        } catch (SQLException e) {
            throw new ServletException("Eroare la baza de date: " + e.getMessage(), e);
        }
    }
	private void generateEmployeeReport(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws ServletException, IOException, SQLException {
        List<Map<String,Object>> employees = new ArrayList<>();
        String sql = "SELECT u.id, u.nume, u.prenume, d.nume_dep, t.denumire AS functie, u.data_ang " +
                     "FROM useri u " +
                     "JOIN departament d ON u.id_dep = d.id_dep " +
                     "JOIN tipuri t ON u.tip = t.tip " +
                     "WHERE u.activ = 1 " +
                     "ORDER BY u.nume, u.prenume";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("nume", rs.getString("nume"));
                m.put("prenume", rs.getString("prenume"));
                m.put("departament", rs.getString("nume_dep"));
                m.put("functie", rs.getString("functie"));
                m.put("dataAngajare", rs.getDate("data_ang"));
                employees.add(m);
            }
        }
        request.setAttribute("employees", employees);
        request.getRequestDispatcher("employee-report.jsp").forward(request, response);
    }

    private void generateDepartmentReport(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws ServletException, IOException, SQLException {
        List<Map<String,Object>> departments = new ArrayList<>();
        String sql = "SELECT d.id_dep, d.nume_dep, COUNT(u.id) AS numar_angajati, " +
                     "AVG(DATEDIFF(CURDATE(), u.data_ang)) AS vechime_medie " +
                     "FROM departament d " +
                     "LEFT JOIN useri u ON d.id_dep = u.id_dep AND u.activ = 1 " +
                     "GROUP BY d.id_dep, d.nume_dep " +
                     "ORDER BY numar_angajati DESC";
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("idDep", rs.getInt("id_dep"));
                m.put("numeDep", rs.getString("nume_dep"));
                m.put("numarAngajati", rs.getInt("numar_angajati"));
                m.put("vechimeMedie", rs.getDouble("vechime_medie"));
                departments.add(m);
            }
        }
        request.setAttribute("departments", departments);
        request.getRequestDispatcher("department-report.jsp").forward(request, response);
    }
    
	private void generateDashboard(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws ServletException, IOException, SQLException {
        Map<String, Object> dashboardData = new HashMap<>();

        // Total angajați
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM useri WHERE id_dep != -1");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) dashboardData.put("totalEmployees", rs.getInt("total"));
        }
        // Angajați noi (ultimele 30 zile)
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM useri WHERE data_ang >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) dashboardData.put("newEmployees", rs.getInt("total"));
        }
        // Joburi active
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM joburi WHERE activ = 1 AND end >= CURDATE()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) dashboardData.put("activeJobs", rs.getInt("total"));
        }
        // Aplicări recente (ultimele 7 zile)
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM aplicari WHERE data_apl >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) dashboardData.put("recentApplications", rs.getInt("total"));
        }
        // Concedii active
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM concedii WHERE status = 2 AND start_c <= CURDATE() AND end_c >= CURDATE()");
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) dashboardData.put("activeLeaves", rs.getInt("total"));
        }
        // Top 5 departamente (după număr angajați)
        List<Map<String, Object>> deptStats = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT d.nume_dep, COUNT(u.id) AS total " +
                "FROM departament d LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                "WHERE u.id_dep != -1 GROUP BY d.id_dep, d.nume_dep ORDER BY total DESC LIMIT 5");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("name", rs.getString("nume_dep"));
                m.put("count", rs.getInt("total"));
                deptStats.add(m);
            }
        }
        dashboardData.put("departmentStats", deptStats);

        // Statistici lunare aplicări (ultimele 6 luni)
        List<Map<String, Object>> monthlyApps = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT DATE_FORMAT(data_apl,'%Y-%m') AS month, COUNT(*) AS total " +
                "FROM aplicari WHERE data_apl >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                "GROUP BY month ORDER BY month");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("month", rs.getString("month"));
                m.put("count", rs.getInt("total"));
                monthlyApps.add(m);
            }
        }
        dashboardData.put("monthlyApplications", monthlyApps);

        request.setAttribute("dashboardData", dashboardData);
        request.getRequestDispatcher("reports-dashboard.jsp").forward(request, response);
    }

    private void generateRecruitmentReport(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws ServletException, IOException, SQLException {
        Map<String, Object> reportData = new HashMap<>();
        String startDate = request.getParameter("startDate");
        String endDate   = request.getParameter("endDate");
        if (startDate == null || endDate == null) {
            Calendar cal = Calendar.getInstance();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            endDate   = sdf.format(cal.getTime());
            cal.add(Calendar.DAY_OF_MONTH, -30);
            startDate = sdf.format(cal.getTime());
        }

        // Total aplicări în interval
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total FROM aplicari WHERE data_apl BETWEEN ? AND ?");
        ) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) reportData.put("totalApplications", rs.getInt("total"));
            }
        }
        // Aplicări pe job
        List<Map<String, Object>> byJob = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT j.titlu, COUNT(a.id) AS total " +
                "FROM joburi j LEFT JOIN aplicari a ON j.id = a.job_id " +
                "WHERE a.data_apl BETWEEN ? AND ? GROUP BY j.id, j.titlu ORDER BY total DESC");
        ) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("title", rs.getString("titlu"));
                    m.put("count", rs.getInt("total"));
                    byJob.add(m);
                }
            }
        }
        reportData.put("applicationsByJob", byJob);

        // Rata conversie
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) AS total_applications, " +
                "SUM(CASE WHEN status='INTERVIEW' THEN 1 ELSE 0 END) AS interviews, " +
                "SUM(CASE WHEN status='HIRED' THEN 1 ELSE 0 END) AS hires " +
                "FROM aplicari WHERE data_apl BETWEEN ? AND ?");
        ) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int tot = rs.getInt("total_applications"),
                        ivs = rs.getInt("interviews"),
                        hrs = rs.getInt("hires");
                    reportData.put("conversionRate", calculateConversionRate(tot, ivs, hrs));
                }
            }
        }

        // Timp mediu procesare
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT AVG(DATEDIFF(COALESCE(modified_date, CURDATE()), data_apl)) AS avg_days " +
                "FROM aplicari WHERE data_apl BETWEEN ? AND ? AND status <> 'PENDING'");
        ) {
            ps.setString(1, startDate);
            ps.setString(2, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) reportData.put("avgProcessingTime", rs.getDouble("avg_days"));
            }
        }

        request.setAttribute("reportData", reportData);
        request.setAttribute("startDate", startDate);
        request.setAttribute("endDate", endDate);
        request.getRequestDispatcher("recruitment-report.jsp").forward(request, response);
    }

    private void generateLeaveReport(HttpServletRequest request, HttpServletResponse response, Connection conn)
            throws ServletException, IOException, SQLException {
        Map<String, Object> reportData = new HashMap<>();
        String year = request.getParameter("year");
        if (year == null) year = String.valueOf(Calendar.getInstance().get(Calendar.YEAR));

        // Total zile concediu
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT SUM(durata) AS total_days FROM concedii WHERE YEAR(start_c)=? AND status=2");
        ) {
            ps.setString(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) reportData.put("totalLeaveDays", rs.getInt("total_days"));
            }
        }
        // Concedii pe departament
        List<Map<String, Object>> byDept = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT d.nume_dep, SUM(c.durata) AS total_days, COUNT(c.id) AS total_leaves " +
                "FROM departament d " +
                "LEFT JOIN useri u ON d.id_dep = u.id_dep " +
                "LEFT JOIN concedii c ON u.id = c.id_ang AND YEAR(c.start_c)=? AND c.status=2 " +
                "GROUP BY d.id_dep, d.nume_dep ORDER BY total_days DESC");
        ) {
            ps.setString(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("nume_dep"));
                    m.put("days", rs.getInt("total_days"));
                    m.put("count", rs.getInt("total_leaves"));
                    byDept.add(m);
                }
            }
        }
        reportData.put("leavesByDepartment", byDept);

        // Concedii pe tip
        List<Map<String, Object>> byType = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT tc.motiv AS name, COUNT(c.id) AS count, SUM(c.durata) AS days " +
                "FROM tipcon tc " +
                "LEFT JOIN concedii c ON tc.tip = c.tip AND YEAR(c.start_c)=? AND c.status=2 " +
                "GROUP BY tc.tip, tc.motiv ORDER BY count DESC");
        ) {
            ps.setString(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("name"));
                    m.put("count", rs.getInt("count"));
                    m.put("days", rs.getInt("days"));
                    byType.add(m);
                }
            }
        }
        reportData.put("leavesByType", byType);

        // Concedii pe lună
        List<Map<String, Object>> byMonth = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT MONTH(start_c) AS month, COUNT(*) AS count, SUM(durata) AS days " +
                "FROM concedii WHERE YEAR(start_c)=? AND status=2 GROUP BY month ORDER BY month");
        ) {
            ps.setString(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("month", getMonthName(rs.getInt("month")));
                    m.put("count", rs.getInt("count"));
                    m.put("days", rs.getInt("days"));
                    byMonth.add(m);
                }
            }
        }
        reportData.put("leavesByMonth", byMonth);

        // Top 10 angajați
        List<Map<String, Object>> topEmps = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT u.nume, u.prenume, SUM(c.durata) AS days, COUNT(c.id) AS count " +
                "FROM useri u " +
                "LEFT JOIN concedii c ON u.id = c.id_ang AND YEAR(c.start_c)=? AND c.status=2 " +
                "GROUP BY u.id, u.nume, u.prenume HAVING days>0 ORDER BY days DESC LIMIT 10");
        ) {
            ps.setString(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("nume") + " " + rs.getString("prenume"));
                    m.put("days", rs.getInt("days"));
                    m.put("count", rs.getInt("count"));
                    topEmps.add(m);
                }
            }
        }
        reportData.put("topEmployeesByLeave", topEmps);

        request.setAttribute("reportData", reportData);
        request.setAttribute("year", year);
        request.getRequestDispatcher("leave-report.jsp").forward(request, response);
    }

    private Map<String, Double> calculateConversionRate(int apps, int ivs, int hrs) {
        Map<String, Double> m = new HashMap<>();
        m.put("applicationToInterview", apps > 0 ? (ivs * 100.0 / apps) : 0.0);
        m.put("interviewToHire", ivs > 0 ? (hrs * 100.0 / ivs) : 0.0);
        m.put("overallConversion", apps > 0 ? (hrs * 100.0 / apps) : 0.0);
        return m;
    }

    private String getMonthName(int month) {
        String[] months = {
            "Ianuarie","Februarie","Martie","Aprilie","Mai","Iunie",
            "Iulie","August","Septembrie","Octombrie","Noiembrie","Decembrie"
        };
        return months[month - 1];
    }
}
