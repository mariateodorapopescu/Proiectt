<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select * from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int id = rs.getInt("id");
                    int userType = rs.getInt("tip");
                   // String zile = rs.getString("zileramase");
                    //System.out.println(zile);
                   //  String con = rs.getString("conramase");
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp"); 
                        
                    } else {
                    	 String accent = null;
                      	 String clr = null;
                      	 String sidebar = null;
                      	 String text = null;
                      	 String card = null;
                      	 String hover = null;
                      	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT * from teme where id_usr = ?";
                             try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 stmt.setInt(1, id);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next()) {
                                       accent =  rs2.getString("accent");
                                       clr =  rs2.getString("clr");
                                       sidebar =  rs2.getString("sidebar");
                                       text = rs2.getString("text");
                                       card =  rs2.getString("card");
                                       hover = rs2.getString("hover");
                                     }
                                 }
                             }
                             
                            
                             // Display the user dashboard or related information
                             //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                             // Add additional user-specific content here
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                      	 
                        %>
<html>
<head>
    <title>Adaugare concediu</title>
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
        .flex-container {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            gap: 2rem;
            margin: 2rem;
        }
        
        .calendar-container, .form-container {
            background-color: #2a2a2a;
            padding: 1rem;
            border-radius: 8px;
           
        }
        
        .calendar-container {
            max-width: 300px;
        }
         th.calendar, td.calendar {
            border: 1px solid #1a1a1a;
            text-align: center;
            padding: 8px;
            font-size: 12px;
        }
        th.calendar {
            background-color: #333;
        }
        .highlight {
            /*background-color: #32a852;*/
            color: white;
        }
        :root{
          --first-color: #2a2a2a;
  --second-color: hsl(249, 64%, 47%);
  --title-color-light: hsl(244, 12%, 12%);
  --text-color-light: hsl(244, 4%, 36%);
  --body-color-light: hsl(208, 97%, 85%);
  --title-color-dark: hsl(0, 0%, 95%);
  --text-color-dark: hsl(0, 0%, 80%);
  --body-color-dark: #1a1a1a;
  --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
  --form-border-color-light: hsla(244, 16%, 92%, 0.75);
  --form-bg-color-dark: #333;
  --form-border-color-dark: #3a3a3a;
  /*========== Font and typography ==========*/
  --body-font: "Poppins", sans-serif;
  --h2-font-size: 1.25rem;
  --small-font-size: .813rem;
  --smaller-font-size: .75rem;
  /*========== Font weight ==========*/
  --font-medium: 500;
  --font-semi-bold: 600;
        }
        
        ::placeholder {
  color: var(--text);
  opacity: 1; /* Firefox */
}

::-ms-input-placeholder { /* Edge 12-18 */
  color: var(--text);
}
        @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">


                        <div class="flex-container">
                            <div class="calendar-container" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" class="calendar">
                                <div class="navigation">
                                    <button class='prev' onclick="previousMonth()">❮</button>
                                    <div class="month-year" id="monthYear"></div>
                                    <button class='next' onclick="nextMonth()">❯</button>
                                </div>
                                <table class="calendar" id="calendar">
                                    <thead >
                                        <tr >
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar">Lu.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Ma.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Mi.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Jo.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Vi.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Sâ.</th>
                                            <th style="background:<%out.println(accent);%>; color:<%out.println("white");%>" class="calendar" class="calendar">Du.</th>
                                        </tr>
                                    </thead>
                                    <tbody class="calendar" id="calendar-body" style="background:<%out.println(clr);%>; color:<%out.println(text);%>">
                                        <!-- Calendar will be generated here -->
                                    </tbody>
                                </table>
                                
                            </div>
                            <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
                         
    
                                <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/addcon" method="post" class="login__form">
                                    <div>
                                        <h1 style=" color:<%out.println(accent);%>" class="login__title"><span style=" color:<%out.println(accent);%>">Adaugare concediu</span></h1>
                                        <%
                                        //out.println("<p style='margin:0; padding:0; position:relative; top:0;'>Zile ramase: " + zile + "; Concedii ramase: " + con + "</p>");
                                        %>
                                    </div>
                                    
                                    <div class="login__inputs" style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>">
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Data plecare</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" class="login__input" type='date' id='start' name='start' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/>
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Data sosire</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" class="login__input" type='date' id='end' name='end' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/>
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Motiv</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti motivul" required class="login__input" name='motiv'/>
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Tip concediu</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name='tip' class="login__input">
                                            <%
                                            try (PreparedStatement stmt = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                                                ResultSet rs1 = stmt.executeQuery();
                                                while (rs1.next()) {
                                                    int tip = rs1.getInt("tip");
                                                    String motiv = rs1.getString("motiv");
                                                    out.println("<option value='" + tip + "'>" + motiv + "</option>");
                                                }
                                            }
                                            out.println("</select></div>");
                                            %>
                                            <div>
                                                <label style=" color:<%out.println(text);%>" class="login__label">Locatie</label>
                                                <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti locatia" required class="login__input" name='locatie'/>
                                            </div>
                                        </div>
                                       <% out.println("<input type='hidden' name='userId' value='" + id + "'/>"); %> 
                                        <%  out.println("            <a href=\"actiuni.jsp\" style=\"color:" + accent + "\" class=\"login__forgot\">Inapoi</a>"); %>
                                        <div class="login__buttons">
                                            <input style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" type="submit" value="Adaugare" class="login__button">
                                        </div>
                                    </form>
                                    <%
                                    out.println("</div>");
                                    
                                    %>
                                </div>
                               
                            </div>
                        </div>
                        <%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                    response.sendRedirect("addc.jsp");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("</script>");
                response.sendRedirect("addc.jsp");
            }
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("</script>");
            response.sendRedirect("logout");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
