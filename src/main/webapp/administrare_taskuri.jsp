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
                    
                    // Verificare acces pentru administrare taskuri
                    // Acces permis: Director, Șef, Manager sau Admin
                    if (isAdmin) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }

                    String action = request.getParameter("action");
                    if (action == null) {
                        action = "view";  // Default action
                    }
                 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                    String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
                    String clr = "#d8d9e1";
                    String sidebar = "#ECEDFA";
                    String text = "#333";
                    String card = "#ECEDFA";
                    String hover = "#ECEDFA";
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        String query = "SELECT * from teme where id_usr = ?";
                        try (PreparedStatement stmt = connection.prepareStatement(query)) {
                            stmt.setInt(1, userId);
                            try (ResultSet rs2 = stmt.executeQuery()) {
                                if (rs2.next()) {
                                  accent = rs2.getString("accent");
                                  clr = rs2.getString("clr");
                                  sidebar = rs2.getString("sidebar");
                                  text = rs2.getString("text");
                                  card = rs2.getString("card");
                                  hover = rs2.getString("hover");
                                }
                            }
                        }
                   } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Administrare Taskuri</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <!-- Asigură-te că jQuery este încărcat din CDN pentru fiabilitate -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
       @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
		
		* {
		    
		    font-family: 'Poppins', sans-serif;
		}
        .main-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: <%=sidebar%>;
            border-radius: 8px;
           
        }
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 30px;
        }
        .action-button {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            
    		display: inline-block; 
        }
        .action-button.active {
            background-color: <%=accent%>;
            color: white;
        }
        .action-button:not(.active) {
            background-color: black;
            color: white;
        }
        .action-button:hover {
            transform: translateY(-5px);
        	background-color: black;
        }
        .form-container {
            background: <%=sidebar%>;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
            text-align: center;
            color: <%=text%>;
        }
        .form-container h2 {
            margin-bottom: 20px;
            color: <%=text%>;
        }
        .form-group {
            margin-bottom: 15px;
            color: <%=text%>;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid <%=sidebar%>;
            border-radius: 5px;
            font-size: 16px;
            color: <%=text%>;
        }
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
            color: <%=text%>;
        }
        .submit-button {
            background-color: <%=accent%>;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .submit-button:hover {
            background-color: black;
        }
        .taskuri-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            color: <%=text%>;
        }
        .taskuri-table th, .taskuri-table td {
            padding: 10px;
            border: 1px solid <%=sidebar%>;
            text-align: center;
            color: <%=text%>;
        }
        .taskuri-table tr:hover {
		    background-color: <%=accent%>;
		    color: white; 
		    transition: background-color 0.3s ease, color 0.3s ease;
		}
        .taskuri-table th {
            background-color: <%=accent%>;
            color: white;
        }
        .table-button {
            padding: 5px 10px;
            margin: 0 5px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }
        .modify-button {
            background-color: black;
            color: white;
             transition: all 0.3s ease;
    		display: inline-block; 
        }
        .delete-button {
            background-color: #e63946;
            color: white;
             transition: all 0.3s ease;
    		display: inline-block; 
        }
        .status-button {
            background-color: #ffc107;
            color: black;
            transition: all 0.3s ease;
            display: inline-block;
        }
        .back-button {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #666;
            color: white;
            text-decoration: none;
            border-radius: 5px;
             transition: all 0.3s ease;
    		display: inline-block; 
        }
        .modify-button:hover {
       		background-color: white;
       		color: black;
        	transform: translateY(-5px);
        }
        .delete-button:hover, .back-button:hover, .status-button:hover {
         transform: translateY(-5px);
        	background-color: black;
            color: white;
        }
        .status-badge {
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.9em;
            color: white;
            transition: all 0.3s ease;
    		display: inline-block; 
        }
        .status-badge:hover {
         transform: translateY(-5px);
        }
        .status-0 { background-color: #6c757d; }
        .status-1 { background-color: #17a2b8; }
        .status-2 { background-color: #ffc107; color: black; }
        .status-3 { background-color: #fd7e14; }
        .status-4 { background-color: #28a745; }
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            
            border-radius: 50%;
            border-top-color: <%=accent%>;
            animation: spin 1s ease-in-out infinite;
            margin-left: 10px;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
      
        .disabled-field {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        .main-container {
        color: <%=accent%>;
        }
    </style>
</head>

<body>
    <div class="main-container">
        <h1>Administrare Taskuri</h1>
        
        <% if ("view".equals(action)) { %>
            <div class="action-buttons">
                <button class="action-button active" onclick="window.location.href='administrare_taskuri.jsp?action=add'">
                    Adaugă task
                </button>
                <button class="action-button active" onclick="window.location.href='administrare_taskuri.jsp?action=list'">
                    Vizualizare și modificare taskuri
                </button>
            </div>
            
        <% } else if ("add".equals(action)) { %>
            <div class="form-container">
                <h2>Adaugă task</h2>
                <form method="POST" action="AdaugaTaskServlet" id="addTaskForm">
                    <div class="form-group">
                        <label for="nume">Nume task:</label>
                        <input type="text" id="nume" name="nume" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">Descriere:</label>
                        <textarea id="descriere" name="descriere"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_prj">Proiect:</label>
                        <select id="id_prj" name="id_prj" required onchange="loadTeamMembers(this.value)">
                            <option value="">-- Selectați --</option>
                            <%
                            try {
                                String sql = "SELECT id, nume FROM proiecte WHERE end >= CURDATE() ORDER BY nume";
                                Statement stmt = connection.createStatement();
                                ResultSet rsProiecte = stmt.executeQuery(sql);
                                
                                while (rsProiecte.next()) {
                            %>
                                <option value="<%= rsProiecte.getInt("id") %>">
                                    <%= rsProiecte.getString("nume") %>
                                </option>
                            <%
                                }
                                rsProiecte.close();
                                stmt.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_ang">Asignat către: <span id="loading_members" class="loading" style="display: none;"></span></label>
                        <select id="id_ang" name="id_ang" required>
                            <option value="">-- Selectați mai întâi un proiect --</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="supervizor">Supervizor:</label>
                        <select id="supervizor" name="supervizor" required>
                            <option value="<%= userId %>" selected>Eu</option>
                            <%
                            try {
                                // Selectează doar utilizatori cu ierarhie mai mare sau egală cu a utilizatorului curent
                                String sql = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                            "JOIN tipuri t ON u.tip = t.tip " +
                                            "WHERE u.id != ? AND u.tip <> 34 AND t.ierarhie <= ? " +
                                            "ORDER BY u.nume, u.prenume";
                                PreparedStatement pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userId);
                                pstmt.setInt(2, ierarhie);
                                ResultSet rsSurvizori = pstmt.executeQuery();
                                
                                while (rsSurvizori.next()) {
                            %>
                                <option value="<%= rsSurvizori.getInt("id") %>">
                                    <%= rsSurvizori.getString("nume") %> <%= rsSurvizori.getString("prenume") %>
                                </option>
                            <%
                                }
                                rsSurvizori.close();
                                pstmt.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Status inițial:</label>
                        <select id="status" name="status" required>
                            <option value="0" selected>0% - Neînceput</option>
                            <option value="1">25% - În lucru</option>
                            <option value="2">50% - La jumătate</option>
                            <option value="3">75% - Aproape gata</option>
                            <option value="4">100% - Finalizat</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="submit-button">Adaugă Task</button>
                </form>
                <a href="administrare_taskuri.jsp" class="back-button">Înapoi</a>
                
                <!-- Container pentru informații de debugging -->
                <div id="debug-info" class="debug-info"></div>
            </div>
            
        <% } else if ("list".equals(action)) { %>
            <h2>Vizualizare și modificare taskuri</h2>
            <table class="taskuri-table">
                <thead>
                    <tr>
                        <th>Nr. crt</th>
                        <th>Nume task</th>
                        <th>Proiect</th>
                        <th>Asignat</th>
                        <th>Status</th>
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        String sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume, s.procent " +
                                   "FROM tasks t " +
                                   "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                                   "LEFT JOIN useri u ON t.id_ang = u.id " +
                                   "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                   "WHERE t.supervizor = ? OR t.id_ang = ? " +
                                   "ORDER BY t.start DESC";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        pstmt.setInt(2, userId);
                        ResultSet rsTasks = pstmt.executeQuery();
                        int counter = 1;
                        
                        while (rsTasks.next()) {
                            int status = rsTasks.getInt("status");
                            int procent = rsTasks.getInt("procent");
                            int taskId = rsTasks.getInt("id");
                            int supervisorId = rsTasks.getInt("supervizor");
                            int assignedId = rsTasks.getInt("id_ang");
                            
                            // Determină drepturile utilizatorului pentru acest task
                            boolean isAssignee = (userId == assignedId);
                            boolean isSupervisor = (userId == supervisorId);
                            boolean canModify = isSupervisor || (isDirector && !isSupervisor);
                            boolean canDelete = canModify;
                    %>
                        <tr>
                            <td><%= counter++ %></td>
                            <td><%= rsTasks.getString("nume") %></td>
                            <td><%= rsTasks.getString("proiect_nume") %></td>
                            <td><%= rsTasks.getString("asignat_nume") %> <%= rsTasks.getString("asignat_prenume") %></td>
                            <td>
                                <span class="status-badge status-<%= status %>">
                                    <%= procent %>%
                                </span>
                            </td>
                            <td>
                                <% if (canModify) { %>
                                    <button class="table-button modify-button" 
                                            onclick="window.location.href='administrare_taskuri.jsp?action=edit&id=<%= taskId %>'">
                                        ✏ Modifică
                                    </button>
                                <% } %>
                                
                                <% if (isAssignee && !canModify) { %>
                                    <button class="table-button status-button" 
                                            onclick="window.location.href='administrare_taskuri.jsp?action=status&id=<%= taskId %>'">
                                        📊 Status
                                    </button>
                                <% } %>
                                
                                <% if (canDelete) { %>
                                    <button class="table-button delete-button" 
                                            onclick="deleteTask(<%= taskId %>)">
                                        ❌ Șterge
                                    </button>
                                <% } %>
                            </td>
                        </tr>
                    <%
                        }
                        rsTasks.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </tbody>
            </table>
            <a href="administrare_taskuri.jsp" class="back-button">Înapoi</a>
            
        <% } else if ("edit".equals(action)) { 
            int idTask = Integer.parseInt(request.getParameter("id"));
            try {
                String sql = "SELECT t.*, p.nume as proiect_nume FROM tasks t " +
                           "LEFT JOIN proiecte p ON t.id_prj = p.id " + 
                           "WHERE t.id = ?";
                PreparedStatement pstmt = connection.prepareStatement(sql);
                pstmt.setInt(1, idTask);
                ResultSet rsTask = pstmt.executeQuery();
                
                if (rsTask.next()) {
                    // Verifică dacă utilizatorul are drepturi de modificare completă a task-ului
                    int supervisorId = rsTask.getInt("supervizor");
                    boolean canModify = (userId == supervisorId) || (isDirector && userId != supervisorId);
                    
                    if (!canModify) {
                        // Redirectează către pagina de modificare status dacă nu are drepturi
                        response.sendRedirect("administrare_taskuri.jsp?action=status&id=" + idTask);
                        return;
                    }
        %>
            <div class="form-container">
                <h2>Modificare task</h2>
                <form method="POST" action="EditTaskServlet" id="editTaskForm">
                    <input type="hidden" name="id" value="<%= idTask %>">
                    
                    <div class="form-group">
                        <label for="nume">Nume task:</label>
                        <input type="text" id="nume" name="nume" value="<%= rsTask.getString("nume") %>" required>
                    </div>
                    
                  
                    <div class="form-group">
                        <label for="id_prj">Proiect:</label>
                        <select id="id_prj" name="id_prj" required onchange="loadTeamMembersEdit(this.value)">
                            <%
                            String sql2 = "SELECT id, nume FROM proiecte ORDER BY nume";
                            Statement stmt2 = connection.createStatement();
                            ResultSet rs2 = stmt2.executeQuery(sql2);
                            
                            while (rs2.next()) {
                                boolean selected = rsTask.getInt("id_prj") == rs2.getInt("id");
                            %>
                                <option value="<%= rs2.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs2.getString("nume") %>
                                </option>
                            <%
                            }
                            rs2.close();
                            stmt2.close();
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_ang">Asignat către: <span id="loading_members_edit" class="loading" style="display: none;"></span></label>
                        <select id="id_ang" name="id_ang" required>
                            <!-- Acest select va fi populat prin JavaScript când se încarcă pagina -->
                            <option value="<%= rsTask.getInt("id_ang") %>">Încărcare membri echipă...</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="supervizor">Supervizor:</label>
                        <select id="supervizor" name="supervizor" required>
                            <%
                            // Selectează doar utilizatori cu ierarhie mai mare sau egală cu a utilizatorului curent
                            String sql4 = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "WHERE u.tip <> 34 AND t.ierarhie <= ? " +
                                        "ORDER BY u.nume, u.prenume";
                            PreparedStatement pstmt4 = connection.prepareStatement(sql4);
                            pstmt4.setInt(1, ierarhie);
                            ResultSet rs4 = pstmt4.executeQuery();
                            
                            while (rs4.next()) {
                                boolean selected = rsTask.getInt("supervizor") == rs4.getInt("id");
                            %>
                                <option value="<%= rs4.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs4.getString("nume") %> <%= rs4.getString("prenume") %>
                                </option>
                            <%
                            }
                            rs4.close();
                            pstmt4.close();
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" value="<%= rsTask.getDate("start") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" value="<%= rsTask.getDate("end") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Status:</label>
                        <select id="status" name="status" required>
                            <%
                            String sql5 = "SELECT id, procent FROM statusuri2 ORDER BY id";
                            Statement stmt5 = connection.createStatement();
                            ResultSet rs5 = stmt5.executeQuery(sql5);
                            
                            while (rs5.next()) {
                                boolean selected = rsTask.getInt("status") == rs5.getInt("id");
                            %>
                                <option value="<%= rs5.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs5.getInt("procent") %>% - <%= getStatusText(rs5.getInt("id")) %>
                                </option>
                            <%
                            }
                            rs5.close();
                            stmt5.close();
                            %>
                        </select>
                    </div>
                    
                    <button type="submit" class="submit-button">Salvează Modificările</button>
                </form>
                <a href="administrare_taskuri.jsp?action=list" class="back-button">Înapoi</a>
                
                <!-- Container pentru informații de debugging -->
                <div id="debug-info-edit" class="debug-info"></div>
            </div>
        <%
                }
                rsTask.close();
                pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("status".equals(action)) { 
            int idTask = Integer.parseInt(request.getParameter("id"));
            try {
                String sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume " +
                           "FROM tasks t " +
                           "LEFT JOIN proiecte p ON t.id_prj = p.id " + 
                           "LEFT JOIN useri u ON t.id_ang = u.id " +
                           "WHERE t.id = ?";
                PreparedStatement pstmt = connection.prepareStatement(sql);
                pstmt.setInt(1, idTask);
                ResultSet rsTask = pstmt.executeQuery();
                
                if (rsTask.next()) {
                    // Verifică dacă utilizatorul este asignat la acest task
                    int assignedId = rsTask.getInt("id_ang");
                    boolean isAssignee = (userId == assignedId);
                    
                    if (!isAssignee && !isDirector && userId != rsTask.getInt("supervizor")) {
                        // Redirectează către pagina de listare dacă nu este asignat
                        response.sendRedirect("administrare_taskuri.jsp?action=list");
                        return;
                    }
        %>
            <div class="form-container">
                <h2>Actualizare status task</h2>
                <form method="POST" action="UpdateTaskStatusServlet" id="statusForm">
                    <input type="hidden" name="id" value="<%= idTask %>">
                    
                    <div class="form-group">
                        <label for="nume">Nume task:</label>
                        <input type="text" id="nume" name="nume" value="<%= rsTask.getString("nume") %>" class="disabled-field" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="proiect">Proiect:</label>
                        <input type="text" id="proiect" name="proiect" value="<%= rsTask.getString("proiect_nume") %>" class="disabled-field" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="asignat">Asignat către:</label>
                        <input type="text" id="asignat" name="asignat" 
                               value="<%= rsTask.getString("asignat_nume") %> <%= rsTask.getString("asignat_prenume") %>" 
                               class="disabled-field" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="perioada">Perioada:</label>
                        <input type="text" id="perioada" name="perioada" 
                               value="<%= rsTask.getDate("start") %> - <%= rsTask.getDate("end") %>" 
                               class="disabled-field" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Status:</label>
                        <select id="status" name="status" required>
                            <%
                            String sql5 = "SELECT id, procent FROM statusuri2 ORDER BY id";
                            Statement stmt5 = connection.createStatement();
                            ResultSet rs5 = stmt5.executeQuery(sql5);
                            
                            while (rs5.next()) {
                                boolean selected = rsTask.getInt("status") == rs5.getInt("id");
                            %>
                                <option value="<%= rs5.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs5.getInt("procent") %>% - <%= getStatusText(rs5.getInt("id")) %>
                                </option>
                            <%
                            }
                            rs5.close();
                            stmt5.close();
                            %>
                        </select>
                    </div>
                    
                    <button type="submit" class="submit-button">Actualizează Status</button>
                </form>
                <a href="administrare_taskuri.jsp?action=list" class="back-button">Înapoi</a>
            </div>
        <%
                }
                rsTask.close();
                pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        %>
    </div>

    <%!
    private String getStatusText(int status) {
        switch (status) {
            case 0: return "Neînceput";
            case 1: return "În lucru";
            case 2: return "La jumătate";
            case 3: return "Aproape gata";
            case 4: return "Finalizat";
            default: return "Necunoscut";
        }
    }
    %>

    <script>
        // Funcție pentru a adăuga mesaje în containerul de debugging
        function addDebugMessage(message, containerId = 'debug-info') {
            const debugContainer = document.getElementById(containerId);
            if (debugContainer) {
                const timestamp = new Date().toLocaleTimeString();
                const formattedMessage = `[${timestamp}] ${message}`;
                debugContainer.innerHTML += formattedMessage + '\n';
                
                // Facem containerul vizibil și derulăm la ultimul mesaj
                debugContainer.style.display = 'block';
                debugContainer.scrollTop = debugContainer.scrollHeight;
                
                // Log în consola browserului pentru debugging ușor
                console.log(message);
            }
        }

        // Funcție pentru încărcarea membrilor echipei pe pagina de adăugare
        function loadTeamMembers(projectId) {
            if (!projectId) {
                document.getElementById('id_ang').innerHTML = '<option value="">-- Selectați mai întâi un proiect --</option>';
                return;
            }
            
            addDebugMessage(`Încărcare membri pentru proiectul ID: ${projectId}`);
            
            // Arată indicatorul de încărcare
            document.getElementById('loading_members').style.display = 'inline-block';
            document.getElementById('id_ang').disabled = true;
            
            // Obține ierarhia utilizatorului curent pentru a încărca doar utilizatori cu ierarhie mai mare
            const userIerarhie = <%= ierarhie %>;
            
            // Apelează servlet-ul via AJAX cu parametri suplimentari
            fetch('GetTeamMembersServlet?projectId=' + projectId + '&userIerarhie=' + userIerarhie)
                .then(response => {
                    addDebugMessage(`Răspuns primit cu status: ${response.status}`);
                    return response.text();
                })
                .then(data => {
                    // Actualizează dropdown-ul cu membri
                    document.getElementById('id_ang').innerHTML = data;
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members').style.display = 'none';
                    
                    addDebugMessage(`Membri încărcați cu succes, ${document.getElementById('id_ang').options.length} opțiuni disponibile`);
                })
                .catch(error => {
                    addDebugMessage(`Eroare la încărcarea membrilor: ${error}`);
                    document.getElementById('id_ang').innerHTML = '<option value="">Eroare la încărcarea membrilor</option>';
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members').style.display = 'none';
                    alert('Eroare la încărcarea membrilor echipei: ' + error);
                });
        }
        
        // Funcție pentru încărcarea membrilor echipei pe pagina de editare
        function loadTeamMembersEdit(projectId) {
            if (!projectId) {
                document.getElementById('id_ang').innerHTML = '<option value="">-- Selectați mai întâi un proiect --</option>';
                return;
            }
            
            addDebugMessage(`Încărcare membri pentru proiectul ID: ${projectId}`, 'debug-info-edit');
            
            // Arată indicatorul de încărcare
            document.getElementById('loading_members_edit').style.display = 'inline-block';
            document.getElementById('id_ang').disabled = true;
            
            // Salvează ID-ul angajatului selectat curent (dacă există)
            const currentAngId = document.getElementById('id_ang').value;
            
            // Obține ierarhia utilizatorului curent pentru a încărca doar utilizatori cu ierarhie mai mare
            const userIerarhie = <%= ierarhie %>;
            
            // Apelează servlet-ul via AJAX cu parametri suplimentari
            fetch('GetTeamMembersServlet?projectId=' + projectId + '&userIerarhie=' + userIerarhie)
                .then(response => {
                    addDebugMessage(`Răspuns primit cu status: ${response.status}`, 'debug-info-edit');
                    return response.text();
                })
                .then(data => {
                    // Actualizează dropdown-ul cu membri
                    document.getElementById('id_ang').innerHTML = data;
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members_edit').style.display = 'none';
                    
                    // Încearcă să selecteze angajatul anterior dacă există în lista nouă
                    if (currentAngId) {
                        const options = document.getElementById('id_ang').options;
                        for (let i = 0; i < options.length; i++) {
                            if (options[i].value === currentAngId) {
                                options[i].selected = true;
                                break;
                            }
                        }
                    }
                    
                    addDebugMessage(`Membri încărcați cu succes, ${document.getElementById('id_ang').options.length} opțiuni disponibile`, 'debug-info-edit');
                })
                .catch(error => {
                    addDebugMessage(`Eroare la încărcarea membrilor: ${error}`, 'debug-info-edit');
                    document.getElementById('id_ang').innerHTML = '<option value="">Eroare la încărcarea membrilor</option>';
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members_edit').style.display = 'none';
                    alert('Eroare la încărcarea membrilor echipei: ' + error);
                });
        }

        // Funcție pentru ștergerea unui task
        function deleteTask(idTask) {
            if (confirm('Sigur doriți să ștergeți acest task?')) {
                fetch('DeleteTaskServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'id=' + idTask
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert(data.message || 'Eroare la ștergerea taskului!');
                    }
                })
                .catch(error => {
                    console.error('Delete error:', error);
                    alert('Eroare la conectarea cu serverul!');
                });
            }
        }

        // Se execută când documentul se încarcă
        document.addEventListener('DOMContentLoaded', function() {
            // Verifică dacă suntem pe pagina de editare
            const editForm = document.getElementById('editTaskForm');
            if (editForm) {
                // Încarcă membrii echipei când se încarcă pagina de editare
                const projectId = document.getElementById('id_prj').value;
                if (projectId) {
                    addDebugMessage(`Pagina de editare încărcată, încărcare automată membri pentru proiectul ID: ${projectId}`, 'debug-info-edit');
                    loadTeamMembersEdit(projectId);
                }
            }
            
            // Afișează informații despre încărcarea paginii
            const addForm = document.getElementById('addTaskForm');
            if (addForm) {
                addDebugMessage('Pagina de adăugare task încărcată');
            }
        });
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