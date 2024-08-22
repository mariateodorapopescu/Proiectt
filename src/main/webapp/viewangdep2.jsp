<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int id = rs.getInt("id");
                    if (userType != 0) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        int idDep = Integer.valueOf(request.getParameter("iddep"));
                        
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
                                stmt.setInt(1, id);
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
    <title>Vizualizare angajati</title>
       <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js" integrity="sha512-GsLlZN/3F2ErC5ifS5QtgpiJtWd43JWSuIgh7mbzZ8zBps+dvLusV+eNQATqgA/HdeKFVgA5v3S/cIrLF7QnIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <style>
    
    a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
    
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

                    	<div class="main-content">
        <div class="header">
         </div>
        <div style="border-radius:2rem;" class="content">
             <div class="intro" style="border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">       	
                    	<%
                        
                        PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                        stm.setInt(1, idDep);
                        ResultSet rs2 = stm.executeQuery();
                        String deptName = "";
                        if (rs2.next()) {
                            deptName = rs2.getString("nume_dep");
                        }
                       
%>              	
                    	
                 <div class="events" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                  <% out.println("<h1>Vizualizare angajati din departamentul " + deptName + "</h1>"); 
                  out.println("<h3>" + today + "</h3>"); 
                  
                  %>
                <table >
                    <thead>
                        <tr style="color:<%out.println("white");%>">
                    <th>Nr. crt.</th>    
                    <th>Nume</th>
                    <th>Prenume</th>
                    
                    <th>Functie</th>
                    <th>Departament</th>
                    
                </tr>
            </thead>
            <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                        

<%

                        PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, username, denumire, nume_dep FROM useri left JOIN tipuri on tipuri.tip = useri.tip left JOIN departament on departament.id_dep = useri.id_dep WHERE useri.id_dep = ? and username <> \"test\"");
                        stmt.setInt(1, idDep);
                        ResultSet rs1 = stmt.executeQuery();
                        boolean found = false;
                        int nr = 1;
                        while (rs1.next()) {
                            found = true;
                            out.println("<tr><td>" + nr++ + "</td><td> " + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");
                        }
                        if (!found) {
                            out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                        }
                        %>
                         </tbody>
                </table> 
                              
                </div>
                 <div class="into">
                  <button id="generate" onclick="generate()" >Descarcati PDF</button>
                <%
                 
            		
            			out.println("<button><a href='viewangdep.jsp'>Inapoi</a></button></div>");
         		
                  
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
                        rs1.close();
                        stmt.close();
                        stm.close();
                        
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
