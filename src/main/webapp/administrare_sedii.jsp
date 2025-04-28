<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.NumberFormat" %>

<%
    HttpSession sesi = request.getSession(false);
    int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id, id_dep FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    if (userType != 0 && userType != 3 && (userType != 2 || userDep != 1)) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("ro", "RO"));
                        
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * from teme where id_usr = ?";
                            try (PreparedStatement stmt = con.prepareStatement(query)) {
                                stmt.setInt(1, userId);
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

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Generare Fluturas Salariu</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- REMIXICONS -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">

    <!-- BOOTSTRAP & CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <link rel="stylesheet" href="responsive-login-form-main/assets/css/core2.css">
   
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        a, a:visited, a:hover, a:active {
            color: <%=text%> !important; 
            text-decoration: none;
        }
        
        .card {
            background-color: <%=sidebar%>;
            border-radius: 15px;
            padding: 30px;
            margin: 20px auto;
            max-width: 90%;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: <%=accent%>;
            transform: translateY(-5px);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-control {
            border-radius: 8px;
            padding: 10px 15px;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: <%=accent%>;
        }
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23333' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 16px;
            padding-right: 40px;
        }
        
        .btn-primary {
            background-color: <%=accent%>;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .btn-primary:hover {
            background-color: <%=text%>;
            transform: translateY(-2px);
        }
        
        .btn-outline-secondary {
            border: 1px solid <%=text%>;
            background-color: transparent;
            color: <%=text%>;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-outline-secondary:hover {
            background-color: <%=text%>;
            color: <%=sidebar%>;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
            color: <%=accent%>;
            position: relative;
        }
        
        .page-header h2 {
            font-weight: 700;
            margin-bottom: 1rem;
            font-size: 2.5rem;
        }
        
        .page-header:after {
            content: '';
            display: block;
            width: 80px;
            height: 4px;
            background-color: <%=sidebar%>;
            margin: 0.5rem auto 0;
            border-radius: 2px;
        }
        
        .form-label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: <%=text%>;
        }
        
        /* Input placeholder color */
        ::placeholder {
            color: <%=text%>;
        }
        
        body {
            background-color: <%=clr%>;
            color: <%=text%>;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
        }
        
        .text-muted {
            color: <%=text%> !important;
            opacity: 0.8;
        }
        
        /* Fluturas styles */
        .fluturas {
            background: white;
            padding: 20px;
            margin: 20px 0;
            border: 1px solid #ddd;
            border-radius: 8px;
            color: #333;
        }
        
        .fluturas-header {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }
        
        .fluturas-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .fluturas-table th, .fluturas-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        
        .fluturas-table th {
            background-color: #f4f4f4;
        }
        
        .total-row {
            font-weight: bold;
            background-color: #f9f9f9;
        }
        
        /* Button to generate PDF */
        .pdf-button {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        .sedii-container {
            max-width: 1200px;
            margin: 20px auto;
        }
        .sedii-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .sedii-table th, .sedii-table td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        .sedii-table th {
            background-color: #f4f4f4;
            font-weight: bold;
        }
        .sedii-table tr:hover {
            background-color: #f9f9f9;
        }
        .btn-group {
            display: flex;
            gap: 10px;
        }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.4);
            overflow: auto;
        }
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 600px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .sediu-tip {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.9em;
        }
        .tip-principal { background-color: #28a745; color: white; }
        .tip-secundar { background-color: #17a2b8; color: white; }
        .tip-punct-lucru { background-color: #ffc107; color: black; }
        .search-container {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }
        .search-container input {
            flex: 1;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .map-container {
            height: 400px;
            width: 100%;
            margin-top: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
   </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>">

    
            <h2>Administrare Sedii</h2>
            
            <div class="search-container">
                <input type="text" id="searchInput" placeholder="Caută sediu..." onkeyup="filterSedii()">
                <button class="btn" onclick="openModal('addSediuModal')">Adaugă Sediu Nou</button>
            </div>
            
            <table class="sedii-table" id="sediiTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nume Sediu</th>
                        <th>Tip</th>
                        <th>Adresă</th>
                        <th>Oraș</th>
                        <th>Județ</th>
                        <th>Telefon</th>
                        <th>Email</th>
                        <th>Nr. Angajați</th>
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection conn = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        // Query pentru a obține toate sediile și numărul de angajați
                        String sql = "SELECT s.*, COUNT(u.id) as nr_angajati " +
                                    "FROM sedii s " +
                                    "LEFT JOIN locatii_useri lu ON s.id_sediu = lu.id_sediu " +
                                    "LEFT JOIN useri u ON lu.id_user = u.id AND u.activ = 1 " +
                                    "GROUP BY s.id_sediu " +
                                    "ORDER BY s.nume_sediu";
                        Statement stmt = conn.createStatement();
                        ResultSet rs2 = stmt.executeQuery(sql);
                        
                        while (rs2.next()) {
                            String tipClass = "";
                            String tipText = "";
                            switch (rs2.getString("tip_sediu")) {
                                case "principal":
                                    tipClass = "tip-principal";
                                    tipText = "Principal";
                                    break;
                                case "secundar":
                                    tipClass = "tip-secundar";
                                    tipText = "Secundar";
                                    break;
                                case "punct_lucru":
                                    tipClass = "tip-punct-lucru";
                                    tipText = "Punct de lucru";
                                    break;
                            }
                    %>
                        <tr>
                            <td><%= rs2.getInt("id_sediu") %></td>
                            <td><%= rs2.getString("nume_sediu") %></td>
                            <td><span class="sediu-tip <%= tipClass %>"><%= tipText %></span></td>
                            <td><%= rs2.getString("strada") %></td>
                            <td><%= rs2.getString("oras") %></td>
                            <td><%= rs2.getString("judet") %></td>
                            <td><%= rs2.getString("telefon") != null ? rs2.getString("telefon") : "-" %></td>
                            <td><%= rs2.getString("email") != null ? rs2.getString("email") : "-" %></td>
                            <td><%= rs2.getInt("nr_angajati") %></td>
                            <td>
                                <div class="btn-group">
                                    <button class="btn btn-small" 
                                            onclick="editSediu(<%= rs2.getInt("id_sediu") %>)">
                                        Editează
                                    </button>
                                    <button class="btn btn-small" 
                                            onclick="showMap(<%= rs2.getDouble("latitudine") %>, <%= rs2.getDouble("longitudine") %>)">
                                        Hartă
                                    </button>
                                    <% if (rs2.getInt("nr_angajati") == 0 && !rs2.getString("tip_sediu").equals("principal")) { %>
                                        <button class="btn btn-small btn-danger" 
                                                onclick="deleteSediu(<%= rs2.getInt("id_sediu") %>)">
                                            Șterge
                                        </button>
                                    <% } else { %>
                                        <button class="btn btn-small btn-danger" disabled 
                                                title="Nu se poate șterge un sediu cu angajați sau sediul principal">
                                            Șterge
                                        </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                        rs2.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </tbody>
            </table>
            
            <!-- Container pentru hartă -->
            <div id="mapContainer" class="map-container" style="display: none;">
                <iframe id="mapFrame" width="100%" height="100%" frameborder="0" style="border:0" allowfullscreen></iframe>
            </div>
       
    <!-- Modal Adăugare Sediu -->
    <div id="addSediuModal" class="modal">
        <div class="modal-content">
            <h3>Adaugă Sediu Nou</h3>
            <form id="addSediuForm" method="POST" action="AdaugaSediuServlet">
                <div class="form-group">
                    <label for="nume_sediu">Nume Sediu:</label>
                    <input type="text" id="nume_sediu" name="nume_sediu" required>
                </div>
                
                <div class="form-group">
                    <label for="tip_sediu">Tip Sediu:</label>
                    <select id="tip_sediu" name="tip_sediu" required>
                        <option value="">-- Selectați --</option>
                        <option value="secundar">Secundar</option>
                        <option value="punct_lucru">Punct de lucru</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="strada">Stradă:</label>
                    <input type="text" id="strada" name="strada" required>
                </div>
                
                <div class="form-group">
                    <label for="cod">Cod Poștal:</label>
                    <input type="text" id="cod" name="cod" required>
                </div>
                
                <div class="form-group">
                    <label for="oras">Oraș:</label>
                    <input type="text" id="oras" name="oras" required>
                </div>
                
                <div class="form-group">
                    <label for="judet">Județ:</label>
                    <input type="text" id="judet" name="judet" required>
                </div>
                
                <div class="form-group">
                    <label for="tara">Țară:</label>
                    <input type="text" id="tara" name="tara" value="România" required>
                </div>
                
                <div class="form-group">
                    <label for="telefon">Telefon:</label>
                    <input type="tel" id="telefon" name="telefon">
                </div>
                
                <div class="form-group">
                    <label for="email">Email:</label>
                    <input type="email" id="email" name="email">
                </div>
                
                <div class="form-group">
                    <label for="latitudine">Latitudine:</label>
                    <input type="number" step="any" id="latitudine" name="latitudine">
                </div>
                
                <div class="form-group">
                    <label for="longitudine">Longitudine:</label>
                    <input type="number" step="any" id="longitudine" name="longitudine">
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn">Salvează</button>
                    <button type="button" class="btn" onclick="closeModal('addSediuModal')">Anulează</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Editare Sediu -->
    <div id="editSediuModal" class="modal">
        <div class="modal-content">
            <h3>Editare Sediu</h3>
            <form id="editSediuForm" method="POST" action="EditSediuServlet">
                <input type="hidden" id="edit_id_sediu" name="id_sediu">
                
                <div class="form-group">
                    <label for="edit_nume_sediu">Nume Sediu:</label>
                    <input type="text" id="edit_nume_sediu" name="nume_sediu" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_tip_sediu">Tip Sediu:</label>
                    <select id="edit_tip_sediu" name="tip_sediu" required>
                        <option value="secundar">Secundar</option>
                        <option value="punct_lucru">Punct de lucru</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="edit_strada">Stradă:</label>
                    <input type="text" id="edit_strada" name="strada" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_cod">Cod Poștal:</label>
                    <input type="text" id="edit_cod" name="cod" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_oras">Oraș:</label>
                    <input type="text" id="edit_oras" name="oras" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_judet">Județ:</label>
                    <input type="text" id="edit_judet" name="judet" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_tara">Țară:</label>
                    <input type="text" id="edit_tara" name="tara" required>
                </div>
                
                <div class="form-group">
                    <label for="edit_telefon">Telefon:</label>
                    <input type="tel" id="edit_telefon" name="telefon">
                </div>
                
                <div class="form-group">
                    <label for="edit_email">Email:</label>
                    <input type="email" id="edit_email" name="email">
                </div>
                
                <div class="form-group">
                    <label for="edit_latitudine">Latitudine:</label>
                    <input type="number" step="any" id="edit_latitudine" name="latitudine">
                </div>
                
                <div class="form-group">
                    <label for="edit_longitudine">Longitudine:</label>
                    <input type="number" step="any" id="edit_longitudine" name="longitudine">
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn">Salvează Modificările</button>
                    <button type="button" class="btn" onclick="closeModal('editSediuModal')">Anulează</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Funcție pentru filtrarea sediilor
        function filterSedii() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('sediiTable');
            const tr = table.getElementsByTagName('tr');
            
            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td');
                let textValue = '';
                
                for (let j = 0; j < td.length - 1; j++) {
                    if (td[j]) {
                        textValue += td[j].textContent || td[j].innerText;
                    }
                }
                
                if (textValue.toLowerCase().indexOf(filter) > -1) {
                    tr[i].style.display = '';
                } else {
                    tr[i].style.display = 'none';
                }
            }
        }
        
        // Funcții pentru modal
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        // Funcție pentru editare sediu
        function editSediu(idSediu) {
            $.ajax({
                url: 'GetSediuServlet',
                type: 'GET',
                data: { id: idSediu },
                success: function(sediu) {
                    document.getElementById('edit_id_sediu').value = sediu.id_sediu;
                    document.getElementById('edit_nume_sediu').value = sediu.nume_sediu;
                    document.getElementById('edit_tip_sediu').value = sediu.tip_sediu;
                    document.getElementById('edit_strada').value = sediu.strada;
                    document.getElementById('edit_cod').value = sediu.cod;
                    document.getElementById('edit_oras').value = sediu.oras;
                    document.getElementById('edit_judet').value = sediu.judet;
                    document.getElementById('edit_tara').value = sediu.tara;
                    document.getElementById('edit_telefon').value = sediu.telefon || '';
                    document.getElementById('edit_email').value = sediu.email || '';
                    document.getElementById('edit_latitudine').value = sediu.latitudine || '';
                    document.getElementById('edit_longitudine').value = sediu.longitudine || '';
                    
                    openModal('editSediuModal');
                },
                error: function() {
                    alert('Eroare la încărcarea datelor sediului!');
                }
            });
        }
        
        // Funcție pentru ștergere sediu
        function deleteSediu(idSediu) {
            if (confirm('Sigur doriți să ștergeți acest sediu? Această acțiune este ireversibilă!')) {
                $.ajax({
                    url: 'DeleteSediuServlet',
                    type: 'POST',
                    data: { id_sediu: idSediu },
                    success: function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message || 'Eroare la ștergerea sediului!');
                        }
                    },
                    error: function() {
                        alert('Eroare la conectarea cu serverul!');
                    }
                });
            }
        }
        
        // Funcție pentru afișare hartă
        function showMap(lat, lng) {
            const mapContainer = document.getElementById('mapContainer');
            const mapFrame = document.getElementById('mapFrame');
            
            if (lat && lng) {
                mapFrame.src = `https://www.google.com/maps/embed/v1/place?key=YOUR_API_KEY&q=${lat},${lng}&zoom=15`;
                mapContainer.style.display = 'block';
                mapContainer.scrollIntoView({ behavior: 'smooth' });
            } else {
                alert('Nu există coordonate pentru acest sediu!');
            }
        }
        
        // Închide modalele când se dă click în afara lor
        window.onclick = function(event) {
            if (event.target.className === 'modal') {
                event.target.style.display = 'none';
            }
        }
        
        // Formular pentru obținere coordonate din adresă
        document.getElementById('addSediuForm').addEventListener('submit', function(e) {
            // Poți adăuga aici logică pentru geocoding înainte de submit
        });
    </script>
    <script src="js/core2.js"></script>
<%
                    }
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