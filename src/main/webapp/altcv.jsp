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
// - Încărcare pagină cu funcționalitatea de localizare și găsire sediu apropiat

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
    <title>Localizare și sediu apropiat</title>
    
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
            max-width: 250px;
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
        .office-info {
            margin-top: 15px;
            padding: 10px;
            border-radius: 5px;
            background-color: rgba(255, 255, 255, 0.9);
        }
        .office-detail {
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
        #nearestOfficeInfo {
            display: none;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    
    <div class="form-container control-panel" style="background:<%=sidebar%>; color:<%=text%>; border-color: <%=clr%>">
        <label style="color:<%=text%>;" class="login__label">Localizare și sedii</label>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="locateMeBtn">Localizează-mă</button>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="findNearestBtn">Găsește sediul cel mai apropiat</button>
        
        <div id="nearestOfficeInfo" style="background:<%=card%>; color:<%=text%>; border-radius: 5px; padding: 10px; margin-top: 10px;">
            <h4 style="margin: 0 0 10px 0;">Informații sediu apropiat</h4>
            <div class="office-detail" id="office-name"></div>
            <div class="office-detail" id="office-type"></div>
            <div class="office-detail" id="office-address"></div>
            <div class="office-detail" id="office-city"></div>
            <div class="office-detail" id="office-contact"></div>
            <div class="office-detail" id="office-distance"></div>
        </div>
        
        <button style="box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>;" class="login__button" id="showAllOfficesBtn">Arată toate sediile</button>
        
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
                "esri/symbols/PictureMarkerSymbol",
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
                PictureMarkerSymbol,
                TextSymbol
            ) {
                // API Key pentru serviciile ArcGIS
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                // Inițializare hartă
                const map = new Map({
                    basemap: "arcgis/topographic"
                });

                // Layers pentru diferite elemente grafice
                const locationsLayer = new GraphicsLayer();
                const routeLayer = new GraphicsLayer();
                const userLocationLayer = new GraphicsLayer();
                
                map.add(locationsLayer);
                map.add(routeLayer);
                map.add(userLocationLayer);

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
                const locateMeBtn = document.getElementById("locateMeBtn");
                const findNearestBtn = document.getElementById("findNearestBtn");
                const showAllOfficesBtn = document.getElementById("showAllOfficesBtn");
                const resetBtn = document.getElementById("resetBtn");
                const loadingSpinner = document.getElementById("loadingSpinner");
                const nearestOfficeInfo = document.getElementById("nearestOfficeInfo");

                // Variabile globale
                let currentLocation = null;
                let allOffices = [];
                let nearestOffice = null;
                var accentColor = "<%= accent %>"; // Culoarea de accent a utilizatorului

                // Încărcăm datele sediilor de la server
                let userId = "<%=id%>";
                let dataUrl = "/Proiect/GetSediiServlet" + "?id=" + userId;
                
                // Funcția de încărcare a sediilor
                function loadOffices() {
                    loadingSpinner.style.display = "block";
                    
                    fetch(dataUrl)
                        .then(response => response.json())
                        .then(data => {
                            allOffices = data;
                            console.log("Sedii încărcate:", allOffices);
                            loadingSpinner.style.display = "none";
                        })
                        .catch(error => {
                            console.error("Eroare la încărcarea sediilor:", error);
                            loadingSpinner.style.display = "none";
                            alert("Eroare la încărcarea sediilor. Verificați consola pentru detalii.");
                        });
                }

                // Încărcăm sediile la pornirea aplicației
                loadOffices();

                // Funcția pentru calculul distanței între două puncte (folosind formula Haversine)
                function calculateDistance(lat1, lon1, lat2, lon2) {
                    const R = 6371; // Raza pământului în km
                    const dLat = (lat2 - lat1) * (Math.PI / 180);
                    const dLon = (lon2 - lon1) * (Math.PI / 180);
                    const a = 
                        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(lat1 * (Math.PI / 180)) * Math.cos(lat2 * (Math.PI / 180)) * 
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
                    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    const distance = R * c; // Distanța în km
                    return distance;
                }

                // Funcția de localizare a utilizatorului
                function locateUser() {
                    loadingSpinner.style.display = "block";
                    
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(
                            function (position) {
                                const longitude = position.coords.longitude;
                                const latitude = position.coords.latitude;

                                currentLocation = {
                                    longitude: longitude,
                                    latitude: latitude,
                                    point: new Point({
                                        longitude: longitude,
                                        latitude: latitude
                                    })
                                };

                                // Ștergem locația anterioară a utilizatorului și adăugăm una nouă
                                userLocationLayer.removeAll();
                                
                                const userGraphic = new Graphic({
                                    geometry: currentLocation.point,
                                    symbol: {
                                        type: "simple-marker",
                                        color: "#4287f5",
                                        size: "12px",
                                        outline: {
                                            color: "#ffffff",
                                            width: 2
                                        }
                                    },
                                    attributes: {
                                        title: "Locația mea",
                                        type: "user-location"
                                    },
                                    popupTemplate: {
                                        title: "Locația mea curentă",
                                        content: "Latitudine: {latitude}<br>Longitudine: {longitude}"
                                    }
                                });

                                userLocationLayer.add(userGraphic);

                                // Adăugăm și un text pentru locație
                                const textGraphic = new Graphic({
                                    geometry: currentLocation.point,
                                    symbol: {
                                        type: "text",
                                        color: "#202020",
                                        haloColor: "#ffffff",
                                        haloSize: 1,
                                        text: "Locația mea",
                                        yoffset: -20,
                                        font: {
                                            size: 12,
                                            weight: "bold"
                                        }
                                    }
                                });
                                
                                userLocationLayer.add(textGraphic);

                                // Centrăm harta pe locația utilizatorului
                                view.goTo({
                                    center: [longitude, latitude],
                                    zoom: 13
                                }, { duration: 1000 });

                                loadingSpinner.style.display = "none";
                            },
                            function (error) {
                                loadingSpinner.style.display = "none";
                                alert("Eroare la obținerea poziției: " + error.message);
                            }
                        );
                    } else {
                        loadingSpinner.style.display = "none";
                        alert("Geolocația nu este suportată de acest browser.");
                    }
                }

                // Funcția pentru găsirea celui mai apropiat sediu
                function findNearestOffice() {
                    if (!currentLocation) {
                        alert("Vă rugăm să vă localizați mai întâi.");
                        return;
                    }

                    if (allOffices.length === 0) {
                        alert("Nu există sedii disponibile.");
                        return;
                    }

                    loadingSpinner.style.display = "block";
                    
                    // Calculăm distanțele pentru fiecare sediu
                    let minDistance = Infinity;
                    let closest = null;

                    allOffices.forEach(office => {
                        if (office.latitudine && office.longitudine) {
                            const distance = calculateDistance(
                                currentLocation.latitude, 
                                currentLocation.longitude, 
                                office.latitudine, 
                                office.longitudine
                            );
                            
                            if (distance < minDistance) {
                                minDistance = distance;
                                closest = {
                                    ...office,
                                    distance: distance
                                };
                            }
                        }
                    });

                    if (closest) {
                        nearestOffice = closest;
                        displayNearestOfficeInfo(nearestOffice);
                        displayNearestOfficeOnMap(nearestOffice);
                        generateRouteToNearestOffice(nearestOffice);
                    } else {
                        alert("Nu s-a putut găsi un sediu cu coordonate valide.");
                    }
                    
                    loadingSpinner.style.display = "none";
                }

                // Funcția pentru afișarea informațiilor despre cel mai apropiat sediu
                function displayNearestOfficeInfo(office) {
                    // Actualizăm elementele DOM cu informațiile sediului
                    document.getElementById("office-name").textContent = "Nume: " + office.nume_sediu;
                    document.getElementById("office-type").textContent = "Tip: " + office.tip_sediu;
                    document.getElementById("office-address").textContent = "Adresă: " + office.strada + ", " + office.cod;
                    document.getElementById("office-city").textContent = "Locație: " + office.oras + ", " + office.judet + ", " + office.tara;
                    document.getElementById("office-contact").textContent = "Contact: " + (office.telefon || "N/A") + " / " + (office.email || "N/A");
                    document.getElementById("office-distance").textContent = "Distanță: " + office.distance.toFixed(2) + " km";
                    
                    // Afișăm panoul cu informații
                    nearestOfficeInfo.style.display = "block";
                }

                // Funcția pentru afișarea celui mai apropiat sediu pe hartă
                function displayNearestOfficeOnMap(office) {
                    // Ștergem orice marcaje anterioare pentru sedii
                    locationsLayer.removeAll();
                    
                    // Creăm un punct pentru sediu
                    const point = new Point({
                        longitude: office.longitudine,
                        latitude: office.latitudine
                    });

                    // Adăugăm un marcaj pentru sediu
                    const officeGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "simple-marker",
                            color: accentColor,
                            size: "14px",
                            outline: {
                                color: "#ffffff",
                                width: 2
                            }
                        },
                        attributes: {
                            title: office.nume_sediu,
                            address: office.strada,
                            city: office.oras,
                            type: office.tip_sediu,
                            distance: office.distance.toFixed(2) + " km"
                        },
                        popupTemplate: {
                            title: "{title}",
                            content: [
                                "Tip: {type}",
                                "Adresă: {address}",
                                "Oraș: {city}",
                                "Distanță: {distance}"
                            ].join("<br>")
                        }
                    });

                    locationsLayer.add(officeGraphic);

                    // Adăugăm și un text pentru sediu
                    const textGraphic = new Graphic({
                        geometry: point,
                        symbol: {
                            type: "text",
                            color: "#202020",
                            haloColor: "#ffffff",
                            haloSize: 1,
                            text: office.nume_sediu,
                            yoffset: -20,
                            font: {
                                size: 12,
                                weight: "bold"
                            }
                        }
                    });
                    
                    locationsLayer.add(textGraphic);

                    // Ajustăm vizualizarea pentru a cuprinde atât locația utilizatorului, cât și sediul
                    if (currentLocation) {
                        view.goTo({
                            target: [
                                currentLocation.point,
                                point
                            ],
                            padding: {
                                top: 100,
                                right: 100,
                                bottom: 100,
                                left: 350 // Spațiu pentru panoul de control
                            }
                        }, { duration: 1000 });
                    }
                }

                // Funcția pentru generarea rutei către cel mai apropiat sediu
                function generateRouteToNearestOffice(office) {
                    if (!currentLocation || !office.latitudine || !office.longitudine) {
                        return;
                    }

                    // Ștergem rutele anterioare
                    routeLayer.removeAll();
                    
                    // Creăm punctul de destinație
                    const destinationPoint = new Point({
                        longitude: office.longitudine,
                        latitude: office.latitudine
                    });

                    // Parametrii pentru calculul rutei
                    const routeParams = new RouteParameters({
                        stops: new FeatureSet({
                            features: [
                                new Graphic({ geometry: currentLocation.point }),
                                new Graphic({ geometry: destinationPoint })
                            ]
                        }),
                        directionsLanguage: "ro",
                        returnDirections: true
                    });

                    // Calculăm ruta
                    route.solve(routeUrl, routeParams)
                        .then(function (data) {
                            data.routeResults.forEach(function (result) {
                                result.route.symbol = {
                                    type: "simple-line",
                                    color: accentColor,
                                    width: 4
                                };
                                routeLayer.add(result.route);
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
                                header.textContent = "Indicații rutiere către " + office.nume_sediu;
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
                        })
                        .catch(function (error) {
                            console.error("Eroare la generarea rutei:", error);
                        });
                }

                // Funcția pentru afișarea tuturor sediilor pe hartă
                function showAllOffices() {
                    if (allOffices.length === 0) {
                        alert("Nu există sedii disponibile.");
                        return;
                    }

                    // Ștergem marcajele anterioare
                    locationsLayer.removeAll();
                    routeLayer.removeAll();

                    // Puncte pentru toate sediile
                    const points = [];

                    // Adăugăm fiecare sediu pe hartă
                    allOffices.forEach((office, index) => {
                        if (office.latitudine && office.longitudine) {
                            const point = new Point({
                                longitude: office.longitudine,
                                latitude: office.latitudine
                            });
                            
                            points.push(point);

                            // Creăm simbolul pentru sediu (variază în funcție de tip)
                            let symbolColor;
                            switch(office.tip_sediu) {
                                case "principal":
                                    symbolColor = "#e63946"; // roșu
                                    break;
                                case "secundar":
                                    symbolColor = "#457b9d"; // albastru
                                    break;
                                case "punct_lucru":
                                    symbolColor = "#2a9d8f"; // verde
                                    break;
                                default:
                                    symbolColor = accentColor;
                            }

                            const officeGraphic = new Graphic({
                                geometry: point,
                                symbol: {
                                    type: "simple-marker",
                                    color: symbolColor,
                                    size: "12px",
                                    outline: {
                                        color: "#ffffff",
                                        width: 1.5
                                    }
                                },
                                attributes: {
                                    id: office.id_sediu,
                                    title: office.nume_sediu,
                                    address: office.strada,
                                    city: office.oras + ", " + office.judet,
                                    type: office.tip_sediu,
                                    phone: office.telefon || "N/A",
                                    email: office.email || "N/A"
                                },
                                popupTemplate: {
                                    title: "{title}",
                                    content: [
                                        "Tip sediu: {type}",
                                        "Adresă: {address}",
                                        "Locație: {city}",
                                        "Telefon: {phone}",
                                        "Email: {email}"
                                    ].join("<br>")
                                }
                            });

                            locationsLayer.add(officeGraphic);

                            // Adăugăm nume sediu
                            const textGraphic = new Graphic({
                                geometry: point,
                                symbol: {
                                    type: "text",
                                    color: "#202020",
                                    haloColor: "#ffffff",
                                    haloSize: 1,
                                    text: office.nume_sediu,
                                    yoffset: -20,
                                    font: {
                                        size: 11,
                                        weight: "bold"
                                    }
                                }
                            });
                            
                            locationsLayer.add(textGraphic);
                        }
                    });

                    // Ajustăm vizualizarea pentru a cuprinde toate sediile
                    if (points.length > 0) {
                        view.goTo({
                            target: points,
                            padding: {
                                top: 50,
                                right: 50,
                                bottom: 50,
                                left: 300 // Spațiu pentru panoul de control
                            }
                        }, { duration: 1500 });
                    }

                    // Ascundem panoul de informații despre cel mai apropiat sediu
                    nearestOfficeInfo.style.display = "none";
                }

                // Funcția pentru resetarea hărții
                function resetMap() {
                    // Ștergem toate straturile grafice
                    userLocationLayer.removeAll();
                    locationsLayer.removeAll();
                    routeLayer.removeAll();
                    
                    // Resetăm vizualizarea la România
                    view.goTo({
                        center: [25, 45.9],
                        zoom: 7
                    }, { duration: 1000 });

                    // Ascundem panoul de informații
                    nearestOfficeInfo.style.display = "none";
                    
                    // Eliminăm panourile de instrucțiuni
                    view.ui.empty("top-right");
                    
                    // Resetăm variabilele globale
                    currentLocation = null;
                    nearestOffice = null;
                }

                // Event handlers pentru butoane
                locateMeBtn.addEventListener("click", locateUser);
                findNearestBtn.addEventListener("click", findNearestOffice);
                showAllOfficesBtn.addEventListener("click", showAllOffices);
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