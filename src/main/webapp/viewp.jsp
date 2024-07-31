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
            String user = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume, id_dep from useri where username = ?")) {
                preparedStatement.setString(1, user);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 4) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                            case 4: response.sendRedirect("adminok.jsp"); break;
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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=0.5">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">

    <title>Vizualizare concedii</title>
    <style>
       body, html {
    margin: 0;
    padding: 0;
}

.container {
    padding-top: 60px; /* Adjust as needed */
     
}
    </style>
 
    
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(sidebar);%>">

                        <div class="container" style="height: 100vh; border-radius: 2rem; margin: 0; background: <%out.println(sidebar);%>">
                            <div class="login__content" style="height: 100vh; top: 2.75em; border-radius: 2rem; margin: 0; padding: 1em; background:<%out.println(clr);%>; color:<%out.println(text);%> ">
                                
                                <form style=" border-radius: 2rem; border-color:<%out.println(accent);%>; background:<%out.println(sidebar);%>; color:<%out.println(accent);%> " action="<%= request.getContextPath() %>/masina1.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title"><span style="color:<%out.println(accent);%> ">Vizualizare concedii personale</span></h1>
                                    </div>
                                    
                                    <div class="login__inputs">
                                        <div>
                                            <label style="color:<%out.println(text);%>" class="login__label">Status</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " name="status" class="login__input">
                                                <option value="3">Oricare</option>
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                                                    try (ResultSet rs1 = stm.executeQuery()) {
                                                        if (rs1.next()) {
                                                            do {
                                                                int id = rs1.getInt("status");
                                                                String nume = rs1.getString("nume_status");
                                                                out.println("<option value='" + id + "'>" + nume + "</option>");
                                                            } while (rs1.next());
                                                        } else {
                                                            out.println("<option value=''>Nu exista statusuri disponibile.</option>");
                                                        }
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>
                                        
                                        <div>
                                            <label style="color:<%out.println(text);%>" class="login__label">Tip</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " name="tip" class="login__input">
                                                <option value="-1">Oricare</option>
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM tipcon;")) {
                                                    try (ResultSet rs1 = stm.executeQuery()) {
                                                        if (rs1.next()) {
                                                            do {
                                                                int id = rs1.getInt("tip");
                                                                String nume = rs1.getString("motiv");
                                                                out.println("<option value='" + id + "'>" + nume + "</option>");
                                                            } while (rs1.next());
                                                        } else {
                                                            out.println("<option value=''>Nu exista tipuri disponibile.</option>");
                                                        }
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>

                                        <div>
                                            <input type="checkbox" id="an" name="an" class="login__check-input"/>
                                            <label style="color:<%out.println(text);%>" for="an" class="login__check-label">An</label>
                                        </div>

                                        <div id="start">
                                            <label style="color:<%out.println(text);%>" class="login__label">Inceput</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " type="date" id="start" name="start" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>

                                        <div id="end">
                                            <label style="color:<%out.println(text);%>" class="login__label">Final</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " type="date" id="end" name="end" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>
                                    </div>

                                    <input type="hidden" name="userId" value="<%= userId %>"/>
                                    <input type="hidden" name="id" value="<%= userId %>"/>
                                    <input type="hidden" name="dep" value="<%= userdep %>"/>
                                    <input type="hidden" name="pag" value="3"/>
                                    
                                    <div class="login__buttons">
                                        <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" type="submit" value="Cautati" class="login__button">
                                    </div>
                                </form>
                            </div>
                        </div>
                        <script>
                            function toggleDateInputs() {
                                var radioPer = document.getElementById('an');
                                var startInput = document.getElementById('start');
                                var endInput = document.getElementById('end');
                                if (radioPer.checked) {
                                    startInput.style.display = 'none';
                                    endInput.style.display = 'none';
                                } else {
                                    startInput.style.display = 'block';
                                    endInput.style.display = 'block';
                                }
                            }
                            document.addEventListener('DOMContentLoaded', function() {
                                toggleDateInputs();  // Call on initial load
                                setInterval(toggleDateInputs, 100); // Call every 100 milliseconds
                            });
                        </script>
                        <%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
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
