<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <title>Acasa</title>
    <style>
        iframe {
            width: 100%;
            border: none;
            transition: height 0.5s ease;
            overflow: hidden; /* Hide scrollbars */
            overflow-y: hidden; /* Hide vertical scrollbar */
            /* Hide scrollbar for Chrome, Safari and Opera */
             -ms-overflow-style: none;  /* IE and Edge */
  scrollbar-width: none;  /* Firefox */
height: 90%;
border-radius: 2em;
        }
        iframe::-webkit-scrollbar {
  display: none;
}
        
    </style>
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
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume, id from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("0") != 0) {
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
                    	int id = rs.getInt("id");
                    	String nume = rs.getString("prenume");
                    	 int cate = -1;
                    	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT COUNT(*) AS count FROM concedii WHERE start_c + 3 <= date(NOW()) AND id_ang = ?";
                             try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 stmt.setInt(1, id);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next() && rs2.getInt("count") > 0) {
                                        cate =  rs2.getInt("count");
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
            <h1>Pagina principala</h1>
        </div>
        <div class="content">
            <div class="intro">
                <h1>Bun venit, <% out.println(nume); %>!</h1>
                <h3>Statistici</h3>
                 <div class="events">
                <table style="border-bottom: 1px solid #3F48CC;">
                    <thead>
                        <tr style="background-color: #3F48CC; border-bottom: 1px solid #3F48CC;">
                            <th>Concedii luate</th>
                            <th>Concedii ramase</th>
                            <th>Zile luate</th>
                            <th>Zile ramase</th>
                            <th>Respinse director</th>
                            <th>Respinse sef</th>
                            <th>Aprobate director</th>
                            <th>Aprobate sef</th>
                            <th>In asteptare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, data_nasterii, adresa, email, telefon, username, denumire, nume_dep, zilecons, zileramase, conluate, conramase FROM useri NATURAL JOIN tipuri NATURAL JOIN departament where username = ?")) {
                        	stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + rs1.getString("conluate") + "</td><td>" + rs1.getString("conramase") + "</td><td>" + rs1.getString("zilecons") + "</td><td>" + rs1.getString("zileramase") + "</td>");
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            
                        }
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from concedii where status = -2")) {
                        	//stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<td>" + rs1.getString("total") + "</td>");
                            }
                                                       
                        }
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from concedii where status = -1")) {
                        	//stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<td>" + rs1.getString("total") + "</td>");
                            }
                           
                        }
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from concedii where status = 2")) {
                        	//stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<td>" + rs1.getString("total") + "</td>");
                            }
                           
                        }
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from concedii where status = 1")) {
                        	//stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<td>" + rs1.getString("total") + "</td>");
                            }
                           
                        }
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from concedii where status = 0")) {
                        	//stmt.setString(1, username);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            while (rs1.next()) {
                                found = true;
                                out.println("<td>" + rs1.getString("total") + "</td></tr>");
                            }
                           
                        }
                        %>
                    </tbody>
                </table> 
                </div>
                
                
                <%
               int cate2 = -1;
                             	if (cate >= 1) {
                             		 String query2 = "SELECT CASE WHEN DATEDIFF(start_c, date(NOW())) between 0 and 4 THEN DATEDIFF(start_c, date(NOW())) ELSE -1 END AS dif FROM concedii WHERE id_ang = ? order by dif desc limit 1;";
                                     try (PreparedStatement stmt = connection.prepareStatement(query2)) {
                                         stmt.setInt(1, id);
                                         try (ResultSet rs2 = stmt.executeQuery()) {
                                             if (rs2.next() && rs2.getInt("dif") > 0) {
                                                cate2 =  rs2.getInt("dif");
                                                
                                             }
                                         }
                                     }
                                     if (cate2 > 0)
                             		out.println ("Aveti un concediu in mai putin de " + cate2 + " zile!");
                             	}
               %>
               </div>
           
        
    </div>
                       <%
                    }
                }
            } catch (Exception e) {
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
</body>
</html>
