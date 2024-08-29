<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%
// structura unei pagini suna cam asa
// verificare daca exista sesiune activa, utilizator logat(curent), 
// extragere date despre user cum ar fi tipul ca sa se stie ce pagina 
// sa deschida, temele de culoare ale fiecarui utilizator
// apoi se incarca pagina in sine
// in ceea ce priveste gruparea de pagini concediinoieu, concediinoisef, concediinoidir, e cam asa
// header cu titlu si data curenta
// cap de tabel: partea comuna la toti 3 e de la nr crt la status, apoi la sef si la dir e in plus aprobati/respingeti
// nrcrt, nume, preume, functie, departament, inceput, sfarsit, motiv, locatie, tip, adaugat, modificat, acceptat/respins, status
// masina2?
// apoi vine sql ul comun SELECT c.acc_res, c.added, c.modified, c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, t.denumire AS functie, c.start_c, c.end_c,
// c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon FROM useri u JOIN tipuri t ON u.tip = t.tip JOIN departament d ON u.id_dep = d.id_dep 
// JOIN concedii c ON c.id_ang = u.id JOIN statusuri s ON c.status = s.status JOIN tipcon ct ON c.tip = ct.tip WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ?
// la care in plus depinzand de user se adauga: and c.status = 0 (sef) and c.status = 1 (director), c.id_ang sau id = uid pentru concediinoieu
// exista 2 tipuri de concediinoieu, unul care permite modificarea -> si aici ai cazuri: and c.status = 0 pentru tip1,tip2, and c.status = 1 pentru director si sef 
// -> la fel, la partea comuna din capul de tabel adaugi coloanele de modificati/stergeti
// apoi vin ultimele coloane: status, aprobati,respingeti/modificati,stergeti cu iconitele:  if (rs1.getString("status").compareTo("neaprobat") == 0) {
// out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Neaprobat</span><span class='status-icon status-neaprobat'><i class='ri-focus-line'></i></span></td>");
// out.println("<td data-label='Status'><span class='status-icon status-aprobat-sef'><a href='aprobsef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-checkbox-circle-line'></i></a></span></td>");
// out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-sef'><a href='ressef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-close-line'></i></a></span></td></tr>"); }
// deci, hai sa pregatim teren pentru masina2 care le contine pe astea: deci in loc de 4 o sa am 1 =)
    
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
    <title>Concedii noi</title>
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <meta charset="UTF-8">
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
      <style>
        
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
  
        .status-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 14px;
        }
        
        .status-neaprobat { background-color: #88aedb; }
        .status-dezaprobat-sef { background-color: #b37142; }
        .status-dezaprobat-director { background-color: #873931; }
        .status-aprobat-director { background-color: #40854a; }
        .status-aprobat-sef { background-color: #ccc55e; }
        .status-pending { background-color: #e0a800; }
       
       /* Tooltip */
       	.tooltip {
		  position: relative; 
		  border-bottom: 1px dotted black; 
		}
		
		.tooltip .tooltiptext {
		  visibility: hidden;
		  width: 120px;
		  background-color: rgba(0,0,0,0.5);
		  color: white;
		  text-align: center;
		  padding: 5px 0;
		  border-radius: 6px;
		  position: absolute;
		  z-index: 1;
		}
		
		.tooltip:hover .tooltiptext {
		  visibility: visible;
		}
       
    </style>
    </head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

     <div class="main-content">
        <div class="header"></div>
        <div style=" border-radius: 2rem;" class="content">
            <div class="intro" style="border-radius: 2rem; background:<%out.println(sidebar);%>;">
                 <div class="events" style="border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                  <h1>Cereri noi de concedii</h1>
                <h3><%out.println(today); %></h3>
                <table>
                    <thead>
                        <tr>
                  <th style="color:white">Nr.crt</th>
                    <th style="color:white">Nume</th>
                    <th style="color:white">Prenume</th>
                    <th style="color:white">Functie</th>
                    <th style="color:white">Departament</th>
                    <th style="color:white">Salariu de baza</th>
                    <th style="color:white">Acordati salariul</th>
                    <th style="color:white">Marire?</th>
                     <th style="color:white">Penalizari?</th>
                    </tr>
                    </thead>
                   <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
  
                    <%
                    // interogare de baza
                    String sql = "SELECT u.id, u.salariu, d.nume_dep AS departament, u.nume, u.prenume, " +
                            "t.denumire AS functie " +
                            "FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "WHERE u.platit = 0 and u.id <> " + id;
                    
                    try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                    	ResultSet rs1 = stmt.executeQuery();
                        boolean found = false;
                        int nr = 1;
                        while (rs1.next()) {
                            found = true;
                          	
                            		
                            out.print("<tr><td data-label='Nr.crt'>" + nr + "</td><td data-label='Nume'>" +
                                    rs1.getString("nume") + "</td><td data-label='Prenume'>" + rs1.getString("prenume") + "</td><td data-label='Functie'>" + rs1.getString("functie") + "</td><td data-label='Departament'>" + rs1.getString("departament") + 
                                     "</td>" + "<td data-label='Salariu de baza'>" + rs1.getString("salariu") + "</td>");
                            // acordare salariu
	                              out.println("<td data-label='Status'><span class='status-icon status-neaprobat'><a href='acordare?id=" + rs1.getInt("id")+ "'><i class='ri-checkbox-circle-line'></i></a></span></td>");
	                           // acordare marire
	                              out.println("<td data-label='Status'><span class='status-icon status-aprobat-director'><a href='marire?id=" + rs1.getInt("id")+ "'><i class='ri-focus-line'></i></a></span></td>");
                            // acordare penalizari   
                            out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-director'><a href='penalizare?id=" + rs1.getInt("id")+ "'><i class='ri-close-line'></i></a></span></td></tr>");
	                          
                         nr++; 
                        }
                        if (!found) {
                            out.println("<tr><td colspan='14'>Nu exista date.</td></tr>");
                        }
                    }
                         %>
                          </tbody>
                </table> 
                              
                </div>
                <div class="into">
                  <button id="generate" onclick="generate()" >Descarcati PDF</button>
                </div>
                
                <%
        			} else {
                    	switch (userType) {
                        case 4: response.sendRedirect("adminok.jsp"); break;
                    }
                    }
                } else {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
    	        out.println("alert('Eroare la baza de date!');");
    	        out.println("alert('" + e.getMessage() + "');");
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