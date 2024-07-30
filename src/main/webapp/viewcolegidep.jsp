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
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id_dep, id FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    int id = rs.getInt("id");
                    if (userType == 1 || userType == 2 || userType == 4) {
                    	 if (rs.getString("tip").compareTo("1") == 0) {
                         	response.sendRedirect("tip1ok.jsp");
                         }
                         if (rs.getString("tip").compareTo("2") == 0) {
                         	response.sendRedirect("tip2ok.jsp");
                         }
                         if (rs.getString("tip").compareTo("3") == 0) {
                         	response.sendRedirect("sefok.jsp");
                         }
                         if (rs.getString("tip").compareTo("4") == 0) {
                          	response.sendRedirect("adminok.jsp");
                          }
                    } else {
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
         <div class="content">
            <div class="intro" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
            
               
                 <div class="events"  style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                 <h1>Angajati din departamentul meu</h1>
                <h3><%out.println(today); %></h3>
                <table >
                    <thead>
                         <tr style="color:<%out.println("white");%>">
                            <th>Nume</th>
                            <th>Prenume</th>
                            <th>Nume utilizator</th>
                            <th>Functie</th>
                            <th>Departament</th>
                        </tr>
                    </thead>
                    <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                    
                    	<%
                        //out.println("<h1>Vizualizare angajati din toata institutia</h1><br>");
                        //out.println("<table border='1'><tr><th>Nume</th><th>Prenume</th><th>Username</th><th>Tip</th><th>Departament</th></tr>");
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM useri left join tipuri on useri.tip = tipuri.tip left join departament on departament.id_dep = useri.id_dep where useri.id_dep = ?")) {
                            stmt.setInt(1, userdep);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("username") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");   
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            out.println("</table>");
                            //out.println(userType == 4 ? "<a href='adminok.jsp'>Inapoi</a>" : "<a href='dashboard.jsp'>Inapoi</a>");
                        }
                        %>
                          </tbody>
                </table> 
                              
                </div>
                <div class="intro" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                 <button id="generate" onclick="generate()" >Descarcati PDF</button>
                 <button ><a href='viewang.jsp'>Inapoi</a></button></div>
                        <%
                        
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
    	        out.println("alert('Eroare la baza de date!');");
    	        out.println("</script>");
                response.sendRedirect("viewcolegidep.jsp");
            }
        } else {
        	out.println("<script type='text/javascript'>");
	        out.println("alert('Utilizator neconectat!');");
	        out.println("</script>");
            response.sendRedirect("logout");
        }
    } else {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }

%>
<script>
                   

                    function generate() {
                        const element = document.getElementById("content");
                        html2pdf()
                        .from(element)
                        .save();
                    }

                   
                </script>
</body>
</html>
