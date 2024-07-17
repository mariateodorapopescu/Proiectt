<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<!DOCTYPE html>  
<html>  
<head>  
    <title>Adaugare concediu</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .container {
            width: 90%;
            max-width: 800px;
            margin: 20px auto;
            padding: 20px;
            background-color: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        .calendar-container {
            margin-top: 30px;
        }
        h1 {
            text-align: center;
            margin-bottom: 20px;
        }
        table.calendar {
            width: 100%;
            border-collapse: collapse;
        }
        th.calendar, td.calendar {
            border: 1px solid #ddd;
            text-align: center;
            padding: 8px;
            font-size: 12px;
        }
        th.calendar {
            background-color: #f2f2f2;
        }
        .navigation {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .month-year {
            font-size: 1.2em;
        }
        .navigation button {
            font-size: 1em;
            padding: 5px;
        }
        .highlight {
            background-color: green;
            color: white;
        }
        #difference {
            text-align: center;
            font-size: 1em;
            margin-top: 10px;
        }
        button {
            display: block;
            margin: 20px auto;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
        @media (max-width: 400px) {
            .container {
                width: 95%;
                padding: 10px;
            }
            th.calendar, td.calendar {
                padding: 4px;
                font-size: 10px;
            }
            .month-year {
                font-size: 1em;
            }
            .navigation button {
                font-size: 0.8em;
                padding: 3px;
            }
            button {
                font-size: 14px;
                padding: 8px 16px;
            }
        }
    </style>
</head>
<body>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip, zileramase, conramase FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    String zile = rs.getString("zileramase");
                    String con = rs.getString("conramase");
                    
                    // Allow only non-admin users to access this page
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }
                    out.println("<p>Zile ramase: " + zile + "</p>");
                    out.println("<p>Concedii ramase: " + con + "</p><br>");
                    out.println("<div align='center'>");
                    out.println("<h1>Adaugare concediu</h1>");
                    out.print("<form action='");
                    out.print(request.getContextPath());
                    out.println("/addcon' method='post'>");
                    out.println("<table>");
                    out.println("<tr>");
                    out.println("<td>Data de plecare</td>");
                    out.println("<td><input type='date' id='start' name='start' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/></td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Data de intoarcere</td>");
                    out.println("<td><input type='date' id='end' name='end' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/></td>");
                    out.println("</tr>");
                    out.println("<tr>");
                    out.println("<td>Motiv</td>");
                    out.println("<td><input type='text' name='motiv' required/></td>");
                    out.println("</tr>");
                    out.println("<tr><td>Tip</td>");
                    out.println("<td><select name='tip'>");
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int tip = rs1.getInt("tip");
                            String motiv = rs1.getString("motiv");
                            out.println("<option value='" + tip + "'>" + motiv + "</option>");
                        }
                    }
                    out.println("</select></td></tr>");
                    out.println("<tr>");
                    out.println("<td>Locatie</td>");
                    out.println("<td><input type='text' name='locatie' required/></td>");
                    out.println("</tr>");
                    out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                    out.println("</table>");
                    out.println("<input type='submit' value='Submit' />");
                    out.println("</form>");
                    %>
                    
                    
<div class="container calendar-container">
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
     <!-- <div id="difference">0</div> --> 
</div>
                    
                    <% 
                  
                    out.println("</div>");
                    if (userType >= 0 && userType <= 3) {
                        out.println("<a href='dashboard.jsp'>Inapoi</a>");
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
        document.addEventListener("DOMContentLoaded", function() {
            var dp1 = document.getElementById("start");
            var dp2 = document.getElementById("end");

            if (dp1) {
                dp1.addEventListener("change", function() {
                    console.log('New Start Date:', dp1.value);
                    // Set the minimum date for dp2
                    dp2.min = dp1.value;
                    if (dp2.value < dp1.value) {
                        dp2.value = ''; // Reset dp2 if it's less than dp1
                    }
                });
            }

            if (dp2) {
                dp2.addEventListener("change", function() {
                    if (dp2.value < dp1.value) {
                        alert("Data de final nu poate fi mai mică decât cea de început!");
                        dp2.value = dp1.value; // Optional: automatically adjust dp2 to match dp1
                    }
                    console.log('New End Date:', dp2.value);
                });
            }
        });
    </script>
<script>
    let today = new Date();
    let currentMonth = today.getMonth();
    let currentYear = today.getFullYear();
    let selectedStartDate = null;
    let selectedEndDate = null;

    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.",
        "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];

    function generateCalendar(month, year) {
        let firstDay = (new Date(year, month)).getDay();
        let daysInMonth = 32 - new Date(year, month, 32).getDate();
        let tbl = document.getElementById("calendar-body");
        tbl.innerHTML = "";

        document.getElementById("monthYear").innerHTML = monthNames[month] + " " + year;

        firstDay = (firstDay === 0) ? 6 : firstDay - 1;  // Monday-based adjustment

        let date = 1;
        for (let i = 0; i < 6; i++) {
            let row = document.createElement("tr");
            for (let j = 0; j < 7; j++) {
                if (i === 0 && j < firstDay) {
                    let cell = document.createElement("td");
                    let cellText = document.createTextNode("");
                    cell.appendChild(cellText);
                    row.appendChild(cell);
                } else if (date > daysInMonth) {
                    break;
                } else {
                    let cell = document.createElement("td");
                    let cellText = document.createTextNode(date);
                    cell.appendChild(cellText);
                    if (selectedStartDate && selectedEndDate && isDateInRange(date, month, year)) {
                        cell.classList.add('highlight');
                    }
                    row.appendChild(cell);
                    date++;
                }
            }
            tbl.appendChild(row);
        }
    }

    function isDateInRange(day, month, year) {
        let date = new Date(year, month, day);
        date.setHours(0, 0, 0, 0);
        return date >= selectedStartDate && date <= selectedEndDate;
    }

    function highlightDate() {
        const startDatePicker = document.getElementById('start');
        const endDatePicker = document.getElementById('end');
        selectedStartDate = startDatePicker.value ? new Date(startDatePicker.value) : null;
        selectedEndDate = endDatePicker.value ? new Date(endDatePicker.value) : null;

        if (selectedStartDate) {
            selectedStartDate.setHours(0, 0, 0, 0);
            currentMonth = selectedStartDate.getMonth();  // Update current month to selected start date's month
            currentYear = selectedStartDate.getFullYear(); // Update current year
        }

        if (selectedEndDate) {
            selectedEndDate.setHours(23, 59, 59, 999);
            if (selectedEndDate < selectedStartDate) {
                endDatePicker.value = startDatePicker.value;
                selectedEndDate = new Date(selectedStartDate);
                selectedEndDate.setHours(23, 59, 59, 999);
            }
        }

        generateCalendar(currentMonth, currentYear);
    }

    function previousMonth() {
        currentMonth = (currentMonth === 0) ? 11 : currentMonth - 1;
        currentYear = (currentMonth === 11) ? currentYear + 1 : currentYear;
        generateCalendar(currentMonth, currentYear);
    }

    function nextMonth() {
        currentMonth = (currentMonth + 1) % 12;
        currentYear = (currentMonth === 0) ? currentYear + 1 : currentYear;
        generateCalendar(currentMonth, currentYear);
    }

    document.addEventListener('DOMContentLoaded', function() {
        generateCalendar(currentMonth, currentYear);
        document.getElementById('start').addEventListener('change', highlightDate);
        document.getElementById('end').addEventListener('change', highlightDate);
    });
</script>

</body>
</html>
