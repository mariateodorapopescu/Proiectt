<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// codul pentru fisierele .jsp arata in mare parte cam asa, dupa aceasta structura
// incep prin a face rost de sesiune si de datele stocate la nivel de sesiune, adica utilizatorul
// apoi pe baza a ceea ce am stocat in utilizator, selectez si fac alte interogari ca sa aflu alte lucruri
// in mare, daca am sesiune activa, utilizator in sesiune (adica e cineva conectat) 
// se afiseaza pagina in functie de tipul si de utilizatorul in sine (tematica, tipul de dashboard, alte functionalitati)
    HttpSession sesiune = request.getSession(false); // selectez sesiunea fara a crea alta
    if (sesiune != null) {
        MyUser utilizatorcurent = (MyUser) sesiune.getAttribute("currentUser"); // selectez atributul de user stocat la conectare
        if (utilizatorcurent != null) {
            String numeutilizator = utilizatorcurent.getUsername(); // aflu numele de utilizator, caci acesta este unic si deci pot incepe prin a face interogari pe baza sa
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection conexiune = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement stmt = conexiune.prepareStatement("select * from useri where username = ?")) {
                stmt.setString(1, numeutilizator);
                ResultSet rezultat = stmt.executeQuery();
                if (rezultat.next()) {
                    int id = rezultat.getInt("id");
                    int tip1 = rezultat.getInt("tip");
                    if (tip1 == 4) {
                        response.sendRedirect("adminok.jsp"); 
                    } else {
                    	// selectez culorile pentru tema/schema de culoare
                    	 String accent = null;
                      	 String clr = null;
                      	 String sidebar = null;
                      	 String text = null;
                      	 String card = null;
                      	 String hover = null;
                      	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             String query = "SELECT * from teme where id_usr = ?";
                             try (PreparedStatement stmt2 = conexiune.prepareStatement(query)) {
                                 stmt2.setInt(1, id);
                                 try (ResultSet rezultat2 = stmt2.executeQuery()) {
                                     if (rezultat2.next()) {
                                       accent =  rezultat2.getString("accent");
                                       clr =  rezultat2.getString("clr");
                                       sidebar =  rezultat2.getString("sidebar");
                                       text = rezultat2.getString("text");
                                       card =  rezultat2.getString("card");
                                       hover = rezultat2.getString("hover");
                                     }
                                 }
                             }
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== alt CSS ===============-->
    <style>
     @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
     input[type="date"] {
     background-color: <%=accent%>; 
    color: <%=accent%>; 
    border: 2px solid <%=accent%>; 
    
   
}
.pika-single {
    background-color: <%=sidebar%>;
    color: <%=text%>;
}

input[type="date"]:focus {
    border-color: <%=accent%>; 
    box-shadow: 0 0 8px 0 <%=accent%>; 
}
     
	* {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	    font-family: 'Poppins', sans-serif;
		}
	
     :root{
     /*========== culori de baza ==========*/
      --first-color: #2a2a2a;
	  --second-color: hsl(249, 64%, 47%);
	  /*========== cuulori text ==========*/
	  --title-color-light: hsl(244, 12%, 12%);
	  --text-color-light: hsl(244, 4%, 36%);
	  --title-color-dark: hsl(0, 0%, 95%);
	  --text-color-dark: hsl(0, 0%, 80%);
	  /*========== cuulori corp ==========*/
	  --body-color-light: hsl(208, 97%, 85%);
	  --body-color-dark: #1a1a1a;
	  --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
	  --form-border-color-light: hsla(244, 16%, 92%, 0.75);
	  --form-bg-color-dark: #333;
	  --form-border-color-dark: #3a3a3a;
	  /*========== Font ==========*/
	  --body-font: "Poppins", sans-serif;
	  --h2-font-size: 1.25rem;
	  --small-font-size: .813rem;
	  --smaller-font-size: .75rem;
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
        color: white;
    }
       /* Hover Effect on Date Buttons */
.pika-button:hover, .pika-button:active {
    background-color: <%=accent%>;
    color: #fff; /* White text for hover */
}

/* Styling for the navigation header */
.pika-label {
    color: <%=accent%>; /* Light grey color for the month and year */
    font-size: 16px; /* Larger font size */
    background-color: <%=sidebar%>;
}

/* Navigation buttons */
.pika-prev, .pika-next {
    cursor: pointer;
    color: <%=text%>;
    background-color: <%=sidebar%>;
    border: none;
}

/* Table cells */
.pika-button {
    border: none; /* Remove default borders */
    padding: 5px; /* Padding for the date numbers */
    color: <%=text%>; /* Default date color */
    background-color: <%=sidebar%>;
}

/* Hover effect on date cells */
.pika-button:hover {
    background-color: <%=clr%>; /* Darker background on hover */
    color: <%=text%>; /* White text on hover */
}

/* Special styles for today */
.pika-single .is-today .pika-button {
    color: <%=accent%>; /* Green color for today's date */
    font-weight: bold; /* Make it bold */
}

/* Styles for the selected date */
.pika-single .is-selected .pika-button {
    background-color: <%=accent%>; /* Bright color for selection */
    color: #fff; /* White text for selected date */
}

/* Weekday labels */
.pika-weekday {
    /* color: #aaa; */ /* Light gray for weekdays */
    font-weight: normal;
}

/* Styling for the Selected Date */
.pika-single .is-selected {
    background-color: <%=accent%>;
    color: #fff; /* White text for selected date */
}

/* Styling for Today's Date */
.pika-single .is-today {
    border: 2px solid <%=accent%> /* White border for today */
    color: <%=accent%> /* White text for today */
}
.pika-title {
    background-color: transparent; /* Darker shade for the header */
    color: <%=accent%>; /* White text for clarity */
    text-align: center; /* Center the month and year */
    padding: 5px 0; /* Padding for better spacing */
    border-top-left-radius: 8px; /* Rounded corners at the top */
    border-top-right-radius: 8px;
}
/* If you use dropdowns for month/year selection, style them too */
.pika-month, .pika-year {
    color: <%=accent%>; /* Matching text color */
    background-color: <%=sidebar%>; /* Transparent background to blend in with the header */
    border: none; /* Remove borders for a cleaner look */
}

    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                        <div class="flex-container">
                        <!-- Calendar + formular -->
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
                                        <!-- Aici se va genera calendarul -->
                                    </tbody>
                                </table>
                            </div>
                            <!-- Abia acum vine formularul -->
                            <div class="form-container" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
                                <form style="border-color:<%out.println(clr);%>; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" action="<%= request.getContextPath() %>/addcon" method="post" class="login__form">
                                    <div>
                                        <h1 style=" color:<%out.println(accent);%>" class="login__title"><span style=" color:<%out.println(accent);%>">Adaugare concediu</span></h1>
                                        
                                    </div>
                                    
                                    <div class="login__inputs" style="border-color:<%out.println(accent);%>; color:<%out.println(text);%>">
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Data plecare</label>
                                        			 <div class="date-input-container" style="position: relative;">
                                       			 		 
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" class="login__input" type='text' id='start' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()' >
    
    <input type="hidden" id="start-hidden" name="start">
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Data sosire</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" class="login__input" type='text' id='end' name='end' min='1954-01-01' max='2036-12-31' required onchange='highlightDate()'/>
                                        	<input type="hidden" id="start-hidden" name="start">
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Motiv</label>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti motivul" required class="login__input" name='motiv'/>
                                        </div>
                                        <div>
                                            <label style=" color:<%out.println(text);%>" class="login__label">Tip concediu</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name='tip' class="login__input">
                                            <%
                                            try (PreparedStatement stmt3 = conexiune.prepareStatement("SELECT tip, motiv FROM tipcon")) {
                                                ResultSet rezultat1 = stmt3.executeQuery();
                                                while (rezultat1.next()) {
                                                    int tip = rezultat1.getInt("tip");
                                                    String motiv = rezultat1.getString("motiv");
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
<script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
<script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>

<script>

document.addEventListener("DOMContentLoaded", function() {
	var picker = new Pikaday({
	    field: document.getElementById('start'),
	    format: 'YYYY-MM-DD', // Make sure this format is supported by your version of Pikaday or Moment.js
	    minDate: new Date(2000, 0, 1), // Minimum date
	    maxDate: new Date(2025, 12, 31), // Maximum date
	    yearRange: [2000, 2025],
	    disableWeekends: false,
	    showWeekNumber: true,
	    isRTL: false, // Right-to-left languages
	    theme: 'current',
	    i18n: {
	        previousMonth: 'Luna precedentă',
	        nextMonth: 'Luna următoare',
	        months: ['Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'],
	        weekdays: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
	        weekdaysShort: ['Dum', 'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm']
	    },
	    
	    firstDay: 1,
	    onSelect: function() {
	        var date = this.getDate();
	        date.setDate(date.getDate() + 1);
	        // console.log(date); // Check what you get here
	        if (date) {
	            var formattedDate = date.toISOString().substring(0, 10);
	            console.log(formattedDate); // Ensure format is correct
	            document.getElementById('start-hidden').value = formattedDate;
	        } else {
	            console.error('No date returned from date picker');
	        }
	    }
	});
	var picker2 = new Pikaday({
	    field: document.getElementById('end'),
	    format: 'YYYY-MM-DD', // Make sure this format is supported by your version of Pikaday or Moment.js
	    minDate: new Date(2000, 0, 1), // Minimum date
	    maxDate: new Date(2025, 12, 31), // Maximum date
	    yearRange: [2000, 2025],
	    disableWeekends: false,
	    showWeekNumber: true,
	    isRTL: false, // Right-to-left languages
	    theme: 'current', // This class will be added to the root Pikaday element
	    i18n: {
	        previousMonth: 'Luna precedentă',
	        nextMonth: 'Luna următoare',
	        months: ['Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'],
	        weekdays: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
	        weekdaysShort: ['Dum', 'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm']
	    },
	    firstDay: 1,
	    onSelect: function() {
	        var date = this.getDate();
	        date.setDate(date.getDate() + 1);
	        // console.log(date); // Check what you get here
	        if (date) {
	            var formattedDate = date.toISOString().substring(0, 10);
	            console.log(formattedDate); // Ensure format is correct
	            document.getElementById('end-hidden').value = formattedDate;
	        } else {
	            console.error('No date returned from date picker');
	        }
	    }
	});
	
	//new Pikaday({ field: document.getElementById('start') });
	
	// declarare si initializare variabile
    const dp1 = document.getElementById("start-hidden");
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
    	// atunci cand se face click pe o celula se trimite valoarea la formular
        if (event.target.tagName === 'TD' && event.target.getAttribute('data-date')) {
        	clickCount++;
            handleDateClick(event.target.getAttribute('data-date'));
            
        }
    });

    function validateDates() {
        if (dp2.value < dp1.value) {
            alert("Data de final nu poate fi mai mică decât cea de început!");
            dp2.value = dp1.value;
        }
        highlightDates();
    }
    
    dp1.addEventListener("change", function() {
        dp2.min = dp1.value;
        if (dp2.value < dp1.value) {
            dp2.value = ''; // Reset dp2 if it's less than dp1
        }
    });
    
    function handleDateClick(clickedDate) {
        // Se parseaza valoarea primita din tabel, ca data
        let parsedDate = new Date(clickedDate);
        parsedDate.setDate(parsedDate.getDate() + 1);
        // se pune sub format "YYYY-MM-DD" pentru a completa formularul
        let adjustedDate = parsedDate.toISOString().split('T')[0];
        // daca nu e completat dp1, se pune valoarea in dp1, altfel in dp2
        if (dp1.value !== '') {
            dp2.value = adjustedDate;  // Set end date if start date is already set
        } else {
            dp1.value = adjustedDate;  // Set start date if not already set
            dp2.value = '';  // Clear end date to allow for new selection
        }
        updateCalendarToSelectedDate(parsedDate);  // se randeaza calendarul din nou (ca sa fie si cu ce s-a marcat)
        highlightDates();  // se marcheaza datele selectate in calendar
    }

	// ajuta la randare, ca sa randeze cu tot cu luna si an
    function updateCalendarToSelectedDate(date) {
        currentYear = date.getFullYear();
        currentMonth = date.getMonth();
        renderCalendar(currentMonth, currentYear);
    }

 // adauga (matematic) o zi la o data
    function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() - days);
        return result;
    }

 	// marcheaza datele/celule din calendar/tabel
    function highlightDates() {
        const startDate = dp1.value ? new Date(dp1.value + 'T00:00:00Z') : null; // se dorste format si cu ora
        const endDate = dp2.value ? new Date(dp2.value + 'T00:00:00Z') : null;
        Array.from(calendarBody.querySelectorAll('td[data-date]')).forEach(td => { // pentru fiecare data din tabel
            const currentDate = new Date(td.getAttribute('data-date') + 'T00:00:00Z');
        	// se coloreaza in culoarea de baza (initial)
            td.style.backgroundColor = defaultBg;
        	// daca data curenta din for e intre start si end atunci se adauga un nou atribut de stil de culoare la acea celula
            if (startDate && endDate && currentDate >= addDays(startDate, 1) && currentDate < endDate) {
                td.style.backgroundColor = bg; // Highlight range
            }
        });
    }

 	// aici se randeaza calendarul
    function renderCalendar(month, year) {
        let firstDay = new Date(year, month).getDay();
        calendarBody.innerHTML = ''; // se goleste tot si se construieste de la capat
        monthYear.textContent = monthNames[month] + ' ' + year; // se seteaza data curenta (incrementata/decrementata, 
        		// dar mai intai la incarcarea paginii apare data curenta care se modifica in functie de sageti)
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
 	
	// pentru a modifica luna calendarului, in urma
    prevButton.addEventListener('click', function() {
        currentMonth--;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
     // pentru fiecare schimbare se reface calendarul
        renderCalendar(currentMonth, currentYear);
    });

 // pentru a modifica luna calendarului, inainte
    nextButton.addEventListener('click', function() {
        currentMonth++;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        // pentru fiecare schimbare se reface calendarul
        renderCalendar(currentMonth, currentYear);
    });
 
 // functie ce verifica ca data de final sa fie dupa data de inceput a concediului
	function updateEndDate() {
	    if (dp2.value < dp1.value) {
	        dp2.value = dp1.value;
	    }
	    highlightDate();
	}
 
	// adauga functii care sa se modifice la fiecare schimbare a inputului de data
    dp1.addEventListener("change", highlightDates);
    dp2.addEventListener("change", highlightDates);
    dp1.addEventListener("change", updateEndDate);
    dp2.addEventListener("change", validateDates);
    renderCalendar(currentMonth, currentYear);
});
</script>
<script src="./responsive-login-form-main/assets/js/main.js"></script>
</body>
</html>