<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// Cod pentru verificarea sesiunii și obținerea datelor utilizatorului
// similar cu addc.jsp
  HttpSession sesi = request.getSession(false);
  if (sesi != null) {
      MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
      if (currentUser != null) {
          String username = currentUser.getUsername();
          Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
          try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
              PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
              preparedStatement.setString(1, username);
              ResultSet rs = preparedStatement.executeQuery();
              if (rs.next()) {
                  int id = rs.getInt("id");
                  int userType = rs.getInt("tip");
                  int userdep = rs.getInt("id_dep");
                  if (userType != 4) {  
                  	// Obținerea datei curente
                  	String today = "";
                 	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                          String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                          try (PreparedStatement stmt = connection.prepareStatement(query)) {
                             try (ResultSet rs2 = stmt.executeQuery()) {
                                  if (rs2.next()) {
                                    today =  rs2.getString("today");
                                  }
                              }
                          }
                      } catch (SQLException e) {
                          out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                          e.printStackTrace();
                      }
                 	 
                 	 // Obținerea temelor de culoare pentru utilizator
                 	 String accent = "#10439F";
                	 String clr = "#d8d9e1";
                	 String sidebar = "#ECEDFA";
                	 String text = "#333";
                	 String card = "#ECEDFA";
                	 String hover = "#ECEDFA";
                	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
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
                  } catch (SQLException e) {
                       out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                       e.printStackTrace();
                   }
%>
<html>
<head>
    <title>Adăugare adeverință</title>
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== alt CSS ===============-->
    <style>
     @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
    
     :root{
     /*========== culori de baza ==========*/
      --first-color: #2a2a2a;
	  --second-color: hsl(249, 64%, 47%);
	  /*========== cuulori text ==========*/
	  --title-color-light: hsl(244, 12%, 12%);
	  --text-color-light: hsl(244, 4%, 36%);
	  --title-color-dark: hsl(0, 0%, 95%);
	  --text-color-dark: hsl(0, 0%, 80%);
	  /*========== cuulori corp ==========*/
	  --body-color-light: hsl(208, 97%, 85%);
	  --body-color-dark: #1a1a1a;
	  --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
	  --form-border-color-light: hsla(244, 16%, 92%, 0.75);
	  --form-bg-color-dark: #333;
	  --form-border-color-dark: #3a3a3a;
	  /*========== Font ==========*/
	  --body-font: "Poppins", sans-serif;
	  --h2-font-size: 1.25rem;
	  --small-font-size: .813rem;
	  --smaller-font-size: .75rem;
	  --font-medium: 500;
	  --font-semi-bold: 600;
	 }
	 
	 * {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	    font-family: 'Poppins', sans-serif;
	 }
		        
	::placeholder {
	  color: var(--text);
	  opacity: 1; /* Firefox */
	}
	
	::-ms-input-placeholder { /* Edge 12-18 */
	  color: var(--text);
	}
     
    .flex-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        gap: 2rem;
        margin: 2rem;
    }
    
    .form-container {
        background-color: #2a2a2a;
        padding: 1rem;
        border-radius: 8px;
        width: 100%;
        max-width: 600px;
    }
    
    .info-box {
        background-color: rgba(58, 141, 255, 0.1);
        border-left: 4px solid #3A8DFF;
        padding: 10px 15px;
        margin-bottom: 20px;
        border-radius: 4px;
    }
    
    .info-box h4 {
        margin-top: 0;
        margin-bottom: 5px;
        color: #3A8DFF;
    }
    
    .info-box p {
        margin: 0;
        font-size: 14px;
    }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

<div class="flex-container">
    <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
        <div class="info-box" style="border-left-color:<%out.println(accent);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
            <h4 style="color:<%out.println(accent);%>">Informație:</h4>
            <p>Solicitarea dumneavoastră de adeverință va trebui aprobată de șeful de departament și director pentru a fi eliberată.</p>
        </div>
        
        <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" 
              action="<%= request.getContextPath() %>/AddAdevServlet" method="post" class="login__form">
            <div>
                <h1 style="color:<%out.println(accent);%>" class="login__title">
                    <span style="color:<%out.println(accent);%>">Adăugare adeverință</span>
                </h1>
            </div>
            
            <div class="login__inputs" style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>">
                <div>
                    <label style="color:<%out.println(text);%>" class="login__label">Tip adeverință</label>
                    <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" 
                            name='tip' class="login__input">
                    <%
                    try (PreparedStatement stmt3 = connection.prepareStatement("SELECT id, denumire FROM tip_adev")) {
                        ResultSet rezultat1 = stmt3.executeQuery();
                        while (rezultat1.next()) {
                            int tip = rezultat1.getInt("id");
                            String denumire = rezultat1.getString("denumire");
                            out.println("<option value='" + tip + "'>" + denumire + "</option>");
                        }
                    }
                    %>
                    </select>
                </div>
                <div>
                    <label style="color:<%out.println(text);%>" class="login__label">Motiv</label>
                    <textarea style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" 
                              placeholder="Introduceți motivul solicitării și alte detalii necesare" 
                              required class="login__input" name='motiv' rows="4"></textarea>
                </div>
            </div>
            
            <% out.println("<input type='hidden' name='userId' value='" + id + "'/>"); %> 
            <% out.println("<a href=\"actiuni.jsp\" style=\"color:" + accent + "\" class=\"login__forgot\">Înapoi</a>"); %>
            
            <div class="login__buttons">
                <input style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" 
                       type="submit" value="Adăugare" class="login__button">
            </div>
        </form>
    </div>
</div>
                        <%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                    response.sendRedirect("addadev.jsp");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("</script>");
                response.sendRedirect("addadev.jsp");
            }
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("</script>");
            response.sendRedirect("logout");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
<script src="./responsive-login-form-main/assets/js/main.js"></script>
</body>
</html>