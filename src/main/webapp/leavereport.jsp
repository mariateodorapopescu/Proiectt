<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*, javax.servlet.http.*, bean.MyUser" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%
    // === 1) Verificare sesiune și autentificare ===
    HttpSession sesi = request.getSession(false);
    if (sesi == null) {
        out.println("<script>alert('Nu e nicio sesiune activa!');</script>");
        response.sendRedirect("login.jsp");
        return;
    }

    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser == null) {
        out.println("<script>alert('Utilizator neconectat!');</script>");
        response.sendRedirect("login.jsp");
        return;
    }

    // === 2) Încărcare driver și interogare detalii utilizator ===
    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
    try (Connection connection = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/test?useSSL=false", 
                "root", "student");
         PreparedStatement ps = connection.prepareStatement(
             "SELECT u.*, t.denumire AS functie, t.ierarhie " +
             "FROM useri u " +
             "JOIN tipuri t ON u.tip = t.tip " +
             "WHERE u.username = ?"
         )) {
        ps.setString(1, currentUser.getUsername());
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                // Dacă nu-l găsim în baza de date, deconectăm
                out.println("<script>alert('Utilizator inexistent!');</script>");
                response.sendRedirect("login.jsp");
                return;
            }
            int ierarhie = rs.getInt("ierarhie");
            String functie = rs.getString("functie");

            boolean isDirector         = (ierarhie < 3);
            boolean isSef              = (ierarhie >= 4 && ierarhie <= 5);
            boolean isIncepator        = (ierarhie >= 10);
            boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
            boolean isAdmin            = "Administrator".equals(functie);

            // Dacă NU e director, redirect conform rolului
            if (!isDirector) {
                if (isAdmin)          { response.sendRedirect("adminok.jsp");    return; }
                if (isUtilizatorNormal){ response.sendRedirect("tip1ok.jsp");     return; }
                if (isSef)            { response.sendRedirect("sefok.jsp");      return; }
                if (isIncepator)      { response.sendRedirect("tip2ok.jsp");     return; }
            }
        }
    } catch (Exception e) {
        out.println("<script>alert('Eroare la baza de date: " + e.getMessage() + "');</script>");
        // redirect fallback pe baza tipului curent
        int tip = currentUser.getTip();
        switch (tip) {
            case 0: response.sendRedirect("dashboard.jsp"); break;
            case 1: response.sendRedirect("tip1ok.jsp");    break;
            case 2: response.sendRedirect("tip2ok.jsp");    break;
            case 3: response.sendRedirect("sefok.jsp");     break;
            default: response.sendRedirect("login.jsp");    break;
        }
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Raport Concedii</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Stiluri similare cu recruitment-report.jsp */
        body { font-family: Arial, sans-serif; background: #f9f9f9; margin: 0; padding: 0; }
        .report-container { max-width: 960px; margin: 40px auto; background: #fff; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .filter-section { margin-bottom: 20px; }
        .filter-form .form-group { display: inline-block; margin-right: 10px; }
        .btn-filter { padding: 6px 12px; cursor: pointer; }
        .metrics-grid { display: flex; gap: 20px; margin-bottom: 30px; }
        .metric-card { flex: 1; background: #ececec; padding: 15px; border-radius: 6px; text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; }
        .chart-row { display: flex; gap: 20px; margin-bottom: 30px; }
        .chart-section { flex: 1; }
        .table-container { margin-top: 30px; }
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th, .data-table td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        .data-table th { background: #f0f0f0; }
    </style>
</head>
<body>
    <div class="report-container">
        <h1>Raport Concedii - ${year}</h1>

        <div class="filter-section">
            <form action="ReportsServlet" method="get" class="filter-form">
                <input type="hidden" name="type" value="leave">
                <div class="form-group">
                    <label for="year">An:</label>
                    <select id="year" name="year">
                        <c:forEach var="i" begin="2020" end="2025">
                            <option value="${i}" <c:if test="${i == year}">selected</c:if>>${i}</option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" class="btn-filter">Filtrează</button>
            </form>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-value">${reportData.totalLeaveDays}</div>
                <div class="metric-label">Total Zile Concediu</div>
            </div>
        </div>

        <div class="chart-row">
            <div class="chart-section">
                <h2>Concedii pe Departament</h2>
                <canvas id="departmentChart"></canvas>
            </div>
            <div class="chart-section">
                <h2>Concedii pe Tip</h2>
                <canvas id="typeChart"></canvas>
            </div>
        </div>

        <div class="chart-section">
            <h2>Distribuție Lunară</h2>
            <canvas id="monthlyChart"></canvas>
        </div>

        <div class="table-container">
            <h2>Top 10 Angajați - Zile Concediu</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Nume</th>
                        <th>Total Zile</th>
                        <th>Număr Concedii</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="emp" items="${reportData.topEmployeesByLeave}">
                        <tr>
                            <td>${emp.name}</td>
                            <td>${emp.days}</td>
                            <td>${emp.count}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
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
                        '#3498db','#2ecc71','#e74c3c','#f39c12','#9b59b6',
                        '#1abc9c','#34495e','#95a5a6','#d35400','#c0392b'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { position: 'right' } }
            }
        });

        // Grafic pe tip concediu
        const typeCtx = document.getElementById('typeChart').getContext('2d');
        new Chart(typeCtx, {
            type: 'pie',
            data: {
                labels: [<c:forEach items="${dashboardData.typeStats}" var="t" varStatus="status">
                            '${t.type}'<c:if test="${!status.last}">,</c:if>
                         </c:forEach>],
                datasets: [{
                    data: [<c:forEach items="${dashboardData.typeStats}" var="t" varStatus="status">
                            ${t.count}<c:if test="${!status.last}">,</c:if>
                          </c:forEach>],
                    backgroundColor: [
                        '#9b59b6','#e67e22','#16a085','#2c3e50','#c0392b'
                    ]
                }]
            },
            options: { responsive: true }
        });

        // Grafic distribuție lunară
        const monCtx = document.getElementById('monthlyChart').getContext('2d');
        new Chart(monCtx, {
            type: 'bar',
            data: {
                labels: [<c:forEach items="${dashboardData.monthlyLeave}" var="m" varStatus="status">
                            '${m.month}'<c:if test="${!status.last}">,</c:if>
                         </c:forEach>],
                datasets: [{
                    label: 'Zile Concediu',
                    data: [<c:forEach items="${dashboardData.monthlyLeave}" var="m" varStatus="status">
                            ${m.days}<c:if test="${!status.last}">,</c:if>
                          </c:forEach>],
                    fill: false,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                scales: { y: { beginAtZero: true } }
            }
        });
    </script>
</body>
</html>
