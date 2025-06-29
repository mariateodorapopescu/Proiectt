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
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement(
                		 "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                                 "dp.denumire_completa AS denumire FROM useri u " +
                                 "JOIN tipuri t ON u.tip = t.tip " +
                                 "JOIN departament d ON u.id_dep = d.id_dep " +
                                 "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                                 "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    
                    if (!isAdmin && !isDirector) {
                    	
                        if (isUtilizatorNormal) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (isSef) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (isIncepator) {
                            response.sendRedirect("tip2ok.jsp");
                        }
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
    <title>Vizualizare angajati dintr-un departament</title>
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
       
        @charset "UTF-8";
        /*=============== GOOGLE FONTS ===============*/
        @import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap");
        /* restul CSS-ului pe care l-ai furnizat */
        /* Copiază CSS-ul furnizat aici */
    </style>
    
</head>
<body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                        <div class="container" style="position: fixed; top:0; left: 25%; border-radius: 2rem; padding: 0;  margin: 0; background: <%out.println(clr);%>">
                            <div class="login__content" style="position: fixed; top: 0; border-radius: 2rem; margin: 0; height: 100vh; border-radius: 2rem; margin: 0; padding: 0; background:<%out.println(clr);%>; color:<%out.println(text);%> ">
                                
                                <form style="position: fixed; top: 4rem; border-radius: 2rem; margin: 0; border-radius: 2rem; border-color:<%out.println(accent);%>; background:<%out.println(sidebar);%>; color:<%out.println(accent);%> " action="<%= request.getContextPath() %>/viewangdep2.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title" ><span style="color:<%out.println(accent);%>">Selectati departamentul pe care doriti sa il vizualizati</span></h1>
                                    </div>
                                   
                                    <div class="login__inputs">
                                        <div>
                                            <label class="login__label" style="color:<%out.println(text);%>">Departament</label>
                                            <select style="color:<%out.println(text);%>; border-color:<%out.println(accent);%>; background: <%out.println(sidebar);%>" name="iddep" class="login__input">
                                                <option value="0">Oricare</option>
                                                <%
                                               

                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                                if (rs1.next()) {
                                    do {
                                        int id = rs1.getInt("id_dep");
                                        String nume = rs1.getString("nume_dep");
                                        out.println("<option value='" + id + "'>" + nume + "</option>");
                                    } while (rs1.next());
                                } else {
                                    out.println("<option value=''>Nu exista departamente disponibile.</option>");
                                }
                            }
                        }

                        out.println("</select></div></div>");
                        %> <a href="viewang.jsp" class="login__forgot" style="margin:0; top:-10px; color:<%out.println(accent);%> ">Inapoi</a> <%
                        out.println("<div class='login__buttons'><input style='box-shadow: 0 6px 24px "  + accent + "; background:" + accent + "' class='login__button' type='submit' value='Submit' /></div>");
                        out.println("</form>");
                        out.println("</div>");
                        out.println("</div>");
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                    response.sendRedirect("viewangdep.jsp");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("</script>");
                response.sendRedirect("viewangdep.jsp");
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

</body>
</html>
