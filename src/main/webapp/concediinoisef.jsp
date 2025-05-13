
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser, jakarta.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<%
    // Obținem sesiunea curentă
    HttpSession sesi = request.getSession(false);
    if (sesi == null) {
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Nu există sesiune activă\"}");
        } else {
            out.println("<script>alert('Nu există sesiune activă!');</script>");
            response.sendRedirect("logout");
        }
        return;
    }

    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser == null) {
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Utilizator neconectat\"}");
        } else {
            out.println("<script>alert('Utilizator neconectat!');</script>");
            response.sendRedirect("logout");
        }
        return;
    }

    String username = currentUser.getUsername();
    int userdep = 0, id = 0, userType = 0, ierarhie = 11;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";
    String functie = "";
    boolean isSef = false, isDirector = false, isAdmin = false, isUtilizatorNormal = false, isIncepator = false;

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
            id = rs.getInt("id");
            userType = rs.getInt("tip");
            userdep = rs.getInt("id_dep");
            functie = rs.getString("functie");
            ierarhie = rs.getInt("ierarhie");
            
            // Funcție helper pentru a determina rolul utilizatorului
            isDirector = (ierarhie < 3) ;
            isSef = (ierarhie >= 4 && ierarhie <=5);
            isIncepator = (ierarhie >= 10);
            isAdmin = (functie.contains("Administrator"));
            isUtilizatorNormal = !isDirector && !isSef && !isIncepator && !isAdmin; // tipuri 1, 2, 5-9
            
            if (!isAdmin) {
                String query = "SELECT * FROM teme WHERE id_usr = ?";
                try (PreparedStatement stmt = connection.prepareStatement(query)) {
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
            }
        }
    }

    // Dacă cererea este pentru JSON, returnăm direct JSON-ul
    if ("true".equals(request.getParameter("json"))) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Generăm data curentă în formatul dorit
        // La începutul secțiunii de procesare JSON, adaugă:
System.out.println("Processing JSON request");
    System.out.println("UserType: " + userType);
    System.out.println("Page param: " + request.getParameter("pag"));
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        List<Map<String, String>> concedii = new ArrayList<>();
        try {
            String sql = "SELECT c.id AS nr_crt, c.id_ang, u.nume, u.prenume, d.nume_dep AS departament, t.denumire AS functie, " +
            	       "c.start_c, c.end_c, c.motiv, CONCAT('Str.', l.strada, ', loc. ', l.oras, ', jud. ', l.judet, ', ', l.tara) as adresa,  ct.motiv as tipcon, " +
            	       "s.nume_status AS status, c.added, c.modified, c.acc_res " +
            	"FROM concedii c "+
            	"JOIN useri u ON u.id = c.id_ang "+
            	"JOIN tipuri t ON u.tip = t.tip "+
            	"JOIN departament d ON u.id_dep = d.id_dep "+
            	"JOIN statusuri s ON c.status = s.status "+
            	"JOIN tipcon ct ON c.tip = ct.tip "+
            	"LEFT JOIN locatii_concedii l ON c.id = l.id_concediu " +
                "WHERE YEAR(c.start_c) = YEAR(CURDATE())";
            String pagParam = request.getParameter("pag");
            System.out.println("Request URL: " + request.getRequestURL());
            System.out.println("Query String: " + request.getQueryString());
            System.out.println("Parametrul pag: [" + pagParam + "]");

            // apoi folosim variabila salvată
            if (userType == 3 && pagParam == null) {
                sql = sql + " and u.id_dep = " + userdep + " and c.status = 0 ";
            }

            if (userType == 0 && pagParam == null) {
                sql = sql + " and u.id_dep = " + userdep + " and c.status = 1 ";
            }

            if (pagParam != null && pagParam.equals("1")) {
                sql = sql + " and u.id = " + id;
                if (userType == 1 || userType == 2) {
                    sql = sql + " and c.status = 0";
                } else if (userType == 0 || userType == 3) {
                    sql = sql + " and c.status = 1";
                }
            }
         // aici e fara pag=?
            if (userType == 1 || userType == 2 && pagParam == null) {
                sql = sql + " and u.id = " + id;
            }
System.out.println(sql);
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        		PreparedStatement stmt = connection.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            
            int nr = 1;
            while (rs.next()) {
                Map<String, String> concediu = new LinkedHashMap<>();
                concediu.put("NrCrt", String.valueOf(nr++));
                concediu.put("Nume", rs.getString("nume"));
                concediu.put("Prenume", rs.getString("prenume"));
                concediu.put("Fct", rs.getString("functie"));
                concediu.put("Dep", rs.getString("departament"));
                concediu.put("Incipit", rs.getString("start_c"));
                concediu.put("Fine", rs.getString("end_c"));
                concediu.put("Motiv", rs.getString("motiv"));
                concediu.put("Loc", rs.getString("adresa"));
                concediu.put("Tip", rs.getString("tipcon"));
                concediu.put("Adaug", rs.getString("added") != null ? rs.getString("added") : "N/A");
                concediu.put("Modif", rs.getString("modified") != null ? rs.getString("modified") : "N/A");
                concediu.put("Vzt", rs.getString("acc_res") != null ? rs.getString("acc_res") : "N/A");
                concediu.put("Status", rs.getString("status"));
                concediu.put("id", rs.getString("nr_crt")); // pentru butoanele de acțiune
                concedii.add(concediu);
            }
        }
        System.out.println("Number of results: " + concedii.size());
        System.out.println("First row data (if exists): " + 
            (concedii.isEmpty() ? "No data" : concedii.get(0).toString()));
        Map<String, Object> responseJson = new HashMap<>();
        responseJson.put("header", "Cereri noi de concedii");
        responseJson.put("data", concedii);
        responseJson.put("today", today);

        ObjectMapper objectMapper = new ObjectMapper();
        out.print(objectMapper.writeValueAsString(responseJson));
        System.out.println(objectMapper.writeValueAsString(responseJson));
    } catch (Exception e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\": \"" + e.getMessage() + "\"}");
    }
    return;

    }
