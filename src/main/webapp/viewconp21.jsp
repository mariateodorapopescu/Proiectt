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
            int idDep = Integer.valueOf(request.getParameter("iddep"));
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id, id_dep FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    if (userType == 4) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {             
                        //out.println("<h1>Vizualizare concedii</h1><br>");
                        String startDate = request.getParameter("start");
            String endDate = request.getParameter("end");
                        String sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                "FROM useri u " +
                                "JOIN tipuri t ON u.tip = t.tip " +
                                "JOIN departament d ON u.id_dep = d.id_dep " +
                                "JOIN concedii c ON c.id_ang = u.id " +
                                "JOIN statusuri s ON c.status = s.status " +
                                "JOIN tipcon ct ON c.tip = ct.tip " +
                                "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ? " +
                                ((startDate != null && endDate != null) ? " AND c.start_c between ? AND ? AND c.end_c <= ?" : ""); // ca sa includ si perioada
                        
                        int ok = 0; // daca a trecut o data prin catch aka a avut eroare aka nu s-a ales perioada (nu a trecut prin pagina de ales perioada)
                  
                	   try (PreparedStatement stmtt = connection.prepareStatement(sql)) 
               		{
                		   if (startDate.compareTo("")!=0) {
                			   // daca nu a ales o data nula
                		   
               			stmtt.setInt(1, userId);
                       stmtt.setInt(2, idDep);
                       if (startDate != null && endDate != null) {
                           stmtt.setString(3, startDate);
                           stmtt.setString(4, endDate);
                           stmtt.setString(5, endDate);
                           out.println("<h1>Vizualizare concedii pentru perioada " + startDate + " - " + endDate +" </h1><br>");
                       }
                       
                       ResultSet rss1 = stmtt.executeQuery();
                       boolean found = false;

                       out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                               "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
						while (rss1.next()) {
                           found = true;
                           out.print("<tr><td>" + rss1.getInt("nr_crt") + "</td><td>" + rss1.getString("departament") + "</td><td>" + 
                                   rss1.getString("nume") + "</td><td>" + rss1.getString("prenume") + "</td><td>" + rss1.getString("functie") + "</td><td>" + 
                                   rss1.getDate("start_c") + "</td><td>" + rss1.getDate("end_c") + "</td><td>" + rss1.getString("motiv") + "</td><td>" + 
                                   rss1.getString("locatie") + "</td>" + "<td>" + rss1.getString("tipcon") + "</td>");
                           
                           if (rss1.getString("status").compareTo("neaprobat") == 0) {
                               out.println("<td style='background-color: rgb(136, 174, 219);'>" + rss1.getString("status") + "</td></tr>");
                           }
                           if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                               out.println("<td style='background-color: rgb(179, 113, 66);'>" + rss1.getString("status") + "</td></tr>");
                           }
                           if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                               out.println("<td style='background-color: rgb(135, 57, 49);'>" + rss1.getString("status") + "</td></tr>");
                           }
                           if (rss1.getString("status").compareTo("aprobat director") == 0) {
                               out.println("<td style='background-color: rgb(64, 133, 74);'>" + rss1.getString("status") + "</td></tr>");
                           }
                           if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                               out.println("<td style='background-color: rgb(204, 197, 94);'>" + rss1.getString("status") + "</td></tr>");
                           }    
						}
                       if (!found) {
                           out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
                       }
                       rss1.close();
                       stmtt.close();
                       } // nu mai ai else, o sa ai finally =)
               		}
               		
               		catch (SQLException e){ // daca n a trecut prin pagina de ales perioada inseamna ca nu e o perioada
               			// daca ajunge in catch, e clar ca start si end sunt nule aka ""
               			ok = 1;
               			out.println("<h1>Vizualizare concedii pe anul curent </h1><br>");
               		PreparedStatement stmtt2 = connection.prepareStatement("SELECT " +
                               "c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                               "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                               "FROM useri u " +
                               "JOIN tipuri t ON u.tip = t.tip " +
                               "JOIN departament d ON u.id_dep = d.id_dep " +
                               "JOIN concedii c ON c.id_ang = u.id " +
                               "JOIN statusuri s ON c.status = s.status " +
                               "JOIN tipcon ct ON c.tip = ct.tip " +
                               "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ?;");
               		stmtt2.setInt(1, userId);
                    stmtt2.setInt(2, idDep);
               ResultSet rss1 = stmtt2.executeQuery();
               boolean found = false;

               out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                       "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
				while (rss1.next()) {
                   found = true;
                   out.print("<tr><td>" + rss1.getInt("nr_crt") + "</td><td>" + rss1.getString("departament") + "</td><td>" + 
                           rss1.getString("nume") + "</td><td>" + rss1.getString("prenume") + "</td><td>" + rss1.getString("functie") + "</td><td>" + 
                           rss1.getDate("start_c") + "</td><td>" + rss1.getDate("end_c") + "</td><td>" + rss1.getString("motiv") + "</td><td>" + 
                           rss1.getString("locatie") + "</td>" + "<td>" + rss1.getString("tipcon") + "</td>");
                   
                   if (rss1.getString("status").compareTo("neaprobat") == 0) {
                       out.println("<td style='background-color: rgb(136, 174, 219);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                       out.println("<td style='background-color: rgb(179, 113, 66);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                       out.println("<td style='background-color: rgb(135, 57, 49);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("aprobat director") == 0) {
                       out.println("<td style='background-color: rgb(64, 133, 74);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                       out.println("<td style='background-color: rgb(204, 197, 94);'>" + rss1.getString("status") + "</td></tr>");
                   }    
				}
               if (!found) {
                   out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
               }
               rss1.close();
               stmtt2.close();
               		}
                	   catch (NullPointerException e){ // daca n a trecut prin pagina de ales perioada inseamna ca nu e o perioada
                  			// daca ajunge in catch, e clar ca start si end sunt nule aka ""
                  			out.println("<h1>Vizualizare concedii pe anul curent </h1><br>");
                  			ok = 1;
                  		PreparedStatement stmtt2 = connection.prepareStatement("SELECT " +
                                  "c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                  "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                  "FROM useri u " +
                                  "JOIN tipuri t ON u.tip = t.tip " +
                                  "JOIN departament d ON u.id_dep = d.id_dep " +
                                  "JOIN concedii c ON c.id_ang = u.id " +
                                  "JOIN statusuri s ON c.status = s.status " +
                                  "JOIN tipcon ct ON c.tip = ct.tip " +
                                  "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ?;");
                  		stmtt2.setInt(1, userId);
                        stmtt2.setInt(2, idDep);
                  ResultSet rss1 = stmtt2.executeQuery();
                  boolean found = false;

                  out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                          "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
   				while (rss1.next()) {
                      found = true;
                      out.print("<tr><td>" + rss1.getInt("nr_crt") + "</td><td>" + rss1.getString("departament") + "</td><td>" + 
                              rss1.getString("nume") + "</td><td>" + rss1.getString("prenume") + "</td><td>" + rss1.getString("functie") + "</td><td>" + 
                              rss1.getDate("start_c") + "</td><td>" + rss1.getDate("end_c") + "</td><td>" + rss1.getString("motiv") + "</td><td>" + 
                              rss1.getString("locatie") + "</td>" + "<td>" + rss1.getString("tipcon") + "</td>");
                      
                      if (rss1.getString("status").compareTo("neaprobat") == 0) {
                          out.println("<td style='background-color: rgb(136, 174, 219);'>" + rss1.getString("status") + "</td></tr>");
                      }
                      if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                          out.println("<td style='background-color: rgb(179, 113, 66);'>" + rss1.getString("status") + "</td></tr>");
                      }
                      if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                          out.println("<td style='background-color: rgb(135, 57, 49);'>" + rss1.getString("status") + "</td></tr>");
                      }
                      if (rss1.getString("status").compareTo("aprobat director") == 0) {
                          out.println("<td style='background-color: rgb(64, 133, 74);'>" + rss1.getString("status") + "</td></tr>");
                      }
                      if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                          out.println("<td style='background-color: rgb(204, 197, 94);'>" + rss1.getString("status") + "</td></tr>");
                      }    
   				}
                  if (!found) {
                      out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
                  }
                  rss1.close();
                  stmtt2.close();
                  		}
               finally {
            	   // asta l am pus ca sa se faca daca nu s-a facut catch aka daca s-a trecut prin pagina de ales perioada
               	if (ok == 0) {
               		// aici de vazut daca alege totusi o perioada sau nu
               		 if (startDate.compareTo("")==0) {
               			 // daca nu a ales o perioada nu pune gen ca nu are ce sa puna
               		PreparedStatement stmtt2 = connection.prepareStatement("SELECT " +
                               "c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                               "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                               "FROM useri u " +
                               "JOIN tipuri t ON u.tip = t.tip " +
                               "JOIN departament d ON u.id_dep = d.id_dep " +
                               "JOIN concedii c ON c.id_ang = u.id " +
                               "JOIN statusuri s ON c.status = s.status " +
                               "JOIN tipcon ct ON c.tip = ct.tip " +
                               "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ?;");
               		stmtt2.setInt(1, userId);
                    stmtt2.setInt(2, idDep);
               ResultSet rss1 = stmtt2.executeQuery();
               boolean found = false;

               out.println("<table border='1'><tr><th>Nr. crt</th><th>Departament</th><th>Nume</th><th>Prenume</th>" +
                       "<th>Functie</th><th>Inceput</th><th>Final</th><th>Motiv</th><th>Locatie</th><th>Tip concediu</th><th>Status</th></tr>");
				while (rss1.next()) {
                   found = true;
                   out.print("<tr><td>" + rss1.getInt("nr_crt") + "</td><td>" + rss1.getString("departament") + "</td><td>" + 
                           rss1.getString("nume") + "</td><td>" + rss1.getString("prenume") + "</td><td>" + rss1.getString("functie") + "</td><td>" + 
                           rss1.getDate("start_c") + "</td><td>" + rss1.getDate("end_c") + "</td><td>" + rss1.getString("motiv") + "</td><td>" + 
                           rss1.getString("locatie") + "</td>" + "<td>" + rss1.getString("tipcon") + "</td>");
                   
                   if (rss1.getString("status").compareTo("neaprobat") == 0) {
                       out.println("<td style='background-color: rgb(136, 174, 219);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                       out.println("<td style='background-color: rgb(179, 113, 66);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                       out.println("<td style='background-color: rgb(135, 57, 49);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("aprobat director") == 0) {
                       out.println("<td style='background-color: rgb(64, 133, 74);'>" + rss1.getString("status") + "</td></tr>");
                   }
                   if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                       out.println("<td style='background-color: rgb(204, 197, 94);'>" + rss1.getString("status") + "</td></tr>");
                   }    
				}
               if (!found) {
                   out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
               }
               rss1.close();
               stmtt2.close();
               		
               	}
              
                   }
               }
                        out.println("</table>");
                       
                       	if (request.getParameter("d") != null) {
                       		 out.println("<a href ='viewconcoldeps.jsp'>Inapoi</a>");
                       	} else {
                       		out.println("<a href ='viewconcols.jsp'>Inapoi</a>");
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
