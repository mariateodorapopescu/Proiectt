<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Modificare date</title>
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
<%
    HttpSession sess = request.getSession(false); // Make sure you have the correct import for HttpSession
    if (sess != null) {
        String username = (String) sess.getAttribute("username"); // Assuming username is stored in session
        
        // Check if the username is actually retrieved from the session
        if (username != null && !username.isEmpty()) {
        	  Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
              try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                   PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume, id from useri where username = ?")) {
                  preparedStatement.setString(1, username);
                  ResultSet rs = preparedStatement.executeQuery();
                  if (!rs.next()) {
                      out.println("<script type='text/javascript'>");
                      out.println("alert('Date duse incorect sau nu exista date!');");
                      out.println("</script>");
                  } else {
                      
                      	int id = rs.getInt("id");
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
                                stmt.setInt(1, id);
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
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

        	 <div class="flex-container">
             
             <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
          

                 <form style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/modifusr2.jsp" method="post" class="login__form">
                     <div>
                         <h1 style=" color:<%out.println(accent);%>" class="login__title"><span style=" color:<%out.println(accent);%>">Modificare date personale</span></h1>
                         
                     </div>
                     
                     <div style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>" class="login__inputs">
                        
                         <div>
                             <label style=" color:<%out.println(text);%>" class="login__label" class="login__label">Cod</label>
                             <input style="border-color:<%out.println(accent);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti codul" required class="login__input" name='cnp'/>
                         </div>
                        
                       
                         <div class="login__buttons">
                             <input style="backgroundColor:<%out.println(sidebar);%>; color:<%out.println(accent);%>; border-color:<%out.println(accent);%>" type="submit" value="Modificare" class="login__button login__button-ghost">
                         </div>
                     </form>
                     <%
                     out.println("</div>");
                     %>
                 </div>
             </div>
             </body>
</html>
        	<%
                  }
                  }
        } else {
            // If username is not in session, redirect to login
            String accent = "#03346E";
                     	 String clr = "#d8d9e1";
                     	 String sidebar = "#ECEDFA";
                     	 String text = "#333";
                     	 String card = "#ECEDFA";
                     	 String hover = "#ECEDFA";
            %>
           <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

        	 <div style=" background:<%out.println(clr);%>" class="flex-container">
             
             <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
          

                 <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/modifusr2.jsp" method="post" class="login__form">
                     <div>
                         <h1 style=" color:<%out.println(accent);%>" class="login__title"><span style=" color:<%out.println(accent);%>">Modificare date personale</span></h1>
                         
                     </div>
                     
                     <div style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>" class="login__inputs">
                        
                         <div>
                             <label style=" color:<%out.println(text);%>" class="login__label" class="login__label">Cod</label>
                             <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti codul" required class="login__input" name='cnp'/>
                         </div>
                        
                       
                         <div class="login__buttons">
                         <input style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" type="submit" value="Inainte" class="login__button">
                                        </div>
                     </form>
                     <%
                     out.println("</div>");
                     %>
                 </div>
             </div>
             </body>
</html>
            <%

        }

    } else {
    	out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
</body>
</html>
