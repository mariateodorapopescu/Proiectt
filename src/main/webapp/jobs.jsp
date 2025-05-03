<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
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

                    // Pagina de joburi poate fi accesată de toți utilizatorii autentificați
                    // Toată lumea poate vedea și aplica la joburi disponibile
                    
                    // Setăm utilizatorul curent ca atribut pentru JSTL
                    request.setAttribute("currentUserId", userId);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Joburi Disponibile</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .job-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            padding: 20px;
        }
        .job-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .job-card:hover {
            transform: translateY(-5px);
        }
        .job-title {
            font-size: 1.5em;
            margin-bottom: 10px;
            color: #333;
        }
        .job-info {
            margin-bottom: 10px;
        }
        .apply-button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .apply-button:hover {
            background-color: #45a049;
        }
        .filter-section {
            margin: 20px;
            padding: 20px;
            background: #f5f5f5;
            border-radius: 8px;
        }
    </style>
</head>
<body class="bg">
   
        <div class="container">
            <h1>Joburi Disponibile</h1>
            
            <div class="filter-section">
                <form action="JobsServlet" method="get">
                    <input type="text" name="search" placeholder="Caută job..." />
                    <select name="department">
                        <option value="">Toate departamentele</option>
                        <c:forEach var="dep" items="${departments}">
                            <option value="${dep.id_dep}">${dep.nume_dep}</option>
                        </c:forEach>
                    </select>
                    <select name="location">
                        <option value="">Toate locațiile</option>
                        <c:forEach var="loc" items="${locations}">
                            <option value="${loc.id_locatie}">${loc.oras}</option>
                        </c:forEach>
                    </select>
                    <button type="submit">Caută</button>
                </form>
            </div>
            
            <div class="job-grid">
                <c:forEach var="job" items="${jobs}">
                    <div class="job-card">
                        <h2 class="job-title">${job.titlu}</h2>
                        <div class="job-info">
                            <p><strong>Departament:</strong> ${job.nume_dep}</p>
                            <p><strong>Poziție:</strong> ${job.denumire}</p>
                            <p><strong>Locație:</strong> ${job.locatie}</p>
                            <p><strong>Durată:</strong> 
                                <fmt:formatDate value="${job.start}" pattern="dd.MM.yyyy"/> - 
                                <fmt:formatDate value="${job.end}" pattern="dd.MM.yyyy"/>
                            </p>
                            <p><strong>Tip:</strong> ${job.tip == 1 ? 'Full-time' : 'Part-time'}</p>
                            <p><strong>Ore:</strong> ${job.ore}</p>
                        </div>
                        <a href="JobsServlet?action=detail&id=${job.id}" class="apply-button">Vezi detalii</a>
                    </div>
                </c:forEach>
            </div>
        </div>
  
    
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