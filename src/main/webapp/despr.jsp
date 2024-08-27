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
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri natural join departament natural join tipuri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int id = rs.getInt("id");
                    String prenume = rs.getString("prenume");
                    String functie = rs.getString("denumire");
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
                    }
                    if (rs.getString("tip").compareTo("5") == 0) {
                        response.sendRedirect("adminok.jsp");
                    } else {
                        String today = null;
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                        today = rs2.getString("today");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
                        %>
<html>
<head>
    <title>Profil utilizator</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <style>
        body {
            margin: 0;
            padding: 0;
            
            background-color: var(--clr);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .profile-card {
            background-color: var(--sd);
            border-radius: 2rem;
            /*box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);*/
            padding: 30px; 
            top; 0;
            width: 400px;
            max-width: 90%;
            text-align: center;
            margin: auto;
           
        }
        .profile-card img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid var(--bg);
            margin-bottom: 15px;
            box-shadow: 0 6px 24px <%out.println(accent); %>;
        }
        .profile-card h1 {
            font-size: 26px;
            margin: 10px 0;
            color: var(--text);
        }
        .profile-card h2 {
            font-size: 20px;
            margin: 5px 0;
            color: #999;
            font-weight: normal;
        }
        .profile-card .info {
            margin: 20px 0;
            text-align: left;
        }
        .profile-card .info div {
            margin: 10px 0;
            font-size: 16px;
            color: #999;
        }
        .profile-card .info div span {
            font-weight: bold;
            color: var(--text);
        }
        .profile-card .buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .profile-card .buttons button {
            background-color: var(--bg);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .profile-card .buttons button a {
            color: white;
            text-decoration: none;
        }
        @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}
    </style>
</head>
<body style="overflow: auto; position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: auto; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --text:<%out.println(text);%>; --sd:<%out.println(sidebar);%>">
<div class="test" style="position: fixed; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: auto; overflow: auto;">
                        <div style="position: fixed; top: 2rem; left: 38%; margin: auto; border-radius: 2rem;" class="profile-card">
                       <img src="${pageContext.request.contextPath}/ImageServlet" alt="Profile Image" />
                        <!-- <img src="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png" alt="imagine profil">  -->
                            <h1><%= prenume %></h1>
                            <h2><%= functie %></h2>
                            <div class="info">
                            <%
                                try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, data_nasterii, adresa, email, telefon, username, denumire, nume_dep FROM useri NATURAL JOIN tipuri NATURAL JOIN departament WHERE username = ?")) {
                                    stmt.setString(1, username);
                                    ResultSet rs1 = stmt.executeQuery();
                                    boolean found = false;
                                    while (rs1.next()) {
                                        found = true;
                                        out.println("<div><span>Nume:</span> " + rs1.getString("nume") + "</div>");
                                        out.println("<div><span>Prenume:</span> " + rs1.getString("prenume") + "</div>");
                                        out.println("<div><span>Data nasterii:</span> " + rs1.getString("data_nasterii") + "</div>");
                                        out.println("<div><span>Adresa/Domiciliul:</span> " + rs1.getString("adresa") + "</div>");
                                        out.println("<div><span>e-mail:</span> " + rs1.getString("email") + "</div>");
                                        out.println("<div><span>Nr. de telefon:</span> " + rs1.getString("telefon") + "</div>");
                                        out.println("<div><span>Nume de utilizator:</span> " + rs1.getString("username") + "</div>");
                                        out.println("<div><span>Functie:</span> " + rs1.getString("denumire") + "</div>");
                                        out.println("<div><span>Departament:</span> " + rs1.getString("nume_dep") + "</div>");
                                    }
                                    if (!found) {
                                        out.println("<div>Nu exista date.</div>");
                                    }
                                }
                            %>
                            </div>
                            <div class="buttons">
                                         
                                <button style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"><a href='modifydata.jsp'>Modificati datele personale</a></button>
                            </div>
                            <div class="buttons">
                                         <button style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"><a href='addpic.jsp'>Modificati imaginea de profil</a></button>
                                
                            </div>
                        </div>
                        </div>
                        <%
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
               
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                } else if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                } else if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                } else if (currentUser.getTip() == 0) {
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
</body>
</html>
