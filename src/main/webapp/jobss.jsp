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
                if (isAdmin)           { response.sendRedirect("adminok.jsp");  return; }
                if (isUtilizatorNormal){ response.sendRedirect("tip1ok.jsp");   return; }
                if (isSef)             { response.sendRedirect("sefok.jsp");    return; }
                if (isIncepator)       { response.sendRedirect("tip2ok.jsp");   return; }
            }
        }
    } catch (Exception e) {
        out.println("<script>alert('Eroare la baza de date: " + e.getMessage() + "');</script>");
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
    <title>Joburi Disponibile</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container { max-width: 1200px; margin: 40px auto; padding: 0 20px; font-family: Arial, sans-serif; }
        h1 { margin-bottom: 20px; }
        .filter-section { margin: 20px 0; padding: 20px; background: #f5f5f5; border-radius: 8px; }
        .filter-section input,
        .filter-section select,
        .filter-section button { padding: 8px; margin-right: 10px; }
        .job-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; padding-bottom: 40px; }
        .job-card { border: 1px solid #ddd; border-radius: 8px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); transition: transform 0.2s; }
        .job-card:hover { transform: translateY(-5px); }
        .job-title { font-size: 1.5em; margin-bottom: 10px; color: #333; }
        .job-info { margin-bottom: 10px; }
        .apply-button { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; }
        .apply-button:hover { background-color: #45a049; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Joburi Disponibile</h1>

        <div class="filter-section">
            <form action="JobsServlet" method="get">
                <input type="text" name="search" placeholder="Caută job..." />
                <select name="department">
                    <option value="">Toate departamentele</option>
                    <c:forEach var="dep" items="${departments}">
                        <option value="${dep.id_dep}">${dep.nume_dep}</option>
                    </c:forEach>
                </select>
                <select name="location">
                    <option value="">Toate locațiile</option>
                    <c:forEach var="loc" items="${locations}">
                        <option value="${loc.id_locatie}">${loc.oras}</option>
                    </c:forEach>
                </select>
                <button type="submit">Caută</button>
            </form>
        </div>

        <div class="job-grid">
            <c:forEach var="job" items="${jobs}">
                <div class="job-card">
                    <h2 class="job-title">${job.titlu}</h2>
                    <div class="job-info">
                        <p><strong>Departament:</strong> ${job.nume_dep}</p>
                        <p><strong>Poziție:</strong> ${job.denumire}</p>
                        <p><strong>Locație:</strong> ${job.locatie}</p>
                        <p><strong>Durată:</strong>
                            <fmt:formatDate value="${job.start}" pattern="dd.MM.yyyy"/> —
                            <fmt:formatDate value="${job.end}" pattern="dd.MM.yyyy"/>
                        </p>
                        <p><strong>Tip:</strong> ${job.tip == 1 ? 'Full-time' : 'Part-time'}</p>
                        <p><strong>Ore:</strong> ${job.ore}</p>
                    </div>
                    <a href="JobsServlet?action=detail&id=${job.id}" class="apply-button">Vezi detalii</a>
                </div>
            </c:forEach>
        </div>
    </div>
</body>
</html>
