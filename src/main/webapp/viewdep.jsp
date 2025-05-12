<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.util.*, com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    // Obținem sesiunea curentă
    HttpSession sesi = request.getSession(false);
	boolean isAdmin = false;
    
    // Verificăm dacă există o sesiune
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

    // Verificăm dacă utilizatorul este logat
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
    int userType = 0;
    int id = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";
    String today = null;

    Class.forName("com.mysql.cj.jdbc.Driver");
    
    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement preparedStatement = connection.prepareStatement(
                "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                "dp.denumire_completa AS denumire_specifică FROM useri u " +
                "JOIN tipuri t ON u.tip = t.tip " +
                "JOIN departament d ON u.id_dep = d.id_dep " +
                "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                "WHERE u.username = ?")) {
                
        preparedStatement.setString(1, username);
        ResultSet rs = preparedStatement.executeQuery();
        
        if (rs.next()) {
            id = rs.getInt("id");
            userType = rs.getInt("tip");
            String functie = rs.getString("functie");
            int ierarhie = rs.getInt("ierarhie");

            // Funcție helper pentru a determina rolul utilizatorului
            boolean isDirector = (ierarhie < 3);
            boolean isSef = (ierarhie >= 4 && ierarhie <= 5);
            boolean isIncepator = (ierarhie >= 10);
            boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
            isAdmin = (functie.compareTo("Administrator") == 0);

            // Obținem data curentă formatată
            try (PreparedStatement dateStmt = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today")) {
                ResultSet dateRs = dateStmt.executeQuery();
                if (dateRs.next()) {
                    today = dateRs.getString("today");
                }
            }

            // Obținem setările temei utilizatorului
            try (PreparedStatement themeStmt = connection.prepareStatement("SELECT * from teme where id_usr = ?")) {
                themeStmt.setInt(1, id);
                ResultSet themeRs = themeStmt.executeQuery();
                if (themeRs.next()) {
                    accent = themeRs.getString("accent");
                    clr = themeRs.getString("clr");
                    sidebar = themeRs.getString("sidebar");
                    text = themeRs.getString("text");
                    card = themeRs.getString("card");
                    hover = themeRs.getString("hover");
                }
            }

            // Verificăm dacă cererea este pentru JSON
            if ("true".equals(request.getParameter("json"))) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                List<Map<String, String>> departamente = new ArrayList<>();
                try (PreparedStatement deptStmt = connection.prepareStatement(
                        "SELECT dep.nume_dep, dep.id_dep, COUNT(*) as total " +
                        "FROM useri ang JOIN departament dep ON ang.id_dep = dep.id_dep " +
                        "GROUP BY dep.id_dep")) {
                    
                    ResultSet deptRs = deptStmt.executeQuery();
                    
                    int nr = 1;
                    while (deptRs.next()) {
                        Map<String, String> departament = new LinkedHashMap<>();
                        departament.put("NrCrt", String.valueOf(nr++));
                        departament.put("NumeDepartament", deptRs.getString("nume_dep"));
                        departament.put("NrAngajati", deptRs.getString("total"));
                        departamente.add(departament);
                    }
                }
                
                Map<String, Object> responseJson = new HashMap<>();
                responseJson.put("header", "Departamente din toată instituția");
                responseJson.put("data", departamente);
                responseJson.put("today", today);
                
                ObjectMapper objectMapper = new ObjectMapper();
                out.print(objectMapper.writeValueAsString(responseJson));
                return;
            }

            // Continuăm cu renderizarea paginii normale
            if (!isAdmin && !isDirector) {
                if (isUtilizatorNormal) {
                    response.sendRedirect("tip1ok.jsp");
                    return;
                }
                if (isSef) {
                    response.sendRedirect("sefok.jsp");
                    return;
                }
                if (isIncepator) {
                    response.sendRedirect("tip2ok.jsp");
                    return;
                }
            }
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Date introduse incorect sau nu exista date!');");
            out.println("</script>");
            return;
        }
    } catch (Exception e) {
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la baza de date!');");
            out.println("</script>");
        }
        e.printStackTrace();
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Vizualizare departamente</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
        .main-content, .content, .events {
            overflow: auto;
        }
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

        ::-webkit-scrollbar {
            display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
        }
    </style>
