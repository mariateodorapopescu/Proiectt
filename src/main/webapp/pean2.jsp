<%@ page import="java.io.*, java.util.*, java.sql.*, bean.MyUser, jakarta.servlet.http.*" %>
<%! 
public String join(ArrayList<?> arr, String del) {
    StringBuilder output = new StringBuilder();
    for (int i = 0; i < arr.size(); i++) {
        if (i > 0) output.append(del);
        if (arr.get(i) instanceof String) output.append("\"");
        output.append(arr.get(i));
        if (arr.get(i) instanceof String) output.append("\"");
    }
    return output.toString();
}
%>
<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement preparedStatement = connection.prepareStatement(
            		 "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                             "dp.denumire_completa AS denumire FROM useri u " +
                             "JOIN tipuri t ON u.tip = t.tip " +
                             "JOIN departament d ON u.id_dep = d.id_dep " +
                             "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                             "WHERE u.username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                int userDep = rs.getInt("id_dep");
                String functie = rs.getString("functie");
                int ierarhie = rs.getInt("ierarhie");
                String numeDepartament = rs.getString("nume_dep");

                // Functie helper pentru a determina rolul utilizatorului
                boolean isDirector = (ierarhie < 3) ;
                boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                boolean isIncepator = (ierarhie >= 10);
                boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                boolean isAdmin = (functie.compareTo("Administrator") == 0);
                
                if (isAdmin) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }
                String accent, clr, sidebar, text, card, hover;
                try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    String query = "SELECT * from teme where id_usr = ?";
                    try (PreparedStatement stmt = connection.prepareStatement(query)) {
                        stmt.setInt(1, userId);
                        try (ResultSet rs2 = stmt.executeQuery()) {
                            if (rs2.next()) {
                                accent = rs2.getString("accent");
                                clr = rs2.getString("clr");
                                sidebar = rs2.getString("sidebar");
                                text = rs2.getString("text");
                                card = rs2.getString("card");
                                hover = rs2.getString("hover");
%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raport Departament</title>
    <script src="https://cdn.zingchart.com/zingchart.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <style>
        :root {
            --accent: <%=accent%>;
            --clr: <%=clr%>;
            --sidebar: <%=sidebar%>;
            --text: <%=text%>;
            --card: <%=card%>;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        html, body {
            height: 100%;
            overflow: hidden;
            margin: 0;
            padding: 0;
            background: var(--clr);
            font-family: 'Arial', sans-serif;
            color: var(--text);
        }
        
        /* Main layout structure */
        .app-container {
            display: flex;
            flex-direction: column;
            height: 100vh;
            width: 100%;
            overflow: hidden;
            padding: 10px;
        }
        
        .app-header {
            flex: 0 0 auto;
            padding: 10px 0;
            text-align: center;
            margin-bottom: 10px;
        }
        
        .app-body {
            flex: 1;
            display: flex;
            gap: 20px;
            min-height: 0; /* Important for flex child scrolling */
            height: calc(100% - 70px); /* Header height + margin */
        }
        
        /* Filter panel */
        .filter-panel {
            flex: 0 0 300px;
            background-color: var(--sidebar);
            border-radius: 15px;
            padding: 20px;
            margin-top: 50px; /* Push filters down as requested */
            height: calc(100% - 50px); /* Account for the top margin */
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            overflow-y: auto;
        }
        
        /* Main content */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            background-color: var(--sidebar);
            border-radius: 15px;
            padding: 20px;
            overflow-y: auto;
            min-width: 0; /* Important for flex child sizing */
        }
        
        /* Chart container */
        .chart-container {
            flex: 1;
            background-color: var(--sidebar);
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            min-height: 300px;
            display: flex;
            flex-direction: column;
        }
        
        #myChart {
            flex: 1;
            width: 100%;
            min-height: 300px;
        }
        
        /* Info section */
        .info-container {
            flex: 0 0 auto;
            background-color: var(--sidebar);
            border-radius: 10px;
            padding: 15px;
            margin-top: 10px;
        }
        
        /* Headers */
        h1, h2, h3, h4 {
            color: var(--accent);
            margin-bottom: 15px;
        }
        
        .header-title {
            text-align: center;
            font-size: 1.5rem;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--accent);
        }
        
        /* Form elements */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--accent);
        }
        
        select, input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
            background-color: var(--sidebar);
            color: #333;
        }
        
        .btn {
            display: block;
            width: 100%;
            padding: 12px;
            margin-bottom: 10px;
            background-color: var(--accent);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-align: center;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn:hover {
            opacity: 0.9;
        }
        
        /* Info display */
        .data-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        
        .data-label {
            font-weight: 600;
            color: var(--accent);
        }
        
        .note {
            text-align: center;
            font-style: italic;
            color: #666;
            margin: 5px 0 15px 0;
        }
        
        /* Mobile layout */
        @media (max-width: 767px) {
            .app-body {
                flex-direction: column;
                height: auto;
                overflow-y: auto;
            }
            
            .filter-panel {
                flex: 0 0 auto;
                margin-top: 0;
                height: auto;
                margin-bottom: 15px;
            }
            
            .main-content {
                flex: 1;
                min-height: 500px;
            }
            
            #myChart {
                min-height: 250px;
            }
            
            .app-container {
                height: auto;
                overflow-y: auto;
            }
            
            html, body {
                height: auto;
                overflow-y: auto;
            }
        }
        
        /* Print styles */
        @media print {
            .filter-panel, .btn {
                display: none;
            }
            
            .app-container, .app-body, .main-content {
                display: block;
                height: auto;
            }
            
            body {
                background: var(--sidebar);
            }
        }
    </style>
