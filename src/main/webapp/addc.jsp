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
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip, zileramase, conramase FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    String zile = rs.getString("zileramase");
                    String con = rs.getString("conramase");
                    
                    // Allow only non-admin users to access this page
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }
                    out.println("<p style='position:relative;left:10%;top:10%;padding:0;margin:0;'>Zile ramase: " + zile + "</p>");
                    out.println("<p style='position:relative;left:10%;top:10%;padding:0;margin:0;'>Concedii ramase: " + con + "</p><br>");
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
                    out.println("<td><input type='text' name='motiv' required/></td>");
                    out.println("</tr>");
                    out.println("<tr><td>Tip</td>");
                    out.println("<td><select name = 'tip'>");
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int tip = rs1.getInt("tip");
                            String motiv = rs1.getString("motiv");
                            out.println("<option value='" + tip + "'>" + motiv + "</option>");
                        }
                    }
                    out.println("</select></td></tr>");
                    out.println("<tr>");
                    out.println("<td>Locatie</td>");
                    out.println("<td><input type='text' name='locatie' required/></td>");
                    out.println("</tr>");
                    
                    out.println("<script>");
                    
                    out.println("document.addEventListener('DOMContentLoaded', function() {");
                    out.println("    var dp1 = document.getElementById('start');");
                    out.println("    var dp2 = document.getElementById('end');");
                    out.println("    if (dp1) {");
                    out.println("        dp1.addEventListener('change', function() {");
                    out.println("            dp2.min = dp1.value;");
                    out.println("            if (dp2.value < dp1.value) {");
                    out.println("                dp2.value = '';");
                    out.println("            }");
                    out.println("        });");
                    out.println("    }");
                    out.println("    if (dp2) {");
                    out.println("        dp2.addEventListener('change', function() {");
                    out.println("            if (dp2.value < dp1.value) {");
                    out.println("                dp2.value = '';");
                    out.println("                alert('Data de final nu poate fi mai mica decat cea de inceput!');");
                    out.println("            }");
                    out.println("        });");
                    out.println("    }");
                    out.println("});");
                    
                   	out.println("</script>");
                    
                    // Hidden input to carry user ID forward
                    out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    out.println("</div>");
                    if (userType >= 0 && userType <= 3) {
                        out.println("<a href ='dashboard.jsp'>Inapoi</a>");
                    }
                } else {
                	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");out.println("Nu exista date.");
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
