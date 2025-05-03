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
    int userdep = 0, id = 0, userType = 0, ierarhie = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";
    String functie = "";

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
                id = rs.getInt("id");
                userType = rs.getInt("tip");
                userdep = rs.getInt("id_dep");
                functie = rs.getString("functie");
                ierarhie = rs.getInt("ierarhie");
                if (functie.compareTo("Administrator") != 0) {  
                  
                      
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

    // Funcție helper pentru a determina rolul utilizatorului
    boolean isDirector = (ierarhie < 3) ;
    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
    boolean isUtilizatorNormal = !isDirector && !isSef; // tipuri 1, 2, 5-9

    // Debug userType
    System.out.println("userType: " + userType);
    System.out.println("isDirector: " + isDirector);
    System.out.println("isSef: " + isSef);
    System.out.println("isUtilizatorNormal: " + isUtilizatorNormal);

    // Dacă cererea este pentru JSON, returnăm direct JSON-ul
    if ("true".equals(request.getParameter("json"))) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Generăm data curentă
        String today = LocalDate.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        List<Map<String, String>> adeverinte = new ArrayList<>();
        try {
            String sql = "SELECT a.id AS nr_crt, a.id_ang, u.nume, u.prenume, d.nume_dep AS departament, " +
                    "t.denumire AS functie, ta.denumire AS tip_adeverinta, a.motiv, s.nume_status AS status, " +
                    "a.creare, a.modif, a.pentru_servi " +
                    "FROM adeverinte a " +
                    "JOIN useri u ON u.id = a.id_ang " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "JOIN statusuri s ON a.status = s.status " +
                    "JOIN tip_adev ta ON a.tip = ta.id " +
                    "WHERE 1=1"; // Întotdeauna true pentru a putea adăuga condiții cu AND
            
            String pagParam = request.getParameter("pag");
            System.out.println("pagParam: " + pagParam);

            // Filtru pentru pagina 1 (adeverințele mele)
            if (pagParam != null && pagParam.equals("1")) {
                // Utilizatorul vede doar adeverințele proprii
                sql += " AND a.id_ang = " + id;
                System.out.println("Filtru adăugat pentru id_ang = " + id);
            } 
            // Filtru pentru șefi - văd adeverințele departamentului lor în așteptare
            else if (isSef && pagParam == null) {
                sql += " AND u.id_dep = " + userdep + " AND a.status = 0";
                System.out.println("Filtru adăugat pentru șef: id_dep = " + userdep + ", status = 0");
            } 
            // Filtru pentru directori - văd adeverințele departamentului lor aprobate de șef
            else if (isDirector && pagParam == null) {
                sql += " AND u.id_dep = " + userdep + " AND a.status = 1";
                System.out.println("Filtru adăugat pentru director: id_dep = " + userdep + ", status = 1");
            } 
            // Utilizatori normali - când nu sunt pe pagina 1, văd doar adeverințele lor
            else if (isUtilizatorNormal && pagParam == null) {
                sql += " AND a.id_ang = " + id;
                System.out.println("Filtru adăugat pentru utilizator normal: id_ang = " + id);
            }
            
            // Debug SQL
            System.out.println("SQL query: " + sql);
            
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement stmt = connection.prepareStatement(sql)) {
                ResultSet rs = stmt.executeQuery();
                
                int nr = 1;
                while (rs.next()) {
                    Map<String, String> adeverinta = new LinkedHashMap<>();
                    adeverinta.put("NrCrt", String.valueOf(nr++));
                    adeverinta.put("Nume", rs.getString("nume"));
                    adeverinta.put("Prenume", rs.getString("prenume"));
                    adeverinta.put("Fct", rs.getString("functie"));
                    adeverinta.put("Dep", rs.getString("departament"));
                    adeverinta.put("TipAdev", rs.getString("tip_adeverinta"));
                    adeverinta.put("Motiv", rs.getString("motiv"));
                    adeverinta.put("Creare", rs.getString("creare") != null ? rs.getString("creare") : "N/A");
                    adeverinta.put("Modif", rs.getString("modif") != null ? rs.getString("modif") : "N/A");
                    adeverinta.put("Pentru_servi", rs.getString("pentru_servi") != null ? rs.getString("pentru_servi") : "N/A");
                    adeverinta.put("Status", rs.getString("status"));
                    adeverinta.put("id", rs.getString("nr_crt")); // pentru butoanele de acțiune
                    adeverinte.add(adeverinta);
                }
            }
            
            Map<String, Object> responseJson = new HashMap<>();
            responseJson.put("header", "Adeverințele mele");
            responseJson.put("data", adeverinte);
            responseJson.put("today", today);

            ObjectMapper objectMapper = new ObjectMapper();
            out.print(objectMapper.writeValueAsString(responseJson));
        } catch (Exception e) {
            System.out.println("Eroare la generarea JSON: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"" + e.getMessage() + "\"}");
        }
        return;
    }
