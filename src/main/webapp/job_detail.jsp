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

                    // Pagina cu detalii job poate fi accesată de toți utilizatorii autentificați
                    // Toți pot vedea detaliile joburilor disponibile
                    
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
    <title>${job.titlu} - Detalii Job</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .job-detail {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .job-header {
            background: #f5f5f5;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .job-section {
            margin-bottom: 30px;
        }
        .apply-button {
            background-color: #4CAF50;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            display: inline-block;
        }
        .apply-button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-success {
            background-color: #dff0d8;
            color: #3c763d;
            border: 1px solid #d6e9c6;
        }
        .alert-error {
            background-color: #f2dede;
            color: #a94442;
            border: 1px solid #ebccd1;
        }
    </style>
</head>
<body class="bg">
    
        <div class="container">
            <div class="job-detail">
                <c:if test="${not empty success}">
                    <div class="alert alert-success">${success}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-error">${error}</div>
                </c:if>
                
                <div class="job-header">
                    <h1>${job.titlu}</h1>
                    <p><strong>Departament:</strong> ${job.nume_dep}</p>
                    <p><strong>Poziție:</strong> ${job.denumire}</p>
                    <p><strong>Locație:</strong> ${job.locatie}</p>
                </div>
                
                <div class="job-section">
                    <h2>Cerințe</h2>
                    <p>${job.req}</p>
                </div>
                
                <div class="job-section">
                    <h2>Responsabilități</h2>
                    <p>${job.resp}</p>
                </div>
                
                <div class="job-section">
                    <h2>Informații adiționale</h2>
                    <p><strong>Domeniu:</strong> ${job.dom}</p>
                    <p><strong>Subdomeniu:</strong> ${job.subdom}</p>
                    <p><strong>Durată:</strong> 
                        <fmt:formatDate value="${job.start}" pattern="dd.MM.yyyy"/> - 
                        <fmt:formatDate value="${job.end}" pattern="dd.MM.yyyy"/>
                    </p>
                    <p><strong>Tip:</strong> ${job.tip == 1 ? 'Full-time' : 'Part-time'}</p>
                    <p><strong>Ore:</strong> ${job.ore}</p>
                    <p><strong>Keywords:</strong> ${job.keywords}</p>
                </div>
                
                <div class="job-section">
                    <c:choose>
                        <c:when test="${alreadyApplied}">
                            <button class="apply-button" disabled>Ați aplicat deja</button>
                        </c:when>
                        <c:otherwise>
                            <form action="JobsServlet" method="post">
                                <input type="hidden" name="action" value="apply" />
                                <input type="hidden" name="job_id" value="${job.id}" />
                                <button type="submit" class="apply-button">Aplică acum</button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
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