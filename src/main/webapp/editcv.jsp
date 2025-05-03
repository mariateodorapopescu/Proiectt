<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser, bean.CVUserDetails" %>
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

                    // Verificare dacă utilizatorul poate edita CV-ul
                    // Fiecare utilizator poate edita doar propriul CV
                    // HR poate edita CV-urile angajaților din departamentul HR
                    // Directorii pot edita CV-urile din departamentele lor
                    Object userToEdit = request.getAttribute("user");
                    if (userToEdit != null && userToEdit instanceof bean.CVUserDetails) {
                        bean.CVUserDetails cvUser = (bean.CVUserDetails) userToEdit;
                        int editUserId = cvUser.getId();
                        int editUserDep = cvUser.getIdDep();
                        
                        // Permite editarea doar pentru:
                        // 1. Propriul CV
                        // 2. HR poate edita CV-urile din departamentul HR
                        // 3. Directorii pot edita CV-urile din departamentele lor
                        boolean canEdit = (userId == editUserId) || 
                                         (isHR && editUserDep == 1) || 
                                         (isDirector && editUserDep == userDep);
                        
                        if (!canEdit) {
                            response.sendRedirect("Access.jsp?error=accessDenied");
                            return;
                        }
                    } else {
                        // Dacă nu găsim date despre utilizatorul care trebuie editat, redirecting to CVServlet
                        response.sendRedirect("CVServlet?action=edit");
                        return;
                    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editare CV</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .edit-container {
            max-width: 900px;
            margin: 20px auto;
            padding: 20px;
        }
        .form-section {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        .add-button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 10px;
        }
        .delete-button {
            background-color: #f44336;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 600px;
            border-radius: 8px;
        }
        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
    
        <div class="edit-container">
            <h1>Editare CV - ${user.nume} ${user.prenume}</h1>
            
            <!-- Informații generale -->
            <div class="form-section">
                <h2>Informații Generale</h2>
                <form action="CVServlet" method="post">
                    <input type="hidden" name="action" value="save" />
                    
                    <div class="form-group">
                        <label for="calitati">Calități personale:</label>
                        <textarea id="calitati" name="calitati">${cv.calitati}</textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="interese">Interese:</label>
                        <textarea id="interese" name="interese">${cv.interese}</textarea>
                    </div>
                    
                    <button type="submit" class="add-button">Salvează</button>
                </form>
            </div>
            
            <!-- Experiență -->
            <div class="form-section">
                <h2>Experiență Profesională</h2>
                <c:forEach var="exp" items="${experience}">
                    <div class="experience-item" style="margin-bottom: 20px; padding: 10px; background: #f9f9f9;">
                        <h3>${exp.den_job} la ${exp.instit}</h3>
                        <p>${exp.start} - ${exp.end}</p>
                        <button onclick="deleteExperience(${exp.id})" class="delete-button">Șterge</button>
                    </div>
                </c:forEach>
                <button onclick="showExperienceModal()" class="add-button">Adaugă Experiență</button>
            </div>
            
            <!-- Educație -->
            <div class="form-section">
                <h2>Educație</h2>
                <c:forEach var="edu" items="${education}">
                    <div class="education-item" style="margin-bottom: 20px; padding: 10px; background: #f9f9f9;">
                        <h3>${edu.facultate}</h3>
                        <p>${edu.universitate}</p>
                        <p>${edu.start} - ${edu.end}</p>
                        <button onclick="deleteEducation(${edu.id})" class="delete-button">Șterge</button>
                    </div>
                </c:forEach>
                <button onclick="showEducationModal()" class="add-button">Adaugă Educație</button>
            </div>
            
            <!-- Limbi străine -->
            <div class="form-section">
                <h2>Limbi Străine</h2>
                <c:forEach var="lang" items="${languages}">
                    <div class="language-item" style="margin-bottom: 20px; padding: 10px; background: #f9f9f9;">
                        <h3>${lang.limba} - ${lang.nivel_denumire}</h3>
                        <button onclick="deleteLanguage(${lang.id})" class="delete-button">Șterge</button>
                    </div>
                </c:forEach>
                <button onclick="showLanguageModal()" class="add-button">Adaugă Limbă</button>
            </div>
            
            <!-- Proiecte -->
            <div class="form-section">
                <h2>Proiecte</h2>
                <c:forEach var="project" items="${projects}">
                    <div class="project-item" style="margin-bottom: 20px; padding: 10px; background: #f9f9f9;">
                        <h3>${project.nume}</h3>
                        <p>${project.descriere}</p>
                        <p>${project.start} - ${project.end}</p>
                        <button onclick="deleteProject(${project.id})" class="delete-button">Șterge</button>
                    </div>
                </c:forEach>
                <button onclick="showProjectModal()" class="add-button">Adaugă Proiect</button>
            </div>
        </div>
  
    
    <!-- Modal pentru Experiență -->
    <div id="experienceModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('experienceModal')">&times;</span>
            <h2>Adaugă Experiență</h2>
            <form action="CVServlet" method="post">
                <input type="hidden" name="action" value="addExperience" />
                
                <div class="form-group">
                    <label for="den_job">Titlu job:</label>
                    <input type="text" id="den_job" name="den_job" required />
                </div>
                
                <div class="form-group">
                    <label for="instit">Companie:</label>
                    <input type="text" id="instit" name="instit" required />
                </div>
                
                <div class="form-group">
                    <label for="tip">Poziție:</label>
                    <select id="tip" name="tip" required>
                        <c:forEach var="tip" items="${tipuri}">
                            <option value="${tip.tip}">${tip.denumire}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="id_dep">Departament:</label>
                    <select id="id_dep" name="id_dep" required>
                        <c:forEach var="dep" items="${departamente}">
                            <option value="${dep.id_dep}">${dep.nume_dep}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="domeniu">Domeniu:</label>
                    <input type="text" id="domeniu" name="domeniu" required />
                </div>
                
                <div class="form-group">
                    <label for="subdomeniu">Subdomeniu:</label>
                    <input type="text" id="subdomeniu" name="subdomeniu" />
                </div>
                
                <div class="form-group">
                    <label for="start">Data început:</label>
                    <input type="date" id="start" name="start" required />
                </div>
                
                <div class="form-group">
                    <label for="end">Data sfârșit:</label>
                    <input type="date" id="end" name="end" />
                </div>
                
                <div class="form-group">
                    <label for="descriere">Descriere:</label>
                    <textarea id="descriere" name="descriere"></textarea>
                </div>
                
                <button type="submit" class="add-button">Salvează</button>
            </form>
        </div>
    </div>
    
    <!-- Modal pentru Educație -->
    <div id="educationModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('educationModal')">&times;</span>
            <h2>Adaugă Educație</h2>
            <form action="CVServlet" method="post">
                <input type="hidden" name="action" value="addEducation" />
                
                <div class="form-group">
                    <label for="facultate">Facultate:</label>
                    <input type="text" id="facultate" name="facultate" required />
                </div>
                
                <div class="form-group">
                    <label for="universitate">Universitate:</label>
                    <input type="text" id="universitate" name="universitate" required />
                </div>
                
                <div class="form-group">
                    <label for="ciclu">Ciclu:</label>
                    <select id="ciclu" name="ciclu" required>
                        <c:forEach var="ciclu" items="${cicluri}">
                            <option value="${ciclu.id}">${ciclu.semnificatie}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="edu_start">Data început:</label>
                    <input type="date" id="edu_start" name="start" required />
                </div>
                
                <div class="form-group">
                    <label for="edu_end">Data sfârșit:</label>
                    <input type="date" id="edu_end" name="end" />
                </div>
                
                <button type="submit" class="add-button">Salvează</button>
            </form>
        </div>
    </div>
    
    <!-- Modal pentru Limbi -->
    <div id="languageModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('languageModal')">&times;</span>
            <h2>Adaugă Limbă Străină</h2>
            <form action="CVServlet" method="post">
                <input type="hidden" name="action" value="addLanguage" />
                
                <div class="form-group">
                    <label for="id_limba">Limba:</label>
                    <select id="id_limba" name="id_limba" required>
                        <c:forEach var="limba" items="${limbi}">
                            <option value="${limba.id}">${limba.limba}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="nivel">Nivel:</label>
                    <select id="nivel" name="nivel" required>
                        <c:forEach var="nivel" items="${niveluri}">
                            <option value="${nivel.id}">${nivel.semnificatie}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <button type="submit" class="add-button">Salvează</button>
            </form>
        </div>
    </div>
    
    <!-- Modal pentru Proiecte -->
    <div id="projectModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('projectModal')">&times;</span>
            <h2>Adaugă Proiect</h2>
            <form action="CVServlet" method="post">
                <input type="hidden" name="action" value="addProject" />
                
                <div class="form-group">
                    <label for="nume">Nume proiect:</label>
                    <input type="text" id="nume" name="nume" required />
                </div>
                
                <div class="form-group">
                    <label for="proj_descriere">Descriere:</label>
                    <textarea id="proj_descriere" name="descriere"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="proj_start">Data început:</label>
                    <input type="date" id="proj_start" name="start" required />
                </div>
                
                <div class="form-group">
                    <label for="proj_end">Data sfârșit:</label>
                    <input type="date" id="proj_end" name="end" />
                </div>
                
                <button type="submit" class="add-button">Salvează</button>
            </form>
        </div>
    </div>
    
    <script>
    function showModal(modalId) {
        document.getElementById(modalId).style.display = "block";
    }
    
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = "none";
    }
    
    function showExperienceModal() {
        showModal('experienceModal');
    }
    
    function showEducationModal() {
        showModal('educationModal');
    }
    
    function showLanguageModal() {
        showModal('languageModal');
    }
    
    function showProjectModal() {
        showModal('projectModal');
    }
    
    // Adaugă funcții pentru ștergere
    function deleteExperience(id) {
        if (confirm('Sigur doriți să ștergeți această experiență?')) {
            window.location.href = 'CVServlet?action=deleteExperience&id=' + id;
        }
    }
    
    function deleteEducation(id) {
        if (confirm('Sigur doriți să ștergeți această educație?')) {
            window.location.href = 'CVServlet?action=deleteEducation&id=' + id;
        }
    }
    
    function deleteLanguage(id) {
        if (confirm('Sigur doriți să ștergeți această limbă?')) {
            window.location.href = 'CVServlet?action=deleteLanguage&id=' + id;
        }
    }
    
    function deleteProject(id) {
        if (confirm('Sigur doriți să ștergeți acest proiect?')) {
            window.location.href = 'CVServlet?action=deleteProject&id=' + id;
        }
    }
    
    // Închide modalul când se dă click în afara lui
    window.onclick = function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = "none";
        }
    }
    </script>
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