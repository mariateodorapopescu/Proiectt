<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Date personale</title>
</head>
<body>
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
                    if (userType == 4) {
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
                        out.println("<h1>Date personale</h1><br>");
                        out.println("<table border='1'><tr><th>Nume</th><th>Prenume</th><th>Data nasterii</th><th>Adresa</th><th>E-mail</th><th>Telefon</th><th>Username</th><th>Tip</th><th>Departament</th><th>Zile consumate</th><th>Zile ramase</th><th>Concedii luate</th><th>Concedii ramase</th></tr>");
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, data_nasterii, adresa, email, telefon, username, denumire, nume_dep, zilecons, zileramase, conluate, conramase FROM useri NATURAL JOIN tipuri NATURAL JOIN departament where username = ?")) {
                        	stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("data_nasterii") + "</td><td>" + rs1.getString("adresa") + "</td><td>"+ rs1.getString("email") + "</td><td>"+ rs1.getString("telefon") + "</td><td>"+ rs1.getString("username") + "</td><td>"+ rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td><td>" + rs1.getString("zilecons") + "</td><td>" + rs1.getString("zileramase") + "</td><td>" + rs1.getString("conluate") + "</td><td>" + rs1.getString("conramase") + "</td></tr>");
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            out.println("</table>");
                        }
                        if (userType == 0) {
                            out.println("<a href ='dashboard.jsp'>Inapoi</a>");
                         }
                         if (userType == 1) {
                             out.println("<a href ='tip1ok.jsp'>Inapoi</a>");
                          }
                         if (userType == 2) {
                             out.println("<a href ='tip2ok.jsp'>Inapoi</a>");
                          }
                         if (userType == 3) {
                             out.println("<a href ='sefok.jsp'>Inapoi</a>");
                          }
                        out.println("<br><a href='modifydata.jsp'>Modificare date</a>");
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
