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
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, id, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("4") != 0) {
                        if (rs.getString("tip").compareTo("1") == 0) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("0") == 0) {
                            response.sendRedirect("dashboard.jsp");
                        }
                    } else {
                        int id = rs.getInt("id");
                        String prenume = rs.getString("prenume");
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * from teme where id_usr = ?";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                stmt.setInt(1, id);
                                try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                        accent = rs2.getString("accent");
                                        clr = rs2.getString("clr");
                                        sidebar = rs2.getString("sidebar");
                                        text = rs2.getString("text");
                                        card = rs2.getString("card");
                                        hover = rs2.getString("hover");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Definire Utilizator</title>

    <!-- CSS -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
   
    <!-- JavaScript -->
  <script src="https://js.arcgis.com/4.30/"></script>
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
<script>
const apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";
const baseUrl = "https://js.arcgis.com/4.30/";
</script>
<link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
<script src="https://js.arcgis.com/4.30/"></script>
    <style>
         html,
    body,
    #viewDiv {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }

    #searchButton {
      position: absolute;
      top: 20px;
      left: 20px;
      z-index: 100;
      background-color: #0079c1;
      color: white;
      border: none;
      padding: 10px 15px;
      cursor: pointer;
      border-radius: 5px;
      font-size: 14px;
    }

    #searchButton:hover {
      background-color: #005a91;
    }

    #searchPane {
      display: none; /* Ascuns inițial */
      position: absolute;
      top: 60px;
      left: 20px;
      z-index: 101;
      background-color: white;
      border: 1px solid #ccc;
      box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
      padding: 10px;
      border-radius: 5px;
    }

        .container {
            padding-top: 120px;
        }

        #mapDiv {
            height: 300px;
            width: 100%;
            border-radius: 1rem;
            margin-bottom: 1rem;
            border: 2px solid <%=accent%>;
        }

        .esri-view {
            border-radius: 1rem;
        }

        .esri-search {
            border-radius: 0.5rem;
            overflow: hidden;
        }

        .esri-search__input {
            background-color: <%=sidebar%> !important;
            color: <%=text%> !important;
            border-color: <%=accent%> !important;
        }

        .esri-search__submit-button {
            background-color: <%=accent%> !important;
            color: white !important;
        }

        .esri-popup__header {
            background-color: <%=sidebar%> !important;
            color: <%=text%> !important;
        }

        .esri-popup__content {
            background-color: <%=clr%> !important;
            color: <%=text%> !important;
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
<body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>; --text:<%=text%>; background:<%=clr%>">
    <div class="container">
        <div class="login__content" style="border-radius: 2rem; background:<%=clr%>; color:<%=text%>">
            <form action="<%= request.getContextPath() %>/register" method="post" class="login__form" style="background:<%=sidebar%>; color:<%=text%>">
                <div>
                    <h1 class="login__title">
                        <span style="color: <%=accent%>">Definire utilizator nou</span>
                    </h1>
                </div>
                <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Nume</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="nume" placeholder="Introduceti numele" required class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Prenume</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="prenume" placeholder="Introduceti prenumele" required class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Data nasterii</label>
                                                           
    <input type="hidden" id="start-hidden" name="data_nasterii">
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" id="start" name="data_nasterii" value="2001-07-22" min="1954-01-01" max="2036-12-31" class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Adresa</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="adresa" placeholder="Introduceti adresa" required class="login__input">
                    </div>
                    
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">E-mail</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="email" placeholder="Introduceti e-mailul" required class="login__input">
                    </div>
					
                    
                </div></td>
                
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                <td><p>   </p></td>
                
                <td>
                
                <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">UserName</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="username" placeholder="Introduceti numele de utilizator" required class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Password</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="password" name="password" placeholder="Introduceti parola" required class="login__input">
                    </div>
               
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Departament</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="departament" class="login__input">
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT id_dep, nume_dep FROM departament;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs1 = stmt.executeQuery();

                                if (!rs1.next()) {
                                    out.println("Nu exista date sau date incorecte");
                                } else {
                                    do {
                                        out.println("<option value='" + rs1.getString("id_dep") + "' required>" + rs1.getString("nume_dep") + "</option>");
                                    } while (rs1.next());
                                }
                                rs1.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                               
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Tip/Ierarhie</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="tip" class="login__input">
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "select tip, denumire from tipuri;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs2 = stmt.executeQuery();
                                if (rs2.next() == false) {
                                    out.println("No Records in the table");
                                } else {
                                    do {
                                        out.println("<option value='" + rs2.getString("tip") + "' required>" + rs2.getString("denumire") + "</option>");
                                    } while (rs2.next());
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Telefon</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="telefon" placeholder="Introduceti telefonul" required class="login__input">
                    </div>
                    
                </div>
                 <div>
                        <label style="color:<%=text%>" class="login__label">Locație</label>
                        <div id="mapDiv"></div>
                        <input type="hidden" name="latitude" id="latitude">
                        <input type="hidden" name="longitude" id="longitude">
                    </div>
                </td></tr>
</table>
 <a href="viewang3.jsp" class="login__forgot" style="margin:0; top:-10px; color:<%out.println(accent);%> ">Inapoi</a>
                <div class="login__buttons">
                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button">
                </div>
                
            </form>
 <div id="viewDiv"></div>
  <button id="searchButton">Căutare</button>
  <div id="searchPane"></div>

           
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
	    minDate: new Date(1954, 0, 1), // Minimum date
	    maxDate: new Date(2025, 12, 31), // Maximum date
	    yearRange: [1954, 2025],
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
	
});

