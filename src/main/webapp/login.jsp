<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html lang="ro">
<head>
<meta charset="ISO-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!--=============== REMIXICONS ===============-->
        <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

        <!--=============== CSS ===============-->
        <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
        
        <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
        
<title>Login</title>
<script type="text/javascript">
    function submitForm() {
        document.getElementById("postLogin").submit();
    }
</script>
</head>
<body>

 <div class="container">
            <div class="login__content">
                <img src="./responsive-login-form-main/assets/img/bg-login.jpg" alt="login image" class="login__img login__img-light">
                <img src="./responsive-login-form-main/assets/img/bg-login-dark.jpg" alt="login image" class="login__img login__img-dark">
    
                <form action="<%= request.getContextPath() %>/login" method="post" class="login__form">
                    <div>
                        <h1 class="login__title">
                            <span>Conectare</span>
                        </h1>
                        <p class="login__description">
                            
                        </p>
                    </div>
                    
                    <div>
                        <div class="login__inputs">
                            <div>
                                <label for="" class="login__label">Nume de utilizator</label>
                                <input type="text" placeholder="Introduceti numele de utilizator" required class="login__input" name="username">
                            </div>
    
                            <div>
                                <label for="" class="login__label">Parola</label>
    
                                <div class="login__box">
                                    <input type="password" placeholder="Introduceti parola" required class="login__input" id="input-pass" name="password">
                                    <i class="ri-eye-off-line login__eye" id="input-icon"></i>
                                    
                                    
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <div class="login__buttons">
                            <input type="submit" value="Conectare" class="login__button login__button-ghost">
                        </div>
  <% 
    String loginAttempts = request.getParameter("loginAttempts");
    if (loginAttempts != null && Integer.parseInt(loginAttempts) >= 1) {
        out.println("<a href='forgotpass.jsp' class='login__forgot'>Am uitat parola</a>");
    }
%>
                    </div>
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
</body>
</html>
