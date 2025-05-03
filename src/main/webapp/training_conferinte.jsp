<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.time.LocalDate" %>
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

                    // Verificare acces pentru management evenimente
                    // Acces permis: HR sau manageri (directori și șefi)
                    boolean canManageEvents = (isHR || isSef || isDirector || isAdmin);
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Training-uri și Conferințe</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        .event-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .event-card {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .event-type {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.9em;
            margin-bottom: 10px;
        }
        .type-training { background-color: #17a2b8; color: white; }
        .type-workshop { background-color: #ffc107; color: black; }
        .type-conferinta { background-color: #6f42c1; color: white; }
        
        .event-date {
            font-weight: bold;
            color: #333;
            margin: 10px 0;
        }
        .event-participants {
            font-size: 0.9em;
            color: #666;
        }
        .btn-join {
            margin-top: 15px;
            width: 100%;
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
        .raport-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .raport-table th, .raport-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .raport-table th {
            background-color: #f4f4f4;
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
  
            <h2>Training-uri și Conferințe</h2>
            
            <div class="tab-container">
                <button class="tab-button active" onclick="showTab('viitoare')">Evenimente Viitoare</button>
                <button class="tab-button" onclick="showTab('inscrieri')">Înscrierile Mele</button>
                <button class="tab-button" onclick="showTab('raport')">Raport Participare</button>
                <% if (canManageEvents) { %>
                    <button class="tab-button" onclick="showTab('management')">Management</button>
                <% } %>
            </div>
            
            <!-- Tab Evenimente Viitoare -->
            <div id="viitoare" class="tab-content active">
                <h3>Evenimente Disponibile</h3>
                <div class="event-container">
                    <%
                    try {
                        String sql = "SELECT e.*, te.denumire as tip_eveniment, " +
                                    "(SELECT COUNT(*) FROM participanti_evenimente pe WHERE pe.id_event = e.id) as nr_participanti, " +
                                    "(SELECT COUNT(*) FROM participanti_evenimente pe WHERE pe.id_event = e.id AND pe.id_ang = ?) as este_inscris " +
                                    "FROM evenimente e " +
                                    "JOIN tipuri_evenimente te ON e.tip = te.id " +
                                    "WHERE e.data_start > CURDATE() " +
                                    "ORDER BY e.data_start ASC";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        ResultSet rsEvenimente = pstmt.executeQuery();
                        
                        while (rsEvenimente.next()) {
                            boolean esteInscris = rsEvenimente.getInt("este_inscris") > 0;
                            int locuriRamase = rsEvenimente.getInt("locuri_max") - rsEvenimente.getInt("nr_participanti");
                    %>
                        <div class="event-card">
                            <span class="event-type type-<%= rsEvenimente.getString("tip_eveniment").toLowerCase() %>">
                                <%= rsEvenimente.getString("tip_eveniment") %>
                            </span>
                            <h4><%= rsEvenimente.getString("nume") %></h4>
                            <p class="event-date">
                                Data: <%= rsEvenimente.getDate("data_start") %> <%= rsEvenimente.getTime("ora_start") %>
                            </p>
                            <p><%= rsEvenimente.getString("descriere") %></p>
                            <p class="event-participants">
                                Participanți: <%= rsEvenimente.getInt("nr_participanti") %>/<%= rsEvenimente.getInt("locuri_max") %>
                                (Locuri rămase: <%= locuriRamase %>)
                            </p>
                            <% if (!esteInscris && locuriRamase > 0) { %>
                                <button class="btn btn-join" onclick="inscriereEveniment(<%= rsEvenimente.getInt("id") %>)">
                                    Înscrie-te
                                </button>
                            <% } else if (esteInscris) { %>
                                <button class="btn btn-secondary btn-join" disabled>
                                    Ești deja înscris
                                </button>
                            <% } else { %>
                                <button class="btn btn-secondary btn-join" disabled>
                                    Nu mai sunt locuri
                                </button>
                            <% } %>
                        </div>
                    <%
                        }
                        rsEvenimente.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </div>
            </div>
            
            <!-- Tab Înscrierile Mele -->
            <div id="inscrieri" class="tab-content">
                <h3>Evenimentele Mele</h3>
                <div class="event-container">
                    <%
                    try {
                        String sql = "SELECT e.*, te.denumire as tip_eveniment " +
                                    "FROM evenimente e " +
                                    "JOIN tipuri_evenimente te ON e.tip = te.id " +
                                    "JOIN participanti_evenimente pe ON e.id = pe.id_event " +
                                    "WHERE pe.id_ang = ? " +
                                    "ORDER BY e.data_start ASC";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        ResultSet rsInscrieri = pstmt.executeQuery();
                        
                        while (rsInscrieri.next()) {
                    %>
                        <div class="event-card">
                            <span class="event-type type-<%= rsInscrieri.getString("tip_eveniment").toLowerCase() %>">
                                <%= rsInscrieri.getString("tip_eveniment") %>
                            </span>
                            <h4><%= rsInscrieri.getString("nume") %></h4>
                            <p class="event-date">
                                Data: <%= rsInscrieri.getDate("data_start") %> <%= rsInscrieri.getTime("ora_start") %>
                            </p>
                            <p><%= rsInscrieri.getString("descriere") %></p>
                            <% if (rsInscrieri.getDate("data_start").toLocalDate().isAfter(LocalDate.now())) { %>
                                <button class="btn btn-danger" onclick="anuleazaInscriere(<%= rsInscrieri.getInt("id") %>)">
                                    Anulează Înscrierea
                                </button>
                            <% } %>
                        </div>
                    <%
                        }
                        rsInscrieri.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </div>
            </div>
            
            <!-- Tab Raport Participare -->
            <div id="raport" class="tab-content">
                <h3>Raport Participare Evenimente</h3>
                <table class="raport-table">
                    <thead>
                        <tr>
                            <th>Tip Eveniment</th>
                            <th>Număr Participări</th>
                            <th>Ultima Participare</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String sql = "SELECT te.denumire, COUNT(*) as nr_participari, MAX(e.data_start) as ultima_participare " +
                                        "FROM participanti_evenimente pe " +
                                        "JOIN evenimente e ON pe.id_event = e.id " +
                                        "JOIN tipuri_evenimente te ON e.tip = te.id " +
                                        "WHERE pe.id_ang = ? AND e.data_start < CURDATE() " +
                                        "GROUP BY te.id, te.denumire";
                            PreparedStatement pstmt = connection.prepareStatement(sql);
                            pstmt.setInt(1, userId);
                            ResultSet rsRaport = pstmt.executeQuery();
                            
                            while (rsRaport.next()) {
                        %>
                            <tr>
                                <td><%= rsRaport.getString("denumire") %></td>
                                <td><%= rsRaport.getInt("nr_participari") %></td>
                                <td><%= rsRaport.getDate("ultima_participare") %></td>
                            </tr>
                        <%
                            }
                            rsRaport.close();
                            pstmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
            
            <!-- Tab Management (doar pentru HR și manageri) -->
            <% if (canManageEvents) { %>
            <div id="management" class="tab-content">
                <h3>Management Evenimente</h3>
                
                <button class="btn" onclick="openModal('addEventModal')">Adaugă Eveniment Nou</button>
                
                <table class="raport-table">
                    <thead>
                        <tr>
                            <th>Eveniment</th>
                            <th>Tip</th>
                            <th>Data</th>
                            <th>Participanți</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String sql = "SELECT e.*, te.denumire as tip_eveniment, " +
                                        "(SELECT COUNT(*) FROM participanti_evenimente pe WHERE pe.id_event = e.id) as nr_participanti " +
                                        "FROM evenimente e " +
                                        "JOIN tipuri_evenimente te ON e.tip = te.id " +
                                        "ORDER BY e.data_start DESC";
                            Statement stmt = connection.createStatement();
                            ResultSet rsManagement = stmt.executeQuery(sql);
                            
                            while (rsManagement.next()) {
                        %>
                            <tr>
                                <td><%= rsManagement.getString("nume") %></td>
                                <td><%= rsManagement.getString("tip_eveniment") %></td>
                                <td><%= rsManagement.getDate("data_start") %></td>
                                <td><%= rsManagement.getInt("nr_participanti") %>/<%= rsManagement.getInt("locuri_max") %></td>
                                <td>
                                    <button class="btn-small" onclick="viewParticipants(<%= rsManagement.getInt("id") %>)">
                                        Vezi Participanți
                                    </button>
                                    <button class="btn-small btn-danger" onclick="deleteEvent(<%= rsManagement.getInt("id") %>)">
                                        Șterge
                                    </button>
                                </td>
                            </tr>
                        <%
                            }
                            rsManagement.close();
                            stmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
            <% } %>
    
    
    <!-- Modal Adăugare Eveniment -->
    <div id="addEventModal" class="modal">
        <div class="modal-content">
            <h3>Adaugă Eveniment Nou</h3>
            <form method="POST" action="AdaugaEvenimentServlet">
                <label for="nume">Nume Eveniment:</label>
                <input type="text" id="nume" name="nume" required>
                
                <label for="tip">Tip:</label>
                <select id="tip" name="tip" required>
                    <option value="1">Workshop</option>
                    <option value="2">Training</option>
                    <option value="3">Conferință</option>
                </select>
                
                <label for="data_start">Data:</label>
                <input type="date" id="data_start" name="data_start" required>
                
                <label for="ora_start">Ora:</label>
                <input type="time" id="ora_start" name="ora_start" required>
                
                <label for="locuri_max">Număr maxim participanți:</label>
                <input type="number" id="locuri_max" name="locuri_max" required>
                
                <label for="descriere">Descriere:</label>
                <textarea id="descriere" name="descriere" rows="4"></textarea>
                
                <button type="submit" class="btn">Salvează</button>
                <button type="button" class="btn" onclick="closeModal('addEventModal')">Anulează</button>
            </form>
        </div>
    </div>

    <script>
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
        
        function inscriereEveniment(eventId) {
            $.ajax({
                url: 'InscriereEvenimentServlet',
                type: 'POST',
                data: { event_id: eventId },
                success: function(response) {
                    if (response.success) {
                        alert('Te-ai înscris cu succes!');
                        location.reload();
                    } else {
                        alert(response.message || 'Eroare la înscriere!');
                    }
                },
                error: function() {
                    alert('Eroare la conectarea cu serverul!');
                }
            });
        }
        
        function anuleazaInscriere(eventId) {
            if (confirm('Sigur doriți să anulați înscrierea?')) {
                $.ajax({
                    url: 'AnuleazaInscriereServlet',
                    type: 'POST',
                    data: { event_id: eventId },
                    success: function(response) {
                        if (response.success) {
                            alert('Înscrierea a fost anulată!');
                            location.reload();
                        } else {
                            alert('Eroare la anularea înscrierii!');
                        }
                    },
                    error: function() {
                        alert('Eroare la conectarea cu serverul!');
                    }
                });
            }
        }
        
        function viewParticipants(eventId) {
            window.location.href = 'participanti_eveniment.jsp?id=' + eventId;
        }
        
        function deleteEvent(eventId) {
            if (confirm('Sigur doriți să ștergeți acest eveniment?')) {
                $.ajax({
                    url: 'DeleteEvenimentServlet',
                    type: 'POST',
                    data: { event_id: eventId },
                    success: function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert('Eroare la ștergerea evenimentului!');
                        }
                    },
                    error: function() {
                        alert('Eroare la conectarea cu serverul!');
                    }
                });
            }
        }
        
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
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