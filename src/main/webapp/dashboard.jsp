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
    
    <title>Dashboard</title>
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
                    	 int cate = -1;
                    	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT COUNT(*) AS count FROM concedii WHERE start_c <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND id_ang = ?";
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
                    	
                        out.println("<div class='container'>");
                        out.println("<div class='login__content'>");
                        out.println("<img src='./responsive-login-form-main/assets/img/bg-login.jpg' alt='login image' class='login__img login__img-light'>");
                        out.println("<img src='./responsive-login-form-main/assets/img/bg-login-dark.jpg' alt='login image' class='login__img login__img-dark'>");
                       
                        out.println("<div class='login__form'>");
                        out.println("<div class='login__inputs'>");
                        out.println("<h1>Bun venit, " + rs.getString("prenume") + "!</h1>");
                        //out.println("<label for='menu' class='login__label'>Meniu</label>");
                        		// select date_checked from date_logs ORDER BY date_checked DESC LIMIT 1;
                        		// select * from concedii where start_c + 3 <= (select date_checked from date_logs ORDER BY date_checked DESC LIMIT 1) and id_ang = ?;
                        		
                        		%>
                        		<script>
                        		const date = new Date();
								
								let day = date.getDate();
								let month = date.getMonth() + 1;
								let year = date.getFullYear();
								
								// This arrangement can be altered based on how we want the date's format to appear.
								let currentDate = year + '-' + month + '-' + day;
								console.log(currentDate); // "17-6-2022"
								</script>
                        		<%
                        		int cate2 = -1;
                             	if (cate == 1) {
                             		 String query2 = "SELECT CASE WHEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) between 0 and 4 THEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) ELSE -1 END AS dif FROM concedii WHERE id_ang = ? order by dif desc limit 1";
                                     try (PreparedStatement stmt = connection.prepareStatement(query2)) {
                                         stmt.setInt(1, id);
                                         try (ResultSet rs2 = stmt.executeQuery()) {
                                             if (rs2.next() && rs2.getInt("dif") > 0) {
                                                cate2 =  rs2.getInt("dif");
                                             }
                                         }
                                     }
                             		out.println ("Aveti un concediu in mai putin de " + cate2 + " zile!");
                             	}
                        		out.println("<button id='menu'><a href = 'vizualizareconcedii.jsp'>Vizualizare concedii </a></button>");
                        out.println("<select name='menu' id='menu' class='login__input' onchange='location = this.value;'>");
                        out.println("<option value=''>Selecteaza o optiune</option>");
                        out.println("<option value='addc.jsp'>Adaugare concediu</option>");
                        out.println("<option value='modifc1.jsp'>Modificare concediu</option>");
                        out.println("<option value='delcon1.jsp'>Stergere concediu</option>");
                        out.println("<option value='aprobdir.jsp'>Aprobare concediu</option>");
                        out.println("<option value='resdir.jsp'>Respingere concediu</option>");
                        out.println("<option value='viewp.jsp'>Vizualizare concedii personale</option>");
                        out.println("<option value='viewcol.jsp'>Vizualizare concedii unui angajat</option>");
                        out.println("<option value='viewconcoldepeu.jsp'>Vizualizare concedii unui coleg</option>");
                        out.println("<option value='viewdepeu.jsp'>Vizualizare concedii din departamentul meu</option>");
                        out.println("<option value='viewcondep.jsp'>Vizualizare concedii dintr-un departament</option>");
                        out.println("<option value='viewtot.jsp'>Vizualizare concedii din toata institutia</option>");
                        out.println("<option value='viewcolegi.jsp'>Vizualizare angajati</option>");
                        out.println("<option value='viewcolegidep.jsp'>Vizualizare colegi de departament</option>");
                        out.println("<option value='viewangdep.jsp'>Vizualizarea angajatilor dintr-un departament/option>");
                        out.println("<option value='viewdep.jsp'>Vizualizare departamente</option>");
                        out.println("<option value='viewdesp.jsp'>Profil</option>");
                        out.println("</select>");
                        out.println("</div>");
                        out.println("<div class='login__buttons'>");
                        out.println("<form action='logout' method='post'><button type='submit' class='login__button login__button-ghost'>Logout</button></form>");
                        out.println("</div>");
                       
                        out.println("</div>");

                        out.println("</div>");
                        out.println("</div>");
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
