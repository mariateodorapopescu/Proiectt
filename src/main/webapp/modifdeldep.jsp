<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.*, com.fasterxml.jackson.databind.ObjectMapper" %>


<%
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
    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
    
    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
        
        preparedStatement.setString(1, username);
        ResultSet rs = preparedStatement.executeQuery();
        
        if (!rs.next()) {
            if ("true".equals(request.getParameter("json"))) {
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"Date introduse incorect sau nu exista date!\"}");
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
                response.sendRedirect("modifdeldep.jsp");
            }
            return;
        }

        int id = rs.getInt("id");
        int userType = rs.getInt("tip");
        int userdep = rs.getInt("id_dep");
        
        if (userType != 4) {  // Only type 4 users can approve
            if ("true".equals(request.getParameter("json"))) {
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"Acces neautorizat\"}");
            } else {
                switch (userType) {
                    case 1: response.sendRedirect("tip1ok.jsp"); break;
                    case 2: response.sendRedirect("tip1ok.jsp"); break;
                    case 3: response.sendRedirect("sefok.jsp"); break;
                    case 0: response.sendRedirect("dashboard.jsp"); break;
                }
            }
            return;
        }

        // Handle JSON request
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            List<Map<String, String>> departamente = new ArrayList<>();
            
            String sql = "SELECT * from departament";

            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                ResultSet rs1 = stmt.executeQuery();
                
                while (rs1.next()) {
                    Map<String, String> departament = new LinkedHashMap<>();
                    departament.put("Nume_Departament", rs1.getString("nume_dep"));
                    departament.put("id_dep", rs1.getString("id_dep")); // needed for action buttons
                    departamente.add(departament);
                }
            }

            Map<String, Object> responseJson = new HashMap<>();
            responseJson.put("header", "Vizualizare si modificare departamente din toata institutia");
            responseJson.put("data", departamente);

            ObjectMapper objectMapper = new ObjectMapper();
            response.getWriter().write(objectMapper.writeValueAsString(responseJson));
            
            return;
        }

        // If not JSON request, continue with normal HTML output
        String today = null;
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                try (ResultSet rs2 = stmt.executeQuery()) {
                    if (rs2.next()) {
                        today = rs2.getString("today");
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
            e.printStackTrace();
        }

        // Get theme colors
        String accent = null;
        String clr = null;
        String sidebar = null;
        String text = null;
        String card = null;
        String hover = null;
        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            String query = "SELECT * from teme where id_usr = ?";
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
        } catch (SQLException e) {
            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
            e.printStackTrace();
        }
%>
<html>
<head>
    <title>Departamente</title>
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
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
       
        .tooltip {
            position: relative;
            display: inline-block;
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
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

    <div class="main-content" style="border-radius: 2rem;">
        <div class="header" style="border-radius: 2rem;"></div>
        <div class="content" style="border-radius: 2rem;">
            <div class="intro" style="border-radius: 2rem; background:<%out.println(sidebar);%>;">
                <div class="events" style="border-radius: 2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                    <h1 id="tableTitle">Vizaualizare si modificare departamente din toata institutia</h1>
                    <h3 id="tableDate"><%out.println(today); %></h3>
                    <table id="departamenteTable">
                        <thead>
                            <tr style="color:<%out.println("white");%>">
                                <th>Nume departament</th>
                                <th>Adaugare adresa</th>
                                <th>Modificati numele</th>
                                <th>Stergeti</th>
                            </tr>
                        </thead>
                        <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                            <!-- Se încarcă dinamic -->
                        </tbody>
                    </table>
                </div>
                <div class="into">
                    <button id="generate" onclick="sendJsonToPDFServer()">Descarcati PDF</button>
                    <button><a href='viewdep2.jsp'>Inapoi</a></button>
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
                console.warn("⚠️ JSON-ul nu conține date valide.");
                const tableBody = document.querySelector("#departamenteTable tbody");
                tableBody.innerHTML = "<tr><td colspan='4'>Nu exista date.</td></tr>";
                return;
            }

            document.getElementById("tableTitle").textContent = jsonData.header;
            
            const tableBody = document.querySelector("#departamenteTable tbody");
            tableBody.innerHTML = "";

            jsonData.data.forEach((row, index) => {
                console.log("🔍 Rand:", row);
                const tr = document.createElement("tr");
                
                let cellsHtml = "";
                cellsHtml += "<td data-label='Nume departament'>" + (row.Nume_Departament || 'N/A') + "</td>";
                
                // Butoanele de acțiune
                cellsHtml += "<td data-label='Adaugare adresa'><span class='status-icon status-neaprobat'><a href='NewFile1.jsp?id=" + row.id_dep + "'><i class='ri-edit-circle-line'></i></a></span></td>";
                cellsHtml += "<td data-label='Modificati numele'><span class='status-icon status-aprobat-director'><a href='modifdep2.jsp?username=" + row.Nume_Departament + "'><i class='ri-edit-circle-line'></i></a></span></td>";
                cellsHtml += "<td data-label='Stergeti'><span class='status-icon status-dezaprobat-director'><a href='DelDepServlet?username=" + row.Nume_Departament + "'><i class='ri-close-line'></i></a></span></td>";

                tr.innerHTML = cellsHtml;
                tableBody.appendChild(tr);
            });

            console.log("✅ Tabel încărcat cu succes!");
        })
        .catch(error => console.error("🔥 Eroare AJAX:", error));
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

        let contentDisposition = pdfResponse.headers.get("Content-Disposition");
        let fileName = "Raport_Departamente.pdf";

        if (contentDisposition) {
            let match = contentDisposition.match(/filename="(.+)"/);
            if (match) {
                fileName = match[1];
            }
        }

        console.log("📂 Numele fișierului detectat:", fileName);

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
<%
    } catch (Exception e) {
        e.printStackTrace();
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Eroare la baza de date: " + e.getMessage() + "\"}");
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Eroare la baza de date!');");
            out.println("</script>");
            response.sendRedirect("modifdeldep.jsp");
        }
    }
%>