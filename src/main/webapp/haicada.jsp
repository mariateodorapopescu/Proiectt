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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            background: <%=sidebar%>;
        }
        .container {
            width: 100%;
            max-width: 500px;
            margin: 0 auto;
            padding: 0;
        }
        h1, h3 {
            text-align: center;
        }
        #myChart {
            width: 100%;
            height: 900px;
        }
    </style>
</head>
<body>
<div class="container" id="content">
    <h3 id="chartHeader" style="color: <%=text%>;"></h3>
    <div id="myChart"></div>
</div>
<div class="container" id="content">
                <h3 style="padding: 0; margin: 0; top: -10%; color: <%=accent%>" text-align: center;"> 
                </h3>
                    <div id="myChart"></div>
                </div>
                <div style="position: fixed; left: 15%; bottom: 40%; margin: 0; padding: 0;" class="login__check">
                    <form id="statusForm" method="post" onsubmit="return false;">
                        <div>
                            <label style="color:<%out.println(text);%>" class="login__label">Status</label>
                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="status" class="login__input" >
                                <option value="3" >Oricare</option>
                                <%
                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                                    try (ResultSet rs1 = stm.executeQuery()) {
                                        while (rs1.next()) {
                                            int id = rs1.getInt("status");
                                            String nume = rs1.getString("nume_status");
                                            // out.println("<option value='" + id + "' " + (status == id ? "selected" : "") + ">" + nume + "</option>");
                                            out.println("<option value='" + id + "'>" + nume + "</option>");
                                        }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        <div>
                            <label style="color:<%out.println(text);%>" class="login__label">Departament</label>
                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="dep" class="login__input">
                                <option value="-1">Oricare</option>
                                <%
                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                                    try (ResultSet rs1 = stm.executeQuery()) {
                                        while (rs1.next()) {
                                            int id = rs1.getInt("id_dep");
                                            String nume = rs1.getString("nume_dep");
                                            // out.println("<option value='" + id + "' " + (dep == id ? "selected" : "") + ">" + nume + "</option>");
                                            out.println("<option value='" + id + "'" + ">" + nume + "</option>");
                                        }
                                    }
                                }
                                %>
                            </select>
                        </div>
                         
                 </form>
                 <button style="width: 10em; height: 4em; position: fixed; left: 80%; bottom: 50%; margin: 0; padding: 0; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" onclick="generatePDF()">Descarcati PDF</button>
               
                </div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script>

            
$(document).ready(function() {
    fetchChartData();
    function autoSubmit() {
        document.getElementById('statusForm').submit();
    }
    // face autosubmit
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
                updateChart(response); // Update the chart with the response
            },
            error: function(xhr, status, error) {
                alert('Error: ' + xhr.statusText);
            }
        });
    }

    function updateChart(data) {
        $('#chartHeader').text(data.h3); // Set the header text
        zingchart.render({
            id: 'myChart',
            data: {
                type: 'bar',
                title: {
                    text: 'Numar angajati / luna'
                },
                scaleX: {
                    values: data.months.map(month => month.toString())
                },
                series: [{
                    values: data.counts
                }]
            },
            height: 400,
            width: '100%'
        });
    } 

    function generatePDF() {
                    const element = document.getElementById('content'); // Make sure this ID matches the container of your chart
                    html2pdf().set({
                        pagebreak: { mode: ['css', 'avoid-all'] },
                        html2canvas: {
                            scale: 2, // Increase scale to enhance quality
                            logging: true,
                            dpi: 192,
                            letterRendering: true,
                            useCORS: true // Ensures external content is handled properly
                        },
                        jsPDF: {
                            unit: 'pt',
                            format: 'a4',
                            orientation: 'portrait' // Adjusts orientation to landscape if the content is wide
                        }
                    }).from(element).save();
                }
    
});
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
