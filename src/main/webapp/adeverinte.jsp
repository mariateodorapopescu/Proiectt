<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extrag usernameul, care e unic si asta cam transmit in formuri (mai transmit si id dar deocmadata ma bazez pe username)
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
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
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                  
                        // Obținere preferințe de temă
                        String accent = "#4F46E5"; // Culoare implicită
                        String clr = "#f9fafb";
                        String sidebar = "#ffffff";
                        String text = "#1f2937";
                        String card = "#ffffff";
                        String hover = "#f3f4f6";
                        
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
                            out.println("<script>console.error('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Management Adeverințe</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <style>
        :root {
            --accent: <%=accent%>;
            --background: <%=clr%>;
            --card: <%=sidebar%>;
            --text: <%=text%>;
            --border: #e5e7eb;
            --hover: <%=hover%>;
            --danger: #ef4444;
            --success: #10b981;
            --warning: #f59e0b;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--text);
            line-height: 1.5;
        }
        
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }
        
        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text);
        }
        
        .action-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.5rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            color: white;
        }
        
        .btn-primary {
            background-color: var(--accent);
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-danger {
            background-color: var(--danger);
        }
        
        .btn-danger:hover {
            opacity: 0.9;
        }
        
        .btn-success {
            background-color: var(--success);
        }
        
        .btn-success:hover {
            opacity: 0.9;
        }
        
        .btn-small {
            padding: 0.375rem 0.75rem;
            font-size: 0.75rem;
        }
        
        /* Card pentru tabel */
        .card {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 2rem;
        }
        
        .card-header {
            background-color: var(--accent);
            color: white;
            font-weight: 600;
            padding: 1rem 1.5rem;
            border-top-left-radius: 0.75rem;
            border-top-right-radius: 0.75rem;
        }
        
        .card-body {
            padding: 1.5rem;
        }
        
        /* Stiluri pentru tabel */
        .table-container {
            overflow-x: auto;
        }
        
        .adeverinte-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        .adeverinte-table th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        .adeverinte-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        .adeverinte-table tr:last-child td {
            border-bottom: none;
        }
        
        .adeverinte-table tr:hover td {
            background-color: var(--hover);
        }
        
        .status-aprobat {
            color: var(--success);
            font-weight: 600;
        }
        
        .status-asteptare {
            color: var(--warning);
            font-weight: 600;
        }
        
        .status-respins {
            color: var(--danger);
            font-weight: 600;
        }
        
        /* Alerte */
        .alert {
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .alert-success {
            background-color: rgba(16, 185, 129, 0.1);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        
        .alert-danger {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        
        .alert-icon {
            font-size: 1.25rem;
        }
        
        /* Acțiuni în tabel */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .action-row {
                flex-direction: column;
                align-items: stretch;
                gap: 1rem;
            }
            
            .btn {
                width: 100%;
            }
        }
        
        /* Stiluri pentru nicio adeverință */
        .empty-state {
            padding: 2rem;
            text-align: center;
            color: #6b7280;
        }
        
        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #d1d5db;
        }
        
        .empty-state-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--text);
        }
        
        .empty-state-description {
            margin-bottom: 1.5rem;
        }
        
        /* Tabs */
        .tabs {
            display: flex;
            border-bottom: 1px solid var(--border);
            margin-bottom: 1.5rem;
        }
        
        .tab {
            padding: 0.75rem 1.25rem;
            font-weight: 500;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.2s;
            color: var(--text);
        }
        
        .tab.active {
            color: var(--accent);
            border-bottom-color: var(--accent);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* Spinner */
        .spinner {
            border: 2px solid rgba(0, 0, 0, 0.1);
            border-radius: 50%;
            border-top: 2px solid var(--accent);
            width: 16px;
            height: 16px;
            animation: spin 1s linear infinite;
            display: inline-block;
            margin-right: 0.5rem;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .btn-group {
            display: flex;
            gap: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">
                Management Adeverințe
                <span class="text-sm text-gray-500">
                    (<%= userType == 0 ? "Director" : "Șef Departament" %>)
                </span>
            </h1>
            
            <a href="dashboard.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Înapoi la Panou
            </a>
        </div>
        
        <div id="alert-container"></div>
        
        <div class="tabs">
            <div class="tab active" data-tab="pending">Cereri în așteptare</div>
            <div class="tab" data-tab="processed">Cereri procesate</div>
        </div>
        
        <!-- Tab: Cereri în așteptare -->
        <div id="pending-tab" class="tab-content active">
            <div class="card">
                <div class="card-header">
                    <h2>Cereri de adeverințe în așteptare</h2>
                </div>
                <div class="card-body">
                    <div class="table-container">
                        <table class="adeverinte-table">
                            <thead>
                                <tr>
                                    <th>Angajat</th>
                                    <th>Tip adeverință</th>
                                    <th>Pentru a servi la</th>
                                    <th>Data cererii</th>
                                    <th>Status</th>
                                    <th>Acțiuni</th>
                                </tr>
                            </thead>
                            <tbody id="pending-table-body">
                                <%
                                Connection conn = null;
                                PreparedStatement pstmt = null;
                                ResultSet rs2 = null;
                                
                                try {
                                    // Utilizăm DriverManager în loc de DBConn
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                    
                                    String sql = "SELECT a.*, ta.denumire as tip_adeverinta, s.nume_status, " +
                                                "u.nume, u.prenume, u.tip as angajat_tip " +
                                                "FROM adeverinte a " +
                                                "JOIN tip_adev ta ON a.tip = ta.id " +
                                                "JOIN statusuri s ON a.status = s.status " +
                                                "JOIN useri u ON a.id_ang = u.id " +
                                                "WHERE ";
                                    
                                    if (userType == 3) { // Șef de departament
                                        // Șeful vede doar cererile în status 0 (inițial) din propriul departament
                                        // și doar pentru angajații obișnuiți (nu pentru alți șefi sau directori)
                                        sql += "u.id_dep = ? AND a.status = 0 AND u.tip != 3 AND u.tip != 4 AND u.tip < 10";
                                    } else if (userType == 0) { // Director
                                        // Directorul vede:
                                        // 1. Cererile proprii în status 0
                                        // 2. Cererile aprobate de șefi (status 1)
                                        // 3. Cererile în status 0 de la șefi/manageri (tip=3 sau 10<=tip<=15)
                                        sql += "(a.id_ang = ? AND a.status = 0) OR " +
                                              "(a.status = 1) OR " +
                                              "(a.status = 0 AND (u.tip = 3 OR (u.tip >= 10 AND u.tip <= 15)))";
                                    }
                                    
                                    sql += " ORDER BY a.creare DESC";
                                    
                                    pstmt = conn.prepareStatement(sql);
                                    if (userType == 3) {
                                        pstmt.setInt(1, userDep);
                                    } else if (userType == 0) {
                                        pstmt.setInt(1, userId);
                                    }
                                    
                                    rs2 = pstmt.executeQuery();
                                    
                                    boolean hasAdeverinte = false;
                                    
                                    while (rs2.next()) {
                                        hasAdeverinte = true;
                                        String statusClass = "";
                                        switch (rs2.getInt("status")) {
                                            case 1: statusClass = "status-asteptare"; break;
                                            case 0: statusClass = "status-asteptare"; break;
                                        }
                                %>
                                    <tr id="adeverinta-<%= rs2.getInt("id") %>">
                                        <td><%= rs2.getString("nume") %> <%= rs2.getString("prenume") %></td>
                                        <td><%= rs2.getString("tip_adeverinta") %></td>
                                        <td><%= rs2.getString("pentru_servi") %></td>
                                        <td><%= rs2.getDate("creare") %></td>
                                        <td class="<%= statusClass %>"><%= rs2.getString("nume_status") %></td>
                                        <td>
                                            <div class="btn-group">
                                                <% if (userType == 3 && rs2.getInt("status") == 0) { %>
                                                    <button class="btn btn-small btn-success" 
                                                            onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, 1)">
                                                        <i class="fas fa-check"></i> Aprobă
                                                    </button>
                                                    <button class="btn btn-small btn-danger" 
                                                            onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, -1)">
                                                        <i class="fas fa-times"></i> Respinge
                                                    </button>
                                                <% } else if (userType == 0) { %>
                                                    <% if (rs2.getInt("status") == 1) { %>
                                                        <button class="btn btn-small btn-success" 
                                                                onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, 2)">
                                                            <i class="fas fa-check-double"></i> Aprobă Final
                                                        </button>
                                                        <button class="btn btn-small btn-danger" 
                                                                onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, -2)">
                                                            <i class="fas fa-times"></i> Respinge
                                                        </button>
                                                    <% } else if (rs2.getInt("status") == 0) { %>
                                                        <% if (rs2.getInt("id_ang") == userId) { %>
                                                            <!-- Cazul când directorul își procesează propria cerere -->
                                                            <button class="btn btn-small btn-success" 
                                                                    onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, 2)">
                                                                <i class="fas fa-check-double"></i> Auto-Aprobă
                                                            </button>
                                                            <button class="btn btn-small btn-danger" 
                                                                    onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, -1)">
                                                                <i class="fas fa-times"></i> Respinge
                                                            </button>
                                                        <% } else { %>
                                                            <!-- Cereri de la șefi/manageri în status inițial -->
                                                            <button class="btn btn-small btn-success" 
                                                                    onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, 2)">
                                                                <i class="fas fa-check-double"></i> Aprobă Final
                                                            </button>
                                                            <button class="btn btn-small btn-danger" 
                                                                    onclick="procesareAdeverinta(<%= rs2.getInt("id") %>, -1)">
                                                                <i class="fas fa-times"></i> Respinge
                                                            </button>
                                                        <% } %>
                                                    <% } %>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                <%
                                    }
                                    
                                    if (!hasAdeverinte) {
                                %>
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state">
                                                <div class="empty-state-icon">
                                                    <i class="fas fa-check-circle"></i>
                                                </div>
                                                <h3 class="empty-state-title">Nicio cerere în așteptare</h3>
                                                <p class="empty-state-description">Nu există cereri de adeverințe care necesită aprobarea dumneavoastră.</p>
                                            </div>
                                        </td>
                                    </tr>
                                <%
                                    }
                                } catch (SQLException | ClassNotFoundException e) {
                                    e.printStackTrace();
                                    out.println("<tr><td colspan='6'><div class='alert alert-danger'><i class='fas fa-exclamation-circle'></i> Eroare la interogarea bazei de date: " + e.getMessage() + "</div></td></tr>");
                                } finally {
                                    // Închiderea resurselor în ordine inversă
                                    if (rs2 != null) try { rs2.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
       <!-- Tab: Cereri procesate -->
<div id="processed-tab" class="tab-content">
    <div class="card">
        <div class="card-header">
            <h2>Cereri de adeverințe procesate</h2>
        </div>
        <div class="card-body">
            <div class="table-container">
                <table class="adeverinte-table">
                    <thead>
                        <tr>
                            <th>Angajat</th>
                            <th>Tip adeverință</th>
                            <th>Pentru a servi la</th>
                            <th>Data cererii</th>
                            <th>Data procesării</th>
                            <th>Status</th>
                            <% if (userType == 0) { %>
                            <th>Acțiuni</th>
                            <% } %>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        conn = null;
                        pstmt = null;
                        rs2 = null;
                        
                        try {
                            // Utilizăm DriverManager în loc de DBConn
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            
                            String sql = "";
                            
                            if (userType == 3) { // Șef de departament
                                // Modificare: Șeful vede cererile procesate de el (status 1 sau -1) din departamentul său
                                sql = "SELECT a.*, ta.denumire as tip_adeverinta, s.nume_status, " +
                                      "u.nume, u.prenume " +
                                      "FROM adeverinte a " +
                                      "JOIN tip_adev ta ON a.tip = ta.id " +
                                      "JOIN statusuri s ON a.status = s.status " +
                                      "JOIN useri u ON a.id_ang = u.id " +
                                      "WHERE u.id_dep = ? AND a.status IN (1, -1) " + // Modificat: adăugat status 1
                                      "ORDER BY a.modif DESC LIMIT 50";
                            } else if (userType == 0) { // Director
                                // Directorul vede toate cererile cu status final (2, -2, -1)
                                sql = "SELECT a.*, ta.denumire as tip_adeverinta, s.nume_status, " +
                                      "u.nume, u.prenume " +
                                      "FROM adeverinte a " +
                                      "JOIN tip_adev ta ON a.tip = ta.id " +
                                      "JOIN statusuri s ON a.status = s.status " +
                                      "JOIN useri u ON a.id_ang = u.id " +
                                      "WHERE a.status IN (2, -2, -1) " +
                                      "ORDER BY a.modif DESC LIMIT 50";
                            }
                            
                            pstmt = conn.prepareStatement(sql);
                            if (userType == 3) {
                                pstmt.setInt(1, userDep);
                            }
                            rs2 = pstmt.executeQuery();
                            
                            boolean hasAdeverinte = false;
                            
                            while (rs2.next()) {
                                hasAdeverinte = true;
                                String statusClass = "";
                                switch (rs2.getInt("status")) {
                                    case 2: statusClass = "status-aprobat"; break;
                                    case 1: statusClass = "status-asteptare"; break; // Pentru status 1 (aprobat de șef)
                                    case -1: case -2: statusClass = "status-respins"; break;
                                }
                        %>
                            <tr>
                                <td><%= rs2.getString("nume") %> <%= rs2.getString("prenume") %></td>
                                <td><%= rs2.getString("tip_adeverinta") %></td>
                                <td><%= rs2.getString("pentru_servi") %></td>
                                <td><%= rs2.getDate("creare") %></td>
                                <td><%= rs2.getDate("modif") != null ? rs2.getDate("modif") : "-" %></td>
                                <td class="<%= statusClass %>"><%= rs2.getString("nume_status") %></td>
                                <% if (userType == 0) { %>
                                <td>
                                    <% if (rs2.getInt("status") == 2) { %>
                                    <a href="DescarcaAdeverintaServlet?id=<%= rs2.getInt("id") %>" class="btn btn-small btn-primary">
                                        <i class="fas fa-download"></i> Descarcă
                                    </a>
                                    <% } else { %>
                                    <span>-</span>
                                    <% } %>
                                </td>
                                <% } %>
                            </tr>
                        <%
                            }
                            
                            if (!hasAdeverinte) {
                        %>
                            <tr>
                                <td colspan="<%= userType == 0 ? 7 : 6 %>">
                                    <div class="empty-state">
                                        <div class="empty-state-icon">
                                            <i class="fas fa-history"></i>
                                        </div>
                                        <h3 class="empty-state-title">Nicio cerere procesată</h3>
                                        <p class="empty-state-description">Nu există cereri de adeverințe procesate în istoric.</p>
                                    </div>
                                </td>
                            </tr>
                        <%
                            }
                        } catch (SQLException | ClassNotFoundException e) {
                            e.printStackTrace();
                            out.println("<tr><td colspan='7'><div class='alert alert-danger'><i class='fas fa-exclamation-circle'></i> Eroare la interogarea bazei de date: " + e.getMessage() + "</div></td></tr>");
                        } finally {
                            // Închiderea resurselor în ordine inversă
                            if (rs2 != null) try { rs2.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
        
    </div>
  
    <script>
        $(document).ready(function() {
            // Tab functionality
            $('.tab').on('click', function() {
                $('.tab').removeClass('active');
                $(this).addClass('active');
                
                var tabId = $(this).data('tab');
                $('.tab-content').removeClass('active');
                $('#' + tabId + '-tab').addClass('active');
            });
            
            // Check for URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('success') === 'true') {
                showAlert('success', 'Cererea a fost procesată cu succes!');
            }
            if (urlParams.get('error') === 'true') {
                showAlert('danger', 'A apărut o eroare la procesarea cererii.');
            }
        });
        
        function procesareAdeverinta(id, status) {
            const action = status > 0 ? 'aprobați' : 'respingeți';
            if (confirm('Sigur doriți să ' + action + ' această cerere?')) {
                // Adăugăm spinner pentru a indica procesarea
                const actionsCell = $(`#adeverinta-${id} .btn-group`);
                const originalContent = actionsCell.html();
                actionsCell.html('<div class="spinner"></div> Procesare...');
                
                $.ajax({
                    url: 'ProcesareAdeverintaServlet',
                    type: 'POST',
                    data: { 
                        id: id, 
                        status: status 
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response && response.success) {
                            showAlert('success', 'Cererea a fost procesată cu succes!');
                            // Eliminăm rândul din tabel
                            $(`#adeverinta-${id}`).fadeOut(300, function() {
                                $(this).remove();
                                
                                // Verificăm dacă mai există rânduri în tabel
                                if ($('#pending-table-body tr').length === 0) {
                                    $('#pending-table-body').html(`
                                        <tr>
                                            <td colspan="6">
                                                <div class="empty-state">
                                                    <div class="empty-state-icon">
                                                        <i class="fas fa-check-circle"></i>
                                                    </div>
                                                    <h3 class="empty-state-title">Nicio cerere în așteptare</h3>
                                                    <p class="empty-state-description">Nu există cereri de adeverințe care necesită aprobarea dumneavoastră.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    `);
                                }
                            });
                        } else {
                            actionsCell.html(originalContent);
                            showAlert('danger', response && response.message ? response.message : 'Eroare la procesarea cererii!');
                        }
                    },
                    error: function() {
                        actionsCell.html(originalContent);
                        showAlert('danger', 'Eroare la comunicarea cu serverul!');
                    }
                });
            }
        }
        
        function showAlert(type, message) {
            const icon = type === 'success' ? 'check-circle' : 'exclamation-circle';
            const alertHtml = `
                <div class="alert alert-${type}">
                    <i class="fas fa-${icon} alert-icon"></i>
                    <div>${message}</div>
                </div>
            `;
            
            $('#alert-container').html(alertHtml);
            
            // Ascundem alerta după 5 secunde
            setTimeout(function() {
                $('#alert-container').html('');
            }, 5000);
        }
    </script>
</body>
</html>
<%
                   
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