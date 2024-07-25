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
        int userId = -1;
        if (request.getParameter("id") != null) {
        	userId = Integer.parseInt(request.getParameter("id")); 
        }
        // Assuming ID is passed correctly
        try {
        String cnpp = request.getParameter("cnp");
        System.out.println(cnpp);
        int cnp = Integer.valueOf(request.getParameter("cnp")); // The CNP should have been verified before reaching this page
        System.out.println(cnp);
        if (cnp != 0) {
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                preparedStatement.setInt(1, cnp);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	userId = rs.getInt("id");
                }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu a extras tipul de la utilizatorul cu codul dat cred!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
        }
        if (cnpp != null) {
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                preparedStatement.setInt(1, cnp);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	userId = rs.getInt("id");
                }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu a extras tipul de la utilizatorul cu codul dat cred!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
        }
        
        if (userId == 0) {
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                preparedStatement.setInt(1, cnp);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	userId = rs.getInt("id");
                }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu a extras tipul de la utilizatorul cu codul dat cred!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
        }
        if (userId != -1) {
        	Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                preparedStatement.setInt(1, cnp);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	userId = rs.getInt("id");
                }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nu a extras tipul de la utilizatorul cu codul dat cred!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
        }
        
        } catch (NumberFormatException e) {
        	System.out.println("admin");
        }
       
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE id = ?")) {
            preparedStatement.setInt(1, userId);
            ResultSet rs = preparedStatement.executeQuery();

            if (!rs.next()) {
            	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
            } else {
                int userType = rs.getInt("tip");
                if (userType != 5) {
                	out.println("<div class=\"container\">");
                	out.println("    <div class=\"login__content\">");
                	out.println("        <img src=\"./responsive-login-form-main/assets/img/bg-login.jpg\" alt=\"login image\" class=\"login__img login__img-light\">");
                	out.println("        <img src=\"./responsive-login-form-main/assets/img/bg-login-dark.jpg\" alt=\"login image\" class=\"login__img login__img-dark\">");
                	out.println("        <form action=" +  request.getContextPath() + "/modifusr" +" method=\"post\" class=\"login__form\">");
                	out.println("            <div>");
                	out.println("                <h1 class=\"login__title\">");
                	out.println("                    <span>Modificare Utilizator</span>");
                	out.println("                </h1>");
                	out.println("            </div>");
                	out.println("<table width=\"100%\" style=\"margin:0; top:-10px;\"> <tr><td>");
                	out.println("            <div class=\"form__section\" style=\"margin:0; top:-10px;\">");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Nume</label>");
                	out.println("                    <input type=\"text\" name=\"nume\" placeholder=\"Introduceti numele\" value=\"" +  rs.getString("nume") + "\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Prenume</label>");
                	out.println("                    <input type=\"text\" name=\"prenume\" placeholder=\"Introduceti prenumele\" value=\"" +  rs.getString("prenume") + "\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Data nasterii</label>");
                	out.println("                    <input type=\"date\" name=\"data_nasterii\" value=\""+ rs.getDate("data_nasterii") + "\" min=\"1954-01-01\" max=\"2036-12-31\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Adresa</label>");
                	out.println("                    <input type=\"text\" name=\"adresa\" placeholder=\"Introduceti adresa\" value=\""+ rs.getString("adresa") + "\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">E-mail</label>");
                	out.println("                    <input type=\"email\" name=\"email\" placeholder=\"Introduceti e-mailul\" value=\" "+ rs.getString("email") +"\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println(" </div></td> <td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><div class=\"form__section\" style=\"margin:0; top:-10px;\">");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Telefon</label>");
                	out.println("                    <input type=\"text\" name=\"telefon\" placeholder=\"Introduceti telefonul\" value=\""+ rs.getString("telefon") +"\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">UserName</label>");
                	out.println("                    <input type=\"text\" name=\"username\" placeholder=\"Introduceti numele de utilizator\" value=\""+ rs.getString("username") +"\" required class=\"login__input\">");
                	out.println("                </div>");
                	out.println("                <div>");
                	out.println("                    <label for=\"\" class=\"login__label\">Departament</label>");
                	out.println("                    <select name=\"departament\" class=\"login__input\">");

                            String id_dep = null;
                            String den_dep = null;
                            if (userId != 0) {
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                    String sql = "SELECT u.id_dep as id_d, d.nume_dep as den_dep FROM useri u JOIN departament d ON u.id_dep = d.id_dep WHERE id = ?";
                                    PreparedStatement stmt = con.prepareStatement(sql);
                                    stmt.setInt(1, userId);
                                    ResultSet rs7 = stmt.executeQuery();
                                    if (rs7.next()) {
                                        id_dep = rs7.getString("id_d");
                                        den_dep = rs7.getString("den_dep");
                                    }
                                    rs7.close();
                                    stmt.close();
                                    con.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<script type='text/javascript'>");
                                    out.println("alert('Date introduse incorect sau nu exista date!');");
                                    out.println("alert('" + e.getMessage() + "');");
                                    out.println("</script>");
                                }
                            }
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT id_dep, nume_dep FROM departament;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs8 = stmt.executeQuery();

                                while (rs8.next()) {
                                    String depId = rs8.getString("id_dep");
                                    String depName = rs8.getString("nume_dep");
                                    String selected = "";
                                    if (depId.equals(id_dep)) {
                                        selected = "selected";
                                    }
                                    out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                                }
                                rs8.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            
                            out.println("                    </select>");
                            out.println("                </div>");
                            out.println("                <div>");
                            out.println("                    <label for=\"\" class=\"login__label\">Tip/Ierarhie</label>");
                            out.println("                    <select name=\"tip\" class=\"login__input\">");
                            
                            String tip = null;
                            String nume = null;
                            if (userId != 0) {
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                    String sql = "SELECT u.tip as tiip, t.denumire as den_tip FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE id = ?";
                                    PreparedStatement stmt = con.prepareStatement(sql);
                                    stmt.setInt(1, userId);
                                    ResultSet rs9 = stmt.executeQuery();
                                    if (rs9.next()) {
                                        tip = rs9.getString("tiip");
                                        nume = rs9.getString("den_tip");
                                    }
                                    rs9.close();
                                    stmt.close();
                                    con.close();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    out.println("<script type='text/javascript'>");
                                    out.println("alert('Date introduse incorect sau nu exista date!');");
                                    out.println("alert('" + e.getMessage() + "');");
                                    out.println("</script>");
                                }
                            }
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT tip, denumire FROM tipuri;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs10 = stmt.executeQuery();

                                while (rs10.next()) {
                                    String depId = rs10.getString("tip");
                                    String depName = rs10.getString("denumire");
                                    String selected = "";
                                    if (depId.equals(id_dep)) {
                                        selected = "selected";
                                    }
                                    out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                                }
                                rs10.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            
                out.println("                        </select>");
                out.println("                    </div>");
                out.println("                </div>");
                out.println("</td></tr></table>");
                if (userType == 4)
                out.println("            <a href=\"modifusr1.jsp\" class=\"login__forgot\">Inapoi</a>");
                if (userType != 4)
                    out.println("            <a href=\"modifydata.jsp\" class=\"login__forgot\">Inapoi</a>");
                out.println("                <div class=\"login__buttons\">");
                out.println("                    <input type=\"submit\" value=\"Submit\" class=\"login__button login__button-ghost\">");
                out.println("                </div>");
                out.println("                <input type=\"hidden\" name=\"id\" value=\"" + userId + "\"/>");
                out.println("            </form>");
                out.println("        </div>");
                out.println("    </div>");

    
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
                
                } else {
                    response.sendRedirect("dashboard.jsp");
                }
            }
            rs.close();
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
