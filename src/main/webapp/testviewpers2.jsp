<%@ page import="java.io.*, java.util.*, java.sql.*, bean.MyUser, jakarta.servlet.http.*" %>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                if (userType == 4) {
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
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <style>
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
           
        }
        
		table, 
		td,
		thead,
		tbody,
		.fc-row {
			border-color: <%=clr%> !important;
			background: <%=sidebar%> !important;
			text: <%=accent%>; !important;
		}
		
		th, hr{
			border-color: <%=accent%> !important;
			background: <%=accent%> !important;
			color: white;
		}
		
    </style>
</head>
<body>
    <div id='calendar'></div>
    <script>
        $(document).ready(function() {
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
                dayRender: function(date, cell)
                {
                var today = $.fullCalendar.moment();
                if(date.get('date')==today.get('date'))
                {
                   // cell.css("background", "rgb(52, 140, 235)");
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
                	if (date.get('date') == today.get('date')) { $(".fc-"+date.format('ddd').toLowerCase()).css("background", "#f8f9fa"); 
                	$("th.fc-"+date.format('ddd').toLowerCase()).text("Holiday"); 
                	$("th.fc-"+date.format('ddd').toLowerCase()).css("background", "red"); 
                	$("th.fc-"+date.format('ddd').toLowerCase()).css("color", "#fff"); } },
                	
                events: function(start, end, timezone, callback) {
                    $.ajax({
                    	url: 'decenulvede',
                        type: 'POST',
                        dataType: 'json',
                        data: {
                            start: start.format(),
                            end: end.format()
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
