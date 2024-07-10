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
                    if (rs.getString("tip").compareTo("2") != 0) {
                    	if (currentUser.getTip() == 3) {
                        	response.sendRedirect("sefok.jsp");
                        }
                        if (currentUser.getTip() == 1) {
                        	response.sendRedirect("tip1ok.jsp");
                        }
                        if (currentUser.getTip() == 0) {
                        	response.sendRedirect("dashboard.jsp");
                        }
                        if (currentUser.getTip() == 4) {
                        	response.sendRedirect("adminok.jsp");
                        }
                    } else {
                        out.println("<h1>Bun venit, " + rs.getString("prenume") + "!</h1>");
                        out.println("<p>Meniu</p><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu / an</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii personale pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii din departamentul meu pe o anumita perioada</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Vizualizare concedii unui coleg din departamentul meu pe o anumita perioada </a><br>");
                        out.println("<a href='viewcolegi.jsp'>Adaugare concediu personal</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Modificare concediu personal</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Modificare concediu personal - start</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Modificare concediu personal - end</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Modificare concediu personal - motiv</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Modificare concediu personal - locatie</a><br>");
                        out.println("<a href='viewcolegi.jsp'>Stergere concediu personal</a><br>");
                        out.println("<form action='logout' method='post'><button type='submit'>Logout</button></form>");
                        out.println("<p>To be to...</p>");
                    }
                }
            } catch (Exception e) {
                // out.println("Database connection or query error: " + e.getMessage());
                if (currentUser.getTip() == 3) {
                	response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 1) {
                	response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 0) {
                	response.sendRedirect("dashboard.jsp");
                }
                if (currentUser.getTip() == 4) {
                	response.sendRedirect("adminok.jsp");
                }
                e.printStackTrace();
            }
        } else {
            // out.print("Guest");
        	response.sendRedirect("login.jsp");  
        }
    } else {
        // out.print("Session not found");
    	response.sendRedirect("login.jsp");   
    }
%>
</body>
</html>
