
 <%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
      
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
         
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
 <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
     <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
 
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Localizare atractii turistice</title>
    
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
        .sidebar button:hover {
            background-color: #002a80;
        }
        #loadingSpinner {
            display: none;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 200;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
     <div class="form-container" style="position: fixed; top: 80px; left: 20px; z-index: 100; padding: 15px; background:<%=sidebar%>; color:<%=clr%>; border-color: <%=clr%>">
        <label style="color:<%out.println(text);%>" class="login__label" for="locationSelect">Departament</label>
        <select style="
display: block; margin-bottom: 10px; padding: 10px; width: 100%; border: none; font-size: 14px;
        border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" class="login__input" id="locationSelect"></select>
        
       <button style="
display: block; margin-bottom: 10px; padding: 10px; width: 100%; border: none; font-size: 14px;
         box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" class="login__button" id="locateMeBtn">Localizare</button>
        <button style="
display: block; margin-bottom: 10px; padding: 10px; width: 100%; border: none; font-size: 14px;
         box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" class="login__button" id="generateRouteBtn">Generare rută</button>
        <button style="
display: block; margin-bottom: 10px; padding: 10px; width: 100%; border: none; font-size: 14px;
         box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" class="login__button" id="resetBtn">Resetare harta</button>
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
                "esri/layers/FeatureLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet"
            ], function (
                esriConfig,
                Map,
                MapView,
                Graphic,
                locator,
                FeatureLayer,
                Point,
                route,
                RouteParameters,
                FeatureSet
            ) {

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

                const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";

                const locateMeBtn = document.getElementById("locateMeBtn");
                const locationSelect = document.getElementById("locationSelect");
                const generateRouteBtn = document.getElementById("generateRouteBtn");
                const resetBtn = document.getElementById("resetBtn");
                const loadingSpinner = document.getElementById("loadingSpinner");

                let currentLocation = null;
                var accentColor = "<%= accent %>"; // Păstrați valoarea culorii într-o variabilă JavaScript

                // 1. Încărcăm lista de departamente din servlet
               fetch("locactacs")
  .then(response => response.json())
  .then(data => {
    locationSelect.innerHTML = '<option value="" disabled selected>Selectează o locatie</option>';

    data.forEach(dep => {
      const option = document.createElement("option");
      option.value = dep.id;        
      option.textContent = dep.nume;

      // stocăm lat / lon ca atribute custom
      option.setAttribute("data-lat", dep.latitude);
      option.setAttribute("data-lon", dep.longitude);

      locationSelect.appendChild(option);
    });
  })
  .catch(error => console.error("Eroare la încărcarea departamentelor:", error));

                // 2. Localizeaza-ma
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
                                        color: accentColor,
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

                // 3. Generează rută
               generateRouteBtn.addEventListener("click", function () {
  if (!currentLocation) {
    alert("Rog localizare mai întâi.");
    return;
  }

  const selectedOption = locationSelect.options[locationSelect.selectedIndex];
  if (!selectedOption.value) {
    alert("Selectati o locatie!");
    return;
  }

  // Citești lat / lon din atributele custom
  const lat = parseFloat(selectedOption.getAttribute("data-lat"));
  const lon = parseFloat(selectedOption.getAttribute("data-lon"));

  // Creezi direct Point pentru destinație
  const destinationPoint = new Point({
    longitude: lon,
    latitude: lat
  });
  
  // Marchezi grafic pe hartă
  const destinationGraphic = new Graphic({
    geometry: destinationPoint,
    symbol: {
      type: "simple-marker",
      color: accentColor,
      size: "12px"
    }
  });
  view.graphics.add(destinationGraphic);

  // Generezi ruta
  const routeParams = new RouteParameters({
    stops: new FeatureSet({
      features: [
        new Graphic({ geometry: currentLocation }),
        new Graphic({ geometry: destinationPoint })
      ]
    }),
    returnDirections: true
  });

  route.solve(routeUrl, routeParams)
    .then(function (data) {
      data.routeResults.forEach(function (result) {
        result.route.symbol = {
          type: "simple-line",
          color: accentColor,
          width: 4
        };
        view.graphics.add(result.route);
      });

      if (data.routeResults.length > 0) {
      
                            const destinationPoint = new Point({
                                longitude: results[0].location.x,
                                latitude: results[0].location.y
                            });

                            const destinationGraphic = new Graphic({
                                geometry: destinationPoint,
                                symbol: {
                                    type: "simple-marker",
                                    color: accentColor,
                                    size: "12px"
                                }
                            });

                            view.graphics.add(destinationGraphic);

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
                                            color: accentColor,
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
                        } else {
                            alert("Nu s-au găsit coordonatele pentru locatia selectata.");
                        }
                    }).catch(function (error) {
                        loadingSpinner.style.display = "none";
                        console.error("Eroare la geocodare:", error);
                    });
                });

                // 4. Resetează harta
                resetBtn.addEventListener("click", function () {
                    view.graphics.removeAll();
                    view.goTo({ center: [25, 45], zoom: 6 });
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

