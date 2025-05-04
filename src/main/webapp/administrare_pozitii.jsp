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
    int userdep = 0, id = 0, userType = 0, ierarhie = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";
    String functie = "";

    // Obținem acțiunea din URL (parametrul "action")
    String action = request.getParameter("action");
    if (action == null) {
        action = "view"; // Acțiunea implicită
    }


    Class.forName("com.mysql.cj.jdbc.Driver");

    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
            PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                    "dp.denumire_completa AS denumire FROM useri u " +
                    "JOIN tipuri t ON u.tip = t.tip " +
                    "JOIN departament d ON u.id_dep = d.id_dep " +
                    "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                    "WHERE u.username = ?")) {
            preparedStatement.setString(1, username);
            ResultSet rs = preparedStatement.executeQuery();
            if (rs.next()) {
            	// extrag date despre userul curent
                id = rs.getInt("id");
                userType = rs.getInt("tip");
                userdep = rs.getInt("id_dep");
                functie = rs.getString("functie");
                ierarhie = rs.getInt("ierarhie");
                if (functie.compareTo("Administrator") == 0) {  
                  
                      
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
    boolean isDirector = (ierarhie < 3) ;
    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
    boolean isUtilizatorNormal = !isDirector && !isSef; // tipuri 1, 2, 5-9
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <title>Administrare Poziții</title>
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
            background-color: rgba(0,0,0,0.4);
        }
        
        .modal-content {
            background-color: <%=card%>;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 600px;
            border-radius: 8px;
        }
        
        .close {
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            color: <%=accent%>
        }
        
        .close:hover,
        .close:focus {
            color: #000;
            text-decoration: none;
        }
        
        a, a:visited, a:hover, a:active {
            color: <%=clr%> !important;
            text-decoration: none;
        }
        
        .main-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px;
            background: <%=card%>;
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
            background: <%=card%>;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
        }
        
        .form-container h2 {
            margin-bottom: 20px;
            color: <%=text%>;
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
            border: 1px solid <%=card%>;
            border-radius: 5px;
            font-size: 16px;
        }
        
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        
        .submit-button, .btn {
            background-color: <%=accent%>;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .submit-button:hover, .btn:hover {
            background-color: black;
        }
        
        .pozitii-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        
        .pozitii-table th, .pozitii-table td {
            border: 1px solid <%=card%>;
            padding: 8px;
            text-align: left;
        }
        
        .pozitii-table th {
            background-color: <%=accent%>;
            color: white;
        }
        
        .pozitii-table tr:hover {
            background-color: <%=accent%>;
        }
        
        .btn-small {
            padding: 5px 10px;
            font-size: 0.9em;
            margin: 2px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            color: white;
        }
        
        .btn-edit {
            background-color: #4CAF50;
        }
        
        .btn-toggle {
            background-color: #2196F3;
        }
        
        .btn-danger {
            background-color: #f44336;
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
        
        .tab-container {
            margin-bottom: 20px;
        }
        
        .tab-button {
            padding: 10px 20px;
            margin-right: 5px;
            border: none;
            background-color: #f1f1f1;
            cursor: pointer;
        }
        
        .tab-button.active {
            background-color: <%=accent%>;
            color: white;
            font-weight: bold;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        form label {
            display: block;
            margin: 15px 0 5px;
            font-weight: bold;
        }
        
        form select, form input, form textarea {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
    </style>
</head>
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>;">
    <div class="main-container">
        <h1>Administrare Tipuri de Poziții</h1>
        
        <% 
        // Display success or error messages
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        
        if (success != null) {
        %>
            <div class="alert alert-success">
                <% if ("true".equals(success)) { %>
                    Operațiune efectuată cu succes!
                <% } else if ("updated".equals(success)) { %>
                    Datele au fost actualizate cu succes!
                <% } %>
            </div>
        <% 
        }
        
        if (error != null) {
        %>
            <div class="alert alert-danger">
                <% if ("true".equals(error)) { %>
                    A apărut o eroare la efectuarea operațiunii.
                <% } else if ("duplicate".equals(error)) { %>
                    Această denumire pentru departament există deja.
                <% } else if ("accessDenied".equals(error)) { %>
                    Nu aveți permisiuni pentru această operațiune.
                <% } else if ("updateFailed".equals(error)) { %>
                    Actualizarea datelor a eșuat.
                <% } else if ("driverNotFound".equals(error)) { %>
                    Eroare la încărcarea driverului de bază de date.
                <% } %>
            </div>
        <% 
        }
        %>
        
        <div class="tab-container">
            <button class="tab-button active" onclick="showTab('pozitii', this)">Poziții Standard</button>
            <button class="tab-button" onclick="showTab('denumiri', this)">Denumiri pe Departamente</button>
            <button class="tab-button" onclick="showTab('asignare', this)">Asignare Poziție</button>
        </div>
        
        <!-- Tab Poziții Standard -->
        <div id="pozitii" class="tab-content active">
            <button class="btn" onclick="openModal('addPozitieModal')">Adaugă Poziție Nouă</button>
            
            <table class="pozitii-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Denumire</th>
                        <th>Salariu Standard</th>
                        <th>Ierarhie</th>
                        <th>Departament Specific</th>
                        <th>Descriere</th>
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Connection conn = null;
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT t.*, d.nume_dep FROM tipuri t LEFT JOIN departament d ON t.departament_specific = d.id_dep ORDER BY t.ierarhie, t.denumire";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <tr>
                            <td><%= rs.getInt("tip") %></td>
                            <td><%= rs.getString("denumire") %></td>
                            <td><%= rs.getInt("salariu") %> RON</td>
                            <td><%= rs.getInt("ierarhie") %></td>
                            <td><%= rs.getString("nume_dep") != null ? rs.getString("nume_dep") : "General" %></td>
                            <td><%= rs.getString("descriere") != null ? rs.getString("descriere") : "" %></td>
                            <td>
                                <button class="btn-small btn-edit" onclick="editPozitie(<%= rs.getInt("tip") %>)">Editează</button>
                                <button class="btn-small btn-danger" onclick="deletePozitie(<%= rs.getInt("tip") %>)">
                                    Șterge
                                </button>
                            </td>
                        </tr>
                    <%
                        }
                        rs.close();
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
        </div>
        
        <!-- Tab Denumiri pe Departamente -->
        <div id="denumiri" class="tab-content">
            <button class="btn" onclick="openModal('addDenumireModal')">Adaugă Denumire Departament</button>
            
            <table class="pozitii-table">
                <thead>
                    <tr>
                        <th>Poziție</th>
                        <th>Departament</th>
                        <th>Denumire Completă</th>
                        
                        <th>Acțiuni</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT dp.*, t.denumire as pozitie_standard, d.nume_dep " +
                                   "FROM denumiri_pozitii dp " +
                                   "JOIN tipuri t ON dp.tip_pozitie = t.tip " +
                                   "JOIN departament d ON dp.id_dep = d.id_dep " +
                                   "ORDER BY d.nume_dep, t.ierarhie";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <tr>
                            <td><%= rs.getString("pozitie_standard") %></td>
                            <td><%= rs.getString("nume_dep") %></td>
                            <td><%= rs.getString("denumire_completa") %></td>
                           
                            <td>
                                <button class="btn-small btn-edit" onclick="editDenumire(<%= rs.getInt("id") %>)">Editează</button>
                               
                                <button class="btn-small btn-danger" onclick="deleteDenumire(<%= rs.getInt("id") %>)">
                                    Șterge
                                </button>
                            </td>
                        </tr>
                    <%
                        }
                        rs.close();
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
        </div>
        
        <!-- Tab Asignare Poziție -->
        <div id="asignare" class="tab-content">
            <h3>Asignare Poziție pentru Angajat</h3>
            <form id="asignareForm" method="POST" action="AsignarePozitieServlet">
                <label for="angajat">Selectați Angajatul:</label>
                <select id="angajat" name="id_ang" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT u.id, u.nume, u.prenume, t.denumire as pozitie_curenta, d.nume_dep " +
                                   "FROM useri u " +
                                   "JOIN tipuri t ON u.tip = t.tip " +
                                   "JOIN departament d ON u.id_dep = d.id_dep " +
                                   "WHERE u.activ = 1 " +
                                   "ORDER BY u.nume, u.prenume";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                            <option value="<%= rs.getInt("id") %>">
                                <%= rs.getString("nume") %> <%= rs.getString("prenume") %> - 
                                <%= rs.getString("pozitie_curenta") %> (<%= rs.getString("nume_dep") %>)
                            </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="departament">Departament:</label>
                <select id="departament" name="id_dep" required onchange="loadPozitiiDepartament(this.value)">
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT * FROM departament ORDER BY nume_dep";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                            <option value="<%= rs.getInt("id_dep") %>">
                                <%= rs.getString("nume_dep") %>
                            </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="pozitie">Poziție:</label>
                <select id="pozitie" name="tip_pozitie" required>
                    <option value="">-- Selectați mai întâi departamentul --</option>
                </select>
                
                <label for="dataPozitie">Data Început Poziție:</label>
                <input type="date" id="dataPozitie" name="data_pozitie" required value="<%= LocalDate.now() %>">
                
                <button type="submit" class="btn">Asignează Poziție</button>
            </form>
        </div>
    </div>
    
    <!-- Modal Adăugare Poziție -->
    <div id="addPozitieModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('addPozitieModal')">&times;</span>
            <h3>Adaugă Poziție Nouă</h3>
            <form method="POST" action="AdaugaPozitieServlet">
                <label for="denumire">Denumire:</label>
                <input type="text" id="denumire" name="denumire" required>
                
                <label for="salariu">Salariu Standard:</label>
                <input type="number" id="salariu" name="salariu" min="0" required>
                
                <label for="ierarhie">Nivel Ierarhic:</label>
                <input type="number" id="ierarhie" name="ierarhie" min="0" required>
                
                <label for="departament_specific">Departament Specific:</label>
                <select id="departament_specific" name="departament_specific">
                    <option value="20">General (Toate departamentele)</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT * FROM departament WHERE id_dep != 20 ORDER BY nume_dep";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_dep") %>">
                            <%= rs.getString("nume_dep") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="descriere">Descriere:</label>
                <textarea id="descriere" name="descriere" rows="4"></textarea>
                
                <button type="submit" class="btn">Salvează</button>
                <button type="button" class="btn" style="background-color: #999;" onclick="closeModal('addPozitieModal')">Anulează</button>
            </form>
        </div>
    </div>
    
    <!-- Modal Adăugare Denumire Departament -->
    <div id="addDenumireModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('addDenumireModal')">&times;</span>
            <h3>Adaugă Denumire pentru Departament</h3>
            <form method="POST" action="AdaugaDenumireServlet">
                <label for="tip_pozitie">Poziție Standard:</label>
                <select id="tip_pozitie" name="tip_pozitie" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT tip, denumire FROM tipuri ORDER BY ierarhie, denumire";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("tip") %>">
                            <%= rs.getString("denumire") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="id_dep_modal">Departament:</label>
                <select id="id_dep_modal" name="id_dep" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT * FROM departament ORDER BY nume_dep";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_dep") %>">
                            <%= rs.getString("nume_dep") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="denumire_completa">Denumire Completă:</label>
                <input type="text" id="denumire_completa" name="denumire_completa" required>
                
                <button type="submit" class="btn">Salvează</button>
                <button type="button" class="btn" style="background-color: #999;" onclick="closeModal('addDenumireModal')">Anulează</button>
            </form>
        </div>
    </div>

    <!-- Modal pentru editarea poziției -->
    <div id="editPozitieModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('editPozitieModal')">&times;</span>
            <h3>Editare Poziție</h3>
            <form method="POST" action="EditPozitieServlet">
                <input type="hidden" id="editTipId" name="tip_id">
                
                <label for="editDenumire">Denumire:</label>
                <input type="text" id="editDenumire" name="denumire" required>
                
                <label for="editSalariu">Salariu Standard:</label>
                <input type="number" id="editSalariu" name="salariu" min="0" required>
                
                <label for="editIerarhie">Nivel Ierarhic:</label>
                <input type="number" id="editIerarhie" name="ierarhie" min="0" required>
                
                <label for="editDepartamentSpecific">Departament Specific:</label>
                <select id="editDepartamentSpecific" name="departament_specific">
                    <option value="20">General (Toate departamentele)</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT * FROM departament WHERE id_dep != 20 ORDER BY nume_dep";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_dep") %>">
                            <%= rs.getString("nume_dep") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="editDescriere">Descriere:</label>
                <textarea id="editDescriere" name="descriere" rows="4"></textarea>
                
                <button type="submit" class="btn">Salvează Modificările</button>
                <button type="button" class="btn" style="background-color: #999;" onclick="closeModal('editPozitieModal')">Anulează</button>
            </form>
        </div>
    </div>

    <!-- Modal pentru editarea denumirii -->
    <div id="editDenumireModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('editDenumireModal')">&times;</span>
            <h3>Editare Denumire</h3>
            <form method="POST" action="EditDenumireServlet">
                <input type="hidden" id="editDenumireId" name="id">
                
                <label for="editTipPozitie">Poziție Standard:</label>
                <select id="editTipPozitie" name="tip_pozitie" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT tip, denumire FROM tipuri ORDER BY ierarhie, denumire";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("tip") %>">
                            <%= rs.getString("denumire") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="editIdDep">Departament:</label>
                <select id="editIdDep" name="id_dep" required>
                    <option value="">-- Selectați --</option>
                    <%
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT * FROM departament ORDER BY nume_dep";
                        Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery(sql);
                        
                        while (rs.next()) {
                    %>
                        <option value="<%= rs.getInt("id_dep") %>">
                            <%= rs.getString("nume_dep") %>
                        </option>
                    <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    } finally {
                        if (conn != null) {
                            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                    %>
                </select>
                
                <label for="editDenumireCompleta">Denumire Completă:</label>
                <input type="text" id="editDenumireCompleta" name="denumire_completa" required>
                
                <button type="submit" class="btn">Salvează Modificările</button>
                <button type="button" class="btn" style="background-color: #999;" onclick="closeModal('editDenumireModal')">Anulează</button>
            </form>
        </div>
    </div>

    <script>
        function showTab(tabName, button) {
            // Ascunde toate tab-urile
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
            });
            document.querySelectorAll('.tab-button').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Afișează tab-ul selectat
            document.getElementById(tabName).classList.add('active');
            if (button) {
                button.classList.add('active');
            } else {
                // Fallback pentru event.target (pentru compatibilitate cu codul vechi)
                document.querySelector('.tab-button[onclick*="' + tabName + '"]').classList.add('active');
            }
        }
        
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        function loadPozitiiDepartament(depId) {
            if (!depId) {
                document.getElementById('pozitie').innerHTML = '<option value="">-- Selectați mai întâi departamentul --</option>';
                document.getElementById('pozitie').disabled = true;
                return;
            }
            
            document.getElementById('pozitie').disabled = false;
            
            $.ajax({
                url: 'GetPozitiiDepartamentServlet',
                type: 'GET',
                data: { id_dep: depId },
                success: function(response) {
                    $('#pozitie').html(response);
                },
                error: function(xhr, status, error) {
                    alert('Eroare la încărcarea pozițiilor pentru departament: ' + error);
                    console.error(xhr, status, error);
                }
            });
        }
        
        // Function to edit a position
        function editPozitie(tipId) {
            $.ajax({
                url: 'GetPozitieServlet',
                type: 'GET',
                data: { id: tipId },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Populate the edit form with position data
                        $('#editTipId').val(response.tip);
                        $('#editDenumire').val(response.denumire);
                        $('#editSalariu').val(response.salariu);
                        $('#editIerarhie').val(response.ierarhie);
                        $('#editDepartamentSpecific').val(response.departament_specific);
                        $('#editDescriere').val(response.descriere);
                        
                        // Show the edit modal
                        openModal('editPozitieModal');
                    } else {
                        alert(response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Eroare la obținerea datelor poziției: ' + error);
                    console.error(xhr, status, error);
                }
            });
        }
        
        // Function to delete a position
        function deletePozitie(tipId) {
            if (confirm('Atenție! Sunteți sigur că doriți să ștergeți această poziție? Această acțiune este ireversibilă.')) {
                $.ajax({
                    url: 'DeletePozitieServlet',
                    type: 'POST',
                    data: { id: tipId },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Eroare la ștergerea poziției: ' + error);
                        console.error(xhr, status, error);
                    }
                });
            }
        }
        
        // Function to edit a position name
        function editDenumire(id) {
            $.ajax({
                url: 'GetDenumireServlet',
                type: 'GET',
                data: { id: id },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        // Populate the edit form with position name data
                        $('#editDenumireId').val(response.id);
                        $('#editTipPozitie').val(response.tip_pozitie);
                        $('#editIdDep').val(response.id_dep);
                        $('#editDenumireCompleta').val(response.denumire_completa);
                        
                        // Show the edit modal
                        openModal('editDenumireModal');
                    } else {
                        alert(response.message);
                    }
                },
                error: function(xhr, status, error) {
                    alert('Eroare la obținerea datelor denumirii: ' + error);
                    console.error(xhr, status, error);
                }
            });
        }
        
        // Function to toggle position name active status
        function toggleDenumire(id, currentStatus) {
            if (confirm('Sigur doriți să ' + (currentStatus ? 'dezactivați' : 'activați') + ' această denumire?')) {
                $.ajax({
                    url: 'ToggleDenumireServlet',
                    type: 'POST',
                    data: { id: id, current_status: currentStatus },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Eroare la schimbarea statusului: ' + error);
                        console.error(xhr, status, error);
                    }
                });
            }
        }
        
        // Function to delete a position name
        function deleteDenumire(id) {
            if (confirm('Atenție! Sunteți sigur că doriți să ștergeți această denumire? Această acțiune este ireversibilă.')) {
                $.ajax({
                    url: 'DeleteDenumireServlet',
                    type: 'POST',
                    data: { id: id },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('Eroare la ștergerea denumirii: ' + error);
                        console.error(xhr, status, error);
                    }
                });
            }
        }
        
        // Close modals when clicking outside
        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) {
                event.target.style.display = 'none';
            }
        }
        
        // Initialize current date for dataPozitie field
        document.addEventListener('DOMContentLoaded', function() {
            var today = new Date().toISOString().split('T')[0];
            document.getElementById('dataPozitie').value = today;
        });
    </script>
    <script src="js/core2.js"></script>
</body>
</html>