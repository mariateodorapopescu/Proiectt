<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Vizualizare angajati</title>
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
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    if (userType != 0) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        int idDep = Integer.valueOf(request.getParameter("iddep"));
                        PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                        stm.setInt(1, idDep);
                        ResultSet rs2 = stm.executeQuery();
                        String deptName = "";
                        if (rs2.next()) {
                            deptName = rs2.getString("nume_dep");
                        }
                        out.println("<h1>Vizualizare angajati din departamentul " + deptName + "</h1><br>");

                        PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, username, denumire, nume_dep FROM useri left JOIN tipuri on tipuri.tip = useri.tip left JOIN departament on departament.id_dep = useri.id_dep WHERE useri.id_dep = ?");
                        stmt.setInt(1, idDep);
                        ResultSet rs1 = stmt.executeQuery();
                        boolean found = false;

                        out.println("<table border='1'><tr><th>Nume</th><th>Prenume</th><th>Username</th><th>Tip</th><th>Departament</th></tr>");
                        while (rs1.next()) {
                            found = true;
                            out.println("<tr><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("username") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");
                        }
                        if (!found) {
                            out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                        }
                        out.println("</table>");
                        rs1.close();
                        stmt.close();
                        stm.close();
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
                }
                rs.close();
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
