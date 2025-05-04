<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                            "dp.denumire_completa AS denumire FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                    	// extrag date despre userul curent
                        int userId = rs.getInt("id");
                        int userType = rs.getInt("tip");
                        int userDep = rs.getInt("id_dep");
                        String functie = rs.getString("functie");
                        int ierarhie = rs.getInt("ierarhie");
                        if (functie.compareTo("Administrator") != 0) {  
                          
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        // Obținere preferințe de temă
                        String accent = "#4F46E5"; // Culoare implicită
                        String clr = "#f9fafb";
                        String sidebar = "#ffffff";
                        String text = "#1f2937";
                        String card = "#ffffff";
                        String hover = "#f3f4f6";
                        
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * from teme where id_usr = ?";
                            try (PreparedStatement stmt = con.prepareStatement(query)) {
                                stmt.setInt(1, userId);
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
    <title>Administrare Sedii</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Script-uri ArcGIS -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.27/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.27/"></script>
    
    <style>
        :root {
            --accent: <%=accent%>;
            --background: <%=clr%>;
            --card: <%=sidebar%>;
            --text: <%=text%>;
            --border: #e5e7eb;
            --hover: <%=hover%>;
            --danger: #ef4444;
            --danger-hover: #dc2626;
            --success: #10b981;
            --warning: #f59e0b;
            --info: #3b82f6;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--text);
            line-height: 1.5;
        }
        
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }
        
        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text);
        }
        
        .action-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .search-bar {
            position: relative;
            width: 100%;
            max-width: 400px;
        }
        
        .search-bar input {
            width: 100%;
            padding: 0.75rem 1rem 0.75rem 2.5rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            background-color: var(--card);
            color: var(--text);
            font-size: 0.875rem;
            outline: none;
            transition: all 0.2s;
        }
        
        .search-bar input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        
        .search-icon {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.5rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        
        .btn-primary {
            background-color: var(--accent);
            color: white;
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-outline {
            background-color: transparent;
            border: 1px solid var(--border);
            color: var(--text);
        }
        
        .btn-outline:hover {
            background-color: var(--hover);
        }
        
        .btn-danger {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-danger:hover {
            background-color: var(--danger-hover);
        }
        
        .btn-sm {
            padding: 0.375rem 0.75rem;
            font-size: 0.75rem;
        }
        
        .btn-icon {
            padding: 0.375rem;
        }
        
        /* Card pentru tabel */
        .card {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 2rem;
        }
        
        /* Stiluri pentru tabel */
        .table-container {
            overflow-x: auto;
        }
        
        .sedii-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        .sedii-table th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        .sedii-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        .sedii-table tr:last-child td {
            border-bottom: none;
        }
        
        .sedii-table tr:hover td {
            background-color: var(--hover);
        }
        
        /* Badge pentru tipul de sediu */
        .sediu-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.625rem;
            font-size: 0.75rem;
            font-weight: 500;
            border-radius: 9999px;
            white-space: nowrap;
        }
        
        .badge-principal {
            background-color: var(--success);
            color: white;
        }
        
        .badge-secundar {
            background-color: var(--info);
            color: white;
        }
        
        .badge-punct-lucru {
            background-color: var(--warning);
            color: white;
        }
        
        /* Acțiuni în tabel */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        /* Modal */
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 50;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s;
        }
        
        .modal-backdrop.active {
            opacity: 1;
            visibility: visible;
        }
        
        .modal {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            width: 100%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            transition: all 0.3s;
            transform: scale(0.95);
        }
        
        .modal-backdrop.active .modal {
            transform: scale(1);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
        }
        
        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text);
        }
        
        .modal-close {
            background: transparent;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            font-size: 1.25rem;
            transition: color 0.2s;
        }
        
        .modal-close:hover {
            color: var(--text);
        }
        
        .modal-body {
            padding: 1.5rem;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border);
        }
        
        /* Formular */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-group.full-width {
            grid-column: span 2;
        }
        
        .form-label {
            display: block;
            margin-bottom: 0.375rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text);
        }
        
        .form-control {
            width: 100%;
            padding: 0.625rem 0.75rem;
            font-size: 0.875rem;
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            background-color: white;
            color: var(--text);
            transition: all 0.2s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 16px;
            padding-right: 2.5rem;
        }
        
        /* Notificări toast */
        .toast-container {
            position: fixed;
            bottom: 1.5rem;
            right: 1.5rem;
            z-index: 100;
        }
        
        .toast {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            background-color: white;
            border-left: 4px solid var(--accent);
            border-radius: 0.375rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            padding: 1rem 1.25rem;
            margin-top: 0.75rem;
            max-width: 24rem;
            transform: translateX(100%);
            opacity: 0;
            transition: all 0.3s;
        }
        
        .toast.show {
            transform: translateX(0);
            opacity: 1;
        }
        
        .toast-success {
            border-left-color: var(--success);
        }
        
        .toast-error {
            border-left-color: var(--danger);
        }
        
        .toast-icon {
            font-size: 1.25rem;
        }
        
        .toast-success .toast-icon {
            color: var(--success);
        }
        
        .toast-error .toast-icon {
            color: var(--danger);
        }
        
        .toast-content {
            flex: 1;
        }
        
        .toast-title {
            font-weight: 600;
            font-size: 0.875rem;
            margin-bottom: 0.125rem;
        }
        
        .toast-message {
            font-size: 0.875rem;
            color: #6b7280;
        }
        
        .toast-close {
            background: transparent;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            transition: color 0.2s;
        }
        
        .toast-close:hover {
            color: var(--text);
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .form-group.full-width {
                grid-column: span 1;
            }
            
            .action-row {
                flex-direction: column;
                align-items: stretch;
                gap: 1rem;
            }
            
            .search-bar {
                max-width: none;
            }
        }
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
      width: 300px;
      max-height: 80vh;
      overflow-y: auto;
    }
    .form-container input, .form-container select {
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
      width: 100%;
      margin-bottom: 10px;
    }
    .form-container button:hover {
      background-color: #005a91;
    }
    .status-message {
      margin-top: 10px;
      padding: 10px;
      border-radius: 5px;
    }
    .success {
      background-color: #dff2bf;
      color: #4F8A10;
    }
    .error {
      background-color: #ffbaba;
      color: #D8000C;
    }
  </style>
