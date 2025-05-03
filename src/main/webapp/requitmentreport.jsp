<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%

// Verificare sesiune și obținere user curent
HttpSession sesi = request.getSession(false);

if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                    "dp.denumire_completa AS denumire FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                    "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    // extrag date despre userul curent
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    boolean isHR = (userDep == 1); // Department HR

                    // Verificare acces - doar HR, directorii și administratorii pot accesa rapoartele de recrutare
                    if (!isHR && !isDirector && !isAdmin) {
                        response.sendRedirect("Access.jsp?error=accessDenied");
                        return;
                    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Raport Recrutare</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .report-container {
            padding: 20px;
        }
        
        .filter-section {
            background: #f5f5f5;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .filter-form {
            display: flex;
            gap: 20px;
            align-items: flex-end;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-group input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .btn-filter {
            background: #3498db;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 4px;
            cursor: pointer;
        }
        
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .metric-card {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .metric-value {
            font-size: 24px;
            font-weight: bold;
            color: #2c3e50;
        }
        
        .metric-label {
            color: #7f8c8d;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .chart-section {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .table-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            overflow-x: auto;
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .data-table th,
        .data-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .data-table th {
            background: #f8f9fa;
            font-weight: bold;
        }
        
        .export-buttons {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        
        .btn-export {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            color: white;
        }
        
        .btn-pdf {
            background: #e74c3c;
        }
        
        .btn-excel {
            background: #2ecc71;
        }
    </style>
</head>
<body class="bg">
   
        <div class="report-container">
            <h1>Raport Recrutare</h1>
            
            <div class="filter-section">
                <form action="ReportsServlet" method="get" class="filter-form">
                    <input type="hidden" name="type" value="recruitment">
                    <div class="form-group">
                        <label for="startDate">Data început:</label>
                        <input type="date" id="startDate" name="startDate" value="${startDate}">
                    </div>
                    <div class="form-group">
                        <label for="endDate">Data sfârșit:</label>
                        <input type="date" id="endDate" name="endDate" value="${endDate}">
                    </div>
                    <button type="submit" class="btn-filter">Filtrează</button>
                </form>
            </div>
            
            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-value">${reportData.totalApplications}</div>
                    <div class="metric-label">Total Aplicări</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        <fmt:formatNumber value="${reportData.conversionRate.applicationToInterview}" 
                                        pattern="#.##"/>%
                    </div>
                    <div class="metric-label">Aplicări → Interviuri</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        <fmt:formatNumber value="${reportData.conversionRate.interviewToHire}" 
                                        pattern="#.##"/>%
                    </div>
                    <div class="metric-label">Interviuri → Angajări</div>
                </div>
                <div class="metric-card">
                    <div class="metric-value">
                        <fmt:formatNumber value="${reportData.avgProcessingTime}" 
                                        pattern="#.#"/> zile
                    </div>
                    <div class="metric-label">Timp Mediu Procesare</div>
                </div>
            </div>
            
            <div class="chart-section">
                <h2>Aplicări pe Job</h2>
                <canvas id="applicationsChart"></canvas>
            </div>
            
            <div class="table-container">
                <h2>Top Joburi după Aplicări</h2>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Titlu Job</th>
                            <th>Număr Aplicări</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="job" items="${reportData.applicationsByJob}">
                            <tr>
                                <td>${job.title}</td>
                                <td>${job.count}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            
            <div class="export-buttons">
                <a href="ReportsServlet?type=recruitment&export=pdf&startDate=${startDate}&endDate=${endDate}" 
                   class="btn-export btn-pdf">Export PDF</a>
                <a href="ReportsServlet?type=recruitment&export=excel&startDate=${startDate}&endDate=${endDate}" 
                   class="btn-export btn-excel">Export Excel</a>
            </div>
        </div>
   
    
    <script>
    const ctx = document.getElementById('applicationsChart').getContext('2d');
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: [<c:forEach items="${reportData.applicationsByJob}" var="job" varStatus="status">
                        '${job.title}'<c:if test="${!status.last}">,</c:if>
                    </c:forEach>],
            datasets: [{
                label: 'Număr Aplicări',
                data: [<c:forEach items="${reportData.applicationsByJob}" var="job" varStatus="status">
                        ${job.count}<c:if test="${!status.last}">,</c:if>
                      </c:forEach>],
                backgroundColor: '#3498db'
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    </script>
    <script src="js/core2.js"></script>
</body>
</html>

<%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
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