%>

<!DOCTYPE html>
<html lang="ro">
   <head>
        <title>Concedii</title>
         <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
        <!--=============== REMIXICONS ===============-->
        <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    
        <!--=============== CSS ===============-->
        <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css"> 
       <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
       <style>
            a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
            
        </style>
       
       <!--=============== icon ===============-->
        <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
       
        <!--=============== scripts ===============-->
        <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
         <style>
		.modal {
		    display: none;
		    position: fixed;
		    z-index: 1;
		    left: 0;
		    top: 0;
		    width: 100%;
		    height: 100%;
		    overflow: auto;
		    background-color: <%=clr%>;
		    border-radius: 2rem;
		}
		
		.modal-content {
		    background-color: <%=sidebar%>;
		    border-radius: 2rem;
		    margin: 15% auto;
		    padding: 20px;
		    border: 1px solid #888;
		    width: 80%;
		}
		
		.close {
			background-color: <%=sidebar%>;
		    color: <%=accent%>;
		    float: right;
		    font-size: 28px;
		    font-weight: bold;
		}
		
		.close:hover,
		.close:focus {
		    color: black;
		    text-decoration: none;
		    cursor: pointer;
		}
		
		body {
			top: 0;
			left: 0;
			position: fixed;
			width: 100vh;
			height: 100vh;
			padding: 0;
			margin: 0;
		}
		
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
  
        .status-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 14px;
        }
        
        .status-neaprobat { background-color: #88aedb; }
        .status-dezaprobat-sef { background-color: #b37142; }
        .status-dezaprobat-director { background-color: #873931; }
        .status-aprobat-director { background-color: #40854a; }
        .status-aprobat-sef { background-color: #ccc55e; }
        .status-pending { background-color: #e0a800; }
       
       	/* Tooltip */
       	.tooltip {
		  position: relative; 
		  border-bottom: 1px dotted black; 
		}
		
		.tooltip .tooltiptext {
		  visibility: hidden;
		  width: 120px;
		  background-color: rgba(0,0,0,0.5);
		  color: white;
		  text-align: center;
		  padding: 5px 0;
		  border-radius: 6px;
		  position: absolute;
		  z-index: 1;
		}
		
		.tooltip:hover .tooltiptext {
		  visibility: visible;
		}
		
       .content, .main-content {
		    overflow: auto; /* Permite scroll-ul orizontal */
		    width: 100%; /* Asigură că folosește întreaga lățime disponibilă */
		}
       
		::-webkit-scrollbar {
			    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
		
    </style>
        
    </head>
    <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
<%
// Verifică dacă există concedii în ziua curentă care să aibă locații
boolean hasLocationsForTodayLeaves = false;
int todayLeavesCount = 0;
int todayLeavesWithLocationCount = 0;

try {
    // Interogare pentru a verifica concediile din ziua curentă folosind direct CURDATE()
    String checkQuery = "SELECT c.id FROM concedii c WHERE c.added = CURDATE() and c.id_ang =" + id;

    try (Connection connection2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement checkStmt = connection2.prepareStatement(checkQuery)) {
        
        try (ResultSet checkRs = checkStmt.executeQuery()) {
            // Numără concediile din ziua curentă
            while (checkRs.next()) {
                todayLeavesCount++;

                // Pentru fiecare concediu, verifică dacă are o locație
                int concediuId = checkRs.getInt("id");
                String locatieQuery = "SELECT COUNT(*) AS count FROM locatii_concedii join concedii on locatii_concedii.id_concediu = concedii.id join useri on concedii.id_Ang = useri.id WHERE id_concediu = ? and useri.id = " + id;

                try (PreparedStatement locatieStmt = connection2.prepareStatement(locatieQuery)) {
                    locatieStmt.setInt(1, concediuId);
                    try (ResultSet locatieRs = locatieStmt.executeQuery()) {
                        if (locatieRs.next() && locatieRs.getInt("count") > 0) {
                            todayLeavesWithLocationCount++;
                        }
                    }
                }
            }
        }
    }

    // Există locații pentru concediile din ziua curentă dacă cel puțin un concediu are locație
    hasLocationsForTodayLeaves = (todayLeavesWithLocationCount > 0);

} catch (Exception e) {
    e.printStackTrace();
    out.println("<script type='text/javascript'>");
    out.println("console.error('Eroare la verificarea concediilor: " + e.getMessage() + "');");
    out.println("</script>");
}
%>

<!-- Alertă pentru concedii fără locații -->
<% if (todayLeavesCount > todayLeavesWithLocationCount) { %>
<div id="noLocationsBanner" style="
    position: fixed;
    top: 10px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 9999;
    background-color: <%= accent %>;
    color: white;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.2);
    font-family: 'Poppins', sans-serif;
    display: flex;
    align-items: center;
    gap: 10px;
    width: 80%;
    max-width: 600px;
">
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="min-width: 24px;">
        <circle cx="12" cy="12" r="10"></circle>
        <line x1="12" y1="8" x2="12" y2="12"></line>
        <line x1="12" y1="16" x2="12.01" y2="16"></line>
    </svg>
    <div>
        <strong>Atenție!</strong> Există <%= todayLeavesCount %> concedii adăugate astăzi, dar numai <%=todayLeavesWithLocationCount%> are locație asociată.
    </div>
    <button onclick="document.getElementById('noLocationsBanner').style.display='none';" style="
        background: transparent;
        border: none;
        color: white;
        cursor: pointer;
        font-size: 20px;
        margin-left: 10px;
        padding: 0;
        display: flex;
        align-items: center;
        justify-content: center;
    ">&times;</button>
</div>
<% } %>

<!-- Restul conținutului paginii -->
<div style="position: fixed; top: 0; left: 0; margin: 0; padding-left:1rem; padding-right:1rem;" class="main-content">
            <div style=" border-radius: 2rem;" class="content">
                <div class="intro" style=" border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                    <div class="events"  style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">


                        <%
                    if (request.getParameter("pag")!=null || (request.getParameter("pag")== null && !isSef || !isDirector)) {
                    %>
                    <h1>Cereri noi de concedii</h1>
                     <% } else {%>
                      <h1>Concedii personale</h1>
                  
                  <%} %>
                        
                        <h3 id="tableDate"></h3>
                        <table id="employeeTable">
                            <thead>
                                <tr style="color:<%out.println("white");%>">
                                     <th style="color:white">Nr.crt</th>
                    <th style="color:white">Nume</th>
                    <th style="color:white">Prenume</th>
                    <th style="color:white">Fct.</th>
                    <th style="color:white">Dep.</th>
                    <th style="color:white">Incipit</th>
                    <th style="color:white">Fine</th>
                    <th style="color:white">Motiv</th>
                    <th style="color:white">Loc</th>
                    <th style="color:white">Tip</th>
                    <th style="color:white">Adaug.</th>
                    <th style="color:white">Modif.</th>
                     <th style="color:white">Vzt.</th>
                    <th style="color:white">Status</th>
                    <!-- Cap tabel de baza -->
                    <!-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ -->
                     <!--  Aparent o sa reziliez concediinoieu si concediinoieu2 si fac una singura -->
                     <!--  Ar trebui sa am un parametru de pagina =( -->
                     
                     <!-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ -->
                    <%
                    
                    if (request.getParameter("pag")== null && (isSef || isDirector)) {
                    %>
                     <th style="color:white">Aprob.</th>
                     <th style="color:white">Resp.</th>
                     <% } 
                    if (request.getParameter("pag")!=null && request.getParameter("pag").compareTo("1")==0) {
                     
                     %>
                     <th style="color:white">Localiz.</th>
                     <th style="color:white">Modif.</th>
                     <th style="color:white">Stergeti</th>
                     <%} %>
                      <!-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ -->
                </tr>

                            </thead>
                            <tbody id="dateaici" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                                <!-- Se încarcă dinamic -->
                            </tbody>
                        </table>
                    </div>
                    
                    <button id="generate" onclick="sendJsonToPDFServer()">Descarcati PDF</button>
                   <button id="inapoi" ><a href ="actiuni.jsp">Inapoi</a></button>
                
                </div>
            </div>
        </div>
            <script>
    console.log("Debug: Concedii totale azi: <%= todayLeavesCount %>");
    console.log("Debug: Concedii cu locații: <%= todayLeavesWithLocationCount %>");
    console.log("Debug: Ar trebui să afișez alerta? <%= todayLeavesCount > 0 && !hasLocationsForTodayLeaves %>");
</script>
     <script>
     // Funcții helper pentru status
 	function getStatusClass(status) {
 	    switch(status.toLowerCase()) {
 	        case 'neaprobat': return 'neaprobat';
 	        case 'aprobat sef': return 'aprobat-sef';
 	        case 'aprobat director': return 'aprobat-director';
 	        case 'dezaprobat director': return 'dezaprobat-director';
 	        case 'dezaprobat sef': return 'dezaprobat-sef';
 	        default: return 'neaprobat';
 	    }
 	}

 	function getStatusIcon(status) {
 	    switch(status.toLowerCase()) {
 	        case 'neaprobat': return 'ri-focus-line';
 	        case 'aprobat sef':
 	        case 'aprobat director': return 'ri-checkbox-circle-line';
 	        case 'dezaprobat sef':
 	        case 'dezaprobat director': return 'ri-close-line';
 	        default: return 'ri-focus-line';
 	    }
 	}
        document.addEventListener("DOMContentLoaded", function () {
            console.log("🚀 Pagina încărcată, începe request-ul AJAX...");
            const currentUrl = window.location.pathname;
            const currentParams = window.location.search;
            const separator = currentParams ? '&' : '?';
            const fetchUrl = currentUrl + currentParams + separator + "json=true";
            
            console.log("Starting fetch from:", fetchUrl);

            fetch(fetchUrl)
                .then(response => {
                    if (!response.ok) {
                        throw new Error("❌ Eroare la fetch: " + response.statusText);
                    }
                    return response.json();
                })
                .then(jsonData => {
                    console.log("✅ JSON primit:", jsonData);

                    if (!jsonData || !jsonData.data || jsonData.data.length === 0) {
                        console.warn("⚠ JSON-ul nu conține date valide.");
                        document.getElementById("dateaici").textContent = "Nu există angajați disponibili!";
                        return;
                    }

                   // document.getElementById("tableTitle").textContent = jsonData.header;
                    document.getElementById("tableDate").textContent = new Date().toLocaleDateString("ro-RO");

                    const tableBody = document.querySelector("#employeeTable tbody");
                    tableBody.innerHTML = "";

                    jsonData.data.forEach((row, index) => {
                        console.log("🔍 Rand:", row);
                        const tr = document.createElement("tr");
                        
                        // Calculăm statusClass și statusIcon înainte de a le folosi
                        const statusClass = getStatusClass(row.Status);
                        const statusIcon = getStatusIcon(row.Status);

                        let cellsHtml = "";
                        cellsHtml += "<td data-label='Nr.crt'>" + (row.NrCrt || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Nume'>" + (row.Nume || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Prenume'>" + (row.Prenume || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Functie'>" + (row.Fct || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Departament'>" + (row.Dep || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Inceput'>" + (row.Incipit || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Final'>" + (row.Fine || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Motiv'>" + (row.Motiv || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Locatie'>" + (row.Loc || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Tip'>" + (row.Tip || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Adaugat'>" + (row.Adaug || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Modificat'>" + (row.Modif || 'N/A') + "</td>";
                        cellsHtml += "<td data-label='Vazut'>" + (row.Vzt || 'N/A') + "</td>";

                        cellsHtml += "<td class='tooltip' data-label='Status'>" +
                                    "<span class='tooltiptext'>" + row.Status + "</span>" +
                                    "<span class='status-icon status-" + statusClass + "'>" +
                                    "<i class='" + statusIcon + "'></i>" +
                                    "</span>" +
                                    "</td>";

                        // Butoane pentru șef
                        if (<%=isSef%> && !<%=request.getParameter("pag")%>) {
                            if (row.Status === "Neaprobat") {
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-aprobat-sef'>" +
                                            "<a href='javascript:void(0);' onclick='showModal(\"aprobsef?idcon=" + row.id + "\")'>" +
                                            "<i class='ri-checkbox-circle-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-dezaprobat-sef'>" +
                                            "<a href='javascript:void(0);' onclick='showModal(\"ressef?idcon=" + row.id + "\")'>" +
                                            "<i class='ri-close-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                            }
                        }

                        // Butoane pentru director
                        if (<%=isDirector%> && !<%=request.getParameter("pag")%>) {
                            if (row.Status === "Aprobat sef") {
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-aprobat-director'>" +
                                            "<a href='javascript:void(0);' onclick='showModal(\"aprobdir?idcon=" + row.id + "\")'>" +
                                            "<i class='ri-checkbox-circle-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-dezaprobat-director'>" +
                                            "<a href='javascript:void(0);' onclick='showModal(\"resdir?idcon=" + row.id + "\")'>" +
                                            "<i class='ri-close-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                            }
                        }

                        // Butoane de modificare/ștergere
                        if (<%=request.getParameter("pag") != null%>) {
                            if ((row.Status === "Neaprobat" && (<%=!isSef%> || <%=!isDirector%>)) || 
                                (row.Status === "Aprobat sef" && (<%=isSef%> || <%=isDirector%> ))) {
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-neaprobat'>" +
                                            "<a href='NewFile2.jsp?idcon=" + row.id + "'>" +
                                            "<i class='ri-edit-circle-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-neaprobat'>" +
                                            "<a href='modifc2.jsp?idcon=" + row.id + "'>" +
                                            "<i class='ri-edit-circle-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                                cellsHtml += "<td data-label='Status'>" +
                                            "<span class='status-icon status-dezaprobat-director'>" +
                                            "<a href='delcon?idcon=" + row.id + "'>" +
                                            "<i class='ri-close-line'></i>" +
                                            "</a>" +
                                            "</span>" +
                                            "</td>";
                            }
                        }

                        tr.innerHTML = cellsHtml;
                        tableBody.appendChild(tr);
                    });

                    console.log("✅ Tabel încărcat cu succes!");
                })
                .catch(error => console.error("🔥 Eroare AJAX:", error));
        });
   

    </script>
    <script>
// Codul pentru modal va fi executat după ce DOM-ul este complet încărcat
document.addEventListener("DOMContentLoaded", function() {
    // Acum definim variabilele pentru modal după ce DOM-ul este încărcat
    var modal = document.getElementById("myModal");
    var span = document.getElementsByClassName("close")[0];
    
    // Verificăm dacă elementele există pentru a evita erori
    if (!modal) {
        console.error("Elementul modal cu ID-ul 'myModal' nu a fost găsit!");
        return;
    }
    
    if (!span) {
        console.error("Elementul 'close' nu a fost găsit în modal!");
    } else {
        // Adăugăm event listener pentru butonul de închidere
        span.onclick = function() {
            modal.style.display = "none";
        }
    }
    
    // Adăugăm event listener pentru clic în afara modalului
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }
    
    // Definim funcția globală showModal
    window.showModal = function(actionUrl) {
        console.log("showModal called with URL:", actionUrl);
        var actionUrlInput = document.getElementById("actionUrl");
        var theForm = document.getElementById("theform");
        
        if (!actionUrlInput) {
            console.error("Input-ul 'actionUrl' nu a fost găsit!");
            return;
        }
        
        if (!theForm) {
            console.error("Formularul 'theform' nu a fost găsit!");
            return;
        }
        
        actionUrlInput.value = actionUrl;
        theForm.action = actionUrl;
        modal.style.display = "block";
    }
});
</script>
<script>
// Adăugați acest script pentru a verifica clickurile pe butoanele de aprobare/respingere
document.addEventListener("DOMContentLoaded", function() {
    // Adăugați handleri pentru toate link-urile cu onclick
    var allLinks = document.querySelectorAll("a[onclick]");
    allLinks.forEach(function(link) {
        link.addEventListener("click", function(event) {
            console.log("Link clicked:", this.getAttribute("onclick"));
        });
    });
});
</script>
<script>
window.onerror = function(message, source, lineno, colno, error) {
    console.error("JavaScript error:", message, "at", source, "line", lineno, "column", colno);
    alert("A apărut o eroare JavaScript: " + message);
    return true;
};
</script>
    <script>
    function generate() {
        const element = document.getElementById("content");
        html2pdf()
        .from(element)
        .save();
    } 
</script>
  <script>
    async function sendTableDataToCSV() {
        // Get the table
        const table = document.querySelector("table");
        const rows = table.querySelectorAll("tbody tr");

        // Extract table data into a JSON array
        const data = [];
        rows.forEach((row, index) => {
            const cells = row.querySelectorAll("td");
            if (cells.length > 0) { // Ignore rows with no data
                data.push({
                    "NrCrt": cells[0].textContent.trim(),
                    "Nume": cells[1].textContent.trim(),
                    "Prenume": cells[2].textContent.trim(),
                    "Functie": cells[3].textContent.trim(),
                    "Departament": cells[4].textContent.trim()
                });
            }
        });

        // Send the JSON data to the generic CSV servlet
        try {
            const response = await fetch("generateCSV1", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                const blob = await response.blob();
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement("a");
                a.href = url;
                a.download = "table_data.csv";
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
            } else {
                console.error("Failed to generate CSV");
            }
        } catch (error) {
            console.error("Error:", error);
        }
    }
</script>
        <script>
    function generateJSONFromTable() {
        // Get the table
        const table = document.querySelector("table");
        const rows = table.querySelectorAll("tbody tr");

        // Extract table data into a JSON array
        const data = [];
        rows.forEach((row, index) => {
            const cells = row.querySelectorAll("td");
            if (cells.length > 0) { // Ignore rows with no data
                data.push({
                    "NrCrt": cells[0].textContent.trim(),
                    "Nume": cells[1].textContent.trim(),
                    "Prenume": cells[2].textContent.trim(),
                    "Functie": cells[3].textContent.trim(),
                    "Departament": cells[4].textContent.trim()
                });
            }
        });

        // Convert JSON array to string
        const jsonString = JSON.stringify(data, null, 2); // Pretty print JSON

        // Create a Blob and trigger a download
        const blob = new Blob([jsonString], { type: "application/json" });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "table_data.json";
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }
</script>
<script>
async function sendJsonToPDFServer() {
    console.log("🚀 Fetching JSON data from this page...");
    const currentUrl = window.location.pathname;
    const currentParams = window.location.search;
    const separator = currentParams ? '&' : '?';
    const fetchUrl = currentUrl + currentParams + separator + "json=true";
    
    console.log("Starting fetch from:", fetchUrl);

   
    try {
        let response = await fetch(fetchUrl);
        
        if (!response.ok) {
            throw new Error("❌ Error fetching JSON data: " + response.statusText);
        }
        
        let jsonData = await response.json();
        console.log("✅ JSON data received:", jsonData);

        // Now send this JSON to the PDF generator server
        console.log("🚀 Sending JSON to PDF generator...");
        let pdfResponse = await fetch("generatePDF.jsp", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(jsonData)
        });

        if (!pdfResponse.ok) {
            throw new Error("❌ Error sending JSON to PDF server: " + pdfResponse.statusText);
        }

        console.log("✅ PDF successfully generated! Downloading...");

        // 🔹 Extrage numele fișierului din header-ul Content-Disposition
        let contentDisposition = pdfResponse.headers.get("Content-Disposition");
        let fileName = "Raport_Angajati.pdf"; // Default dacă nu găsim în header

        if (contentDisposition) {
            let match = contentDisposition.match(/filename="(.+)"/);
            if (match) {
                fileName = match[1];
            }
        }

        console.log("📂 Numele fișierului detectat:", fileName);

        // Convert response to blob and trigger download
        let blob = await pdfResponse.blob();
        let url = window.URL.createObjectURL(blob);
        let a = document.createElement("a");
        a.href = url;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        
    } catch (error) {
        console.error("🔥 Error:", error);
        alert("Eroare la trimiterea datelor către serverul de PDF!");
    }
}

</script>
<!-- Modal pentru introducerea motivului -->
<div id="myModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <form id="theform" method="POST">
            <label for="reason">Motivul aprobarii/respingerii:</label>
            <input class="login__input" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" id="reason" name="reason" required>
            <input type="hidden" id="actionUrl" name="actionUrl">
            <button type="submit">Trimite</button>
        </form>
    </div>
</div>
</body>
</html>

