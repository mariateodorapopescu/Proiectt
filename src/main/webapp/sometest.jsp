<%@ page import="java.io.*" %>  
<%@ page import="java.util.*" %>  
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%!  
    // --- String Join Function converts from Java array to javascript string.  
    public String join(ArrayList<?> arr, String del)  
    {  
        StringBuilder output = new StringBuilder();  
        for (int i = 0; i < arr.size(); i++)  
        {  
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
String lunaa = null;

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
                
                out.print("<form action='" + request.getContextPath() + "/sometest.jsp' method='post'>");
                out.println("<table>");
                out.println("<tr>");
                out.println("<td>Luna</td>");
                out.println("<td><select name='luna'>");
                out.println("<option value='1'>Ianuarie</option>");
                out.println("<option value='2'>Februarie</option>");
                out.println("<option value='3'>Martie</option>");
                out.println("<option value='4'>Aprilie</option>");
                out.println("<option value='5'>Mai</option>");
                out.println("<option value='6'>Iunie</option>");
                out.println("<option value='7'>Iulie</option>");
                out.println("<option value='8'>August</option>");
                out.println("<option value='9'>Septembrie</option>");
                out.println("<option value='10'>Octombrie</option>");
                out.println("<option value='11'>Noiembrie</option>");
                out.println("<option value='12'>Decembrie</option>");
                out.println("</select></td></tr>");
                out.println("<tr>");
                out.println("<input type='hidden' name='userId' value='" + userId + "'/>");
                out.println("</table>");
                out.println("<input type='submit' value='Submit' />");
                out.println("</form>");
                
                String luna = request.getParameter("luna");
                int month = -1;
                if (luna != null) {
                    month = Integer.parseInt(luna);
                }

                if (month != -1) {
                	
                	 if(month == 1) {
                     	lunaa = "Ianuarie";
                     }
                     if(month == 2) {
                     	lunaa = "Februarie";
                     }
                     if(month == 3) {
                     	lunaa = "Martie";
                     }
                     if(month == 4) {
                     	lunaa = "Aprilie";
                     }
                     if(month == 5) {
                     	lunaa = "Mai";
                     }
                     if(month == 6) {
                     	lunaa = "Iunie";
                     }
                     if(month == 7) {
                     	lunaa = "Iulie";
                     }
                     if(month == 8) {
                     	lunaa = "August";
                     }
                     if(month == 9) {
                     	lunaa = "Septembrie";
                     }
                     if(month == 10) {
                     	lunaa = "Octombrie";
                     }
                     if(month == 11) {
                     	lunaa = "Noiembrie";
                     }
                     if(month == 12) {
                     	lunaa = "Decembrie";
                     }
						out.println("<h1>" + lunaa + "</h1>");
                	
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT day(leave_date) AS leave_day, COUNT(*) AS plecati FROM (SELECT start_c + INTERVAL n DAY AS leave_date FROM concedii JOIN numbers ON n <= DATEDIFF(end_c, start_c)) AS all_dates WHERE MONTH(leave_date) = ? GROUP BY leave_date ORDER BY leave_date;")) {
                        stmt.setInt(1, month);
                        ResultSet rs1 = stmt.executeQuery();
                        ArrayList<String> days = new ArrayList<>();
                        ArrayList<Integer> counts = new ArrayList<>();
                        while (rs1.next()) {
                            int day = rs1.getInt("leave_day");
                            int count = rs1.getInt("plecati");
                            days.add(String.valueOf(day));
                            counts.add(count);
                        }
                        // Add data to JavaScript arrays for the chart
                        out.println("<script>");
                        out.println("var daysData = [" + join(days, ",") + "];");
                        out.println("var countsData = [" + join(counts, ",") + "];");
                        out.println("</script>");
                    }
                }
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

<script>  
    <%  
       // --- Create two Java Arrays  
        ArrayList<String> months = new ArrayList<String>();  
        ArrayList<Integer> users = new ArrayList<Integer>();  

       // --- Loop 10 times and create 10 string dates and 10 users  
        int counter = 1;  
        while(counter < 11)  
        {  
            months.add("Aug " + counter);  
            users.add(counter++);  
        }  
    %>  

    // --- add a comma after each value in the array and convert to javascript string representing an array  
    var monthData = [<%= join(months, ",") %>];  
    var userData = [<%= join(users, ",") %>];  
</script>  

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
</script>
</body>  
</html>