</head>
<body>
    <div class="app-container">
        <div class="app-header">
            <h1>Raport Departament: <%=numeDepartament%></h1>
        </div>
        
        <div class="app-body">
            <!-- Filter panel -->
            <div class="filter-panel">
                <h3>Optiuni Raport</h3>
                
                <form id="statusForm" method="post" onsubmit="return false;">
                    <div class="form-group">
                        <label>Status concedii</label>
                        <select name="status">
                            <option value="3">Oricare</option>
                            <%
                            try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri ORDER BY status DESC;")) {
                                try (ResultSet rs1 = stm.executeQuery()) {
                                    while (rs1.next()) {
                                        int id = rs1.getInt("status");
                                        String nume = rs1.getString("nume_status");
                                        out.println("<option value='" + id + "'>" + nume + "</option>");
                                    }
                                }
                            }
                            %>
                        </select>
                    </div>
                    
                    <input type="hidden" name="dep" value="<%=userDep%>">
                    <input type="hidden" name="tip" value="1">
                    
                    <div class="form-group">
                        <label>Culoare grafic</label>
                        <input type="color" id="color-picker" value="<%=accent%>">
                    </div>
                    
                    <button class="btn" id="applyFilters">Aplica filtre</button>
                    <button class="btn" onclick="generatePDF()" style="background-color: #4CAF50;">Descarca PDF</button>
                </form>
            </div>
            
            <!-- Main content -->
            <div class="main-content" id="content">
                <h3 id="chartHeader" class="header-title">Raport Concedii</h3>
                <p class="note">*Graficul afiseaza numarul de angajati in fiecare luna</p>
                
                <div class="chart-container">
                    <div id="myChart"></div>
                </div>
                
                <div class="info-container">
                    <h4>Detalii raport</h4>
                    
                    <div class="data-row">
                        <span class="data-label">Status concedii:</span>
                        <span class="data-value" id="statusInfo">Se incarca...</span>
                    </div>
                    
                    <div class="data-row">
                        <span class="data-label">Departament:</span>
                        <span class="data-value" id="departmentInfo"><%=numeDepartament%></span>
                    </div>
                    
                    <div class="data-row">
                        <span class="data-label">Perioada analizata:</span>
                        <span class="data-value" id="dataInfo">Se incarca...</span>
                    </div>
                    
                    <div class="data-row">
                        <span class="data-label">Total angajati:</span>
                        <span class="data-value" id="totalInfo">Se incarca...</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden values for JavaScript -->
    <p id="ceva1" style="display:none;"><%=sidebar%></p>
    <p id="ceva2" style="display:none;"><%=accent%></p>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
<script>
var clear = document.getElementById("ceva1").innerText;
var accent = document.getElementById("ceva2").innerText;
var hbnm = "";
let colorPicker;
let chartData; 
const defaultColor = accent;

// Set up color picker
window.addEventListener("load", startup, false);

function startup() {
    colorPicker = document.querySelector("#color-picker");
    colorPicker.value = defaultColor;
   
    colorPicker.addEventListener("change", updateFirst, false);
    colorPicker.select();
}

function updateFirst(event) {
    hbnm = event.target.value;
}

