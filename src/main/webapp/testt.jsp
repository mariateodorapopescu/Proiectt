<%@ page import="java.io.*" %>  
<%@ page import="java.util.*" %>  

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
    <title>Simple JSP Demo</title>  
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
        <h1>Data From JSP Page Using Docker</h1>  
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
                    "text": "Simple JSP Example"
                },
                "scale-x": {
                    "labels": monthData
                },
                "plot": {
                    "line-width": 1
                },
                "series": [{
                    "values": userData
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
