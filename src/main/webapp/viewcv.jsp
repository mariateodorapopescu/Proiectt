<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.fasterxml.jackson.databind.ObjectMapper" %>
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

                    // Verificare dacă utilizatorul poate vizualiza CV-ul
                    // Fiecare utilizator poate vizualiza propriul CV
                    // HR poate vizualiza CV-urile tuturor angajaților
                    // Directorii pot vizualiza CV-urile din departamentele lor
                    Object userViewed = request.getAttribute("user");
                    if (userViewed != null && userViewed instanceof bean.CVUserDetails) {
                        bean.CVUserDetails cvUser = (bean.CVUserDetails) userViewed;
                        int viewedUserId = cvUser.getId();
                        int viewedUserDep = cvUser.getIdDep();
                        
                        // Permite vizualizarea pentru:
                        // 1. Propriul CV
                        // 2. HR poate vizualiza toate CV-urile
                        // 3. Directorii pot vizualiza CV-urile din departamentele lor
                        // 4. Șefii pot vizualiza CV-urile din departamentele lor
                        boolean canView = (userId == viewedUserId) || 
                                         isHR || 
                                         (isDirector && viewedUserDep == userDep) || 
                                         (isSef && viewedUserDep == userDep);
                        
                        if (!canView) {
                            response.sendRedirect("Access.jsp?error=accessDenied");
                            return;
                        }
                    } else {
                        // Dacă nu găsim date despre utilizatorul care trebuie vizualizat, redirecționăm către CVServlet
                        response.sendRedirect("CVServlet");
                        return;
                    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CV - ${user.nume} ${user.prenume}</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .cv-container {
            max-width: 900px;
            margin: 20px auto;
            background: white;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .cv-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #eee;
        }
        .cv-photo {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
        }
        .personal-info {
            flex: 1;
            margin-left: 30px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section-title {
            font-size: 20px;
            color: #333;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .timeline-item {
            position: relative;
            padding-left: 30px;
            margin-bottom: 20px;
        }
        .timeline-item:before {
            content: '';
            position: absolute;
            left: 0;
            top: 5px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: #4CAF50;
        }
        .timeline-item:after {
            content: '';
            position: absolute;
            left: 4px;
            top: 15px;
            width: 2px;
            height: calc(100% - 10px);
            background: #ddd;
        }
        .timeline-item:last-child:after {
            display: none;
        }
        .date-range {
            color: #666;
            font-size: 14px;
            margin-bottom: 5px;
        }
        .skills-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }
        .skill-item {
            background: #f5f5f5;
            padding: 10px;
            border-radius: 5px;
        }
        .language-level {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            background: #e3f2fd;
            color: #1976d2;
            font-size: 12px;
        }
        @media print {
            .no-print {
                display: none !important;
            }
            .cv-container {
                box-shadow: none;
                padding: 0;
            }
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
   
        <div class="cv-container">
            <div class="cv-header">
                <c:if test="${not empty user.profil}">
                    <img src="data:image/jpeg;base64,${user.profil}" class="cv-photo" alt="Profile photo">
                </c:if>
                <div class="personal-info">
                    <h1>${user.nume} ${user.prenume}</h1>
                    <p>${user.denumire} - ${user.nume_dep}</p>
                    <p>Email: ${user.email}</p>
                    <p>Telefon: ${user.telefon}</p>
                    <p>Adresa: ${user.adresa}</p>
                </div>
            </div>
            
            <c:if test="${not empty cv.calitati || not empty cv.interese}">
                <div class="section">
                    <h2 class="section-title">Profil</h2>
                    <c:if test="${not empty cv.calitati}">
                        <p><strong>Calități:</strong> ${cv.calitati}</p>
                    </c:if>
                    <c:if test="${not empty cv.interese}">
                        <p><strong>Interese:</strong> ${cv.interese}</p>
                    </c:if>
                </div>
            </c:if>
            
            <div class="section">
                <h2 class="section-title">Experiență Profesională</h2>
                <c:forEach var="exp" items="${experience}">
                    <div class="timeline-item">
                        <div class="date-range">
                            <fmt:formatDate value="${exp.start}" pattern="MM/yyyy"/> - 
                            <c:choose>
                                <c:when test="${not empty exp.end}">
                                    <fmt:formatDate value="${exp.end}" pattern="MM/yyyy"/>
                                </c:when>
                                <c:otherwise>Present</c:otherwise>
                            </c:choose>
                        </div>
                        <h3>${exp.den_job}</h3>
                        <p><strong>${exp.instit}</strong></p>
                        <p>${exp.domeniu} - ${exp.subdomeniu}</p>
                        <p>${exp.descriere}</p>
                    </div>
                </c:forEach>
            </div>
            
            <div class="section">
                <h2 class="section-title">Educație</h2>
                <c:forEach var="edu" items="${education}">
                    <div class="timeline-item">
                        <div class="date-range">
                            <fmt:formatDate value="${edu.start}" pattern="yyyy"/> - 
                            <c:choose>
                                <c:when test="${not empty edu.end}">
                                    <fmt:formatDate value="${edu.end}" pattern="yyyy"/>
                                </c:when>
                                <c:otherwise>Present</c:otherwise>
                            </c:choose>
                        </div>
                        <h3>${edu.facultate}</h3>
                        <p>${edu.universitate}</p>
                        <p>${edu.ciclu_denumire}</p>
                    </div>
                </c:forEach>
            </div>
            
            <div class="section">
                <h2 class="section-title">Limbi Străine</h2>
                <div class="skills-grid">
                    <c:forEach var="lang" items="${languages}">
                        <div class="skill-item">
                            <strong>${lang.limba}</strong>
                            <span class="language-level">${lang.nivel_denumire}</span>
                        </div>
                    </c:forEach>
                </div>
            </div>
            
            <div class="section">
                <h2 class="section-title">Proiecte</h2>
                <c:forEach var="project" items="${projects}">
                    <div class="timeline-item">
                        <div class="date-range">
                            <fmt:formatDate value="${project.start}" pattern="MM/yyyy"/> - 
                            <c:choose>
                                <c:when test="${not empty project.end}">
                                    <fmt:formatDate value="${project.end}" pattern="MM/yyyy"/>
                                </c:when>
                                <c:otherwise>Present</c:otherwise>
                            </c:choose>
                        </div>
                        <h3>${project.nume}</h3>
                        <p>${project.descriere}</p>
                    </div>
                </c:forEach>
            </div>
            
            <div class="no-print" style="text-align: center; margin-top: 30px;">
                <c:if test="${currentUser.id == user.id}">
                    <a href="CVServlet?action=edit" class="btn btn-primary">Editează CV</a>
                </c:if>
                <button onclick="window.print()" class="btn btn-secondary">Printează CV</button>
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