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
             PreparedStatement preparedStatement = connection.prepareStatement("SELECT id, tip FROM useri WHERE username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("id");
                int userType = rs.getInt("tip");
                if (userType == 4) {
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
    <title>Raport</title>
    <script src="https://cdn.zingchart.com/zingchart.min.js"></script>
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
            background: <%=clr%>;
            font-family: 'Arial', sans-serif;
        }
        
        .page-container {
            display: flex;
            flex-direction: row;
            height: 100vh;
            width: 100%;
        }
        
        .sidebar {
            width: 250px;
            padding: 20px;
            background-color: <%=sidebar%>;
            border-radius: 20px;
            color: <%=text%>;
            position: fixed;
            left: 0;
            top: 5rem;
            height: 100%;
            overflow-y: auto;
        }
        
        .main-content {
            margin-left: 290px;
            padding: 20px;
            width: calc(100% - 330px);
            top: 5rem;
        }
        
        .chart-container {
            background-color: <%=sidebar%>;
            border-radius: 20px;
            padding: 20px;
            margin-bottom: 20px;
            
        }
        
        #myChart {
            width: 100%;
            height: 400px;
        }
        
        .chart-info {
            background-color: <%=sidebar%>;
            border-radius: 20px;
            padding: 20px;
            margin-top: 20px;
            color: <%=text%>;
            
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        select, input {
            width: 100%;
            padding: 8px;
            border: 1px solid <%=accent%>;
            border-radius: 5px;
            background-color: <%=sidebar%>;
            color: <%=text%>;
        }
        
        .btn {
            display: block;
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            background-color: <%=accent%>;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-align: center;
            transition: background-color 0.3s;
        }
        
        .btn:hover {
            background-color: black;
            color: white;
            text-decoration: underline;
        }
        
        h3, h4 {
            color: <%=accent%>;
            margin-top: 0;
        }
        
        .zc-img, .zc-svg, .zc-rel .zc-top{
            background-color: transparent;
        }
        
        .header-title {
            text-align: center;
            color: <%=accent%>;
            margin-bottom: 20px;
            font-size: 1.5rem;
        }
        
        .note {
            font-size: 0.8rem;
            color: #777;
            font-style: italic;
        }
        
        @media print {
            .sidebar {
                display: none;
            }
            
            .main-content {
                margin-left: 0;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div style="padding-top:4rem;" class="page-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <h3>Optiuni Raport</h3>
            
            <form id="statusForm" method="post" onsubmit="return false;">
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" style="border-color:<%=accent%>; background:white; color:<%=text%>;">
                        <option value="3">Oricare</option>
                        <%
                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
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
                
                <div class="form-group">
                    <label>Departament</label>
                    <select name="dep" style="border-color:<%=accent%>; background:white; color:<%=text%>;">
                        <option value="-1">Oricare</option>
                        <%
                        try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                            try (ResultSet rs1 = stm.executeQuery()) {
                                while (rs1.next()) {
                                    int id = rs1.getInt("id_dep");
                                    String nume = rs1.getString("nume_dep");
                                    out.println("<option value='" + id + "'>" + nume + "</option>");
                                }
                            }
                        }
                        %>
                    </select>
                </div>
                
                <input type="hidden" name="tip" value="1">
            </form>
            
            <div class="form-group">
                <label>Culoare Grafic</label>
                <input type="color" id="color-picker" value="<%=accent%>" style="width: 100%; height: 30px;">
            </div>
            
            <button class="btn" onclick="generatePDF()">Descarcati PDF</button>
            
            
            <p id="ceva1" style="display:none;"><%=sidebar%></p>
            <p id="ceva2" style="display:none;"><%=accent%></p>
        </div>
        
        <!-- Main Content -->
        <div class="main-content">
            <div id="content">
                <h3 id="chartHeader" class="header-title"></h3>
                <p class="note">*Graficul afiseaza numarul de concedii in fiecare luna</p>
                
                <div class="chart-container">
                    <div id="myChart"></div>
                </div>
                
                <div class="chart-info">
                    <h4>Detalii raport</h4>
                    <p id="statusInfo"></p>
                    <p id="departmentInfo"></p>
                    <p id="dataInfo"></p>
                    <p id="totalInfo"></p>
                    <p id="explanationInfo" style="font-style: italic; margin-top: 15px;">
                        Acest raport afiseaza numarul de concedii suprapuse in fiecare luna. 
                        O valoare de 3, de exemplu, inseamna ca in acea luna sunt 3 angajati in concediu simultan.
                    </p>
                </div>
            </div>
        </div>
    </div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://html2canvas.hertzen.com/dist/html2canvas.min.js"></script>
<script>
var clear = document.getElementById("ceva1").innerText;
var accent = document.getElementById("ceva2").innerText;
var hbnm = "";
let colorPicker;
let chartData; // Variable to store the JSON data
const defaultColor = accent;

window.addEventListener("load", startup, false);

function startup() {
  colorPicker = document.querySelector("#color-picker");
  colorPicker.value = defaultColor;
 
  colorPicker.addEventListener("change", updateFirst, false);
  colorPicker.select();
}

function updateFirst(event) {
  hbrnm = event.target.value;
}

$(document).ready(function() {
    fetchChartData();

    $('#statusForm').on('change', 'select', function() {
        fetchChartData(); // Call this function on change
    });

    function fetchChartData() {
        $.ajax({
            url: 'JsonServlet', // Ensure this URL is correct
            type: 'POST',
            data: $('#statusForm').serialize(), // Serialize the form data
            dataType: 'json', // Expecting JSON response
            success: function(response) {
                chartData = response; 
                updateChart(response); // Update the chart with the response
                updateChartInfo(response);
            },
            error: function(xhr, status, error) {
                alert('Error: ' + xhr.statusText);
            }
        });
    }
    
    function updateChartInfo(data) {
        $('#statusInfo').text('Status: ' + (data.status === '3' ? 'Toate statusurile' : data.status));
        $('#departmentInfo').text('Departament: ' + data.departament);
        
        // Determine the date range if available
        if (data.months && data.months.length > 0) {
            $('#dataInfo').text('Luni analizate: ' + data.months[0] + ' - ' + data.months[data.months.length-1]);
        } else {
            $('#dataInfo').text('Luni analizate: Nu sunt date disponibile');
        }
        
        // Calculate total from counts and max overlap
        const total = data.counts.reduce((a, b) => a + b, 0);
        
        
        $('#totalInfo').html('Total concedii: ' + total );
    }

    function updateChart(data) {
        $('#chartHeader').text(data.h3);
        
        zingchart.render({
            id: 'myChart',
            data: {
                type: 'bar',
                backgroundColor: 'transparent', // Sets the background color of the chart area
                title: {
                    text: 'Suprapuneri concedii / luna'
                },
                scaleX: {
                    values: data.months.map(month => month.toString())
                },
                series: [{
                    values: data.counts,
                    backgroundColor: document.getElementById("color-picker").value
                }],
                plot: { // Additional styling for plot area
                    valueBox: {
                        text: '%v', // Displaying value on the bar
                        placement: 'top',
                        fontColor: '#FFF',
                        backgroundColor: document.getElementById("color-picker").value,
                        borderRadius: 3
                    },
                    "hover-mode": "node",
                    "hover-state": {
                      "background-color": "black"
                    },
                    "selection-mode": "plot",
                    "selected-state": {
                      "background-color": "black",
                      "border-width": 5,
                      "border-color": "white",
                      "line-style": "dashdot"
                    },
                    "animation": {
                        "effect": "ANIMATION_EXPAND_BOTTOM",
                        "method": "ANIMATION_STRONG_EASE_OUT",
                        "sequence": "ANIMATION_BY_PLOT_AND_NODE",
                        "speed": 275
                    }
                }
            },
            height: 400,
            width: '100%'
        });
    }  
    
    document.getElementById('color-picker').addEventListener('change', function(e) {
        if (!chartData) return;
        
        var myConfig2 = {
            type: 'bar',
            plot: {
                "animation": {
                    "effect": "ANIMATION_EXPAND_BOTTOM",
                    "method": "ANIMATION_STRONG_EASE_OUT",
                    "sequence": "ANIMATION_BY_PLOT_AND_NODE",
                    "speed": 275
                },
                valueBox: {
                    text: '%v',
                    placement: 'top',
                    fontColor: '#FFF',
                    backgroundColor: document.getElementById("color-picker").value,
                    borderRadius: 3
                }
            },
            title: {
                text: 'Suprapuneri concedii / luna'
            },
            scaleX: {
                values: chartData.months.map(month => month.toString())
            },
            series: [{
                values: chartData.counts,
                backgroundColor: document.getElementById("color-picker").value
            }]
        };

        zingchart.render({
            id: 'myChart',
            data: myConfig2,
            height: '100%',
            width: '100%'
        });
    }, false);
});

function generatePDF() {
	// Ensure libraries are loaded
    if (typeof html2canvas === 'undefined' || typeof html2pdf === 'undefined') {
        alert('PDF generation libraries not loaded. Please refresh the page.');
        return;
    }

    // Get the content to convert
    const contentElement = document.getElementById('content');

    // Use html2pdf to generate PDF directly
    html2pdf().set({
        margin: [10, 10, 10, 10],
        filename: 'raport_concedii.pdf',
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
        console.log('PDF generated successfully');
    }).catch((error) => {
        console.error('PDF Generation Error:', error);
        alert('Failed to generate PDF. Check browser console for details.');
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