%>

<!DOCTYPE html>
<html lang="ro">
   <head>
        <title>Adeverințele mele</title>
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
        <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
       
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

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #666;
        }
        
        .empty-state i {
            font-size: 48px;
            margin-bottom: 20px;
            color: #ccc;
        }
        
        .empty-state h3 {
            margin-bottom: 10px;
            font-weight: 500;
        }
        
        .empty-state p {
            margin-bottom: 20px;
        }
        
        .add-button {
            display: inline-block;
            background-color: <%=accent%>;
            color: white !important;
            padding: 10px 20px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.3s;
        }
        
        .add-button:hover {
            background-color: <%=hover%>;
        }
        </style>
    </head>
    <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
<!-- Conținut pagină -->
<div style="position: fixed; top: 0; left: 0; margin: 0; padding-left:1rem; padding-right:1rem;" class="main-content">
    <div style="border-radius: 2rem;" class="content">
        <div class="intro" style="border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
            <div class="events" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                <%
                if (request.getParameter("pag")!=null || (request.getParameter("pag")== null && (userType != 3 && userType != 0))) {
                %>
                <h1>Adeverințele mele</h1>
                <% } else {%>
                <h1>Toate adeverințele</h1>
                <%} %>
                
                <h3 id="tableDate"></h3>
                <table id="adeverinteTable">
                    <thead>
                        <tr style="color:<%out.println("white");%>">
                            <th style="color:white">Nr.crt</th>
                            <th style="color:white">Nume</th>
                            <th style="color:white">Prenume</th>
                            <th style="color:white">Fct.</th>
                            <th style="color:white">Dep.</th>
                            <th style="color:white">Tip adeverință</th>
                            <th style="color:white">Pentru a servi la</th>
                            
                            <th style="color:white">Creare</th>
                            <th style="color:white">Modif.</th>
                            <th style="color:white">Motiv</th>
                            <th style="color:white">Status</th>
                            
                            <%
                            if (request.getParameter("pag")== null && (userType == 3 || userType == 0)) {
                            %>
                            <th style="color:white">Aprob.</th>
                            <th style="color:white">Resp.</th>
                            <% } 
                            if (request.getParameter("pag")!=null && request.getParameter("pag").compareTo("1")==0) {
                            %>
                            <th style="color:white">Descarcă</th>
                            <th style="color:white">Modif.</th>
                            <th style="color:white">Șterge</th>
                            <%} %>
                        </tr>
                    </thead>
                    <tbody id="dateaici" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                        <!-- Se încarcă dinamic -->
                    </tbody>
                </table>
                
                <!-- Stare goală care va fi afișată dacă nu există adeverințe -->
                <div id="emptyState" class="empty-state" style="display:none">
                    <i class="ri-file-list-3-line"></i>
                    <h3>Nu există adeverințe</h3>
                    <p>Nu aveți adeverințe adăugate în sistem.</p>
                    <a href="addadev.jsp" class="add-button">
                        <i class="ri-add-line"></i> Adaugă adeverință
                    </a>
                </div>
            </div>
            
            <button id="generate" onclick="sendJsonToPDFServer()">Descarcă PDF</button>
            <button id="inapoi"><a href="actiuni2.jsp">Înapoi</a></button>
        </div>
    </div>
</div>

<!-- Modal pentru introducerea motivului -->
<div id="myModal" class="modal">
    <div class="modal-content">
        <span class="close">&times;</span>
        <form id="theform" method="POST">
            <label for="reason">Motivul aprobării/respingerii:</label>
            <input class="login__input" style="border-color:<%=accent%>; background:<%=clr%>; color:<%=text%>" type="text" id="reason" name="reason" required>
            <input type="hidden" id="actionUrl" name="actionUrl">
            <button type="submit">Trimite</button>
        </form>
    </div>
