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
    <title>Gestionare Aplicări - HR</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; font-family: Arial, sans-serif; }
        h1 { margin-bottom: 20px; }
        .applications-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .applications-table th, .applications-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        .applications-table th { background-color: #f5f5f5; }
        .action-buttons { display: flex; gap: 10px; }
        .btn { padding: 6px 12px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; text-decoration: none; }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-success { background-color: #28a745; color: white; }
        .btn-danger { background-color: #dc3545; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gestionare Aplicări</h1>
        <table class="applications-table">
            <thead>
                <tr>
                    <th>Candidat</th>
                    <th>Job</th>
                    <th>Departament</th>
                    <th>Data aplicării</th>
                    <th>Contact</th>
                    <th>Acțiuni</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="app" items="${applications}">
                    <tr>
                        <td>${app.nume} ${app.prenume}</td>
                        <td>${app.titlu}</td>
                        <td>${app.nume_dep}</td>
                        <td>
                            <fmt:formatDate value="${app.data_apl}" pattern="dd.MM.yyyy"/>
                        </td>
                        <td>
                            ${app.email}<br/>
                            ${app.telefon}
                        </td>
                        <td>
                            <div class="action-buttons">
                                <a href="ViewCVServlet?id=${app.id_ang}" class="btn btn-primary">Vezi CV</a>
                                <a href="ScheduleInterviewServlet?app_id=${app.id}" class="btn btn-success">Programează interviu</a>
                                <a href="RejectApplicationServlet?app_id=${app.id}" class="btn btn-danger">Respinge</a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</body>
</html>
