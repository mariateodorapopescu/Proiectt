<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Aplicatie Concedii</title>
  <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
  <script src="https://js.arcgis.com/4.30/"></script>
  <style>
    html,
      body,
      #viewDiv {
        padding: 0;
        margin: 0;
        height: 100%;
        width: 100%;
      }
    }
  </style>
</head>
<body>
  <div id="viewDiv"></div>
  <script src="script.js"></script>
  <script>
  
  require([
	  "esri/config",
	  "esri/Map",
	  "esri/views/MapView",
	  "esri/layers/FeatureLayer",
	  "esri/widgets/Search"
	], function (esriConfig, Map, MapView, FeatureLayer, Search) {
	  esriConfig.apiKey =
	    "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

	
	  const destinationsUrl =
	    "https://services.arcgis.com/example/arcgis/rest/services/Destinations/FeatureServer/0";

	  const destinationsLayer = new FeatureLayer({
	    url: destinationsUrl,
	    popupTemplate: {
	      title: "{Name}",
	      content: `
	        <b>Descriere:</b> {Description}<br>
	        <b>Tara:</b> {Country}<br>
	        <b>Rating:</b> {Rating} / 5
	      `
	    },
	    renderer: {
	      type: "simple",
	      symbol: {
	        type: "simple-marker",
	        color: "blue",
	        size: "10px",
	        outline: {
	          color: "white",
	          width: 1
	        }
	      }
	    }
	  });

	  const map = new Map({
	    basemap: "arcgis/topographic",
	    layers: [destinationsLayer]
	  });

	  const view = new MapView({
	    container: "viewDiv",
	    map: map,
	    center: [0, 20],
	    zoom: 2 
	  });

	 
	  const searchWidget = new Search({
	    view: view
	  });
	  view.ui.add(searchWidget, {
	    position: "top-right"
	  });
	});

  </script>
</body>
</html>
