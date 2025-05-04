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
// - Extragere date despre adresa de acasă și concedii
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
    <title>Traseu acasă - concediu</title>
    
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
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    
    <div class="form-container control-panel" style="background:<%=sidebar%>; color:<%=text%>; border-color: <%=clr%>">
        <label style="color:<%=text%>;" class="login__label">Traseu acasă - concediu</label>
        
        <label style="color:<%=text%>; margin-top: 10px;" class="login__label">Selectați concediul:</label>
        <select id="holidaySelect" style="background:<%=clr%>; color:<%=text%>; border-color:<%=accent%>;" class="login__input">
            <option value="" disabled selected>Alegeți un concediu...</option>
        </select>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="showHomeBtn">Arată adresa de acasă</button>
        
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
                <span>Adresa dvs. de acasă</span>
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
                const homeLayer = new GraphicsLayer();
                const holidayLayer = new GraphicsLayer();
                const routeLayer = new GraphicsLayer();
                
                map.add(homeLayer);
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
                const holidaySelect = document.getElementById("holidaySelect");
                const showHomeBtn = document.getElementById("showHomeBtn");
                const showHolidayBtn = document.getElementById("showHolidayBtn");
                const showRouteBtn = document.getElementById("showRouteBtn");
                const resetBtn = document.getElementById("resetBtn");
                const loadingSpinner = document.getElementById("loadingSpinner");
                const routeInfo = document.getElementById("routeInfo");
                const routeDistance = document.getElementById("route-distance");
                const routeTime = document.getElementById("route-time");

                // Variabile globale
                let userId = <%=id%>;
                let homeLocation = null;
                let holidayLocation = null;
                let selectedHoliday = null;
                let allHolidays = [];
                var accentColor = "<%= accent %>";

                // Încărcăm datele despre adresa de acasă și concedii de la server
                const holidaysUrl = "GetUserHolidayServlet" + "?id=" + userId;
                const homeUrl = "getUserHomeServlet" + "?id=" + userId;
                
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

                // Funcția pentru încărcarea adresei de acasă
                function loadHomeAddress() {
                    loadingSpinner.style.display = "block";
                    
                    fetch(homeUrl)
                        .then(response => response.json())
                        .then(data => {
                            if (data && data.latitudine && data.longitudine) {
                                homeLocation = {
                                    longitude: data.longitudine,
                                    latitude: data.latitudine,
                                    address: data.strada,
                                    city: data.oras,
                                    county: data.judet,
                                    country: data.tara,
                                    postal: data.cod
                                };
                                console.log("Adresă acasă încărcată:", homeLocation);
                            } else {
                                console.log("Nu s-a găsit o adresă de acasă cu coordonate valide.");
                            }
                            
                            loadingSpinner.style.display = "none";
                        })
                        .catch(error => {
                            console.error("Eroare la încărcarea adresei de acasă:", error);
                            loadingSpinner.style.display = "none";
                            alert("Eroare la încărcarea adresei de acasă. Verificați consola pentru detalii.");
                        });
                }

                // Încărcăm datele la pornirea aplicației
                loadHolidays();
                loadHomeAddress();

                // Funcția pentru afișarea adresei de acasă pe hartă
                function showHomeLocation() {
                    if (!homeLocation) {
                        alert("Nu s-a găsit o adresă de acasă cu coordonate valide.");
                        return;
                    }

                    // Ștergem orice marker anterior
                    homeLayer.removeAll();
                    
                    // Creăm un punct pentru adresa de acasă
                    const point = new Point({
                        longitude: homeLocation.longitude,
                        latitude: homeLocation.latitude
                    });

                    // Adăugăm un marker pentru adresa de acasă
                    const homeGraphic = new Graphic({
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
                            title: "Adresa de acasă",
                            address: homeLocation.address,
                            city: homeLocation.city,
                            county: homeLocation.county,
                            country: homeLocation.country,
                            postal: homeLocation.postal
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

                    homeLayer.add(homeGraphic);

                    // Adăugăm și un text pentru adresa de acasă
                    const textGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "text",
                            color: "#202020",
                            haloColor: "#ffffff",
                            haloSize: 1,
                            text: "Acasă",
                            yoffset: -20,
                            font: {
                                size: 12,
                                weight: "bold"
                            }
                        }
                    });
                    
                    homeLayer.add(textGraphic);

                    // Centrăm harta pe adresa de acasă
                    view.goTo({
                        target: point,
                        zoom: 13
                    }, { duration: 1000 });
                }

                // Funcția pentru afișarea locației de concediu pe hartă
                function showHolidayLocation() {
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

                // Funcția pentru generarea traseului între acasă și locația de concediu
                function generateRoute() {
                    if (!homeLocation) {
                        alert("Nu s-a găsit o adresă de acasă cu coordonate valide.");
                        return;
                    }

                    if (!holidayLocation) {
                        alert("Vă rugăm să selectați și să afișați o locație de concediu.");
                        return;
                    }

                    loadingSpinner.style.display = "block";
                    
                    // Ștergem rutele anterioare
                    routeLayer.removeAll();
                    
                    // Creăm punctele pentru acasă și concediu
                    const homePoint = new Point({
                        longitude: homeLocation.longitude,
                        latitude: homeLocation.latitude
                    });

                    const holidayPoint = new Point({
                        longitude: holidayLocation.longitude,
                        latitude: holidayLocation.latitude
                    });

                    // Parametrii pentru calculul rutei
                    const routeParams = new RouteParameters({
                        stops: new FeatureSet({
                            features: [
                                new Graphic({ geometry: homePoint }),
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
                                header.textContent = "Traseu: Acasă → " + holidayLocation.name;
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
                                target: [homePoint, holidayPoint],
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
                    homeLayer.removeAll();
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
                holidaySelect.addEventListener("change", function() {
                    // La schimbarea concediului selectat, resetăm afișarea locației de concediu
                    holidayLayer.removeAll();
                    routeLayer.removeAll();
                    routeInfo.style.display = "none";
                    view.ui.empty("top-right");
                    holidayLocation = null;
                });

                showHomeBtn.addEventListener("click", showHomeLocation);
                showHolidayBtn.addEventListener("click", showHolidayLocation);
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