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
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    if (userType != 0) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                            case 4: response.sendRedirect("adminok.jsp"); break;
                        }
                    } else {
                        out.println("<div align='center'>");
                        out.println("<h1>Selectati tipul concediilor de vizualizat</h1>");
                        out.print("<form action='");
                        out.print(request.getContextPath());
                        out.println("/viewcontott2.jsp' method='post'>");
                        out.println("<table style='width: 80%'>");
                        out.println("<tr><td>Tip</td><td><select name='iddep'>");

                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM tipcon;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                                if (rs1.next()) {
                                    do {
                                        int id = rs1.getInt("tip");
                                        String nume = rs1.getString("motiv");
                                        out.println("<option value='" + id + "'>" + nume + "</option>");
                                    } while (rs1.next());
                                } else {
                                    out.println("<option value=''>Nu exista tipuri didponibile.</option>");
                                }
                            }
                        }

                        out.println("</select></td></tr>");
                        
                        String start = request.getParameter("start");
                        String end = request.getParameter("end");
                        out.println("<input type='hidden' name='start' value='" + start + "'/>");
                        out.println("<input type='hidden' name='end' value='" + end + "'/>");
  
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
