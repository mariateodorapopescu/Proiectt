<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*, javax.servlet.http.*, bean.MyUser" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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

    // === 2) Încarcă driver-ul și preia detalii utilizator ===
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
    <title>Programează Interviu</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .container { max-width: 600px; margin: 30px auto; padding: 0 20px; font-family: Arial, sans-serif; }
        .form-container { background: #f9f9f9; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="time"],
        .form-group textarea,
        .form-group select {
            width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;
        }
        .form-group textarea { height: 100px; resize: vertical; }
        .submit-button { background-color: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
        .submit-button:hover { background-color: #218838; }
        .candidate-info { background: #e9ecef; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Programează Interviu</h1>
        <div class="form-container">
            <div class="candidate-info">
                <h3>Detalii Candidat</h3>
                <p><strong>Nume:</strong> ${application.nume} ${application.prenume}</p>
                <p><strong>Email:</strong> ${application.email}</p>
                <p><strong>Poziție:</strong> ${application.titlu}</p>
            </div>
            <form action="ScheduleInterviewServlet" method="post">
                <input type="hidden" name="app_id" value="${application.id}" />
                <div class="form-group">
                    <label for="interview_date">Data interviu:</label>
                    <input type="date" id="interview_date" name="interview_date" required />
                </div>
                <div class="form-group">
                    <label for="interview_time">Ora interviu:</label>
                    <input type="time" id="interview_time" name="interview_time" required />
                </div>
                <div class="form-group">
                    <label for="location">Locație:</label>
                    <select id="location" name="location" required>
                        <option value="">Selectează locația</option>
                        <option value="Sala de conferințe A">Sala de conferințe A</option>
                        <option value="Sala de conferințe B">Sala de conferințe B</option>
                        <option value="Online - Teams">Online - Teams</option>
                        <option value="Online - Zoom">Online - Zoom</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="notes">Note adiționale:</label>
                    <textarea id="notes" name="notes" placeholder="Adaugă note despre interviu, documente necesare, etc."></textarea>
                </div>
                <button type="submit" class="submit-button">Programează Interviu</button>
            </form>
        </div>
    </div>
</body>
</html>
