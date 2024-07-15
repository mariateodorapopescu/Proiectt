<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<html>
<head>
    <title>Modificare parola</title>
</head>
<body>
<%
    HttpSession sessi = request.getSession(false);
    if (sessi != null) {
        String username = (String) sessi.getAttribute("username"); // Check if the username is stored in session
        if (username != null) {
            int userId = Integer.parseInt(request.getParameter("id"));
            String cnpp = request.getParameter("cnp");
            System.out.println(cnpp);
            int cnp = Integer.valueOf(request.getParameter("cnp")); // The CNP should have been verified before reaching this page
            System.out.println(cnp);
            if (userId != 0) {
            	  // Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                  try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE id = ?")) {
                       preparedStatement.setInt(1, userId);
                       ResultSet rs = preparedStatement.executeQuery();
                       if (rs.next()) {
                           out.println("<div align='center'>");
                           out.println("<h1>Modificare parola</h1>");
                           out.println("<form action='" + request.getContextPath() + "/ModifPasdServlet' method='post'>");
                           out.println("<input type='hidden' name='id' value='" + userId + "' />");
                           out.println("<table style='width: 80%'>");
                           out.println("<tr><td>Parola noua</td><td><input type='password' name='password' required /></td></tr>");
                           out.println("<tr><td><input type='submit' value='Submit' /></td></tr>");
                           out.println("</table>");
                           out.println("</form>");
                           out.println("</div>");
                           out.println("<a href ='login.jsp'>Inapoi</a>");
                           if ("true".equals(request.getParameter("p"))) {
                          	 out.println("<script type='text/javascript'>");
                   	        out.println("alert('Trebuie sa alegeti o parola mai complexa!');");
                   	        out.println("</script>");
                          	    out.println("<br>Parola trebuie sa contina:<br>");
                          	    out.println("- minim 8 caractere<br>");
                          	    out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
                          	    out.println("- o litera mare<br>");
                          	    out.println("- o litera mica<br>");
                          	    out.println("- o cifra<br>");
                          	    out.println("- cifrele alaturate sa nu fie egale sau consecutive<br>");
                          	    out.println("- literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele");
                          	}
                       } else {
                    	   out.println("<script type='text/javascript'>");
                           out.println("alert('Date introduse incorect sau nu exista date!');");
                           out.println("</script>");
                       }
                   } catch (SQLException e) {
                       e.printStackTrace();
                       out.println("<script type='text/javascript'>");
                       out.println("alert('Nu a extras tipul de la utilizatorul curent???!');");
                       out.println("</script>");
                       response.sendRedirect("login.jsp");
                   }
            } 
        } else {
        	
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        		int cnp = Integer.valueOf(request.getParameter("cnp")); 
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                     PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                    preparedStatement.setInt(1, cnp);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                        out.println("<div align='center'>");
                        out.println("<h1>Modificare parola</h1>");
                        out.println("<form action='" + request.getContextPath() + "/ModifPasdServlet' method='post'>");
                        out.println("<input type='hidden' name='id' value='" + rs.getInt("id") + "' />");
                        out.println("<table style='width: 80%'>");
                        out.println("<tr><td>Parola noua</td><td><input type='password' name='password' required /></td></tr>");
                        out.println("<tr><td><input type='submit' value='Submit' /></td></tr>");
                        out.println("</table>");
                        out.println("</form>");
                        out.println("</div>");
                        out.println("<a href ='login.jsp'>Inapoi</a>");
                        if ("true".equals(request.getParameter("p"))) {
                       	 out.println("<script type='text/javascript'>");
                	        out.println("alert('Trebuie sa alegeti o parola mai complexa!');");
                	        out.println("</script>");
                       	    out.println("<br>Parola trebuie sa contina:<br>");
                       	    out.println("- minim 8 caractere<br>");
                       	    out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
                       	    out.println("- o litera mare<br>");
                       	    out.println("- o litera mica<br>");
                       	    out.println("- o cifra<br>");
                       	    out.println("- cifrele alaturate sa nu fie egale sau consecutive<br>");
                       	    out.println("- literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele");
                       	}
                    } else {
                    	 out.println("<script type='text/javascript'>");
                         out.println("alert('Date introduse incorect sau nu exista date!');");
                         out.println("</script>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu a extras tipul de la utilizatorul cu codul dat cred!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
            
        }
    } else {
    	 out.println("<script type='text/javascript'>");
         out.println("alert('Nu exista nicio sesiune activa!');");
         out.println("</script>");
        response.sendRedirect("login.jsp");
    }
%>
</body>
</html>
