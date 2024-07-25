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
    <title>Eroare</title>
    <style>
        
        a, a:visited, a:hover, a:active{color:#eaeaea !important}
    </style>
</head>
<body>

    
                    	<div class="main-content">
                    	<div class="intro">
                <h1>Oh, vai! S-a intamplat ceva... =(</h1>
                <h3>Va rugam sa va conectati din nou</h3>
                 <button style="--bg: #3F48CC;"> <a href = "logout" style="text-decoration:none;">Conectare din nou</a></button>
              </div>
               </div>
   
    <script src="main.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>
   

</body>
</html>
