<%@ page import="java.io.*, java.util.*, java.sql.*, bean.MyUser, jakarta.servlet.http.*" %>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
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
            	String culoare = rs.getString("culoare");
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                String functie = rs.getString("functie");
                int ierarhie = rs.getInt("ierarhie");
                String numeDepartament = rs.getString("nume_dep");
                int idDepartament = rs.getInt("id_dep");

                // Functie helper pentru a determina rolul utilizatorului
                boolean isDirector = (ierarhie < 3) ;
                boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                boolean isIncepator = (ierarhie >= 10);
                boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                boolean isAdmin = (functie.compareTo("Administrator") == 0);

                if (isAdmin) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }
                String accent, clr, sidebar, text, card, hover;
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
%>
<!DOCTYPE html>
<html>
<head>
    <title>Calendar Concedii</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/locale-all.js"></script>
    <style>
     @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
        body {
            margin: 0;
            padding: 0;
            background-color: <%=clr%>;
            color: <%=text%>;
           font-family: 'Poppins', sans-serif;
        }
        * {
         font-family: 'Poppins', sans-serif;
        }
        
        .main-container {
            display: flex;
            padding: 20px;
            margin-top: 2em;
        }
        
        .sidebar {
            width: 240px;
            padding-right: 20px;
        }
        
        .content {
            flex: 1;
            background-color: <%=card%>;
            padding: 20px;
            border-radius: 20px;
           position: relative;
           top: 6em;
            min-height: 600px;
        }
        
        h1, h2, h3 {
            color: <%=accent%>;
            margin-top: 0;
        }
        
        #calendar {
            max-width: 100%;
            margin: 20px 0;
        }
        
        .fc-day-number {
            color: <%=accent%> !important;
        }
        
        table, 
        td,
        thead,
        tbody,
        .fc-row, .fc-column {
            border-color: <%=clr%> !important;
            background: <%=sidebar%> !important;
            color: <%=text%> !important;
        }
        
        th, hr {
            border-color: <%=accent%> !important;
            background: <%=accent%> !important;
            color: white;
        }
        
        /* Stiluri pentru filtre */
        .filters-card {
            background-color: <%=sidebar%>;
            border-radius: 15px;
            margin-bottom: 20px;
            padding: 15px;
           position: relative;
           top: 6em;
        }
        
        .filters-heading {
            color: <%=accent%>;
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 18px;
            font-weight: bold;
            border-bottom: 1px solid <%=accent%>;
            padding-bottom: 10px;
        }
        
        .filters-body label {
            color: <%=accent%>;
            margin-bottom: 5px;
            display: block;
            width: 100%;
            font-weight: 600;
        }
        
        .filters-body select {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid <%=accent%>;
            background-color: <%=sidebar%>;
            color: <%=text%>;
            font-size: 14px;
            width: 100%;
            margin-bottom: 15px;
            
        }
        
        .filters-body button {
            padding: 10px 15px;
            border: none;
            border-radius: 6px;
            background-color: <%=accent%>;
            color: white;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: all 0.3s ease;
            width: 100%;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .filters-body button:hover {
            background-color: <%=clr%>;
            color: <%=text%>;
            transform: translateY(-2px);
            
        }
        
        /* Legenda pentru statusuri */
        .legend-card {
            background-color: <%=sidebar%>;
            border-radius: 15px;
            padding: 15px;
            position: relative;
           top: 6em;
            
        }
        
        .legend-heading {
            color: <%=accent%>;
            margin-top: 0;
            margin-bottom: 15px;
            font-size: 18px;
            font-weight: bold;
            border-bottom: 1px solid <%=accent%>;
            padding-bottom: 10px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
        }
        
        .legend-color {
            width: 16px;
            height: 16px;
            margin-right: 10px;
            border-radius: 4px;
        }
        
        .legend-text {
            color: <%=text%>;
            font-size: 14px;
        }
        
        .user-info {
            padding: 15px;
            background-color: <%=sidebar%>;
            border-radius: 15px;
            margin-bottom: 20px;
            position: relative;
            top: 6em;
           
        }
        
        .user-info p {
            margin: 5px 0;
            color: <%=text%>;
        }
        
        .user-info strong {
            color: <%=accent%>;
        }
        
        .tentative-event {
            opacity: 0.7;
            border-style: dashed !important;
        }
        
        /* Stil pentru mesajul de eroare/debug */
        #debug-info {
            position: fixed;
            bottom: 10px;
            left: 10px;
            right: 10px;
            padding: 10px;
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
            display: none;
            z-index: 1000;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .main-container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                padding-right: 0;
                padding-bottom: 20px;
            }
            
            .content {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <!-- Sidebar cu filtre si informatii -->
        <div class="sidebar">
            <!-- Informatii despre utilizator -->
            <div class="user-info">
                <h3 style="margin-top: 0; color: <%=accent%>;">Informatii Utilizator</h3>
                <p><strong>Nume:</strong> <%=rs.getString("nume")%> <%=rs.getString("prenume")%></p>
                <p><strong>Functie:</strong> <%=functie%></p>
                <p><strong>Departament:</strong> <%=numeDepartament%></p>
                <% if (isDirector) { %>
                    <p><strong>Vizibilitate:</strong> Toate concediile</p>
                <% } else if (isSef) { %>
                    <p><strong>Vizibilitate:</strong> Concediile din departament</p>
                <% } else { %>
                    <p><strong>Vizibilitate:</strong> Doar concediile personale</p>
                <% } %>
            </div>
            
            <!-- Filtre pentru concedii -->
            <div class="filters-card">
                <h3 class="filters-heading">Filtrare Concedii</h3>
                <div class="filters-body">
                    <label for="leaveStatus">Status concedii:</label>
                    <select id="leaveStatus">
                        <option value="2">Aprobate de director</option>
                        <option value="1">Aprobate de sef</option>
                        <option value="0">Neaprobate</option>
                        <option value="-1">Respinse de sef</option>
                        <option value="-2">Respinse de director</option>
                        <option value="3" selected>Oricare</option>
                    </select>
                    
                    <% if (isDirector) { %>
                    <label for="departmentFilter">Departament:</label>
                    <select id="departmentFilter">
                        <option value="0" selected>Toate departamentele</option>
                        <%
                        // Listam toate departamentele pentru directori
                        try (PreparedStatement deptStmt = connection.prepareStatement("SELECT id_dep, nume_dep FROM departament ORDER BY nume_dep")) {
                            ResultSet deptRs = deptStmt.executeQuery();
                            while (deptRs.next()) {
                                int deptId = deptRs.getInt("id_dep");
                                String deptName = deptRs.getString("nume_dep");
                        %>
                            <option value="<%=deptId%>"><%=deptName%></option>
                        <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                    <% } %>
                    
                    <button id="applyFilters">Aplica filtre</button>
                </div>
            </div>
            
            <!-- Legenda pentru statusuri -->
            <div class="legend-card">
                <h3 class="legend-heading">Legenda Statusuri</h3>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #198754;"></div>
                    <span class="legend-text">Aprobat de director</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #0DCAF0;"></div>
                    <span class="legend-text">Aprobat de sef</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #FFC107;"></div>
                    <span class="legend-text">Neaprobat</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #FD7E14;"></div>
                    <span class="legend-text">Respins de sef</span>
                </div>
                <div class="legend-item">
                    <div class="legend-color" style="background-color: #DC3545;"></div>
                    <span class="legend-text">Respins de director</span>
                </div>
            </div>
        </div>
        
        <!-- Continut principal cu calendar -->
        <div class="content">
            <h1>Calendar Concedii</h1>
            <div id="calendar"></div>
        </div>
    </div>
    
    <!-- Container pentru informatii de debug -->
    <div id="debug-info"></div>
    
    <script>
        $(document).ready(function() {
            var userId = <%= userId %>;
            var isDirector = <%= isDirector %>;
            var isSef = <%= isSef %>;
            var departmentId = <%= idDepartament %>;
            var currentStatus = 3; // Valoarea implicita - toate statusurile
            var currentDepartment = 0; // Valoarea implicita - toate departamentele
            
            // Functie pentru reincarcarea calendarului cu filtrele selectate
            function reloadCalendar(status, departmentId) {
                $('#calendar').fullCalendar('destroy'); // Distruge vechiul calendar
                initCalendar(status, departmentId); // Initializeaza un nou calendar
            }
            
            // Functie pentru initializarea calendarului
            function initCalendar(status, departmentId) {
                var calendar = $('#calendar').fullCalendar({
                    header: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'month,agendaWeek,agendaDay,listMonth'
                    },
                    locale: 'ro', // Limba romana
                    buttonIcons: true,
                    weekNumbers: false,
                    navLinks: true,
                    editable: false,
                    eventLimit: true,
                    defaultView: 'month',
                    height: 'auto',
                    events: function(start, end, timezone, callback) {
                        // Afisam informatii in consola pentru debugging
                        console.log("Requesting events with filters - Status: " + status + ", Department: " + departmentId);
                        console.log("Date range: " + start.format() + " to " + end.format());
                        
                        $.ajax({
                            url: 'LeaveDataServlet',
                            type: 'POST',
                            dataType: 'json',
                            data: {
                                start: start.format(),
                                end: end.format(),
                                status: status,
                                department: departmentId
                            },
                            success: function(response) {
                                console.log("Received " + response.length + " events");
                                // Ascundem mesajul de eroare daca este vizibil
                                $('#debug-info').hide();
                                callback(response);
                            },
                            error: function(xhr, status, error) {
                                console.error('Error fetching events:', error);
                                // Afisam mesaj de eroare cu detalii pentru debugging
                                var errorText = "Eroare la incarcarea concediilor! ";
                                if (xhr.responseText) {
                                    try {
                                        var errorObj = JSON.parse(xhr.responseText);
                                        errorText += errorObj.error || xhr.responseText;
                                    } catch (e) {
                                        errorText += xhr.responseText;
                                    }
                                } else {
                                    errorText += error;
                                }
                                $('#debug-info').text(errorText).show();
                                callback([]); // Calendar gol in caz de eroare
                            }
                        });
                    },
                    eventRender: function(event, element) {
                        // Adauga tooltip cu informatii suplimentare
                        element.attr('title', event.description || 'Fara descriere');
                        
                        // Adauga clasa pentru evenimente tentative (neaprobate)
                        if (event.status === 'Neaprobat') {
                            element.addClass('tentative-event');
                        }
                    },
                    eventClick: function(event, jsEvent, view) {
                        // Afisam detalii despre eveniment la click
                        var title = event.title;
                        var start = moment(event.start).format('DD.MM.YYYY');
                        var end = event.end ? moment(event.end).format('DD.MM.YYYY') : start;
                        var description = event.description || 'Nespecificat';
                        var location = event.location || 'Nespecificata';
                        var status = event.status;
                        
                        alert('Concediu: ' + title + '\n' +
                              'Perioada: ' + start + ' - ' + end + '\n' +
                              'Motiv: ' + description + '\n' +
                              'Locatie: ' + location + '\n' +
                              'Status: ' + status);
                    }
                });
            }
            
            // Initializeaza calendarul cu valorile implicite
            initCalendar(currentStatus, currentDepartment);
            
            // Handler pentru butonul de aplicare a filtrelor
            $('#applyFilters').click(function() {
                var selectedStatus = $('#leaveStatus').val();
                console.log("Selected status: " + selectedStatus);
                currentStatus = selectedStatus;
                
                <% if (isDirector) { %>
                var selectedDepartment = $('#departmentFilter').val();
                console.log("Selected department: " + selectedDepartment);
                currentDepartment = selectedDepartment;
                <% } %>
                
                reloadCalendar(currentStatus, currentDepartment);
            });
        });
    </script>
</body>
</html>
<%
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            out.println("<script type='text/javascript'>alert('Database error!');</script>");
            response.sendRedirect("login.jsp");
        }
    } else {
        out.println("<script type='text/javascript'>alert('User not logged in!');</script>");
        response.sendRedirect("login.jsp");
    }
} else {
    out.println("<script type='text/javascript'>alert('No active session!');</script>");
    response.sendRedirect("login.jsp");
}
%>