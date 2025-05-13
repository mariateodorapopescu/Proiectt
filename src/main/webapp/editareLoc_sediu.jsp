<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>

<%
    HttpSession sesi = request.getSession(false); // verifică dacă există o sesiune activă
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // verifică dacă există un utilizator în sesiune
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
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    if (isAdmin) {  
                        // Extrag ID-ul sediului din parametrul URL
                        String idSediuStr = request.getParameter("id");
                        int idSediu = 0;
                        String numeSediu = "";
                        String strada = "";
                        String oras = "";
                        String judet = "";
                        String tara = "România";
                        String cod = "";
                        double latitudine = 0;
                        double longitudine = 0;
                        
                        if (idSediuStr != null && !idSediuStr.isEmpty()) {
                            try {
                                idSediu = Integer.parseInt(idSediuStr);
                                
                                // Obțin datele actuale ale sediului
                                try (PreparedStatement stmtSediu = connection.prepareStatement(
                                    "SELECT * FROM sedii WHERE id_sediu = ?")) {
                                    stmtSediu.setInt(1, idSediu);
                                    ResultSet rsSediu = stmtSediu.executeQuery();
                                    if (rsSediu.next()) {
                                        numeSediu = rsSediu.getString("nume_sediu");
                                        strada = rsSediu.getString("strada");
                                        oras = rsSediu.getString("oras");
                                        judet = rsSediu.getString("judet");
                                        tara = rsSediu.getString("tara");
                                        cod = rsSediu.getString("cod");
                                        latitudine = rsSediu.getDouble("latitudine");
                                        longitudine = rsSediu.getDouble("longitudine");
                                    }
                                }
                            } catch (NumberFormatException e) {
                                // Gestionare eroare format ID
                                out.println("<script>alert('ID sediu invalid!');</script>");
                                response.sendRedirect("administrare_sedii.jsp");
                                return;
                            }
                        } else {
                            out.println("<script>alert('ID sediu lipsă!');</script>");
                            response.sendRedirect("administrare_sedii.jsp");
                            return;
                        }
                        
                        // Obțin culorile temei utilizatorului
                        String accent = "#10439F";
                        String clr = "#d8d9e1";
                        String sidebar = "#ECEDFA";
                        String text = "#333";
                        String card = "#ECEDFA";
                        String hover = "#ECEDFA";
                        
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * FROM teme WHERE id_usr = ?";
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
    <title>Actualizare Locație Sediu</title>
    
    <!-- ArcGIS API -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    
    <!-- Stiluri CSS -->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
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
            width: 100%;
            height: 100%;
            padding: 0;
            margin: 0;
        }
        
        a, a:visited, a:hover, a:active {
            color: #eaeaea !important;
            text-decoration: none;
        }
        
        .form-container {
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 100;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            font-family: Arial, sans-serif;
            max-width: 320px;
            overflow-y: auto;
            max-height: 90vh;
        }
        
        .form-container input {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: calc(100% - 16px);
        }
        
        .form-container button {
            margin-top: 10px;
            padding: 10px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            width: 100%;
        }
        
        ::-webkit-scrollbar {
            display: none;
        }
        
        .login__input {
            width: 100%;
            padding: 8px;
            margin-bottom: 12px;
            border-radius: 4px;
        }
        
        .login__label {
            display: block;
            margin-bottom: 4px;
            font-weight: bold;
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
        <h3 style="color: <%=accent%>">Actualizare Locație Sediu</h3>
        <p style="margin-bottom: 15px; color: <%=text%>"><strong>Sediu:</strong> <%=numeSediu%></p>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Strada</label>
            <input id="street" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="street" placeholder="Introduceți strada..." value="<%=strada%>" required class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Localitatea</label>
            <input id="city" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="city" placeholder="Introduceți localitatea..." value="<%=oras%>" required class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Județul</label>
            <input id="sector" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="sector" placeholder="Introduceți județul..." value="<%=judet%>" required class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Țara</label>
            <input id="country" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="country" placeholder="Introduceți țara..." value="<%=tara%>" required class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Codul Poștal</label>
            <input id="code" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="code" placeholder="Introduceți codul poștal..." value="<%=cod%>" required class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Latitudine (opțional)</label>
            <input id="latitudine" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="latitudine" placeholder="Latitudine..." value="<%=latitudine != 0 ? latitudine : ""%>" class="login__input">
        </div>
        
        <div>
            <label style="color:<%=text%>" class="login__label">Longitudine (opțional)</label>
            <input id="longitudine" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" name="longitudine" placeholder="Longitudine..." value="<%=longitudine != 0 ? longitudine : ""%>" class="login__input">
        </div>
        
        <button style="margin-top:15px; box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>; color:white;" id="updateLocation">
            Actualizează Locația
        </button>
        
        <button style="margin-top:10px; box-shadow: 0 6px 24px <%=accent%>; background:<%=accent%>; color:white;">
            <a style="color: white !important;" href="administrare_sedii.jsp">Înapoi</a>
        </button>
        
        <p id="addressOutput" style="color:<%=text%>" class="login__label"></p>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            let view;
            let marker;
            
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/geometry/Point",
                "esri/symbols/SimpleMarkerSymbol",
                "esri/rest/locator"
            ], function(esriConfig, Map, MapView, Graphic, Point, SimpleMarkerSymbol, locator) {
                // Setăm cheia API ArcGIS
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                // Creăm harta
                const map = new Map({
                    basemap: "arcgis-navigation" // Harta de bază
                });

                // Inițializăm view-ul
                view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [<%=longitudine != 0 ? longitudine : "26.1025"%>, <%=latitudine != 0 ? latitudine : "44.4268"%>],
                    zoom: <%=latitudine != 0 && longitudine != 0 ? "15" : "6"%>
                });

                // Funcție pentru adăugarea unui marker pe hartă
                function addMarker(longitude, latitude) {
                    // Ștergem markerii existenți
                    view.graphics.removeAll();
                    
                    // Creăm un punct pentru marker
                    const point = new Point({
                        longitude: longitude,
                        latitude: latitude
                    });
                    
                    // Stilizăm markerul
                    const simpleMarkerSymbol = new SimpleMarkerSymbol({
                        color: [226, 119, 40], // Portocaliu
                        outline: {
                            color: [255, 255, 255], // Alb
                            width: 2
                        },
                        size: 12
                    });
                    
                    // Creăm graficul (marcatorul)
                    marker = new Graphic({
                        geometry: point,
                        symbol: simpleMarkerSymbol
                    });
                    
                    // Adăugăm marcatorul pe hartă
                    view.graphics.add(marker);
                    
                    // Actualizăm câmpurile de latitudine și longitudine
                    document.getElementById("latitudine").value = latitude;
                    document.getElementById("longitudine").value = longitude;
                }

                // Adăugăm marker pentru locația curentă dacă există coordonate
                <% if(latitudine != 0 && longitudine != 0) { %>
                    addMarker(<%=longitudine%>, <%=latitudine%>);
                <% } %>

                // Eveniment pentru click pe hartă
                view.on("click", function(event) {
                    const point = event.mapPoint;
                    addMarker(point.longitude, point.latitude);
                });

                // Handler pentru actualizarea locației
                document.getElementById("updateLocation").addEventListener("click", async function() {
                    const street = document.getElementById("street").value;
                    const code = document.getElementById("code").value;
                    const sector = document.getElementById("sector").value;
                    const city = document.getElementById("city").value;
                    const country = document.getElementById("country").value;
                    let latValue = document.getElementById("latitudine").value;
                    let longValue = document.getElementById("longitudine").value;
                    
                    // Dacă utilizatorul nu a dat click pe hartă, încercăm să geocodificăm adresa
                    if (!latValue || !longValue) {
                        const address = `${street}, ${city}, ${sector}, ${country}`;
                        const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                        
                        try {
                            const params = {
                                address: {
                                    "address": address,
                                    "postal": code,
                                    "countryCode": "RO"
                                },
                                outFields: ["*"],
                                maxLocations: 1
                            };
                            
                            const results = await locator.addressToLocations(locatorUrl, params);
                            
                            if (results.length > 0) {
                                const location = results[0].location;
                                latValue = location.latitude;
                                longValue = location.longitude;
                                
                                // Adăugăm marker pentru locația găsită
                                addMarker(longValue, latValue);
                                
                                // Facem zoom la locație
                                view.goTo({
                                    target: new Point({
                                        longitude: longValue,
                                        latitude: latValue
                                    }),
                                    zoom: 15
                                });
                            } else {
                                document.getElementById("addressOutput").textContent = 
                                    "Nu s-a găsit adresa introdusă. Dați click pe hartă pentru a selecta manual locația.";
                                document.getElementById("addressOutput").className = "error-message";
                                return;
                            }
                        } catch (error) {
                            console.error("Eroare geocodificare:", error);
                            document.getElementById("addressOutput").textContent = 
                                "Eroare la geocodificarea adresei. Dați click pe hartă pentru a selecta manual locația.";
                            document.getElementById("addressOutput").className = "error-message";
                            return;
                        }
                    }
                    
                    // Trimitem datele către server
                    const requestBody = {
                        idSediu: <%=idSediu%>,
                        strada: street,
                        cod: code,
                        judet: sector,
                        oras: city,
                        tara: country,
                        latitudine: latValue,
                        longitudine: longValue
                    };

                    try {
                        const response = await fetch("/Proiect/UpdateSediutLocatieServlet", {
                            method: "POST",
                            headers: {
                                "Content-Type": "application/json"
                            },
                            body: JSON.stringify(requestBody)
                        });

                        if (response.ok) {
                            document.getElementById("addressOutput").textContent = 
                                "Locația sediului a fost actualizată cu succes!";
                            document.getElementById("addressOutput").className = "success-message";
                            
                            // Opțional: redirecționare după actualizare
                            // setTimeout(() => {
                            //     window.location.href = "administrare_sedii.jsp";
                            // }, 2000);
                        } else {
                            const errorText = await response.text();
                            throw new Error("Eroare la actualizarea locației: " + errorText);
                        }
                    } catch (error) {
                        console.error("Eroare:", error);
                        document.getElementById("addressOutput").textContent = 
                            "Eroare: " + error.message;
                        document.getElementById("addressOutput").className = "error-message";
                    }
                });

                // Obținem locația curentă a utilizatorului
                if (navigator.geolocation && (!<%=latitudine%> || !<%=longitudine%>)) {
                    navigator.geolocation.getCurrentPosition(
                        (pos) => {
                            const { latitude, longitude } = pos.coords;
                            
                            // Centrăm harta pe locația utilizatorului
                            view.goTo({
                                center: [longitude, latitude],
                                zoom: 13
                            });
                        },
                        (err) => {
                            console.error("Eroare la geolocație:", err);
                            // Putem centraliza pe o locație implicită pentru România
                            view.goTo({
                                center: [26.1025, 44.4268], // București
                                zoom: 6
                            });
                        }
                    );
                }
            });
        });
    </script>
</body>
</html>
<%
                    } else {
                        ;;
                    }
                } else {
                    // Utilizator nu există în baza de date
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu există date!');");
                    out.println("</script>");
                    response.sendRedirect("login.jsp");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                response.sendRedirect("login.jsp");
            }
        } else {
            // Utilizator neconectat
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("</script>");
            response.sendRedirect("login.jsp");
        }
    } else {
        // Nu există sesiune activă
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activă!');");
        out.println("</script>");
        response.sendRedirect("login.jsp");
    }
%>