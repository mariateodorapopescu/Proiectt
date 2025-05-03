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
                    
                    // Verificare acces pentru management taskuri
                    // Acces permite: Director, Manager, Șef sau Admin
                    if (isAdmin) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }

                    // Verificare rol utilizator pentru funcționalități specifice
                    boolean isManager = false;
                    boolean hasProjects = false;

                    // Director sau șef de departament
                    if (isDirector || isSef) {
                        isManager = true;
                    } else {
                        // Verifică dacă este manager de proiect
                        try {
                            String sql = "SELECT COUNT(*) FROM proiecte WHERE supervizor = ?";
                            PreparedStatement pstmt = connection.prepareStatement(sql);
                            pstmt.setInt(1, userId);
                            ResultSet rsProjects = pstmt.executeQuery();
                            if (rsProjects.next() && rsProjects.getInt(1) > 0) {
                                hasProjects = true;
                            }
                            rsProjects.close();
                            pstmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Management Taskuri</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <link rel="stylesheet" href="css/fullcalendar.min.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="js/moment.min.js"></script>
    <script src="js/fullcalendar.min.js"></script>
    <style>
        .task-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin: 20px 0;
        }
        .task-view {
            flex: 1;
            min-width: 300px;
        }
        .task-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            background: white;
            transition: all 0.3s ease;
        }
        .task-card:hover {
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .task-status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            color: white;
            font-size: 0.9em;
        }
        .status-0 { background-color: #6c757d; } /* 0% - Neînceput */
        .status-1 { background-color: #17a2b8; } /* 25% - În lucru */
        .status-2 { background-color: #ffc107; color: black; } /* 50% - La jumătate */
        .status-3 { background-color: #fd7e14; } /* 75% - Aproape gata */
        .status-4 { background-color: #28a745; } /* 100% - Finalizat */
        
        .task-priority {
            float: right;
            font-weight: bold;
        }
        .priority-high { color: #dc3545; }
        .priority-medium { color: #ffc107; }
        .priority-low { color: #28a745; }
        
        .calendar-view {
            margin-top: 30px;
        }
        .tab-container {
            margin-bottom: 20px;
        }
        .tab-button {
            padding: 10px 20px;
            margin-right: 5px;
            border: none;
            background-color: #f1f1f1;
            cursor: pointer;
        }
        .tab-button.active {
            background-color: #ddd;
            font-weight: bold;
        }
        .tab-content {
            display: none;
        }
        .tab-content.active {
            display: block;
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
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 600px;
            border-radius: 8px;
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
    
        
            <h2>Management Taskuri</h2>
            
            <div class="tab-container">
                <button class="tab-button active" onclick="showTab('taskuri')">Lista Taskuri</button>
                <button class="tab-button" onclick="showTab('calendar')">Calendar</button>
                <button class="tab-button" onclick="showTab('rapoarte')">Rapoarte</button>
                <% if (isManager || hasProjects) { %>
                    <button class="tab-button" onclick="showTab('management')">Management</button>
                <% } %>
            </div>
            
            <!-- Tab Lista Taskuri -->
            <div id="taskuri" class="tab-content active">
                <h3>Taskurile Mele</h3>
                <% if (isManager || hasProjects) { %>
                    <button class="btn" onclick="openModal('addTaskModal')">Adaugă Task Nou</button>
                <% } %>
                
                <div class="task-container">
                    <%
                    try {
                        String sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, " +
                                    "u.prenume as asignat_prenume, s.procent, " +
                                    "CONCAT(us.nume, ' ', us.prenume) as supervizor_nume " +
                                    "FROM tasks t " +
                                    "JOIN proiecte p ON t.id_prj = p.id " +
                                    "JOIN useri u ON t.id_ang = u.id " +
                                    "JOIN statusuri2 s ON t.status = s.id " +
                                    "JOIN useri us ON t.supervizor = us.id " +
                                    "WHERE t.id_ang = ? OR t.supervizor = ? " +
                                    "ORDER BY t.end ASC";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        pstmt.setInt(2, userId);
                        ResultSet rsTasks = pstmt.executeQuery();
                        
                        while (rsTasks.next()) {
                            int statusId = rsTasks.getInt("status");
                            String prioritate = "medium"; // Aici ar trebui să existe o coloană în DB
                    %>
                        <div class="task-card">
                            <h4><%= rsTasks.getString("nume") %></h4>
                            <p><strong>Proiect:</strong> <%= rsTasks.getString("proiect_nume") %></p>
                            <p><strong>Asignat:</strong> <%= rsTasks.getString("asignat_nume") %> <%= rsTasks.getString("asignat_prenume") %></p>
                            <p><strong>Deadline:</strong> <%= rsTasks.getDate("end") %></p>
                            <p>
                                <span class="task-status status-<%= statusId %>">
                                    <%= rsTasks.getInt("procent") %>% Completat
                                </span>
                                <span class="task-priority priority-<%= prioritate %>">
                                    <%= prioritate.substring(0,1).toUpperCase() + prioritate.substring(1) %>
                                </span>
                            </p>
                            <% if (rsTasks.getInt("id_ang") == userId || rsTasks.getInt("supervizor") == userId) { %>
                                <button class="btn btn-small" onclick="updateTaskStatus(<%= rsTasks.getInt("id") %>)">
                                    Actualizează Status
                                </button>
                            <% } %>
                        </div>
                    <%
                        }
                        rsTasks.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </div>
            </div>
            
            <!-- Tab Calendar -->
            <div id="calendar" class="tab-content">
                <h3>Calendar Taskuri</h3>
                <div id="calendar-container"></div>
            </div>
            
            <!-- Tab Rapoarte -->
            <div id="rapoarte" class="tab-content">
                <h3>Rapoarte Productivitate</h3>
                
                <div class="report-section">
                    <h4>Raport Personal</h4>
                    <canvas id="personalChart" width="400" height="200"></canvas>
                </div>
                
                <% if (isManager || hasProjects) { %>
                <div class="report-section">
                    <h4>Raport Echipă</h4>
                    <canvas id="teamChart" width="400" height="200"></canvas>
                </div>
                <% } %>
            </div>
            
            <!-- Tab Management (doar pentru manageri) -->
            <% if (isManager || hasProjects) { %>
            <div id="management" class="tab-content">
                <h3>Management Taskuri</h3>
                
                <div class="management-controls">
                    <button class="btn" onclick="openModal('addTaskModal')">Adaugă Task</button>
                    <button class="btn" onclick="exportRaport()">Export Raport</button>
                </div>
                
                <table class="full-width">
                    <thead>
                        <tr>
                            <th>Task</th>
                            <th>Proiect</th>
                            <th>Asignat</th>
                            <th>Status</th>
                            <th>Deadline</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String sql = "";
                            PreparedStatement pstmt = null;
                            
                            if (hasProjects && !isManager) {
                                // Manager de proiect - doar proiectele sale
                                sql = "SELECT t.*, p.nume as proiect_nume, u.nume, u.prenume, s.procent " +
                                      "FROM tasks t " +
                                      "JOIN proiecte p ON t.id_prj = p.id " +
                                      "JOIN useri u ON t.id_ang = u.id " +
                                      "JOIN statusuri2 s ON t.status = s.id " +
                                      "WHERE p.supervizor = ? " +
                                      "ORDER BY t.end ASC";
                                pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userId);
                            } else {
                                // Director/Șef - toate taskurile
                                sql = "SELECT t.*, p.nume as proiect_nume, u.nume, u.prenume, s.procent " +
                                      "FROM tasks t " +
                                      "JOIN proiecte p ON t.id_prj = p.id " +
                                      "JOIN useri u ON t.id_ang = u.id " +
                                      "JOIN statusuri2 s ON t.status = s.id " +
                                      "ORDER BY t.end ASC";
                                pstmt = connection.prepareStatement(sql);
                            }
                            
                            ResultSet rsTasksManagement = pstmt.executeQuery();
                            
                            while (rsTasksManagement.next()) {
                        %>
                            <tr>
                                <td><%= rsTasksManagement.getString("nume") %></td>
                                <td><%= rsTasksManagement.getString("proiect_nume") %></td>
                                <td><%= rsTasksManagement.getString("nume") %> <%= rsTasksManagement.getString("prenume") %></td>
                                <td>
                                    <span class="task-status status-<%= rsTasksManagement.getInt("status") %>">
                                        <%= rsTasksManagement.getInt("procent") %>%
                                    </span>
                                </td>
                                <td><%= rsTasksManagement.getDate("end") %></td>
                                <td>
                                    <button class="btn-small" onclick="editTask(<%= rsTasksManagement.getInt("id") %>)">Edit</button>
                                    <button class="btn-small btn-danger" onclick="deleteTask(<%= rsTasksManagement.getInt("id") %>)">Șterge</button>
                                </td>
                            </tr>
                        <%
                            }
                            rsTasksManagement.close();
                            pstmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
            <% } %>
      
    <!-- Modal Adăugare Task -->
    <div id="addTaskModal" class="modal">
        <div class="modal-content">
            <h3>Adaugă Task Nou</h3>
            <form method="POST" action="AdaugaTaskServlet">
                <label for="nume">Nume Task:</label>
                <input type="text" id="nume" name="nume" required>
                
                <label for="id_prj">Proiect:</label>
                <select id="id_prj" name="id_prj" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        String sql = "";
                        PreparedStatement pstmt = null;
                        
                        if (hasProjects && !isManager) {
                            sql = "SELECT * FROM proiecte WHERE supervizor = ?";
                            pstmt = connection.prepareStatement(sql);
                            pstmt.setInt(1, userId);
                        } else {
                            sql = "SELECT * FROM proiecte WHERE end >= CURDATE()";
                            pstmt = connection.prepareStatement(sql);
                        }
                        
                        ResultSet rsProiecte = pstmt.executeQuery();
                        
                        while (rsProiecte.next()) {
                    %>
                        <option value="<%= rsProiecte.getInt("id") %>">
                            <%= rsProiecte.getString("nume") %>
                        </option>
                    <%
                        }
                        rsProiecte.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </select>
                
                <label for="id_ang">Asignat către:</label>
                <select id="id_ang" name="id_ang" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        String sql = "SELECT id, nume, prenume FROM useri WHERE activ = 1 AND id_dep = ? ORDER BY nume, prenume";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userDep);
                        ResultSet rsAngajati = pstmt.executeQuery();
                        
                        while (rsAngajati.next()) {
                    %>
                        <option value="<%= rsAngajati.getInt("id") %>">
                            <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                        </option>
                    <%
                        }
                        rsAngajati.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </select>
                
                <label for="start">Data Start:</label>
                <input type="date" id="start" name="start" required>
                
                <label for="end">Data Sfârșit:</label>
                <input type="date" id="end" name="end" required>
                
                <label for="descriere">Descriere:</label>
                <textarea id="descriere" name="descriere" rows="4"></textarea>
                
                <button type="submit" class="btn">Salvează</button>
                <button type="button" class="btn" onclick="closeModal('addTaskModal')">Anulează</button>
            </form>
        </div>
    </div>
    
    <!-- Modal Update Status -->
    <div id="updateStatusModal" class="modal">
        <div class="modal-content">
            <h3>Actualizează Status Task</h3>
            <form method="POST" action="UpdateTaskStatusServlet">
                <input type="hidden" id="task_id" name="task_id">
                
                <label for="status">Status:</label>
                <select id="status" name="status" required>
                    <option value="0">0% - Neînceput</option>
                    <option value="1">25% - În lucru</option>
                    <option value="2">50% - La jumătate</option>
                    <option value="3">75% - Aproape gata</option>
                    <option value="4">100% - Finalizat</option>
                </select>
                
                <label for="comentariu">Comentariu:</label>
                <textarea id="comentariu" name="comentariu" rows="4"></textarea>
                
                <button type="submit" class="btn">Actualizează</button>
                <button type="button" class="btn" onclick="closeModal('updateStatusModal')">Anulează</button>
            </form>
        </div>
    </div>

    <script>
        // Calendar
        $(document).ready(function() {
            $('#calendar-container').fullCalendar({
                header: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'month,agendaWeek,agendaDay'
                },
                events: 'GetTasksCalendarServlet',
                eventClick: function(event) {
                    if (event.id) {
                        updateTaskStatus(event.id);
                    }
                },
                eventRender: function(event, element) {
                    element.css('background-color', getStatusColor(event.status));
                    element.attr('title', event.description);
                }
            });
        });
        
        function getStatusColor(status) {
            switch(status) {
                case 0: return '#6c757d';
                case 1: return '#17a2b8';
                case 2: return '#ffc107';
                case 3: return '#fd7e14';
                case 4: return '#28a745';
                default: return '#6c757d';
            }
        }
        
        function showTab(tabName) {
            // Ascunde toate tab-urile
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab-button').forEach(button => {
                button.classList.remove('active');
            });
            
            // Afișează tab-ul selectat
            document.getElementById(tabName).classList.add('active');
            event.target.classList.add('active');
        }
        
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        function updateTaskStatus(taskId) {
            document.getElementById('task_id').value = taskId;
            openModal('updateStatusModal');
        }
        
        function editTask(taskId) {
            // Implementare editare task
            window.location.href = 'edit_task.jsp?id=' + taskId;
        }
        
        function deleteTask(taskId) {
            if (confirm('Sigur doriți să ștergeți acest task?')) {
                $.ajax({
                    url: 'DeleteTaskServlet',
                    type: 'POST',
                    data: { task_id: taskId },
                    success: function(response) {
                        location.reload();
                    },
                    error: function() {
                        alert('Eroare la ștergerea taskului!');
                    }
                });
            }
        }
        
        function exportRaport() {
            window.location.href = 'ExportRaportTaskuriServlet';
        }
        
        // Charts pentru rapoarte
        function loadCharts() {
            // Personal Chart
            $.ajax({
                url: 'GetPersonalProductivityServlet',
                type: 'GET',
                success: function(data) {
                    // Implementare chart cu Chart.js
                }
            });
            
            // Team Chart
            $.ajax({
                url: 'GetTeamProductivityServlet',
                type: 'GET',
                success: function(data) {
                    // Implementare chart cu Chart.js
                }
            });
        }
        
        // Închide modalele când se dă click în afara lor
        window.onclick = function(event) {
            if (event.target.className === 'modal') {
                event.target.style.display = 'none';
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