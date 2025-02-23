<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String old_otp = request.getParameter("oldotp");
        String accent = "#03346E", clr = "#d8d9e1", sidebar = "#ecedfa", text = "#333", card = "#ecedfa", hover = "#ecedfa";
        String pagee = request.getParameter("page");
                        %>
<html>
<head>
    <title>OTP</title>
    
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
        
        ::placeholder {
  color: var(--text);
  opacity: 1; /* Firefox */
}

::-ms-input-placeholder { /* Edge 12-18 */
  color: var(--text);
}
        @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">


                        <div class="flex-container">
                            
                            <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
                         
    
                                <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/OTP3" method="post" class="login__form">
                                    <div>
                                        <h1 style=" color:<%out.println(accent);%>" class="login__title"><span style=" color:<%out.println(accent);%>">Introduceti codul primit prin e-Mail</span></h1>
                                        <%
                                        //out.println("<p style='margin:0; padding:0; position:relative; top:0;'>Zile ramase: " + zile + "; Concedii ramase: " + con + "</p>");
                                        %>
                                    </div>
                                    
                                    <div class="login__inputs" style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>">
                                        
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Cod One Time Password</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti codul..." required class="login__input" name="userOtp"/>
                                        </div>
                                        
                                        <div class="login__buttons">
                                            <input style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" type="submit" value="Mai departe >" class="login__button">
                                        </div>
        <input type="hidden" name="username" value="<%=username%>">
                                         <input type="hidden" name="password" value="<%=password%>">
                                         <input type="hidden" name="oldotp" value="<%=old_otp%>">
                                         <input type="hidden" name="page" value="<%=pagee%>"> 
                                    </form>
                                    <%
                                    out.println("</div>");
                                    
                                    %>
                                    
                                </div>
                               
                            </div>
                        </div>
                        <form name="hiddenForm" action="/Proiect/OTP3" method="POST" style="display:none;">
        <input type="hidden" name="username" value="<%=username%>">
                                         <input type="hidden" name="password" value="<%=password%>">
                                         <input type="hidden" name="oldotp" value="<%=old_otp%>">
    </form>
   
                        <%
           
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
<script src="./responsive-login-form-main/assets/js/main.js"></script>
<script src="./responsive-login-form-main/assets/js/calendar4.js"></script>
<script>
//La începutul paginii
const token = localStorage.getItem('jwtToken');
if (token) {
    // Adaugă token-ul în header pentru toate request-urile fetch
    fetch = new Proxy(fetch, {
        apply: function(target, thisArg, argumentsList) {
            const [url, config = {}] = argumentsList;
            config.headers = config.headers || {};
            config.headers['Authorization'] = token;
            return target.apply(thisArg, [url, config]);
        }
    });
}
</script>
</body>
</html>
