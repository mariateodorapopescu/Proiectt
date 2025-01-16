<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
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
    <div class="sidebar">
         
        <label for="locationSelect">Departament</label>
        <select id="locationSelect"></select>
        
        <button id="locateMeBtn">Localizează-mă</button>
        <button id="generateRouteBtn">Generează rută</button>
        <button id="resetBtn">Resetează harta</button>
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

                // 1. Încărcăm lista de departamente din servletul locactdep
               fetch("locactacs")
  .then(response => response.json())
  .then(data => {
    locationSelect.innerHTML = '<option value="" disabled selected>Selectează departamentul</option>';

    data.forEach(dep => {
      const option = document.createElement("option");
      option.value = dep.id_dep;         // "1", "2", etc.
      option.textContent = dep.nume_dep; // "IT", "HR", etc.

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

                // 3. Generează rută
               generateRouteBtn.addEventListener("click", function () {
  if (!currentLocation) {
    alert("Te rog să te localizezi mai întâi.");
    return;
  }

  const selectedOption = locationSelect.options[locationSelect.selectedIndex];
  if (!selectedOption.value) {
    alert("Selectează un departament!");
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
      color: "red",
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
          color: [0, 0, 255],
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
                                    color: "red",
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
                            alert("Nu s-au găsit coordonatele pentru departamentul selectat.");
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
</body>
</html>
