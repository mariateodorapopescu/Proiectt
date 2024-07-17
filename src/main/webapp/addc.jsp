<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<!DOCTYPE html>  
<html>  
<head>  
    <title>Adaugare concediu</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

        <!--=============== CSS ===============-->
       <!-- <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css"> --> 
        <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
        
        <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
</head>
<body>
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
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    String zile = rs.getString("zileramase");
                    String con = rs.getString("conramase");
                    
                    // Allow only non-admin users to access this page
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }
                    out.println("<p>Zile ramase: " + zile + "</p>");
                    out.println("<p>Concedii ramase: " + con + "</p><br>");
                    out.println("<div align='center'>");
                    out.println("<h1>Adaugare concediu</h1>");
                    out.print("<form action='");
                    out.print(request.getContextPath());
                    out.println("/addcon' method='post'>");
                    out.println("<table>");
                    out.println("<tr>");
                    out.println("<td>Data de plecare</td>");
                    out.println("<td><input type='date' id='start' name='start' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/></td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Data de intoarcere</td>");
                    out.println("<td><input type='date' id='end' name='end' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/></td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Motiv</td>");
                    out.println("<td><input type='text' name='motiv' required/></td>");
                    out.println("</tr>");
                    out.println("<tr><td>Tip</td>");
                    out.println("<td><select name='tip'>");
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int tip = rs1.getInt("tip");
                            String motiv = rs1.getString("motiv");
                            out.println("<option value='" + tip + "'>" + motiv + "</option>");
                        }
                    }
                    out.println("</select></td></tr>");
                    out.println("<tr>");
                    out.println("<td>Locatie</td>");
                    out.println("<td><input type='text' name='locatie' required/></td>");
                    out.println("</tr>");
                    out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    %>
                    
                    
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
     <!-- <div id="difference">0</div> --> 
</div>
                    
                    <% 
                  
                    out.println("</div>");
                    if (userType >= 0 && userType <= 3) {
                        out.println("<a href='dashboard.jsp'>Inapoi</a>");
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

<script src="./responsive-login-form-main/assets/js/main.js"></script>
<script src="./responsive-login-form-main/assets/js/calendar.js"></script>
</body>
</html>
