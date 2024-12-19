<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%
    HttpSession sesi = request.getSession(false);
int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
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
                    	 String accent = null;
                      	 String clr = null;
                      	 String sidebar = null;
                      	 String text = null;
                      	 String card = null;
                      	 String hover = null;
                      	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT * from teme where id_usr = ?";
                             try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 stmt.setInt(1, userId);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next()) {
                                       accent =  rs2.getString("accent");
                                       clr =  rs2.getString("clr");
                                       sidebar =  rs2.getString("sidebar");
                                       text = rs2.getString("text");
                                       card =  rs2.getString("card");
                                       hover = rs2.getString("hover");
                                     }
                                 }
                             }
                             // Display the user dashboard or related information
                             //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                             // Add additional user-specific content here
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                      	 %> 
<html>

<head>
    <title>Vizualizare concedii</title>
     <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js" integrity="sha512-GsLlZN/3F2ErC5ifS5QtgpiJtWd43JWSuIgh7mbzZ8zBps+dvLusV+eNQATqgA/HdeKFVgA5v3S/cIrLF7QnIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
        
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
  
        .status-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 14px;
        }
        
        .status-neaprobat { background-color: #88aedb; }
        .status-dezaprobat-sef { background-color: #b37142; }
        .status-dezaprobat-director { background-color: #873931; }
        .status-aprobat-director { background-color: #40854a; }
        .status-aprobat-sef { background-color: #ccc55e; }
        .status-pending { background-color: #e0a800; }
       
       /* Tooltip */
       	.tooltip {
		  position: relative; 
		  border-bottom: 1px dotted black; 
		}
		
		.tooltip .tooltiptext {
		  visibility: hidden;
		  width: 120px;
		  background-color: rgba(0,0,0,0.5);
		  color: white;
		  text-align: center;
		  padding: 5px 0;
		  border-radius: 6px;
		  position: absolute;
		  z-index: 1;
		}
		
		.tooltip:hover .tooltiptext {
		  visibility: visible;
		}
       .content, .main-content {
    overflow: auto; /* Permite scroll-ul orizontal */
    width: 100%; /* Asigură că folosește întreaga lățime disponibilă */
}
       
::-webkit-scrollbar {
		    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
		       
    </style>
</head>

<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                      	 <%
                    	 int id = Integer.valueOf(request.getParameter("id"));
                    	 int status = Integer.valueOf(request.getParameter("status"));
                    	 int tip = Integer.valueOf(request.getParameter("tip"));
                    	 int dep = Integer.valueOf(request.getParameter("dep"));
                    	 String an =  request.getParameter("an");
                    	 int perioada = 0;
                    	 String start = null;
                    	 String end = null;
                    	
                    	if (an == null) {
                    		perioada = 1;
                    		start = request.getParameter("start");
                    		end = request.getParameter("end");
                    		if (start.compareTo("")==0) {
                    			perioada = 0;
                    		}
                    		if (end.compareTo("")==0) {
                    			perioada = 0;
                    		}
                    	}
                    	
                    	 pag = Integer.valueOf(request.getParameter("pag"));
                    	
                    	String sql = null;
                    	PreparedStatement stmtt2 = null;
                    	%>
                    	
                    	<div class="main-content" style="background:<%out.println(clr);%>; ">
        <div class="header">
         </div>
        <div class="content" style="border-radius: 2rem; margin-top:5%; ">
            <div class="intro" style="border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%> ">             	
                    	
                 <div class="events"  style="border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                 <%
                    	
                    	if (pag == 3) {
               			 out.println("<h1> Vizualizare concedii personale");
             				
               		}
               		if (pag == 4) {
               		
                    	 out.println("<h1> Vizualizare concedii ale unui angajat");

                     }
               		
               		if (pag == 5) {
              			 out.println("<h1> Vizualizare concedii ale unui coleg din departamentul meu");
            				
              		}
               		if (pag == 6) {
             			 out.println("<h1> Vizualizare concedii din departamentul meu");
           				
             		}
               		if (pag == 7) {
                     	out.println("<h1> Vizualizare concedii dintr-un departament ");
           				
             		}
               		if (pag == 8) {
            			 out.println("<h1> Vizualizare concedii din toata institutia");
          				
            		}
               		
               		if (perioada == 0) {
               			out.println(" pe an. </h1>");
               		} else 
               		{
               			out.println(" pe perioada " + start + " - " + end + ". </h1>");
               		}
                    	
               		String today = null;
                  	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                           // Check for upcoming leaves in 3 days
                           String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                           try (PreparedStatement stmt = connection.prepareStatement(query)) {
                               // stmt.setInt(1, id);
                               try (ResultSet rs2 = stmt.executeQuery()) {
                                   if (rs2.next()) {
                                     today =  rs2.getString("today");
                                   }
                               }
                           }
                          
                           // Display the user dashboard or related information
                           //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                           // Add additional user-specific content here
                       } catch (SQLException e) {
                           out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                           e.printStackTrace();
                       }
                    	
                    	%>
 	
                <h3><%out.println(today); %></h3>
                <table style="color: white">
                    <thead style="color: white">
                        <tr style="color: white">
                    
                    <th style="color:white">Nr.crt</th>
                    <th style="color:white">Nume</th>
                    <th style="color:white">Prenume</th>
                    <th style="color:white">Functie</th>
                    <th style="color:white">Departament</th>
                    <th style="color:white">Inceput</th>
                    <th style="color:white">Final</th>
                    <th style="color:white">Motiv</th>
                    <th style="color:white">Locatie</th>
                    <th style="color:white">Tip</th>
                    <th style="color:white">Adaugat</th>
                    <th style="color:white">Modificat</th>
                     <th style="color:white">Vazut</th>
                    <th style="color:white">Status</th>
                    
                     
                </tr>
            </thead>
             <tbody style="background:<%out.println(clr);%>; color:<%out.println(text);%>">
                   <% 	
                   sql = "SELECT c.acc_res, c.added, c.modified, c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                           "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                           "FROM useri u " +
                           "JOIN tipuri t ON u.tip = t.tip " +
                           "JOIN departament d ON u.id_dep = d.id_dep " +
                           "JOIN concedii c ON c.id_ang = u.id " +
                           "JOIN statusuri s ON c.status = s.status " +
                           "JOIN tipcon ct ON c.tip = ct.tip ";
                    	if (pag == 3 || pag == 4 || pag == 5) {
                    		// aici se adauga id_ang pentru ca: personal, angajat, coleg de departament
                    		sql = sql + " where c.id_ang = ? and u.username <> " + "\"test\"";
                    		
                    		int nr = 1;
                    		int nrt = -1;
                    		int nrs = -1;
                    		int nrp1 = -1;
                    		int nrp2 = -1;
                    		int nrp3 = -1;
                    		
                    		if (perioada == 0) {
                    			sql = sql + " and YEAR(c.start_c) = YEAR(CURDATE()) ";
                    		}
                    		
                    		if (tip != -1) {
                    			sql = sql  + " and c.tip = ? ";
                    			nr++;
                    			nrt = nr;
                  		}
                    		if (status != 3) {
                    			sql = sql  + " and c.status = ? ";
                    			nr++;
                    			nrs = nr;
                  		}
                    		
                    		if (perioada == 1) {
                    			sql = sql  + " and YEAR(c.start_c) = YEAR(CURDATE()) AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			nr++;
                    			nrp1 = nr;
                    			nr++;
                    			nrp2 = nr;
                    			nr++;
                    			nrp3 = nr;
                    		}
                    		 
                    		stmtt2 = connection.prepareStatement(sql);
                    		stmtt2.setInt(1, id);
                    		
                    		if (nrt != -1) {
                    			stmtt2.setInt(nrt, tip);
                    		}
                    		
                    		if (nrs != -1) {
                    			stmtt2.setInt(nrs, status);
                    		}
                    		
                    		if (nrp1 != -1) {
                    			stmtt2.setString(nrp1, start);
                    			stmtt2.setString(nrp2, end);
                    			stmtt2.setString(nrp3, end);
                    		}
                    	}
                    	
                    	if (pag == 6 || pag == 7) {
                    		// aici adaug departamentul
							sql = sql + " where u.id_dep = ? and u.tip <> 4 ";
                    		
                    		if (pag == 6) {
                    			sql = sql + " and c.id_ang <> " + userId;
                    		}
                    		
                    		if (pag == 7 && dep == userDep) {
                    			sql = sql + " and c.id_ang <> " + userId;
                    		}
                    		
                    		int nr = 1;
                    		int nrt = -1;
                    		int nrs = -1;
                    		int nrp1 = -1;
                    		int nrp2 = -1;
                    		int nrp3 = -1;
                    		
                    		if (perioada == 0) {
                    			sql = sql + " and YEAR(c.start_c) = YEAR(CURDATE()) ";
                    		}
                    		
                    		if (tip != -1) {
                    			sql = sql  + " and c.tip = ? ";
                    			nr++;
                    			nrt = nr;
                  		}
                    		if (status != 3) {
                    			sql = sql  + " and c.status = ? ";
                    			nr++;
                    			nrs = nr;
                  		}
                    		
                    		if (perioada == 1) {
                    			sql = sql  + " and YEAR(c.start_c) = YEAR(CURDATE()) AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			nr++;
                    			nrp1 = nr;
                    			nr++;
                    			nrp2 = nr;
                    			nr++;
                    			nrp3 = nr;
                    		}
                    		 
                    		stmtt2 = connection.prepareStatement(sql);
                    		stmtt2.setInt(1, dep);
                    		
                    		if (nrt != -1) {
                    			stmtt2.setInt(nrt, tip);
                    		}
                    		
                    		if (nrs != -1) {
                    			stmtt2.setInt(nrs, status);
                    		}
                    		
                    		if (nrp1 != -1) {
                    			stmtt2.setString(nrp1, start);
                    			stmtt2.setString(nrp2, end);
                    			stmtt2.setString(nrp3, end);
                    		}
                    		
                    	}
                    	if (pag == 8) {
                    		// aici e pe toata institutia
                    		
                    		sql = sql + " and u.id <> " + userId; 
                    		
                    		int nr = 0;
                    		int nrt = -1;
                    		int nrs = -1;
                    		int nrp1 = -1;
                    		int nrp2 = -1;
                    		int nrp3 = -1;
                    		
                    		String word = " and ";
                    		if (perioada == 0) {
                    			nr++;
                    			if (nr == 1) {
                    				word = " where ";
                    			}
                    			sql = sql + word + " YEAR(c.start_c) = YEAR(CURDATE()) ";
                    		}
                    		
                    		if (tip != -1) {
                    			nr++;
                    			if (nr == 1) {
                    				word = " where ";
                    			}
                    			sql = sql + word + " c.tip = ? ";
                    			nrt = nr;
                  		}
                    		if (status != 3) {
                    			nr++;
                    			if (nr == 1) {
                    				word = " where ";
                    			}
                    			sql = sql + word  + " c.status = ? ";
                    			nrs = nr;
                  		}
                    		
                    		if (perioada == 1) {
                    			nr++;
                    			nrp1 = nr;
                    			if (nr == 1) {
                    				word = " where ";
                    			}
                    			sql = sql + word + " YEAR(c.start_c) = YEAR(CURDATE()) AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			nr++;
                    			nrp2 = nr;
                    			nr++;
                    			nrp3 = nr;
                    		}
                    		 
                    		stmtt2 = connection.prepareStatement(sql);
                    		
                    		if (nrt != -1) {
                    			stmtt2.setInt(nrt, tip);
                    		}
                    		
                    		if (nrs != -1) {
                    			stmtt2.setInt(nrs, status);
                    		}
                    		
                    		if (nrp1 != -1) {
                    			stmtt2.setString(nrp1, start);
                    			stmtt2.setString(nrp2, end);
                    			stmtt2.setString(nrp3, end);
                    		}
                    	}
                    	
                    	  ResultSet rss1 = stmtt2.executeQuery();
                          boolean found = false;
							int nr = 1;
							if (!rss1.next()) {
								 
		                              out.println("<tr><td colspan='14'>Nu exista date.</td></tr>");
		        
		                          rss1.close();
		                          stmtt2.close();
							} else {
                          while (rss1.next()) {
                              found = true;
                              
                                String added = rss1.getString("added") != null ? rss1.getString("added") : " - ";
                                String modif = rss1.getString("modified") != null ? rss1.getString("modified") : " - ";
                                String accres = rss1.getString("acc_res") != null ? rss1.getString("acc_res") : " - ";
                                		
                                out.print("<tr><td data-label='Nr.crt'>" + nr + "</td><td data-label='Nume'>" +
                                        rss1.getString("nume") + "</td><td data-label='Prenume'>" + rss1.getString("prenume") + "</td><td data-label='Fct'>" + rss1.getString("functie") + "</td><td data-label='Dep'>" + rss1.getString("departament") + 
                                        "</td>" + "<td data-label='Inceput'>" +
                                        		rss1.getString("start_c")+ "</td><td data-label='Final'>" + rss1.getString("end_c") + "</td><td data-label='Motiv'>" + rss1.getString("motiv") + "</td><td data-label='Locatie'>" +
                                        rss1.getString("locatie") + "</td>" + "<td data-label='Tip'>" + rss1.getString("tipcon") + "</td>" + "<td data-label='Adaugat'>" + added + "</td>" + "<td data-label='Modif'>" + modif + "</td>"+ 
                                        "<td data-label='Acc/Res'>" + accres + "</td>");

                              if (rss1.getString("status").compareTo("neaprobat") == 0) {
                            	  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Neaprobat</span><span class='status-icon status-neaprobat'><i class='ri-focus-line'></i></span></td>");
                                
                              }
                              if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                            	  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Dezaprobat sef</span><span class='status-icon status-dezaprobat-sef'><i class='ri-close-line'></i></span></td>");
                                  //out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-sef'><i class='ri-close-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                            	  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Dezaprobat director</span><span class='status-icon status-dezaprobat-director'><i class='ri-close-line'></i></span></td>");
                                  //out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-director'><i class='ri-close-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("aprobat director") == 0) {
                            	  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Aprobat director</span><span class='status-icon status-aprobat-director'><i class='ri-checkbox-circle-line'></i></span></td>");
                                  //out.println("<td data-label='Status'><span class='status-icon status-aprobat-director'><i class='ri-checkbox-circle-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                            	  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Aprobat sef</span><span class='status-icon status-aprobat-sef'><i class='ri-checkbox-circle-line'></i></span></td>");
                                  //out.println("<td data-label='Status'><span class='status-icon status-aprobat-sef'><i class='ri-checkbox-circle-line'></i></span></td></tr>");
                              }
                              nr++;
                          }
							}
                          if (!found) {
                              out.println("<tr><td colspan='14'>Nu exista date.</td></tr>");
                          }
                          rss1.close();
                          stmtt2.close();
                        
                    }
           %>
            </tbody>
                </table> 
                              
                </div>
                
                  <button id="generate" onclick="generate()">Descarcati PDF</button>
                  <%
                  if (pag == 3) {
            			 out.println("<button ><a href='viewp.jsp'>Inapoi</a></button></div>");
            		}
            		if (pag == 4) {
            			out.println("<button ><a href='viewcol.jsp'>Inapoi</a></button></div>");
                 	  }
            		if (pag == 5) {
            			out.println("<button ><a href='viewconcoldepeu.jsp'>Inapoi</a></button></div>");
           			 }
            		if (pag == 6) {
            			out.println("<button ><a href='viewdepeu.jsp'>Inapoi</a></button></div>");
          			 }
            		if (pag == 7) {
            			out.println("<button ><a href='viewcondep.jsp'>Inapoi</a></button></div>");
                  		}
            		if (pag == 8) {
            			out.println("<button ><a href='viewtot.jsp'>Inapoi</a></button></div>");
         			}
                  
                  %>
               
                <script>
              
                function generate() {
                    const element = document.getElementById('content'); // Ensure you target the specific div
                    html2pdf().set({
                        pagebreak: { mode: ['css', 'legacy'] },
                        html2canvas: {
                            scale: 1, // Adjust scale to manage the size and visibility of content
                            logging: true,
                            dpi: 192,
                            letterRendering: true,
                            useCORS: true // This helps handle external content like images
                        },
                        jsPDF: {
                            unit: 'in',
                            format: 'a4',
                            orientation: 'landscape' // Change to 'landscape' if the content is too wide
                        }
                    }).from(element).save();
                }

            </script>
           <%
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