<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// codul pentru fisierele .jsp arata in mare parte cam asa, dupa aceasta structura
// incep prin a face rost de sesiune si de datele stocate la nivel de sesiune, adica utilizatorul
// apoi pe baza a ceea ce am stocat in utilizator, selectez si fac alte interogari ca sa aflu alte lucruri
// in mare, daca am sesiune activa, utilizator in sesiune (adica e cineva conectat) 
// se afiseaza pagina in functie de tipul si de utilizatorul in sine (tematica, tipul de dashboard, alte functionalitati)
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
<html>
<head>
    <title>Vizualizare angajati</title>
     <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css"> 
   <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
   <style>
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
    </style>
   
   <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
   
    <!--=============== scripts ===============-->
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
<div style="position: fixed; top: 0; left: 25%; margin: 0; position: relative; padding-left:1rem; padding-right:1rem;" class="main-content">
         <div style=" border-radius: 2rem;" class="content">
            <div class="intro" style=" border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                 <div class="events"  style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                 <h1>Angajati din departamentul meu</h1>
                <h3><%out.println(today); %></h3>
                <table >
                    <thead>
                         <tr style="color:<%out.println("white");%>">
                         	<th>Nr. crt.</th>
                            <th>Nume</th>
                            <th>Prenume</th>
                            <th>Functie</th>
                            <th>Departament</th>
                        </tr>
                    </thead>
                    <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                   	<%
                       try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM useri left join tipuri on useri.tip = tipuri.tip left join departament on departament.id_dep = useri.id_dep where useri.id_dep = ? and username <> \"test\"")) {
                           stmt.setInt(1, userdep);
                       	ResultSet rs1 = stmt.executeQuery();
                           boolean found = false;
                           int nr = 1;
                           while (rs1.next()) {
                               found = true;
                               out.println("<tr><td>" + nr++ + "</td><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");   
                           }
                           if (!found) {
                               out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                           }
                           out.println("</table>");
                       }
                       %>
                	</tbody>
                </table>              
                </div>
                <div class="intro" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                 <button id="generate" onclick="generate()" >Descarcati PDF</button>
                 <% if (userType == 3) { %> 
                 <button><a href='viewang4.jsp'>Inapoi</a></button></div>
                 <% 
                    }
                 if (userType == 0)  { %>
                     <button><a href='viewang.jsp'>Inapoi</a></button></div>
                     <% 
                 }
                        }
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
    	        out.println("alert('Eroare la baza de date!');");
    	        out.println("</script>");
                response.sendRedirect("viewcolegidep.jsp");
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
<script>
    function generate() {
        const element = document.getElementById("content");
        html2pdf()
        .from(element)
        .save();
    } 
</script>
</body>
</html>
