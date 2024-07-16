<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
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
                if (rs.next() == false) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("0") != 0) {
                    	if (rs.getString("tip").compareTo("1") == 0) {
                        	response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                        	response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                        	response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("4") == 0) {
                        	response.sendRedirect("adminok.jsp");
                        }
                    } else {
                        out.println("<h1>Bun venit, " + rs.getString("prenume") + "!</h1>");
                        out.println("<p>Meniu</p>");
                        out.println("<p><b>Resurse umane</b></p>");
                        out.println("<b><a href='viewcolegidep.jsp'>Vizualizare colegi din departamentul meu</a><br></b>");
                        out.println("<b><a href='viewcolegi.jsp'>Vizualizare angajati din toata intitutia</a><br></b>");
                        out.println("<b><a href='viewdep.jsp'>Vizualizare departamente din toata institutia</a><br></b>");
                        out.println("<b><a href='viewangdep.jsp'>Vizualizare angajati dintr-un anumit departament</a></b><br>");
                        out.println("<b><a href='despr.jsp'>Vizualizare date personale</b></a><br>");
                        out.println("<p><b>Actiuni</b></p>");
                        out.println("<b><a href='addc.jsp'>Adaugare concediu personal</a></b><br>");
                        out.println("<b><a href='modifc1.jsp'>Modificare concediu personal</b></a><br>");
                        out.println("<b><a href='delcon1.jsp'>Stergere concediu personal</b></a><br>");
                        out.println("<b><a href='aprobdir.jsp'>Aprobare concediu</b></a><br>");
                        out.println("<b><a href='resdir.jsp'>Respingere concediu</b></a><br>");
                        out.println("<b><a href='aprobsef.jsp'>Aprobare concediu S</b></a><br>");
                        out.println("<b><a href='ressef.jsp'>Respingere concediu S</b></a><br>");
                        out.println("<p><b>Concedii</b></p>");
                        out.println("<p><b>Total</b></p>");
                        out.println("<b><a href='viewcontot.jsp'>Vizualizare concedii din toata institutia / an</a></b><br>");
                        out.println("<b><a href='viewconp.jsp'>Vizualizare concedii personale / an</a></b><br>");
                        out.println("<b><a href='viewcondept1.jsp'>Vizualizare concedii dintr-un departament / an</a></b><br>");
                        out.println("<b><a href='viewcondep1.jsp'>Vizualizare concedii din departamentul meu / an</b></a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament / an (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii dintr-un departament pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu pe o anumita perioada </a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament pe o anumita perioada (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<p><b>Status</b></p>");
                        out.println("<b><a href='viewcontot2.jsp'>Vizualizare concedii din toata institutia / an</a></b><br>");
                        out.println("<b><a href='viewconp2.jsp'>Vizualizare concedii personale / an</a></b><br>");
                        out.println("<b><a href='viewcondept.jsp'>Vizualizare concedii dintr-un departament / an</a></b><br>");
                        out.println("<b><a href='viewcondepms.jsp'>Vizualizare concedii din departamentul meu / an</a></b><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament / an (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii dintr-un departament pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu pe o anumita perioada </a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament pe o anumita perioada (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<p><b>Tipuri</b></p>");
                        out.println("<b><a href='viewcontott.jsp'>Vizualizare concedii din toata institutia / an</a></b><br>");
                        out.println("<b><a href='viewconpt.jsp'>Vizualizare concedii personale / an</a></b><br>");
                        out.println("<b><a href='viewcondept.jsp'>Vizualizare concedii dintr-un departament / an</a></b><br>");
                        out.println("<b><a href='viewcondepmt.jsp'>Vizualizare concedii din departamentul meu / an</a></b><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament / an (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii dintr-un departament pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu pe o anumita perioada </a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament pe o anumita perioada (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<p><b>Tipuri + Status</b></p>");
                        out.println("<b><a href='viewcontotts.jsp'>Vizualizare concedii din toata institutia / an</a></b><br>");
                        out.println("<b><a href='viewconpts.jsp'>Vizualizare concedii personale / an</a></b><br>");
                        out.println("<b><a href='viewcondepts.jsp'>Vizualizare concedii dintr-un departament / an</a></b><br>");
                        out.println("<b><a href='viewcondepmts.jsp'>Vizualizare concedii din departamentul meu / an</a></b><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament / an (doar coleg, nu conteaza departamentul gen)</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii dintr-un departament pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu pe o anumita perioada </a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg dintr-un departament pe o anumita perioada (doar coleg, nu conteaza departamentul gen)</a><br>");
                       	
                        out.println("<form action='logout' method='post'><button type='submit'>Logout</button></form>");
                        out.println("<p>To be to...</p>");
                    }
                }
            } catch (Exception e) {
                // out.println("Database connection or query error: " + e.getMessage());
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
