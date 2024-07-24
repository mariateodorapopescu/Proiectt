<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Vizualizare angajati</title>
       <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js" integrity="sha512-GsLlZN/3F2ErC5ifS5QtgpiJtWd43JWSuIgh7mbzZ8zBps+dvLusV+eNQATqgA/HdeKFVgA5v3S/cIrLF7QnIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <style>
    
    a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
    
    </style>
</head>
<body>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    if (userType != 0) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        int idDep = Integer.valueOf(request.getParameter("iddep"));
                        
                    	%>
                    	<div class="main-content">
        <div class="header">
         </div>
        <div class="content">
            <div class="intro">             	
                    	<%
                        
                        PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                        stm.setInt(1, idDep);
                        ResultSet rs2 = stm.executeQuery();
                        String deptName = "";
                        if (rs2.next()) {
                            deptName = rs2.getString("nume_dep");
                        }
                        out.println("<h1>Vizualizare angajati din departamentul " + deptName + "</h1><br>");
%>              	
                    	
                 <div class="events"  id="content">
                <table style="border-bottom: 1px solid #3F48CC;">
                    <thead>
                        <tr style="background-color: #3F48CC; border-bottom: 1px solid #3F48CC;">
                        
                    <th>Nume</th>
                    <th>Prenume</th>
                    <th>Username</th>
                    <th>Functie</th>
                    <th>Departament</th>
                    
                </tr>
            </thead>
            <tbody>
                        

<%

                        PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, username, denumire, nume_dep FROM useri left JOIN tipuri on tipuri.tip = useri.tip left JOIN departament on departament.id_dep = useri.id_dep WHERE useri.id_dep = ?");
                        stmt.setInt(1, idDep);
                        ResultSet rs1 = stmt.executeQuery();
                        boolean found = false;
                        while (rs1.next()) {
                            found = true;
                            out.println("<tr><td>" + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("username") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");
                        }
                        if (!found) {
                            out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                        }
                        %>
                         </tbody>
                </table> 
                              
                </div>
                 <div class="into">
                  <button id="generate" onclick="generate()" style="--bg:#3F48CC;">Descarcati PDF</button>
                  <%
                 
            		
            			out.println("<button style='--bg:#3F48CC;'><a href='viewangdep.jsp'>Inapoi</a></button></div>");
         		
                  
                  %>
               
                <script>
              
                function generate() {
                    const element = document.getElementById('content'); // Ensure you target the specific div
                    html2pdf().set({
                        pagebreak: { mode: ['css', 'legacy'] },
                        html2canvas: {
                            scale: 1, // Adjust scale to manage the size and visibility of content
                            logging: true,
                            dpi: 192,
                            letterRendering: true,
                            useCORS: true // This helps handle external content like images
                        },
                        jsPDF: {
                            unit: 'in',
                            format: 'a4',
                            orientation: 'landscape' // Change to 'landscape' if the content is too wide
                        }
                    }).from(element).save();
                }

            </script>
                
                <%
                        rs1.close();
                        stmt.close();
                        stm.close();
                        
                    }
                }
                rs.close();
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
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("login.jsp");
    }

%>
</body>
</html>
