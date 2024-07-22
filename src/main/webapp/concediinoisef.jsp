<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Aprobare concediu</title>
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
     <style>
        
        a, a:visited, a:hover, a:active{text-decoration: none; color:#eaeaea !important}
    </style>
</head>
<style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #e0f7fa;
        }
        .container {
            width: 100%;
            max-width: 1200px;
            margin: auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            font-size: 24px;
            margin-bottom: 20px;
            color: #00796b;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #00796b;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
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
        @media (max-width: 600px) {
            table, thead, tbody, th, td, tr {
                display: block;
            }
            th, td {
                text-align: right;
            }
            th {
                position: absolute;
                top: -9999px;
                left: -9999px;
            }
            tr {
                border: 1px solid #ccc;
                margin-bottom: 5px;
            }
            td {
                border: none;
                border-bottom: 1px solid #eee;
                position: relative;
                padding-left: 50%;
                text-align: left;
            }
            td:before {
                position: absolute;
                top: 6px;
                left: 6px;
                width: 45%;
                padding-right: 10px;
                white-space: nowrap;
                content: attr(data-label);
                font-weight: bold;
                text-align: left;
            }
        }
    </style>
<body>
<%
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
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 3) {  // Assuming only type 4 users can approve
                    	
                    	
                    	out.println("<h1>Vizualizare angajati din toata institutia</h1><br>");
                        %>
                        <div class="container">
                         <table>
            <thead>
                <tr>
                    <th>Nr. crt</th>
                    <th>Departament</th>
                    <th>Nume</th>
                    <th>Prenume</th>
                    <th>Functie</th>
                    <th>Inceput</th>
                    <th>Final</th>
                    <th>Motiv</th>
                    <th>Locatie</th>
                    <th>Tip concediu</th>
                    <th>Status</th>
                     <th>Aprobati</th>
                      <th>Dezaprobati</th>
                </tr>
            </thead>
            <tbody><%
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
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
                            while (rs1.next()) {
                                found = true;
                                out.print("<tr><td data-label='Nr. crt'>" + rs1.getInt("nr_crt") + "</td><td data-label='Departament'>" + rs1.getString("departament") + "</td><td data-label='Nume'>" +
                                        rs1.getString("nume") + "</td><td data-label='Prenume'>" + rs1.getString("prenume") + "</td><td data-label='Functie'>" + rs1.getString("functie") + "</td><td data-label='Inceput'>" +
                                        rs1.getDate("start_c") + "</td><td data-label='Final'>" + rs1.getDate("end_c") + "</td><td data-label='Motiv'>" + rs1.getString("motiv") + "</td><td data-label='Locatie'>" +
                                        rs1.getString("locatie") + "</td>" + "<td data-label='Tip concediu'>" + rs1.getString("tipcon") + "</td>");

                              
                              if (rs1.getString("status").compareTo("aprobat sef") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-aprobat-sef'><i class='ri-checkbox-circle-line'></i></span></td>");
                                  out.println("<td data-label='Status'><span class='status-icon status-aprobat-director'><a href='aprobsef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-checkbox-circle-line'></i></a></span></td>");
                                  out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-director'><a href='ressef?idcon=" + rs1.getInt("nr_crt")+ "'><i class='ri-close-line'></i></a></span></td></tr>");
                              }}
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            
                        }
                    	
                         %>
                          </tbody>
        </table>  </div><%
        
        if (userType == 0) {
            out.println("<a href ='dashboard.jsp'>Inapoi</a>");
         }
         if (userType == 1) {
             out.println("<a href ='tip1ok.jsp'>Inapoi</a>");
          }
         if (userType == 2) {
             out.println("<a href ='tip2ok.jsp'>Inapoi</a>");
          }
         if (userType == 3) {
             out.println("<a href ='sefok.jsp'>Inapoi</a>");
          }
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
</body>
</html>