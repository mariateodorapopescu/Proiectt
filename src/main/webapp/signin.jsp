<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Definire utilizator</title>
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
                    	
                    	out.println("<div align=\"center\">");
                    	out.println("<h1>Definire Utilizator</h1>");
                    	out.print("<form action=\"");
                    	request.getContextPath();
                    	out.println("register\" method=\"post\">");
                    	out.println("<table style=\"with: 80%\">");
                    	out.println("<tr>");
                    	out.println("<td>Nume</td>");
                    	out.println("<td><input type='text' name='nume' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Prenume</td>");
                    	out.println("<td><input type='text' name='prenume' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Data nasterii</td>");
                    	out.println("<td><input type='date' id='start' name='data_nasterii' value='2001-07-22' min='1954-01-01' max='2036-12-31' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Adresa</td>");
                    	out.println("<td><input type='text' name='adresa' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>E-mail</td>");
                    	out.println("<td><input type='text' name='email' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Telefon</td>");
                    	out.println("<td><input type='text' name='telefon' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>UserName</td>");
                    	out.println("<td><input type='text' name='username' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Password</td>");
                    	out.println("<td><input type='password' name='password' required/></td>");
                    	out.println("</tr>");

                    	out.println("<tr>");
                    	out.println("<td>Departament</td>");
                    	out.println("<td><select name='departament'>");

                         try {
                             Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                             Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                             String sql = "SELECT id_dep, nume_dep FROM departament;";
                             PreparedStatement stmt = con.prepareStatement(sql);
                             ResultSet rs1 = stmt.executeQuery();

                             if (!rs1.next()) {
                                 out.println("No Records in the table");
                             } else {
                                 do {
                                     out.println("<option value='" + rs1.getString("id_dep") + "' required>" + rs1.getString("nume_dep") + "</option>");
                                 } while (rs1.next());
                             }
                             rs1.close();
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
                         out.println("<td><select name='tip'>");
                         try
                         {
                           
                           Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                           Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false","root","student");
                           String sql = "select tip, denumire from tipuri;";
                           PreparedStatement stmt = con.prepareStatement(sql);
                           ResultSet rs2 = stmt.executeQuery();
                           if(rs2.next()==false)
                           {
                             out.println("No Records in the table");
                           }
                           else
                           {
                             do {
                             	 out.println("<option value='" + rs2.getString("tip") + "' required>" + rs2.getString("denumire") + "</option>");
                             } while(rs2.next());
                           } 
                         }
                         catch(Exception e)
                         {
                         System.out.println(e.getMessage());
                         e.getStackTrace();
                         }
                         out.println("</select>");
                         out.println("</td>");
                         out.println("</tr>");
                         out.println("</table>");
                         out.println("<input type='submit' value='Submit' />");
                         out.println("</form>");
                         out.println("</div>");       
                         out.println("<a href ='adminok.jsp'>Inapoi</a>");
                         
                         if ("true".equals(request.getParameter("p"))) {
                        	    out.println("Parola trebuie sa contina:<br>");
                        	    out.println("- minim 8 caractere<br>");
                        	    out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
                        	    out.println("- o litera mare<br>");
                        	    out.println("- o litera mica<br>");
                        	    out.println("- o cifra<br>");
                        	    out.println("- cifrele alaturate sa nu fie egale sau consecutive<br>");
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