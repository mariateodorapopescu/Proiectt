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

                    // Pagina cu aplicările personale poate fi accesată de toți utilizatorii autentificați
                    // Fiecare utilizator vede doar propriile aplicări
                    
                    // Setăm utilizatorul curent ca atribut pentru JSTL
                    request.setAttribute("currentUserId", userId);
                    request.setAttribute("isHR", isHR);
                    request.setAttribute("isDirector", isDirector);
                    request.setAttribute("isAdmin", isAdmin);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Aplicările Mele</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .applications-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .applications-table th, .applications-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        .applications-table th {
            background-color: #f5f5f5;
        }
        .status-badge {
            padding: 5px 10px;
            border-radius: 15px;
            color: white;
            font-size: 0.9em;
        }
        .status-pending { background-color: #ffc107; }
        .status-reviewed { background-color: #17a2b8; }
        .status-interview { background-color: #28a745; }
        .status-rejected { background-color: #dc3545; }
    </style>
</head>
<body class="bg">
    
        <div class="container">
            <h1>Aplicările Mele</h1>
            
            <table class="applications-table">
                <thead>
                    <tr>
                        <th>Job</th>
                        <th>Departament</th>
                        <th>Poziție</th>
                        <th>Data aplicării</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="app" items="${applications}">
                        <tr>
                            <td>${app.titlu}</td>
                            <td>${app.nume_dep}</td>
                            <td>${app.denumire}</td>
                            <td><fmt:formatDate value="${app.data_apl}" pattern="dd.MM.yyyy"/></td>
                            <td>
                                <span class="status-badge status-pending">În așteptare</span>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
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