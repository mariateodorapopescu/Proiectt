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

                    // Verificare dacă utilizatorul poate gestiona CV-ul
                    // Fiecare utilizator poate gestiona doar propriul CV
                    // HR poate gestiona CV-urile angajaților din departamentul HR
                    // Directorii pot gestiona CV-urile din departamentele lor
                    Object userToManage = request.getAttribute("user");
                    if (userToManage != null && userToManage instanceof bean.CVUserDetails) {
                        bean.CVUserDetails cvUser = (bean.CVUserDetails) userToManage;
                        int manageUserId = cvUser.getId();
                        int manageUserDep = cvUser.getIdDep();
                        
                        // Permite managementul doar pentru:
                        // 1. Propriul CV
                        // 2. HR poate gestiona CV-urile din departamentul HR
                        // 3. Directorii pot gestiona CV-urile din departamentele lor
                        boolean canManage = (userId == manageUserId) || 
                                           (isHR && manageUserDep == 1) || 
                                           (isDirector && manageUserDep == userDep);
                        
                        if (!canManage) {
                            response.sendRedirect("Access.jsp?error=accessDenied");
                            return;
                        }
                    } else {
                        // Dacă nu găsim date despre utilizatorul care trebuie gestionat, redirecționăm către CVManagementServlet
                        response.sendRedirect("CVManagementServlet");
                        return;
                    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestionare CV</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .cv-container {
            max-width: 900px;
            margin: 20px auto;
            padding: 20px;
        }
        
        .section {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            border-bottom: 2px solid #eee;
            padding-bottom: 10px;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
        }
        
        .btn-primary {
            background-color: #3498db;
            color: white;
        }
        
        .btn-success {
            background-color: #2ecc71;
            color: white;
        }
        
        .btn-danger {
            background-color: #e74c3c;
            color: white;
        }
        
        .btn-warning {
            background-color: #f39c12;
            color: white;
        }
        
        .item-card {
            border: 1px solid #eee;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 5px;
            position: relative;
        }
        
        .item-actions {
            position: absolute;
            top: 10px;
            right: 10px;
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
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
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
<body class="bg">
   
        <div class="cv-container">
            <h1>Gestionare CV - ${user.nume} ${user.prenume}</h1>
            
            <c:if test="${param.success}">
                <div class="alert alert-success">Operațiunea a fost efectuată cu succes!</div>
            </c:if>
            <c:if test="${param.error}">
                <div class="alert alert-error">A apărut o eroare!</div>
            </c:if>
            
            <!-- Informații generale CV -->
            <div class="section">
                <div class="section-header">
                    <h2>Informații Generale</h2>
                    <button class="btn btn-primary" onclick="showModal('generalModal')">Editează</button>
                </div>
                <form id="generalForm" action="CVManagementServlet" method="post">
                    <input type="hidden" name="action" value="save">
                    <div class="form-group">
                        <label for="calitati">Calități:</label>
                        <textarea id="calitati" name="calitati" rows="3">${cv.calitati}</textarea>
                    </div>
                    <div class="form-group">
                        <label for="interese">Interese:</label>
                        <textarea id="interese" name="interese" rows="3">${cv.interese}</textarea>
                    </div>
                    <button type="submit" class="btn btn-success">Salvează</button>
                </form>
            </div>
            
            <!-- Experiență -->
            <div class="section">
                <div class="section-header">
                    <h2>Experiență Profesională</h2>
                    <button class="btn btn-primary" onclick="showModal('experienceModal')">Adaugă Experiență</button>
                </div>
                <c:forEach var="exp" items="${experience}">
                    <div class="item-card">
                        <div class="item-actions">
                            <button class="btn btn-warning" onclick="editExperience(${exp.id})">Editează</button>
                            <a href="CVManagementServlet?action=deleteExperience&id=${exp.id}" 
                               class="btn btn-danger" 
                               onclick="return confirm('Sigur doriți să ștergeți această experiență?')">Șterge</a>
                        </div>
                        <h3>${exp.den_job}</h3>
                        <p><strong>${exp.instit}</strong></p>
                        <p>${exp.start} - ${exp.end == null ? 'Present' : exp.end}</p>
                        <p>${exp.descriere}</p>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Educație -->
            <div class="section">
                <div class="section-header">
                    <h2>Educație</h2>
                    <button class="btn btn-primary" onclick="showModal('educationModal')">Adaugă Educație</button>
                </div>
                <c:forEach var="edu" items="${education}">
                    <div class="item-card">
                        <div class="item-actions">
                            <button class="btn btn-warning" onclick="editEducation(${edu.id})">Editează</button>
                            <a href="CVManagementServlet?action=deleteEducation&id=${edu.id}" 
                               class="btn btn-danger" 
                               onclick="return confirm('Sigur doriți să ștergeți această educație?')">Șterge</a>
                        </div>
                        <h3>${edu.facultate}</h3>
                        <p>${edu.universitate}</p>
                        <p>${edu.ciclu_denumire}</p>
                        <p>${edu.start} - ${edu.end == null ? 'Present' : edu.end}</p>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Limbi străine -->
            <div class="section">
                <div class="section-header">
                    <h2>Limbi Străine</h2>
                    <button class="btn btn-primary" onclick="showModal('languageModal')">Adaugă Limbă</button>
                </div>
                <c:forEach var="lang" items="${languages}">
                    <div class="item-card">
                        <div class="item-actions">
                            <button class="btn btn-warning" onclick="editLanguage(${lang.id})">Editează</button>
                            <a href="CVManagementServlet?action=deleteLanguage&id=${lang.id}" 
                               class="btn btn-danger" 
                               onclick="return confirm('Sigur doriți să ștergeți această limbă?')">Șterge</a>
                        </div>
                        <h3>${lang.limba}</h3>
                        <p>Nivel: ${lang.nivel_denumire}</p>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Proiecte -->
            <div class="section">
                <div class="section-header">
                    <h2>Proiecte</h2>
                    <button class="btn btn-primary" onclick="showModal('projectModal')">Adaugă Proiect</button>
                </div>
                <c:forEach var="project" items="${projects}">
                    <div class="item-card">
                        <div class="item-actions">
                            <button class="btn btn-warning" onclick="editProject(${project.id})">Editează</button>
                            <a href="CVManagementServlet?action=deleteProject&id=${project.id}" 
                               class="btn btn-danger" 
                               onclick="return confirm('Sigur doriți să ștergeți acest proiect?')">Șterge</a>
                        </div>
                        <h3>${project.nume}</h3>
                        <p>${project.descriere}</p>
                        <p>${project.start} - ${project.end == null ? 'Present' : project.end}</p>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Butoane acțiuni globale -->
            <div style="text-align: center; margin-top: 30px;">
                <a href="CVGeneratorServlet?action=generate" class="btn btn-primary">Vizualizează CV</a>
                <a href="CVManagementServlet?action=delete" 
                   class="btn btn-danger" 
                   onclick="return confirm('Sigur doriți să ștergeți întregul CV? Toate datele vor fi pierdute!')">
                   Șterge CV
                </a>
            </div>
        </div>
   
    <!-- Modal Experiență -->
    <div id="experienceModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('experienceModal')">&times;</span>
            <h2>Adaugă/Editează Experiență</h2>
            <form id="experienceForm" action="CVManagementServlet" method="post">
                <input type="hidden" name="action" value="addExperience">
                <input type="hidden" name="id" id="experience_id">
                
                <div class="form-group">
                    <label for="den_job">Titlu Job:</label>
                    <input type="text" id="den_job" name="den_job" required>
                </div>
                
                <div class="form-group">
                    <label for="instit">Companie:</label>
                    <input type="text" id="instit" name="instit" required>
                </div>
                
                <div class="form-group">
                    <label for="tip">Tip Poziție:</label>
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
                    <input type="text" id="domeniu" name="domeniu" required>
                </div>
                
                <div class="form-group">
                    <label for="subdomeniu">Subdomeniu:</label>
                    <input type="text" id="subdomeniu" name="subdomeniu">
                </div>
                
                <div class="form-group">
                    <label for="start">Data Început:</label>
                    <input type="date" id="start" name="start" required>
                </div>
                
                <div class="form-group">
                    <label for="end">Data Sfârșit:</label>
                    <input type="date" id="end" name="end">
                </div>
                
                <div class="form-group">
                    <label for="descriere">Descriere:</label>
                    <textarea id="descriere" name="descriere" rows="4"></textarea>
                </div>
                
                <button type="submit" class="btn btn-success">Salvează</button>
            </form>
        </div>
    </div>
    
    <!-- Modaluri similare pentru Educație, Limbi și Proiecte -->
    
    <script>
    function showModal(modalId) {
        document.getElementById(modalId).style.display = "block";
    }
    
    function closeModal(modalId) {
        document.getElementById(modalId).style.display = "none";
    }
    
    function editExperience(id) {
        // Aici ar trebui să încărcăm datele experienței în formular
        document.getElementById('experience_id').value = id;
        document.getElementById('experienceForm').action = 'CVManagementServlet?action=updateExperience';
        showModal('experienceModal');
    }
    
    // Funcții similare pentru editEducation, editLanguage, editProject
    
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