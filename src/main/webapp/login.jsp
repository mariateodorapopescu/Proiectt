<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
 pageEncoding="ISO-8859-1"%>
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
  <form action="<%=request.getContextPath()%>/login" method="post">
   <table style="with: 100%">
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
  <% out.println("<a href='signin.jsp'>Am uitat parola - cnp - tobeto</a>"); %>
  <%
if ("true".equals(request.getParameter("logout"))) {
    out.print("Deconectare cu succes.");
}
%>
  <%
if ("true".equals(request.getParameter("wup"))) {
    out.print("Nume de utilizator sau parola gresite.");
}
%>
  <form name="postForm" action="dashboard.jsp" method="POST" style="display:none;">
        <input type="hidden" name="username" value="${param.username}">
    </form>
 </div>
</body>
</html>