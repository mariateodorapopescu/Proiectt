<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
      
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizator in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extrag usernameul, care e unic
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                            "dp.denumire_completa AS denumire FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (!rs.next()) {
                        out.println("<script type='text/javascript'>");
                        out.println("alert('Date introduse incorect sau nu exista date!');");
                        out.println("</script>");
                    } else {
                        int userType = rs.getInt("tip");
                        int id = rs.getInt("id");
                        int userDep = rs.getInt("id_dep");
                        int ierarhie = rs.getInt("ierarhie");
                        String functie = rs.getString("functie");
                        String nume_dep = rs.getString("nume_dep");
                        
                        // Funcție helper pentru a determina rolul utilizatorului
                        boolean isDirector = (ierarhie < 3);
                        boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                        boolean isIncepator = (ierarhie >= 10);
                        boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                        boolean isAdmin = (functie.compareTo("Administrator") == 0);
                        
                        if (!isAdmin) {  
                          // data curenta, tot ca o interogare bd =(
                          String today = "";
                          try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                              String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                              try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                      if (rs2.next()) {
                                        today = rs2.getString("today");
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

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Rutare: Acasă → Următorul concediu</title>
    
    <style>
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }
        
        .sidebar {
            position: absolute;
            top: 80px;
            left: 20px;
            z-index: 100;
            background-color: <%=sidebar%>;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            color: <%=text%>;
            font-family: Arial, sans-serif;
        }
        
        .form-container {
            max-height: 90vh;
            overflow-y: auto;
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 100;
            padding: 15px;
            background: <%=sidebar%>;
            color: <%=clr%>;
            border-color: <%=clr%>;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            width: 300px;
        }
        
        .form-container button {
            display: block;
            margin-top: 15px;
            margin-bottom: 10px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            background-color: <%=accent%>;
            color: white;
            cursor: pointer;
            box-shadow: 0 6px 24px <%=accent%>;
        }
        
        .form-container button:hover {
            opacity: 0.9;
        }
        
        .form-container button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
            box-shadow: none;
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
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
            text-align: center;
        }
        
        #loadingSpinner p {
            margin-bottom: 10px;
            font-weight: bold;
        }
        
        .details-panel {
            background-color: <%=sidebar%>;
            color: <%=text%>;
            padding: 10px 15px;
            border-radius: 8px;
            margin-top: 10px;
            font-size: 14px;
        }
        
        .details-panel h4 {
            margin-top: 0;
            color: <%=accent%>;
            border-bottom: 1px solid <%=clr%>;
            padding-bottom: 5px;
        }
        
        .location-info {
            margin-bottom: 5px;
        }
        
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            color: white;
            margin-right: 5px;
        }
        
        .badge-distance {
            background-color: <%=accent%>;
        }
        
        .badge-days {
            background-color: #4caf50; /* verde */
        }
        
        .badge-status {
            background-color: #28a745; /* verde pentru aprobat */
        }
        
        .badge-status-pending {
            background-color: #ffc107; /* galben pentru în așteptare */
        }
        
        .badge-status-rejected {
            background-color: #dc3545; /* roșu pentru respins */
        }

        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            display: none;
        }

        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            display: none;
        }
        
        ::-webkit-scrollbar {
            display: none;
        }
        
        /* Stil pentru formatul datei */
        .date-display {
            font-style: italic;
            color: <%=accent%>;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    <div class="form-container">
        <h3 style="color: <%=accent%>; margin-top: 0;">Rutare: Acasă → Următorul concediu</h3>
        
        <div id="homeDetails" class="details-panel" style="display: none;">
            <h4>Locația ta de acasă</h4>
            <div id="homeInfo"></div>
        </div>
        
        <div id="nextConcediuDetails" class="details-panel" style="display: none;">
            <h4>Următorul tău concediu</h4>
            <div id="daysBadge" class="badge badge-days" style="display: none;"></div>
            <div id="distanceBadge" class="badge badge-distance" style="display: none;"></div>
            <div id="statusBadge" class="badge" style="display: none;"></div>
            <div id="concediuInfo"></div>
        </div>
        
        <button id="loadDataBtn" class="login__button">
            <i class="ri-calendar-check-line"></i> Încarcă datele
        </button>
        
        <button id="generateRouteBtn" class="login__button" disabled>
            <i class="ri-route-line"></i> Generează rută
        </button>
        
        <button id="resetBtn" class="login__button">
            <i class="ri-refresh-line"></i> Resetează harta
        </button>
        
        <button class="login__button">
            <a style="color: white !important; text-decoration: none; font-size: 14px;" href="actiuni_harti.jsp">
                <i class="ri-arrow-left-line"></i> Înapoi
            </a>
        </button>
        
        <p id="statusMessage" style="color:<%=text%>; margin-top: 10px; font-size: 14px;"></p>
        <div id="errorMsg" class="error-message"></div>
        <div id="successMsg" class="success-message"></div>
    </div>

    <div id="loadingSpinner">
        <p>Se încarcă...</p>
        <div style="width: 50px; height: 50px; border: 5px solid <%=clr%>; border-top: 5px solid <%=accent%>; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
    </div>

    <script>
        // Animație pentru loading spinner
        document.head.insertAdjacentHTML('beforeend', `
            <style>
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
            </style>
        `);
        
        document.addEventListener('DOMContentLoaded', function () {
            // Culoarea accentului utilizatorului
            const accentColor = "<%=accent%>";
            
            // ID-ul utilizatorului curent
            const userId = <%=id%>;
            
            // Referințe la elementele DOM
            const homeDetails = document.getElementById("homeDetails");
            const homeInfo = document.getElementById("homeInfo");
            const nextConcediuDetails = document.getElementById("nextConcediuDetails");
            const concediuInfo = document.getElementById("concediuInfo");
            const daysBadge = document.getElementById("daysBadge");
            const distanceBadge = document.getElementById("distanceBadge");
            const statusBadge = document.getElementById("statusBadge");
            const loadDataBtn = document.getElementById("loadDataBtn");
            const generateRouteBtn = document.getElementById("generateRouteBtn");
            const resetBtn = document.getElementById("resetBtn");
            const loadingSpinner = document.getElementById("loadingSpinner");
            const statusMessage = document.getElementById("statusMessage");
            const errorMsg = document.getElementById("errorMsg");
            const successMsg = document.getElementById("successMsg");
            
            // Variabile pentru stocarea datelor
            let homeLocation = null;
            let nextConcediu = null;
            
            // Funcție pentru formatarea datelor
            function formatDate(dateString) {
                if (!dateString) return '';
                
                const parts = dateString.split('-');
                if (parts.length === 3) {
                    return parts[2] + '/' + parts[1] + '/' + parts[0]; // zi/luna/an
                }
                
                return dateString;
            }
            
            // Funcție pentru afișarea mesajelor
            function afișareMesaj(tip, mesaj, durată = 5000) {
                if (tip === 'succes') {
                    successMsg.textContent = mesaj;
                    successMsg.style.display = 'block';
                    setTimeout(() => { successMsg.style.display = 'none'; }, durată);
                } else if (tip === 'eroare') {
                    errorMsg.textContent = mesaj;
                    errorMsg.style.display = 'block';
                    setTimeout(() => { errorMsg.style.display = 'none'; }, durată);
                } else {
                    statusMessage.textContent = mesaj;
                }
            }
            
            // Inițializare hartă ArcGIS
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/layers/GraphicsLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet"
            ], function (
                esriConfig,
                Map,
                MapView,
                Graphic,
                GraphicsLayer,
                Point,
                route,
                RouteParameters,
                FeatureSet
            ) {
                // Setăm cheia API ArcGIS
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";
                
                // Creăm harta
                const map = new Map({
                    basemap: "arcgis-topographic" // Hartă topografică
                });
                
                // Creăm un layer pentru grafice (puncte, linii)
                const graphicsLayer = new GraphicsLayer();
                map.add(graphicsLayer);
                
                // Inițializăm view-ul hărții
                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45], // Centrat pe România
                    zoom: 6,
                    ui: {
                        components: ["zoom"] // Afișăm doar controlul de zoom
                    },
                    // Dezactivăm zoom-ul la scroll
                    navigation: {
                        mouseWheelZoomEnabled: false,
                        browserTouchPanEnabled: true
                    }
                });
                
                // URL pentru serviciul de rutare
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";
                
                // Handler pentru butonul "Încarcă datele"
                loadDataBtn.addEventListener("click", function() {
                    // Afișăm indicatorul de încărcare
                    loadingSpinner.style.display = "block";
                    afișareMesaj('normal', "Se încarcă datele...");
                    
                    // Facem cerere către servlet pentru a obține datele
                    fetch("GetNextConcediuAndHomeServlet?userId=" + userId)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error("Eroare la încărcarea datelor: " + response.statusText);
                            }
                            return response.json();
                        })
                        .then(data => {
                            // Ascundem indicatorul de încărcare
                            loadingSpinner.style.display = "none";
                            
                            // Verificăm dacă avem datele necesare
                            if (!data.user_location || !data.next_concediu) {
                                throw new Error("Nu s-au găsit datele necesare.");
                            }
                            
                            // Salvăm datele
                            homeLocation = data.user_location;
                            nextConcediu = data.next_concediu;
                            
                            // Afișăm detaliile
                            displayHomeDetails(data.user_info, homeLocation);
                            displayNextConcediuDetails(nextConcediu);
                            
                            // Afișăm locațiile pe hartă
                            displayLocationsOnMap();
                            
                            // Activăm butonul de generare rută
                            generateRouteBtn.disabled = false;
                            
                            afișareMesaj('succes', "Datele au fost încărcate cu succes. Poți genera ruta acum.");
                        })
                        .catch(error => {
                            // Ascundem indicatorul de încărcare
                            loadingSpinner.style.display = "none";
                            afișareMesaj('eroare', error.message);
                            console.error(error);
                        });
                });
                
                // Funcție pentru afișarea detaliilor locației de acasă
                function displayHomeDetails(userInfo, homeLocation) {
                    homeDetails.style.display = "block";
                    homeInfo.innerHTML = 
                        `<div class="location-info"><strong>Nume:</strong> ${userInfo.nume} ${userInfo.prenume}</div>` +
                        `<div class="location-info"><strong>Adresa:</strong> ${homeLocation.adresa_completa}</div>`;
                }
                
                // Funcție pentru afișarea detaliilor următorului concediu
                function displayNextConcediuDetails(concediu) {
                    nextConcediuDetails.style.display = "block";
                    
                    // Afișăm badge-ul cu zilele rămase
                    daysBadge.style.display = "inline-block";
                    if (concediu.zile_ramase > 0) {
                        const zileText = concediu.zile_ramase == 1 ? 'zi' : 'zile';
                        daysBadge.textContent = `Peste ${concediu.zile_ramase} ${zileText}`;
                    } else if (concediu.zile_ramase == 0) {
                        daysBadge.textContent = "Astăzi!";
                    } else {
                        daysBadge.textContent = "În desfășurare";
                    }
                    
                    // Afișăm badge-ul cu distanța
                    if (concediu.distanta_km) {
                        distanceBadge.style.display = "inline-block";
                        distanceBadge.textContent = concediu.distanta_km + " km";
                    }
                    
                    // Determinăm clasa pentru badge-ul de status
                    let statusClass = "badge-status";
                    if (concediu.status < 0) {
                        statusClass = "badge-status-rejected";
                    } else if (concediu.status === 0 || concediu.status === 1) {
                        statusClass = "badge-status-pending";
                    }
                    
                    // Afișăm badge-ul de status
                    statusBadge.className = "badge " + statusClass;
                    statusBadge.style.display = "inline-block";
                    statusBadge.textContent = concediu.status_text;
                    
                    // Formatăm datele
                    const startDate = formatDate(concediu.start_c);
                    const endDate = formatDate(concediu.end_c);
                    
                    // Afișăm informațiile despre concediu
                    concediuInfo.innerHTML = 
                        `<div class="location-info"><strong>Locație:</strong> ${concediu.locatie}</div>` +
                        `<div class="location-info"><strong>Perioada:</strong> <span class="date-display">${startDate} - ${endDate}</span> (${concediu.durata} zile)</div>` +
                        `<div class="location-info"><strong>Motiv:</strong> ${concediu.motiv}</div>` +
                        `<div class="location-info"><strong>Tip:</strong> ${concediu.tip_text}</div>` +
                        `<div class="location-info"><strong>Adresa:</strong> ${concediu.adresa_completa}</div>`;
                }
                
                // Funcție pentru afișarea locațiilor pe hartă
                function displayLocationsOnMap() {
                    // Curățăm graficele existente
                    graphicsLayer.removeAll();
                    
                    // Creăm punctul pentru locația de acasă
                    const homePoint = new Point({
                        longitude: homeLocation.longitudine,
                        latitude: homeLocation.latitudine
                    });
                    
                    // Creăm marker pentru locația de acasă
                    const homeGraphic = new Graphic({
                        geometry: homePoint,
                        symbol: {
                            type: "simple-marker",
                            color: "blue", // Albastru pentru locația de acasă
                            size: "12px",
                            outline: {
                                color: [255, 255, 255],
                                width: 2
                            }
                        },
                        attributes: {
                            title: "Locația ta de acasă",
                            description: homeLocation.adresa_completa
                        },
                        popupTemplate: {
                            title: "{title}",
                            content: "{description}"
                        }
                    });
                    
                    // Adăugăm marker-ul pentru acasă
                    graphicsLayer.add(homeGraphic);
                    
                    // Creăm punctul pentru locația concediului
                    const concediuPoint = new Point({
                        longitude: nextConcediu.longitudine,
                        latitude: nextConcediu.latitudine
                    });
                    
                    // Creăm marker pentru locația concediului
                    const concediuGraphic = new Graphic({
                        geometry: concediuPoint,
                        symbol: {
                            type: "simple-marker",
                            color: accentColor, // Culoarea accentului pentru concediu
                            size: "15px",
                            outline: {
                                color: [255, 255, 255],
                                width: 2
                            }
                        },
                        attributes: {
                            title: "Destinația concediului: " + nextConcediu.locatie,
                            description: "Adresa: " + nextConcediu.adresa_completa +
                                       "<br>Perioada: " + formatDate(nextConcediu.start_c) + 
                                       " - " + formatDate(nextConcediu.end_c)
                        },
                        popupTemplate: {
                            title: "{title}",
                            content: "{description}"
                        }
                    });
                    
                    // Adăugăm marker-ul pentru concediu
                    graphicsLayer.add(concediuGraphic);
                    
                    // Ajustăm vizualizarea pentru a include ambele locații
                    view.goTo({
                        target: [homePoint, concediuPoint],
                        padding: {
                            top: 100,
                            bottom: 100,
                            left: 350,
                            right: 100
                        }
                    });
                }
                
                // Handler pentru butonul "Generează rută"
                generateRouteBtn.addEventListener("click", async function() {
                    if (!homeLocation || !nextConcediu) {
                        afișareMesaj('eroare', "Te rog să încarci datele mai întâi.");
                        return;
                    }
                    
                    // Afișăm indicatorul de încărcare
                    loadingSpinner.style.display = "block";
                    afișareMesaj('normal', "Se calculează ruta...");
                    
                    try {
                        // Creăm punctele pentru locații
                        const homePoint = new Point({
                            longitude: homeLocation.longitudine,
                            latitude: homeLocation.latitudine
                        });
                        
                        const concediuPoint = new Point({
                            longitude: nextConcediu.longitudine,
                            latitude: nextConcediu.latitudine
                        });
                        
                        // Parametri pentru calculul rutei
                        const routeParams = new RouteParameters({
                            stops: new FeatureSet({
                                features: [
                                    new Graphic({ geometry: homePoint }),  // Locația de acasă
                                    new Graphic({ geometry: concediuPoint }) // Locația concediului
                                ]
                            }),
                            directionsLanguage: "ro", // Indicații în limba română
                            returnDirections: true,   // Returnează indicațiile de direcții
                            outSpatialReference: {    // Folosim același sistem de referință ca view-ul
                                wkid: view.spatialReference.wkid
                            }
                        });
                        
                        // Calculăm ruta
                        const routeResult = await route.solve(routeUrl, routeParams);
                        
                        // Procesăm rezultatele
                        if (routeResult && routeResult.routeResults && routeResult.routeResults.length > 0) {
                            // Păstrăm doar markerii
                            const points = [];
                            graphicsLayer.graphics.forEach(graphic => {
                                if (graphic.geometry.type === "point") {
                                    points.push(graphic);
                                }
                            });
                            
                            graphicsLayer.removeAll();
                            
                            // Adăugăm înapoi markerii
                            points.forEach(point => {
                                graphicsLayer.add(point);
                            });
                            
                            // Adăugăm graficul rutei
                            routeResult.routeResults.forEach(result => {
                                // Setăm simbolul pentru rută
                                result.route.symbol = {
                                    type: "simple-line",
                                    color: accentColor,
                                    width: 4
                                };
                                
                                // Adăugăm ruta pe hartă
                                graphicsLayer.add(result.route);
                            });
                            
                            // Afișăm indicațiile de direcții
                            if (routeResult.routeResults[0].directions &&
                                routeResult.routeResults[0].directions.features) {
                                
                                // Creăm un container pentru indicații
                                const directions = document.createElement("div");
                                directions.className = "esri-widget esri-widget--panel esri-directions__scroller";
                                directions.style.margin = "10px";
                                directions.style.padding = "15px";
                                directions.style.backgroundColor = "<%=sidebar%>";
                                directions.style.color = "<%=text%>";
                                directions.style.borderRadius = "8px";
                                directions.style.maxHeight = "300px";
                                directions.style.overflowY = "auto";
                                directions.style.boxShadow = "0 2px 8px rgba(0,0,0,0.2)";
                                
                                // Adăugăm titlul
                                const title = document.createElement("h3");
                                title.style.color = "<%=accent%>";
                                title.style.marginTop = "0";
                                title.style.fontSize = "16px";
                                title.textContent = "Indicații de direcții către " + nextConcediu.locatie;
                                directions.appendChild(title);
                                
                                // Adăugăm lista de indicații
                                const list = document.createElement("ol");
                                list.style.paddingLeft = "25px";
                                list.style.margin = "10px 0";
                                
                                // Procesăm fiecare indicație
                                routeResult.routeResults[0].directions.features.forEach(feature => {
                                    const item = document.createElement("li");
                                    item.style.marginBottom = "8px";
                                    item.style.fontSize = "14px";
                                    
                                    // Formatare conținut
                                    const kmText = (feature.attributes.length.toFixed(2) + " km");
                                    item.innerHTML = feature.attributes.text +
                                        " <span style=\"color:" + accentColor + "; font-weight:bold;\">(" + kmText + ")</span>";
                                    
                                    list.appendChild(item);
                                });
                                
                                directions.appendChild(list);
                                
                                // Adăugăm informații despre distanță totală și timp
                                const summary = document.createElement("div");
                                summary.style.marginTop = "15px";
                                summary.style.paddingTop = "10px";
                                summary.style.borderTop = "1px solid " + "<%=clr%>";
                                summary.style.fontSize = "14px";
                                
                                // Calculăm distanța și timpul total
                                const totalLength = routeResult.routeResults[0].directions.totalLength;
                                const totalTime = routeResult.routeResults[0].directions.totalTime;
                                
                                // Convertim timpul din minute în ore și minute
                                const hours = Math.floor(totalTime / 60);
                                const minutes = Math.round(totalTime % 60);
                                
                                // Formatare text
                                let timeText;
                                if (hours > 0) {
                                    const hoursText = hours == 1 ? 'oră' : 'ore';
                                    const minutesText = minutes == 1 ? 'minut' : 'minute';
                                    timeText = hours + " " + hoursText + " și " + minutes + " " + minutesText;
                                } else {
                                    const minutesText = minutes == 1 ? 'minut' : 'minute';
                                    timeText = minutes + " " + minutesText;
                                }
                                
                                // Adăugăm informații despre zile rămase
                                let daysText = "";
                                if (nextConcediu.zile_ramase > 0) {
                                    const zileText = nextConcediu.zile_ramase == 1 ? 'zi' : 'zile';
                                    daysText = `<p><strong>Concediul începe în:</strong> ${nextConcediu.zile_ramase} ${zileText}</p>`;
                                } else if (nextConcediu.zile_ramase == 0) {
                                    daysText = "<p><strong>Concediul începe:</strong> Astăzi!</p>";
                                } else {
                                    daysText = "<p><strong>Concediul:</strong> Este în desfășurare</p>";
                                }
                                
                                summary.innerHTML = 
                                    "<p><strong>Distanță totală:</strong> " + totalLength.toFixed(2) + " km</p>" +
                                    "<p><strong>Timp estimat:</strong> " + timeText + "</p>" +
                                    daysText +
                                    "<p><strong>Plecare:</strong> <span class='date-display'>" + formatDate(nextConcediu.start_c) + "</span></p>" +
                                    "<p><strong>Întoarcere:</strong> <span class='date-display'>" + formatDate(nextConcediu.end_c) + "</span></p>";
                                directions.appendChild(summary);
                                
                                // Adăugăm containerul de indicații în interfața utilizator
                                view.ui.empty("top-right");
                                view.ui.add(directions, "top-right");
                                
                                // Zoom la extinderea rutei cu padding
                                view.goTo({
                                    target: routeResult.routeResults[0].route.geometry.extent,
                                    padding: {
                                        top: 100,
                                        bottom: 100,
                                        left: 350, // Pad mai mare în stânga pentru panoul de control
                                        right: 350 // Pad mai mare în dreapta pentru indicații
                                    }
                                });
                                
                                afișareMesaj('succes', "Ruta a fost generată cu succes!");
                            }
                        } else {
                            afișareMesaj('eroare', "Nu s-a putut genera ruta între locațiile specificate.");
                        }
                    } catch (error) {
                        console.error("Eroare la generarea rutei:", error);
                        afișareMesaj('eroare', "Eroare la generarea rutei: " + error.message);
                    } finally {
                        // Ascundem indicatorul de încărcare
                        loadingSpinner.style.display = "none";
                    }
                });
                
                // Handler pentru butonul "Resetează harta"
                resetBtn.addEventListener("click", function() {
                    // Curățăm toate graficele
                    graphicsLayer.removeAll();
                    
                    // Resetăm interfața utilizator
                    view.ui.empty("top-right");
                    
                    // Resetăm vizualizarea hărții
                    view.goTo({
                        center: [25, 45],
                        zoom: 6
                    });
                    
                    // Dacă avem datele, afișăm din nou locațiile
                    if (homeLocation && nextConcediu) {
                        displayLocationsOnMap();
                    }
                    
                    // Resetăm mesajul de status
                    afișareMesaj('normal', "Hartă resetată. Poți genera ruta din nou.");
                });
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