require([
	  "esri/config",
	  "esri/Map",
	  "esri/views/MapView",
	  "esri/layers/FeatureLayer",
	  "esri/widgets/Search"
	], function (esriConfig, Map, MapView, FeatureLayer, Search) {
	  esriConfig.apiKey =
	    "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

	  // URL-ul unui FeatureLayer cu locații pentru concedii
	  const destinationsUrl =
	    "https://services.arcgis.com/example/arcgis/rest/services/Destinations/FeatureServer/0";

	  // Configurare FeatureLayer
	  const destinationsLayer = new FeatureLayer({
	    url: destinationsUrl,
	    popupTemplate: {
	      title: "{Name}",
	      content: `
	        <b>Descriere:</b> {Description}<br>
	        <b>Țara:</b> {Country}<br>
	        <b>Rating:</b> {Rating} / 5
	      `
	    },
	    renderer: {
	      type: "simple",
	      symbol: {
	        type: "simple-marker",
	        color: "blue",
	        size: "10px",
	        outline: {
	          color: "white",
	          width: 1
	        }
	      }
	    }
	  });

	  // Creare hartă
	  const map = new Map({
	    basemap: "arcgis/topographic",
	    layers: [destinationsLayer]
	  });

	  // Creare MapView pentru vizualizarea hărții
	  const view = new MapView({
	    container: "viewDiv",
	    map: map,
	    center: [0, 20], // Centrul hărții
	    zoom: 2 // Zoom inițial
	  });

	  // Adăugare widget Search
	  const searchWidget = new Search({
	    view: view
	  });

	  // Ascunde widget-ul Search inițial
	  searchWidget.container.style.display = "none";

	  // Adăugare funcționalitate pentru butonul de căutare
	  const searchPane = document.getElementById("searchPane");
	  const searchButton = document.getElementById("searchButton");

	  searchButton.addEventListener("click", () => {
	    const isHidden = searchPane.style.display === "none";
	    searchPane.style.display = isHidden ? "block" : "none";
	  });

	  // Adaugă widget-ul Search în `searchPane`
	  searchPane.appendChild(searchWidget.container);
	});


fetch('getLocations')
.then(response => response.json())
.then(locations => {
    locations.forEach(loc => {
        addPoint(loc.lat, loc.long, loc.descriere);
    });
});

function saveLocation(lat, long, descriere) {
    fetch('saveLocation', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            lat: lat,
            long: long,
            descriere: descriere
        })
    });
}

</script>

    <% 
    if ("true".equals(request.getParameter("p"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Trebuie sa alegeti o parola mai complexa!');");
        out.println("</script>");
        out.println("<br>Parola trebuie sa contina:<br>");
        out.println("- minim 8 caractere<br>");
        out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
        out.println("- o litera mare<br>");
        out.println("- o litera mica<br>");
        out.println("- o cifra<br>");
        out.println("- cifrele alaturate sa nu fie egale sau consecutive<br>");
        out.println("- literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele");
    }

    if ("true".equals(request.getParameter("n"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("pn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Prenume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("t"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Telefon scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("e"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('E-mail scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("dn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Utilizatorul trebuie sa aiba minim 18 ani!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pms"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un sef / departament!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pmd"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un director / departament!');");
        out.println("</script>");
    }   
                }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
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
