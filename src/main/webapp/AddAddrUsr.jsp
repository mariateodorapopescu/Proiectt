
 <!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Adaugare Adresa</title>
  <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
  <script src="https://js.arcgis.com/4.30/"></script>
  <style>
    html, body, #viewDiv {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }
    .form-container {
      position: absolute;
      top: 20px;
      left: 20px;
      z-index: 100;
      background-color: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
      font-family: Arial, sans-serif;
    }
    .form-container input {
      display: block;
      margin-bottom: 10px;
      padding: 8px;
      width: calc(100% - 16px);
    }
    .form-container button {
      background-color: #0079c1;
      color: white;
      border: none;
      padding: 10px;
      cursor: pointer;
      border-radius: 5px;
    }
    .form-container button:hover {
      background-color: #005a91;
    }
  </style>
</head>
<body>
  <div id="viewDiv"></div>
  <div class="form-container">
    <h3>Adaugare Adresa</h3>
    <input type="text" id="street" placeholder="Strada">
    <input type="text" id="number" placeholder="Numarul">
    <input type="text" id="code" placeholder="Cod postal">
    <input type="text" id="sector" placeholder="Sector (optional)">
    <input type="text" id="city" placeholder="Oras">
    <input type="text" id="country" placeholder="Tara">
    <button id="addAddress">Adaugare Adresa</button>
    <p id="addressOutput"></p>
    <p id="locationOutput"></p>
    <form action="<%= request.getContextPath() %>/addaddress" method="post" class="send">
    <input type="hidden" name="latitude" id="latitude">
    </form>
  </div>
  <script>
document.addEventListener('DOMContentLoaded', function() {
    var inputs = document.querySelectorAll('.send');
    inputs.forEach(input => {
        input.addEventListener('change', function() {
            this.form.submit();
        });
    });
});
</script>
  <% 
  int userId = 0;
  userId = Integer.parseInt(request.getParameter("id"));
  // trimis ca parametru intr-un post la servlet nu JSON impreuna cu adresa
  // formuri hidden cu auto-submit
  %>
  <script>
    require([
      "esri/config",
      "esri/Map",
      "esri/views/MapView",
      "esri/Graphic",
      "esri/rest/locator"
    ], function (esriConfig, Map, MapView, Graphic, locator) {
      esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";


      const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";

      const map = new Map({
        basemap: "arcgis/topographic"
      });

      const view = new MapView({
        container: "viewDiv",
        map: map,
        center: [0, 20],
        zoom: 2
      });

      navigator.geolocation.getCurrentPosition(
        function (position) {
          const { latitude, longitude } = position.coords;
          view.center = [longitude, latitude];
          view.zoom = 14;

          const userLocation = new Graphic({
            geometry: {
              type: "point",
              longitude: longitude,
              latitude: latitude
            },
            symbol: {
              type: "simple-marker",
              color: "red",
              size: "10px",
              outline: {
                color: "white",
                width: 1
              }
            }
          });

          view.graphics.add(userLocation);
          document.getElementById("locationOutput").textContent = `Locatia curenta: Latitudine ${latitude.toFixed(6)}, Longitudine ${longitude.toFixed(6)}`;
        },
        function (error) {
          console.error("Eroare la detectarea locatiei utilizatorului:", error);
          document.getElementById("locationOutput").textContent = "Eroare la detectarea locatiei.";
        }
      );

      document.getElementById("addAddress").addEventListener("click", function () {
        const street = document.getElementById("street").value;
        const number = document.getElementById("number").value;
        const code = document.getElementById("code").value;
        const sector = document.getElementById("sector").value;
        const city = document.getElementById("city").value;
        const country = document.getElementById("country").value;

        const address = `${street} ${number}, ${code} ${sector ? "Sector " + sector + ", " : ""}${city}, ${country}`;

       // const userId = new URLSearchParams(window.location.search).get("user");
        // const userId = new URLSearchParams(window.location.search).get("id");
        const userId <%= Integer.parseInt(request.getParameter("id"))%>
        if (!userId) {
          document.getElementById("addressOutput").textContent = "ID-ul utilizatorului este lipsa!";
          return;
        }

        document.getElementById("addressOutput").textContent = `Adresa formata: ${address}`;

        locator.addressToLocations(locatorUrl, {
          address: {
            SingleLine: address
          }
        })
        .then(function (results) {
          if (results.length > 0) {
            const location = results[0].location;

            const marker = new Graphic({
              geometry: location,
              symbol: {
                type: "simple-marker",
                color: "blue",
                size: "10px",
                outline: {
                  color: "white",
                  width: 1
                }
              }
            });

            view.graphics.add(marker);
            view.center = [location.x, location.y];
            view.zoom = 14;

            fetch("/ServletUpdateAddress", {
              method: "POST",
              headers: {
                "Content-Type": "application/json"
              },
              body: JSON.stringify({
                userId: userId,
                address: address
              })
            })
            .then((response) => {
              if (response.ok) {
                return response.text();
              } else {
                throw new Error("Eroare la actualizarea adresei in baza de date.");
              }
            })
            .then((data) => {
              document.getElementById("addressOutput").textContent = `Adresa a fost salvata cu succes pentru utilizatorul cu ID-ul ${userId}.`;
            })
            .catch((error) => {
              console.error("Eroare la trimiterea datelor catre servlet:", error);
              document.getElementById("addressOutput").textContent = "Eroare la salvarea adresei.";
            });

          } else {
            document.getElementById("locationOutput").textContent = "Adresa nu a fost gasita.";
          }
        })
        .catch(function (error) {
          console.error("Eroare la geocodare:", error);
          document.getElementById("locationOutput").textContent = "Eroare la geocodarea adresei.";
        });
      });
    });
  </script>
</body>
</html>

