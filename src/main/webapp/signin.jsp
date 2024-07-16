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
    
    <title>Definire Utilizator</title>
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
%>
    <div class="container">
        <div class="login__content">
            <img src="./responsive-login-form-main/assets/img/bg-login.jpg" alt="login image" class="login__img login__img-light">
            <img src="./responsive-login-form-main/assets/img/bg-login-dark.jpg" alt="login image" class="login__img login__img-dark">

            <form action="<%= request.getContextPath() %>/register" method="post" class="login__form">
            <div>
                        <h1 class="login__title" style="margin:0; top:-10px;">
                            <span style="margin:0; top:-10px;">Definire utilizator nou</span>
                        </h1>
                        
                    </div>
                    <table width="100%" style="margin:0; top:-10px;"> <tr><td>
                <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label for="" class="login__label">Nume</label>
                        <input type="text" name="nume" placeholder="Introduceti numele" required class="login__input">
                    </div>

                    <div>
                        <label for="" class="login__label">Prenume</label>
                        <input type="text" name="prenume" placeholder="Introduceti prenumele" required class="login__input">
                    </div>

                    <div>
                        <label for="" class="login__label">Data nasterii</label>
                        <input type="date" name="data_nasterii" value="2001-07-22" min="1954-01-01" max="2036-12-31" required class="login__input">
                    </div>

                    <div>
                        <label for="" class="login__label">Adresa</label>
                        <input type="text" name="adresa" placeholder="Introduceti adresa" required class="login__input">
                    </div>
                    
                    <div>
                        <label for="" class="login__label">E-mail</label>
                        <input type="text" name="email" placeholder="Introduceti e-mailul" required class="login__input">
                    </div>

                    
                </div></td>
                
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                
                <td>
                <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label for="" class="login__label">UserName</label>
                        <input type="text" name="username" placeholder="Introduceti numele de utilizator" required class="login__input">
                    </div>

                    <div>
                        <label for="" class="login__label">Password</label>
                        <input type="password" name="password" placeholder="Introduceti parola" required class="login__input">
                    </div>
               
                    <div>
                        <label for="" class="login__label">Departament</label>
                        <select name="departament" class="login__input">
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT id_dep, nume_dep FROM departament;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs1 = stmt.executeQuery();

                                if (!rs1.next()) {
                                    out.println("No Records in the table");
                                } else {
                                    do {
                                        out.println("<option value='" + rs1.getString("id_dep") + "' required>" + rs1.getString("nume_dep") + "</option>");
                                    } while (rs1.next());
                                }
                                rs1.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>

                    <div>
                        <label for="" class="login__label">Tip/Ierarhie</label>
                        <select name="tip" class="login__input">
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "select tip, denumire from tipuri;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs2 = stmt.executeQuery();
                                if (rs2.next() == false) {
                                    out.println("No Records in the table");
                                } else {
                                    do {
                                        out.println("<option value='" + rs2.getString("tip") + "' required>" + rs2.getString("denumire") + "</option>");
                                    } while (rs2.next());
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>
                    <div>
                        <label for="" class="login__label">Telefon</label>
                        <input type="text" name="telefon" placeholder="Introduceti telefonul" required class="login__input">
                    </div>
                    
                </div>
                </td></tr>
</table>
 <a href="adminok.jsp" class="login__forgot" style="margin:0; top:-10px;">Inapoi</a>
                <div class="login__buttons">
                    <input style="margin:0; top:-10px;"
                    type="submit" value="Submit" class="login__button login__button-ghost">
                </div>
                
            </form>

           
        </div>
    </div>

    <% 
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

    if ("true".equals(request.getParameter("n"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("pn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Prenume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("t"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Telefon scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("e"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('E-mail scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("dn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Utilizatorul trebuie sa aiba minim 18 ani!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pms"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un sef / departament!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pmd"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un director / departament!');");
        out.println("</script>");
    }   
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
