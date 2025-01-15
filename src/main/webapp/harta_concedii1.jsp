<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Harta Concedii</title>
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
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
            background-color: #3366cc;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
            color: white;
            font-family: Arial, sans-serif;
        }
        .sidebar select,
        .sidebar button {
            display: block;
            margin-bottom: 10px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
        }
        .sidebar button {
            background-color: #0044cc;
            color: white;
            cursor: pointer;
        }
        .sidebar button:hover {
            background-color: #002a80;
        }
        view.ui.add(zoom, "top-right");
        view.ui.add(zoom, {
		  position: "bottom-right",
		  index: 1
		});
		        
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    <div class="sidebar">
        <label for="periodSelect">Unde</label>
        <select id="periodSelect">
            <option value="ianuarie">Locatie actuala - munca</option>
            <option value="februarie">Locatie actuala - acasa</option>
            <option value="martie">Acasa - munca</option>
            
        </select>

       
		<button id="locateMeBtn">Localizează-mă</button>
		
		
        <button id="generateRouteBtn">Generează rută</button>
       
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
        	require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/rest/locator",
                "esri/layers/FeatureLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet"
            ], function (esriConfig, Map, MapView, Graphic, locator, FeatureLayer, Point, route, RouteParameters, FeatureSet) {

            	esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                const map = new Map({
                    basemap: "arcgis/topographic"
                });

                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45], // Centru aproximativ pe Romania
                    zoom: 6
                });
                
             	// Layer de atracții turistice
                const attractionsLayer = new FeatureLayer({
                    url: "https://services-eu1.arcgis.com/zci5bUiJ8olAal7N/arcgis/rest/services/OSM_Tourism_EU/FeatureServer",
                    title: "Atracții turistice"
                });
             	
                let layerAdded = false;
                
                const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";

                const locateMeBtn = document.getElementById("locateMeBtn");
                const locationSelect = document.getElementById("locationSelect");
                const generateRouteBtn = document.getElementById("generateRouteBtn");
                
                let currentLocation = null;
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";

                document.getElementById("toggleLayerBtn").addEventListener("click", function () {
                    if (layerAdded) {
                        map.remove(attractionsLayer);
                        this.textContent = "Activează layer-ul de atractii turistice";
                    } else {
                        map.add(attractionsLayer);
                        this.textContent = "Dezactivează layer-ul de atractii turistice";
                    }
                    layerAdded = !layerAdded;
                });
                
             	
                // Încarcă localitățile din servlet
                fetch("LeaveGetAddress")
                    .then(response => response.json())
                    .then(data => {
                        locationSelect.innerHTML = '<option value="" selected disabled>Selectează o localitate</option>';
                        data.forEach(location => {
                            const option = document.createElement("option");
                            option.value = location;
                            option.textContent = location;
                            locationSelect.appendChild(option);
                        });
                    })
                    .catch(error => {
                        console.error("Eroare la încărcarea localităților:", error);
                    });
             	
                /// Funcție pentru localizarea utilizatorului
				locateMeBtn.addEventListener("click", function () {
				    if (navigator.geolocation) {
				        navigator.geolocation.getCurrentPosition(
				            function (position) {
				                const longitude = position.coords.longitude;
				                const latitude = position.coords.latitude;
				
				                currentLocation = new Point({
				                    longitude: longitude,
				                    latitude: latitude
				                });
				
				                const pointGraphic = new Graphic({
				                    geometry: currentLocation,
				                    symbol: {
				                        type: "simple-marker",
				                        color: "green",
				                        size: "12px"
				                    }
				                });
				
				                view.graphics.removeAll();
				                view.graphics.add(pointGraphic);
				
				                view.goTo({
				                    center: [longitude, latitude],
				                    zoom: 14
				                });
				            },
				            function (error) {
				                alert("Eroare la obținerea poziției: " + error.message);
				            }
				        );
				    } else {
				        alert("Geolocația nu este suportată de acest browser.");
				    }
				});
				
				// Eveniment pentru generarea rutei
				generateRouteBtn.addEventListener("click", function () {
				    if (!currentLocation) {
				        alert("Te rog să te localizezi mai întâi.");
				        return;
				    }

				    const selectedLocation = locationSelect.value;
				    if (!selectedLocation) {
				        alert("Selectează o localitate!");
				        return;
				    }

				    locator.addressToLocations(locatorUrl, {
				        address: { "SingleLine": selectedLocation },
				        countryCode: "RO",
				        maxLocations: 1
				    }).then(function (results) {
				        if (results.length > 0) {
				            const destinationPoint = new Point({
				                longitude: results[0].location.x,
				                latitude: results[0].location.y
				            });

				            const destinationGraphic = new Graphic({
				                geometry: destinationPoint,
				                symbol: {
				                    type: "simple-marker",
				                    color: "red",
				                    size: "12px"
				                }
				            });

				            view.graphics.add(destinationGraphic);

				            const routeParams = new RouteParameters({
				                stops: new FeatureSet({
				                    features: [
				                        new Graphic({ geometry: currentLocation }), // Punctul de plecare
				                        new Graphic({ geometry: destinationPoint }) // Punctul de destinație
				                    ]
				                }),
				                returnDirections: true
				            });

				            route.solve(routeUrl, routeParams)
				                .then(function (data) {
				                    data.routeResults.forEach(function (result) {
				                        result.route.symbol = {
				                            type: "simple-line",
				                            color: [0, 0, 255],
				                            width: 4
				                        };
				                        view.graphics.add(result.route);
				                    });

				                    if (data.routeResults.length > 0) {
				                        const directions = document.createElement("ol");
				                        directions.classList = "esri-widget esri-widget--panel esri-directions__scroller";
				                        directions.style.marginTop = "10px";
				                        directions.style.padding = "15px 15px 15px 30px";

				                        data.routeResults[0].directions.features.forEach(function (result, i) {
				                            const direction = document.createElement("li");
				                            direction.innerHTML = result.attributes.text + " (" + result.attributes.length.toFixed(2) + " km)";
				                            directions.appendChild(direction);
				                        });

				                        view.ui.empty("top-right");
				                        view.ui.add(directions, "top-right");
				                    }
				                })
				                .catch(function (error) {
				                    console.error("Eroare la generarea rutei:", error);
				                });
				        } else {
				            alert("Nu s-au găsit coordonatele pentru localitatea selectată.");
				        }
				    }).catch(function (error) {
				        console.error("Eroare la geocodare:", error);
				    });
				});
				                
                // Eveniment pentru selectarea localității și geocodarea acesteia
                locationSelect.addEventListener("change", function () {
                    const selectedLocation = this.value;
                    if (selectedLocation) {
                        geocodeLocation(selectedLocation);
                    }
                });

                // Funcție pentru geocodarea localității selectate
                function geocodeLocation(location) {
                    locator.addressToLocations(locatorUrl, {
                        address: {
                            "SingleLine": location
                        },
                        countryCode: "RO",
                        maxLocations: 1
                    }).then(function (results) {
                        if (results.length > 0) {
                            const result = results[0].location;

                            // Facem zoom și centrăm harta pe localitatea selectată
                            view.goTo({
                                center: [result.x, result.y],
                                zoom: 12
                            });

                            // Adăugăm un marker pe hartă
                            const pointGraphic = new Graphic({
                                geometry: {
                                    type: "point",
                                    longitude: result.x,
                                    latitude: result.y
                                },
                                symbol: {
                                    type: "simple-marker",
                                    color: "red",
                                    size: "12px"
                                }
                            });

                            view.graphics.removeAll(); // Eliminăm marker-ii anteriori
                            view.graphics.add(pointGraphic); // Adăugăm marker-ul nou
                        } else {
                            alert("Nu s-au găsit coordonatele pentru localitatea selectată.");
                        }
                    }).catch(function (error) {
                        console.error("Eroare la geocodare:", error);
                    });
                }
             
                // Eveniment pentru generarea PDF-ului
                document.getElementById("generatePdfBtn").addEventListener("click", function () {
                    const selectedPeriod = document.getElementById("periodSelect").value;
                    const selectedLocation = document.getElementById("locationSelect").value;

                    if (selectedLocation) {
                        window.open(`GeneratePdfServlet?period=${selectedPeriod}&location=${selectedLocation}`, "_blank");
                    } else {
                        alert("Selectează o localitate!");
                    }
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
