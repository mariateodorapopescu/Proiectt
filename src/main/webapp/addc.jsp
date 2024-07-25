<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Adaugare concediu</title>
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
        .flex-container {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            gap: 2rem;
            margin: 2rem;
        }
        
        .calendar-container, .form-container {
            background-color: #2a2a2a;
            padding: 1rem;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        
        .calendar-container {
            max-width: 300px;
        }
         th.calendar, td.calendar {
            border: 1px solid #1a1a1a;
            text-align: center;
            padding: 8px;
            font-size: 12px;
        }
        th.calendar {
            background-color: #333;
        }
        .highlight {
            /*background-color: #32a852;*/
            color: white;
        }
        :root{
          --first-color: #2a2a2a;
  --second-color: hsl(249, 64%, 47%);
  --title-color-light: hsl(244, 12%, 12%);
  --text-color-light: hsl(244, 4%, 36%);
  --body-color-light: hsl(208, 97%, 85%);
  --title-color-dark: hsl(0, 0%, 95%);
  --text-color-dark: hsl(0, 0%, 80%);
  --body-color-dark: #1a1a1a;
  --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
  --form-border-color-light: hsla(244, 16%, 92%, 0.75);
  --form-bg-color-dark: #333;
  --form-border-color-dark: #3a3a3a;
  /*========== Font and typography ==========*/
  --body-font: "Poppins", sans-serif;
  --h2-font-size: 1.25rem;
  --small-font-size: .813rem;
  --smaller-font-size: .75rem;
  /*========== Font weight ==========*/
  --font-medium: 500;
  --font-semi-bold: 600;
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
                 PreparedStatement preparedStatement = connection.prepareStatement("select * from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                   // String zile = rs.getString("zileramase");
                    //System.out.println(zile);
                   //  String con = rs.getString("conramase");
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp"); 
                        
                    } else {
                        %>
                        <div class="flex-container">
                            <div class="calendar-container">
                                <div class="navigation">
                                    <button class='prev' onclick="previousMonth()">❮</button>
                                    <div class="month-year" id="monthYear"></div>
                                    <button class='next' onclick="nextMonth()">❯</button>
                                </div>
                                <table class="calendar" id="calendar">
                                    <thead>
                                        <tr>
                                            <th class="calendar">Lu.</th>
                                            <th class="calendar">Ma.</th>
                                            <th class="calendar">Mi.</th>
                                            <th class="calendar">Jo.</th>
                                            <th class="calendar">Vi.</th>
                                            <th class="calendar">Sâ.</th>
                                            <th class="calendar">Du.</th>
                                        </tr>
                                    </thead>
                                    <tbody class="calendar" id="calendar-body">
                                        <!-- Calendar will be generated here -->
                                    </tbody>
                                </table>
                                
                            </div>
                            <div class="form-container">
                         
    
                                <form action="<%= request.getContextPath() %>/addcon" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title"><span>Adaugare concediu</span></h1>
                                        <%
                                        //out.println("<p style='margin:0; padding:0; position:relative; top:0;'>Zile ramase: " + zile + "; Concedii ramase: " + con + "</p>");
                                        %>
                                    </div>
                                    
                                    <div class="login__inputs">
                                        <div>
                                            <label class="login__label">Data plecare</label>
                                            <input class="login__input" type='date' id='start' name='start' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/>
                                        </div>
                                        <div>
                                            <label class="login__label">Data sosire</label>
                                            <input class="login__input" type='date' id='end' name='end' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/>
                                        </div>
                                        <div>
                                            <label class="login__label">Motiv</label>
                                            <input type="text" placeholder="Introduceti motivul" required class="login__input" name='motiv'/>
                                        </div>
                                        <div>
                                            <label class="login__label">Tip concediu</label>
                                            <select name='tip' class="login__input">
                                            <%
                                            try (PreparedStatement stmt = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                                                ResultSet rs1 = stmt.executeQuery();
                                                while (rs1.next()) {
                                                    int tip = rs1.getInt("tip");
                                                    String motiv = rs1.getString("motiv");
                                                    out.println("<option value='" + tip + "'>" + motiv + "</option>");
                                                }
                                            }
                                            out.println("</select></div>");
                                            %>
                                            <div>
                                                <label class="login__label">Locatie</label>
                                                <input type="text" placeholder="Introduceti locatia" required class="login__input" name='locatie'/>
                                            </div>
                                        </div>
                                       <% out.println("<input type='hidden' name='userId' value='" + userId + "'/>"); %> 
                                        <%  out.println("            <a href=\"actiuni.jsp\" class=\"login__forgot\">Inapoi</a>"); %>
                                        <div class="login__buttons">
                                            <input type="submit" value="Adaugare" class="login__button login__button-ghost">
                                        </div>
                                    </form>
                                    <%
                                    out.println("</div>");
                                    
                                    %>
                                </div>
                            </div>
                        </div>
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
<script src="./responsive-login-form-main/assets/js/main.js"></script>
<script src="./responsive-login-form-main/assets/js/calendar4.js"></script>
</body>
</html>
