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
    
      <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <title>Modificare Utilizator</title>
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
                    //out.println("<div align='center'>");
%>
    <div class="container">
        <div class="login__content">
            <img src="./responsive-login-form-main/assets/img/bg-login.jpg" alt="login image" class="login__img login__img-light">
            <img src="./responsive-login-form-main/assets/img/bg-login-dark.jpg" alt="login image" class="login__img login__img-dark">

            <form action="<%= request.getContextPath() %>/modifusr2.jsp" method="post" class="login__form">
                <div>
                    <h1 class="login__title">
                        <span>Modificare Utilizator</span>
                    </h1>
                </div>
                
                <div class="form__section">
                    <label for="id" class="login__label">Utilizator (Nume, Prenume, Username)</label>
                    <select name="id" class="login__input">
                        <%
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
                        %>
                    </select>
                </div>
<a href="adminok.jsp" class="login__forgot">Inapoi</a>
                <div class="login__buttons">
                    <input type="submit" value="Submit" class="login__button login__button-ghost">
                </div>
                 
            </form>

           
        </div>
    </div>
<%
                    out.println("</div>");
                }
            } else {
            	 out.println("<script type='text/javascript'>");
                 out.println("alert('Nu a extras tipul de la utilizatorul curent?!');");
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
