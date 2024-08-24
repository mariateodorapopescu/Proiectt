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
            String user = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume, id_dep from useri where username = ?")) {
                preparedStatement.setString(1, user);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    if (userType == 4) {
                        switch (userType) {
                            case 1: response.sendRedirect("tip1ok.jsp"); break;
                            case 2: response.sendRedirect("tip2ok.jsp"); break;
                            case 3: response.sendRedirect("sefok.jsp"); break;
                            case 4: response.sendRedirect("adminok.jsp"); break;
                        }
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
                                 stmt.setInt(1, userId);
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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>

    <title>Vizualizare concedii</title>
     <style>
       body, html {
    margin: 0;
    padding: 0;
}

.container {
    padding-top: 120px; /* Adjust as needed */
     
}

/* Hover Effect on Date Buttons */
.pika-button:hover, .pika-button:active {
    background: <%=accent%>;
    color: #fff; /* White text for hover */
}

/* Styling for the navigation header */
.pika-label {
    color: <%=accent%>; /* Light grey color for the month and year */
    font-size: 16px; /* Larger font size */
    background: <%=sidebar%>;
}

/* Navigation buttons */
.pika-prev, .pika-next {
    cursor: pointer;
    color: <%=text%>;
    background: <%=sidebar%>;
    border: none;
}

/* Table cells */
.pika-button {
    border: none; /* Remove default borders */
    padding: 5px; /* Padding for the date numbers */
    color: <%=text%>; /* Default date color */
    background: <%=sidebar%>;
}

/* Hover effect on date cells */
.pika-button:hover {
    background: <%=clr%>; /* Darker background on hover */
    color: <%=text%>; /* White text on hover */
}

/* Special styles for today */
.pika-single .is-today .pika-button {
    color: <%=accent%>; /* Green color for today's date */
    font-weight: bold; /* Make it bold */
}

/* Styles for the selected date */
.pika-single .is-selected .pika-button {
    background: <%=accent%>; /* Bright color for selection */
    color: #fff; /* White text for selected date */
}

/* Weekday labels */
.pika-weekday {
    /* color: #aaa; */ /* Light gray for weekdays */
    font-weight: normal;
}

/* Styling for the Selected Date */
.pika-single .is-selected {
    background: <%=accent%>;
    color: #fff; /* White text for selected date */
}

/* Styling for Today's Date */
.pika-single .is-today {
    border: 2px solid <%=accent%> /* White border for today */
    color: <%=accent%> /* White text for today */
}
.pika-title {
    background: <%=sidebar%>; /* Darker shade for the header */
    color: <%=accent%>; /* White text for clarity */
    text-align: center; /* Center the month and year */
    padding: 5px 0; /* Padding for better spacing */
    border-top-left-radius: 8px; /* Rounded corners at the top */
    border-top-right-radius: 8px;
}
/* If you use dropdowns for month/year selection, style them too */
.pika-month, .pika-year {
    color: <%=accent%>; /* Matching text color */
    background: <%=sidebar%>; /* Transparent background to blend in with the header */
    border: none; /* Remove borders for a cleaner look */
}
.pika-single {
    background: <%=sidebar%>; /* Change to your desired color */
    border-radius: 1rem;
}

table.picka-table tr {
    background-color: <%=accent%>; /* Golden color for the header */
}


.pika-single .pika-week {
    background:  <%=clr%>; /* Change week numbers background */
}

    </style>
</head>
<body style="overflow: auto; position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                        <div class="container" style="overflow: auto; position: fixed; top:0; left: 28%; border-radius: 2rem; padding: 0;  margin: 0; background: <%out.println(clr);%>">
                            <div class="login__content" style="position: fixed; top: 0; border-radius: 2rem; margin: 0; height: 100vh; border-radius: 2rem; margin: 0; padding: 0; background:<%out.println(clr);%>; color:<%out.println(text);%> ">
                                
                                <form style="position: fixed; top: 6rem;  border-radius: 2rem; margin: 0; border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(sidebar);%>; color:<%out.println(accent);%> " action="<%= request.getContextPath() %>/masina1.jsp" method="post" class="login__form">
                                    <div>
                                        <h1 class="login__title"><span style="color:<%out.println(accent);%> ">Vizualizare concedii ale unui angajat</span></h1>
                                    </div>
                                    
                                    <div class="login__inputs">
                                        <div>
    
                                            <label style="color:<%out.println(text);%> " class="login__label">Utilizator (Nume, Prenume, Username)</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="id" class="login__input">
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT id, nume, prenume, username FROM useri")) {
                                                    ResultSet rs1 = stm.executeQuery();
                                                    while (rs1.next()) {
                                                        int id = rs1.getInt("id");
                                                        String nume = rs1.getString("nume");
                                                        String prenume = rs1.getString("prenume");
                                                        String username = rs1.getString("username");
                                                        out.println("<option value='" + id + "'>" + nume + " " + prenume + " (" + username + ")</option>");
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>
                                        
                                        <div>
                                            <label style="color:<%out.println(text);%> " class="login__label">Status</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " name="status" class="login__input">
                                                <option value="3">Oricare</option>
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                                                    try (ResultSet rs1 = stm.executeQuery()) {
                                                        if (rs1.next()) {
                                                            do {
                                                                int id = rs1.getInt("status");
                                                                String nume = rs1.getString("nume_status");
                                                                out.println("<option value='" + id + "'>" + nume + "</option>");
                                                            } while (rs1.next());
                                                        } else {
                                                            out.println("<option value=''>Nu exista statusuri disponibile.</option>");
                                                        }
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>
                                        
                                        <div>
                                            <label style="color:<%out.println(text);%> " class="login__label">Tip</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " name="tip" class="login__input">
                                                <option value="-1">Oricare</option>
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM tipcon;")) {
                                                    try (ResultSet rs1 = stm.executeQuery()) {
                                                        if (rs1.next()) {
                                                            do {
                                                                int id = rs1.getInt("tip");
                                                                String nume = rs1.getString("motiv");
                                                                out.println("<option value='" + id + "'>" + nume + "</option>");
                                                            } while (rs1.next());
                                                        } else {
                                                            out.println("<option value=''>Nu exista tipuri disponibile.</option>");
                                                        }
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>

                                        <div class="login__check">
                                            <input type="checkbox" id="an" name="an" class="login__check-input"/>
                                            <label style="color:<%out.println(text);%> " for="an" class="login__check-label">An</label>
                                        </div>

                                        <div id="start">
                                            <label style="color:<%out.println(text);%> " class="login__label">Inceput</label>
                                            
    <input type="hidden" id="start-hidden" name="start">
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " type="text" id="start" name="start" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>

                                        <div id="end">
                                            <label style="color:<%out.println(text);%> " class="login__label">Final</label>
                                             <input type="hidden" id="end-hidden" name="end">
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%> " type="text" id="end" name="end" min="1954-01-01" max="2036-12-31" class="login__input"/>
                                        </div>
                                    </div>

                                    <input type="hidden" name="userId" value="<%= userId %>"/>
                                    <input type="hidden" name="dep" value="<%= userdep %>"/>
                                    <input type="hidden" name="pag" value="4"/>
                                    
                                    <div class="login__buttons">
                                       <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" type="submit" value="Cautati" class="login__button">
                                    </div>
                                </form>
                            </div>
                        </div>
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
});
</script>
                        <script>
                            function toggleDateInputs() {
                                var radioPer = document.getElementById('an');
                                var startInput = document.getElementById('start');
                                var endInput = document.getElementById('end');
                                if (radioPer.checked) {
                                    startInput.style.display = 'none';
                                    endInput.style.display = 'none';
                                } else {
                                    startInput.style.display = 'block';
                                    endInput.style.display = 'block';
                                }
                            }
                            document.addEventListener('DOMContentLoaded', function() {
                                toggleDateInputs();  // Call on initial load
                                setInterval(toggleDateInputs, 100); // Call every 100 milliseconds
                            });
                        </script>
                        <%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
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
</body>
</html>
