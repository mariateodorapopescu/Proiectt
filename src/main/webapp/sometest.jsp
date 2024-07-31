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
                
                String accent = null;
             	 String clr = null;
             	 String sidebar = null;
             	 String text = null;
             	 String card = null;
             	 String hover = null;
             	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    // Check for upcoming leaves in 3 days
                    String query = "SELECT * from teme where id_usr = ?";
                    try (PreparedStatement stmt = connection.prepareStatement(query)) {
                        stmt.setInt(1, userId);
                        try (ResultSet rs2 = stmt.executeQuery()) {
                            if (rs2.next()) {
                              accent =  rs2.getString("accent");
                              clr =  rs2.getString("clr");
                              sidebar =  rs2.getString("sidebar");
                              text = rs2.getString("text");
                              card =  rs2.getString("card");
                              hover = rs2.getString("hover");
                            }
                        }
                    }
                    // Display the user dashboard or related information
                    //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                    // Add additional user-specific content here
                } catch (SQLException e) {
                    out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                    e.printStackTrace();
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
            max-width: 700px;
            margin: 0 auto;
            padding: 0;
        }
        h1, h3 {
            text-align: center;
            top: 0;
            margin: 0;
            bottom: 0;
        }
        #myChart {
            width: 100%;
            height: 400px;
             font-size: 13px;
             
             padding: 0;
             margin: auto;
             top: -20%;
             position: relative;
            
        }
       
        .navigation, .login__check {
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0;
            padding: 0;
        }
        button {
        display: flex;
        	 justify-content: center;
            align-items: center;
            margin: auto;
            padding: 0;
        }
        
    </style>
     <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
</head>  
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(sidebar);%>">

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

                
                String statusParam = request.getParameter("status");
                String depParam = request.getParameter("dep");

                int status = (statusParam != null) ? Integer.parseInt(statusParam) : 3;
                int dep = (depParam != null) ? Integer.parseInt(depParam) : -1;
                
                out.print("<div style=\"color: " + accent + "; position: sticky; top: 95%; \" class='navigation'>");
                out.print("<form action='" + request.getContextPath() + "/sometest.jsp' method='post' style='display: inline;'>");
                out.print("<input type='hidden' name='selectedMonth' value='" + (currentMonth == 1 ? 12 : currentMonth - 1) + "'/>");
                out.print("<input type='hidden' name='selectedYear' value='" + (currentMonth == 1 ? currentYear - 1 : currentYear) + "'/>");
                out.print("<input type='hidden' name='status' value='" + status + "'/>");
                out.print("<input type='hidden' name='dep' value='" + dep + "'/>");
                out.print("<input type='submit' value='❮' />");
                out.print("</form>");
                out.print("<h3>" + getMonthName(currentMonth) + " " + currentYear + "</h3>");
                out.print("<form action='" + request.getContextPath() + "/sometest.jsp' method='post' style='display: inline;'>");
                out.print("<input type='hidden' name='selectedMonth' value='" + (currentMonth == 12 ? 1 : currentMonth + 1) + "'/>");
                out.print("<input type='hidden' name='selectedYear' value='" + (currentMonth == 12 ? currentYear + 1 : currentYear) + "'/>");
                out.print("<input type='hidden' name='status' value='" + status + "'/>");
                out.print("<input type='hidden' name='dep' value='" + dep + "'/>");
                out.print("<input type='submit' value='❯' />");
                out.print("</form>");
                out.print("</div>");
                
              

                int daysInMonth = getDaysInMonth(currentMonth, currentYear);
                Map<Integer, Integer> leaveCountMap = new HashMap<>();
                for (int i = 1; i <= daysInMonth; i++) {
                    leaveCountMap.put(i, 0);
                }

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
                <h3 style="padding: 0; margin: 0; top: -10%; color: <%=accent%>" text-align: center;"> Vizualizare concedii
                <%
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
                out.println(" pe luna " + getMonthName(currentMonth));
                %>
                </h3>
    <div id="myChart"></div>  
</div>
  
                <div style="position: fixed; left: 5%; bottom: 40%; margin: 0; padding: 0;" class="login__check">
                    <form id="statusForm" onsubmit="return false;">
                        <div>
                            <label style="color:<%out.println(text);%>"  class="login__label">Status</label>
                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="status" class="login__input" onchange="submitForm()">
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
                            <label style="color:<%out.println(text);%>" class="login__label">Departament</label>
                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="dep" class="login__input" onchange="submitForm()">
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
                        <input style="margin-top:1em;  box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" type="submit" value="Genereaza" class="login__button">
                    </form>
                   
                </div>
                 <button style="width: 10em; height: 4em; position: fixed; left: 80%; bottom: 50%; margin: 0; padding: 0; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    class="login__button" onclick="generate()">Descarcati PDF</button>
                

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
