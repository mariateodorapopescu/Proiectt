<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Vizualizare angajati dintr-un departament</title>
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
        <!-- Include aici CSS-ul dat -->
        @charset "UTF-8";
        /*=============== GOOGLE FONTS ===============*/
        @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap");
        /* restul CSS-ului pe care l-ai furnizat */
        /* Copiază CSS-ul furnizat aici */
    </style>
    
</head>
<body>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    if (userType != 0) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                            case 4: response.sendRedirect("adminok.jsp"); break;
                        }
                    } else {
                       %>
                       
                       <div class="container">
                            <div class="login__content">
                                <img src="./responsive-login-form-main/assets/img/bg-login.jpg" alt="login image" class="login__img login__img-light">
                                <img src="./responsive-login-form-main/assets/img/bg-login-dark.jpg" alt="login image" class="login__img login__img-dark">
                                
                                <form action="<%= request.getContextPath() %>/viewangdep2.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title"><span>Selectati departamentul pe care doriti sa il vizualizati</span></h1>
                                    </div>
                                    
                                    <div class="login__inputs">
                                        <div>
                                            <label class="login__label">Status</label>
                                            <select name="iddep" class="login__input">
                                                <option value="3">Oricare</option>
                                                <%
                                               

                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                                if (rs1.next()) {
                                    do {
                                        int id = rs1.getInt("id_dep");
                                        String nume = rs1.getString("nume_dep");
                                        out.println("<option value='" + id + "'>" + nume + "</option>");
                                    } while (rs1.next());
                                } else {
                                    out.println("<option value=''>Nu exista departamente disponibile.</option>");
                                }
                            }
                        }

                        out.println("</select></div></div>");
                        out.println("<div class='login__buttons'><input class='login__button' type='submit' value='Submit' /></div>");
                        out.println("</form>");
                        out.println("</div>");
                        out.println("</div>");
                        if (userType == 0) {
                            out.println("<a class='login__forgot' href ='dashboard.jsp'>Inapoi</a>");
                        }
                        if (userType == 1) {
                            out.println("<a class='login__forgot' href ='tip1ok.jsp'>Inapoi</a>");
                        }
                        if (userType == 2) {
                            out.println("<a class='login__forgot' href ='tip2ok.jsp'>Inapoi</a>");
                        }
                        if (userType == 3) {
                            out.println("<a class='login__forgot' href ='sefok.jsp'>Inapoi</a>");
                        }
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
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
