<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%

// Verificare sesiune și obținere user curent
HttpSession sesi = request.getSession(false);

if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement(
                    "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                    "dp.denumire_completa AS denumire FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                    "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    // extrag date despre userul curent
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    boolean isHR = (userDep == 1); // Department HR

                    // Verificare acces - doar HR poate vizualiza CV-urile candidaților
                    if (!isHR && !isDirector && !isAdmin) {
                        response.sendRedirect("Access.jsp?error=accessDenied");
                        return;
                    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Vizualizare CV-uri Candidați</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .candidates-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .candidates-table th,
        .candidates-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        
        .candidates-table th {
            background-color: #f5f5f5;
        }
        
        .btn-view-cv {
            background-color: #3498db;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
        }
        
        .btn-view-cv:hover {
            background-color: #2980b9;
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
   
            <h1>CV-uri Candidați</h1>
            
            <table class="candidates-table">
                <thead>
                    <tr>
                        <th>Nume</th>
                        <th>Prenume</th>
                        <th>Email</th>
                        <th>Telefon</th>
                        <th>Data aplicării</th>
                        <th>Poziție</th>
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="candidate" items="${candidates}">
                        <tr>
                            <td>${candidate.nume}</td>
                            <td>${candidate.prenume}</td>
                            <td>${candidate.email}</td>
                            <td>${candidate.telefon}</td>
                            <td>${candidate.data_aplicare}</td>
                            <td>${candidate.pozitie}</td>
                            <td>
                                <a href="CVGeneratorServlet?action=generate&id=${candidate.id}" 
                                   class="btn-view-cv">Vezi CV</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
       
    
    <script src="js/core2.js"></script>
</body>
</html>

<%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
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