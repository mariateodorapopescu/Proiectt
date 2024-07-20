<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.io.*" %>  
<%@ page import="java.util.*" %>  
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Test</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar2.css">
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
</head>
<body>
<div class="container calendar-container">
    <div class="navigation">
        <button onclick="previousMonth()">❮</button>
        <div class="month-year" id="monthYear"></div>
        <button onclick="nextMonth()">❯</button>
    </div>
    <table class="calendar" id="calendar">
        <thead>
            <tr>
                <th class="calendar">Lu.</th>
                <th class="calendar">Ma.</th>
                <th class="calendar">Mi.</th>
                <th class="calendar">Jo.</th>
                <th class="calendar">Vi.</th>
                <th class="calendar">Sâ.</th>
                <th class="calendar">Du.</th>
            </tr>
        </thead>
        <tbody class="calendar" id="calendar-body">
            <!-- Calendar will be generated here -->
        </tbody>
    </table>
</div>
<form id="dateForm" action="testviewpers.jsp" method="post" style="display:none;">
    <input type="date" name="selectedDate" id="selectedDate">
</form>
<script src="./responsive-login-form-main/assets/js/calendar2.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', (event) => {
        // Add event listener for all calendar cells
        document.getElementById('calendar-body').addEventListener('click', function(e) {
            if (e.target && e.target.nodeName === 'TD') {
                let selectedDate = e.target.getAttribute('data-date');
                if (selectedDate) {
                    document.getElementById('selectedDate').value = selectedDate;
                    document.getElementById('dateForm').submit();
                }
            }
        });
    });
</script>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip, zileramase, conramase FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userType = rs.getInt("tip");
                // Allow only non-admin users to access this page
                if (userType == 4) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }
                String data = request.getParameter("selectedDate");
                String nume = null, prenume = null, fullnume = null;
                ArrayList<String> persoane = new ArrayList<String>();  
                if (data != null && !data.isEmpty()) {
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume FROM useri JOIN concedii ON useri.id = concedii.id_ang WHERE start_c <= ? AND end_c >= ?")) {
                        stmt.setString(1, data);
                        stmt.setString(2, data);
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            nume = rs1.getString("nume");
                            prenume = rs1.getString("prenume");
                            fullnume = nume + " " + prenume;
                            persoane.add(fullnume);
                        }
                    }
                }
                out.println("<h2>Persoane in concediu pe data de " + data + ":</h2>");
                if (persoane.isEmpty()) {
                    out.println("<p>Nu exista persoane in concediu pe aceasta data.</p>");
                } else {
                    out.println("<ul>");
                    for (String persoana : persoane) {
                        out.println("<li>" + persoana + "</li>");
                    }
                    out.println("</ul>");
                }
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
                out.println("Nu exista date.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la baza de date!');");
            out.println("</script>");
            response.sendRedirect("login.jsp");
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
</body>
</html>
