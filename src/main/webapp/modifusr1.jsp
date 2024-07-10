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
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                int userType = rs.getInt("tip");
                if (rs.next() == false) {
                    out.println("No Records in the table");
                } else {
                    if (rs.getString("tip").compareTo("4") != 0) {
                        //out.println("Nu ai ce cauta aici!");
                        if (rs.getString("tip").compareTo("1") == 0) {
                        	response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                        	response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                        	response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("0") == 0) {
                        	response.sendRedirect("dashboard.jsp");
                        }
                    } else {
                    	
                    	out.println("<h1>Modificare utilizator</h1>");
                    	out.println("<form action='");
                    	request.getContextPath();
                    	out.println("modifusr2.jsp' method='post'>");
                    	out.println("<table style='width: 100%'>");
                    	out.println("<tr>");
                    	out.println("<td>UserName</td>");
                    	out.println("<td><input type='text' name='username' /></td>");
                    	out.println("</tr>");
                    	out.println("</table>");
                    	out.println("<input type='submit' value='Submit' />");
                    	out.println("</form>");             	
           				if ("true".equals(request.getParameter("wu"))) {
    						out.print("Username gresit sau inexistent.");
						}
           				out.println("<form name='postForm' action='modifusr2.jsp' method='POST' style='display:none;'>");
           				out.println("<input type='hidden' name='tomodify' value='${param.username}'>");
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
           response.sendRedirect("login.jsp");   
        }
    } else {
    	response.sendRedirect("login.jsp");
    }
%>
</body>
</html>