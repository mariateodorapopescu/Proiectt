<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Vizualizare concediu</title>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    
                    // Allow only non-admin users to access this page
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }

                    out.println("<div align='center'>");
                    out.println("<h1>Vizualizare concediu</h1>");
                    out.print("<form action='");
                    out.print(request.getContextPath());
                    out.println("/viewconpts.jsp' method='post'>");
                    out.println("<table style='width: 80%'>");
                    out.println("<tr>");
                    out.println("<td>Inceput</td>");
                    out.println("<td><input type='date' id='start' name='start' min='1954-01-01' max='2036-12-31'/></td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Final</td>");
                    out.println("<td><input type='date' id='end' name='end' min='1954-01-01' max='2036-12-31'/></td>");
                    out.println("</tr>");
                    //out.println("<tr>");
                    //out.println("<td>Tot anul</td>");
                    //out.println("<td><input type='checkbox' name='an'/></td>");
                    //out.println("</tr>");
                   
                    // Hidden input to carry user ID forward
                    out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    out.println("</div>");
                    if (userType >= 0 && userType <= 3) {
                        out.println("<a href ='dashboard.jsp'>Inapoi</a>");
                    }
                } else {
                	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");out.println("Nu exista date.");
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
