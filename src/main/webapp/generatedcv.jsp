<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
                            response.sendRedirect("homedir.jsp");
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
    <style>
        @page {
            size: A4;
            margin: 2cm;
        }
        
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
        }
        
        .cv-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: white;
        }
        
        .cv-header {
            text-align: center;
            border-bottom: 3px solid #2c3e50;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        .cv-header h1 {
            color: #2c3e50;
            margin: 0;
            font-size: 32px;
        }
        
        .contact-info {
            margin-top: 10px;
            font-size: 14px;
        }
        
        .contact-info span {
            margin: 0 10px;
        }
        
        .section {
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 5px;
            margin-bottom: 15px;
            font-size: 22px;
        }
        
        .entry {
            margin-bottom: 20px;
        }
        
        .entry-header {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
        }
        
        .entry-title {
            font-weight: bold;
            font-size: 18px;
            color: #2c3e50;
        }
        
        .entry-date {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .entry-subtitle {
            color: #34495e;
            font-style: italic;
            margin: 5px 0;
        }
        
        .entry-description {
            margin-top: 5px;
        }
        
        .skills-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        
        .skill-item {
            display: flex;
            align-items: center;
        }
        
        .skill-name {
            width: 120px;
        }
        
        .skill-level {
            flex: 1;
            height: 10px;
            background: #ecf0f1;
            border-radius: 5px;
            overflow: hidden;
        }
        
        .skill-level-fill {
            height: 100%;
            background: #3498db;
        }
        
        .language-level {
            display: inline-block;
            padding: 3px 10px;
            background: #3498db;
            color: white;
            border-radius: 15px;
            font-size: 12px;
        }
        
        @media print {
            .no-print {
                display: none !important;
            }
            
            .cv-container {
                padding: 0;
            }
            
            .section {
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>
    <div class="cv-container">
        <!-- Header cu date personale -->
        <div class="cv-header">
            <h1>${user.nume} ${user.prenume}</h1>
            <div class="contact-info">
                <span>📅 <fmt:formatDate value="${user.data_nasterii}" pattern="dd.MM.yyyy"/></span>
                <span>📧 ${user.email}</span>
                <span>📱 ${user.telefon}</span>
                <span>📍 ${user.adresa}</span>
            </div>
        </div>
        
        <!-- Profil (dacă există calități sau interese) -->
        <c:if test="${cv != null}">
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
        </c:if>
        
        <!-- Experiență Profesională -->
        <div class="section">
            <h2 class="section-title">Experiență Profesională</h2>
            <c:forEach var="exp" items="${experience}">
                <div class="entry">
                    <div class="entry-header">
                        <div class="entry-title">${exp.den_job}</div>
                        <div class="entry-date">
                            <fmt:formatDate value="${exp.start}" pattern="MM/yyyy"/> - 
                            <c:choose>
                                <c:when test="${not empty exp.end}">
                                    <fmt:formatDate value="${exp.end}" pattern="MM/yyyy"/>
                                </c:when>
                                <c:otherwise>Prezent</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="entry-subtitle">${exp.instit}</div>
                    <div class="entry-description">
                        <p><strong>Domeniu:</strong> ${exp.domeniu}<c:if test="${not empty exp.subdomeniu}"> - ${exp.subdomeniu}</c:if></p>
                        <c:if test="${not empty exp.descriere}">
                            <p>${exp.descriere}</p>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <!-- Educație -->
        <div class="section">
            <h2 class="section-title">Educație</h2>
            <c:forEach var="edu" items="${education}">
                <div class="entry">
                    <div class="entry-header">
                        <div class="entry-title">${edu.facultate}</div>
                        <div class="entry-date">
                            <fmt:formatDate value="${edu.start}" pattern="yyyy"/> - 
                            <c:choose>
                                <c:when test="${not empty edu.end}">
                                    <fmt:formatDate value="${edu.end}" pattern="yyyy"/>
                                </c:when>
                                <c:otherwise>Prezent</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="entry-subtitle">${edu.universitate}</div>
                    <div class="entry-description">
                        <p><strong>Nivel:</strong> ${edu.ciclu_denumire}</p>
                    </div>
                </div>
            </c:forEach>
        </div>
        
        <!-- Proiecte Personale -->
        <c:if test="${not empty projects}">
            <div class="section">
                <h2 class="section-title">Proiecte Personale</h2>
                <c:forEach var="project" items="${projects}">
                    <div class="entry">
                        <div class="entry-header">
                            <div class="entry-title">${project.nume}</div>
                            <div class="entry-date">
                                <fmt:formatDate value="${project.start}" pattern="MM/yyyy"/> - 
                                <c:choose>
                                    <c:when test="${not empty project.end}">
                                        <fmt:formatDate value="${project.end}" pattern="MM/yyyy"/>
                                    </c:when>
                                    <c:otherwise>Prezent</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="entry-description">
                            <p>${project.descriere}</p>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
        
        <!-- Limbi Străine -->
        <div class="section">
            <h2 class="section-title">Limbi Străine</h2>
            <div class="skills-grid">
                <c:forEach var="lang" items="${languages}">
                    <div class="skill-item">
                        <span class="skill-name">${lang.limba}</span>
                        <span class="language-level">${lang.nivel_denumire}</span>
                    </div>
                </c:forEach>
            </div>
        </div>
        
        <!-- Butoane pentru acțiuni -->
        <div class="no-print" style="text-align: center; margin-top: 30px;">
            <button onclick="window.print()" class="btn btn-primary" style="margin-right: 10px;">🖨️ Printează CV</button>
            <button onclick="downloadPDF()" class="btn btn-secondary">⬇️ Descarcă PDF</button>
        </div>
    </div>
    
    <script>
    function downloadPDF() {
        // Pentru a descărca ca PDF, folosim funcționalitatea de print
        window.print();
    }
    </script>
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
            response.sendRedirect("homedir.jsp");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("homedir.jsp");
    }
%>