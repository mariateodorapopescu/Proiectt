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
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            preparedStatement = connection.prepareStatement("SELECT tip, prenume, id FROM useri WHERE username = ?");
            preparedStatement.setString(1, username);
            rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                out.println("<script type='text/javascript'>alert('Date introduse incorect sau nu exista date!');</script>");
            } else {
                int userId = rs.getInt("id");
                String userType = rs.getString("tip");
                String accent = "##03346E";
                String clr = "#d8d9e1";
                String sidebar =  "#ecedfa";
                String text = "#333";
                String card =  "#ecedfa";
               	String hover = "#ecedfa";
                // Retrieve user theme settings
                try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM teme WHERE id_usr = ?")) {
                    stmt.setInt(1, userId);
                    try (ResultSet rs2 = stmt.executeQuery()) {
                        if (rs2.next()) {
                           	accent = rs2.getString("accent");
                            clr = rs2.getString("clr");
                            sidebar = rs2.getString("sidebar");
                            text = rs2.getString("text");
                            card = rs2.getString("card");
                            hover = rs2.getString("hover");

                            // Output user-specific style settings
                            out.println("<style>:root {--bg:" + accent + "; --clr:" + clr + "; --sd:" + sidebar + "; --text:" + text + "; background:" + clr + ";}</style>");
                        }
                    }
                }
                
                %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
<link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
<link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
<title>Rapoarte</title>
<style>
     * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
        overflow-y: auto;
    }
    body, html {
        background: <%= clr %>;
        font-family: Arial, sans-serif;
        overflow-x: hidden;
        overflow: auto;
        width: 100%;
        height: 100%;
        overflow-y: auto;
    }
    nav {
        width: 100%;
        background-color: <%= sidebar %>;
        display: flex;
        justify-content: space-around; /* Changed to space-around for better spacing */
        position: fixed;
        top: 0;
        z-index: 1000;
        padding: 10px 0;
        overflow: auto;
    }
    nav a {
        padding: 12px 6px; /* Reduced padding for smaller screens */
        text-align: center;
        text-decoration: none;
        font-size: 14px; /* Adjust font size if needed */
        color: <%= text %>;
        transition: background-color 0.3s, color 0.3s;
    }
    nav a:hover, nav a:active nav a:focus{
        background-color: <%= accent %>;
        color: <%= clr %>;
    }
    iframe {
        width: 100%;
         border: none;
         transition: height 0.5s ease;
         overflow: auto; /* Hide scrollbars */
         overflow-y: auto; /* Hide vertical scrollbar */
         /* Hide scrollbar for Chrome, Safari and Opera */
          -ms-overflow-style: none;  /* IE and Edge */
		  scrollbar-width: none;  /* Firefox */
		height: 100%;
		border-radius: 2em;
		margin: 0;
		padding: 0;
		    }

    @media (max-width: 600px) {
        nav a {
            flex-grow: 1;
            font-size: 12px; /* Smaller font size for very small screens */
        }
    }
    .active-tab {
        background-color: <%= accent %>; 
        color: white; /* White text for active tab */
    }
    
    ::-webkit-scrollbar {
		    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
		iframe::-webkit-scrollbar {
		    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
</style>
</head>
<body>

<nav>
    <a id="unu" onclick="setActiveTab('unu')" href="viewconcoldepeu.jsp" target="contentFrame">Coleg</a>
   
    <a id="trei" onclick="setActiveTab('trei')" href="viewp.jsp" target="contentFrame">Personale</a>
    <a id="patru" onclick="setActiveTab('patru')" href="viewdepeu.jsp" target="contentFrame">Dept. meu</a>
  
   
    <a id="sapte" onclick="setActiveTab('sapte')" href="pean2.jsp" target="contentFrame">Anual</a>
    <a id="opt" onclick="setActiveTab('opt')" href="sometest2.jsp" target="contentFrame">Lunar</a>
    <a id="noua" onclick="setActiveTab('noua')" href="testviewpers2.jsp" target="contentFrame">Calendar</a>
    <a class="nav a" id="zece" onclick="setActiveTab('zece')" href="harta_concedii.jsp" target="contentFrame">Harta</a>
    
</nav>
<script>

function setActiveTab(tabId) {
    // Remove active class from all tabs
    document.querySelectorAll('nav a').forEach(tab => tab.classList.remove('active-tab'));
    // Add active class to clicked tab
    document.getElementById(tabId).classList.add('active-tab');
    // Store the active tab in sessionStorage
    sessionStorage.setItem('activeTab', tabId);
}

// Event listener to maintain the active state on page reload
window.onload = function() {
    const activeTab = sessionStorage.getItem('activeTab');
    if (activeTab) {
        setActiveTab(activeTab);
    }
};
</script>
<iframe style="overflow: auto; padding: 0; margin: 0;" name="contentFrame" src="viewconcoldepeu.jsp"></iframe>
<% }
            
            }catch(Exception e) {
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
