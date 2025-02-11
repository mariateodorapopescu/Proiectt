<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>


<%
String cnp = "";
cnp = request.getParameter("cnp");
if (cnp == null){
	cnp = "";
}
System.out.println(cnp); // ok
String idd = request.getParameter("idd");

if (idd == null || idd.trim().isEmpty()) {
 idd = "0"; 
} else {
	idd = idd.replaceAll("[^0-9]", ""); // Păstrează doar cifre
}
if (idd.isEmpty()) {
 idd = "0";
}
int idd2 = 0;
try {
 idd2 = Integer.parseInt(idd);
 System.out.println("ID-ul este: " + idd2); // ✅ Va afișa un număr valid
} catch (NumberFormatException e) {
 System.err.println("Eroare: ID invalid! Valoarea primită: " + idd);
}

HttpSession sesi = request.getSession(false);
    		String username = null;
if (sesi != null) {
	 username = (String) sesi.getAttribute("username");
	 System.out.println(username); // ok
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    int userId = 0;
    if (currentUser != null) {
    	       
    	username = currentUser.getUsername();

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
    	        
    	        userId = rs.getInt("id");
    	        System.out.println(userId); // ok
    	        int userType = 0;
    	        userType = rs.getInt("tip");
    	        System.out.println(userType); // ok
    	        
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
    	            }  catch (Exception e) {
    	             	System.err.println("Oooff... ceva nu a mers bine =( ");
    	             }
    	            userId = idd2;
    	        	System.out.println(userId); 
    	        	%>
    	        	 <html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <title>Modificare parola</title>
    <style>
        :root {
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
            background: <%=clr%>;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">
<div class="container" style="background: <%=clr%>; color: <%=text%>;">
    <div class="login__content" style="justify-content: center; border-radius: 2rem; border-color: <%=sidebar%>; background: <%=clr%>;">
        <div align='center'>
            
            <form style="background:  <%=sidebar%>; border-color: <%=sidebar%>;" action="<%=request.getContextPath()%>/ModifPasdServlet" method='post' class='login__form'>
            <h1 style="color: <%=accent%>;">Modificare parola</h1>
                <input type='hidden' name='id' value='<%=userId%>' />
                <table style='width: 80%'>
                    <tr>
                        <label style="color: <%=text%>;" for="" class="login__label">Parola</label>
    
                                <div class="login__box">
                                    <input style="color: <%=text%>; background:  <%=sidebar%>; border-color: <%=accent%>;" type="password" placeholder="Introduceti parola" required class="login__input" id="input-pass" name="password">
                                    <i class="ri-eye-off-line login__eye" id="input-icon"></i>
                                    
                                    
                                </div></tr>
                    <tr><td>  <a style="color:  <%=accent%>;" href='modifdel.jsp' class='login__forgot'>Inapoi</a></td></tr>
                    <tr>
                  
                        <td colspan='2'><input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button"></td>
                    </tr>
                </table>
                 
            </form>
           
        </div>
    </div>
</div>

<% if ("true".equals(request.getParameter("p"))) %>
    <script type='text/javascript'>
        alert('Trebuie sa alegeti o parola mai complexa!');
   
    <br>Parola trebuie sa contina:<br>
    - minim 8 caractere<br>
    - un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>
    - o litera mare<br>
    - o litera mica<br>
    - o cifra<br>
    - cifrele alaturate sa nu fie egale sau consecutive<br>
    - literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele
    </script>
    <%
    	        }
                catch (Exception e) {
             	System.err.println("Oooff... ceva nu a mers bine =( ");
             }
         }
     } catch (Exception e) {
     	System.err.println("Oooff... ceva nu a mers bine =( ");
     }
 } else {
	 Connection connection = null;
     PreparedStatement preparedStatement = null;
     ResultSet rs = null;

     try {
         Class.forName("com.mysql.cj.jdbc.Driver");
         connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE cnp = ?");
         preparedStatement.setString(1, cnp);
         rs = preparedStatement.executeQuery();

         if (!rs.next()) {
             out.println("<script type='text/javascript'>alert('Date introduse incorect sau nu exista date!');</script>");
         } else {
             // int userId = 0;
             userId = rs.getInt("id");
             System.out.println(userId); // ok
             int userType = 0;
             userType = rs.getInt("tip");
             System.out.println(userType); // ok
             
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
                         %>
                          <html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <title>Modificare parola</title>
    <style>
        :root {
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
            background: <%=clr%>;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">
<div class="container" style="background: <%=clr%>; color: <%=text%>;">
    <div class="login__content" style="justify-content: center; border-radius: 2rem; border-color: <%=sidebar%>; background: <%=clr%>;">
        <div align='center'>
            
            <form style="background:  <%=sidebar%>; border-color: <%=sidebar%>;" action="<%=request.getContextPath()%>/ModifPasdServlet" method='post' class='login__form'>
            <h1 style="color: <%=accent%>;">Modificare parola</h1>
                <input type='hidden' name='id' value='<%=userId%>' />
                <table style='width: 80%'>
                    <tr>
                        <label style="color: <%=text%>;" for="" class="login__label">Parola</label>
    
                                <div class="login__box">
                                    <input style="color: <%=text%>; background:  <%=sidebar%>; border-color: <%=accent%>;" type="password" placeholder="Introduceti parola" required class="login__input" id="input-pass" name="password">
                                    <i class="ri-eye-off-line login__eye" id="input-icon"></i>
                                    
                                    
                                </div></tr>
                    <tr><td>  <a style="color:  <%=accent%>;" href='modifdel.jsp' class='login__forgot'>Inapoi</a></td></tr>
                    <tr>
                  
                        <td colspan='2'><input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button"></td>
                    </tr>
                </table>
                 
            </form>
           
        </div>
    </div>
</div>

<% if ("true".equals(request.getParameter("p"))) %>
    <script type='text/javascript'>
        alert('Trebuie sa alegeti o parola mai complexa!');
   
    <br>Parola trebuie sa contina:<br>
    - minim 8 caractere<br>
    - un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>
    - o litera mare<br>
    - o litera mica<br>
    - o cifra<br>
    - cifrele alaturate sa nu fie egale sau consecutive<br>
    - literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele
    </script>
                         <%
                     }
                 } catch (Exception e) {
 	             	System.err.println("Oooff... ceva nu a mers bine =( ");
 	             }
 			} catch (Exception e) {
             	System.err.println("Oooff... ceva nu a mers bine =( ");
             }
		}
     } catch (Exception e) {
      	System.err.println("Oooff... ceva nu a mers bine =( ");
      }
 }
}     
                %>
         
<script src="./responsive-login-form-main/assets/js/main.js"></script>
</body>
</html>
