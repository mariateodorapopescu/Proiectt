<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Stergere concediu</title>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    if (userType == 4) {
                        switch (userType) {
                            case 4: response.sendRedirect("adminok.jsp"); break;
                        }
                    } else {
                        out.println("<div align='center'>");
                        out.println("<h1>Selectati concediul pe care doriti sa il stergeti</h1>");
                        out.print("<form action='");
                        out.print(request.getContextPath());
                        out.println("/delcon' method='post'>");
                        out.println("<table style='width: 80%'>");
                        out.println("<tr><td>Concediu (Motiv)</td><td><select name='idcon'>");

                        try (PreparedStatement stm = connection.prepareStatement("SELECT id, start_c, end_c, motiv, locatie FROM concedii WHERE id_ang = ?")) {
                            stm.setInt(1, userId);
                            try (ResultSet rs1 = stm.executeQuery()) {
                                if (rs1.next()) {
                                    do {
                                        int id = rs1.getInt("id");
                                        String motiv = rs1.getString("motiv");
                                        out.println("<option value='" + id + "'>" + motiv + " (" + rs1.getString("start_c") + " to " + rs1.getString("end_c") + ")</option>");
                                    } while (rs1.next());
                                } else {
                                    out.println("<option value=''>No exista concedii disponibile.</option>");
                                }
                            }
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
                    }
                } else {
                    out.println("Nu exista date.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("login.jsp");
            }
        } else {
            response.sendRedirect("login.jsp");
        }
    } else {
        response.sendRedirect("login.jsp");
    }
%>
</body>
</html>
