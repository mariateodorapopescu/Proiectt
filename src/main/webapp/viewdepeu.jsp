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

    <title>Vizualizare concedii</title>
</head>
<body>
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
                        %>
                        <div class="container">
                            <div class="login__content">
                                <img src="./responsive-login-form-main/assets/img/bg-login.jpg" alt="login image" class="login__img login__img-light">
                                <img src="./responsive-login-form-main/assets/img/bg-login-dark.jpg" alt="login image" class="login__img login__img-dark">

                                <form action="<%= request.getContextPath() %>/masina1.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title"><span>Vizualizare concedii din departamentul meu</span></h1>
                                    </div>
                                    
                                    <div class="login__inputs">
                                        <div>
                                            <label class="login__label">Status</label>
                                            <select name="status" class="login__input">
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
                                            <label class="login__label">Tip</label>
                                            <select name="tip" class="login__input">
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

                                        <div class="login__check">
                                            <input type="checkbox" id="an" name="an" class="login__check-input"/>
                                            <label for="an" class="login__check-label">An</label>
                                        </div>

                                        <div>
                                            <label class="login__label">Inceput</label>
                                            <input type="date" id="start" name="start" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>

                                        <div>
                                            <label class="login__label">Final</label>
                                            <input type="date" id="end" name="end" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>
                                    </div>

                                    <input type="hidden" name="userId" value="<%= userId %>"/>
                                    <input type="hidden" name="dep" value="<%= userdep %>"/>
                                    <input type="hidden" name="pag" value="6"/>
                                    <input type="hidden" name="id" value="-1"/>
                                    
                                    <div class="login__buttons">
                                        <input type="submit" value="Submit" class="login__button login__button-ghost"/>
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
