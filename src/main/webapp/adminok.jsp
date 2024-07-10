<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Dashboard</title>
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
                if (rs.next() == false) {
                    out.println("No Records in the table");
                } else {
                    if (rs.getString("tip").compareTo("4") != 0) {
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
                        out.println("<h1>Bun venit, " + rs.getString("prenume") + "!</h1>");
                        out.println("<p>Meniu</p>");
                        out.println("<b><a href='viewcolegi.jsp'>Vizualizare angajati din toata institutia</a></b><br>");
                        out.println("<b><a href='viewdep.jsp'>Vizualizare departamente din toata institutia</a></b><br>");
                        out.println("<b><a href='signin.jsp'>Adaugare Utilizator nou</a></b><br>");
                        out.println("<b><a href='modifusr1.jsp'>Modificare Utilizator</a></b><br>");
                        out.println("<b><a href='modifpasd.jsp'>Modificare Utilizator - parola</a></b><br>");
                        out.println("<b><a href='delusr1.jsp'>Stergere Utilizator</a></b><br>");
                        out.println("<b><a href='adddep.jsp'>Adaugare departament</a></b><br>");
                        out.println("<b><a href='modifdep.jsp'>Modificare departament</a></b><br>");
                        out.println("<b><a href='deldep.jsp'>Stergere departament</a></b><br>");
                        out.println("<form action='logout' method='post'><button type='submit'>Logout</button></form>");
                        out.println("<p>To be to...</p>");
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
