<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
    <title>Modificare parola</title>
</head>
<body>
<%
    HttpSession sessi = request.getSession(false);
    if (sessi != null) {
        String username = (String) sessi.getAttribute("username"); // Check if the username is stored in session
        if (username != null) {
            int userId = Integer.parseInt(request.getParameter("id"));
            if (userId != 0) {
            	  // Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            	  int tip = -1;
                  try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE id = ?")) {
                       preparedStatement.setInt(1, userId);
                       ResultSet rs = preparedStatement.executeQuery();
                       if (rs.next()) {
                    	   tip = Integer.valueOf(rs.getInt("tip"));
                    	   if (tip == 4) {
                    		   out.println("<div class=\"container\">");
                    		   out.println("<div class=\"login__content\">");
                    		   out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login.jpg\" alt=\"login image\" class=\"login__img login__img-light\">");
                    		   out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login-dark.jpg\" alt=\"login image\" class=\"login__img login__img-dark\">");
                               out.println("<div align='center'>");
                               out.println("<h1>Modificare parola</h1>");
                               out.println("<form action='" + request.getContextPath() + "/ModifPasdServlet' method='post' class='login__form'>");
                               out.println("<input type='hidden' name='id' value='" + userId + "' />");
                               out.println("<table style='width: 80%'>");
                               out.println("<tr><td>Parola noua</td><td><input type='password' name='password' required class='login__input'/></td></tr>");
                               out.println("<tr><td><input type='submit' value='Submit' class='login__button login__button-ghost'/></td></tr>");
                               out.println("</table>");
                               out.println("</form>");
                               out.println("</div>");
                               out.println("<a href ='login.jsp' class='login__forgot'>Inapoi</a>");
                               out.println("</div>");
                               out.println("</div>");
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
        	try {
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        		int cnp = Integer.valueOf(request.getParameter("cnp")); 
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                     PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                    preparedStatement.setInt(1, cnp);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                        out.println("<div class=\"container\">");
                        out.println("<div class=\"login__content\">");
                        out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login.jpg\" alt=\"login image\" class=\"login__img login__img-light\">");
                        out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login-dark.jpg\" alt=\"login image\" class=\"login__img login__img-dark\">");
                        out.println("<div align='center'>");
                        out.println("<h1>Modificare parola</h1>");
                        out.println("<form action='" + request.getContextPath() + "/ModifPasdServlet' method='post' class='login__form'>");
                        out.println("<input type='hidden' name='id' value='" + rs.getInt("id") + "' />");
                        out.println("<table style='width: 80%'>");
                        out.println("<tr><td>Parola noua</td><td><input type='password' name='password' required class='login__input'/></td></tr>");
                        out.println("<tr><td><input type='submit' value='Submit' class='login__button login__button-ghost'/></td></tr>");
                        out.println("</table>");
                        out.println("</form>");
                        out.println("</div>");
                        out.println("<a href ='login.jsp' class='login__forgot'>Inapoi</a>");
                        out.println("</div>");
                        out.println("</div>");
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
        	} catch (NumberFormatException e) {
            	System.out.println("admin");
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
