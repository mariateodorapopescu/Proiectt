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
            String originalUsername = request.getParameter("username"); // Get the original username to use in SQL queries and keep it constant
            String username = request.getParameter("username");
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?");
            preparedStatement.setString(1, originalUsername);
            ResultSet rs = preparedStatement.executeQuery();
			int userType = rs.getInt("tip");
            if (!rs.next()) {
                out.println("Nu exista date.");
                // Redirect or handle error appropriately
            } else {
            	out.println("<div align='center'>");
            	out.println("<h1>Modificare User</h1>");
            	out.println("<form action='modifusr' method='post'>");
            	out.println("<input type='hidden' name='originalUsername' value='" + originalUsername + "'/>"); // Pass the original username as a hidden field
            	out.println("<table style='width: 80%'>");
            	out.println("<tr>");
            	out.println("<td>Nume</td>");
            	out.println("<td>");
            	String tomodify = request.getParameter("username");
                if (tomodify != null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT nume FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify);
                      ResultSet rs3 = stmt.executeQuery();
                      if (rs3.next()) {
                          do {
                              out.println("<input type='text' name='nume' value='" + rs3.getString("nume") + "'>");
                          } while (rs3.next());
                      } else {
                      	out.println("<input type='text' name='nume'>");
                      }
                      rs3.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='text' name='nume'>");
                      e.printStackTrace();
                    }
                }
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Prenume</td>");
                out.println("<td>");
                
                String tomodify2 = request.getParameter("username");
                if (tomodify2 != null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT prenume FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify2);
                      ResultSet rs1 = stmt.executeQuery();
                      if (rs1.next()) {
                          do {
                              out.println("<input type='text' name='prenume' value='" + rs1.getString("prenume") + "'>");
                          } while (rs1.next());
                      } else {
                      	out.println("<input type='text' name='prenume'>");
                      }
                      rs1.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='text' name='prenume'>");
                      e.printStackTrace();
                    }
                }
                
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Data nasterii</td>");
                out.println("<td>");
                String tomodify3 = request.getParameter("username");
                System.out.println(tomodify3);
                if (username!= null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT data_nasterii FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify3);
                      ResultSet rs2 = stmt.executeQuery();
                      if (rs2.next()) {
                          do {
                              out.println("<input type='date' id='start' name='data_nasterii' value='" + rs2.getString("data_nasterii") + "' min='1954-01-01' max='2036-12-31'>");
                          } while (rs2.next());
                      } else {
                      	out.println("<input type='date' id='start' name='data_nasterii' value='2001-07-01' min='1954-01-01' max='2036-12-31'>");
                      }
                      rs2.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='date' id='start' name='data_nasterii' value='2001-07-01' min='1954-01-01' max='2036-12-31'>");
                      e.printStackTrace();
                    }
                }
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Adresa</td>");
                out.println("<td>");
                String tomodify4 = request.getParameter("username");
                if (tomodify4 != null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT adresa FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify4);
                      ResultSet rs4 = stmt.executeQuery();
                      if (rs4.next()) {
                          do {
                              out.println("<input type='text' name='adresa' value='" + rs4.getString("adresa") + "'>");
                          } while (rs4.next());
                      } else {
                      	out.println("<input type='text' name='adresa'>");
                      }
                      rs4.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='text' name='adresa'>");
                      e.printStackTrace();
                    }
                }
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>E-mail</td>");
                out.println("<td>");
                String tomodify5 = request.getParameter("username");
                if (tomodify5 != null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT email FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify2);
                      ResultSet rs5 = stmt.executeQuery();
                      if (rs5.next()) {
                          do {
                              out.println("<input type='text' name='email' value='" + rs5.getString("email") + "'>");
                          } while (rs5.next());
                      } else {
                      	out.println("<input type='text' name='email'>");
                      }
                      rs5.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='text' name='email'>");
                      e.printStackTrace();
                    }
                }
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Telefon</td>");
                out.println("<td>");
                String tomodify6 = request.getParameter("username");
                if (tomodify6 != null) {
                    try {
                      Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                      Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                      String sql = "SELECT telefon FROM useri WHERE username = ?";
                      PreparedStatement stmt = con.prepareStatement(sql);
                      stmt.setString(1, tomodify2);
                      ResultSet rs6 = stmt.executeQuery();
                      if (rs6.next()) {
                          do {
                              out.println("<input type='text' name='telefon' value='" + rs6.getString("telefon") + "'>");
                          } while (rs6.next());
                      } else {
                      	out.println("<input type='text' name='telefon'>");
                      }
                      rs6.close();
                      stmt.close();
                      con.close();
                    } catch (Exception e) {
                  	  out.println("<input type='text' name='telefon'>");
                      e.printStackTrace();
                    }
                }
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>UserName</td>");
                String tomodify7 = request.getParameter("username"); 
                out.println("<td><input type='text' name='username' value='" + tomodify7 + "'></td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Password</td>");
                out.println("<td><input type=\"password\" name=\"password\" disabled/></td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Departament</td>");
                out.println("<td>");
                String tomodify8 = request.getParameter("username");
                String id_dep = null;
                String den_dep = null;
                if (tomodify8 != null) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT u.id_dep as id_d, d.nume_dep as den_dep FROM useri u JOIN departament d ON u.id_dep = d.id_dep WHERE username = ?";
                        PreparedStatement stmt = con.prepareStatement(sql);
                        stmt.setString(1, tomodify8);
                        ResultSet rs7 = stmt.executeQuery();
                        if (rs7.next()) {
                            id_dep = rs7.getString("id_d");
                            den_dep = rs7.getString("den_dep");
                        }
                        rs7.close();
                        stmt.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                out.println("<select name=\"departament\">");
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    String sql = "SELECT id_dep, nume_dep FROM departament;";
                    PreparedStatement stmt = con.prepareStatement(sql);
                    ResultSet rs8 = stmt.executeQuery();

                    while (rs8.next()) {
                        String depId = rs8.getString("id_dep");
                        String depName = rs8.getString("nume_dep");
                        String selected = "";
                        if (depId.equals(id_dep)) {
                            selected = "selected";
                        }
                        out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                    }
                    rs8.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println("</select>");
                out.println("</td>");
                out.println("</tr>");
                out.println("<tr>");
                out.println("<td>Tip/Ierarhie</td>");
                out.println("<td>");
                String tomodify9 = request.getParameter("username");
                String tip = null;
                String nume = null;
                if (tomodify9 != null) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT u.tip as tiip, t.denumire as den_tip FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE username = ?";
                        PreparedStatement stmt = con.prepareStatement(sql);
                        stmt.setString(1, tomodify9);
                        ResultSet rs9 = stmt.executeQuery();
                        if (rs9.next()) {
                            tip = rs9.getString("tiip");
                            nume = rs9.getString("den_tip");
                        }
                        rs9.close();
                        stmt.close();
                        con.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                out.println("<select name=\"tip\">");
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    String sql = "SELECT tip, denumire FROM tipuri;";
                    PreparedStatement stmt = con.prepareStatement(sql);
                    ResultSet rs10 = stmt.executeQuery();

                    while (rs10.next()) {
                        String depId = rs10.getString("tip");
                        String depName = rs10.getString("denumire");
                        String selected = "";
                        if (depId.equals(id_dep)) {
                            selected = "selected";
                        }
                        out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
                    }
                    rs10.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                    e.printStackTrace();
                }
                out.println("</select>");
                out.println("</td>");
                out.println("</tr>");
                out.println("</table>");
                out.println("<input type='submit' value='Submit' />");
                out.println("</form>");
                
                out.println("</div>");
               	out.println("<a href ='modifusr1.jsp'>Inapoi</a>");
                
                if ("true".equals(request.getParameter("p"))) {
                    out.println("Parola trebuie sa contina:<br>");
                    out.println("- minim 8 caractere<br>");
                    out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
                    out.println("- o litera mare<br>");
                    out.println("- o litera mica<br>");
                    out.println("- o cifra<br>");
                    out.println("- ciferele alaturate sa nu fie egale sau consecutive<br>");
                    out.println("- literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele");
                }
                
                if ("true".equals(request.getParameter("n"))) {
                    out.println("Nume scris incorect");
                }
                
                if ("true".equals(request.getParameter("pn"))) {
                    out.println("Prenume scris incorect");
                }
                
                if ("true".equals(request.getParameter("t"))) {
                    out.println("Telefon scris incorect");
                }
               
                if ("true".equals(request.getParameter("e"))) {
                    out.println("e-mail scris incorect");
                }
                
                if ("true".equals(request.getParameter("dn"))) {
                    out.println("Utilizatorul trebuie sa aiba minim 18 ani!");
                }

            }
            rs.close();
            preparedStatement.close();
            connection.close();
        } else {
            response.sendRedirect("login.jsp");
        }
    } else {
        response.sendRedirect("login.jsp");
    }
%>
</body>
</html>