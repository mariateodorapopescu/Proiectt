<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.fasterxml.jackson.databind.ObjectMapper" %>
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
                    boolean isDirector1 = (ierarhie < 3) ;
                    boolean isSef1 = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator1 = (ierarhie >= 10);
                    boolean isUtilizatorNormal1 = !isDirector1 && !isSef1 && !isIncepator1; // tipuri 1, 2, 5-9
                    boolean isAdmin1 = (functie.compareTo("Administrator") == 0);
                    boolean isHR1 = (userDep == 1); // Department HR

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
                                         isHR1 || 
                                         (isDirector1 && viewedUserDep == userDep) || 
                                         (isSef1 && viewedUserDep == userDep);
                        
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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vizualizare CV</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .cv-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        
        .cv-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #3498db;
        }
        
        .cv-header h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .cv-section {
            margin-bottom: 25px;
        }
        
        .cv-section h3 {
            color: #2c3e50;
            border-bottom: 1px solid #ecf0f1;
            padding-bottom: 10px;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        
        .experience-item, .education-item {
            margin-bottom: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #3498db;
            border-radius: 5px;
        }
        
        .experience-item h4, .education-item h4 {
            color: #2c3e50;
            margin: 0 0 10px 0;
        }
        
        .date-range {
            font-style: italic;
            color: #7f8c8d;
            font-size: 0.9em;
        }
        
        .languages-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .language-tag {
            background: #3498db;
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9em;
            display: inline-block;
        }
        
        .cv-actions {
            margin-top: 30px;
            text-align: center;
            border-top: 1px solid #ecf0f1;
            padding-top: 20px;
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 0 5px;
            border-radius: 5px;
            text-decoration: none;
            color: white;
            background: #3498db;
            transition: background 0.3s;
        }
        
        .btn:hover {
            background: #2980b9;
        }
        
        .btn-secondary {
            background: #95a5a6;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .info-item {
            background: #ecf0f1;
            padding: 10px;
            border-radius: 5px;
        }
        
        .info-label {
            font-weight: bold;
            color: #2c3e50;
        }
        
        @media (max-width: 768px) {
            .cv-container {
                margin: 10px;
                padding: 15px;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
    <div class="cv-container">
        <%
        try {
            // Obține datele din atributele setate de servlet
            ResultSet userRs = (ResultSet) request.getAttribute("user");
            ResultSet cvRs = (ResultSet) request.getAttribute("cv");
            ResultSet experienceRs = (ResultSet) request.getAttribute("experience");
            ResultSet educationRs = (ResultSet) request.getAttribute("education");
            ResultSet languagesRs = (ResultSet) request.getAttribute("languages");
            ResultSet projectsRs = (ResultSet) request.getAttribute("projects");
            
            Boolean isDirector = (Boolean) request.getAttribute("isDirector");
            Boolean isHR = (Boolean) request.getAttribute("isHR");
            Boolean isAdmin = (Boolean) request.getAttribute("isAdmin");
            Integer targetUserId = (Integer) request.getAttribute("targetUserId");
            Integer currentUserId = (Integer) request.getAttribute("currentUserId");
            
            if (userRs != null && userRs.next()) {
        %>
        
        <!-- Header cu informații personale -->
        <div class="cv-header">
            <h1>
                <%= userRs.getString("nume") != null ? userRs.getString("nume") : "" %> 
                <%= userRs.getString("prenume") != null ? userRs.getString("prenume") : "" %>
            </h1>
            
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Poziție:</span> 
                    <%= userRs.getString("denumire") != null ? userRs.getString("denumire") : "N/A" %>
                </div>
                <div class="info-item">
                    <span class="info-label">Departament:</span> 
                    <%= userRs.getString("nume_dep") != null ? userRs.getString("nume_dep") : "N/A" %>
                </div>
                <div class="info-item">
                    <span class="info-label">Email:</span> 
                    <%= userRs.getString("email") != null ? userRs.getString("email") : "N/A" %>
                </div>
                <div class="info-item">
                    <span class="info-label">Telefon:</span> 
                    <%= userRs.getString("telefon") != null ? userRs.getString("telefon") : "N/A" %>
                </div>
            </div>
        </div>
        
        <%
            }
            
            // Secțiunea CV (calități și interese)
            if (cvRs != null && cvRs.next()) {
        %>
        
        <div class="cv-section">
            <h3>📋 Calități Personale</h3>
            <p><%= cvRs.getString("calitati") != null ? cvRs.getString("calitati") : "Nu sunt specificate calități." %></p>
        </div>
        
        <div class="cv-section">
            <h3>🎯 Interese</h3>
            <p><%= cvRs.getString("interese") != null ? cvRs.getString("interese") : "Nu sunt specificate interese." %></p>
        </div>
        
        <%
            }
            
            // Secțiunea Experiență
        %>
        
        <div class="cv-section">
            <h3>💼 Experiență Profesională</h3>
            <%
                boolean hasExperience = false;
                if (experienceRs != null) {
                    while (experienceRs.next()) {
                        hasExperience = true;
            %>
            <div class="experience-item">
                <h4><%= experienceRs.getString("den_job") != null ? experienceRs.getString("den_job") : "Poziție nespecificată" %></h4>
                <p><strong>Instituție:</strong> <%= experienceRs.getString("instit") != null ? experienceRs.getString("instit") : "N/A" %></p>
                <p><strong>Domeniu:</strong> <%= experienceRs.getString("domeniu") != null ? experienceRs.getString("domeniu") : "N/A" %></p>
                <% if (experienceRs.getString("subdomeniu") != null) { %>
                <p><strong>Subdomeniu:</strong> <%= experienceRs.getString("subdomeniu") %></p>
                <% } %>
                <% if (experienceRs.getString("tip_denumire") != null) { %>
                <p><strong>Tip poziție:</strong> <%= experienceRs.getString("tip_denumire") %></p>
                <% } %>
                <% if (experienceRs.getString("nume_dep") != null) { %>
                <p><strong>Departament:</strong> <%= experienceRs.getString("nume_dep") %></p>
                <% } %>
                <p class="date-range">
                    <%= experienceRs.getDate("start") != null ? experienceRs.getDate("start") : "Data necunoscută" %> - 
                    <%= experienceRs.getDate("end") != null ? experienceRs.getDate("end") : "Prezent" %>
                </p>
                <% if (experienceRs.getString("descriere") != null && !experienceRs.getString("descriere").trim().isEmpty()) { %>
                <p><strong>Descriere:</strong> <%= experienceRs.getString("descriere") %></p>
                <% } %>
            </div>
            <%
                    }
                }
                if (!hasExperience) {
            %>
            <p>Nu este specificată experiență profesională.</p>
            <%
                }
            %>
        </div>
        
        <!-- Secțiunea Educație -->
        <div class="cv-section">
            <h3>🎓 Educație</h3>
            <%
                boolean hasEducation = false;
                if (educationRs != null) {
                    while (educationRs.next()) {
                        hasEducation = true;
            %>
            <div class="education-item">
                <h4><%= educationRs.getString("facultate") != null ? educationRs.getString("facultate") : "Facultate nespecificată" %></h4>
                <p><strong>Universitate:</strong> <%= educationRs.getString("universitate") != null ? educationRs.getString("universitate") : "N/A" %></p>
                <p><strong>Ciclu:</strong> <%= educationRs.getString("ciclu_denumire") != null ? educationRs.getString("ciclu_denumire") : "N/A" %></p>
                <p class="date-range">
                    <%= educationRs.getDate("start") != null ? educationRs.getDate("start") : "Data necunoscută" %> - 
                    <%= educationRs.getDate("end") != null ? educationRs.getDate("end") : "În curs" %>
                </p>
            </div>
            <%
                    }
                }
                if (!hasEducation) {
            %>
            <p>Nu este specificată educație.</p>
            <%
                }
            %>
        </div>
        
        <!-- Secțiunea Limbi Străine -->
        <div class="cv-section">
            <h3>🌍 Limbi Străine</h3>
            <div class="languages-container">
                <%
                    boolean hasLanguages = false;
                    if (languagesRs != null) {
                        while (languagesRs.next()) {
                            hasLanguages = true;
                %>
                <span class="language-tag">
                    <%= languagesRs.getString("limba") %> - <%= languagesRs.getString("nivel_denumire") %>
                </span>
                <%
                        }
                    }
                    if (!hasLanguages) {
                %>
                <p>Nu sunt specificate limbi străine.</p>
                <%
                    }
                %>
            </div>
        </div>
        
        <!-- Secțiunea Proiecte (dacă există) -->
        <%
            if (projectsRs != null) {
        %>
        <div class="cv-section">
            <h3>🚀 Proiecte</h3>
            <%
                boolean hasProjects = false;
                while (projectsRs.next()) {
                    hasProjects = true;
            %>
            <div class="experience-item">
                <h4><%= projectsRs.getString("nume") != null ? projectsRs.getString("nume") : "Proiect nespecificat" %></h4>
                <p><%= projectsRs.getString("descriere") != null ? projectsRs.getString("descriere") : "Fără descriere" %></p>
                <p class="date-range">
                    <%= projectsRs.getDate("start") != null ? projectsRs.getDate("start") : "Data necunoscută" %> - 
                    <%= projectsRs.getDate("end") != null ? projectsRs.getDate("end") : "În curs" %>
                </p>
            </div>
            <%
                }
                if (!hasProjects) {
            %>
            <p>Nu sunt specificate proiecte.</p>
            <%
                }
            %>
        </div>
        <%
            }
        %>
        
        <!-- Butoane de acțiune -->
        <div class="cv-actions">
            <%
                // Afișează butoanele doar dacă utilizatorul își vizualizează propriul CV
                if (currentUserId != null && targetUserId != null && currentUserId.equals(targetUserId)) {
            %>
            <a href="CVServlet?action=edit" class="btn">✏️ Editează CV</a>
            <%
                }
                
                // Butonul de export pentru toți utilizatorii autorizați
                if (isDirector != null && isDirector || isHR != null && isHR || 
                    (currentUserId != null && targetUserId != null && currentUserId.equals(targetUserId))) {
            %>
            <a href="CVGeneratorServlet?action=export&id=<%= targetUserId %>" class="btn">📥 Exportă PDF</a>
            <%
                }
            %>
            <a href="cvmanagement.jsp" class="btn btn-secondary">🏠 Management CV</a>
            <a href="homedir.jsp" class="btn btn-secondary">🔙 Înapoi</a>
        </div>
        
        <%
        } catch (Exception e) {
            out.println("<div style='color: red; text-align: center; padding: 20px;'>");
            out.println("<h3>Eroare la încărcarea CV-ului</h3>");
            out.println("<p>A apărut o eroare: " + e.getMessage() + "</p>");
            out.println("<a href='cvmanagement.jsp' class='btn'>Înapoi la Management CV</a>");
            out.println("</div>");
            e.printStackTrace();
        }
        %>
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