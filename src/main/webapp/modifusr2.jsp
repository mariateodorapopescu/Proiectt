<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Modificare utilizator</title>
</head>
<body>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        int userId = Integer.parseInt(request.getParameter("id")); // Assuming ID is passed correctly
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE id = ?")) {
            preparedStatement.setInt(1, userId);
            ResultSet rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                out.println("Nu exista date.");
            } else {
                int userType = rs.getInt("tip");
                if (userType != 5) {
                    out.println("<div align='center'>");
                    out.println("<h1>Modificare User</h1>");
                    out.println("<form action='" + request.getContextPath() + "/modifusr' method='post'>");
                    out.println("<table style='width: 80%'>");
                    out.println("<tr><td>Nume</td><td><input type='text' name='nume' value='" + rs.getString("nume") + "'></td></tr>");
                    out.println("<tr><td>Prenume</td><td><input type='text' name='prenume' value='" + rs.getString("prenume") + "'></td></tr>");
                    out.println("<tr><td>Data nasterii</td><td><input type='date' name='data_nasterii' value='" + rs.getDate("data_nasterii") + "' min='1954-01-01' max='2036-12-31'></td></tr>");
                    out.println("<tr><td>Adresa</td><td><input type='text' name='adresa' value='" + rs.getString("adresa") + "'></td></tr>");
                    out.println("<tr><td>E-mail</td><td><input type='email' name='email' value='" + rs.getString("email") + "'></td></tr>");
                    out.println("<tr><td>Telefon</td><td><input type='text' name='telefon' value='" + rs.getString("telefon") + "'></td></tr>");
                    out.println("<tr><td>UserName</td><td><input type='text' name='username' value='" + rs.getString("username") + "'></td></tr>");
                    out.println("<td>Departament</td>");
                    out.println("<td>");
                    String id_dep = null;
                    String den_dep = null;
                    if (userId != 0) {
                        try {
                          Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                          Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                          String sql = "SELECT u.id_dep as id_d, d.nume_dep as den_dep FROM useri u JOIN departament d ON u.id_dep = d.id_dep WHERE id = ?";
                          PreparedStatement stmt = con.prepareStatement(sql);
                          stmt.setInt(1, userId);
                         
                            ResultSet rs7 = stmt.executeQuery();
                            if (rs7.next()) {
                                id_dep = rs7.getString("id_d");
                                den_dep = rs7.getString("den_dep");
                            }
                            rs7.close();
                            stmt.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    out.println("<select name=\"departament\">");
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT id_dep, nume_dep FROM departament;";
                        PreparedStatement stmt = con.prepareStatement(sql);
                        ResultSet rs8 = stmt.executeQuery();

                        while (rs8.next()) {
                            String depId = rs8.getString("id_dep");
                            String depName = rs8.getString("nume_dep");
                            String selected = "";
                            if (depId.equals(id_dep)) {
                                selected = "selected";
                            }
                            out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                        }
                        rs8.close();
                        stmt.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                        e.printStackTrace();
                    }
                    out.println("</select>");
                    out.println("</td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Tip/Ierarhie</td>");
                    out.println("<td>");
                    String tomodify9 = request.getParameter("username");
                    String tip = null;
                    String nume = null;
                    
                    if (userId != 0) {
                        try {
                          Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                          Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                          String sql = "SELECT u.tip as tiip, t.denumire as den_tip FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE id = ?";
                          PreparedStatement stmt = con.prepareStatement(sql);
                          stmt.setInt(1, userId);
                            ResultSet rs9 = stmt.executeQuery();
                            if (rs9.next()) {
                                tip = rs9.getString("tiip");
                                nume = rs9.getString("den_tip");
                            }
                            rs9.close();
                            stmt.close();
                            con.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    out.println("<select name=\"tip\">");
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT tip, denumire FROM tipuri;";
                        PreparedStatement stmt = con.prepareStatement(sql);
                        ResultSet rs10 = stmt.executeQuery();

                        while (rs10.next()) {
                            String depId = rs10.getString("tip");
                            String depName = rs10.getString("denumire");
                            String selected = "";
                            if (depId.equals(id_dep)) {
                                selected = "selected";
                            }
                            out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                        }
                        rs10.close();
                        stmt.close();
                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                        e.printStackTrace();
                    }
                    out.println("</select>");
                    out.println("</td>");
                    out.println("</tr>");
                    out.println("<input type='hidden' name='id' value='" + userId + "'/>"); // Pass the ID as a hidden field
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    out.println("</div>");
                    out.println("<a href='modifusr1.jsp'>Inapoi</a>");
                } else {
                    response.sendRedirect("dashboard.jsp");
                }
            }
            rs.close();
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("Database connection or query error: " + e.getMessage());
            response.sendRedirect("error.jsp");
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