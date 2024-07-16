<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
    <title>Stergere utilizator</title>
</head>
<body>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, currentUser.getUsername());
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userType = rs.getInt("tip");
                if (userType != 4) {
                    response.sendRedirect(userType == 3 ? "sefok.jsp" : userType == 2 ? "tip2ok.jsp" : "tip1ok.jsp");
                } else {
                    out.println("<div class=\"container\">");
                    out.println("<div class=\"login__content\">");
                    out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login.jpg\" alt=\"login image\" class=\"login__img login__img-light\">");
                    out.println("<img src=\"./responsive-login-form-main/assets/img/bg-login-dark.jpg\" alt=\"login image\" class=\"login__img login__img-dark\">");
                   // out.println("<div align='center'>");
                    out.println("<h1>Selectati utilizatorul pe care doriti sa il stergeti</h1>");
                    out.print("<form action='");
                    out.print(request.getContextPath() + "/delusr");
                    out.println("' method='post' class='login__form'>");
                    out.println("<table style='width: 80%'>");
                    out.println("<tr><td>Utilizator (Nume, Prenume, Username)</td><td><select name='id' class='login__input'>");

                    try (PreparedStatement stm = connection.prepareStatement("SELECT id, nume, prenume, username FROM useri")) {
                        ResultSet rs1 = stm.executeQuery();
                        while (rs1.next()) {
                            int id = rs1.getInt("id");
                            String nume = rs1.getString("nume");
                            String prenume = rs1.getString("prenume");
                            String username = rs1.getString("username");
                            out.println("<option value='" + id + "'>" + nume + " " + prenume + " (" + username + ")</option>");
                        }
                    }
                    out.println("</select></td></tr>");
                    out.println("</table>");
                    if (userType == 0) {
                        out.println("<a href ='dashboard.jsp' class='login__forgot'>Inapoi</a>");
                     }
                     if (userType == 1) {
                         out.println("<a href ='tip1ok.jsp' class='login__forgot'>Inapoi</a>");
                      }
                     if (userType == 2) {
                         out.println("<a href ='tip2ok.jsp' class='login__forgot'>Inapoi</a>");
                      }
                     if (userType == 3) {
                         out.println("<a href ='sefok.jsp' class='login__forgot'>Inapoi</a>");
                      }
                     if (userType == 4) {
                         out.println("<a href ='adminok.jsp' class='login__forgot'>Inapoi</a>");
                      }
                    out.println("<div class=\"login__buttons\">");
                    out.println("<input style=\"margin:0; top:-10px;\" type=\"submit\" value=\"Sterge\" class=\"login__button login__button-ghost\">");
                out.print("</div>");
                     out.println("</form>");
                     out.println("</div>");
                    out.println("</div>");
                    out.println("</div>");
                }
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
            }
        } 
        catch (Exception e) {
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
