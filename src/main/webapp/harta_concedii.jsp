<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id, id_dep FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                	out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    if (userType == 4) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Harta Concedii</title>
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    <style>
      @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
		
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar {
            position: absolute;
            top: 80px;
            left: 20px;
            z-index: 100;
            background-color: <%= accent%>;
            padding: 15px;
            border-radius: 8px;
          
            color: white;
            font-family: 'Poppins', sans-serif;
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
            font-family: 'Poppins', sans-serif;
        }
        .sidebar select:hover, .sidebar select:active, .sidebar select:selected, .sidebar select:visited {
         background-color: <%= clr%>;
            color: <%= text%>;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar button {
            background-color: <%= sidebar%>;
            color: <%= text%>;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar button:hover  {
            background-color: <%= clr%>;
            font-family: 'Poppins', sans-serif;
        }
        .custom-popup {
            background-color: <%= sidebar%>;
            padding: 10px;
            border-radius: 5px;
            font-family: 'Poppins', sans-serif;
           
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    <div class="sidebar">
        <label for="locationSelect">Localitatea</label>
        <select id="locationSelect"></select>
        
        
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/layers/GraphicsLayer",
                "esri/rest/locator",
                "esri/layers/FeatureLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet",
                "esri/PopupTemplate",
                "esri/symbols/Font"
            ], function (esriConfig, Map, MapView, Graphic, GraphicsLayer, locator, FeatureLayer, Point, route, RouteParameters, FeatureSet, PopupTemplate) {

                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                const map = new Map({
                    basemap: "arcgis/topographic"
                });

                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45],
                    zoom: 6
                });

                const graphicsLayer = new GraphicsLayer();
                map.add(graphicsLayer);

                const routeLayer = new GraphicsLayer();
                map.add(routeLayer);

                const vacationLayer = new GraphicsLayer();
                map.add(vacationLayer);

                // Create a popup template for vacation points
                const popupTemplate = {
                    title: "Detalii Concediu",
                    content: [{
                        type: "text",
                        text: "{address}"
                    }]
                };

                // Load vacation points
                function loadVacationPoints() {
                    fetch("GetVacationDetailsServlet")
                        .then(response => response.json())
                        .then(vacations => {
                            vacationLayer.removeAll();
                            vacations.forEach(vacation => {
                                const point = new Point({
                                    longitude: vacation.longitude,
                                    latitude: vacation.latitude
                                });

                                const pointGraphic = new Graphic({
                                    geometry: point,
                                    symbol: {
                                        type: "simple-marker",
                                        color: "<%=accent%>",  // Red color
                                        size: "12px",
                                        outline: {
                                            color: "white",
                                            width: 2
                                        }
                                    },
                                    attributes: {
                                        address: vacation.address
                                    },
                                    popupTemplate: {
                                        title: "Adresă Locație",
                                        content: "{address}"
                                    }
                                });

                                vacationLayer.add(pointGraphic);
                            });
                        })
                        .catch(error => {
                            console.error("Error loading vacation points:", error);
                        });
                }

                // Load vacation points when the map loads
                loadVacationPoints();

                const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";

                let currentLocation = null;
                const locateMeBtn = document.getElementById("locateMeBtn");
                const locationSelect = document.getElementById("locationSelect");
                const generateRouteBtn = document.getElementById("generateRouteBtn");

                // Layer for selectable locations
                const selectableLocationsLayer = new GraphicsLayer();
                map.add(selectableLocationsLayer);

                // Load locations for dropdown and add points to map
                fetch("GetVacationDetailsServlet")
                    .then(response => response.json())
                    .then(data => {
                        locationSelect.innerHTML = '<option value="" selected disabled>Selectează o localitate</option>';
                        data.forEach(location => {
                            const option = document.createElement("option");
                            option.value = location;
                            option.textContent = location;
                            locationSelect.appendChild(option);
                            
                            // Geocode and add point for each location
                            locator.addressToLocations(locatorUrl, {
                                address: { "SingleLine": location },
                                countryCode: "RO",
                                maxLocations: 1
                            }).then(function(results) {
                                if (results.length > 0) {
                                    const point = {
                                        type: "point",
                                        longitude: results[0].location.x,
                                        latitude: results[0].location.y
                                    };

                                    const pointGraphic = new Graphic({
                                        geometry: point,
                                        symbol: {
                                            type: "simple-marker",
                                            color: "<%=accent%>",  // Roșu
                                            size: "12px",
                                            outline: {
                                                color: "white",
                                                width: 2
                                            }
                                           
                                        },
                                        attributes: {
                                            name: location
                                        },
                                        popupTemplate: {
                                            title: "Locație",
                                            content: "{name}"
                                        }
                                    });

                                    selectableLocationsLayer.add(pointGraphic);
                                }
                            }).catch(function(error) {
                                console.error("Eroare la geocodare:", error);
                            });
                        });
                    })
                    .catch(error => {
                        console.error("Eroare la încărcarea localităților:", error);
                    });

                // Locate Me functionality
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
                                        color: "<%=accent%>",
                                        size: "12px",
                                        outline: {
                                            color: "white",
                                            width: 2
                                        }
                                    }
                                });

                                graphicsLayer.removeAll();
                                graphicsLayer.add(pointGraphic);
                                
                                // Clear existing route and directions
                                routeLayer.removeAll();
                                view.ui.empty("top-right");

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

                // Generate route functionality
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

                    routeLayer.removeAll();

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
                                    size: "12px",
                                    outline: {
                                        color: "white",
                                        width: 2
                                    }
                                }
                            });

                            routeLayer.add(destinationGraphic);

                            const routeParams = new RouteParameters({
                                stops: new FeatureSet({
                                    features: [
                                        new Graphic({ geometry: currentLocation }),
                                        new Graphic({ geometry: destinationPoint })
                                    ]
                                }),
                                directionsLanguage: "ro",
                                returnDirections: true
                            });

                            route.solve(routeUrl, routeParams)
                                .then(function (data) {
                                    data.routeResults.forEach(function (result) {
                                        result.route.symbol = {
                                            type: "simple-line",
                                            color: [0, 0, 255],
                                            width: 3
                                        };
                                        routeLayer.add(result.route);
                                    });

                                    if (data.routeResults.length > 0) {
                                        const directions = document.createElement("ol");
                                        directions.classList = "esri-widget esri-widget--panel esri-directions__scroller";
                                        directions.style.marginTop = "10px";
                                        directions.style.padding = "15px 15px 15px 30px";
                                        directions.style.backgroundColor = "white";

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
                                    alert("Eroare la generarea rutei. Vă rugăm încercați din nou.");
                                });
                        } else {
                            alert("Nu s-au găsit coordonatele pentru localitatea selectată.");
                        }
                    }).catch(function (error) {
                        console.error("Eroare la geocodare:", error);
                        alert("Eroare la găsirea localității. Vă rugăm încercați din nou.");
                    });
                });

                // Location select change handler
                locationSelect.addEventListener("change", function () {
                    const selectedLocation = this.value;
                    if (selectedLocation) {
                        // Clear existing route and directions
                        routeLayer.removeAll();
                        view.ui.empty("top-right");
                        
                        geocodeLocation(selectedLocation);
                    }
                });

                // Geocode location function
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

                            view.goTo({
                                center: [result.x, result.y],
                                zoom: 12
                            });
                        }
                    }).catch(function (error) {
                        console.error("Eroare la geocodare:", error);
                    });
                }
            });
        });
    </script>
    <%
                    }
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