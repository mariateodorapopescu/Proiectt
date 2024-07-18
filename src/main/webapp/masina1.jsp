<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>

<head>
    <title>Vizualizare concedii</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
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
</head>

<body>
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
                </tr>
            </thead>
            <tbody>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id, id_dep FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    if (userType == 4) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                    	
                    	 int id = Integer.valueOf(request.getParameter("id"));
                    	 int status = Integer.valueOf(request.getParameter("status"));
                    	 int tip = Integer.valueOf(request.getParameter("tip"));
                    	 int dep = Integer.valueOf(request.getParameter("dep"));
                    	 String an =  request.getParameter("an");
                    	 int perioada = 0;
                    	 String start = null;
                    	 String end = null;
                    	
                    	if (an == null) {
                    		perioada = 1;
                    		start = request.getParameter("start");
                    		end = request.getParameter("end");
                    	}
                    	
                    	int pag = Integer.valueOf(request.getParameter("pag"));
                    	
                    	String sql = null;
                    	PreparedStatement stmtt2 = null;
                    	
                    	if (pag == 3) {
               			 out.println("<h1> Vizualizare concedii personale");
             				
               		}
               		if (pag == 4) {
               		
                    	 out.println("<h1> Vizualizare concedii ale unui angajat");

                     }
               		
               		if (pag == 5) {
              			 out.println("<h1> Vizualizare concedii ale unui coleg din departamentul meu");
            				
              		}
               		if (pag == 6) {
             			 out.println("<h1> Vizualizare concedii din departamentul meu");
           				
             		}
               		if (pag == 7) {
                     	out.println("<h1> Vizualizare concedii dintr-un departament ");
           				
             		}
               		if (pag == 8) {
            			 out.println("<h1> Vizualizare concedii din toata institutia");
          				
            		}
               		
               		if (perioada == 0) {
               			out.println(" pe an. </h1>");
               		} else 
               		{
               			out.println(" pe perioada " + start + " - " + end + ". </h1>");
               		}
                    	
                    	if (pag == 3 || pag == 4 || pag == 5) {
                    		
                    		if (status == 3 && tip == -1 && perioada == 0) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ?";
                    			  stmtt2 = connection.prepareStatement(sql);
                    			  stmtt2.setInt(1, id);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.tip = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			  stmtt2.setInt(1, id);
                   			stmtt2.setInt(2, tip);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			  stmtt2.setInt(1, id);
                   			stmtt2.setInt(2, status);
                  		}
                    		if (status != 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.tip = ? and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			  stmtt2.setInt(1, id);
                   			stmtt2.setInt(2, tip);
                   			stmtt2.setInt(3, status);
                  		}
                    		if (status == 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                			  stmtt2.setInt(1, id);
                				stmtt2.setString(2, start);
                				stmtt2.setString(3, end);
                				stmtt2.setString(4, end);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 1) {
                  			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                       "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                       "FROM useri u " +
                                       "JOIN tipuri t ON u.tip = t.tip " +
                                       "JOIN departament d ON u.id_dep = d.id_dep " +
                                       "JOIN concedii c ON c.id_ang = u.id " +
                                       "JOIN statusuri s ON c.status = s.status " +
                                       "JOIN tipcon ct ON c.tip = ct.tip " +
                                       "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.tip = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                  			stmtt2 = connection.prepareStatement(sql);
              			  stmtt2.setInt(1, id);
              			stmtt2.setInt(2, tip);
              				stmtt2.setString(3, start);
              				stmtt2.setString(4, end);
              				stmtt2.setString(5, end);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                			  stmtt2.setInt(1, id);
                			stmtt2.setInt(2, status);
                				stmtt2.setString(3, start);
                				stmtt2.setString(4, end);
                				stmtt2.setString(5, end);
                    		}
                    		if (status != 3 && tip != -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.id_ang = ? and c.tip = ? c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                			  stmtt2.setInt(1, id);
                			stmtt2.setInt(2, tip);
                			stmtt2.setInt(3, status);
                				stmtt2.setString(4, start);
                				stmtt2.setString(5, end);
                				stmtt2.setString(6, end);
                    		}
                    	}
                    	
                    	if (pag == 6 || pag == 7) {
                    		if (status == 3 && tip == -1 && perioada == 0) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ?";
                    			  stmtt2 = connection.prepareStatement(sql);
                    			  stmtt2.setInt(1, dep);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.tip = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, dep);
                   			stmtt2.setInt(2, tip);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, dep);
                   			stmtt2.setInt(2, status);
                  		}
                    		if (status != 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.tip = ? and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, dep);
                   			stmtt2.setInt(2, tip);
                   			stmtt2.setInt(3, status);
                  		}
                    		if (status == 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                    			stmtt2.setInt(1, dep);
                				stmtt2.setString(2, start);
                				stmtt2.setString(3, end);
                				stmtt2.setString(4, end);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 1) {
                  			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                       "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                       "FROM useri u " +
                                       "JOIN tipuri t ON u.tip = t.tip " +
                                       "JOIN departament d ON u.id_dep = d.id_dep " +
                                       "JOIN concedii c ON c.id_ang = u.id " +
                                       "JOIN statusuri s ON c.status = s.status " +
                                       "JOIN tipcon ct ON c.tip = ct.tip " +
                                       "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.tip = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                  			stmtt2 = connection.prepareStatement(sql);
                  			stmtt2.setInt(1, dep);
              			stmtt2.setInt(2, tip);
              				stmtt2.setString(3, start);
              				stmtt2.setString(4, end);
              				stmtt2.setString(5, end);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                    			stmtt2.setInt(1, dep);
                			stmtt2.setInt(2, status);
                				stmtt2.setString(3, start);
                				stmtt2.setString(4, end);
                				stmtt2.setString(5, end);
                    		}
                    		if (status != 3 && tip != -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and u.id_dep = ? and c.tip = ? c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                    			stmtt2.setInt(1, dep);
                			stmtt2.setInt(2, tip);
                			stmtt2.setInt(3, status);
                				stmtt2.setString(4, start);
                				stmtt2.setString(5, end);
                				stmtt2.setString(6, end);
                    		}
                    	}
                    	if (pag == 8) {
                    		if (status == 3 && tip == -1 && perioada == 0) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE())";
                    			  stmtt2 = connection.prepareStatement(sql);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.tip = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, tip);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, status);
                  		}
                    		if (status != 3 && tip != -1 && perioada == 0) {
                    			sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                        "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "JOIN departament d ON u.id_dep = d.id_dep " +
                                        "JOIN concedii c ON c.id_ang = u.id " +
                                        "JOIN statusuri s ON c.status = s.status " +
                                        "JOIN tipcon ct ON c.tip = ct.tip " +
                                        "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.tip = ? and c.status = ?";
                   			  stmtt2 = connection.prepareStatement(sql);
                   			stmtt2.setInt(1, tip);
                   			stmtt2.setInt(2, status);
                  		}
                    		if (status == 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                				stmtt2.setString(1, start);
                				stmtt2.setString(2, end);
                				stmtt2.setString(3, end);
                    		}
                    		if (status == 3 && tip != -1 && perioada == 1) {
                  			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                       "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                       "FROM useri u " +
                                       "JOIN tipuri t ON u.tip = t.tip " +
                                       "JOIN departament d ON u.id_dep = d.id_dep " +
                                       "JOIN concedii c ON c.id_ang = u.id " +
                                       "JOIN statusuri s ON c.status = s.status " +
                                       "JOIN tipcon ct ON c.tip = ct.tip " +
                                       "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.tip = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                  			stmtt2 = connection.prepareStatement(sql);
              			stmtt2.setInt(1, tip);
              				stmtt2.setString(2, start);
              				stmtt2.setString(3, end);
              				stmtt2.setString(4, end);
                  		}
                    		if (status != 3 && tip == -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                			stmtt2.setInt(1, status);
                				stmtt2.setString(2, start);
                				stmtt2.setString(3, end);
                				stmtt2.setString(4, end);
                    		}
                    		if (status != 3 && tip != -1 && perioada == 1) {
                    			  sql = "SELECT c.id AS nr_crt, d.nume_dep AS departament, u.nume, u.prenume, " +
                                         "t.denumire AS functie, c.start_c, c.end_c, c.motiv, c.locatie, s.nume_status AS status, ct.motiv as tipcon " +
                                         "FROM useri u " +
                                         "JOIN tipuri t ON u.tip = t.tip " +
                                         "JOIN departament d ON u.id_dep = d.id_dep " +
                                         "JOIN concedii c ON c.id_ang = u.id " +
                                         "JOIN statusuri s ON c.status = s.status " +
                                         "JOIN tipcon ct ON c.tip = ct.tip " +
                                         "WHERE YEAR(c.start_c) = YEAR(CURDATE()) and c.tip = ? c.status = ? AND c.start_c between ? AND ? AND c.end_c <= ?";
                    			stmtt2 = connection.prepareStatement(sql);
                			stmtt2.setInt(1, tip);
                			stmtt2.setInt(2, status);
                				stmtt2.setString(3, start);
                				stmtt2.setString(4, end);
                				stmtt2.setString(5, end);
                    		}
                    	}
                    	
                    	  ResultSet rss1 = stmtt2.executeQuery();
                          boolean found = false;

                          while (rss1.next()) {
                              found = true;
                              out.print("<tr><td data-label='Nr. crt'>" + rss1.getInt("nr_crt") + "</td><td data-label='Departament'>" + rss1.getString("departament") + "</td><td data-label='Nume'>" +
                                        rss1.getString("nume") + "</td><td data-label='Prenume'>" + rss1.getString("prenume") + "</td><td data-label='Functie'>" + rss1.getString("functie") + "</td><td data-label='Inceput'>" +
                                        rss1.getDate("start_c") + "</td><td data-label='Final'>" + rss1.getDate("end_c") + "</td><td data-label='Motiv'>" + rss1.getString("motiv") + "</td><td data-label='Locatie'>" +
                                        rss1.getString("locatie") + "</td>" + "<td data-label='Tip concediu'>" + rss1.getString("tipcon") + "</td>");

                              if (rss1.getString("status").compareTo("neaprobat") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-neaprobat'><i class='ri-close-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("dezaprobat sef") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-sef'><i class='ri-close-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("dezaprobat director") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-dezaprobat-director'><i class='ri-close-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("aprobat director") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-aprobat-director'><i class='ri-checkbox-circle-line'></i></span></td></tr>");
                              }
                              if (rss1.getString("status").compareTo("aprobat sef") == 0) {
                                  out.println("<td data-label='Status'><span class='status-icon status-aprobat-sef'><i class='ri-checkbox-circle-line'></i></span></td></tr>");
                              }
                          }
                          if (!found) {
                              out.println("<tr><td colspan='11'>Nu exista date.</td></tr>");
                          }
                          rss1.close();
                          stmtt2.close();
                        
                    }
           
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
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("login.jsp");
    }

%>
 </tbody>
        </table>
    </div>
</body>
</html>