<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.time.LocalDate, java.time.LocalTime" %>
<%

// Verificare sesiune și obținere user curent
HttpSession sesi = request.getSession(false);

if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
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
                    // extrag date despre userul curent
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    boolean isHR = (userDep == 1); // Department HR

                    // Verifică dacă a bifat prezența pentru ziua curentă
                    boolean isPrezentaAstazi = false;
                    try (PreparedStatement pstmt = connection.prepareStatement("SELECT * FROM prezenta WHERE id_ang = ? AND data = CURDATE()")) {
                        pstmt.setInt(1, userId);
                        ResultSet rsPresence = pstmt.executeQuery();
                        if (rsPresence.next()) {
                            isPrezentaAstazi = true;
                        }
                        rsPresence.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Prezență și Punctualitate</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        .prezenta-container {
            max-width: 600px;
            margin: 20px auto;
            text-align: center;
        }
        .prezenta-button {
            padding: 20px 40px;
            font-size: 1.2em;
            margin: 20px;
            border-radius: 8px;
            border: none;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-check-in {
            background-color: #28a745;
        }
        .btn-check-in:hover {
            background-color: #218838;
        }
        .btn-check-in:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        .prezenta-info {
            margin: 30px 0;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .comment-section {
            margin-top: 20px;
        }
        .comment-box {
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .raport-prezenta {
            margin-top: 40px;
        }
        .prezenta-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .prezenta-table th, .prezenta-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .prezenta-table th {
            background-color: #f4f4f4;
        }
        .status-prezent { color: #28a745; }
        .status-absent { color: #dc3545; }
        .status-intarziat { color: #ffc107; }
    </style>
</head>
<body class="bg" onload="getTheme()">
    
            <h2>Prezență și Punctualitate</h2>
            
            <div class="prezenta-container">
                <% if (!isPrezentaAstazi) { %>
                    <button id="checkInBtn" class="prezenta-button btn-check-in" onclick="checkIn()">
                        Bifează Prezența
                    </button>
                    <p>Data: <%= LocalDate.now() %> | Ora: <span id="currentTime"></span></p>
                <% } else { %>
                    <div class="prezenta-info">
                        <h3>Ați fost marcat prezent pentru astăzi!</h3>
                        <p>Data: <%= LocalDate.now() %></p>
                    </div>
                <% } %>
                
                <div class="comment-section">
                    <h4>Adaugă comentariu (opțional):</h4>
                    <textarea id="comentariu" class="comment-box" rows="3" placeholder="Exemplu: Am întârziat din cauza traficului..."></textarea>
                    <button class="btn" onclick="addComment()">Salvează Comentariu</button>
                </div>
            </div>
            
            <% if (isSef || (isHR && !isDirector)) { %>
            <!-- Secțiune pentru HR și șefi de departament -->
            <div class="raport-prezenta">
                <h3>Raport Prezență Departament</h3>
                
                <div>
                    <label for="dataRaport">Selectați data:</label>
                    <input type="date" id="dataRaport" value="<%= LocalDate.now() %>" onchange="loadRaportPrezenta()">
                </div>
                
                <table class="prezenta-table" id="tabelPrezenta">
                    <thead>
                        <tr>
                            <th>Nume</th>
                            <th>Prenume</th>
                            <th>Ora</th>
                            <th>Status</th>
                            <th>Comentariu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Datele vor fi încărcate prin AJAX -->
                    </tbody>
                </table>
            </div>
            <% } %>
            
            <!-- Istoric prezență personală -->
            <div class="raport-prezenta">
                <h3>Istoricul Prezenței Tale</h3>
                <table class="prezenta-table">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Ora</th>
                            <th>Status</th>
                            <th>Comentariu</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String sql = "SELECT * FROM prezenta WHERE id_ang = ? ORDER BY data DESC LIMIT 30";
                            PreparedStatement pstmt = connection.prepareStatement(sql);
                            pstmt.setInt(1, userId);
                            ResultSet rsPrezenta = pstmt.executeQuery();
                            
                            while (rsPrezenta.next()) {
                                Time ora = rsPrezenta.getTime("ora");
                                String status = ora.toLocalTime().isAfter(LocalTime.of(9, 0)) ? "Întârziat" : "Prezent";
                                String statusClass = status.equals("Prezent") ? "status-prezent" : "status-intarziat";
                        %>
                            <tr>
                                <td><%= rsPrezenta.getDate("data") %></td>
                                <td><%= ora %></td>
                                <td class="<%= statusClass %>"><%= status %></td>
                                <td><%= rsPrezenta.getString("comentariu") != null ? rsPrezenta.getString("comentariu") : "-" %></td>
                            </tr>
                        <%
                            }
                            rsPrezenta.close();
                            pstmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
      
    <script>
        // Actualizează ora curentă
        function updateTime() {
            const now = new Date();
            document.getElementById('currentTime').textContent = 
                now.toLocaleTimeString('ro-RO', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        }
        
        setInterval(updateTime, 1000);
        updateTime();
        
        function checkIn() {
            const comentariu = document.getElementById('comentariu').value;
            
            $.ajax({
                url: 'CheckInServlet',
                type: 'POST',
                data: { comentariu: comentariu },
                success: function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert('Eroare la înregistrarea prezenței!');
                    }
                },
                error: function() {
                    alert('Eroare la conectarea cu serverul!');
                }
            });
        }
        
        function addComment() {
            const comentariu = document.getElementById('comentariu').value;
            
            if (!comentariu) {
                alert('Vă rugăm să introduceți un comentariu!');
                return;
            }
            
            $.ajax({
                url: 'AdaugaComentariuPrezentaServlet',
                type: 'POST',
                data: { comentariu: comentariu },
                success: function(response) {
                    if (response.success) {
                        alert('Comentariu adăugat cu succes!');
                        document.getElementById('comentariu').value = '';
                    } else {
                        alert('Eroare la adăugarea comentariului!');
                    }
                },
                error: function() {
                    alert('Eroare la conectarea cu serverul!');
                }
            });
        }
        
        function loadRaportPrezenta() {
            const data = document.getElementById('dataRaport').value;
            
            $.ajax({
                url: 'GetRaportPrezentaServlet',
                type: 'GET',
                data: { data: data },
                success: function(response) {
                    $('#tabelPrezenta tbody').html(response);
                },
                error: function() {
                    alert('Eroare la încărcarea raportului!');
                }
            });
        }
        
        // Încarcă raportul pentru ziua curentă
        <% if (isSef || (isHR && !isDirector)) { %>
        loadRaportPrezenta();
        <% } %>
    </script>
    <script src="js/core2.js"></script>
</body>
</html>

<%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                e.printStackTrace();
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