</head>
<body>
  <div id="viewDiv"></div>
  <div class="form-container">
    <h3>Adăugare/Editare Sediu</h3>
    <input type="text" id="nume_sediu" placeholder="Nume sediu" required>
    <select id="tip_sediu" required>
      <option value="">Selectează tipul sediului</option>
      <option value="principal">Principal</option>
      <option value="secundar">Secundar</option>
      <option value="punct_lucru">Punct de lucru</option>
    </select>
    <input type="text" id="strada" placeholder="Strada" required>
    <input type="text" id="cod" placeholder="Cod poștal" required>
    <input type="text" id="oras" placeholder="Oraș" required>
    <input type="text" id="judet" placeholder="Județ" required>
    <input type="text" id="tara" placeholder="Țară" required>
    <input type="text" id="telefon" placeholder="Telefon">
    <input type="email" id="email" placeholder="Email">
    <input type="hidden" id="latitudine">
    <input type="hidden" id="longitudine">
    <input type="hidden" id="id_sediu" value="0">
    
    <button id="searchAddress">Caută adresa pe hartă</button>
    <button id="saveSediu">Salvează sediul</button>
    <div id="statusMessage"></div>
  </div>

  <script>
//Replace the entire script section with this fixed version

  document.addEventListener('DOMContentLoaded', function () {
    require([
      "esri/config",
      "esri/Map",
      "esri/views/MapView",
      "esri/Graphic",
      "esri/rest/locator"
    ], function (esriConfig, Map, MapView, Graphic, locator) {
      // Configurare API key pentru ArcGIS
      esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

      const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";

      // Inițializare hartă
      const map = new Map({
        basemap: "arcgis-topographic"
      });

      const view = new MapView({
        container: "viewDiv",
        map: map,
        center: [26.1025, 44.4268], // București
        zoom: 13
      });

      // Verifică dacă avem un ID de sediu în URL
      const urlParams = new URLSearchParams(window.location.search);
      const sediu_id = urlParams.get('id_sediu');
      
      if (sediu_id) {
        document.getElementById('id_sediu').value = sediu_id;
        // Încarcă datele sediului pentru editare
        fetch(`/Proiect/GetSediuDetails?id_sediu=${sediu_id}`)
          .then(response => {
            if (!response.ok) {
              throw new Error('Eroare la obținerea datelor sediului');
            }
            return response.json();
          })
          .then(data => {
            // Populează câmpurile formularului
            document.getElementById('nume_sediu').value = data.nume_sediu;
            document.getElementById('tip_sediu').value = data.tip_sediu;
            document.getElementById('strada').value = data.strada;
            document.getElementById('cod').value = data.cod;
            document.getElementById('oras').value = data.oras;
            document.getElementById('judet').value = data.judet;
            document.getElementById('tara').value = data.tara;
            document.getElementById('telefon').value = data.telefon || '';
            document.getElementById('email').value = data.email || '';
            document.getElementById('latitudine').value = data.latitudine;
            document.getElementById('longitudine').value = data.longitudine;
            
            // Centrează harta pe locația sediului
            if (data.latitudine && data.longitudine) {
              view.center = [data.longitudine, data.latitudine];
              view.zoom = 15;
              
              // Adaugă un marker pentru sediu
              const sediuGraphic = new Graphic({
                geometry: {
                  type: "point",
                  longitude: data.longitudine,
                  latitude: data.latitudine
                },
                symbol: {
                  type: "simple-marker",
                  color: "blue",
                  size: "12px",
                  outline: {
                    color: "white",
                    width: 1
                  }
                }
              });
              
              view.graphics.add(sediuGraphic);
            }
          })
          .catch(error => {
            console.error('Eroare:', error);
            showStatusMessage('Eroare la încărcarea datelor sediului.', false);
          });
      } else {
        // Detectează locația curentă a utilizatorului pentru sediu nou
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
          },
          function (error) {
            console.error("Eroare la detectarea locației utilizatorului:", error);
          }
        );
      }

      // Funcție pentru afișarea mesajelor de status
      function showStatusMessage(message, isSuccess) {
        const statusElement = document.getElementById('statusMessage');
        statusElement.textContent = message;
        statusElement.className = 'status-message ' + (isSuccess ? 'success' : 'error');
        
        // Ascunde mesajul după 5 secunde
        setTimeout(() => {
          statusElement.textContent = '';
          statusElement.className = '';
        }, 5000);
      }

      // Eveniment pentru căutarea adresei bazat pe cod poștal
      document.getElementById("searchAddress").addEventListener("click", function () {
        const cod = document.getElementById("cod").value;
        const oras = document.getElementById("oras").value;
        const tara = document.getElementById("tara").value;
        
        // Verifică dacă avem cod poștal (obligatoriu pentru această abordare)
        if (!cod) {
          showStatusMessage('Codul poștal este obligatoriu pentru căutare.', false);
          return;
        }
        
        // Construiește query-ul pentru căutare prioritizând codul poștal
        let searchQuery = cod;
        
        // Adaugă orașul și țara pentru o precizie mai bună
        if (oras) searchQuery += ` ${oras}`;
        if (tara) searchQuery += ` ${tara}`;
        
        locator.addressToLocations(locatorUrl, {
          address: { 
            SingleLine: searchQuery,
            PostalCode: cod // Specifică explicit codul poștal
          },
          outFields: ["Postal", "StAddr", "City", "RegionAbbr", "Country"]
        })
        .then(function (results) {
          if (results.length > 0) {
            const location = results[0].location;
            const latitude = location.y;
            const longitude = location.x;
            
            // Populează informațiile suplimentare din rezultat
            const attributes = results[0].attributes;
            
            // Actualizează formularul cu datele obținute dacă nu sunt deja completate
            if (attributes.StAddr && document.getElementById("strada").value === '') {
              document.getElementById("strada").value = attributes.StAddr;
            }
            
            if (attributes.City && document.getElementById("oras").value === '') {
              document.getElementById("oras").value = attributes.City;
            }
            
            if (attributes.RegionAbbr && document.getElementById("judet").value === '') {
              document.getElementById("judet").value = attributes.RegionAbbr;
            }
            
            if (attributes.Country && document.getElementById("tara").value === '') {
              document.getElementById("tara").value = attributes.Country;
            }
            
            // Salvează coordonatele în formularul ascuns
            document.getElementById('latitudine').value = latitude;
            document.getElementById('longitudine').value = longitude;

            // Curăță markerii existenți și adaugă unul nou
            view.graphics.removeAll();
            
            const marker = new Graphic({
              geometry: location,
              symbol: {
                type: "simple-marker",
                color: "blue",
                size: "12px",
                outline: { color: "white", width: 1 }
              }
            });

            view.graphics.add(marker);
            view.center = [longitude, latitude];
            view.zoom = 15;
            
            showStatusMessage('Locație găsită pe baza codului poștal!', true);
          } else {
            // Încercăm o căutare mai generală dacă nu s-a găsit nimic cu codul poștal
            locator.addressToLocations(locatorUrl, {
              address: { SingleLine: `${cod} ${oras}, ${tara}` }
            })
            .then(function (fallbackResults) {
              if (fallbackResults.length > 0) {
                const location = fallbackResults[0].location;
                const latitude = location.y;
                const longitude = location.x;
                
                // Salvează coordonatele în formularul ascuns
                document.getElementById('latitudine').value = latitude;
                document.getElementById('longitudine').value = longitude;

                // Curăță markerii existenți și adaugă unul nou
                view.graphics.removeAll();
                
                const marker = new Graphic({
                  geometry: location,
                  symbol: {
                    type: "simple-marker",
                    color: "orange", // Culoare diferită pentru căutarea de rezervă
                    size: "12px",
                    outline: { color: "white", width: 1 }
                  }
                });

                view.graphics.add(marker);
                view.center = [longitude, latitude];
                view.zoom = 15;
                
                showStatusMessage('Locație găsită aproximativ. Verificați precizia adresei.', true);
              } else {
                showStatusMessage('Codul poștal nu a fost găsit. Verificați datele introduse.', false);
              }
            })
            .catch(function (error) {
              console.error("Eroare la căutarea alternativă:", error);
              showStatusMessage('Eroare la procesarea codului poștal.', false);
            });
          }
        })
        .catch(function (error) {
          console.error("Eroare la geocodare:", error);
          showStatusMessage('Eroare la procesarea adresei.', false);
        });
      });

      // Adaugă listener pentru click pe hartă - SINGURA IMPLEMENTARE
      view.on("click", function(event) {
        // Obține coordonatele
        const point = view.toMap({ x: event.x, y: event.y });
        
        // Curăță markerii existenți și adaugă unul nou
        view.graphics.removeAll();
        
        const marker = new Graphic({
          geometry: point,
          symbol: {
            type: "simple-marker",
            color: "blue",
            size: "12px",
            outline: { color: "white", width: 1 }
          }
        });
        
        view.graphics.add(marker);
        
        // Salvează coordonatele în formularul ascuns
        document.getElementById('latitudine').value = point.latitude;
        document.getElementById('longitudine').value = point.longitude;
        
        // Reverse geocoding pentru a completa adresa
        locator.locationToAddress(locatorUrl, {
          location: point,
          outFields: ["Postal", "Address", "City", "Region", "Country"]
        })
        .then(function(response) {
          const address = response.address;
          
          // Completează câmpurile formularului cu datele adresei
          if (address) {
            // Prioritizăm codul poștal
            if (address.Postal) {
              document.getElementById("cod").value = address.Postal;
              // Evidențiem câmpul cod poștal pentru a arăta că a fost actualizat
              document.getElementById("cod").style.backgroundColor = "#e6f7ff";
              setTimeout(() => {
                document.getElementById("cod").style.backgroundColor = "";
              }, 2000);
            }
            
            if (address.Address) document.getElementById("strada").value = address.Address;
            if (address.City) document.getElementById("oras").value = address.City;
            if (address.Region) document.getElementById("judet").value = address.Region;
            if (address.Country) document.getElementById("tara").value = address.Country;
            
            showStatusMessage('Adresa a fost actualizată conform locației selectate.', true);
          }
        })
        .catch(function(error) {
          console.error("Eroare la reverse-geocoding:", error);
          // Încă salvăm coordonatele, chiar dacă reverse geocoding a eșuat
          showStatusMessage('Coordonatele au fost salvate, dar nu s-a putut determina adresa.', false);
        });
      });

      // Eveniment pentru salvarea sediului
      document.getElementById("saveSediu").addEventListener("click", function () {
        try {
          // Validare date
          const numeSediu = document.getElementById("nume_sediu").value;
          const tipSediu = document.getElementById("tip_sediu").value;
          const strada = document.getElementById("strada").value;
          const cod = document.getElementById("cod").value;
          const oras = document.getElementById("oras").value;
          const judet = document.getElementById("judet").value;
          const tara = document.getElementById("tara").value;
          const telefon = document.getElementById("telefon").value;
          const email = document.getElementById("email").value;
          const latitudine = document.getElementById("latitudine").value;
          const longitudine = document.getElementById("longitudine").value;
          const idSediu = document.getElementById("id_sediu").value;
          
          if (!numeSediu || !tipSediu || !strada || !cod || !oras || !judet || !tara) {
            showStatusMessage('Completați toate câmpurile obligatorii.', false);
            return;
          }
          
          // Verifică dacă avem coordonate
          if (!latitudine || !longitudine) {
            showStatusMessage('Localizați adresa pe hartă înainte de a salva.', false);
            return;
          }
          
          console.log('Pregătesc datele pentru trimitere:', {
            id_sediu: idSediu,
            nume_sediu: numeSediu,
            tip_sediu: tipSediu,
            strada: strada,
            cod: cod,
            oras: oras,
            judet: judet,
            tara: tara,
            telefon: telefon,
            email: email,
            latitudine: parseFloat(latitudine),
            longitudine: parseFloat(longitudine)
          });
          
          fetch("/ManageSediu", {  // Changed from "/Proiect/ManageSediu" to "/ManageSediu"
        	  method: "POST",
        	  headers: { "Content-Type": "application/json" },
        	  body: JSON.stringify({
        	    id_sediu: parseInt(idSediu) || 0,
        	    nume_sediu: numeSediu,
        	    tip_sediu: tipSediu,
        	    strada: strada,
        	    cod: cod,
        	    oras: oras,
        	    judet: judet,
        	    tara: tara,
        	    telefon: telefon,
        	    email: email,
        	    latitudine: parseFloat(latitudine),
        	    longitudine: parseFloat(longitudine)
        	  })
        	})
          .then(response => {
            console.log('Răspuns primit:', response);
            if (response.ok) {
              return response.text();
            } else {
              return response.text().then(text => {
                throw new Error("Eroare la salvarea sediului: " + text);
              });
            }
          })
          .then(data => {
            console.log('Date de succes:', data);
            showStatusMessage('Sediul a fost salvat cu succes!', true);
            
            // Opțional: redirecționează către pagina de listare a sediilor
            setTimeout(() => {
              window.location.href = '/Proiect/listasedii.jsp';
            }, 2000);
          })
          .catch(error => {
            console.error("Eroare la trimiterea datelor către servlet:", error);
            showStatusMessage('Eroare la salvarea sediului: ' + error.message, false);
          });
        } catch (error) {
          console.error("Excepție la pregătirea datelor pentru salvare:", error);
          showStatusMessage('Eroare la pregătirea datelor: ' + error.message, false);
        }
      });
    });
  });
  </script>
</body>
</html>
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