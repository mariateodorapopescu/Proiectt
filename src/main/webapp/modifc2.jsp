<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Modificare concediu</title>
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
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip, prenume FROM useri WHERE username = ?")) {
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
                }
                
                int data = Integer.valueOf(request.getParameter("idcon"));
                PreparedStatement stm = connection.prepareStatement("SELECT * FROM concedii WHERE id = ?");
                stm.setInt(1, data);
                ResultSet rs1 = stm.executeQuery();
                if (rs1.next()) {
                	int id = rs1.getInt("id");
                    String data_s = rs1.getString("start_c");
                    String data_e = rs1.getString("end_c");
                    String motiv = rs1.getString("motiv");
                    String locatie = rs1.getString("locatie");
                    
                    out.println("<div align='center'>");
                    out.println("<h1>Modificare concediu</h1>");
                    out.println("<form action='modifcon' method='post'>");
                    out.println("<input type='hidden' name='idcon' value='" + id + "'/>");
                    out.println("<table style='width: 80%'>");
                    out.println("<tr><td>Data de plecare</td><td><input type='date' id='start' name='start' value='" + data_s + "' min='1954-01-01' max='2036-12-31' required/></td></tr>");
                    out.println("<tr><td>Data de intoarcere</td><td><input type='date' id='end' name='end' value='" + data_e + "' min='1954-01-01' max='2036-12-31' required/></td></tr>");
                    out.println("<tr><td>Motiv</td><td><input type='textarea' name='motiv' value='" + motiv + "' required/></td></tr>");
                    out.println("<tr><td>Locatie</td><td><input type='text' name='locatie' value='" + locatie + "' required/></td></tr>");
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    out.println("</div>");
                    out.println("<a href ='modifc1.jsp'>Inapoi</a>");
                } else {
                    out.println("Nu exista date pentru data selectata.");
                }
                rs1.close();
                stm.close();
            } else {
                out.println("Nu exista date.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            // response.sendRedirect("login.jsp");
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