$(document).ready(function() {
    fetchChartData();

    // Apply filters button
    $('#applyFilters').click(function() {
        fetchChartData();
    });

    function fetchChartData() {
        // Disable buttons during fetch
        $('#applyFilters').prop('disabled', true).text('Se proceseaza...');
        
        $.ajax({
            url: 'JsonServlet',
            type: 'POST',
            data: $('#statusForm').serialize(),
            dataType: 'json',
            success: function(response) {
                chartData = response; 
                updateChart(response);
                updateChartInfo(response);
                $('#applyFilters').prop('disabled', false).text('Aplica filtre');
            },
            error: function(xhr, status, error) {
                alert('Eroare: ' + (xhr.responseJSON?.error || xhr.statusText || error));
                $('#applyFilters').prop('disabled', false).text('Aplica filtre');
            }
        });
    }

    function updateChartInfo(data) {
        // Update status info
        if (data.statusName) {
            $('#statusInfo').text(data.statusName);
        } else {
            $('#statusInfo').text(data.status === '3' ? 'Toate statusurile' : 'Status necunoscut');
        }
        
        // Update date range
        if (data.months && data.months.length > 0) {
            $('#dataInfo').text(data.months[0] + ' - ' + data.months[data.months.length-1]);
        } else {
            $('#dataInfo').text('Nu sunt date disponibile');
        }
        
        // Calculate total from counts
        const total = data.counts ? data.counts.reduce((a, b) => a + b, 0) : 0;
        $('#totalInfo').text(total);
    }

    function updateChart(data) {
        $('#chartHeader').text(data.h3 || 'Raport Concedii Departament');
        
        // Responsive font sizes based on screen width
        const isMobile = window.innerWidth < 768;
        const fontSize = isMobile ? 12 : 16;
        const titleSize = isMobile ? 14 : 18;
        
        zingchart.render({
            id: 'myChart',
            data: {
                type: 'bar',
                backgroundColor: 'transparent',
                title: {
                    text: 'Numar angajati / luna',
                    fontColor: document.getElementById("color-picker").value,
                    fontSize: titleSize
                },
                scaleX: {
                    values: data.months ? data.months.map(month => month.toString()) : [],
                    item: {
                        fontColor: accent,
                        fontSize: fontSize
                    },
                    // Make labels vertical on mobile
                    labels: data.months ? data.months.map(month => month.toString()) : [],
                    "max-labels": isMobile ? 6 : 12,
                    "step": isMobile ? Math.ceil(data.months?.length / 6) || 1 : 1
                },
                scaleY: {
                    item: {
                        fontColor: accent,
                        fontSize: fontSize
                    }
                },
                series: [{
                    values: data.counts || [],
                    backgroundColor: document.getElementById("color-picker").value,
                    tooltip: {
                        text: '%v angajati',
                        backgroundColor: document.getElementById("color-picker").value
                    }
                }],
                plot: {
                    valueBox: {
                        text: '%v',
                        placement: 'top',
                        fontColor: '#FFF',
                        backgroundColor: document.getElementById("color-picker").value,
                        borderRadius: 3,
                        fontSize: fontSize
                    },
                    "animation": {
                        "effect": "ANIMATION_EXPAND_BOTTOM",
                        "method": "ANIMATION_STRONG_EASE_OUT",
                        "sequence": "ANIMATION_BY_PLOT_AND_NODE",
                        "speed": 275
                    }
                }
            },
            height: '100%',
            width: '100%'
        });
    }  
    
    // Color picker change event
    document.getElementById('color-picker').addEventListener('change', function(e) {
        if (!chartData) return;
        
        updateChart(chartData);
    }, false);
    
    // Re-render chart on window resize for responsiveness
    let resizeTimer;
    window.addEventListener('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            if (chartData) updateChart(chartData);
        }, 250);
    });
});

function generatePDF() {
    // Ensure libraries are loaded
    if (typeof html2canvas === 'undefined' || typeof html2pdf === 'undefined') {
        alert('Bibliotecile necesare pentru generarea PDF-ului nu sunt incarcate. Reimprospatati pagina.');
        return;
    }

    // Show loading state
    const downloadBtn = document.querySelector('.btn[onclick="generatePDF()"]');
    const originalText = downloadBtn.textContent;
    downloadBtn.textContent = 'Se genereaza PDF...';
    downloadBtn.disabled = true;

    // Get the content to convert
    const contentElement = document.getElementById('content');

    // Use html2pdf to generate PDF directly
    html2pdf().set({
        margin: [15, 15, 15, 15],
        filename: 'raport_departament.pdf',
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: {
            scale: 2,
            useCORS: true,
            logging: false,
            allowTaint: true
        },
        jsPDF: {
            unit: 'mm',
            format: 'a4',
            orientation: 'portrait'
        }
    }).from(contentElement).save().then(() => {
        console.log('PDF generat cu succes');
        downloadBtn.textContent = originalText;
        downloadBtn.disabled = false;
    }).catch((error) => {
        console.error('Eroare la generarea PDF:', error);
        alert('Nu s-a putut genera PDF-ul. Verificati consola browserului pentru detalii.');
        downloadBtn.textContent = originalText;
        downloadBtn.disabled = false;
    });
}
</script>
</body>
</html>
<%
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            out.println("<script type='text/javascript'>alert('Database error!');</script>");
            response.sendRedirect("login.jsp");
        }
    } else {
        out.println("<script type='text/javascript'>alert('User not logged in!');</script>");
        response.sendRedirect("login.jsp");
    }
} else {
    out.println("<script type='text/javascript'>alert('No active session!');</script>");
    response.sendRedirect("login.jsp");
}
%>