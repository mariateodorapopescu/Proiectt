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
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            preparedStatement = connection.prepareStatement("SELECT tip, prenume, id FROM useri WHERE username = ?");
            preparedStatement.setString(1, username);
            rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                out.println("<script type='text/javascript'>alert('Date introduse incorect sau nu exista date!');</script>");
            } else {
                int userId = rs.getInt("id");
                String userType = rs.getString("tip");
                String accent = "##03346E";
                String clr = "#d8d9e1";
                String sidebar =  "#ecedfa";
                String text = "#333";
                String card =  "#ecedfa";
               	String hover = "#ecedfa";
                // Retrieve user theme settings
                try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM teme WHERE id_usr = ?")) {
                    stmt.setInt(1, userId);
                    try (ResultSet rs2 = stmt.executeQuery()) {
                        if (rs2.next()) {
                           	accent = rs2.getString("accent");
                            clr = rs2.getString("clr");
                            sidebar = rs2.getString("sidebar");
                            text = rs2.getString("text");
                            card = rs2.getString("card");
                            hover = rs2.getString("hover");

                            // Output user-specific style settings
                            out.println("<style>:root {--bg:" + accent + "; --clr:" + clr + "; --sd:" + sidebar + "; --text:" + text + "; background:" + clr + ";}</style>");
                        }
                    }
                }
                %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
<link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
<link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
<title>Rapoarte</title>
<style>
    * {
       
        margin: 0;
        padding: 0;
    }
    body, html {
        background: <%= clr %>;
        padding: 0;
        marging: 0;
        overflow-x: hidden;
    }
    nav {
        width: 100%;
        background-color: <%= sidebar %>;
        
        display: flex;
        justify-content: center;
        position: fixed;
        top: 0;
        z-index: 1000;
        padding: 0;
        margin: 0;
    }
    nav a {
        flex-grow: 1;
        
        padding: 12px 10px;
        text-align: center;
        text-decoration: none;
        font-size: 14px;
        color: <%= text %>;
        transition: background-color 0.3s, color 0.3s;
    }
    nav a:hover, nav a:active, nav a:focus {
        background-color: <%= accent %>;
        color: <%= clr %>;
    }
    iframe {
        width: 100%;
        height: 100vh; /* Adjusted for nav height */
        border: none;
        position: relative;
        top: 0;
         overflow-y: hidden;
    }
</style>
</head>
<body>

<nav>
    <a  href="viewconcoldepeu.jsp" target="contentFrame">Coleg</a>
    <a href="viewp.jsp" target="contentFrame">Concedii personale</a>
    <a href="viewdepeu.jsp" target="contentFrame">Din departamentul meu</a>
    <a href="pean2.jsp" target="contentFrame">Raport pe an</a>
    <a href="sometest2.jsp" target="contentFrame">Raport lunar</a>
    <a href="testviewpers2.jsp" target="contentFrame">Calendar</a>
</nav>

<iframe name="contentFrame" src="about:blank"></iframe>

</body>
</html>

    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script type='text/javascript'>alert('Eroare la baza de date!'); location='logout';</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    } else {
        out.println("<script type='text/javascript'>alert('Utilizator neconectat!'); location='logout';</script>");
    }
} else {
    out.println("<script type='text/javascript'>alert('Nu e nicio sesiune activa!'); location='logout';</script>");
}
    
    %>
</script>
</body>
</html>
