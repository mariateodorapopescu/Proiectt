<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

//structura unei pagini este astfel
//verificare daca exista sesiune activa, utilizator conectat, 
//extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//se mai extrag temele de culoare ale fiecarui utilizator
//apoi se incarca pagina in sine

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizatoir in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extrag usernameul, care e unic si asta cam transmit in formuri (mai transmit si id dar deocmadata ma bazez pe username)
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	// extrag date despre userul curent
                    int id = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType != 4) {  
                    	// aflu data curenta, tot ca o interogare bd =(
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
                   	 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                   	 String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
        a, a:visited, a:hover, a:active{color:white !important}
    </style>
    
   <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Acasa</title>
    
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

	<div class="main-content">
	 <div class="intro" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
		<h3>Ce doriti sa faceti?</h3>
		<button > <a href = "addc.jsp" style="text-decoration:none;">Adaugare concediu</a></button>
		<button ><a href = "concediinoisef.jsp?pag=1" style="text-decoration:none;">Modificare si stergere concedii</a></button>
      </div>
   </div>
   
    <script src="./responsive-login-form-main/assets/js/index.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const iframe = document.getElementById('iframe');
            const links = document.querySelectorAll('.load-content');

            links.forEach(link => {
                link.addEventListener('click', function(event) {
                    event.preventDefault();
                    iframe.src = this.href;
                });
            });

            iframe.onload = function() {
                const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
                iframe.style.height = iframeDocument.documentElement.scrollHeight + 'px';
            };
        });
    </script>
                       <%
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
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
