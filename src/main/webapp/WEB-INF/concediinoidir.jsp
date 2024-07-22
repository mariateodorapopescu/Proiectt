<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Aprobare concediu</title>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 0) {  // Assuming only type 4 users can approve
                    	
                    	
                    	out.println("<h1>Vizualizare angajati din toata institutia</h1><br>");
                        out.println("<table border='1'><tr><th>Nume</th><th>Prenume</th><th>Username</th><th>Tip</th><th>Departament</th></tr>");
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT concedii.id as nr_crt, departament.nume_dep as departament, nume, prenume, " + 
                                "tipuri.denumire as functie, start_c, end_c, motiv, locatie, statusuri.nume_status as status FROM useri " +
                                "NATURAL JOIN tipuri NATURAL JOIN departament JOIN concedii ON concedii.id_ang = useri.id JOIN statusuri ON concedii.status = statusuri.status where concedii.status = 1 and useri.id_dep = ?")) {
                            
                        	stmt.setInt(1, userdep);ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("username") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");   
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            out.println("</table>");
                            out.println(userType == 4 ? "<a href='adminok.jsp'>Inapoi</a>" : "<a href='dashboard.jsp'>Inapoi</a>");
                        }
                    	
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
                    } else {
                    	switch (userType) {
                        case 1: response.sendRedirect("tip1ok.jsp"); break;
                        case 2: response.sendRedirect("tip1ok.jsp"); break;
                        case 3: response.sendRedirect("sefok.jsp"); break;
                        case 4: response.sendRedirect("adminok.jsp"); break;
                    }
                    }
                } else {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
    	        out.println("alert('Eroare la baza de date!');");
    	        out.println("alert('" + e.getMessage() + "');");
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