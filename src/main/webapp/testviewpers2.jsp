<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.io.*" %>  
<%@ page import="java.util.*" %>  
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Test</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <style>
    .leave-1 { background-color: #90ee90; } /* Light green for 1 person */
    .leave-2 { background-color: #ffff99; } /* Yellow for 2 people */
    .leave-3 { background-color: #ffcc99; } /* Orange for 3 people */
    .leave-more { background-color: #ff6666; } /* Red for more than 3 people */
    /* Tooltip container */
.tooltip {
  position: relative;
  display: inline-block;
  border-bottom: 1px dotted black; /* If you want dots under the hoverable text */
}

/* Tooltip text */
.tooltip .tooltiptext {
  visibility: hidden;
  width: 120px;
  background-color: rgba(0,0,0,0.5);
  color: white;
  text-align: center;
  padding: 5px 0;
  border-radius: 6px;
 
  /* Position the tooltip text - see examples below! */
  position: absolute;
  z-index: 1;
}

/* Show the tooltip text when you mouse over the tooltip container */
.tooltip:hover .tooltiptext {
  visibility: visible;
}
</style>
</style>
    
</head>
<body>

<div class="container calendar-container">
<div class="ceva tooltip">Legenda
  <span class="ceva tooltiptext">transparent = 0;<br> verde = 1; <br>galben = 2; <br>portocaliu = 3; <br>rosu = >3 </span>
</div>
    <div class="navigation">
    
        <button onclick="previousMonth()">❮</button>
        <div class="month-year" id="monthYear"></div>
        
        <button onclick="nextMonth()">❯</button>
    </div>
    <table class="calendar" id="calendar">
        <thead>
            <tr>
                <th class="calendar">Lu.</th>
                <th class="calendar">Ma.</th>
                <th class="calendar">Mi.</th>
                <th class="calendar">Jo.</th>
                <th class="calendar">Vi.</th>
                <th class="calendar">Sâ.</th>
                <th class="calendar">Du.</th>
            </tr>
        </thead>
        <tbody class="calendar" id="calendar-body">
            <!-- Calendar will be generated here -->
        </tbody>
    </table>
</div>
<form id="dateForm" action="testviewpers2.jsp" method="post" style="display:none;">
    <input type="date" name="selectedDate" id="selectedDate">
</form>
<script src="./responsive-login-form-main/assets/js/calendar3.js"></script>
<script>


    document.addEventListener('DOMContentLoaded', (event) => {
        // Add event listener for all calendar cells
        document.getElementById('calendar-body').addEventListener('click', function(e) {
            if (e.target && e.target.nodeName === 'TD') {
                let selectedDate = e.target.getAttribute('data-date');
                if (selectedDate) {
                    document.getElementById('selectedDate').value = selectedDate;
                    document.getElementById('dateForm').submit();
                }
            }
        });
    });
    
    
    
</script>
<%
Map<String, ArrayList<String>> persoane = new HashMap<>();  

%>
<script>
    var leaveData = {
        <% for (Map.Entry<String, ArrayList<String>> entry : persoane.entrySet()) { %>
            "<%= entry.getKey() %>": <%= entry.getValue().size() %>,
        <% } %>
    };
</script>

<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        		PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
				int userDep = rs.getInt("id_dep");
                if (userType == 4) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }
            
                String data = null;
                
                data = request.getParameter("selectedDate");
               
               String nume = null;
               String prenume = null;
               String fullnume = null;
               int nr = 0;
            
                 int year = request.getParameter("year") != null ? Integer.parseInt(request.getParameter("year")) : Calendar.getInstance().get(Calendar.YEAR);
               int month = request.getParameter("month") != null ? Integer.parseInt(request.getParameter("month")) - 1 : Calendar.getInstance().get(Calendar.MONTH);
				month++;
              
               Calendar calendar = Calendar.getInstance();
               calendar.set(Calendar.MONTH, month);
               calendar.set(Calendar.YEAR, calendar.get(Calendar.YEAR));
               calendar.set(Calendar.DAY_OF_MONTH, 1);

               Map<String, List<String>> leaveDataByDate = new TreeMap<>();
             
              
               try (PreparedStatement stmt = connection.prepareStatement(
                       "SELECT nume, prenume, start_c, end_c FROM useri JOIN concedii ON useri.id = concedii.id_ang WHERE (MONTH(start_c) = ? OR MONTH(end_c) = ?) AND YEAR(start_c) = ? and useri.id_dep = ?")) {
                   stmt.setInt(1, month);
                   stmt.setInt(2, month);
                   stmt.setInt(3, calendar.get(Calendar.YEAR));
                   stmt.setInt(4, userDep);
                   ResultSet rs1 = stmt.executeQuery();
                   
                   while (rs1.next()) {
                       nume = rs1.getString("nume");
                       prenume = rs1.getString("prenume");
                       fullnume = nume + " " + prenume;

                       LocalDate startDate = rs1.getDate("start_c").toLocalDate();
                       LocalDate endDate = rs1.getDate("end_c").toLocalDate();

                       LocalDate currentDate = startDate;

                       while (!currentDate.isAfter(endDate)) {
                           String dateKey = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
                           leaveDataByDate.computeIfAbsent(dateKey, k -> new ArrayList<>()).add(fullnume);
                           currentDate = currentDate.plusDays(1);
                       }
                   }
               }
            // Serializarea datelor în JSON
               StringBuilder jsonBuilder = new StringBuilder("{");
               boolean firstEntry = true;
               for (Map.Entry<String, List<String>> entry : leaveDataByDate.entrySet()) {
                   if (!firstEntry) jsonBuilder.append(",");
                   jsonBuilder.append("\"").append(entry.getKey()).append("\":").append(entry.getValue().size());
                   firstEntry = false;
               }
               jsonBuilder.append("}");
               String jsonData = jsonBuilder.toString();
%>
<script>
    var jsonData = <%= jsonData %>;
    console.log(jsonData); // Verifică în consola browserului
</script>
<%
               // Afișare date în format JSON pentru debug
               // System.out.println("JSON Data: " + jsonData);
            
                 
               try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume FROM useri JOIN concedii ON useri.id = concedii.id_ang WHERE start_c <= ? AND end_c >= ?")) {
                   stmt.setString(1, data);
                   stmt.setString(2, data);
                   ResultSet rs1 = stmt.executeQuery();
                   while (rs1.next()) {
                   	
                       nume = rs1.getString("nume");
                       prenume = rs1.getString("prenume");
                       fullnume = nume + " " + prenume;
                       if (persoane.get(data)==null) {
                       	persoane.put(data, new ArrayList<>(Arrays.asList(fullnume)));
                       } else {
                       	persoane.get(data).add(fullnume);
                       }
                   }
               }
              
               for (String date : persoane.keySet()) {
               	
               	nr = persoane.get(date).size();
               	
               }

               out.println("<h2>Persoane (in numar de " + nr + ") in concediu pe data de " + data + ":</h2>");
               if (persoane.isEmpty()) {
                   out.println("<p>Nu exista persoane in concediu pe aceasta data.</p>");
               } else {
                   out.println("<ul>");
                   for (String persoana : persoane.get(data)) {
                       out.println("<li>" + persoana + "</li>");
                   }
                   out.println("</ul>");
               }
               
                
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
                out.println("Nu exista date.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la baza de date!');");
            out.println("</script>");
            response.sendRedirect("login.jsp");
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
<script>
document.addEventListener('DOMContentLoaded', () => {
    const monthYear = document.getElementById('monthYear');
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();
    
    // Funcție pentru actualizarea datelor afișate pe calendar
    function updateCalendarDisplay() {
        monthYear.textContent = getMonthName(currentMonth) + " " + currentYear;
        fetchCalendarData(currentMonth, currentYear);
    }
    
    // Obținerea numelui lunii
    function getMonthName(monthIndex) {
        const monthNames = ["Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie",
                            "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"];
        return monthNames[monthIndex];
    }
    
    // Solicitarea AJAX pentru actualizarea calendarului
    function fetchCalendarData(month, year) {
        fetch(testviewpers2.jsp?month=${month+1}&year=${year})
            .then(response => response.text())
            .then(html => {
                document.getElementById('calendar-body').innerHTML = html;
            })
            .catch(error => console.error('Error fetching data:', error));
    }
    
    // Navigare luni anterioare
    document.getElementById('prevMonth').addEventListener('click', () => {
        if (currentMonth === 0) {
            currentMonth = 11;
            currentYear--;
        } else {
            currentMonth--;
        }
        updateCalendarDisplay();
    });

    // Navigare luni următoare
    document.getElementById('nextMonth').addEventListener('click', () => {
        if (currentMonth === 11) {
            currentMonth = 0;
            currentYear++;
        } else {
            currentMonth++;
        }
        updateCalendarDisplay();
    });

    updateCalendarDisplay(); // Apel inițial pentru a încărca calendarul
});
</script>
</body>
</html>