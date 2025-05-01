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
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                if (userType == 4) {
                	switch (userType) {
	                    case 4:
	                        response.sendRedirect("adminok.jsp");
	                        break;
                	}
                } // el i currentuser din sesiune deci e ok
                String accent = null;
             	 String clr = null;
             	 String sidebar = null;
             	 String text = null;
             	 String card = null;
             	 String hover = null;
             	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    // Verifică tematica utilizatorului
                    String query = "SELECT * from teme where id_usr = ?";
                    try (PreparedStatement stmt = connection.prepareStatement(query)) {
                        stmt.setInt(1, userId);
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
           String idAdeverinta = request.getParameter("idadev");
                
           PreparedStatement stm = connection.prepareStatement("SELECT * FROM adeverinte WHERE id = ?");
           stm.setString(1, idAdeverinta);
           ResultSet rs1 = stm.executeQuery();
           if (rs1.next()) {
        	   int id = rs1.getInt("id");
               int tipAdeverinta = rs1.getInt("tip");
               
               // Verifică ambele câmpuri și utilizează valoarea non-null
               String motiv = rs1.getString("pentru_servi");
               if (motiv == null || motiv.trim().isEmpty()) {
                   motiv = rs1.getString("motiv");
               }
               
               String dataCreare = rs1.getString("creare");
               int status = rs1.getInt("status");
               
               // Obține numele tipului de adeverință
               String tipNume = "";
               PreparedStatement stmTip = connection.prepareStatement("SELECT denumire FROM tip_adev WHERE id = ?");
               stmTip.setInt(1, tipAdeverinta);
               ResultSet rsTip = stmTip.executeQuery();
               if (rsTip.next()) {
                   tipNume = rsTip.getString("denumire");
               }
               rsTip.close();
               stmTip.close();
                
%>
<html>
<head>
    <title>Modificare adeverință</title>
     <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
         @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
     
	* {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	    font-family: 'Poppins', sans-serif;
	}
	
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
    
    /* Fix pentru textarea */
    .login__input[name='motiv'] {
        min-height: 100px;
        resize: vertical;
    }
    
    /* Fix pentru butonul de anulare */
    .login__button {
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        color: white !important;
    }
    
    /* Fix pentru select */
    select.login__input {
        padding: 10px;
        width: 100%;
        border-radius: 8px;
        border: 1px solid;
        background-position: right 10px center;
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        padding-right: 30px;
    }
</style>
</head>

<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">
    <div class="flex-container">
        <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
            <div class="info-box" style="border-left-color:<%out.println(accent);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                <h4 style="color:<%out.println(accent);%>">Informație:</h4>
                <p>Modificarea adeverinței va reseta procesul de aprobare.</p>
            </div>
                         
            <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/ModifAdevServlet" method="post" class="login__form">
                <div>
                    <h1 style="color:<%out.println(accent);%>" class="login__title"><span style="color:<%out.println(accent);%>">Modificare adeverință</span></h1>
                </div>
                
                <div class="login__inputs" style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>">
                    <div>
                        <label style="color:<%out.println(text);%>" class="login__label">Tip adeverință</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="tip" class="login__input">
                        <%
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT id, denumire FROM tip_adev")) {
                            ResultSet rs2 = stmt.executeQuery();
                            while (rs2.next()) {
                                int tip = rs2.getInt("id");
                                String denumire = rs2.getString("denumire");
                                if (tip == tipAdeverinta) {
                                    out.println("<option value='" + tip + "' selected>" + denumire + "</option>");
                                } else {
                                    out.println("<option value='" + tip + "'>" + denumire + "</option>");
                                }
                            }
                        }
                        %>
                        </select>
                    </div>
                    <div>
                        <label style="color:<%out.println(text);%>" class="login__label">Pentru a servi la...</label>
                        <textarea style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" 
                                  required class="login__input" name="motiv" rows="4"><%=motiv%></textarea>
                    </div>
                    <div>
                        <label style="color:<%out.println(text);%>" class="login__label">Data creare</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" 
                               type="text" class="login__input" value="<%=dataCreare%>" disabled />
                    </div>
                </div>
                
                <input type="hidden" name="idadev" value="<%=id%>" />
                
                <div class="login__buttons" style="display: flex; gap: 10px;">
                    <input class="login__button" type="submit" value="Salvează" 
                           style="flex: 1; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>">
                    <a href="adeverintenoiuser.jsp?pag=1" class="login__button" 
                       style="flex: 1; box-shadow: 0 6px 24px #777777; background:#777777; text-align: center; display: flex; justify-content: center; align-items: center;">
                       Anulare
                    </a>
                </div>
            </form>
        </div>
    </div>
<%
                } else {
                    out.println("Nu există date pentru adeverința selectată.");
                }
                rs1.close();
                stm.close();
            } else {
            	out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu există date!');");
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
    out.println("alert('Nu e nicio sesiune activă!');");
    out.println("</script>");
    response.sendRedirect("login.jsp");
}
%>

<script src="./responsive-login-form-main/assets/js/main.js"></script>
</body>
</html>