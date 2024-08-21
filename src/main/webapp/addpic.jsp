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
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (!rs.next()) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
            } else {
                int userType = rs.getInt("tip");
                int userdep = rs.getInt("id_dep");
                int id = rs.getInt("id");
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
                   
               } catch (SQLException e) {
                   out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                   e.printStackTrace();
               } %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
      <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <title>Schimbare imagine de profil</title>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --text:<%out.println(text);%>; --sd:<%out.println(sidebar);%>">
<%
                    out.println("<div style=\"background:" + sidebar + "\" class=\"container\">");
                    out.println("<div style=\"border-radius: 2rem; background:" +  clr + "\" class=\"login__content\">");
                    out.println("<form style=\"border-color: " + accent + "; border-radius: 2rem; background:" + sidebar + "\" action=\"UploadImageServlet\" enctype=\"multipart/form-data\" method='post' class='login__form'>");
                    out.println("<h3 style=\"color:" + accent + "\" class='login__title'>Modificare imagine de profil</h3>");
                    out.println("<div class='login__inputs'>");
                    out.println("<div>");
                    out.println("<label style=\"color:" + text + "\" for='' class='login__label'>Imagine JPG/JPEG</label>");
                    out.println("<input style=\"color:" + text + "\" type=\"file\" name=\"image\" required>");
                    out.println("</div>");
                    out.println("</div>");
                    out.println("<a style=\"color:" + accent + "\" href ='adminok.jsp' class='login__forgot''>Inapoi</a>");
                    out.println("<div class='login__buttons'>");
                    // out.println("<input type='submit' value='Submit' class='login__button' />");
                    %> <input style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" type="submit" value="Modificare" class="login__button"> <%
                    out.println("</div>");
                    out.println("</form>");
                    out.println("</div>");
                    out.println("</div>");
                }
            
        } catch (Exception e) {
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la baza de date!');");
            out.println("alert('" + e.getMessage() + "');");
            out.println("</script>");
            e.printStackTrace();
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