</head>
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>">
    <div style="border-radius:2rem; position: fixed; top: 0; left: 28%;" class="main-content">
        <div style="border-radius:2rem;" class="header"></div>
        <div style="border-radius:2rem;" class="content">
            <div class="intro" style="border-radius:2rem; background:<%=sidebar%>; color:<%=text%>">
                <div class="events" id="content" style="border-radius:2rem; background:<%=sidebar%>; color:<%=text%>">
                    <h1 id="tableTitle">Departamente din toată instituția</h1>
                    <h3 id="tableDate"><%=today%></h3>
               
                    <table id="departmentTable">
                        <thead>
                            <tr style="color:white">
                                <th>Nr. crt</th>
                                <th>Nume departament</th>
                                <th>Nr. angajați</th>
                            </tr>
                        </thead>
                        <tbody id="dateaici" style="background:<%=sidebar%>; color:<%=text%>">
                            <!-- Datele vor fi încărcate dinamic prin AJAX -->
                        </tbody>
                    </table> 
                </div>
                <div class="into">
                    <button id="generate" onclick="sendJsonToPDFServer()">Descărcați PDF</button>  
                    <% if (isAdmin) { %>
                    <button onclick="window.location.href='adminok.jsp'">Înapoi</button>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <script>
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
                        document.getElementById("dateaici").innerHTML = "<tr><td colspan='3'>Nu există departamente disponibile!</td></tr>";
                        return;
                    }

                    document.getElementById("tableTitle").textContent = jsonData.header;
                    document.getElementById("tableDate").textContent = jsonData.today;

                    const tableBody = document.getElementById("dateaici");
                    tableBody.innerHTML = "";

                    jsonData.data.forEach(row => {
                        console.log("🔍 Rand procesat:", row);
                        
                        const tr = document.createElement("tr");
                        
                        // Creăm celulele explicit
                        const tdNr = document.createElement("td");
                        tdNr.textContent = row.NrCrt;
                        tdNr.setAttribute("data-label", "Nr.crt");
                        
                        const tdNume = document.createElement("td");
                        tdNume.textContent = row.NumeDepartament;
                        tdNume.setAttribute("data-label", "Nume Departament");
                        
                        const tdAngajati = document.createElement("td");
                        tdAngajati.textContent = row.NrAngajati;
                        tdAngajati.setAttribute("data-label", "Nr Angajați");
                        
                        // Adăugăm celulele la rând
                        tr.appendChild(tdNr);
                        tr.appendChild(tdNume);
                        tr.appendChild(tdAngajati);
                        
                        // Adăugăm rândul la tabel
                        tableBody.appendChild(tr);
                    });

                    console.log("✅ Tabel încărcat cu succes!");
                })
                .catch(error => {
                    console.error("🔥 Eroare AJAX:", error);
                    document.getElementById("dateaici").innerHTML = "<tr><td colspan='3'>Eroare la încărcarea datelor!</td></tr>";
                });
        });
        
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

                // Trimitem acest JSON către generatorul de PDF
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

                // Extragem numele fișierului din header-ul Content-Disposition
                let contentDisposition = pdfResponse.headers.get("Content-Disposition");
                let fileName = "Raport_Departamente.pdf"; // Default dacă nu găsim în header

                if (contentDisposition) {
                    let match = contentDisposition.match(/filename="(.+)"/);
                    if (match) {
                        fileName = match[1];
                    }
                }

                console.log("📂 Numele fișierului detectat:", fileName);

                // Convertim răspunsul în blob și declanșăm descărcarea
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