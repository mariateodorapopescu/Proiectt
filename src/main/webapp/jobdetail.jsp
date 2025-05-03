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
    <title>${job.titlu} - Detalii Job</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; font-family: Arial, sans-serif; }
        .job-detail { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
        .job-header { background: #f5f5f5; padding: 20px; border-radius: 6px; margin-bottom: 20px; }
        .job-section { margin-bottom: 30px; }
        .apply-button { background-color: #4CAF50; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .apply-button:disabled { background-color: #ccc; cursor: not-allowed; }
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 4px; }
        .alert-success { background-color: #dff0d8; color: #3c763d; border: 1px solid #d6e9c6; }
        .alert-error { background-color: #f2dede; color: #a94442; border: 1px solid #ebccd1; }
    </style>
</head>
<body>
    <div class="container">
        <div class="job-detail">
            <c:if test="${not empty success}">
                <div class="alert alert-success">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-error">${error}</div>
            </c:if>

            <div class="job-header">
                <h1>${job.titlu}</h1>
                <p><strong>Departament:</strong> ${job.nume_dep}</p>
                <p><strong>Poziție:</strong> ${job.denumire}</p>
                <p><strong>Locație:</strong> ${job.locatie}</p>
            </div>

            <div class="job-section">
                <h2>Cerințe</h2>
                <p>${job.req}</p>
            </div>

            <div class="job-section">
                <h2>Responsabilități</h2>
                <p>${job.resp}</p>
            </div>

            <div class="job-section">
                <h2>Informații adiționale</h2>
                <p><strong>Domeniu:</strong> ${job.dom}</p>
                <p><strong>Subdomeniu:</strong> ${job.subdom}</p>
                <p><strong>Durată:</strong>
                    <fmt:formatDate value="${job.start}" pattern="dd.MM.yyyy"/> —
                    <fmt:formatDate value="${job.end}" pattern="dd.MM.yyyy"/>
                </p>
                <p><strong>Tip:</strong> ${job.tip == 1 ? 'Full-time' : 'Part-time'}</p>
                <p><strong>Ore:</strong> ${job.ore}</p>
                <p><strong>Keywords:</strong> ${job.keywords}</p>
            </div>

            <div class="job-section">
                <c:choose>
                    <c:when test="${alreadyApplied}">
                        <button class="apply-button" disabled>Ați aplicat deja</button>
                    </c:when>
                    <c:otherwise>
                        <form action="JobsServlet" method="post">
                            <input type="hidden" name="action" value="apply" />
                            <input type="hidden" name="job_id" value="${job.id}" />
                            <button type="submit" class="apply-button">Aplică acum</button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</body>
</html>
