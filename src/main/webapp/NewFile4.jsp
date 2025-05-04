<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
      
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

// Structura paginii:
// - Verificare sesiune activă și utilizator conectat
// - Extragere date despre user (tip, teme de culoare)
// - Extragere date despre locul de muncă și concedii
// - Încărcare pagină cu funcționalitatea de vizualizare traseu

    HttpSession sesi = request.getSession(false); // verificăm dacă există o sesiune activă
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // verificăm dacă există un utilizator în sesiune
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extragem username-ul (unic)
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
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
                	// extrag date despre userul curent
                    int id = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");
                    int idSediu = rs.getInt("id_sediu");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; 
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    if (!isAdmin) {  
                    	// aflu data curenta, tot ca o interogare bd
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
                   	 // acum aflu tematica de culoare specifică utilizatorului
                   	 String accent = "#10439F"; // mai intai le initializez cu cele implicite
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
         
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
 
    <script src="https://js.arcgis.com/4.30/"></script>
    <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Traseu muncă - concediu</title>
    
    <style>
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }
        .control-panel {
            position: absolute;
            top: 80px;
            left: 20px;
            z-index: 100;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            font-family: Arial, sans-serif;
            max-width: 280px;
        }
        .control-panel select,
        .control-panel button {
            display: block;
            margin-bottom: 10px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
        }
        .location-info {
            margin-top: 15px;
            padding: 10px;
            border-radius: 5px;
            background-color: rgba(255, 255, 255, 0.9);
        }
        .location-detail {
            margin: 5px 0;
            font-size: 13px;
        }
        #loadingSpinner {
            display: none;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 200;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .route-info {
            display: none;
            margin-top: 15px;
            padding: 10px;
            border-radius: 5px;
        }
        .legend {
            padding: 8px;
            margin-top: 10px;
            border-radius: 5px;
            font-size: 12px;
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
        .workplace-selector {
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    
    <div class="form-container control-panel" style="background:<%=sidebar%>; color:<%=text%>; border-color: <%=clr%>">
        <label style="color:<%=text%>;" class="login__label">Traseu muncă - concediu</label>
        
        <div class="workplace-selector">
            <label style="color:<%=text%>; margin-top: 10px;" class="login__label">Locul de muncă:</label>
            <select id="workplaceSelect" style="background:<%=clr%>; color:<%=text%>; border-color:<%=accent%>;" class="login__input">
                <option value="" disabled selected>Selectați locul de muncă...</option>
            </select>
        </div>
        
        <label style="color:<%=text%>; margin-top: 10px;" class="login__label">Concediu:</label>
        <select id="holidaySelect" style="background:<%=clr%>; color:<%=text%>; border-color:<%=accent%>;" class="login__input">
            <option value="" disabled selected>Alegeți un concediu...</option>
        </select>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="showWorkplaceBtn">Arată locul de muncă</button>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="showHolidayBtn">Arată locația concediului</button>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="showRouteBtn">Generează traseu</button>
        
        <div id="routeInfo" class="route-info" style="background:<%=card%>; color:<%=text%>;">
            <h4 style="margin: 0 0 10px 0;">Informații traseu</h4>
            <div class="location-detail" id="route-distance"></div>
            <div class="location-detail" id="route-time"></div>
        </div>
        
        <div class="legend" style="background:<%=card%>; color:<%=text%>;">
            <h4 style="margin: 0 0 10px 0;">Legendă</h4>
            <div class="legend-item">
                <div class="legend-color" style="background-color: #4287f5;"></div>
                <span>Locul de muncă</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background-color: <%=accent%>;"></div>
                <span>Locație concediu</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background-color: <%=accent%>; border-radius: 0;"></div>
                <span>Traseu</span>
            </div>
        </div>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="resetBtn">Resetare hartă</button>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button">
            <a style="color: white; text-decoration: none; font-size: 14px;" href="actiuni_harti.jsp">< Înapoi</a>
        </button>
    </div>

    <div id="loadingSpinner">
        <p>Se încarcă...</p>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/rest/locator",
                "esri/layers/GraphicsLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet",
                "esri/symbols/SimpleMarkerSymbol",
                "esri/symbols/TextSymbol"
            ], function (
                esriConfig,
                Map,
                MapView,
                Graphic,
                locator,
                GraphicsLayer,
                Point,
                route,
                RouteParameters,
                FeatureSet,
                SimpleMarkerSymbol,
                TextSymbol
            ) {
                // API Key pentru serviciile ArcGIS
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                // Inițializare hartă
                const map = new Map({
                    basemap: "arcgis/topographic"
                });

                // Layers pentru diferite elemente grafice
                const workplaceLayer = new GraphicsLayer();
                const holidayLayer = new GraphicsLayer();
                const routeLayer = new GraphicsLayer();
                
                map.add(workplaceLayer);
                map.add(holidayLayer);
                map.add(routeLayer);

                // View inițial centrat pe România
                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45.9], 
                    zoom: 7
                });

                // URL-uri pentru servicii
                const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";

                // Referințe către elementele DOM
                const workplaceSelect = document.getElementById("workplaceSelect");
                const holidaySelect = document.getElementById("holidaySelect");
                const showWorkplaceBtn = document.getElementById("showWorkplaceBtn");
                const showHolidayBtn = document.getElementById("showHolidayBtn");
                const showRouteBtn = document.getElementById("showRouteBtn");
                const resetBtn = document.getElementById("resetBtn");
                const loadingSpinner = document.getElementById("loadingSpinner");
                const routeInfo = document.getElementById("routeInfo");
                const routeDistance = document.getElementById("route-distance");
                const routeTime = document.getElementById("route-time");

                // Variabile globale
                let userId = <%=id%>;
                let userDepartmentId = <%=userdep%>;
                let userSediuId = <%=idSediu%>;
                let workplaceLocation = null;
                let holidayLocation = null;
                let selectedHoliday = null;
                let allWorkplaces = [];
                let allHolidays = [];
                var accentColor = "<%= accent %>";

                // Încărcăm datele despre concedii și locurile de muncă de la server
                const holidaysUrl = "GetUserHolidayServlet" + "?id=" + userId;
                const workplacesUrl = "GetUserWorkplaceServlet" + "?id=" + userId + "&id_dep=" + userDepartmentId + "&id_sediu=" + userSediuId;
                
                // Funcția pentru încărcarea concediilor
                function loadHolidays() {
                    loadingSpinner.style.display = "block";
                    
                    fetch(holidaysUrl)
                        .then(response => response.json())
                        .then(data => {
                            allHolidays = data;
                            console.log("Concedii încărcate:", allHolidays);
                            
                            // Populăm dropdown-ul cu concedii
                            holidaySelect.innerHTML = '<option value="" disabled selected>Alegeți un concediu...</option>';
                            
                            allHolidays.forEach((holiday, index) => {
                                const option = document.createElement("option");
                                option.value = index;
                                option.textContent = `${holiday.motiv} (${holiday.start_c} - ${holiday.end_c}) - ${holiday.locatie}`;
                                holidaySelect.appendChild(option);
                            });
                            
                            loadingSpinner.style.display = "none";
                        })
                        .catch(error => {
                            console.error("Eroare la încărcarea concediilor:", error);
                            loadingSpinner.style.display = "none";
                            alert("Eroare la încărcarea concediilor. Verificați consola pentru detalii.");
                        });
                }

                // Funcția pentru încărcarea locurilor de muncă
                function loadWorkplaces() {
                    loadingSpinner.style.display = "block";
                    
                    fetch(workplacesUrl)
                        .then(response => response.json())
                        .then(data => {
                            allWorkplaces = data;
                            console.log("Locuri de muncă încărcate:", allWorkplaces);
                            
                            // Populăm dropdown-ul cu locuri de muncă
                            workplaceSelect.innerHTML = '<option value="" disabled selected>Selectați locul de muncă...</option>';
                            
                            allWorkplaces.forEach((workplace, index) => {
                                const option = document.createElement("option");
                                option.value = index;
                                
                                // Construim textul opțiunii în funcție de tipul locației
                                let displayText = "";
                                if (workplace.type === "sediu") {
                                    displayText = `Sediu: ${workplace.nume_sediu} - ${workplace.oras}`;
                                } else if (workplace.type === "departament") {
                                    displayText = `Departament: ${workplace.nume_dep} - ${workplace.oras}`;
                                } else {
                                    displayText = `Locație: ${workplace.strada}, ${workplace.oras}`;
                                }
                                
                                option.textContent = displayText;
                                workplaceSelect.appendChild(option);
                            });
                            
                            // Selectăm automat primul loc de muncă dacă există
                            if (allWorkplaces.length > 0) {
                                workplaceSelect.value = 0;
                                // Simulăm un eveniment change pentru a actualiza selecția
                                const event = new Event('change');
                                workplaceSelect.dispatchEvent(event);
                            }
                            
                            loadingSpinner.style.display = "none";
                        })
                        .catch(error => {
                            console.error("Eroare la încărcarea locurilor de muncă:", error);
                            loadingSpinner.style.display = "none";
                            alert("Eroare la încărcarea locurilor de muncă. Verificați consola pentru detalii.");
                        });
                }

                // Încărcăm datele la pornirea aplicației
                loadHolidays();
                loadWorkplaces();

                // Funcția pentru afișarea locului de muncă pe hartă
                function showWorkplace() {
                    const selectedIndex = workplaceSelect.value;
                    
                    if (!selectedIndex && selectedIndex !== 0) {
                        alert("Vă rugăm să selectați un loc de muncă.");
                        return;
                    }

                    const selectedWorkplace = allWorkplaces[selectedIndex];
                    
                    if (!selectedWorkplace || !selectedWorkplace.latitudine || !selectedWorkplace.longitudine) {
                        alert("Locul de muncă selectat nu are coordonate valide.");
                        return;
                    }

                    workplaceLocation = {
                        longitude: selectedWorkplace.longitudine,
                        latitude: selectedWorkplace.latitudine,
                        type: selectedWorkplace.type,
                        name: selectedWorkplace.type === "sediu" ? selectedWorkplace.nume_sediu : 
                              (selectedWorkplace.type === "departament" ? selectedWorkplace.nume_dep : "Locație de muncă"),
                        address: selectedWorkplace.strada,
                        city: selectedWorkplace.oras,
                        county: selectedWorkplace.judet,
                        country: selectedWorkplace.tara,
                        postal: selectedWorkplace.cod
                    };

                    // Ștergem orice marker anterior
                    workplaceLayer.removeAll();
                    
                    // Creăm un punct pentru locul de muncă
                    const point = new Point({
                        longitude: workplaceLocation.longitude,
                        latitude: workplaceLocation.latitude
                    });

                    // Adăugăm un marker pentru locul de muncă
                    const workplaceGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "simple-marker",
                            color: "#4287f5", // albastru
                            size: "12px",
                            outline: {
                                color: "#ffffff",
                                width: 2
                            }
                        },
                        attributes: {
                            title: workplaceLocation.name,
                            address: workplaceLocation.address,
                            city: workplaceLocation.city,
                            county: workplaceLocation.county,
                            country: workplaceLocation.country,
                            postal: workplaceLocation.postal
                        },
                        popupTemplate: {
                            title: "{title}",
                            content: [
                                "Adresă: {address}",
                                "Oraș: {city}, {county}",
                                "Țară: {country}",
                                "Cod poștal: {postal}"
                            ].join("<br>")
                        }
                    });

                    workplaceLayer.add(workplaceGraphic);

                    // Adăugăm și un text pentru locul de muncă
                    const textGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "text",
                            color: "#202020",
                            haloColor: "#ffffff",
                            haloSize: 1,
                            text: workplaceLocation.name,
                            yoffset: -20,
                            font: {
                                size: 12,
                                weight: "bold"
                            }
                        }
                    });
                    
                    workplaceLayer.add(textGraphic);

                    // Centrăm harta pe locul de muncă
                    view.goTo({
                        target: point,
                        zoom: 13
                    }, { duration: 1000 });
                }

                // Funcția pentru afișarea locației de concediu pe hartă
                function showHoliday() {
                    const selectedIndex = holidaySelect.value;
                    
                    if (!selectedIndex) {
                        alert("Vă rugăm să selectați un concediu.");
                        return;
                    }

                    selectedHoliday = allHolidays[selectedIndex];
                    
                    if (!selectedHoliday || !selectedHoliday.latitudine || !selectedHoliday.longitudine) {
                        alert("Locația concediului selectat nu are coordonate valide.");
                        return;
                    }

                    holidayLocation = {
                        longitude: selectedHoliday.longitudine,
                        latitude: selectedHoliday.latitudine,
                        address: selectedHoliday.strada,
                        city: selectedHoliday.oras,
                        county: selectedHoliday.judet,
                        country: selectedHoliday.tara,
                        postal: selectedHoliday.cod,
                        name: selectedHoliday.locatie,
                        startDate: selectedHoliday.start_c,
                        endDate: selectedHoliday.end_c,
                        reason: selectedHoliday.motiv
                    };

                    // Ștergem orice marker anterior
                    holidayLayer.removeAll();
                    
                    // Creăm un punct pentru locația de concediu
                    const point = new Point({
                        longitude: holidayLocation.longitude,
                        latitude: holidayLocation.latitude
                    });

                    // Adăugăm un marker pentru locația de concediu
                    const holidayGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "simple-marker",
                            color: accentColor,
                            size: "12px",
                            outline: {
                                color: "#ffffff",
                                width: 2
                            }
                        },
                        attributes: {
                            title: "Locație concediu: " + holidayLocation.name,
                            address: holidayLocation.address,
                            city: holidayLocation.city,
                            county: holidayLocation.county,
                            country: holidayLocation.country,
                            dates: `${holidayLocation.startDate} - ${holidayLocation.endDate}`,
                            reason: holidayLocation.reason
                        },
                        popupTemplate: {
                            title: "{title}",
                            content: [
                                "Adresă: {address}",
                                "Oraș: {city}, {county}",
                                "Țară: {country}",
                                "Perioadă: {dates}",
                                "Motiv: {reason}"
                            ].join("<br>")
                        }
                    });

                    holidayLayer.add(holidayGraphic);

                    // Adăugăm și un text pentru locația de concediu
                    const textGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "text",
                            color: "#202020",
                            haloColor: "#ffffff",
                            haloSize: 1,
                            text: holidayLocation.name,
                            yoffset: -20,
                            font: {
                                size: 12,
                                weight: "bold"
                            }
                        }
                    });
                    
                    holidayLayer.add(textGraphic);

                    // Centrăm harta pe locația de concediu
                    view.goTo({
                        target: point,
                        zoom: 13
                    }, { duration: 1000 });
                }

                // Funcția pentru generarea traseului între muncă și locația de concediu
                function generateRoute() {
                    if (!workplaceLocation) {
                        alert("Vă rugăm să selectați și să afișați locul de muncă.");
                        return;
                    }

                    if (!holidayLocation) {
                        alert("Vă rugăm să selectați și să afișați o locație de concediu.");
                        return;
                    }

                    loadingSpinner.style.display = "block";
                    
                    // Ștergem rutele anterioare
                    routeLayer.removeAll();
                    
                    // Creăm punctele pentru loc de muncă și concediu
                    const workplacePoint = new Point({
                        longitude: workplaceLocation.longitude,
                        latitude: workplaceLocation.latitude
                    });

                    const holidayPoint = new Point({
                        longitude: holidayLocation.longitude,
                        latitude: holidayLocation.latitude
                    });

                    // Parametrii pentru calculul rutei
                    const routeParams = new RouteParameters({
                        stops: new FeatureSet({
                            features: [
                                new Graphic({ geometry: workplacePoint }),
                                new Graphic({ geometry: holidayPoint })
                            ]
                        }),
                        directionsLanguage: "ro",
                        returnDirections: true,
                        returnRoutes: true,
                        returnStops: true,
                        travelMode: "driving"
                    });

                    // Calculăm ruta
                    route.solve(routeUrl, routeParams)
                        .then(function (data) {
                            loadingSpinner.style.display = "none";
                            
                            data.routeResults.forEach(function (result) {
                                result.route.symbol = {
                                    type: "simple-line",
                                    color: accentColor,
                                    width: 4
                                };
                                routeLayer.add(result.route);
                                
                                // Actualizăm informațiile despre traseu
                                if (result.route.attributes) {
                                    const totalKm = (result.route.attributes.Total_Kilometers).toFixed(2);
                                    const totalMinutes = Math.floor(result.route.attributes.Total_TravelTime);
                                    const hours = Math.floor(totalMinutes / 60);
                                    const minutes = totalMinutes % 60;
                                    
                                    routeDistance.textContent = `Distanță: ${totalKm} km`;
                                    routeTime.textContent = `Durată estimată: ${hours}h ${minutes}min`;
                                    routeInfo.style.display = "block";
                                }
                            });

                            // Afișăm instrucțiunile de navigare
                            if (data.routeResults.length > 0) {
                                const directions = document.createElement("ol");
                                directions.classList = "esri-widget esri-widget--panel esri-directions__scroller";
                                directions.style.marginTop = "10px";
                                directions.style.padding = "15px 15px 15px 30px";
                                directions.style.backgroundColor = "#ffffff";
                                directions.style.maxWidth = "300px";
                                directions.style.maxHeight = "400px";
                                directions.style.overflow = "auto";
                                directions.style.fontSize = "14px";

                                const header = document.createElement("h3");
                                header.textContent = "Traseu: " + workplaceLocation.name + " → " + holidayLocation.name;
                                header.style.marginTop = "0";
                                directions.appendChild(header);

                                data.routeResults[0].directions.features.forEach(function (result, i) {
                                    const direction = document.createElement("li");
                                    direction.innerHTML = result.attributes.text + 
                                        " (" + result.attributes.length.toFixed(2) + " km)";
                                    directions.appendChild(direction);
                                });

                                view.ui.empty("top-right");
                                view.ui.add(directions, "top-right");
                            }

                            // Ajustăm vizualizarea pentru a cuprinde întregul traseu
                            view.goTo({
                                target: [workplacePoint, holidayPoint],
                                padding: {
                                    top: 100,
                                    right: 100,
                                    bottom: 100,
                                    left: 350 // Spațiu pentru panoul de control
                                }
                            }, { duration: 1000 });
                        })
                        .catch(function (error) {
                            loadingSpinner.style.display = "none";
                            console.error("Eroare la generarea rutei:", error);
                            alert("Eroare la generarea rutei. Verificați consola pentru detalii.");
                        });
                }

                // Funcția pentru resetarea hărții
                function resetMap() {
                    // Ștergem toate straturile grafice
                    workplaceLayer.removeAll();
                    holidayLayer.removeAll();
                    routeLayer.removeAll();
                    
                    // Resetăm vizualizarea la România
                    view.goTo({
                        center: [25, 45.9],
                        zoom: 7
                    }, { duration: 1000 });

                    // Ascundem panoul cu informații despre traseu
                    routeInfo.style.display = "none";
                    
                    // Eliminăm panourile de instrucțiuni
                    view.ui.empty("top-right");
                    
                    // Resetăm dropdown-ul de concedii
                    holidaySelect.selectedIndex = 0;
                    
                    // Resetăm variabilele globale
                    holidayLocation = null;
                    selectedHoliday = null;
                }

                // Event handlers pentru elemente
                workplaceSelect.addEventListener("change", function() {
                    // La schimbarea locului de muncă selectat, resetăm afișarea acestuia
                    workplaceLayer.removeAll();
                    routeLayer.removeAll();
                    routeInfo.style.display = "none";
                    view.ui.empty("top-right");
                    workplaceLocation = null;
                });

                holidaySelect.addEventListener("change", function() {
                    // La schimbarea concediului selectat, resetăm afișarea locației de concediu
                    holidayLayer.removeAll();
                    routeLayer.removeAll();
                    routeInfo.style.display = "none";
                    view.ui.empty("top-right");
                    holidayLocation = null;
                });

                showWorkplaceBtn.addEventListener("click", showWorkplace);
                showHolidayBtn.addEventListener("click", showHoliday);
                showRouteBtn.addEventListener("click", generateRoute);
                resetBtn.addEventListener("click", resetMap);
            });
        });
    </script>
  <%
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