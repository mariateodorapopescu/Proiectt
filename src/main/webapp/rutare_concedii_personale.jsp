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
    <title>Rutare către concediile mele</title>
    
    <style>
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
            /* Previne comportamentul de zoom la scroll */
            touch-action: none;
        }
        
        /* Folosim CSS pentru a opri scroll wheel zoom */
        #viewDiv {
            -ms-touch-action: none;
            touch-action: none;
        }
        
        .esri-view {
            touch-action: none !important;
        }
        
        .form-container {
            max-height: 90vh;
            overflow-y: auto;
            position: fixed;
            top: 10px;
            left: 10px;
            z-index: 100;
            padding: 12px;
            background: <%=sidebar%>;
            color: <%=text%>;
            border-color: <%=clr%>;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            width: 90%;
            max-width: 320px;
            font-size: 14px;
        }
        
        .form-container h3 {
            margin-top: 0;
            margin-bottom: 8px;
            font-size: 16px;
        }
        
        .form-container select {
            display: block;
            margin-bottom: 8px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            background-color: <%=clr%>;
            color: <%=text%>;
        }
        
        .form-container button {
            display: block;
            margin-top: 10px;
            margin-bottom: 8px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            background-color: <%=accent%>;
            color: white;
            cursor: pointer;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .form-container button:hover {
            opacity: 0.9;
        }
        
        .form-container button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
            box-shadow: none;
        }
        
        .details-panel {
            background-color: <%=card%>;
            color: <%=text%>;
            padding: 8px 10px;
            border-radius: 8px;
            margin-top: 8px;
            font-size: 13px;
        }
        
        .details-panel h4 {
            margin-top: 0;
            margin-bottom: 5px;
            color: <%=accent%>;
            border-bottom: 1px solid <%=clr%>;
            padding-bottom: 3px;
            font-size: 14px;
        }
        
        .concediu-info {
            margin-bottom: 4px;
        }
        
        .badge {
            display: inline-block;
            padding: 2px 6px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
            color: white;
            margin-right: 4px;
            margin-bottom: 4px;
        }
        
        .badge-distance {
            background-color: <%=accent%>;
        }

        .badge-current {
            background-color: #4CAF50;
        }

        .badge-concediu {
            background-color: #E91E63;
        }
        
        #loadingSpinner {
            display: none;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 200;
            background-color: rgba(255, 255, 255, 0.8);
            padding: 16px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
            text-align: center;
        }
        
        #loadingSpinner p {
            margin-bottom: 10px;
            font-weight: bold;
            font-size: 14px;
        }
        
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 8px;
            border-radius: 5px;
            margin-top: 8px;
            display: none;
            font-size: 12px;
        }

        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 8px;
            border-radius: 5px;
            margin-top: 8px;
            display: none;
            font-size: 12px;
        }
        
        .zoom-controls {
            display: flex;
            gap: 8px;
        }
        
        .zoom-controls button {
            flex: 1;
            padding: 8px;
            margin-top: 0;
            font-size: 12px;
        }
        
        .directions-panel {
            margin: 10px;
            padding: 12px;
            background-color: <%=sidebar%>;
            color: <%=text%>;
            border-radius: 8px;
            max-height: 400px;
            width: 90%;
            max-width: 320px;
            overflow-y: auto;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            position: fixed;
            top: 10px;
            right: 10px;
            font-size: 13px;
            z-index: 100;
        }
        
        .directions-panel h3 {
            color: <%=accent%>;
            margin-top: 0;
            margin-bottom: 8px;
            font-size: 15px;
        }
        
        .directions-panel ol {
            padding-left: 20px;
            margin: 8px 0;
        }
        
        .directions-panel li {
            margin-bottom: 6px;
            font-size: 12px;
        }
        
        .directions-summary {
            margin-top: 10px;
            padding-top: 8px;
            border-top: 1px solid <%=clr%>;
            font-size: 12px;
        }
        
        .close-btn {
            position: absolute;
            top: 8px;
            right: 8px;
            background: transparent;
            border: none;
            color: <%=accent%>;
            font-size: 16px;
            cursor: pointer;
            padding: 0;
            line-height: 1;
        }
        
        /* Media queries pentru dispozitive mobile */
        @media (max-width: 480px) {
            .form-container {
                width: calc(100% - 20px);
                max-width: none;
                font-size: 13px;
            }
            
            .form-container h3 {
                font-size: 15px;
            }
            
            .details-panel {
                padding: 6px 8px;
                font-size: 12px;
            }
            
            .details-panel h4 {
                font-size: 13px;
            }
            
            .badge {
                font-size: 10px;
                padding: 2px 5px;
            }
            
            .directions-panel {
                width: calc(100% - 20px);
                max-width: none;
                font-size: 12px;
            }
            
            .directions-panel h3 {
                font-size: 14px;
            }
            
            .directions-panel li,
            .directions-summary p {
                font-size: 11px;
            }
        }
        
        ::-webkit-scrollbar {
            display: none;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    <div class="form-container">
        <h3 style="color: <%=accent%>;">Rutare către concediile mele</h3>
        
        <div class="details-panel">
            <h4>Despre această funcționalitate</h4>
            <p style="margin-top: 0; font-size: 12px;">
                Acest instrument îți permite să vizualizezi și să generezi ruta către locațiile concediilor tale personale.
            </p>
        </div>
        
        <div class="details-panel">
            <h4>Selectează un concediu</h4>
            <select id="concediuSelect" class="login__input">
                <option value="" disabled selected>Alege un concediu...</option>
                <!-- Opțiunile vor fi încărcate dinamic -->
            </select>
        </div>
        
        <div id="concediuDetails" class="details-panel" style="display: none;">
            <h4>Detalii concediu</h4>
            <div class="badge badge-concediu">Concediu</div>
            <div id="concediuInfo"></div>
        </div>
        
        <div class="details-panel">
            <h4>Control Zoom</h4>
            <div class="zoom-controls">
                <button id="zoomInBtn">
                    <i class="ri-zoom-in-line"></i> Zoom In
                </button>
                <button id="zoomOutBtn">
                    <i class="ri-zoom-out-line"></i> Zoom Out
                </button>
            </div>
            <p style="font-size: 11px; margin-top: 5px; color: <%=text%>;">Notă: Scroll-ul pe hartă este dezactivat pentru o navigare mai ușoară pe pagină.</p>
        </div>
        
        <button id="locateMeBtn" class="login__button">
            <i class="ri-map-pin-user-line"></i> Localizează-mă
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
        
        <p id="statusMessage" style="color:<%=text%>; margin-top: 10px; font-size: 12px;"></p>
        <div id="errorMsg" class="error-message"></div>
        <div id="successMsg" class="success-message"></div>
    </div>

    <div id="loadingSpinner">
        <p>Se încarcă...</p>
        <div style="width: 50px; height: 50px; border: 5px solid <%=clr%>; border-top: 5px solid <%=accent%>; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto;"></div>
    </div>

    <script>
        // Prevenim efectul de zoom la scroll direct în browser
        document.addEventListener('DOMContentLoaded', function() {
            // Prevenim scroll-ul pe div-ul hărții
            const mapDiv = document.getElementById('viewDiv');
            
            mapDiv.addEventListener('wheel', function(e) {
                e.preventDefault();
                return false;
            }, { passive: false });
            
            // Adăugăm un event listener pentru a asigura că toate elementele ArcGIS sunt încărcate
            window.addEventListener('load', function() {
                setTimeout(function() {
                    const esriElements = document.querySelectorAll('.esri-view-surface');
                    esriElements.forEach(function(element) {
                        element.addEventListener('wheel', function(e) {
                            e.preventDefault();
                            return false;
                        }, { passive: false });
                    });
                }, 1000); // Așteptăm 1 secundă pentru încărcarea elementelor ArcGIS
            });
        });
        
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
            const concediuSelect = document.getElementById("concediuSelect");
            const concediuDetails = document.getElementById("concediuDetails");
            const concediuInfo = document.getElementById("concediuInfo");
            const locateMeBtn = document.getElementById("locateMeBtn");
            const generateRouteBtn = document.getElementById("generateRouteBtn");
            const resetBtn = document.getElementById("resetBtn");
            const zoomInBtn = document.getElementById("zoomInBtn");
            const zoomOutBtn = document.getElementById("zoomOutBtn");
            const loadingSpinner = document.getElementById("loadingSpinner");
            const statusMessage = document.getElementById("statusMessage");
            const errorMsg = document.getElementById("errorMsg");
            const successMsg = document.getElementById("successMsg");
            
            // Variabile pentru stocarea datelor
            let currentLocation = null;
            let selectedConcediuLocation = null;
            
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
            
            // Încarcă concediile utilizatorului
            loadConcediiPersonale();
            
            // Inițializare hartă ArcGIS
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/layers/GraphicsLayer",
                "esri/geometry/Point",
                "esri/geometry/Polyline",
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
                Polyline,
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
                
                // Handler pentru selectarea unui concediu
                concediuSelect.addEventListener("change", function() {
                    const selectedConcediu = this.options[this.selectedIndex];
                    
                    if (selectedConcediu.value) {
                        // Extragem informațiile din atributele opțiunii
                        const lat = parseFloat(selectedConcediu.getAttribute("data-lat"));
                        const lon = parseFloat(selectedConcediu.getAttribute("data-lon"));
                        const motiv = selectedConcediu.getAttribute("data-motiv");
                        const locatie = selectedConcediu.getAttribute("data-locatie");
                        const perioada = selectedConcediu.getAttribute("data-perioada");
                        const tip = selectedConcediu.getAttribute("data-tip");
                        
                        // Verificăm dacă avem coordonate valide
                        if (!isNaN(lat) && !isNaN(lon)) {
                            // Creăm un punct pentru locația concediului
                            selectedConcediuLocation = new Point({
                                longitude: lon,
                                latitude: lat
                            });
                            
                            // Afișăm detaliile concediului
                            concediuDetails.style.display = "block";
                            concediuInfo.innerHTML = `
                                <div class="concediu-info"><strong>Motiv:</strong> ${motiv}</div>
                                <div class="concediu-info"><strong>Locație:</strong> ${locatie}</div>
                                <div class="concediu-info"><strong>Perioada:</strong> ${perioada}</div>
                                <div class="concediu-info"><strong>Tip:</strong> ${tip}</div>
                            `;
                            
                            // Ștergem markerii anteriori pentru concedii
                            graphicsLayer.graphics.forEach(function(graphic) {
                                if (graphic.attributes && graphic.attributes.title === "Locație concediu") {
                                    graphicsLayer.remove(graphic);
                                }
                            });
                            
                            // Creăm un marker pentru locația concediului
                            const pointGraphic = new Graphic({
                                geometry: selectedConcediuLocation,
                                symbol: {
                                    type: "simple-marker",
                                    color: "#E91E63", // Roz pentru locația concediului
                                    size: "12px",
                                    outline: {
                                        color: [255, 255, 255],
                                        width: 2
                                    }
                                },
                                attributes: {
                                    title: "Locație concediu",
                                    description: motiv
                                },
                                popupTemplate: {
                                    title: "{title}",
                                    content: "{description}"
                                }
                            });
                            
                            // Adăugăm markerul pe hartă
                            graphicsLayer.add(pointGraphic);
                            
                            // Zoom și centrare pe locația concediului
                            view.goTo({
                                center: [lon, lat],
                                zoom: 12
                            }, {
                                duration: 1000,
                                easing: "ease-in-out"
                            });
                            
                            // Activăm butonul de generare rută dacă avem și locația curentă
                            if (currentLocation) {
                                generateRouteBtn.disabled = false;
                            }
                            
                            afișareMesaj('succes', "Concediu selectat cu succes!");
                        } else {
                            // Nu avem coordonate valide
                            afișareMesaj('eroare', "Acest concediu nu are coordonate geografice definite.");
                            selectedConcediuLocation = null;
                            generateRouteBtn.disabled = true;
                        }
                    } else {
                        // Nu a fost selectat niciun concediu
                        concediuDetails.style.display = "none";
                        selectedConcediuLocation = null;
                        generateRouteBtn.disabled = true;
                    }
                });
                
                // Handler pentru butonul "Localizează-mă"
                locateMeBtn.addEventListener("click", function() {
                    if (navigator.geolocation) {
                        loadingSpinner.style.display = "block";
                        afișareMesaj('normal', "Se obține locația...");
                        
                        navigator.geolocation.getCurrentPosition(
                            function(position) {
                                loadingSpinner.style.display = "none";
                                const longitude = position.coords.longitude;
                                const latitude = position.coords.latitude;
                                
                                // Salvăm locația curentă
                                currentLocation = new Point({
                                    longitude: longitude,
                                    latitude: latitude
                                });
                                
                                // Ștergem markerul anterior pentru locația curentă
                                graphicsLayer.graphics.forEach(function(graphic) {
                                    if (graphic.attributes && graphic.attributes.title === "Locația mea") {
                                        graphicsLayer.remove(graphic);
                                    }
                                });
                                
                                // Creăm un marker pentru locația curentă
                                const pointGraphic = new Graphic({
                                    geometry: currentLocation,
                                    symbol: {
                                        type: "simple-marker",
                                        color: "#4CAF50", // Verde pentru locația curentă
                                        size: "12px",
                                        outline: {
                                            color: [255, 255, 255],
                                            width: 2
                                        }
                                    },
                                    attributes: {
                                        title: "Locația mea",
                                        description: "Poziția mea curentă"
                                    },
                                    popupTemplate: {
                                        title: "{title}",
                                        content: "{description}"
                                    }
                                });
                                
                                // Adăugăm markerul pe hartă
                                graphicsLayer.add(pointGraphic);
                                
                                // Dacă avem și o locație de concediu selectată, ajustăm vizualizarea
                                if (selectedConcediuLocation) {
                                    // Calculăm centrul dintre cele două puncte
                                    const centerLat = (latitude + selectedConcediuLocation.latitude) / 2;
                                    const centerLon = (longitude + selectedConcediuLocation.longitude) / 2;
                                    
                                    // Calculăm distanța aproximativă (în grade)
                                    const distanceLat = Math.abs(latitude - selectedConcediuLocation.latitude);
                                    const distanceLon = Math.abs(longitude - selectedConcediuLocation.longitude);
                                    
                                    // Determinăm un nivel de zoom adecvat bazat pe distanță
                                    let zoomLevel;
                                    const maxDistance = Math.max(distanceLat, distanceLon) * 111; // Aproximativ km
                                    
                                    if (maxDistance > 100) {
                                        zoomLevel = 8;
                                    } else if (maxDistance > 50) {
                                        zoomLevel = 9;
                                    } else if (maxDistance > 20) {
                                        zoomLevel = 10;
                                    } else if (maxDistance > 10) {
                                        zoomLevel = 11;
                                    } else if (maxDistance > 5) {
                                        zoomLevel = 12;
                                    } else if (maxDistance > 2) {
                                        zoomLevel = 13;
                                    } else if (maxDistance > 1) {
                                        zoomLevel = 14;
                                    } else {
                                        zoomLevel = 15;
                                    }
                                    
                                    // Aplicăm zoom-ul pentru a include ambele locații
                                    view.goTo({
                                        center: [centerLon, centerLat],
                                        zoom: zoomLevel
                                    }, {
                                        duration: 1000,
                                        easing: "ease-in-out"
                                    });
                                    
                                    // Activăm butonul de generare rută
                                    generateRouteBtn.disabled = false;
                                } else {
                                    // Doar locația curentă
                                    view.goTo({
                                        center: [longitude, latitude],
                                        zoom: 15
                                    }, {
                                        duration: 1000,
                                        easing: "ease-in-out"
                                    });
                                }
                                
                                afișareMesaj('succes', "Localizat cu succes!");
                            },
                            function(error) {
                                loadingSpinner.style.display = "none";
                                let errorMessage = "Eroare la obținerea poziției.";
                                
                                switch(error.code) {
                                    case error.PERMISSION_DENIED:
                                        errorMessage = "Accesul la geolocalizare a fost refuzat. Verifică permisiunile browser-ului.";
                                        break;
                                    case error.POSITION_UNAVAILABLE:
                                        errorMessage = "Informațiile de localizare nu sunt disponibile.";
                                        break;
                                    case error.TIMEOUT:
                                        errorMessage = "Cererea de localizare a expirat.";
                                        break;
                                    case error.UNKNOWN_ERROR:
                                        errorMessage = "A apărut o eroare necunoscută la determinarea locației.";
                                        break;
                                }
                                
                                afișareMesaj('eroare', errorMessage);
                                console.error("Eroare la geolocație:", error);
                            },
                            {
                                enableHighAccuracy: true,
                                timeout: 10000,
                                maximumAge: 0
                            }
                        );
                    } else {
                        afișareMesaj('eroare', "Geolocația nu este suportată de acest browser.");
                    }
                });
                
                // Handler pentru butonul "Generează rută"
                generateRouteBtn.addEventListener("click", function() {
                    if (!currentLocation) {
                        afișareMesaj('eroare', "Te rog să te localizezi mai întâi.");
                        return;
                    }
                    
                    if (!selectedConcediuLocation) {
                        afișareMesaj('eroare', "Te rog să selectezi un concediu cu locație definită.");
                        return;
                    }
                    
                    // Afișăm indicatorul de încărcare
                    loadingSpinner.style.display = "block";
                    afișareMesaj('normal', "Se calculează ruta...");
                    
                    // Obținem coordonatele punctelor de start și destinație
                    const startPoint = currentLocation;
                    const endPoint = selectedConcediuLocation;
                    
                    // Creăm o linie simplă între cele două puncte (ca rezervă)
                    const straightLine = new Polyline({
                        paths: [
                            [startPoint.longitude, startPoint.latitude],
                            [endPoint.longitude, endPoint.latitude]
                        ],
                        spatialReference: view.spatialReference
                    });
                    
                    // Parametri pentru calculul rutei
                    const routeParams = new RouteParameters({
                        stops: new FeatureSet({
                            features: [
                                new Graphic({ geometry: startPoint }),
                                new Graphic({ geometry: endPoint })
                            ]
                        }),
                        directionsLanguage: "ro",
                        returnDirections: true
                    });
                    
                    // Încercăm să obținem ruta
                    route.solve(routeUrl, routeParams)
                        .then(function(result) {
                            // Procesăm rezultatele
                            if (result && result.routeResults && result.routeResults.length > 0) {
                                const routeResult = result.routeResults[0];
                                
                                // Curățăm graficele vechi (linii - rute)
                                graphicsLayer.graphics.forEach(function(graphic) {
                                    if (graphic.geometry && 
                                        (graphic.geometry.type === "polyline" || 
                                         graphic.geometry instanceof Polyline)) {
                                        graphicsLayer.remove(graphic);
                                    }
                                });
                                
                                // Adăugăm ruta pe hartă
                                const routeGraphic = new Graphic({
                                    geometry: routeResult.route.geometry,
                                    symbol: {
                                        type: "simple-line",
                                        color: accentColor,
                                        width: 4
                                    }
                                });
                                
                                graphicsLayer.add(routeGraphic);
                                
                                // Afișăm indicațiile
                                showDirections(result.routeResults[0].directions);
                                
                                // Calculăm centrul și zoom-ul pentru extinderea rutei
                                const extent = routeResult.route.geometry.extent;
                                const centerX = (extent.xmin + extent.xmax) / 2;
                                const centerY = (extent.ymin + extent.ymax) / 2;
                                
                                // Determinăm un nivel de zoom adecvat
                                const width = extent.xmax - extent.xmin;
                                const height = extent.ymax - extent.ymin;
                                const maxDimension = Math.max(width, height) * 111; // Aproximativ km
                                
                                let zoomLevel = 12; // Valoare implicită
                                
                                if (maxDimension > 100) {
                                    zoomLevel = 8;
                                } else if (maxDimension > 50) {
                                    zoomLevel = 9;
                                } else if (maxDimension > 20) {
                                    zoomLevel = 10;
                                } else if (maxDimension > 10) {
                                    zoomLevel = 11;
                                } else if (maxDimension > 5) {
                                    zoomLevel = 12;
                                } else if (maxDimension > 2) {
                                    zoomLevel = 13;
                                } else if (maxDimension > 1) {
                                    zoomLevel = 14;
                                } else {
                                    zoomLevel = 15;
                                }
                                
                                // Aplicăm zoom pentru a include întreaga rută
                                view.goTo({
                                    center: [centerX, centerY],
                                    zoom: zoomLevel
                                }, {
                                    duration: 1000,
                                    easing: "ease-in-out"
                                });
                                
                                afișareMesaj('succes', "Ruta a fost generată cu succes!");
                            } else {
                                // Dacă nu avem rută, afișăm linia directă
                                const directLineGraphic = new Graphic({
                                    geometry: straightLine,
                                    symbol: {
                                        type: "simple-line",
                                        color: accentColor,
                                        width: 4,
                                        style: "dash"
                                    }
                                });
                                
                                graphicsLayer.add(directLineGraphic);
                                
                                // Centrăm între puncte
                                const centerX = (startPoint.longitude + endPoint.longitude) / 2;
                                const centerY = (startPoint.latitude + endPoint.latitude) / 2;
                                
                                view.goTo({
                                    center: [centerX, centerY],
                                    zoom: 12
                                }, {
                                    duration: 1000,
                                    easing: "ease-in-out"
                                });
                                
                                afișareMesaj('eroare', "Nu s-a putut genera ruta. Se afișează linia directă.");
                            }
                            
                            loadingSpinner.style.display = "none";
                        })
                        .catch(function(error) {
                            console.error("Eroare la calcularea rutei:", error);
                            
                            // În caz de eroare, afișăm linia directă
                            const directLineGraphic = new Graphic({
                                geometry: straightLine,
                                symbol: {
                                    type: "simple-line",
                                    color: accentColor,
                                    width: 4,
                                    style: "dash"
                                }
                            });
                            
                            graphicsLayer.add(directLineGraphic);
                            
                            // Centrăm între puncte
                            const centerX = (startPoint.longitude + endPoint.longitude) / 2;
                            const centerY = (startPoint.latitude + endPoint.latitude) / 2;
                            
                            view.goTo({
                                center: [centerX, centerY],
                                zoom: 12
                            }, {
                                duration: 1000,
                                easing: "ease-in-out"
                            });
                            
                            loadingSpinner.style.display = "none";
                            afișareMesaj('eroare', "Eroare la generarea rutei: " + error.message);
                        });
                });
                
                // Funcție pentru afișarea indicațiilor
                function showDirections(directions) {
                    if (!directions || !directions.features || directions.features.length === 0) {
                        return;
                    }
                    
                    // Curățăm indicațiile anterioare
                    document.querySelectorAll('.directions-panel').forEach(el => el.remove());
                    
                    // Creăm un container pentru indicații
                    const directionsPanel = document.createElement("div");
                    directionsPanel.className = "directions-panel";
                    
                    // Titlu
                    const title = document.createElement("h3");
                    title.textContent = "Indicații de direcții";
                    directionsPanel.appendChild(title);
                    
                    // Buton de închidere
                    const closeButton = document.createElement("button");
                    closeButton.className = "close-btn";
                    closeButton.innerHTML = "✖";
                    closeButton.addEventListener("click", function() {
                        directionsPanel.remove();
                    });
                    directionsPanel.appendChild(closeButton);
                    
                    // Lista de indicații
                    const list = document.createElement("ol");
                    list.style.paddingLeft = "20px";
                    
                    directions.features.forEach(function(feature) {
                        const item = document.createElement("li");
                        const text = feature.attributes.text;
                        const distance = feature.attributes.length;
                        
                        item.innerHTML = text + 
                            " <span style='color:" + accentColor + ";font-weight:bold;'>(" + 
                            distance.toFixed(2) + " km)</span>";
                            
                        list.appendChild(item);
                    });
                    
                    directionsPanel.appendChild(list);
                    
                    // Rezumat
                    const summary = document.createElement("div");
                    summary.className = "directions-summary";
                    
                    const totalDistance = directions.totalLength;
                    const totalMinutes = directions.totalTime;
                    
                    // Convertim timpul în ore și minute
                    const hours = Math.floor(totalMinutes / 60);
                    const minutes = Math.round(totalMinutes % 60);
                    
                    let timeText = "";
                    if (hours > 0) {
                        timeText = hours + " " + (hours === 1 ? "oră" : "ore");
                        if (minutes > 0) {
                            timeText += " și " + minutes + " " + (minutes === 1 ? "minut" : "minute");
                        }
                    } else {
                        timeText = minutes + " " + (minutes === 1 ? "minut" : "minute");
                    }
                    
                    summary.innerHTML = 
                        "<p><strong>Distanță totală:</strong> " + totalDistance.toFixed(2) + " km</p>" +
                        "<p><strong>Timp estimat:</strong> " + timeText + "</p>";
                        
                    directionsPanel.appendChild(summary);
                    
                    // Adăugăm la pagină
                    document.body.appendChild(directionsPanel);
                }
                
                // Handler pentru butonul "Resetează harta"
                resetBtn.addEventListener("click", function() {
                    // Curățăm toate graficele
                    graphicsLayer.removeAll();
                    
                    // Curățăm indicațiile
                    document.querySelectorAll('.directions-panel').forEach(el => el.remove());
                    
                    // Resetăm vizualizarea hărții
                    view.goTo({
                        center: [25, 45],
                        zoom: 6
                    }, {
                        duration: 1000,
                        easing: "ease-in-out"
                    });
                    
                    // Resetăm variabilele
                    currentLocation = null;
                    
                    // Dezactivăm butonul de generare rută
                    generateRouteBtn.disabled = true;
                    
                    // Resetăm mesajul de status
                    afișareMesaj('normal', "Hartă resetată.");
                    
                    // Păstrăm selecția concediului dacă există
                    if (concediuSelect.selectedIndex > 0) {
                        const event = new Event('change');
                        concediuSelect.dispatchEvent(event);
                    }
                });
                
                // Handler-i pentru butoanele de zoom
                zoomInBtn.addEventListener('click', function() {
                    // Păstrăm centrul actual și doar mărim nivelul de zoom
                    const currentCenter = view.center;
                    view.goTo({
                        target: currentCenter,
                        zoom: view.zoom + 1
                    }, {
                        duration: 500
                    });
                });
                
                zoomOutBtn.addEventListener('click', function() {
                    // Păstrăm centrul actual și doar micșorăm nivelul de zoom
                    const currentCenter = view.center;
                    view.goTo({
                        target: currentCenter,
                        zoom: view.zoom - 1
                    }, {
                        duration: 500
                    });
                });
            });
            
            // Funcție pentru încărcarea concediilor personale
            function loadConcediiPersonale() {
                fetch(`GetConcediiPersonaleServlet?userId=<%=id%>`)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error("Eroare la încărcarea concediilor");
                        }
                        return response.json();
                    })
                    .then(data => {
                        // Verificăm dacă avem date
                        if (!data || data.length === 0) {
                            afișareMesaj('eroare', "Nu există concedii cu locații definite.");
                            return;
                        }
                        
                        // Populăm dropdown-ul cu concedii
                        concediuSelect.innerHTML = '<option value="" disabled selected>Alege un concediu...</option>';
                        
                        // Adăugăm fiecare concediu în dropdown
                        data.forEach(concediu => {
                            // Verificăm dacă concediul are coordonate
                            if (concediu.latitudine && concediu.longitudine) {
                                const option = document.createElement("option");
                                option.value = concediu.id;
                                option.textContent = `${concediu.motiv} (${concediu.start_c} - ${concediu.end_c})`;
                                
                                // Stocăm detaliile concediului ca atribute data-*
                                option.setAttribute("data-lat", concediu.latitudine);
                                option.setAttribute("data-lon", concediu.longitudine);
                                option.setAttribute("data-motiv", concediu.motiv);
                                option.setAttribute("data-locatie", concediu.locatie);
                                option.setAttribute("data-perioada", `${concediu.start_c} - ${concediu.end_c}`);
                                option.setAttribute("data-tip", concediu.tip);
                                
                                concediuSelect.appendChild(option);
                            }
                        });
                        
                        // Verificăm dacă am adăugat vreun concediu în dropdown
                        if (concediuSelect.options.length <= 1) {
                            afișareMesaj('eroare', "Nu există concedii cu locații definite.");
                        } else {
                            afișareMesaj('succes', `${concediuSelect.options.length - 1} concedii disponibile.`);
                        }
                    })
                    .catch(error => {
                        console.error("Eroare la încărcarea concediilor:", error);
                        afișareMesaj('eroare', "Eroare la încărcarea concediilor: " + error.message);
                    });
            }
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