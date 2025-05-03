<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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

                    // Verificare acces - această pagină poate fi accesată de toți utilizatorii autentificați
                    // dar modul de afișare variază în funcție de rol
                    pageContext.setAttribute("isHR", isHR);
                    pageContext.setAttribute("isDirector", isDirector);
                    pageContext.setAttribute("isAdmin", isAdmin);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestionare Aplicări</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .applications-container {
            max-width: 1000px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .applications-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .applications-table th,
        .applications-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .applications-table th {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            margin-right: 5px;
        }
        
        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }
        
        .btn-warning {
            background-color: #f39c12;
            color: white;
        }
        
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-pending {
            background-color: #ffeeba;
            color: #856404;
        }
        
        .status-interview {
            background-color: #d4edda;
            color: #155724;
        }
        
        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .alert {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body class="bg" >
   
        <div class="applications-container">
            <h1>${isHR ? 'Gestionare Aplicări (HR)' : 'Aplicările Mele'}</h1>
            
            <c:if test="${param.success == 'withdrawn'}">
                <div class="alert alert-success">Aplicarea a fost retrasă cu succes!</div>
            </c:if>
            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-success">Aplicarea a fost ștearsă cu succes!</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-error">
                    <c:choose>
                        <c:when test="${param.error == 'unauthorized'}">Nu aveți permisiunea necesară!</c:when>
                        <c:when test="${param.error == 'delete_failed'}">Ștergerea a eșuat!</c:when>
                        <c:when test="${param.error == 'withdraw_failed'}">Retragerea a eșuat!</c:when>
                        <c:otherwise>A apărut o eroare!</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            
            <table class="applications-table">
                <thead>
                    <tr>
                        <c:if test="${isHR}">
                            <th>Candidat</th>
                            <th>Email</th>
                        </c:if>
                        <th>Poziție</th>
                        <th>Departament</th>
                        <th>Data Aplicării</th>
                        <th>Status</th>
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="app" items="${applications}">
                        <tr>
                            <c:if test="${isHR}">
                                <td>${app.nume} ${app.prenume}</td>
                                <td>${app.email}</td>
                            </c:if>
                            <td>${app.titlu}</td>
                            <td>${app.nume_dep}</td>
                            <td><fmt:formatDate value="${app.data_apl}" pattern="dd.MM.yyyy"/></td>
                            <td>
                                <span class="status-badge status-${app.status == null ? 'pending' : app.status.toLowerCase()}">
                                    ${app.status == null ? 'În așteptare' : app.status}
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${isHR || isDirector || isAdmin}">
                                        <a href="ApplicationManagementServlet?action=delete&id=${app.id}" 
                                           class="btn btn-danger" 
                                           onclick="return confirm('Sigur doriți să ștergeți această aplicare?')">
                                           Șterge
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${app.status == null || app.status == 'PENDING'}">
                                            <a href="ApplicationManagementServlet?action=withdraw&id=${app.id}" 
                                               class="btn btn-warning" 
                                               onclick="return confirm('Sigur doriți să retrageți această aplicare?')">
                                               Retrage
                                            </a>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
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