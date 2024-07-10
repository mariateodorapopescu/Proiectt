<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.*, java.util.*" %>
<%@ page import="bean.UserData" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>...</title>
</head>
<body>
 <p>${sessionScope.currentUser.username}</p>
 <h1><%
    HttpSession ses = request.getSession(false);

    if (ses != null) {
        MyUser currentUser = (MyUser) ses.getAttribute("currentUser");

        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
       	 try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    PreparedStatement preparedStatement = connection.prepareStatement("select tip from useri where username = ?")) {
                   preparedStatement.setString(1, username);
       	ResultSet rs = preparedStatement.executeQuery();
       	if(rs.next()==false)
       	{
       	  out.println("No Records in the table");
       	}
       	else {
       		String tip = rs.getString("tip");
       		if (tip.compareTo("0")==0) {
       			// daca este administrator 
       			%>
       		 <form name="hiddenForm" action="dashboard.jsp" method="POST">
             <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
             <script>
                 document.hiddenForm.submit(); // Automatically submit the form
             </script>
         </form><%        		
         }
       		if (tip.compareTo("1")==0) {
       			// daca este administrator 
       			%>
       		 <form name="hiddenForm" action="tip1ok.jsp" method="POST">
             <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
             <script>
                 document.hiddenForm.submit(); // Automatically submit the form
             </script>
         </form><%        		
         }
       		if (tip.compareTo("2")==0) {
       			// daca este administrator 
       			%>
       		 <form name="hiddenForm" action="tip2ok.jsp" method="POST">
             <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
             <script>
                 document.hiddenForm.submit(); // Automatically submit the form
             </script>
         </form><%        		
         }
       		if (tip.compareTo("3")==0) {
       			// daca este administrator 
       			%>
       		 <form name="hiddenForm" action="sefok.jsp" method="POST">
             <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
             <script>
                 document.hiddenForm.submit(); // Automatically submit the form
             </script>
         </form><%        		
         }
       		if (tip.compareTo("4")==0) {
       			// daca este administrator 
       			%>
       		 <form name="hiddenForm" action="adminok.jsp" method="POST">
             <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
             <script>
                 document.hiddenForm.submit(); // Automatically submit the form
             </script>
         </form><%        		
         }
       	}
       	 }
        }
       	  else {
            out.print("Guest");
        }
    } else {
        out.print("Session not found");
    }
    %></h1>
 <form name="hiddenForm" action="dashboard.jsp" method="POST">
        <input type="hidden" name="username" value="${sessionScope.currentUser.username}">
        <script>
            document.hiddenForm.submit(); // Automatically submit the form
        </script>
    </form>
</body>
</html>
