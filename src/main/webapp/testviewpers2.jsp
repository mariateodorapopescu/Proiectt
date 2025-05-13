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
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                String functie = rs.getString("functie");
                int ierarhie = rs.getInt("ierarhie");

                // Funcție helper pentru a determina rolul utilizatorului
                boolean isDirector = (ierarhie < 3);
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
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.css"/>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/locale-all.js"></script>
     <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
     @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
       .fc-day-number {
          color: <%=accent%> !important;
       }
    
       body {
          margin: 0;
          padding: 0;
          background-color: <%=sidebar%>;
          font-family: 'Poppins', sans-serif;
       }
       
       #calendar {
          max-width: 700px;
          max-height: 700px;
          padding: 0;
          margin: 20px auto;
          text: <%=accent%>; !important;
          color: <%=accent%>; !important;
       }
        
       table, 
       td,
       thead,
       tbody,
       .fc-row, .fc-column {
          border-color: <%=clr%> !important;
          background: <%=sidebar%> !important;
          text: <%=accent%>; !important;
          color: <%=accent%>; !important;
       }
		
       th, hr {
          border-color: <%=accent%> !important;
          background: <%=accent%> !important;
          color: white;
       }
       
       /* Stiluri pentru selectorul de status */
       .status-selector {
          position: fixed;
          top: 12rem;
          left: 3%;
          width: 220px;
          padding: 15px;
          background-color: <%=sidebar%>;
          border-radius: 15px;
          margin-bottom: 10px;
          display: flex;
          flex-direction: column;
          justify-content: flex-start;
          align-items: flex-start;
          gap: 15px;
          z-index: 100;
        
       }
       
       .status-selector select {
          padding: 8px;
          border-radius: 4px;
          border: 1px solid <%=accent%>;
          background-color: <%=sidebar%>;
          color: <%=accent%>;
          font-size: 14px;
          width: 100%;
       }
       
       .status-selector button {
          padding: 8px 15px;
          border: none;
          border-radius: 4px;
          background-color: <%=accent%>;
          color: white;
          cursor: pointer;
          font-size: 14px;
          transition: background-color 0.3s;
          width: 100%;
       }
       
       .status-selector button:hover {
          background-color: <%=clr%>;
          color: <%=text%>;
          text-decoration: underline;
       }
       
       .legend {
          position: fixed;
          top: 2rem;
          right: 5%;
          padding: 10px;
          background-color: <%=sidebar%>;
          border-radius: 5px;
          box-shadow: 0 2px 5px rgba(0,0,0,0.1);
       }
       
       .legend-item {
          display: flex;
          align-items: center;
          margin-bottom: 5px;
       }
       
       .legend-color {
          width: 15px;
          height: 15px;
          margin-right: 5px;
          border-radius: 50%;
       }
       
       /* Adăugăm stil pentru mesajul de eroare/debugging */
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
    </style>
</head>
<body style="background:<%=clr%>">
    <!-- Selector pentru status concedii -->
    <div class="status-selector">
        <h4 style="color: <%=accent%>; margin-top: 0; margin-bottom: 10px;">Filtrare concedii</h4>
        <label for="leaveStatus" style="color: <%=accent%>; margin-bottom: 5px;">Status concedii:</label>
        <select id="leaveStatus" style="width: 100%; margin-bottom: 10px;">
            <option value="2">Aprobate de director</option>
            <option value="1">Aprobate de sef</option>
            <option value="0">Neaprobate</option>
            <option value="-1">Respins sef</option>
            <option value="-2">Respins director</option>
            <option value="3" selected>Oricare</option>
        </select>
        <button id="applyStatus" style="width: 100%;">Aplica</button>
    </div>
    
    <!-- Container pentru calendar -->
    <div style="position: fixed; top: 5rem; left:25%;" id='calendar'></div>
    
    <!-- Div pentru afișarea informațiilor de debug în caz de eroare -->
    <div id="debug-info"></div>
    
    <script>
        $(document).ready(function() {
            var currentStatus = 3; // Valoarea implicită - toate statusurile
            
            // Funcție pentru reîncărcarea calendarului cu statusul selectat
            function reloadCalendar(status) {
                $('#calendar').fullCalendar('destroy'); // Distruge vechiul calendar
                initCalendar(status); // Inițializează un nou calendar
            }
            
            // Funcție pentru inițializarea calendarului
            function initCalendar(status) {
                var calendar = $('#calendar').fullCalendar({
                    header: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'month,agendaWeek,agendaDay,listMonth'
                    },
                    locale: 'ro', // Romanian language
                    buttonIcons: true,
                    weekNumbers: false,
                    navLinks: true,
                    editable: false,
                    eventLimit: true,
                    defaultView: 'month',
                    events: function(start, end, timezone, callback) {
                        // Afișăm informații în consola de dezvoltator pentru debugging
                        console.log("Requesting events with status: " + status);
                        console.log("Date range: " + start.format() + " to " + end.format());
                        
                        $.ajax({
                            url: 'decenulvede',
                            type: 'POST',
                            dataType: 'json',
                            data: {
                                start: start.format(),
                                end: end.format(),
                                status: status
                            },
                            success: function(response) {
                                console.log("Received " + response.length + " events");
                                // Ascundem mesajul de eroare dacă este vizibil
                                $('#debug-info').hide();
                                callback(response);
                            },
                            error: function(xhr, status, error) {
                                console.error('Error fetching events:', error);
                                // Afișăm mesaj de eroare cu detalii pentru debugging
                                var errorText = "Eroare la încărcarea concediilor! ";
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
                                callback([]); // Calendar gol în caz de eroare
                            }
                        });
                    },
                    eventRender: function(event, element) {
                        // Adăugă tooltip cu informații suplimentare
                        element.attr('title', event.description || 'Fără descriere');
                        
                        // Adăugă clasa pentru evenimente tentative (neaprobate)
                        if (event.status === 'Neaprobat') {
                            element.addClass('tentative-event');
                        }
                    },
                    eventClick: function(event, jsEvent, view) {
                        // Afișăm informații despre eveniment la click
                        alert('Concediu: ' + event.title + '\n' +
                              'Perioada: ' + moment(event.start).format('DD.MM.YYYY') + ' - ' + 
                                          moment(event.end || event.start).format('DD.MM.YYYY') + '\n' +
                              'Motiv: ' + (event.description || 'Nespecificat') + '\n' +
                              'Locație: ' + (event.location || 'Nespecificată') + '\n' +
                              'Status: ' + event.status);
                    }
                });
            }
            
            // Inițializează calendarul cu statusul implicit
            initCalendar(currentStatus);
            
            // Handler pentru butonul de aplicare a statusului
            $('#applyStatus').click(function() {
                var selectedStatus = $('#leaveStatus').val();
                console.log("Selected status: " + selectedStatus);
                currentStatus = selectedStatus;
                reloadCalendar(selectedStatus);
            });
        });
    </script>
    
    <!-- Include Bootstrap JS -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
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