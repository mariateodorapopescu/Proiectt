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
    
    <title>Dashboard</title>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
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
                        out.println("<div class='container'>");
                        out.println("<div class='login__content'>");
                        out.println("<img src='./responsive-login-form-main/assets/img/bg-login.jpg' alt='login image' class='login__img login__img-light'>");
                        out.println("<img src='./responsive-login-form-main/assets/img/bg-login-dark.jpg' alt='login image' class='login__img login__img-dark'>");
                       
                        out.println("<div class='login__form'>");
                        out.println("<div class='login__inputs'>");
                        out.println("<h1>Bun venit, " + rs.getString("prenume") + "!</h1>");
                        //out.println("<label for='menu' class='login__label'>Meniu</label>");
                        out.println("<select name='menu' id='menu' class='login__input' onchange='location = this.value;'>");
                        out.println("<option value=''>Selecteaza o optiune</option>");
                        out.println("<option value='viewcolegi.jsp'>Vizualizare angajati din toata institutia</option>");
                        out.println("<option value='viewdep.jsp'>Vizualizare departamente din toata institutia</option>");
                        out.println("<option value='signin.jsp'>Adaugare Utilizator nou</option>");
                        out.println("<option value='modifusr1.jsp'>Modificare Utilizator</option>");
                        out.println("<option value='modifpasd.jsp'>Modificare Utilizator - parola</option>");
                        out.println("<option value='delusr1.jsp'>Stergere Utilizator</option>");
                        out.println("<option value='adddep.jsp'>Adaugare departament</option>");
                        out.println("<option value='modifdep.jsp'>Modificare departament</option>");
                        out.println("<option value='deldep.jsp'>Stergere departament</option>");
                        out.println("</select>");
                        out.println("</div>");
                        out.println("<div class='login__buttons'>");
                        out.println("<form action='logout' method='post'><button type='submit' class='login__button login__button-ghost'>Logout</button></form>");
                        out.println("</div>");
                       
                        out.println("</div>");

                       
                        out.println("</div>");
                        out.println("</div>");
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
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
