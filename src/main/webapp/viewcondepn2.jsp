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
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    if (userType != 0) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        int idDep = Integer.valueOf(request.getParameter("iddep"));
                        PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                        stm.setInt(1, idDep);
                        ResultSet rs2 = stm.executeQuery();
                        String deptName = "";
                        if (rs2.next()) {
                            deptName = rs2.getString("nume_dep");
                        }
                        out.println("<h1>Vizualizare concedii din departamentul " + deptName + "</h1><br>");

                        PreparedStatement stmt = connection.prepareStatement("SELECT " +
                                "c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                "FROM useri u " +
                                "JOIN tipuri t ON u.tip = t.tip " +
                                "JOIN departament d ON u.id_dep = d.id_dep " +
                                "JOIN concedii c ON c.id_ang = u.id " +
                                "JOIN statusuri s ON c.status = s.status " +
                                "JOIN tipcon ct ON c.tip = ct.tip " +
                                "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and d.id_dep = ? and c.status = 0;");
                        stmt.setInt(1, idDep);
                        ResultSet rs1 = stmt.executeQuery();
                        boolean found = false;

                        out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                                "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
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
                            out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
                        }
                        out.println("</table>");
                        rs1.close();
                        stmt.close();
                        stm.close();
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
