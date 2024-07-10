<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Respingere concediu</title>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 3) {  // Assuming only type 4 users can approve
                        out.println("<div align='center'>");
                        out.println("<h1>Selectati concediul pe care doriti sa il respingeti</h1>");
                        out.print("<form action='");
                        out.print(request.getContextPath());
                        out.println("/ressef' method='post'>");  // Assume there's an endpoint to handle this
                        out.println("<table style='width: 80%'>");
                        out.println("<tr><td>Concediu (Motiv)</td><td><select name='idcon'>");

                        String query = "SELECT concedii.id as nr_crt, departament.nume_dep as departament, nume, prenume, " + 
                                "tipuri.denumire as functie, start_c, end_c, motiv, locatie, statusuri.nume_status as status FROM useri " +
                                "NATURAL JOIN tipuri NATURAL JOIN departament JOIN concedii ON concedii.id_ang = useri.id JOIN statusuri ON concedii.status = statusuri.status where concedii.status = 0 and tipuri.tip != 0 and useri.id_dep = ?"; // Assuming status 0 is for pending approval
                        try (PreparedStatement stm = connection.prepareStatement(query)) {
                            stm.setInt(1, userdep);
                            ResultSet rs1 = stm.executeQuery();
                            while (rs1.next()) {
                                int id = rs1.getInt("nr_crt");
                                String motiv = rs1.getString("motiv");
                                String period = rs1.getString("start_c") + " to " + rs1.getString("end_c");
                                out.println("<option value='" + id + "'>" + motiv + " (" + period + ")</option>");
                            }
                            //if (!rs1.isBeforeFirst()) {
                            //    out.println("<option value=''>Nu exista concedii disponibile.</option>");
                            //}
                        }

                        out.println("</select></td></tr>");
                        out.println("</table>");
                        out.println("<input type='submit' value='Submit' />");
                        out.println("</form>");
                        out.println("</div>");
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
                    	switch (userType) {
                        case 1: response.sendRedirect("tip1ok.jsp"); break;
                        case 2: response.sendRedirect("tip1ok.jsp"); break;
                        case 3: response.sendRedirect("sefok.jsp"); break;
                        case 4: response.sendRedirect("adminok.jsp"); break;
                    }
                    }
                } else {
                    out.println("Nu exista date pentru utilizator.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("err.jsp");  // Redirect to an error page
            }
        } else {
            response.sendRedirect("login.jsp");  // No user in session, redirect to login
        }
    } else {
        response.sendRedirect("login.jsp");  // No session, redirect to login
    }
%>
</body>
</html>