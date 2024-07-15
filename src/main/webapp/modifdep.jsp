<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Modificare departament</title>
</head>
<body>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        //int userdep = currentUser.getDepartament();
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (!rs.next()) {
            	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
            } else {
                int userType = rs.getInt("tip");
                int userdep = rs.getInt("id_dep");
                if (userType != 4) {
                	 if (rs.getString("tip").compareTo("1") == 0) {
                     	response.sendRedirect("tip1ok.jsp");
                     }
                     if (rs.getString("tip").compareTo("2") == 0) {
                     	response.sendRedirect("tip2ok.jsp");
                     }
                     if (rs.getString("tip").compareTo("3") == 0) {
                     	response.sendRedirect("sefok.jsp");
                     }
                     if (rs.getString("tip").compareTo("4") == 0) {
                      	response.sendRedirect("adminok.jsp");
                      }
                } else {
                    	out.println("<h1>Modificare departament</h1>");
                    	out.println("<form action='");
                    	request.getContextPath();
                    	out.println("modifdep2.jsp' method='post'>");
                    	out.println("<table style='width: 100%'>");
                    	out.println("<tr>");
                    	out.println("<td>Nume departament</td>");
                    	 out.println("<td><select name='username'>");
                    	 try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament")) {
                             ResultSet rs1 = stm.executeQuery();
                             while (rs1.next()) {
                                 int id = rs1.getInt("id_dep");
                                 String nume = rs1.getString("nume_dep");
                                 out.println("<option value='" + nume + "'>" + nume + "</option>");
                             }
                         }
                    	 out.println("</select></td></tr>");
                    	out.println("</table>");
                    	out.println("<input type='submit' value='Submit' />");
                    	out.println("</form>");             	
           				if ("true".equals(request.getParameter("wu"))) {
    						out.print("Nume gresit sau inexistent.");
						}
           				out.println("<form name='postForm' action='modifdep2.jsp' method='POST' style='display:none;'>");
           				out.println("<input type='hidden' name='username' value='${param.username}'>");
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
                }
            } catch (Exception e) {
                // out.println("Database connection or query error: " + e.getMessage());
                out.println("<script type='text/javascript'>");
                    out.println("alert('Eroare la baza de date!');");
                    out.println("alert('" + e.getMessage() + "');");
                    out.println("</script>");
                if (currentUser.getTip() == 1) {
                	response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                	response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                	response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                	response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
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