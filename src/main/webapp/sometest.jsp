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

    public int getDaysInMonth(int month, int year) {
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.MONTH, month - 1);
        calendar.set(Calendar.YEAR, year);
        return calendar.getActualMaximum(Calendar.DAY_OF_MONTH);
    }

    public String getMonthName(int month) {
        String[] monthNames = {"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"};
        return monthNames[month - 1];
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
        .navigation {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
    </style>
</head>  
<body>  
<%
String lunaa = null;
int currentMonth = Calendar.getInstance().get(Calendar.MONTH) + 1;
int currentYear = Calendar.getInstance().get(Calendar.YEAR);

String selectedMonthParam = request.getParameter("selectedMonth");
String selectedYearParam = request.getParameter("selectedYear");

if (selectedMonthParam != null && selectedYearParam != null) {
    currentMonth = Integer.parseInt(selectedMonthParam);
    currentYear = Integer.parseInt(selectedYearParam);
}

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
                out.print("<div class='navigation'>");
                out.print("<form action='" + request.getContextPath() + "/sometest.jsp' method='post' style='display: inline;'>");
                out.print("<input type='hidden' name='selectedMonth' value='" + (currentMonth == 1 ? 12 : currentMonth - 1) + "'/>");
                out.print("<input type='hidden' name='selectedYear' value='" + (currentMonth == 1 ? currentYear - 1 : currentYear) + "'/>");
                out.print("<input type='submit' value='❮ Anterior' />");
                out.print("</form>");
                out.print("<h1>" + getMonthName(currentMonth) + " " + currentYear + "</h1>");
                out.print("<form action='" + request.getContextPath() + "/sometest.jsp' method='post' style='display: inline;'>");
                out.print("<input type='hidden' name='selectedMonth' value='" + (currentMonth == 12 ? 1 : currentMonth + 1) + "'/>");
                out.print("<input type='hidden' name='selectedYear' value='" + (currentMonth == 12 ? currentYear + 1 : currentYear) + "'/>");
                out.print("<input type='submit' value='Următor ❯' />");
                out.print("</form>");
                out.print("</div>");
                
                String statusParam = request.getParameter("status");
                String depParam = request.getParameter("dep");

                int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
                int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
                
                %>
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
                <%

                int daysInMonth = getDaysInMonth(currentMonth, currentYear);
                Map<Integer, Integer> leaveCountMap = new HashMap<>();
                for (int i = 1; i <= daysInMonth; i++) {
                    leaveCountMap.put(i, 0);
                }
/*
                String statusParam = request.getParameter("status");
                String depParam = request.getParameter("dep");

                int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
                int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
*/
                if (dep == -1 && status == 3) {
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT day(leave_date) AS leave_day, COUNT(*) AS plecati FROM (SELECT start_c + INTERVAL n DAY AS leave_date FROM concedii JOIN numbers ON n <= DATEDIFF(end_c, start_c)) AS all_dates WHERE MONTH(leave_date) = ? AND YEAR(leave_date) = ? GROUP BY leave_date ORDER BY leave_date;")) {
                        stmt.setInt(1, currentMonth);
                        stmt.setInt(2, currentYear);
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int day = rs1.getInt("leave_day");
                            int count = rs1.getInt("plecati");
                            leaveCountMap.put(day, count);
                        }

                        ArrayList<String> days = new ArrayList<>();
                        ArrayList<Integer> counts = new ArrayList<>();
                        for (int i = 1; i <= daysInMonth; i++) {
                            days.add(String.valueOf(i));
                            counts.add(leaveCountMap.get(i));
                        }

                        // Add data to JavaScript arrays for the chart
                        out.println("<script>");
                        out.println("var daysData = [" + join(days, ",") + "];");
                        out.println("var countsData = [" + join(counts, ",") + "];");
                        out.println("</script>");
                    }
                } else if (status != 3 && dep == -1) {
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT day(leave_date) AS leave_day, COUNT(*) AS plecati FROM (SELECT start_c + INTERVAL n DAY AS leave_date FROM concedii JOIN numbers ON n <= DATEDIFF(end_c, start_c) WHERE status = ?) AS all_dates WHERE MONTH(leave_date) = ? AND YEAR(leave_date) = ? GROUP BY leave_date ORDER BY leave_date;")) {
                        stmt.setInt(1, status);
                        stmt.setInt(2, currentMonth);
                        stmt.setInt(3, currentYear);
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int day = rs1.getInt("leave_day");
                            int count = rs1.getInt("plecati");
                            leaveCountMap.put(day, count);
                        }

                        ArrayList<String> days = new ArrayList<>();
                        ArrayList<Integer> counts = new ArrayList<>();
                        for (int i = 1; i <= daysInMonth; i++) {
                            days.add(String.valueOf(i));
                            counts.add(leaveCountMap.get(i));
                        }

                        // Add data to JavaScript arrays for the chart
                        out.println("<script>");
                        out.println("var daysData = [" + join(days, ",") + "];");
                        out.println("var countsData = [" + join(counts, ",") + "];");
                        out.println("</script>");
                    }
                } else if (dep != -1 && status == 3) {
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT day(leave_date) AS leave_day, COUNT(*) AS plecati FROM (SELECT start_c + INTERVAL n DAY AS leave_date FROM concedii JOIN numbers ON n <= DATEDIFF(end_c, start_c) JOIN useri ON concedii.id_ang = useri.id JOIN departament ON useri.id_dep = departament.id_dep WHERE departament.id_dep = ?) AS all_dates WHERE MONTH(leave_date) = ? AND YEAR(leave_date) = ? GROUP BY leave_date ORDER BY leave_date;")) {
                        stmt.setInt(1, dep);
                        stmt.setInt(2, currentMonth);
                        stmt.setInt(3, currentYear);
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int day = rs1.getInt("leave_day");
                            int count = rs1.getInt("plecati");
                            leaveCountMap.put(day, count);
                        }

                        ArrayList<String> days = new ArrayList<>();
                        ArrayList<Integer> counts = new ArrayList<>();
                        for (int i = 1; i <= daysInMonth; i++) {
                            days.add(String.valueOf(i));
                            counts.add(leaveCountMap.get(i));
                        }

                        // Add data to JavaScript arrays for the chart
                        out.println("<script>");
                        out.println("var daysData = [" + join(days, ",") + "];");
                        out.println("var countsData = [" + join(counts, ",") + "];");
                        out.println("</script>");
                    }
                } else {
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT day(leave_date) AS leave_day, COUNT(*) AS plecati FROM (SELECT start_c + INTERVAL n DAY AS leave_date FROM concedii JOIN numbers ON n <= DATEDIFF(end_c, start_c) JOIN useri ON concedii.id_ang = useri.id JOIN departament ON useri.id_dep = departament.id_dep WHERE departament.id_dep = ? AND concedii.status = ?) AS all_dates WHERE MONTH(leave_date) = ? AND YEAR(leave_date) = ? GROUP BY leave_date ORDER BY leave_date;")) {
                        stmt.setInt(1, dep);
                        stmt.setInt(2, status);
                        stmt.setInt(3, currentMonth);
                        stmt.setInt(4, currentYear);
                        ResultSet rs1 = stmt.executeQuery();
                        while (rs1.next()) {
                            int day = rs1.getInt("leave_day");
                            int count = rs1.getInt("plecati");
                            leaveCountMap.put(day, count);
                        }

                        ArrayList<String> days = new ArrayList<>();
                        ArrayList<Integer> counts = new ArrayList<>();
                        for (int i = 1; i <= daysInMonth; i++) {
                            days.add(String.valueOf(i));
                            counts.add(leaveCountMap.get(i));
                        }

                        // Add data to JavaScript arrays for the chart
                        out.println("<script>");
                        out.println("var daysData = [" + join(days, ",") + "];");
                        out.println("var countsData = [" + join(counts, ",") + "];");
                        out.println("</script>");
                    }
                }
                
                %>
<div class="container" id="content">
    <div id="myChart"></div>  
</div>
<button onclick="generate()">Generate PDF</button>

<script>
window.onload = function() {
    zingchart.render({
        id: "myChart",
        width: "100%",
        height: 400,
        data: {
            "type": "bar",
            "title": {
                "text": "Numar angajati / zi"
            },
            "scale-x": {
                "labels": daysData
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
    fetch("sometest.jsp?" + params)
        .then(response => response.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
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