<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Resetare parola</title>
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
            background-color: var(--bg);
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
    HttpSession sess = request.getSession(false); // Make sure you have the correct import for HttpSession
    if (sess != null) {
        String username = (String) sess.getAttribute("username"); // Assuming username is stored in session
        String redir = "";
        // Check if the username is actually retrieved from the session
        if (username != null && !username.isEmpty()) {
        	 if (request.getParameter("page").compareTo("2") == 0) {
            	 redir = "/modifpasd2.jsp?page=2";
            }
            else {
           redir = "/modifpasd2.jsp";
            }
        	%>
        	 <div class="flex-container">
            
             <div class="form-container">
          

                 <form action="<%= request.getContextPath() %>/modifpasd2.jsp" method="post" class="login__form">
                     <div>
                         <h1 class="login__title"><span>Modificare parola</span></h1>
                         
                     </div>
                     
                     <div class="login__inputs">
                        
                         <div>
                             <label class="login__label">Cod</label>
                             <input type="text" placeholder="Introduceti codul" required class="login__input" name='cnp'/>
                         </div>
                          <%  out.println("            <a href=\"about:blank\" class=\"login__forgot\">Inapoi</a>"); %>
                       
                         <div class="login__buttons">
                             <input type="submit" value="Modificare" class="login__button login__button-ghost">
                         </div>
                     </form>
                     <%
                     out.println("</div>");
                     %>
                 </div>
             </div>
       
         
        	<%
           
        } else {
            // If username is not in session, redirect to login
            if (request.getParameter("page").compareTo("2") == 0) {
            	 redir = "/OTP?page=2";
            }
            else {
           redir = "/OTP?page=2";
            }
            %>
        	<div class="flex-container">
            
            <div class="form-container">
         

               <form action="<%= request.getContextPath() %><%= redir %>" method="post" class="login__form">
                     <div>
                         <h1 class="login__title"><span>Modificare parola</span></h1>
                         
                     </div>
                     
                     <div class="login__inputs">
                        
                         <div>
                             <label class="login__label">Nume de utilizator</label>
                             <input type="text" placeholder="Introduceti numele de utilizator" required class="login__input" name='username'/>
                         </div>
                          <%  out.println("            <a href=\"about:blank\" class=\"login__forgot\">Inapoi</a>"); %>
                       
                         <div class="login__buttons">
                             <input type="submit" value="Modificare" class="login__button login__button-ghost">
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
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("login.jsp");
    }
%>
</body>
</html>
