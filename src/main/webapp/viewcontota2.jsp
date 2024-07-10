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
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<p>Nu exista date.</p>");
                } else {
                    int userType = rs.getInt("tip");
                    if (userType == 0) {
                        out.println("<h1>Vizualizarea tuturor concediilor din toata institutia per total APROBATE SEF</h1><br>");
                        out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                        "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Status</th></tr>");
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT concedii.id as nr_crt, departament.nume_dep as departament, nume, prenume, " + 
                            "tipuri.denumire as functie, start_c, end_c, motiv, locatie, statusuri.nume_status as status FROM useri " +
                            "NATURAL JOIN tipuri NATURAL JOIN departament JOIN concedii ON concedii.id_ang = useri.id JOIN statusuri ON concedii.status = statusuri.status where concedii.status = 1")) {
                            ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.print("<tr><td>" + rs1.getInt("nr_crt") + "</td><td>" + rs1.getString("departament") + "</td><td>" + 
                                    rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("functie") + "</td><td>" + 
                                    rs1.getDate("start_c") + "</td><td>" + rs1.getDate("end_c") + "</td><td>" + rs1.getString("motiv") + "</td><td>" + 
                                    rs1.getString("locatie") + "</td>");
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
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("login.jsp");
                System.out.println("?????");
            }
        } else {
            response.sendRedirect("login.jsp");
            System.out.println("lol ce");
        }
    } else {
        response.sendRedirect("login.jsp");
    	System.out.println("lol ce x2");
    }
%>
</body>
</html>
