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
    <style>
    .container {
        position: fixed;
        top: 1rem;
        left: 28%;
        border-radius: 2rem;
        background: <%=clr%>;
    }
    .login__content {
        overflow: auto;
        position: fixed;
        top: 1rem;
        height: 100vh;
        border-radius: 2rem;
        background:  <%=clr%>;
    }
    .login__form {
        overflow: auto;
        position: fixed;
        top: 6rem;
        border-radius: 2rem;
        background:  <%=sidebar%>;
        border-color: <%=sidebar%>;
    }
    .login__title {
        color: <%=accent%>;
    }
    .login__label, .login__input, .login__forgot {
        color: <%=text%>;
    }
    .login__button {
        box-shadow: 0 6px 24px <%=accent%>;
        background: <%=accent%>;
    }
</style>
    
</head>
<body style="background: <%=clr%>; position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0 1rem; margin: 0;">
<div class="container">
<div class="login__content">
    <form class="login__form" action="UploadImageServlet" enctype="multipart/form-data" method='post'>
        <h3 class='login__title'>Modificare imagine de profil</h3>
        <div class='login__inputs'>
            <label for="imageUpload" class='login__label'>Imagine JPG/JPEG</label>
            <input style="border-color: <%=sidebar%>; background: <%=sidebar%>" id="imageUpload" type="file" name="image" required class='login__input'>
        </div>
        <a href='adminok.jsp' style="color: <%=accent%>" class='login__forgot'>Inapoi</a>
        <div class='login__buttons'>
            <input type="submit" value="Modificare" class="login__button">
        </div>
    </form>
</div>
</div>
<%
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
