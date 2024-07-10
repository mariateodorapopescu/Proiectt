<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Adaugare concediu</title>
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
                            case 4:
                                response.sendRedirect("adminok.jsp");
                                break;
                        }
                    } else {
                        out.println("<div align='center'>");
                        out.println("<h1>Adaugare concediu</h1>");
                        out.print("<form action='");
                        out.print(request.getContextPath());
                        out.println("/addcon' method='post'>");
                        out.println("<table style='width: 80%'>");
                        out.println("<tr>");
                        out.println("<td>Data de plecare</td>");
                        out.println("<td><input type='date' id='start' name='start' min='1954-01-01' max='2036-12-31' required/></td>");
                        out.println("</tr>");
                        out.println("<tr>");
                        out.println("<td>Data de intoarcere</td>");
                        out.println("<td><input type='date' id='end' name='end' min='1954-01-01' max='2036-12-31' required/></td>");
                        out.println("</tr>");
                        out.println("<tr>");
                        out.println("<td>Motiv</td>");
                        out.println("<td><input type='textarea' name='motiv' required/></td>");
                        out.println("</tr>");
                        out.println("<tr>");
                        out.println("<td>Locatie</td>");
                        out.println("<td><input type='text' name='locatie' required/></td>");
                        out.println("</tr>");
                        // Hidden input to carry user ID forward
                        out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
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
                    out.println("Nu exista date");
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
