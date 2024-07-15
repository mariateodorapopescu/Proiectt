<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Login</title>
<script type="text/javascript">
    function submitForm() {
        document.getElementById("postLogin").submit();
    }
</script>
</head>
<body>
<div align="center">
    <h1>Login</h1>
    <form action="<%= request.getContextPath() %>/login" method="post">
        <table style="width: 100%">
            <tr>
                <td>UserName</td>
                <td><input type="text" name="username" required/></td>
            </tr>
            <tr>
                <td>Password</td>
                <td><input type="password" name="password" required/></td>
            </tr>
        </table>
        <input type="submit" value="Submit" />
    </form>

    <% 
    String loginAttempts = request.getParameter("loginAttempts");
    if (loginAttempts != null && Integer.parseInt(loginAttempts) >= 1) {
        out.println("<a href='forgotpass.jsp'>Am uitat parola</a>");
    }

    String logout = request.getParameter("logout");
    if ("true".equals(logout)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Deconectare efectuata cu succes!');");
        out.println("</script>");
    }

    String wup = request.getParameter("wup");
    if ("true".equals(wup)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Nume de utilizator sau parola gresite!');");
        out.println("</script>");
    }

    String rp = request.getParameter("rp");
    if ("true".equals(rp)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Puteti modifica parola oricand!');");
        out.println("</script>");
    }
    
    %>

    <form name="postForm" action="dashboard.jsp" method="POST" style="display:none;">
        <input type="hidden" name="username" value="${param.username}">
    </form>
</div>
</body>
</html>
