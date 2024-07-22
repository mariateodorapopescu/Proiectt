<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
                    if (userType == 1 || userType == 2 || userType == 3) {
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
                    	 
                    	 
                    	%>
                    	
                    	<div class="main-content">
        <div class="header">
            
        </div>
        <div class="content">
            <div class="intro" id="content">
            <h1>Departamente din toata institutia</h1>
                <h3><%out.println(today); %></h3>
               
                 <div class="events">
                <table style="border-bottom: 1px solid #3F48CC;">
                    <thead>
                        <tr style="background-color: #3F48CC; border-bottom: 1px solid #3F48CC;">
                         <th>Nume departament</th>
                            <th>Cod de identificare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM departament")) {
                            ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + rs1.getString("nume_dep") + "</td><td>" + rs1.getString("id_dep") + "</td></tr>");
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            //out.println("</table>");
                        }
                        //out.println(userType == 4 ? "<a href='adminok.jsp'>Inapoi</a>" : "<a href='dashboard.jsp'>Inapoi</a>");
                        %>
                        </tbody>
              </table> 
                            
              </div>
              <div class="into">
                <button id="generate" onclick="generate()" style="--bg:#3F48CC;">Generate PDF</button>
             
                      <%
                    }
                }
            } catch (Exception e) {
                // out.println("Database connection or query error: " + e.getMessage());
                out.println("<script type='text/javascript'>");
                    out.println("alert('Eroare la baza de date!');");
                    out.println("alert('" + e.getMessage() + "');");
                    out.println("</script>");
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
