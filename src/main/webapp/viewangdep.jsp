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
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    if (userType != 0 && userType != 4) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                           
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
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                       
                       <div style=" width:1vw; height:1vh; position: relative; top:5%; left: 25%; margin: 0; padding: 0;" "class="container">
                            <div class="login__content" style="margin: 0; padding: 0; border-color:<%out.println(sidebar);%>; border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                                 
                                <form style="border-color:<%out.println(accent);%>; border-radius: 2rem; background:<%out.println(clr);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/viewangdep2.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title" ><span style="color:<%out.println(accent);%>">Selectati departamentul pe care doriti sa il vizualizati</span></h1>
                                    </div>
                                   
                                    <div class="login__inputs">
                                        <div>
                                            <label class="login__label" style="color:<%out.println(text);%>">Status</label>
                                            <select style="color:<%out.println(text);%>; border-color:<%out.println(accent);%>; background: <%out.println(sidebar);%>" name="iddep" class="login__input">
                                                <option value="3">Oricare</option>
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
