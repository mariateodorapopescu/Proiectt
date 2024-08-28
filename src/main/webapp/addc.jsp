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
//structura unei pagini este astfel
//verificare daca exista sesiune activa, utilizator conectat, 
//extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//se mai extrag temele de culoare ale fiecarui utilizator
//apoi se incarca pagina in sine

  HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
  if (sesi != null) {
      MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizatoir in sesiune aka daca e cineva logat
      if (currentUser != null) {
          String username = currentUser.getUsername(); // extrag usernameul, care e unic si asta cam transmit in formuri (mai transmit si id dar deocmadata ma bazez pe username)
          Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
          try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
              PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
              preparedStatement.setString(1, username);
              ResultSet rs = preparedStatement.executeQuery();
              if (rs.next()) {
              	// extrag date despre userul curent
                  int id = rs.getInt("id");
                  int userType = rs.getInt("tip");
                  int userdep = rs.getInt("id_dep");
                  if (userType != 4) {  
                  	// aflu data curenta, tot ca o interogare bd =(
                  	String today = "";
                 	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                          String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                          try (PreparedStatement stmt = connection.prepareStatement(query)) {
                             try (ResultSet rs2 = stmt.executeQuery()) {
                                  if (rs2.next()) {
                                    today =  rs2.getString("today");
                                  }
                              }
                          }
                      } catch (SQLException e) {
                          out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                          e.printStackTrace();
                      }
                 	 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                 	 String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
                	 String clr = "#d8d9e1";
                	 String sidebar = "#ECEDFA";
                	 String text = "#333";
                	 String card = "#ECEDFA";
                	 String hover = "#ECEDFA";
                	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
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
	 
	 * {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	    font-family: 'Poppins', sans-serif;
		}
		        
	::placeholder {
	  color: var(--text);
	  opacity: 1; /* Firefox */
	}
	
	::-ms-input-placeholder { /* Edge 12-18 */
	  color: var(--text);
	}
     
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
	    
	.pika-button:hover, .pika-button:active {
	    background: <%=accent%>;
	    color: #fff; 
	}
	
	.pika-label {
	    color: <%=accent%>;
	    font-size: 16px;
	    background: <%=sidebar%>;
	}
	
	.pika-prev, .pika-next {
	    cursor: pointer;
	    color: <%=text%>;
	    background: <%=sidebar%>;
	    border: none;
	}
	
	.pika-button {
	    border: none;
	    padding: 5px; 
	    color: <%=text%>;
	    background: <%=sidebar%>;
	}
	
	.pika-button:hover {
	    background: <%=clr%>;
	    color: <%=text%>; 
	}
	
	.pika-single .is-today .pika-button {
	    color: <%=accent%>;
	    font-weight: bold;
	}
	
	.pika-single .is-selected .pika-button {
	    background: <%=accent%>; 
	    color: #fff; 
	}
	
	.pika-weekday {
	    font-weight: normal;
	}
	
	.pika-single .is-selected {
	    background: <%=accent%>;
	    color: #fff; 
	}
	
	.pika-single .is-today {
	    border: 2px solid <%=accent%> ;
	    color: <%=accent%>;
	}
	.pika-title {
	    background: <%=sidebar%>; 
	    color: <%=accent%>; 
	    text-align: center; 
	    padding: 5px 0; 
	    border-top-left-radius: 8px; 
	    border-top-right-radius: 8px;
	}
	
	.pika-month, .pika-year {
	    color: <%=accent%>; 
	    background: <%=sidebar%>; 
	    border: none; 
	}
	
	.pika-single {
	    background: <%=sidebar%>; 
	    border-radius: 1rem;
	}
	
	table.picka-table tr {
	    background-color: <%=accent%>; 
	}
	
	.pika-single .pika-week {
	    background:  <%=clr%>; 
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
        <thead>
            <tr>
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
<!-- Abia acum este formularul -->
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
            	<input type="hidden" id="end-hidden" name="end">
            </div>
            <div>
                <label style=" color:<%out.println(text);%>" class="login__label">Motiv</label>
                <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" style="border-color:<%out.println(clr);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" placeholder="Introduceti motivul" required class="login__input" name='motiv'/>
            </div>
            <div>
                <label style=" color:<%out.println(text);%>" class="login__label">Tip concediu</label>
                <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name='tip' class="login__input">
                <%
                try (PreparedStatement stmt3 = connection.prepareStatement("SELECT tip, motiv FROM tipcon")) {
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
            dp2.value = adjustedDate;  
        } else {
            dp1.value = adjustedDate;  
            dp2.value = '';  
        }
        updateCalendarToSelectedDate(parsedDate);  
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
                td.style.backgroundColor = bg; 
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