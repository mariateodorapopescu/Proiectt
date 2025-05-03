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
    <title>Calendar View</title>
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
       .fc-day-number {
          color: <%=accent%> !important;
       }
    
       body {
          margin: 0;
          padding: 0;
          background-color: <%=sidebar%>;
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
    </style>
</head>
<body style="background:<%=clr%>">
    <!-- Selector pentru status concedii -->
    <div class="status-selector">
        <h4 style="color: <%=accent%>; margin-top: 0; margin-bottom: 10px;">Filtrare concedii</h4>
        <label for="leaveStatus" style="color: <%=accent%>; margin-bottom: 5px;">Status concedii:</label>
        <select id="leaveStatus" style="width: 100%; margin-bottom: 10px;">
            <option value="2" selected>Aprobate de director</option>
            <option value="1">Aprobate de sef</option>
            <option value="0">Neaprobate</option>
            <option value="-1">Respins sef</option>
            <option value="-2">Respins director</option>
             <option value="3">Oricare</option>
        </select>
        <button id="applyStatus" style="width: 100%;">Aplica</button>
    </div>
    
    <div style="position: fixed; top: 5rem; left:25%;" id='calendar'></div>
    <script>
        $(document).ready(function() {
            var currentStatus = 2; // Default status (aprobat de director)
            
            // Functie pentru reincarcarea calendarului cu statusul selectat
            function reloadCalendar(status) {
                $('#calendar').fullCalendar('destroy'); // Distruge vechiul calendar
                initCalendar(status); // Initializeaza un nou calendar
            }
            
            // Functie pentru initializarea calendarului
            function initCalendar(status) {
                var calendar = $('#calendar').fullCalendar({
                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,timeGridWeek,timeGridDay,listMonth'
                    },
                    locale: 'ro', // Romanian language
                    buttonIcons: true,
                    weekNumbers: false,
                    navLinks: true,
                    editable: true,
                    dayMaxEvents: true,
                    defaultView: 'month',
                    dayRender: function(date, cell) {
                        var today = $.fullCalendar.moment();
                        if(date.get('date') == today.get('date')) {
                           cell.css("textColor", "white");
                        }
                    },
                    selectable: true,
                    selectHelper: true,
    
                    dayClick: function (date, jsEvent, view) {
                        //var D = moment(date);
                        t.row.add([
                            counter,
                            date.format('dddd,MMMM DD,YYYY'),
                            'testing'
                        ]).draw(false);
    
                        counter++;
    
                        cell.css("background-color", "teal");
                    },
                    
                    dayRender: function(date, cell) { 
                        var today = $.fullCalendar.moment(); 
                        var end = $.fullCalendar.moment().add(7, 'days'); 
                        if (date.get('date') == today.get('date')) { 
                            $(".fc-"+date.format('ddd').toLowerCase()).css("background", "#f8f9fa"); 
                            $("th.fc-"+date.format('ddd').toLowerCase()).text("Holiday"); 
                            $("th.fc-"+date.format('ddd').toLowerCase()).css("background", "red"); 
                            $("th.fc-"+date.format('ddd').toLowerCase()).css("color", "#fff"); 
                        } 
                    },
                        
                    events: function(start, end, timezone, callback) {
                        $.ajax({
                            url: 'decenulvede',
                            type: 'POST',
                            dataType: 'json',
                            data: {
                                start: start.format(),
                                end: end.format(),
                                status: status // Adaugam parametrul de status
                            },
                            success: function(response) {
                                callback(response);
                            },
                            error: function() {
                                alert('There was an error while fetching events!');
                            }
                        });
                    }
                });
            }
            
            // Initializeaza calendarul cu statusul implicit
            initCalendar(currentStatus);
            
            // Handler pentru butonul de aplicare a statusului
            $('#applyStatus').click(function() {
                var selectedStatus = $('#leaveStatus').val();
                currentStatus = selectedStatus;
                reloadCalendar(selectedStatus);
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