<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Resetare parola</title>
</head>
<body>
<%
    HttpSession sess = request.getSession(false); // Make sure you have the correct import for HttpSession
    if (sess != null) {
        String username = (String) sess.getAttribute("username"); // Assuming username is stored in session
        
        // Check if the username is actually retrieved from the session
        if (username != null && !username.isEmpty()) {
            out.println("<div align='center'>");
            out.println("<h1>Introduceti codul personal primit la angajare</h1>");
            out.print("<form action='" + request.getContextPath() + "/modifpasd2.jsp' method='post'>");
            out.println("<table style='width: 80%'>");
            out.println("<tr><td>ID unic</td><td><input type='text' name='cnp' required></td></tr>");
            out.println("</table>");
            out.println("<input type='submit' value='Submit' />");
            out.println("</form>");
            out.println("</div>");
            out.println("<a href='login.jsp'>Inapoi</a>");
        } else {
            // If username is not in session, redirect to login
        	out.println("<div align='center'>");
            out.println("<h1>Introduceti codul personal primit la angajare</h1>");
            out.print("<form action='" + request.getContextPath() + "/modifpasd2.jsp' method='post'>");
            out.println("<table style='width: 80%'>");
            out.println("<tr><td>ID unic</td><td><input type='text' name='cnp' required></td></tr>");
            out.println("</table>");
            out.println("<input type='submit' value='Submit' />");
            out.println("</form>");
            out.println("</div>");
            out.println("<a href='login.jsp'>Inapoi</a>");
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
