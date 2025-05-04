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
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0079c1;
            margin-top: 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #0079c1;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .action-btn {
            display: inline-block;
            padding: 6px 12px;
            margin: 0 5px;
            background-color: #0079c1;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
        }
        .action-btn.edit {
            background-color: #4CAF50;
        }
        .action-btn.delete {
            background-color: #f44336;
        }
        .action-btn.map {
            background-color: #FF9800;
        }
        .action-btn:hover {
            opacity: 0.8;
        }
        .add-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-bottom: 20px;
            font-weight: bold;
        }
        .add-btn:hover {
            background-color: #45a049;
        }
        .button-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .search-container {
            display: flex;
            align-items: center;
        }
        .search-container input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-right: 10px;
        }
        .search-container button {
            padding: 8px 16px;
            background-color: #0079c1;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-container button:hover {
            background-color: #005a91;
        }
        .no-data {
            text-align: center;
            padding: 20px;
            color: #666;
            font-style: italic;
        }
        .status-message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #dff2bf;
            color: #4F8A10;
        }
        .error {
            background-color: #ffbaba;
            color: #D8000C;
  
    html, body, #viewDiv {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }
    .info-panel {
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
    .info-panel h3 {
      margin-top: 0;
      color: #0079c1;
    }
    .info-panel p {
      margin: 5px 0;
    }
    .info-panel .label {
      font-weight: bold;
    }
    .button-container {
      margin-top: 20px;
      display: flex;
      justify-content: space-between;
    }
    .button {
      background-color: #0079c1;
      color: white;
      border: none;
      padding: 8px 16px;
      cursor: pointer;
      border-radius: 4px;
      text-decoration: none;
      font-size: 14px;
      text-align: center;
    }
    .button.edit {
      background-color: #4CAF50;
    }
    .button:hover {
      opacity: 0.8;
    }
    .status-message {
      margin-top: 10px;
      padding: 10px;
      border-radius: 5px;
      display: none;
    }
    .error {
      background-color: #ffbaba;
      color: #D8000C;
      display: block;
    }
      }
    </style>
</head>
<body>
  <div id="viewDiv"></div>
  <div class="info-panel">
    <h3>Detalii Sediu</h3>
    <div id="detaliiSediu">
      <p><span class="label">Nume:</span> <span id="numeSediu">Se încarcă...</span></p>
      <p><span class="label">Tip:</span> <span id="tipSediu">Se încarcă...</span></p>
      <p><span class="label">Adresă:</span> <span id="adresaSediu">Se încarcă...</span></p>
      <p><span class="label">Telefon:</span> <span id="telefonSediu">Se încarcă...</span></p>
      <p><span class="label">Email:</span> <span id="emailSediu">Se încarcă...</span></p>
      <p><span class="label">Coordonate:</span> <span id="coordonateSediu">Se încarcă...</span></p>
    </div>
    <div class="button-container">
      <a href="ListaSedii.jsp" class="button">Înapoi la Lista Sedii</a>
      <a id="editButton" href="#" class="button edit">Editează</a>
    </div>
    <div id="statusMessage" class="status-message"></div>
  </div>

  <script>
    document.addEventListener('DOMContentLoaded', function () {
      require([
        "esri/config",
        "esri/Map",
        "esri/views/MapView",
        "esri/Graphic",
        "esri/rest/locator",
        "esri/widgets/BasemapToggle",
        "esri/widgets/Search"
      ], function (esriConfig, Map, MapView, Graphic, locator, BasemapToggle, Search) {
        // Configurare API key pentru ArcGIS
        esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

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
        
        // Adaugă widget pentru schimbarea hărții de bază
        const basemapToggle = new BasemapToggle({
          view: view,
          nextBasemap: "satellite"
        });
        view.ui.add(basemapToggle, "bottom-right");
        
        // Adaugă widget de căutare
        const searchWidget = new Search({
          view: view
        });
        view.ui.add(searchWidget, {
          position: "top-right",
          index: 0
        });

        // Obține ID-ul sediului din URL
        const urlParams = new URLSearchParams(window.location.search);
        const idSediu = urlParams.get('id_sediu');
        
        if (!idSediu) {
          document.getElementById('statusMessage').textContent = 'ID-ul sediului lipsește din URL.';
          document.getElementById('statusMessage').className = 'status-message error';
          document.getElementById('detaliiSediu').style.display = 'none';
          return;
        }
        
        // Actualizează link-ul de editare
        document.getElementById('editButton').href = `AdaugareSediu.html?id_sediu=${idSediu}`;
        
        // Încarcă detaliile sediului
        fetch(`/Proiect/GetSediuDetails?id_sediu=${idSediu}`)
          .then(response => {
            if (!response.ok) {
              throw new Error(`HTTP status ${response.status}`);
            }
            return response.json();
          })
          .then(data => {
            // Populează detaliile sediului
            document.getElementById('numeSediu').textContent = data.nume_sediu;
            
            // Formatează tipul sediului
            let tipSediuText = data.tip_sediu;
            if (data.tip_sediu === 'principal') {
              tipSediuText = 'Principal';
            } else if (data.tip_sediu === 'secundar') {
              tipSediuText = 'Secundar';
            } else if (data.tip_sediu === 'punct_lucru') {
              tipSediuText = 'Punct de lucru';
            }
            document.getElementById('tipSediu').textContent = tipSediuText;
            
            // Formatează adresa
            const adresa = `${data.strada}, ${data.cod} ${data.oras}, ${data.judet}, ${data.tara}`;
            document.getElementById('adresaSediu').textContent = adresa;
            
            document.getElementById('telefonSediu').textContent = data.telefon || 'N/A';
            document.getElementById('emailSediu').textContent = data.email || 'N/A';
            document.getElementById('coordonateSediu').textContent = 
              `Lat: ${data.latitudine.toFixed(6)}, Lon: ${data.longitudine.toFixed(6)}`;
            
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
                },
                attributes: {
                  title: data.nume_sediu,
                  address: adresa
                },
                popupTemplate: {
                  title: "{title}",
                  content: [
                    {
                      type: "fields",
                      fieldInfos: [
                        {
                          fieldName: "address",
                          label: "Adresă"
                        }
                      ]
                    }
                  ]
                }
              });
              
              view.graphics.add(sediuGraphic);
              
              // Adaugă markeri pentru alte sedii (opțional)
              fetch('/Proiect/GetAllSedii')
                .then(response => response.json())
                .then(sedii => {
                  sedii.forEach(sediu => {
                    if (sediu.id_sediu != idSediu && sediu.latitudine && sediu.longitudine) {
                      const otherSediuGraphic = new Graphic({
                        geometry: {
                          type: "point",
                          longitude: sediu.longitudine,
                          latitude: sediu.latitudine
                        },
                        symbol: {
                          type: "simple-marker",
                          color: "gray",
                          size: "10px",
                          outline: {
                            color: "white",
                            width: 1
                          }
                        },
                        attributes: {
                          title: sediu.nume_sediu,
                          address: `${sediu.strada}, ${sediu.oras}, ${sediu.judet}, ${sediu.tara}`
                        },
                        popupTemplate: {
                          title: "{title}",
                          content: [
                            {
                              type: "fields",
                              fieldInfos: [
                                {
                                  fieldName: "address",
                                  label: "Adresă"
                                }
                              ]
                            }
                          ]
                        }
                      });
                      view.graphics.add(otherSediuGraphic);
                    }
                  });
                })
                .catch(error => {
                  console.error('Eroare la încărcarea tuturor sediilor:', error);
                });
            }
          })
          .catch(error => {
            console.error('Eroare:', error);
            document.getElementById('statusMessage').textContent = 'Eroare la încărcarea datelor sediului.';
            document.getElementById('statusMessage').className = 'status-message error';
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