<script>
document.addEventListener("DOMContentLoaded", function() {
    const dp1 = document.getElementById("start");
    const dp2 = document.getElementById("end");
    const calendarBody = document.getElementById('calendar-body');
    const monthYear = document.getElementById('monthYear');
    const prevButton = document.querySelector('.prev');
    const nextButton = document.querySelector('.next');
    const bg = "#32a852"; // Background color for highlighted dates
    const defaultBg = ""; // Default background color for non-selected dates
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();
    const monthNames = ["Ian.", "Feb.", "Mar.", "Apr.", "Mai", "Iun.", "Iul.", "Aug.", "Sep.", "Oct.", "Nov.", "Dec."];
    var clickCount = 0; // Track the number of clicks

    calendarBody.addEventListener('click', function(event) {
        if (event.target.tagName === 'TD' && event.target.getAttribute('data-date')) {
        	clickCount++;
            handleDateClick(event.target.getAttribute('data-date'));
            
        }
    });

    function handleDateClick(clickedDate) {
    	if (dp1.value != '')
    	{ dp2.value = clickedDate;
            //dp2.value='';
        } else {
            
                dp1.value = clickedDate;
            dp2.value='';
        }
        updateCalendarToSelectedDate(new Date(clickedDate));
        highlightDates();
    }

    function updateCalendarToSelectedDate(date) {
        currentYear = date.getFullYear();
        currentMonth = date.getMonth();
        renderCalendar(currentMonth, currentYear);
    }

    function highlightDates() {
        const startDate = dp1.value ? new Date(dp1.value) : '';
        const endDate = dp2.value ? new Date(dp2.value) : '';
        Array.from(calendarBody.querySelectorAll('td[data-date]')).forEach(td => {
            const currentDate = new Date(td.getAttribute('data-date'));
            td.classList.remove('highlight');
            td.style.backgroundColor = defaultBg; // Reset to default background color
            if (startDate && currentDate >= startDate && (!endDate || currentDate <= endDate)) {
                td.classList.add('highlight');
                td.style.backgroundColor = bg;
            }
        });
    }

    function renderCalendar(month, year) {
        let firstDay = new Date(year, month).getDay();
        calendarBody.innerHTML = ''; // Clear previous cells
        monthYear.textContent = monthNames[month] + ' ' + year; // Set the current month and year

        let date = 1;
        for (let i = 0; i < 6; i++) {
            let row = document.createElement('tr');
            for (let j = 0; j < 7; j++) {
                let cell = document.createElement('td');
                if (i === 0 && j < firstDay || date > new Date(year, month + 1, 0).getDate()) {
                    cell.appendChild(document.createTextNode(''));
                } else {
                    let cellDate = new Date(year, month, date);
                    cell.setAttribute('data-date', cellDate.toISOString().split('T')[0]);
                    cell.appendChild(document.createTextNode(date));
                    date++;
                }
                row.appendChild(cell);
            }
            calendarBody.appendChild(row);
        }
    }

    prevButton.addEventListener('click', function() {
        currentMonth--;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
        renderCalendar(currentMonth, currentYear);
    });

    nextButton.addEventListener('click', function() {
        currentMonth++;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        renderCalendar(currentMonth, currentYear);
    });
 // Ensures that the end date is not before the start date
	function updateEndDate() {
	    if (dp2.value < dp1.value) {
	        dp2.value = dp1.value;
	    }
	    highlightDate();
	}
	// Update and validate dates
    dp1.addEventListener("change", highlightDates);
    dp2.addEventListener("change", highlightDates);
    renderCalendar(currentMonth, currentYear);
});

</script>


<script src="./responsive-login-form-main/assets/js/main.js"></script>

</body>
</html>