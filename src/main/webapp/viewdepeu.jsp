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
            String user = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume, id_dep from useri where username = ?")) {
                preparedStatement.setString(1, user);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 4) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                            case 4: response.sendRedirect("adminok.jsp"); break;
                        }
                    } else {
                        out.println("<div align='center'>");
                        out.println("<h1>Vizualizare concediu coleg de departament</h1>");
                        out.print("<form action='");
                        out.print(request.getContextPath());
                        out.println("/masina1.jsp' method='post'>");
                        out.println("<table style='width: 80%'>");
                        
                        out.println("<tr><td>Status</td><td><select name='status'>");
                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                            	out.println("<option value='" + 3 + "'>" + "Oricare" + "</option>");
                                if (rs1.next()) {
                                    do {
                                        int id = rs1.getInt("status");
                                        String nume = rs1.getString("nume_status");
                                        out.println("<option value='" + id + "'>" + nume + "</option>");
                                    } while (rs1.next());
                                } else {
                                    out.println("<option value=''>Nu exista statusuri didponibile.</option>");
                                }
                            }
                        }
                        out.println("</select></td></tr>");
                        
                        out.println("<tr><td>Tip</td><td><select name='tip'>");
                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM tipcon;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                            	out.println("<option value='" + -1 + "'>" + "Oricare" + "</option>");
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
                        
                        %>
                        <tr><td></td><td>
						 
						  <div>
						    <input type="checkbox" id="an" name="an" />
						    <label for="an">An</label>
						  </div>
						
</td></tr>
                      <script>
        function toggleDateInputs() {
            var radioPer = document.getElementById('an');
            var startInput = document.getElementById('start');
            var endInput = document.getElementById('end');
            if (radioPer.checked) {
                startInput.style.display = 'none';
                endInput.style.display = 'none';
            } else {
                startInput.style.display = 'block';
                endInput.style.display = 'block';
            }
        }
        document.addEventListener('DOMContentLoaded', function() {
            toggleDateInputs();  // Call on initial load
            setInterval(toggleDateInputs, 100); // Call every 1000 milliseconds (1 second)
        });
    </script>
                        <%
                        out.println("<tr>");
                        out.println("<td>Inceput</td>");
                        out.println("<td><input type='date' id='start' name='start' min='1954-01-01' max='2036-12-31'/></td>");
                        out.println("</tr>");
                        out.println("<tr>");
                        out.println("<td>Final</td>");
                        out.println("<td><input type='date' id='end' name='end' min='1954-01-01' max='2036-12-31'/></td>");
                        out.println("</tr>");
                      
                        out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                        out.println("<input type='hidden' name='dep' value='" + userdep + "'/>");
                        out.println("<input type='hidden' name='pag' value='" + 6 + "'/>");
                        out.println("<input type='hidden' name='id' value='" + -1 + "'/>");
                        
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
