<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Vizualizare concedii</title>
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
                if (!rs.next()) {
                    out.println("<p>Nu exista date.</p>");
                } else {
                    int userType = rs.getInt("tip");
                    if (userType != 4) {
                    	int col = Integer.valueOf(request.getParameter("id"));
                    	out.println("<h1>Vizualizarea concediilor unui coleg din departamentul meu</h1><br>");
                        out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                        "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT " +
                                "c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                "FROM useri u " +
                                "JOIN tipuri t ON u.tip = t.tip " +
                                "JOIN departament d ON u.id_dep = d.id_dep " +
                                "JOIN concedii c ON c.id_ang = u.id " +
                                "JOIN statusuri s ON c.status = s.status " +
                                "JOIN tipcon ct ON c.tip = ct.tip " +
                                "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id = ?;")) {    
                        	stmt.setInt(1, col);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.print("<tr><td>" + rs1.getInt("nr_crt") + "</td><td>" + rs1.getString("departament") + "</td><td>" + 
                                        rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("functie") + "</td><td>" + 
                                        rs1.getDate("start_c") + "</td><td>" + rs1.getDate("end_c") + "</td><td>" + rs1.getString("motiv") + "</td><td>" + 
                                        rs1.getString("locatie") + "</td>" + "<td>" + rs1.getString("tipcon") + "</td>");
                                if (rs1.getString("status").compareTo("neaprobat") == 0) {
                                    out.println("<td style='background-color: rgb(136, 174, 219);'>" + rs1.getString("status") + "</td></tr>");
                                }
                                if (rs1.getString("status").compareTo("dezaprobat sef") == 0) {
                                    out.println("<td style='background-color: rgb(179, 113, 66);'>" + rs1.getString("status") + "</td></tr>");
                                }
                                if (rs1.getString("status").compareTo("dezaprobat director") == 0) {
                                    out.println("<td style='background-color: rgb(135, 57, 49);'>" + rs1.getString("status") + "</td></tr>");
                                }
                                if (rs1.getString("status").compareTo("aprobat director") == 0) {
                                    out.println("<td style='background-color: rgb(64, 133, 74);'>" + rs1.getString("status") + "</td></tr>");
                                }
                                if (rs1.getString("status").compareTo("aprobat sef") == 0) {
                                    out.println("<td style='background-color: rgb(204, 197, 94);'>" + rs1.getString("status") + "</td></tr>");
                                }
                            }
                            if (!found) {
                                out.println("<tr><td colspan='10'>Nu exista date.</td></tr>");
                            }
                            out.println("</table>");
                        }
                        out.println("<a href ='viewconcol.jsp'>Inapoi</a>");
                    } else {
                        response.sendRedirect("adminok.jsp");
                        // nu e  director
                    }
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