<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <% String accent = "#03346E", clr = "#d8d9e1", sidebar = "#ecedfa", text = "#333", card = "#ecedfa", hover = "#ecedfa"; %>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

        <!--=============== REMIXICONS ===============-->
        <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

        <!--=============== CSS ===============-->
        <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
        
        <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
        
<title>Concedii</title>
<style>
#preloader {
        top: 0;
        left: 0;
        color: <%= accent %>;
        height: 100%;
        width: 100%;
        position: fixed;
        z-index: 100;
        display: flex;
        justify-content: center;
        align-items: center;
        background-image: linear-gradient(-45deg, #808080, #e4efe9, #6b8cce);
        background-size: 100% 100%;
        animation: gradientAnimation 5s ease infinite;
    }
    .loader {
        display: flex;
        height: 4rem;
        width: 4rem;
        position: relative;
        justify-content: space-between;
        /* animation: rotate 1.5s linear infinite; */
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
        /* asta e un fel de container */
    }
    
    .loader span {
        width: 0.6rem;
        height: 0.6rem;
        left: 0;
        border-radius: 50%;
        background-color: <%= accent %>;
        position: absolute;
        top: 50%;
        animation: animate 2s ease-in-out infinite;
        animation-delay: calc(0.15s * var(--i));
    }
     @keyframes animate {
        0%,
        10% {
            width: 0.6rem;
            height: 0.6rem;
            transform: rotate(0deg) translateX(2rem);
        }
        40%,
        70% {
            width: 0.8rem;
            height: 0.8rem;
            transform: rotate(calc(360deg /8 * var(--i))) translateX(2rem);
            box-shadow: 0 0 0 0.1rem <%= sidebar %>;
        }
        90%,
        100% {
            width: 0.6rem;
            height: 0.6rem;
            transform: rotate(0deg) translateX(2rem);
        }
    }
    body {
        --bg: <%= accent %>;
        --clr: <%= clr %>;
        --sd: <%= sidebar %>;
        --text: <%= text %>;
        background: <%= clr %>;
        margin: 0;
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .container {
        display: flex;
        flex-direction: column; /* Change direction to column for vertical alignment */
        align-items: center; /* Align items to the center horizontally */
        background: <%= sidebar %>;
        padding: 25%;
        border-radius: 2rem;
        
    }
    .logo {
        text-align: center; /* Center logo and text horizontally */
    }
    .logo img {
        width: 75%;
    }
    a, a:hover, a:active, a:visited {
    color: white; 
    text-decoration: none;}
</style>
</head>
<body>
 <div id="preloader" class="day-mode">
        <div class="loader">
            <span style="--i:0"></span>
            <span style="--i:1"></span>
            <span style="--i:2"></span>
            <span style="--i:3"></span>
            <span style="--i:4"></span>
            <span style="--i:5"></span>
            <span style="--i:6"></span>
            <span style="--i:7"></span>
        </div>
    </div>
    
<div class="container">
        <div class="logo">
            <img src="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" alt="Logo">
            <h1 style="color: <%= accent %>;">Bun venit!</h1>
        </div>
       <button style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button"><a href="login.jsp" style="display: block; text-align: center; margin:0; top:-10px; box-shadow: 0 6px 24px <%= accent %>; background: <%= accent %>; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none;">
    Intrati
</a> </button>
    </div>

  
    <script>
    document.addEventListener("DOMContentLoaded", function() {
        var preloader = document.getElementById("preloader");
        setTimeout(function() {
            preloader.style.display = "none";
        }, 5000);
    });

    </script>
    <script src="./responsive-login-form-main/assets/js/main.js"></script>
</body>
</html>