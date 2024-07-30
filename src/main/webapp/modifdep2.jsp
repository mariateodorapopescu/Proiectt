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
            int id = -1;
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume, id from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next() == false) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("4") != 0) {
                        if (rs.getString("tip").compareTo("1") == 0) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("0") == 0) {
                            response.sendRedirect("dashboard.jsp");
                        }
                    } else {
                    	id = rs.getInt("id");
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
    
    <title>Modificare departament</title>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

<div class="container" >
        <div class="login__content" style="border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
    <%
                        out.print("<form style=\"border-radius: 2rem; border-color: " + sidebar + "; background: " + sidebar + "; color: " + text + "\" class=\"login__form\" action=\"");
                        request.getContextPath();
                        out.println("ModifDepServlet\" method=\"post\" class=\"login__form\">");
                        %>
                         <div>
                        <h1 class="login__title" style="margin:0; top:-10px;">
                            <span style="margin:0; top:-10px; color: <% out.println(accent);%>">Modificare departament</span>
                        </h1>
                        
                    </div>
                        <%
                        out.println("<table style=\"with: 80%\"><tr><td>");
                        %>
                         <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Nume departament</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="password" placeholder="Introduceti numele" required class="login__input">
                    </div>
                        <%
                        
                        out.println("</div></td>");
                        out.println("</tr>");
                        out.println("</table>");
                        out.println("<a style=\"color: " + accent + "\" href ='viewdep2.jsp' class='login__forgot''>Inapoi</a>");
                        // out.println("<input type='submit' value='Submit' class='login_button login_button-ghost' />");
                        // out.println("<button class='login_forgot'><a href ='adminok.jsp' class='login_forgot'>Inapoi</a></button>");
                        out.println("<input type='hidden' name='username' value='" + request.getParameter("username") + "' />");
                       %>
                        <div class="login__buttons">
                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button">
                </div>
                       <%
                        out.println("</form>");
                        out.println("</div>");                      
                        out.println("</div>");
                        out.println("</div>");
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                
                out.println("</script>");
                if ("true".equals(request.getParameter("n"))) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nume scris incorect!');");
                    out.println("</script>");
                }
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
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
<% 
   
    if ("true".equals(request.getParameter("n"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nume scris incorect!');");
        out.println("</script>");
    }

  
%>
</body>
</html>