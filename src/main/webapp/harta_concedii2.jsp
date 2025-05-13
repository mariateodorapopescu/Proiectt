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
                    boolean isDirector = (ierarhie < 3);
                    boolean isSef = (ierarhie >= 4 && ierarhie <= 5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    // Obținem ID-ul concediului din URL
                    String idConcediu = request.getParameter("idcon");
                    if (idConcediu == null || idConcediu.isEmpty()) {
                        out.println("<script type='text/javascript'>");
                        out.println("alert('ID concediu lipsă!');");
                        out.println("window.location.href = 'concediinoisef.jsp?pag=1';");
                        out.println("</script>");
                        return;
                    }

                    // Obținem culorile temei utilizatorului
                    String accent = "#10439F";
                    String clr = "#d8d9e1";
                    String sidebar = "#ECEDFA";
                    String text = "#333";
                    String card = "#ECEDFA";
                    String hover = "#ECEDFA";
                    
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        String query = "SELECT * from teme where id_usr = ?";
                        try (PreparedStatement stmt = con.prepareStatement(query)) {
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
    <title>Selectare Atracție Turistică pentru Concediu</title>
    
    <!-- Fonturi și Stiluri -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
    <!-- ArcGIS API -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    
    <style>
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
        }
        
        body {
            top: 0;
            left: 0;
            position: fixed;
            width: 100vw;
            height: 100vh;
            padding: 0;
            margin: 0;
        }
        
        .form-container {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 100;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            max-width: 320px;
            max-height: 90vh;
            overflow-y: auto;
        }
        
        .form-container select, 
        .form-container input {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: calc(100% - 16px);
        }
        
        .form-container button {
            display: block;
            margin-bottom: 10px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
        }
        
        #detailsPanel {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 100;
            width: 300px;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            display: none;
        }
        
        .selected-location {
            margin-top: 15px;
            padding: 10px;
            border-radius: 5px;
            background-color: rgba(255, 255, 255, 0.2);
        }
        
        ::-webkit-scrollbar {
            display: none;
        }
        
        a, a:visited, a:hover, a:active {
            color: #eaeaea !important;
            text-decoration: none;
        }
        
        .success-message {
            color: #4caf50;
            margin-top: 10px;
            font-weight: bold;
        }
        
        .error-message {
            color: #f44336;
            margin-top: 10px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    
    <div class="form-container" style="background:<%=sidebar%>; color:<%=clr%>; border-color: <%=clr%>">
        <h3 style="color: <%=accent%>">Selectează o Atracție Turistică</h3>
        
        <label style="color:<%=text%>" class="login__label">Locație turistică</label>
        <select id="locationSelect" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" class="login__input">
            <option value="" disabled selected>Selectați o locație...</option>
        </select>
        
        <button id="locateMeBtn" style="margin-top:15px; box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>; color:white;">
            Localizare mea
        </button>
        
        <div class="selected-location" id="selectedLocation" style="background:<%=clr%>; color:<%=text%>; display:none;">
            <h4 style="margin-top:0; color:<%=accent%>">Locație selectată:</h4>
            <p id="locationName" style="margin-bottom:5px; font-weight:bold;"></p>
            <p id="locationCoords" style="font-size:12px; margin-top:0;"></p>
        </div>
        
        <button id="saveBtn" style="margin-top:15px; box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>; color:white;" disabled>
            Salvează această locație
        </button>
        
        <button style="margin-top:10px; box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>; color:white;">
            <a style="color: white !important;" href="concediinoisef.jsp?pag=1">Înapoi la concedii</a>
        </button>
        
        <p id="statusMessage" style="color:<%=text%>"></p>
    </div>
    
    <div id="detailsPanel" style="background:<%=sidebar%>; color:<%=text%>">
        <h3 style="color:<%=accent%>; margin-top:0;">Detalii Atracție</h3>
        <div id="detailsContent"></div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const idConcediu = '<%= idConcediu %>';
            let selectedLocationData = null;
            
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/layers/FeatureLayer",
                "esri/geometry/Point",
                "esri/rest/locator",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet"
            ], function(
                esriConfig,
                Map,
                MapView,
                Graphic,
                FeatureLayer,
                Point,
                locator,
                route,
                RouteParameters,
                FeatureSet
            ) {
                // Setăm cheia API ArcGIS
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";
                
                // Creăm harta de bază
                const map = new Map({
                    basemap: "arcgis-topographic"
                });
                
                // Inițializăm view-ul hărții
                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45], // Centrat pe România
                    zoom: 6
                });
                
                // Layer pentru atracții turistice
                const attractionsLayer = new FeatureLayer({
                    url: "https://services-eu1.arcgis.com/zci5bUiJ8olAal7N/arcgis/rest/services/OSM_Tourism_EU/FeatureServer",
                    title: "Atracții turistice",
                    popupTemplate: {
                        title: "{name}",
                        content: "Tip: {tourism}<br>Descriere: {description}"
                    },
                    outFields: ["*"]
                });
                
                // Adăugăm layer-ul pe hartă
                map.add(attractionsLayer);
                
                // Încărcăm lista de atracții turistice din server
                fetch("locactacs")
                    .then(response => response.json())
                    .then(data => {
                        const locationSelect = document.getElementById("locationSelect");
                        locationSelect.innerHTML = '<option value="" disabled selected>Selectați o locație...</option>';
                        
                        data.forEach(location => {
                            const option = document.createElement("option");
                            option.value = location.id;
                            option.textContent = location.nume;
                            option.setAttribute("data-lat", location.latitude);
                            option.setAttribute("data-lon", location.longitude);
                            locationSelect.appendChild(option);
                        });
                    })
                    .catch(error => {
                        console.error("Eroare la încărcarea atracțiilor turistice:", error);
                        document.getElementById("statusMessage").textContent = "Eroare la încărcarea atracțiilor turistice";
                        document.getElementById("statusMessage").className = "error-message";
                    });
                
                // Eveniment pentru selectarea unei locații din dropdown
                document.getElementById("locationSelect").addEventListener("change", function() {
                    const selectedOption = this.options[this.selectedIndex];
                    
                    if (selectedOption.value) {
                        // Citim coordonatele lat/lon din opțiunea selectată
                        const lat = parseFloat(selectedOption.getAttribute("data-lat"));
                        const lon = parseFloat(selectedOption.getAttribute("data-lon"));
                        
                        if (!isNaN(lat) && !isNaN(lon)) {
                            const selectedPoint = new Point({
                                longitude: lon,
                                latitude: lat
                            });
                            
                            // Salvăm datele locației selectate
                            selectedLocationData = {
                                id: selectedOption.value,
                                name: selectedOption.textContent,
                                latitude: lat,
                                longitude: lon
                            };
                            
                            // Afișăm informațiile despre locația selectată
                            document.getElementById("locationName").textContent = selectedOption.textContent;
                            document.getElementById("locationCoords").textContent = `Lat: ${lat.toFixed(6)}, Lon: ${lon.toFixed(6)}`;
                            document.getElementById("selectedLocation").style.display = "block";
                            
                            // Activăm butonul de salvare
                            document.getElementById("saveBtn").disabled = false;
                            
                            // Creare marker pentru locația selectată
                            const pointGraphic = new Graphic({
                                geometry: selectedPoint,
                                symbol: {
                                    type: "simple-marker",
                                    color: "<%= accent %>",
                                    size: "12px",
                                    outline: {
                                        color: [255, 255, 255],
                                        width: 2
                                    }
                                },
                                attributes: {
                                    title: selectedOption.textContent,
                                    location: "Atracție turistică"
                                },
                                popupTemplate: {
                                    title: "{title}",
                                    content: "{location}"
                                }
                            });
                            
                            // Eliminăm markerii anteriori și adăugăm unul nou
                            view.graphics.removeAll();
                            view.graphics.add(pointGraphic);
                            
                            // Zoom și centrare pe locația selectată
                            view.goTo({
                                target: selectedPoint,
                                zoom: 15
                            });
                        } else {
                            console.error("Coordonate invalide pentru locația selectată.");
                        }
                    }
                });
                
                // Eveniment pentru butonul "Localizare mea"
                document.getElementById("locateMeBtn").addEventListener("click", function() {
                    if (navigator.geolocation) {
                        navigator.geolocation.getCurrentPosition(
                            function(position) {
                                const longitude = position.coords.longitude;
                                const latitude = position.coords.latitude;
                                
                                const myLocation = new Point({
                                    longitude: longitude,
                                    latitude: latitude
                                });
                                
                                const locationGraphic = new Graphic({
                                    geometry: myLocation,
                                    symbol: {
                                        type: "simple-marker",
                                        color: "blue",
                                        size: "12px",
                                        outline: {
                                            color: [255, 255, 255],
                                            width: 2
                                        }
                                    },
                                    attributes: {
                                        title: "Locația mea",
                                        location: "Poziția curentă"
                                    },
                                    popupTemplate: {
                                        title: "{title}",
                                        content: "{location}"
                                    }
                                });
                                
                                // Eliminăm markerii anteriori dacă e necesar și adăugăm cel nou
                                if (selectedLocationData) {
                                    view.graphics.removeAll();
                                    
                                    // Readăugăm și markerul pentru locația selectată
                                    const selectedPoint = new Point({
                                        longitude: selectedLocationData.longitude,
                                        latitude: selectedLocationData.latitude
                                    });
                                    
                                    const selectedGraphic = new Graphic({
                                        geometry: selectedPoint,
                                        symbol: {
                                            type: "simple-marker",
                                            color: "<%= accent %>",
                                            size: "12px",
                                            outline: {
                                                color: [255, 255, 255],
                                                width: 2
                                            }
                                        }
                                    });
                                    
                                    view.graphics.add(selectedGraphic);
                                    
                                    // Linie pentru rută între poziția mea și locația selectată
                                    const routeLine = new Graphic({
                                        geometry: {
                                            type: "polyline",
                                            paths: [
                                                [longitude, latitude], 
                                                [selectedLocationData.longitude, selectedLocationData.latitude]
                                            ]
                                        },
                                        symbol: {
                                            type: "simple-line",
                                            color: "<%= accent %>",
                                            width: 3
                                        }
                                    });
                                    
                                    view.graphics.add(routeLine);
                                }
                                
                                view.graphics.add(locationGraphic);
                                
                                // Zoom și centrare pe regiunea care include ambele puncte
                                if (selectedLocationData) {
                                    view.goTo({
                                        target: [myLocation, new Point({
                                            longitude: selectedLocationData.longitude,
                                            latitude: selectedLocationData.latitude
                                        })],
                                        padding: {
                                            top: 100,
                                            right: 100,
                                            bottom: 100,
                                            left: 100
                                        }
                                    });
                                } else {
                                    view.goTo({
                                        center: [longitude, latitude],
                                        zoom: 15
                                    });
                                }
                            },
                            function(error) {
                                console.error("Eroare la obținerea locației:", error);
                                document.getElementById("statusMessage").textContent = "Eroare la obținerea locației: " + error.message;
                                document.getElementById("statusMessage").className = "error-message";
                            }
                        );
                    } else {
                        document.getElementById("statusMessage").textContent = "Geolocația nu este suportată de browser";
                        document.getElementById("statusMessage").className = "error-message";
                    }
                });
                
                // Eveniment pentru butonul "Salvează această locație"
                document.getElementById("saveBtn").addEventListener("click", function() {
                    if (!selectedLocationData) {
                        document.getElementById("statusMessage").textContent = "Selectați o locație întâi!";
                        document.getElementById("statusMessage").className = "error-message";
                        return;
                    }
                    
                    // Pregătim datele pentru a fi trimise la server
                    const requestBody = {
                        id_con: idConcediu,
                        strada: "Atracție turistică: " + selectedLocationData.name,
                        cod: "000000", // Cod poștal implicit
                        judet: "N/A", // Se va determina de către server prin reverse geocoding
                        oras: "N/A", // Se va determina de către server prin reverse geocoding
                        tara: "România",
                        latitudine: selectedLocationData.latitude,
                        longitudine: selectedLocationData.longitude
                    };
                    
                    // Încercăm să facem reverse geocoding pentru a obține adresa completă
                    const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                    
                    const location = {
                        longitude: selectedLocationData.longitude,
                        latitude: selectedLocationData.latitude
                    };
                    
                    locator.locationToAddress(locatorUrl, {
                        location: location
                    })
                    .then(function(response) {
                        // Actualizăm requestBody cu datele de adresă obținute
                        if (response && response.address) {
                            requestBody.judet = response.address.Region || "N/A";
                            requestBody.oras = response.address.City || "N/A";
                            requestBody.strada = "Atracție turistică: " + selectedLocationData.name + 
                                                " (" + (response.address.Address || "Adresă necunoscută") + ")";
                        }
                        
                        // Trimitem datele către server
                        sendLocationToServer(requestBody);
                    })
                    .catch(function(error) {
                        console.log("Reverse geocoding eșuat, se folosesc date implicite", error);
                        // Trimitem datele către server cu datele implicite
                        sendLocationToServer(requestBody);
                    });
                });
                
                // Funcție pentru trimiterea datelor de locație către server
                function sendLocationToServer(requestBody) {
                    fetch("/Proiect/AddLeaveLocation", {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify(requestBody)
                    })
                    .then(response => {
                        if (response.ok) {
                            document.getElementById("statusMessage").textContent = "Locația a fost salvată cu succes!";
                            document.getElementById("statusMessage").className = "success-message";
                            
                            // Opțional: redirecționare după succes
                            setTimeout(function() {
                                window.location.href = "concediinoisef.jsp?pag=1";
                            }, 2000);
                        } else {
                            throw new Error("Eroare la salvarea locației");
                        }
                    })
                    .catch(error => {
                        console.error("Eroare:", error);
                        document.getElementById("statusMessage").textContent = "Eroare: " + error.message;
                        document.getElementById("statusMessage").className = "error-message";
                    });
                }
                
                // Eveniment pentru click pe hartă - afișarea detaliilor atracțiilor
                view.on("click", function(event) {
                    // Facem un query pe layer-ul de atracții turistice
                    const query = attractionsLayer.createQuery();
                    query.geometry = event.mapPoint;
                    query.distance = 100; // Căutare într-o rază de 100 metri
                    query.spatialRelationship = "intersects";
                    query.outFields = ["*"];
                    query.returnGeometry = true;
                    
                    attractionsLayer.queryFeatures(query).then(function(results) {
                        if (results.features.length > 0) {
                            const feature = results.features[0];
                            const attributes = feature.attributes;
                            
                            // Afișăm detaliile atracției
                            const detailsPanel = document.getElementById("detailsPanel");
                            const detailsContent = document.getElementById("detailsContent");
                            
                            let content = `<h4>${attributes.name || 'Atracție turistică'}</h4>`;
                            content += `<p><strong>Tip:</strong> ${attributes.tourism || 'Nespecificat'}</p>`;
                            if (attributes.description) {
                                content += `<p><strong>Descriere:</strong> ${attributes.description}</p>`;
                            }
                            
                            // Adăugăm coordonatele
                            const point = feature.geometry;
                            content += `<p><strong>Coordonate:</strong> Lat: ${point.latitude.toFixed(6)}, Lon: ${point.longitude.toFixed(6)}</p>`;
                            
                            // Buton pentru a selecta această atracție
                            content += `<button id="selectAttraction" style="
                                width: 100%;
                                padding: 8px;
                                background-color: ${accent};
                                color: white;
                                border: none;
                                border-radius: 4px;
                                cursor: pointer;
                                margin-top: 10px;
                            ">Selectează această atracție</button>`;
                            
                            detailsContent.innerHTML = content;
                            detailsPanel.style.display = "block";
                            
                            // Adăugăm handler pentru butonul de selectare
                            document.getElementById("selectAttraction").addEventListener("click", function() {
                                // Salvăm datele despre atracția selectată
                                selectedLocationData = {
                                    id: attributes.OBJECTID || 'unknown',
                                    name: attributes.name || 'Atracție turistică',
                                    latitude: point.latitude,
                                    longitude: point.longitude
                                };
                                
                                // Afișăm informațiile în panoul de locație selectată
                                document.getElementById("locationName").textContent = selectedLocationData.name;
                                document.getElementById("locationCoords").textContent = 
                                    `Lat: ${selectedLocationData.latitude.toFixed(6)}, Lon: ${selectedLocationData.longitude.toFixed(6)}`;
                                document.getElementById("selectedLocation").style.display = "block";
                                
                                // Activăm butonul de salvare
                                document.getElementById("saveBtn").disabled = false;
                                
                                // Creare marker pentru locația selectată
                                const pointGraphic = new Graphic({
                                    geometry: point,
                                    symbol: {
                                        type: "simple-marker",
                                        color: accent,
                                        size: "12px",
                                        outline: {
                                            color: [255, 255, 255],
                                            width: 2
                                        }
                                    }
                                });
                                
                                // Eliminăm markerii anteriori și adăugăm unul nou
                                view.graphics.removeAll();
                                view.graphics.add(pointGraphic);
                                
                                // Ascundem panoul de detalii după selectare
                                detailsPanel.style.display = "none";
                            });
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>
<%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                e.printStackTrace();
                ;;
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