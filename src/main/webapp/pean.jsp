<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%!
    // --- String Join Function converts from Java array to JavaScript string.
    public String join(ArrayList<?> arr, String del) {
        StringBuilder output = new StringBuilder();
        for (int i = 0; i < arr.size(); i++) {
            if (i > 0) output.append(del);
            // --- Quote strings, only, for JS syntax
            if (arr.get(i) instanceof String) output.append("\"");
            output.append(arr.get(i));
            if (arr.get(i) instanceof String) output.append("\"");
        }
        return output.toString();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Raport</title>
    <script type="text/javascript" src="https://cdn.zingchart.com/zingchart.min.js"></script>
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }
        .container {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            margin-bottom: 20px;
        }
        #myChart {
            width: 100%;
            height: 400px;
        }
        button {
            display: block;
            margin: 20px auto;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
    </style>
</head>
<body>
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

                // Allow only non-admin users to access this page
                if (userType == 4) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }

                String statusParam = request.getParameter("status");
                String depParam = request.getParameter("dep");

                int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
                int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
                int currentYear = Calendar.getInstance().get(Calendar.YEAR);

%>
                
<%
                Map<Integer, Integer> leaveCountMap = new HashMap<>();
                for (int i = 1; i <= 12; i++) {
                    leaveCountMap.put(i, 0);
                }

                String query = "SELECT MONTH(month_dates) AS month, CEIL(COUNT(*) / 2) AS numar_concedii FROM (SELECT start_c AS month_dates FROM concedii";
                if (status != 3 || dep != -1) {
                    query += " JOIN useri ON id_ang = useri.id JOIN departament ON useri.id_dep = departament.id_dep WHERE";
                    if (status != 3) query += " status = ? AND";
                    if (dep != -1) query += " departament.id_dep = ? AND";
                    query = query.substring(0, query.length() - 4); // Remove the last " AND"
                }
                query += " UNION ALL SELECT end_c FROM concedii";
                if (status != 3 || dep != -1) {
                    query += " JOIN useri ON id_ang = useri.id JOIN departament ON useri.id_dep = departament.id_dep WHERE";
                    if (status != 3) query += " status = ? AND";
                    if (dep != -1) query += " departament.id_dep = ? AND";
                    query = query.substring(0, query.length() - 4); // Remove the last " AND"
                }
                query += " UNION ALL SELECT DATE_ADD(start_c, INTERVAL 1 MONTH) FROM concedii WHERE MONTH(start_c) <> MONTH(end_c) AND YEAR(start_c) = ?) AS combined_dates GROUP BY MONTH(month_dates)";

                try (PreparedStatement stmt = connection.prepareStatement(query)) {
                    int paramIndex = 1;
                    if (status != 3) {
                        stmt.setInt(paramIndex++, status);
                        stmt.setInt(paramIndex++, status);
                    }
                    if (dep != -1) {
                        stmt.setInt(paramIndex++, dep);
                        stmt.setInt(paramIndex++, dep);
                    }
                    stmt.setInt(paramIndex, currentYear);

                    ResultSet rs1 = stmt.executeQuery();
                    while (rs1.next()) {
                        int month = rs1.getInt("month");
                        int count = rs1.getInt("numar_concedii");
                        leaveCountMap.put(month, count);
                    }

                    ArrayList<Integer> months = new ArrayList<>();
                    ArrayList<Integer> counts = new ArrayList<>();
                    for (int i = 1; i <= 12; i++) {
                        months.add(i);
                        counts.add(leaveCountMap.get(i));
                    }

                    // Add data to JavaScript arrays for the chart
                    out.println("<script>");
                    out.println("var monthsData = [" + join(months, ",") + "];");
                    out.println("var countsData = [" + join(counts, ",") + "];");
                    out.println("</script>");
                }
%>
                <div class="container" id="content">
                <h3 style="text-align: center;"> Vizualizare concedii
                <%
                // note to self -> ca sa apara tot graficul pe pagina, sa fie el vizibil mai intai pe pagina
                if (status == 0) {
                	out.println("neaprobate");
                } 
                if (status == 2) {
                	out.println("aprobate director");
                } 
                if (status == 1) {
                	out.println("aprobate sef");
                } 
                if (status == -1) {
                	out.println("respinse sef");
                }
                if (status == 0) {
                	out.println("respinse director");
                }
                if (status == 3) {
                	out.println("cu orice status");
                }
                if (dep == -1) {
                	out.println("pe toata institutia");
                } else {
                	  try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                          try (ResultSet rs1 = stm.executeQuery()) {
                              while (rs1.next()) {
                                  int id = rs1.getInt("id_dep");
                                  String nume = rs1.getString("nume_dep");
                                  if(dep == id)
                                  out.println("din departamentul " + nume);
                              }
                          }
                      }
                }
                %>
                </h3>
                    <div id="myChart"></div>
                </div>
                <button onclick="generatePDF()">Generate PDF</button>
<div class="login__check">
                    <form id="statusForm" onsubmit="return false;">
                        <div>
                            <label class="login__label">Status</label>
                            <select name="status" class="login__input" onchange="submitForm()">
                                <option value="3" <%= (status == 3 ? "selected" : "") %>>Oricare</option>
                                <%
                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                                    try (ResultSet rs1 = stm.executeQuery()) {
                                        while (rs1.next()) {
                                            int id = rs1.getInt("status");
                                            String nume = rs1.getString("nume_status");
                                            out.println("<option value='" + id + "' " + (status == id ? "selected" : "") + ">" + nume + "</option>");
                                        }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        <div>
                            <label class="login__label">Departament</label>
                            <select name="dep" class="login__input" onchange="submitForm()">
                                <option value="-1" <%= (dep == -1 ? "selected" : "") %>>Oricare</option>
                                <%
                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                                    try (ResultSet rs1 = stm.executeQuery()) {
                                        while (rs1.next()) {
                                            int id = rs1.getInt("id_dep");
                                            String nume = rs1.getString("nume_dep");
                                            out.println("<option value='" + id + "' " + (dep == id ? "selected" : "") + ">" + nume + "</option>");
                                        }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        <input type="submit" value="submit">
                    </form>
                </div>
                <script>
                    window.onload = function() {
                        zingchart.render({
                            id: "myChart",
                            width: "100%",
                            height: 400,
                            data: {
                                "type": "bar",
                                "title": {
                                    "text": "Numar angajati / luna"
                                },
                                "scale-x": {
                                    "labels": monthsData
                                },
                                "plot": {
                                    "line-width": 1
                                },
                                "series": [{
                                    "values": countsData
                                }]
                            }
                        });
                    };

                    function generate() {
                        const element = document.getElementById("content");
                        html2pdf()
                        .from(element)
                        .save();
                    }

                    function submitForm() {
                        const form = document.getElementById("statusForm");
                        const data = new FormData(form);
                        const params = new URLSearchParams(data).toString();
                        fetch("pean.jsp?" + params)
                            .then(response => response.text())
                            .then(html => {
                                document.open();
                                document.write(html);
                                document.close();
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
                                orientation: 'landscape' // Adjusts orientation to landscape if the content is wide
                            }
                        }).from(element).save();
                    }
                   
                </script>
<%
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
                out.println("Nu exista date.");
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
</body>
</html>