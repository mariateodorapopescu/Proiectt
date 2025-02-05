<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
    <h3>Adaugare locatie departament</h3>
    <input type="text" id="street" placeholder="Strada">
    <input type="text" id="number" placeholder="Numarul">
    <input type="text" id="code" placeholder="Cod postal">
    <input type="text" id="sector" placeholder="Judet/Sector">
    <input type="text" id="city" placeholder="Oras">
    <input type="text" id="country" placeholder="Tara">
    <button id="addAddress">Adaugare</button>
    <p id="addressOutput"></p>
    <p id="locationOutput"></p>
  </div>
 <script>
 document.addEventListener('DOMContentLoaded', function () {
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
		      center: [26.1025, 44.4268], // Bucharest coordinates as fallback
		      zoom: 11
		    });

		    // Opțiuni pentru geolocație
		    const options = {
		      enableHighAccuracy: true,
		      timeout: 10000,
		      maximumAge: 0
		    };

		    // Handler pentru erori de geolocație
		    function handleLocationError(error) {
		      let errorMessage = "";
		      switch(error.code) {
		        case error.PERMISSION_DENIED:
		          errorMessage = "Utilizatorul a refuzat cererea de geolocație.";
		          break;
		        case error.POSITION_UNAVAILABLE:
		          errorMessage = "Informațiile despre locație nu sunt disponibile.";
		          break;
		        case error.TIMEOUT:
		          errorMessage = "Cererea de detectare a locației a expirat.";
		          break;
		        case error.UNKNOWN_ERROR:
		          errorMessage = "A apărut o eroare necunoscută.";
		          break;
		      }
		      console.error("Eroare la geolocație:", errorMessage);
		      document.getElementById("locationOutput").textContent = "Eroare: " + errorMessage;
		      
		      // Centrăm harta pe București ca fallback
		      view.center = [26.1025, 44.4268];
		      view.zoom = 11;
		    }

		    // Handler pentru succes
		    function handleLocationSuccess(position) {
		      const { latitude, longitude } = position.coords;
		      console.log("Locație detectată:", latitude, longitude);
		      
		      // Actualizăm centrul hărții
		      view.center = [longitude, latitude];
		      view.zoom = 14;

		      // Adăugăm marker pentru locația curentă
		      const userLocation = new Graphic({
		        geometry: {
		          type: "point",
		          longitude: longitude,
		          latitude: latitude
		        },
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

		      view.graphics.add(userLocation);
		      document.getElementById("locationOutput").textContent = 
		        `Locația curentă: Latitudine ${latitude.toFixed(6)}, Longitudine ${longitude.toFixed(6)}`;
		    }

		    // Verificăm dacă browserul suportă geolocație
		    if ("geolocation" in navigator) {
		      console.log("Începe detectarea locației...");
		      navigator.geolocation.getCurrentPosition(
		        handleLocationSuccess,
		        handleLocationError,
		        options
		      );
		    } else {
		      document.getElementById("locationOutput").textContent = 
		        "Geolocația nu este suportată de acest browser.";
		    }

	    document.getElementById("addAddress").addEventListener("click", function () {
	      const street = document.getElementById("street").value;
	      const number = document.getElementById("number").value;
	      const code = document.getElementById("code").value;
	      const sector = document.getElementById("sector").value;
	      const city = document.getElementById("city").value;
	      const country = document.getElementById("country").value;
		  // const county = document.getElementById("county").value;
	      const address = `${street} ${number}, ${code} ${sector ? "Sector " + sector + ", " : ""}${city}, ${country}`;
	      const idDep = new URLSearchParams(window.location.search).get("id");

	      if (!idDep) {
	    	  document.getElementById("addressOutput").textContent = "ID-ul departamentului este lipsa!";
	    	  return;
	    	}

	      document.getElementById("addressOutput").textContent = `Adresa formata: ${address}`;

	      locator.addressToLocations(locatorUrl, {
	        address: { SingleLine: address }
	      })
	      .then(function (results) {
	        if (results.length > 0) {
	          const location = results[0].location;
	          const latitude = location.y;
	          const longitude = location.x;

	          const marker = new Graphic({
	            geometry: location,
	            symbol: {
	              type: "simple-marker",
	              color: "blue",
	              size: "10px",
	              outline: { color: "white", width: 1 }
	            }
	          });

	          view.graphics.add(marker);
	          view.center = [longitude, latitude];
	          view.zoom = 14;

	          // Trimite datele către servlet
	          fetch("/Proiect/locatiee", {
	            method: "POST",
	            headers: { "Content-Type": "application/json" },
	            body: JSON.stringify({
	              id_dep: idDep,
	              adresa: address,
	              strada: street,
	              oras: city,
	              judet: sector,
	              cod: code,
	              nr: number,
	              tara: country,
	              latitudine: latitude,
	              longitudine: longitude
	            })
	          })
	          .then((response) => {
	            if (response.ok) {
	              return response.text();
	            } else {
	              throw new Error("Eroare la actualizarea adresei în baza de date.");
	            }
	          })
	          .then((data) => {
	            document.getElementById("addressOutput").textContent = `Adresa a fost salvata cu succes pentru departamentul cu ID-ul ${idDep}.`;
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
	});

</script>
</body>
</html>