<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser, jakarta.servlet.http.HttpSession" %>

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
    int userdep = 0, id = 0, userType = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";

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
                    String functie = rs.getString("functie");
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

    // Dacă cererea este pentru JSON, returnăm direct JSON-ul
    if ("true".equals(request.getParameter("json"))) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        List<Map<String, String>> employees = new ArrayList<>();
        try {
            // Folosim interogarea originală din prima pagină
            String sql = "SELECT d.nume_dep AS departament, u.nume, u.prenume, " +
                    "t.denumire AS functie " +
                    "FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "WHERE u.activ = 1 and u.id <> " + id;
            
            if (userType == 3) {
                sql = sql + " and u.id_dep = " + userdep;     
            }

        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        		PreparedStatement stmt = connection.prepareStatement(sql)) {
            ResultSet rs1 = stmt.executeQuery();
            int nr = 1;
            while (rs1.next()) {
                Map<String, String> employee = new LinkedHashMap<>();
                employee.put("NrCrt", String.valueOf(nr++));
                employee.put("Nume", rs1.getString("nume"));
                employee.put("Prenume", rs1.getString("prenume"));
                employee.put("Functie", rs1.getString("functie"));
                employee.put("Departament", rs1.getString("departament"));
                employees.add(employee);
            }
        }

        Map<String, Object> responseJson = new HashMap<>();
        responseJson.put("header", "Utilizatori activi");
        responseJson.put("data", employees);

        ObjectMapper objectMapper = new ObjectMapper();
        out.print(objectMapper.writeValueAsString(responseJson));
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
        <title>Vizualizare angajati</title>
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
        
    </head>
    <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
        <div style="position: fixed; top: 0; left: 25%; margin: 0; position: relative; padding-left:1rem; padding-right:1rem;" class="main-content">
            <div style=" border-radius: 2rem;" class="content">
                <div class="intro" style=" border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                    <div class="events"  style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">

                        <h1 id="tableTitle">Angajati activi</h1>
                        <h3 id="tableDate"></h3>
                        <table id="employeeTable">
                            <thead>
                                <tr style="color:<%out.println("white");%>">
                                    <th>Nr. crt.</th>
                                    <th>Nume</th>
                                    <th>Prenume</th>
                                    <th>Functie</th>
                                    <th>Departament</th>
                                </tr>
                            </thead>
                            <tbody id="dateaici" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                                <!-- Se încarcă dinamic -->
                            </tbody>
                        </table>
                    </div>
                    
                    <button id="generate" onclick="sendJsonToPDFServer()">Descarcati PDF</button>
                   <button id="inapoi" ><a href ="viewang.jsp">Inapoi</a></button>
                
                </div>
            </div>
        </div>
            
     <script>
        document.addEventListener("DOMContentLoaded", function () {
            console.log("🚀 Pagina încărcată, începe request-ul AJAX...");

            fetch("activi.jsp?json=true")
                .then(response => {
                    if (!response.ok) {
                        throw new Error("❌ Eroare la fetch: " + response.statusText);
                    }
                    return response.json();
                })
                .then(jsonData => {
                    console.log("✅ JSON primit:", jsonData);

                    if (!jsonData || !jsonData.data || jsonData.data.length === 0) {
                        console.warn("⚠️ JSON-ul nu conține date valide.");
                        document.getElementById("dateaici").textContent = "Nu există angajați disponibili!";
                        return;
                    }

                    document.getElementById("tableTitle").textContent = jsonData.header;
                    document.getElementById("tableDate").textContent = new Date().toLocaleDateString("ro-RO");

                    const tableBody = document.querySelector("#employeeTable tbody");
                    tableBody.innerHTML = "";

                    jsonData.data.forEach((row, index) => {
                        console.log("🔍 Rand:", row);
                        const tr = document.createElement("tr");

                        tr.innerHTML =
                            "<td>" + (row.NrCrt ? row.NrCrt : index + 1) + "</td>" +
                            "<td>" + (row.Nume ? row.Nume : 'N/A') + "</td>" +
                            "<td>" + (row.Prenume ? row.Prenume : 'N/A') + "</td>" +
                            "<td>" + (row.Functie ? row.Functie : 'N/A') + "</td>" +
                            "<td>" + (row.Departament ? row.Departament : 'N/A') + "</td>";

                        tableBody.appendChild(tr);
                    });

                    console.log("✅ Tabel încărcat cu succes!");
                })
                .catch(error => console.error("🔥 Eroare AJAX:", error));
        });
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
    
    try {
        let response = await fetch("activi.jsp?json=true");
        
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

</body>
</html>
