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
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id_dep FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, currentUser.getUsername());
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userType = rs.getInt("tip");
                int userdep = rs.getInt("id_dep");
                if (userType == 4) {
                    response.sendRedirect(userType == 4 ? "adminok.jsp" : userType == 2 ? "tip2ok.jsp" : "tip1ok.jsp");
                } else {
                    out.println("<div align='center'>");
                    out.println("<h1>Selectati utilizatorul</h1>");
                    out.print("<form action='");
                    out.print(request.getContextPath() + "/viewconcold2.jsp");
                    out.println("' method='post'>");
                    out.println("<table style='width: 80%'>");
                    out.println("<tr><td>Utilizator (Nume, Prenume, Username)</td><td><select name='id'>");

                    try (PreparedStatement stm = connection.prepareStatement("SELECT id, nume, prenume, username FROM useri where id_dep = ?")) {
                    	stm.setInt(1, userdep);
                        ResultSet rs1 = stm.executeQuery();
                        while (rs1.next()) {
                            int id = rs1.getInt("id");
                            String nume = rs1.getString("nume");
                            String prenume = rs1.getString("prenume");
                            String username = rs1.getString("username");
                            out.println("<option value='" + id + "'>" + nume + " " + prenume + " (" + username + ")</option>");
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
                     if (userType == 4) {
                         out.println("<a href ='adminok.jsp'>Inapoi</a>");
                      }
                }
            } else {
            	 out.println("<script type='text/javascript'>");
                 out.println("alert('Nu a extras tipul de la utilizatorul curent???!');");
                 out.println("</script>");
            }
        } 
        catch (Exception e) {
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
