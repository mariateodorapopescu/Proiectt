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
            response.sendRedirect("login.jsp");
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
            response.sendRedirect("login.jsp");
        }
        return;
    }

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
        
        if (!rs.next()) {
            if ("true".equals(request.getParameter("json"))) {
                response.setContentType("application/json");
                response.getWriter().write("{\"error\":\"Date introduse incorect sau nu exista date!\"}");
            } else {
                out.println("<script type='text/javascript'>");
                out.println("alert('Date introduse incorect sau nu exista date!');");
                out.println("</script>");
            }
            return;
        }
        
        int userType = rs.getInt("tip");
        int id = rs.getInt("id");
        String functie = rs.getString("functie");
        int ierarhie = rs.getInt("ierarhie");

        // Funcție helper pentru a determina rolul utilizatorului
        boolean isDirector = (ierarhie < 3) ;
        boolean isSef = (ierarhie >= 4 && ierarhie <=5);
        boolean isIncepator = (ierarhie >= 10);
        boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
        boolean isAdmin = (functie.compareTo("Administrator") == 0);
        
        // Redirect based on user type (only for non-JSON requests)
        if (!isDirector && !"true".equals(request.getParameter("json"))) {
            response.sendRedirect(isUtilizatorNormal ? "tip1ok.jsp" : isIncepator ? "tip2ok.jsp" : isSef ? "sefok.jsp" : "adminok.jsp");
            return;
        }

        int idDep = 0;
        if (request.getParameter("iddep") != null) {
            idDep = Integer.valueOf(request.getParameter("iddep"));
        }

        // Handle JSON request
        // Handle JSON request
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            List<Map<String, String>> employees = new ArrayList<>();
            
            // Get department name
            String deptName = "";
            if (idDep != 0) {
                PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                stm.setInt(1, idDep);
                ResultSet rs2 = stm.executeQuery();
                if (rs2.next()) {
                    deptName = rs2.getString("nume_dep");
                }
                rs2.close();
                stm.close();
            }

            // Get employees
            String sql = "SELECT nume, prenume, username, denumire, nume_dep FROM useri " +
                        "LEFT JOIN tipuri ON tipuri.tip = useri.tip " +
                        "LEFT JOIN departament ON departament.id_dep = useri.id_dep";
            if (idDep != 0) {
                sql += " WHERE useri.id_dep = ? AND username <> 'test'";
            }
            
            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                if (idDep != 0) {
                    stmt.setInt(1, idDep);
                }
                
                ResultSet rs1 = stmt.executeQuery();
                int nr = 1;
                
                while (rs1.next()) {
                    Map<String, String> employee = new LinkedHashMap<>();
                    employee.put("NrCrt", String.valueOf(nr++));
                    employee.put("Nume", rs1.getString("nume"));
                    employee.put("Prenume", rs1.getString("prenume"));
                    employee.put("Functie", rs1.getString("denumire"));
                    employee.put("Departament", rs1.getString("nume_dep"));
                    employees.add(employee);
                }
            }

            Map<String, Object> responseJson = new HashMap<>();
            if (idDep != 0) {
                responseJson.put("header", "Vizualizare angajati din departamentul " + deptName);
            } else {
                responseJson.put("header", "Vizualizare angajati din oricare departament");
            }
            responseJson.put("data", employees);

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
    <title>Vizualizare angajati</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js" integrity="sha512-GsLlZN/3F2ErC5ifS5QtgpiJtWd43JWSuIgh7mbzZ8zBps+dvLusV+eNQATqgA/HdeKFVgA5v3S/cIrLF7QnIg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

    <div class="main-content">
        <div class="header"></div>
        <div style="border-radius:2rem;" class="content">
            <div class="intro" style="position: fixed; top: 2rem; left: 15%; border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                <%
                PreparedStatement stm = connection.prepareStatement("SELECT nume_dep from departament WHERE id_dep = ?");
                stm.setInt(1, idDep);
                ResultSet rs2 = stm.executeQuery();
                String deptName = "";
                if (rs2.next()) {
                    deptName = rs2.getString("nume_dep");
                }
                %>
                
                <div class="events" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>" id="content">
                    <% if (idDep != 0) { 
                        out.println("<h1>Vizualizare angajati din departamentul " + deptName + "</h1>"); 
                        out.println("<h3>" + today + "</h3>"); 
                    } else {
                        out.println("<h1>Vizualizare angajati din oricare departament</h1>"); 
                        out.println("<h3>" + today + "</h3>"); 
                    }
                    %>
                    <table>
                        <thead>
                            <tr style="color:<%out.println("white");%>">
                                <th>Nr. crt.</th>    
                                <th>Nume</th>
                                <th>Prenume</th>
                                <th>Functie</th>
                                <th>Departament</th>
                            </tr>
                        </thead>
                        <tbody style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                            <%
                            String sql = "SELECT nume, prenume, username, denumire, nume_dep FROM useri left JOIN tipuri on tipuri.tip = useri.tip left JOIN departament on departament.id_dep = useri.id_dep";
                            if (idDep != 0) {
                                sql = "SELECT nume, prenume, username, denumire, nume_dep FROM useri left JOIN tipuri on tipuri.tip = useri.tip left JOIN departament on departament.id_dep = useri.id_dep WHERE useri.id_dep = ? and username <> \"test\""; 
                            }
                            PreparedStatement stmt = connection.prepareStatement(sql);
                            if (idDep != 0) {
                                stmt.setInt(1, idDep);
                            }
                            ResultSet rs1 = stmt.executeQuery();
                            boolean found = false;
                            int nr = 1;
                            while (rs1.next()) {
                                found = true;
                                out.println("<tr><td>" + nr++ + "</td><td> " + rs1.getString("nume") + "</td><td>" + rs1.getString("prenume") + "</td><td>" + rs1.getString("denumire") + "</td><td>" + rs1.getString("nume_dep") + "</td></tr>");
                            }
                            if (!found) {
                                out.println("<tr><td colspan='5'>Nu exista date.</td></tr>");
                            }
                            rs1.close();
                            stmt.close();
                            stm.close();
                            %>
                        </tbody>
                    </table>
                </div>
                
                <div class="into">
                    <button id="generate" onclick="sendJsonToPDFServer()">Descarcati PDF</button>
                   
                    <button><a href='viewangdep.jsp'>Inapoi</a></button>
                </div>
                
                <script>
                
                async function sendJsonToPDFServer() {
                    console.log("🚀 Fetching JSON data from this page...");
                    
                    try {
                        // Pentru pagina viewangdep2.jsp, parametrul iddep vine prin POST din formularul anterior
                        // Însă când pagina este deja încărcată, putem accesa valoarea din URL-ul curent
                        
                        // Verificăm mai întâi dacă avem parametrul în URL
                        let idDepParam;
                        
                        // Încercăm să obținem parametrul din URL
                        const currentUrl = new URL(window.location.href);
                        idDepParam = currentUrl.searchParams.get("iddep");
                        
                        // Dacă nu există în URL, îl căutăm în codul PHP
                        if (!idDepParam) {
                            // Folosim valoarea setată în JSP (din formularul POST)
                            idDepParam = "<%= idDep %>";
                        }
                        
                        // Construct the URL for fetching JSON
                        let jsonUrl = "viewangdep2.jsp?json=true";
                        if (idDepParam && idDepParam !== "0") {
                            jsonUrl += "&iddep=" + idDepParam;
                        }
                        
                        console.log("Fetching JSON from: " + jsonUrl);
                        
                        let response = await fetch(jsonUrl);
                        
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
                        let fileName = "Raport_Angajati.pdf";

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
            </div>
        </div>
    </div>
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
            response.sendRedirect("login.jsp");
        }
    }
%>