<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int id = rs.getInt("id");
                int userType = rs.getInt("tip");
                int userdep = rs.getInt("id_dep");
                if (userType == 4) {  // Assuming only type 4 users can approve
                	
                	String accent = null;
                 	 String clr = null;
                 	 String sidebar = null;
                 	 String text = null;
                 	 String card = null;
                 	 String hover = null;
                 	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        // Check for upcoming leaves in 3 days
                        String query = "SELECT * from teme where id_usr = ?";
                        try (PreparedStatement stmt = connection.prepareStatement(query)) {
                            stmt.setInt(1, id);
                            try (ResultSet rs2 = stmt.executeQuery()) {
                                if (rs2.next()) {
                                  accent =  rs2.getString("accent");
                                  clr =  rs2.getString("clr");
                                  sidebar =  rs2.getString("sidebar");
                                  text = rs2.getString("text");
                                  card =  rs2.getString("card");
                                  hover = rs2.getString("hover");
                                }
                            }
                        }
                        // Display the user dashboard or related information
                        //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                        // Add additional user-specific content here
                    } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
                 	 
    %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
      <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <title>Modificare parola</title>
</head>
<body>
<%
                    		   int userId = Integer.parseInt(request.getParameter("idd"));
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
                          
                } else {
                	switch (userType) {
                    case 1: response.sendRedirect("tip1ok.jsp"); break;
                    case 2: response.sendRedirect("tip1ok.jsp"); break;
                    case 3: response.sendRedirect("sefok.jsp"); break;
                    case 0: response.sendRedirect("dashboard.jsp"); break;
                }
                }
            } else {
            	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
                response.sendRedirect("modifdel.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script type='text/javascript'>");
	        out.println("alert('Eroare la baza de date!');");
	       
	        out.println("</script>");
            response.sendRedirect("modifdel.jsp");
        }
    } else {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Utilizator neconectat!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
} else {
	out.println("<script type='text/javascript'>");
    out.println("alert('Nu e nicio sesiune activa!');");
    out.println("</script>");
    response.sendRedirect("logout");
}
%>
</body>
</html>
