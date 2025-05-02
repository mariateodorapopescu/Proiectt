<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<%
    // Obținem sesiunea curentă
    HttpSession sesi = request.getSession(false);
    if (sesi == null) {
        out.println("<script>alert('Nu există sesiune activă!');</script>");
        response.sendRedirect("logout");
        return;
    }

    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser == null) {
        out.println("<script>alert('Utilizator neconectat!');</script>");
        response.sendRedirect("logout");
        return;
    }

    String username = currentUser.getUsername();
    int userdep = 0, id = 0, userType = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";

    // Obținem acțiunea din URL (parametrul "action")
    String action = request.getParameter("action");
    if (action == null) {
        action = "view"; // Acțiunea implicită
    }

    // Stocăm tipul utilizatorului în sesiune pentru servleturi
    Class.forName("com.mysql.cj.jdbc.Driver");

    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {

        preparedStatement.setString(1, username);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            id = rs.getInt("id");
            userType = rs.getInt("tip");
            userdep = rs.getInt("id_dep");
            
            // Stocăm tipul utilizatorului în sesiune
            sesi.setAttribute("userTip", userType);

            if (userType != 4) {
                String query = "SELECT * FROM teme WHERE id_usr = ?";
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
            }
        }
    }

    // Funcție helper pentru a determina rolul utilizatorului
    boolean isDirector = userType == 0 || userType > 15;
    boolean isSef = userType == 3 || (userType >= 10 && userType <= 15);
    boolean isUtilizatorNormal = !isDirector && !isSef; // tipuri 1, 2, 5-9
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <title>Administrare Proiecte</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
    <!--=============== jQuery ===============-->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: <%= clr %>;
            color: <%= text %>;
            margin: 0;
            padding: 0;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: <%=clr%>;
            border-radius: 2rem;
        }
        
        .modal-content {
            background-color: <%=sidebar%>;
            border-radius: 2rem;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
        }
        
        .close {
            background-color: <%=sidebar%>;
            color: <%=accent%>;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
        
        a, a:visited, a:hover, a:active {
            color: #eaeaea !important;
            text-decoration: none;
        }
        
        .main-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .action-button {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            background-color: <%=accent%>;
            color: white;
        }
        
        .action-button:hover {
            opacity: 0.9;
            background-color: <%=hover%>;
        }
        
        .form-container {
            background: #f5f5f5;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
        }
        
        .form-container h2 {
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        
        .submit-button {
            background-color: <%=accent%>;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .submit-button:hover {
            background-color: <%=hover%>;
        }
        
        .proiecte-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .proiecte-table th, .proiecte-table td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: center;
        }
        
        .proiecte-table th {
            background-color: <%=accent%>;
            color: white;
        }
        
        .proiecte-table tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        
        .table-button {
            padding: 5px 10px;
            margin: 0 5px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .modify-button {
            background-color: #4CAF50;
            color: white;
        }
        
        .team-button {
            background-color: #2196F3;
            color: white;
        }
        
        .delete-button {
            background-color: #f44336;
            color: white;
        }
        
        .back-button {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #666;
            color: white !important;
            text-decoration: none;
            border-radius: 5px;
        }
        
        .member-checkbox {
            margin-right: 10px;
        }
        
        .members-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            text-align: left;
            margin-top: 15px;
        }
        
        h1, h2, h3 {
            color: <%=accent%>;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        
        .alert-success {
            color: #3c763d;
            background-color: #dff0d8;
            border-color: #d6e9c6;
        }
        
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
    </style>
</head>
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>;">
    <div class="main-container">
        <h1>Administrare Proiecte</h1>
        
        <% 
        // Afișăm mesaje de succes sau eroare dacă există
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        
        if ("true".equals(success)) { 
        %>
            <div class="alert alert-success">
                Operațiunea a fost efectuată cu succes!
            </div>
        <% } else if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger">
                <% 
                if ("accessDenied".equals(error)) {
                    out.println("Nu aveți permisiunile necesare pentru această acțiune.");
                } else if ("invalidData".equals(error)) {
                    out.println("Datele introduse nu sunt valide.");
                } else if ("invalidDates".equals(error)) {
                    out.println("Data de început trebuie să fie înainte de data de sfârșit.");
                } else if ("databaseError".equals(error)) {
                    out.println("Eroare la baza de date.");
                } else if ("noMembersSelected".equals(error)) {
                    out.println("Nu ați selectat niciun membru.");
                } else {
                    out.println("A apărut o eroare.");
                }
                %>
            </div>
        <% } %>
        
        <% if ("view".equals(action)) { %>
            <div class="action-buttons">
                <button class="action-button" onclick="window.location.href='administrare_proiecte.jsp?action=add'">
                    Adaugă proiect
                </button>
                <button class="action-button" onclick="window.location.href='administrare_proiecte.jsp?action=list'">
                    Vizualizare și modificare proiecte
                </button>
            </div>
            
        <% } else if ("add".equals(action)) { %>
            <div class="form-container">
                <h2>Adaugă proiect</h2>
                <form method="POST" action="AAA">
                    <div class="form-group">
                        <label for="nume">Nume proiect:</label>
                        <input type="text" id="nume" name="nume" required>
                    </div>
                    <div class="form-group">
                        <label for="descriere">Descriere:</label>
                        <textarea id="descriere" name="descriere" required></textarea>
                    </div>
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" required>
                    </div>
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" required>
                    </div>
                    <div class="form-group">
                        <label for="manager">Manager proiect:</label>
                        <select id="manager" name="supervizor" required>
                            <option value="">-- Selectați --</option>
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                String sql = "SELECT id, nume, prenume FROM useri WHERE tip >= 10 AND activ = 1 ORDER BY nume, prenume";
                                try (Statement stmt = conn.createStatement();
                                     ResultSet rs = stmt.executeQuery(sql)) {
                                    
                                    while (rs.next()) {
                            %>
                                <option value="<%= rs.getInt("id") %>">
                                    <%= rs.getString("nume") %> <%= rs.getString("prenume") %>
                                </option>
                            <%
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    <div style="text-align: center;">
                        <button type="submit" class="submit-button">Adaugă Proiect</button>
                    </div>
                </form>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="administrare_proiecte.jsp" class="back-button">Înapoi</a>
                </div>
            </div>
            
        <% } else if ("list".equals(action)) { %>
            <h2>Vizualizare și modificare proiecte</h2>
            <table class="proiecte-table">
                <thead>
                    <tr>
                        <th>Nr. crt</th>
                        <th>Nume proiect</th>
                        <th>Modificare</th>
                        <th>Echipe</th>
                        <th>Ștergere</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        String sql = "SELECT p.id, p.nume FROM proiecte p ORDER BY p.nume";
                        try (Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {
                            
                            int counter = 1;
                            while (rs.next()) {
                    %>
                        <tr>
                            <td><%= counter++ %></td>
                            <td><%= rs.getString("nume") %></td>
                            <td>
                                <button class="table-button modify-button" 
                                        onclick="window.location.href='administrare_proiecte.jsp?action=edit&id=<%= rs.getInt("id") %>'">
                                    ✏
                                </button>
                            </td>
                            <td>
                                <button class="table-button team-button" 
                                        onclick="window.location.href='administrare_proiecte.jsp?action=teams&id=<%= rs.getInt("id") %>'">
                                    👥
                                </button>
                            </td>
                            <td>
                                <button class="table-button delete-button" 
                                        onclick="deleteProiect(<%= rs.getInt("id") %>)">
                                    ❌
                                </button>
                            </td>
                        </tr>
                    <%
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </tbody>
            </table>
            <div style="text-align: center; margin-top: 20px;">
                <a href="administrare_proiecte.jsp" class="back-button">Înapoi</a>
            </div>
            
        <% } else if ("edit".equals(action)) { 
            int idProiect = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                String sql = "SELECT * FROM proiecte WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idProiect);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
        %>
            <div class="form-container">
                <h2>Modificare proiect</h2>
                <form method="POST" action="blaaaa">
                    <input type="hidden" name="id" value="<%= idProiect %>">
                    <div class="form-group">
                        <label for="nume">Nume proiect:</label>
                        <input type="text" id="nume" name="nume" value="<%= rs.getString("nume") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="descriere">Descriere:</label>
                        <textarea id="descriere" name="descriere" required><%= rs.getString("descriere") %></textarea>
                    </div>
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" value="<%= rs.getDate("start") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" value="<%= rs.getDate("end") %>" required>
                    </div>
                    <div class="form-group">
                        <label for="manager">Manager proiect:</label>
                        <select id="manager" name="supervizor" required>
                            <%
                            String sql2 = "SELECT id, nume, prenume FROM useri WHERE tip >= 10 AND activ = 1 ORDER BY nume, prenume";
                            try (Statement stmt2 = conn.createStatement();
                                 ResultSet rs2 = stmt2.executeQuery(sql2)) {
                                
                                while (rs2.next()) {
                                    boolean selected = rs.getInt("supervizor") == rs2.getInt("id");
                            %>
                                <option value="<%= rs2.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs2.getString("nume") %> <%= rs2.getString("prenume") %>
                                </option>
                            <%
                                }
                            }
                            %>
                        </select>
                    </div>
                    <div style="text-align: center;">
                        <button type="submit" class="submit-button">Salvează Modificările</button>
                    </div>
                </form>
                <div style="text-align: center; margin-top: 20px;">
                    <a href="administrare_proiecte.jsp?action=list" class="back-button">Înapoi</a>
                </div>
            </div>
        <%
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("teams".equals(action)) { 
            int idProiect = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Obține detalii proiect
                String sqlProiect = "SELECT * FROM proiecte WHERE id = ?";
                try (PreparedStatement pstmtProiect = conn.prepareStatement(sqlProiect)) {
                    pstmtProiect.setInt(1, idProiect);
                    try (ResultSet rsProiect = pstmtProiect.executeQuery()) {
                        if (rsProiect.next()) {
        %>
            <div class="form-container">
                <h2>Gestionare echipe - <%= rsProiect.getString("nume") %></h2>
                
                <!-- Formular adăugare echipă nouă -->
                <form method="POST" action="moaradevant">
                    <input type="hidden" name="id_prj" value="<%= idProiect %>">
                    <div class="form-group">
                        <label for="nume_echipa">Nume echipă:</label>
                        <input type="text" id="nume_echipa" name="nume" required>
                    </div>
                    <div class="form-group">
                        <label for="supervizor_echipa">Supervizor echipă:</label>
                        <select id="supervizor_echipa" name="supervizor" required>
                            <option value="">-- Selectați --</option>
                            <%
                            String sqlSupervizori = "SELECT id, nume, prenume FROM useri WHERE tip >= 8 AND activ = 1 ORDER BY nume, prenume";
                            try (Statement stmtSupervizori = conn.createStatement();
                                 ResultSet rsSupervizori = stmtSupervizori.executeQuery(sqlSupervizori)) {
                                
                                while (rsSupervizori.next()) {
                            %>
                                <option value="<%= rsSupervizori.getInt("id") %>">
                                    <%= rsSupervizori.getString("nume") %> <%= rsSupervizori.getString("prenume") %>
                                </option>
                            <%
                                }
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Selectați membrii echipei:</label>
                        <div class="members-list">
                            <%
                            String sqlAngajati = "SELECT id, nume, prenume FROM useri WHERE activ = 1 AND id_echipa IS NULL ORDER BY nume, prenume";
                            try (Statement stmtAngajati = conn.createStatement();
                                 ResultSet rsAngajati = stmtAngajati.executeQuery(sqlAngajati)) {
                                
                                while (rsAngajati.next()) {
                            %>
                                <label>
                                    <input type="checkbox" name="membri" value="<%= rsAngajati.getInt("id") %>" class="member-checkbox">
                                    <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                                </label>
                            <%
                                }
                            }
                            %>
                        </div>
                    </div>
                    
                    <div style="text-align: center;">
                        <button type="submit" class="submit-button">Adaugă Echipă</button>
                    </div>
                </form>
                
                <!-- Listă echipe existente -->
                <h3 style="margin-top: 30px; text-align: center;">Echipe existente</h3>
                <table class="proiecte-table">
                    <thead>
                        <tr>
                            <th>Nume echipă</th>
                            <th>Supervizor</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        String sqlEchipe = "SELECT e.*, u.nume as supervizor_nume, u.prenume as supervizor_prenume " +
                                         "FROM echipe e " +
                                         "LEFT JOIN useri u ON e.supervizor = u.id " +
                                         "WHERE e.id_prj = ?";
                        try (PreparedStatement pstmtEchipe = conn.prepareStatement(sqlEchipe)) {
                            pstmtEchipe.setInt(1, idProiect);
                            try (ResultSet rsEchipe = pstmtEchipe.executeQuery()) {
                                boolean hasTeams = false;
                                while (rsEchipe.next()) {
                                    hasTeams = true;
                        %>
                            <tr>
                                <td><%= rsEchipe.getString("nume") %></td>
                                <td><%= rsEchipe.getString("supervizor_nume") %> <%= rsEchipe.getString("supervizor_prenume") %></td>
                                <td>
                                    <button class="table-button team-button" 
                                            onclick="window.location.href='administrare_proiecte.jsp?action=members&id_echipa=<%= rsEchipe.getInt("id") %>&id_prj=<%= idProiect %>'">
                                        👥 Membri
                                    </button>
                                    <button class="table-button delete-button" 
                                            onclick="deleteEchipa(<%= rsEchipe.getInt("id") %>, <%= idProiect %>)">
                                        ❌
                                    </button>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hasTeams) {
                        %>
                            <tr>
                                <td colspan="3">Nu există echipe create pentru acest proiect.</td>
                            </tr>
                        <%
                                }
                            }
                        }
                        %>
                    </tbody>
                </table>
                
                <div style="text-align: center; margin-top: 20px;">
                    <a href="administrare_proiecte.jsp?action=list" class="back-button">Înapoi</a>
                </div>
            </div>
        <%
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("members".equals(action)) {
            int idEchipa = Integer.parseInt(request.getParameter("id_echipa"));
            int idProiect = Integer.parseInt(request.getParameter("id_prj"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                // Obține detalii echipă
                String sqlEchipa = "SELECT e.*, u.nume as supervizor_nume, u.prenume as supervizor_prenume " +
                                "FROM echipe e " +
                                "LEFT JOIN useri u ON e.supervizor = u.id " +
                                "WHERE e.id = ?";
                try (PreparedStatement pstmtEchipa = conn.prepareStatement(sqlEchipa)) {
                    pstmtEchipa.setInt(1, idEchipa);
                    try (ResultSet rsEchipa = pstmtEchipa.executeQuery()) {
                        if (rsEchipa.next()) {
        %>
            <div class="form-container">
                <h2>Membri echipa: <%= rsEchipa.getString("nume") %></h2>
                <h3>Supervizor: <%= rsEchipa.getString("supervizor_nume") %> <%= rsEchipa.getString("supervizor_prenume") %></h3>
                
                <!-- Formular adăugare membri -->
                <form method="POST" action="AdaugaMembruEchipaServlet">
                    <input type="hidden" name="id_echipa" value="<%= idEchipa %>">
                    <input type="hidden" name="id_prj" value="<%= idProiect %>">
                    
                    <div class="form-group">
                        <label>Adaugă membri noi:</label>
                        <div class="members-list">
                            <%
                            // Selectează angajații care nu sunt deja în echipă
                            String sqlAngajatiNeinclusi = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                                        "WHERE u.activ = 1 " +
                                                        "AND u.id_echipa IS NULL " +
                                                        "ORDER BY u.nume, u.prenume";
                            try (PreparedStatement pstmtAngajati = conn.prepareStatement(sqlAngajatiNeinclusi)) {
                                try (ResultSet rsAngajati = pstmtAngajati.executeQuery()) {
                                    boolean hasCandidates = false;
                                    while (rsAngajati.next()) {
                                        hasCandidates = true;
                            %>
                                <label>
                                    <input type="checkbox" name="membri" value="<%= rsAngajati.getInt("id") %>" class="member-checkbox">
                                    <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                                </label>
                            <%
                                    }
                                    if (!hasCandidates) {
                            %>
                                <p>Nu mai există angajați disponibili pentru adăugare în echipă.</p>
                            <%
                                    } else {
                            %>
                                <div style="text-align: center; margin-top: 20px;">
                                    <button type="submit" class="submit-button">Adaugă Membri</button>
                                </div>
                            <%
                                    }
                                }
                            }
                            %>
                        </div>
                    </div>
                </form>
                
                <!-- Lista membrilor actuali -->
                <h3 style="margin-top: 30px; text-align: center;">Membri actuali ai echipei</h3>
                <table class="proiecte-table">
                    <thead>
                        <tr>
                            <th>Nume</th>
                            <th>Prenume</th>
                            <th>Poziție</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        String sqlMembri = "SELECT u.id, u.nume, u.prenume, t.denumire as pozitie " +
                                        "FROM useri u " +
                                        "JOIN tipuri t ON u.tip = t.tip " +
                                        "WHERE u.id_echipa = ?";
                        try (PreparedStatement pstmtMembri = conn.prepareStatement(sqlMembri)) {
                            pstmtMembri.setInt(1, idEchipa);
                            try (ResultSet rsMembri = pstmtMembri.executeQuery()) {
                                boolean hasMembers = false;
                                while (rsMembri.next()) {
                                    hasMembers = true;
                        %>
                            <tr>
                                <td><%= rsMembri.getString("nume") %></td>
                                <td><%= rsMembri.getString("prenume") %></td>
                                <td><%= rsMembri.getString("pozitie") %></td>
                                <td>
                                    <button class="table-button delete-button" 
                                            onclick="removeMembru(<%= rsMembri.getInt("id") %>, <%= idEchipa %>, <%= idProiect %>)">
                                        Elimină
                                    </button>
                                </td>
                            </tr>
                        <%
                                }
                                if (!hasMembers) {
                        %>
                            <tr>
                                <td colspan="4">Echipa nu are membri încă.</td>
                            </tr>
                        <%
                                }
                            }
                        }
                        %>
                    </tbody>
                </table>
                
                <div style="text-align: center; margin-top: 20px;">
                    <a href="administrare_proiecte.jsp?action=teams&id=<%= idProiect %>" class="back-button">Înapoi la echipe</a>
                </div>
            </div>
        <%
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        %>
    </div>
   
    <script>
    function deleteProiect(idProiect) {
        if (confirm('Sigur doriți să ștergeți acest proiect? Se vor șterge și echipele asociate!')) {
            console.log("Trimitem cerere de ștergere pentru proiectul ID: " + idProiect);
            $.ajax({
                url: 'DeleteProiectServlet',
                type: 'POST',
                data: { id: idProiect },
                dataType: 'json',
                success: function(response) {
                    console.log("Răspuns primit:", response);
                    if (response.success) {
                        alert('Proiectul a fost șters cu succes!');
                        window.location.href = 'administrare_proiecte.jsp?action=list&success=true';
                    } else {
                        alert(response.message || 'Eroare la ștergerea proiectului!');
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Eroare AJAX:", status, error);
                    console.log("Răspuns XHR:", xhr.responseText);
                    alert('Eroare la conectarea cu serverul: ' + error);
                }
            });
        }
    }
        
    function deleteEchipa(idEchipa, idProiect) {
        if (confirm('Sigur doriți să ștergeți această echipă?')) {
            console.log("Trimitem cerere de ștergere pentru echipa ID: " + idEchipa);
            $.ajax({
                url: 'DeleteEchipaServlet',
                type: 'POST',
                data: { id: idEchipa },
                dataType: 'json',
                success: function(response) {
                    console.log("Răspuns primit:", response);
                    if (response.success) {
                        alert('Echipa a fost ștearsă cu succes!');
                        window.location.href = 'administrare_proiecte.jsp?action=teams&id=' + idProiect + '&success=true';
                    } else {
                        alert(response.message || 'Eroare la ștergerea echipei!');
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Eroare AJAX:", status, error);
                    console.log("Răspuns XHR:", xhr.responseText);
                    alert('Eroare la conectarea cu serverul: ' + error);
                }
            });
        }
    }
        
    function removeMembru(idMembru, idEchipa, idProiect) {
        if (confirm('Sigur doriți să eliminați acest membru din echipă?')) {
            console.log("Trimitem cerere de eliminare pentru membrul ID: " + idMembru);
            $.ajax({
                url: 'RemoveMembruEchipaServlet',
                type: 'POST',
                data: { id: idMembru },
                dataType: 'json',
                success: function(response) {
                    console.log("Răspuns primit:", response);
                    if (response.success) {
                        alert('Membrul a fost eliminat cu succes!');
                        window.location.href = 'administrare_proiecte.jsp?action=members&id_echipa=' + idEchipa + '&id_prj=' + idProiect + '&success=true';
                    } else {
                        alert(response.message || 'Eroare la eliminarea membrului!');
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Eroare AJAX:", status, error);
                    console.log("Răspuns XHR:", xhr.responseText);
                    alert('Eroare la conectarea cu serverul: ' + error);
                }
            });
        }
    }
    </script>
</body>
</html>