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
                    if (userType == 3) {  // Assuming only type 4 users can approve
                    	
                    	
                    	String today = null;
                   	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            // Check for upcoming leaves in 3 days
                            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                // stmt.setInt(1, id);
                                try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                      today =  rs2.getString("today");
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
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
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
       
       .tooltip {
  position: relative;
  
  border-bottom: 1px dotted black; /* If you want dots under the hoverable text */
}

/* Tooltip text */
.tooltip .tooltiptext {
  visibility: hidden;
  width: 120px;
  background-color: rgba(0,0,0,0.5);
  color: white;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;
 
  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
}

/* Show the tooltip text when you mouse over the tooltip container */
.tooltip:hover .tooltiptext {
  visibility: visible;
}
       
    </style>
    </head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

                        	<div class="main-content">
        <div class="header">
         </div>
        <div style=" border-radius: 2rem;" class="content">
            <div class="intro" style="border-radius: 2rem; background:<%out.println(sidebar);%>;">
           
                 <div class="events" style="border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                  <h1>Cereri noi de concedii</h1>
                <h3><%out.println(today); %></h3>
                <table>
                    <thead>
                        <tr >
                   
                  <th style="color:white">Nr.crt</th>
                    <th style="color:white">Nume</th>
                    <th style="color:white">Prenume</th>
                    <th style="color:white">Fct</th>
                    <th style="color:white">Dep</th>
                    <th style="color:white">Inceput</th>
                    <th style="color:white">Final</th>
                    <th style="color:white">Motiv</th>
                    <th style="color:white">Locatie</th>
                    <th style="color:white">Tip</th>
                    <th style="color:white">Adaugat</th>
                    <th style="color:white">Modif</th>
                     <th style="color:white">Acc/Res</th>
                    <th style="color:white">Status</th>
                    
                     <th style="color:white">Aprobati</th>
                     <th style="color:white">Respingeti</th>
                </tr>
                    </thead>
                   <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                    
                    
                    <%
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT c.acc_res, c.added, c.modified, c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                "FROM useri u " +
                                "JOIN tipuri t ON u.tip = t.tip " +
                                "JOIN departament d ON u.id_dep = d.id_dep " +
                                "JOIN concedii c ON c.id_ang = u.id " +
                                "JOIN statusuri s ON c.status = s.status " +
                                "JOIN tipcon ct ON c.tip = ct.tip " +
                                "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.status = 0")) {
                            
                        	stmt.setInt(1, userdep);
                        	ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            int nr = 1;
                            while (rs1.next()) {
                                found = true;
                               
                                
                                String added = rs1.getString("added") != null ? rs1.getString("added") : " - ";
                                String modif = rs1.getString("modified") != null ? rs1.getString("modified") : " - ";
                                String accres = rs1.getString("acc_res") != null ? rs1.getString("acc_res") : " - ";
                                		
                                out.print("<tr><td data-label='Nr.crt'>" + nr + "</td><td data-label='Nume'>" +
                                        rs1.getString("nume") + "</td><td data-label='Prenume'>" + rs1.getString("prenume") + "</td><td data-label='Fct'>" + rs1.getString("functie") + "</td><td data-label='Dep'>" + rs1.getString("departament") + 
                                        "</td>" + "<td data-label='Inceput'>" +
                                        		rs1.getString("start_c")+ "</td><td data-label='Final'>" + rs1.getString("end_c") + "</td><td data-label='Motiv'>" + rs1.getString("motiv") + "</td><td data-label='Locatie'>" +
                                        rs1.getString("locatie") + "</td>" + "<td data-label='Tip'>" + rs1.getString("tipcon") + "</td>" + "<td data-label='Adaugat'>" + added + "</td>" + "<td data-label='Modif'>" + modif + "</td>"+ 
                                        "<td data-label='Acc/Res'>" + accres + "</td>");

                              
                              if (rs1.getString("status").compareTo("neaprobat") == 0) {
                                  out.println("<td class='tooltip' data-label='Status'><span class='tooltiptext'>Neaprobat</span><span class='status-icon status-neaprobat'><i class='ri-focus-line'></i></span></td>");
                                  out.println("<td data-label='Status'><span class='status-icon status-aprobat-sef'><a href='aprobsef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-checkbox-circle-line'></i></a></span></td>");
                                  out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-sef'><a href='ressef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-close-line'></i></a></span></td></tr>");
                              }
                             nr++; 
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
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
                        case 1: response.sendRedirect("tip1ok.jsp"); break;
                        case 2: response.sendRedirect("tip1ok.jsp"); break;
                        case 3: response.sendRedirect("sefok.jsp"); break;
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