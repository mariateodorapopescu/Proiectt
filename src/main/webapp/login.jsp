<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<% String accent = "#03346E", clr = "#d8d9e1", sidebar = "#ecedfa", text = "#333", card = "#ecedfa", hover = "#ecedfa"; %>
<!DOCTYPE html>
<html lang="ro">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
<link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
<link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
<title>Login</title>
<style>
    body {
        --bg: <%= accent %>;
        --clr: <%= clr %>;
        --sd: <%= sidebar %>;
        --text: <%= text %>;
        background: <%= clr %>;
        margin: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-direction: column;
        padding: 20px;
    }
    .container {
        background: <%= sidebar %>;
        padding: 20px;
        border-radius: 2rem;
       
        width: 100%; /* Responsive width */
        max-width: 75%; /* Maximum width */
    }
    .logo img {
        width: 80%; /* Smaller logo for small screens */
        max-width: 150px; /* Maximum width of the logo */
        margin-bottom: 20px; /* Space below the logo */
    }
  
    .login__button {
        background: <%= accent %>;
        color: white;
        padding: 10px;
        border-radius: 5px;
        cursor: pointer;
        border: none;
    }
    @media (max-width: 300px) {
        .logo, .login__form {
            padding: 10px;
        }
        h1, label {
            font-size: 0.8rem; /* Smaller font size for smaller screens */
        }
    }
   
      input::-ms-reveal,
      input::-ms-clear {
        display: none;
      }
   
</style>
</head>
<body>
    <div class="container" style="margin:0; padding: 0; justify-content: center;">
        <div class="logo">
            <img src="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" alt="Logo">
            <h1 style="color: <%= accent %>;">Firma XYZ</h1>
        </div>
        <form style="margin:0; background: <%= clr %>; border-color: <%= clr %>; " action="<%= request.getContextPath() %>/login" method="post" class="login__form">
            <h1 style="color: <%= accent %>;" class="login__title">Conectare</h1>
            <div class="login__inputs">
                <label style="color: <%= text %>;" for="username" class="login__label">Nume de utilizator</label>
                <input style="color: <%= text %>; background: <%= sidebar %>; border-color: <%= accent %>; " type="text" id="username" name="username" placeholder="Introduceti numele de utilizator" required class="login__input">
                
                <div>
                                <label style="color: <%=text%>;" for="" class="login__label">Parola</label>
    
                                <div class="login__box">
                                    <input style="color: <%=text%>; background:  <%=sidebar%>; border-color: <%=accent%>;" type="password" placeholder="Introduceti parola" required class="login__input" id="input-pass" name="password">
                                    <i class="ri-eye-off-line login__eye" id="input-icon"></i>
                                    
                                    
                                </div>
            </div>
            <input style="color: <%= sidebar %>; margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" type="submit" value="Conectare" class="login__button"><% 
    String loginAttempts = request.getParameter("loginAttempts");
    if (loginAttempts != null && Integer.parseInt(loginAttempts) >= 1) {
        out.println("<a style='color: " + accent + ";' href='forgotpass.jsp?' class='login__forgot'>Am uitat parola</a>");
    }
%>
                    </div>
                    <input type="hidden" name="page" value="1">
                </form>
            </div>
        </div>

   <%
    String logout = request.getParameter("logout");
    if ("true".equals(logout)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Deconectare efectuata cu succes!');");
        out.println("</script>");
    }

    String wup = request.getParameter("wup");
    if ("true".equals(wup)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Nume de utilizator sau parola gresite!');");
        out.println("</script>");
    }

    String rp = request.getParameter("rp");
    if ("true".equals(rp)) {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Puteti modifica parola oricand!');");
        out.println("</script>");
    }
    
    %>

    <form name="postForm" action="dashboard.jsp" method="POST" style="display:none;">
        <input type="hidden" name="username" value="${param.username}">
    </form>
   
</div>
<script src="./responsive-login-form-main/assets/js/main.js"></script>
<script>
    // Check if the 'logout' query parameter is set to 'true'
    if (new URLSearchParams(window.location.search).has('logout')) {
        localStorage.removeItem('jwtToken');  // Remove the JWT from local storage
        window.location.href = 'login.jsp';   // Optionally redirect to clean the URL
    }
</script>

</body>
</html>