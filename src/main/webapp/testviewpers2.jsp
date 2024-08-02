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
    <title>Fullcalendar Integration</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"/> 
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.18.1/moment.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.4.0/fullcalendar.min.js"></script> 
     <script src="https://cdn.zingchart.com/zingchart.min.js"></script>
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     <script type="text/javascript" src="https://cdn.zingchart.com/zingchart.min.js"></script>
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
            background: <%=sidebar%>;
        }
        .container {
            width: 100%;
            max-width: 500px;
            margin: 0 auto;
            padding: 0;
            background: <%=sidebar%>
        }
        h1, h3 {
            text-align: center;
            padding: 0; 
            margin: 0; 
            top: -10%; 
            color: <%=accent%>
        }
        #myChart {
            width: 100%;
            height: 900px;
        }
    </style>
</head>
<body>
    <h2 style="color:<%=accent%>"><center>Calendar</center></h2>
    <div class="container">
        <div style="color:<%=text%>" id="calendar"></div>
    </div>
</body>
</html>

<script>
    $(document).ready(function() {
        $('#calendar').fullCalendar({
        	locale: 'ro',
            events: function(start, end, timezone, callback) {
                $.ajax({
                    url: 'decenulvede',
                    type: 'POST',
                    dataType: 'json', // Ensure that response is expected to be JSON
                    data: {
                        start: start.format(),
                        end: end.format()
                    },
                    success: function(events) {
                        // Assuming 'events' is an array of event objects in the correct format
                        callback(events);
                    },
                    error: function(xhr, status, error) {
                        console.error("Error fetching events: " + xhr.status + " " + error);
                    }
                });
               
            },
            header:
            {
            left: 'month, agendaWeek, agendaDay, list',
            center: 'title',
            right: 'prev, today, next'
            },
            buttonText:
            {
            today: 'Today',
            month: 'Month',
            week: 'Week',
            day: 'Day',
            list: 'List'
            },
            
       	 selectable: true,
            selectHelper: true,
            select: function()
            {
                $('#myModal').modal('toggle');
            },
            header:
            {
            left: 'month, agendaWeek, agendaDay, list',
            center: 'title',
            right: 'prev, today, next'
            },
            buttonText:
            {
            today: 'Today',
            month: 'Month',
            week: 'Week',
            day: 'Day',
            list: 'List'
            }
        
        });
    });
</script>
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