</div>

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
                document.getElementById("adeverinteTable").style.display = "none";
                document.getElementById("emptyState").style.display = "block";
                return;
            }

            document.getElementById("tableDate").textContent = new Date().toLocaleDateString("ro-RO");
            document.getElementById("emptyState").style.display = "none";
            document.getElementById("adeverinteTable").style.display = "table";

            const tableBody = document.querySelector("#adeverinteTable tbody");
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
                cellsHtml += "<td data-label='TipAdev'>" + (row.TipAdev || 'N/A') + "</td>";
                cellsHtml += "<td data-label='Pentru_servi'>" + (row.Pentru_servi || 'N/A') + "</td>";
              
                cellsHtml += "<td data-label='Creare'>" + (row.Creare || 'N/A') + "</td>";
                cellsHtml += "<td data-label='Modif'>" + (row.Modif || 'N/A') + "</td>";
                cellsHtml += "<td data-label='Motiv'>" + (row.Motiv || 'N/A') + "</td>";

                cellsHtml += "<td class='tooltip' data-label='Status'>" +
                            "<span class='tooltiptext'>" + row.Status + "</span>" +
                            "<span class='status-icon status-" + statusClass + "'>" +
                            "<i class='" + statusIcon + "'></i>" +
                            "</span>" +
                            "</td>";

                // Butoane pentru șef
                if (<%=userType%> === 3 && !<%=request.getParameter("pag") != null%>) {
                    if (row.Status === "Neaprobat") {
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-aprobat-sef'>" +
                                    "<a href='javascript:void(0);' onclick='showModal(\"AprobAdevSef?idadev=" + row.id + "\")'>" +
                                    "<i class='ri-checkbox-circle-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-sef'>" +
                                    "<a href='javascript:void(0);' onclick='showModal(\"ResAdevSefServlet?idadev=" + row.id + "\")'>" +
                                    "<i class='ri-close-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                    } else {
                        // Dacă nu este Neaprobat, afișăm butoane dezactivate
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-aprobat-sef' style='opacity: 0.5;'>" +
                                    "<i class='ri-checkbox-circle-line'></i>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-sef' style='opacity: 0.5;'>" +
                                    "<i class='ri-close-line'></i>" +
                                    "</span>" +
                                    "</td>";
                    }
                }

                // Butoane pentru director
                if (<%=userType%> === 0 && !<%=request.getParameter("pag") != null%>) {
                    if (row.Status === "Aprobat sef") {
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-aprobat-director'>" +
                                    "<a href='javascript:void(0);' onclick='showModal(\"AprobAdevDirServlet?idadev=" + row.id + "\")'>" +
                                    "<i class='ri-checkbox-circle-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-director'>" +
                                    "<a href='javascript:void(0);' onclick='showModal(\"ResAdevDirServlet?idadev=" + row.id + "\")'>" +
                                    "<i class='ri-close-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                    } else {
                        // Dacă nu este Aprobat sef, afișăm butoane dezactivate
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-aprobat-director' style='opacity: 0.5;'>" +
                                    "<i class='ri-checkbox-circle-line'></i>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-director' style='opacity: 0.5;'>" +
                                    "<i class='ri-close-line'></i>" +
                                    "</span>" +
                                    "</td>";
                    }
                }

                // Butoane de descărcare/modificare/ștergere
                if (<%=request.getParameter("pag") != null%>) {
                    // Buton de descărcare - doar pentru adeverințe aprobate
                    if (row.Status === "Aprobat director") {
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-aprobat-director'>" +
                                    "<a href='DescarcaAdeverintaServlet?idadev=" + row.id + "'>" +
                                    "<i class='ri-download-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                    } else {
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-neaprobat' style='opacity: 0.5;'>" +
                                    "<i class='ri-download-line'></i>" +
                                    "</span>" +
                                    "</td>";
                    }
                    
                    // Butoane de modificare și ștergere - doar pentru adeverințe neaprobate sau aprobate de șef
                    if (row.Status === "Neaprobat" || 
                        (row.Status === "Aprobat sef" && (<%=userType%> === 3 || <%=userType%> === 0))) {
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-neaprobat'>" +
                                    "<a href='modifadev.jsp?idadev=" + row.id + "'>" +
                                    "<i class='ri-edit-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-director'>" +
                                    "<a href='DelAdevServlet?idadev=" + row.id + "'>" +
                                    "<i class='ri-delete-bin-line'></i>" +
                                    "</a>" +
                                    "</span>" +
                                    "</td>";
                    } else {
                        // Butoane dezactivate
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-neaprobat' style='opacity: 0.5;'>" +
                                    "<i class='ri-edit-line'></i>" +
                                    "</span>" +
                                    "</td>";
                        cellsHtml += "<td data-label='Status'>" +
                                    "<span class='status-icon status-dezaprobat-director' style='opacity: 0.5;'>" +
                                    "<i class='ri-delete-bin-line'></i>" +
                                    "</span>" +
                                    "</td>";
                    }
                }

                tr.innerHTML = cellsHtml;
                tableBody.appendChild(tr);
            });

            console.log("✅ Tabel încărcat cu succes!");
        })
        .catch(error => {
            console.error("🔥 Eroare AJAX:", error);
            document.getElementById("adeverinteTable").style.display = "none";
            document.getElementById("emptyState").style.display = "block";
        });
});

// Codul pentru modal
document.addEventListener("DOMContentLoaded", function() {
    // Definim variabilele pentru modal după ce DOM-ul este încărcat
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

// Funcție pentru trimiterea datelor către PDF
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

        // Extrage numele fișierului din header-ul Content-Disposition
        let contentDisposition = pdfResponse.headers.get("Content-Disposition");
        let fileName = "Raport_Adeverinte.pdf"; // Default dacă nu găsim în header

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

function generate() {
    const element = document.getElementById("content");
    html2pdf()
    .from(element)
    .save();
}
</script>
</body>
</html>