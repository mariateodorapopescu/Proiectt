<%@ page import="java.sql.*, javax.servlet.http.*, bean.MyUser" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);

    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                         "dp.denumire_completa AS denumire FROM useri u " +
                         "JOIN tipuri t ON u.tip = t.tip " +
                         "JOIN departament d ON u.id_dep = d.id_dep " +
                         "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                         "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    boolean isDirector = (ierarhie < 3);
                    boolean isSef = (ierarhie >= 4 && ierarhie <= 5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    if (!isDirector) {
                        if (isAdmin) {
                            response.sendRedirect("adminok.jsp");
                        }
                        if (isUtilizatorNormal) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (isSef) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (isIncepator) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
            }
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("</script>");
            response.sendRedirect("login.jsp");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("login.jsp");
    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Raportări - Dashboard</title>
    <link rel="stylesheet" href="assets/css/dashboard.css">
</head>
<body>
       <div class="dashboard-container">
        <h1>Dashboard Rapoarte HR</h1>
        
        <div class="report-links">
            <a href="ReportsServlet?type=recruitment" class="report-link">Raport Recrutare</a>
            <a href="ReportsServlet?type=leave" class="report-link">Raport Concedii</a>
            <a href="ReportsServlet?type=employee" class="report-link">Raport Angajați</a>
            <a href="ReportsServlet?type=department" class="report-link">Raport Departament</a>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Angajați</div>
                <div class="stat-value">${dashboardData.totalEmployees}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Angajați Noi (30 zile)</div>
                <div class="stat-value">${dashboardData.newEmployees}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Joburi Active</div>
                <div class="stat-value">${dashboardData.activeJobs}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Aplicări Recente (7 zile)</div>
                <div class="stat-value">${dashboardData.recentApplications}</div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Concedii Active</div>
                <div class="stat-value">${dashboardData.activeLeaves}</div>
            </div>
        </div>
        
        <div class="chart-row">
            <div class="chart-card">
                <div class="chart-title">Angajați pe Departamente</div>
                <canvas id="departmentChart"></canvas>
            </div>
            <div class="chart-card">
                <div class="chart-title">Aplicări Lunare (ultimele 6 luni)</div>
                <canvas id="applicationsChart"></canvas>
            </div>
        </div>
    </div>
    
    <script>
    // Grafic departamente
    const deptCtx = document.getElementById('departmentChart').getContext('2d');
    new Chart(deptCtx, {
        type: 'pie',
        data: {
            labels: [<c:forEach items="${dashboardData.departmentStats}" var="dept" varStatus="status">
                        '${dept.name}'<c:if test="${!status.last}">,</c:if>
                    </c:forEach>],
            datasets: [{
                data: [<c:forEach items="${dashboardData.departmentStats}" var="dept" varStatus="status">
                        ${dept.count}<c:if test="${!status.last}">,</c:if>
                      </c:forEach>],
                backgroundColor: [
                    '#3498db', '#2ecc71', '#e74c3c', '#f39c12', '#9b59b6',
                    '#1abc9c', '#34495e', '#95a5a6', '#d35400', '#c0392b'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'right'
                }
            }
        }
    });
    
    // Grafic aplicări
    const appCtx = document.getElementById('applicationsChart').getContext('2d');
    new Chart(appCtx, {
        type: 'line',
        data: {
            labels: [<c:forEach items="${dashboardData.monthlyApplications}" var="month" varStatus="status">
                        '${month.month}'<c:if test="${!status.last}">,</c:if>
                    </c:forEach>],
            datasets: [{
                label: 'Aplicări',
                data: [<c:forEach items="${dashboardData.monthlyApplications}" var="month" varStatus="status">
                        ${month.count}<c:if test="${!status.last}">,</c:if>
                      </c:forEach>],
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    </script>
    
</body>
</html>
