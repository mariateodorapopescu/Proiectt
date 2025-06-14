<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.util.Date" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    // ================ PARTEA DE AUTENTIFICARE ȘI EXTRAGERE DATE ================
    HttpSession sesi = request.getSession(false);
    
    // Verificăm dacă există sesiune activă și utilizator logat
    if (sesi == null || sesi.getAttribute("currentUser") == null) {
        out.println("<script>alert('Nu există nicio sesiune activă!');</script>");
        response.sendRedirect("login.jsp");
        return;
    }
    
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    String username = currentUser.getUsername();
    
    // Variabile pentru datele utilizatorului
    String functie = "", numeDep = "", denumireCompleta = "";
    int userId = 0, userType = 0, userDep = 0, ierarhie = 0;
    int totalTaskuri = 0, taskuriActive = 0, taskuriFinalizate = 0;
    int taskuriAsignate = 0;
    
    // Variabile pentru tema de culoare
    String accent = "#10439F", clr = "#d8d9e1", sidebar = "#ECEDFA";
    String text = "#333", card = "#ECEDFA", hover = "#ECEDFA";
    String today = "";
    
    // Variabile pentru permisiuni
    boolean isDirector = false, isSef = false, isIncepator = false;
    boolean isUtilizatorNormal = false, isAdmin = false;
    
    // Obținem acțiunea din URL
    String action = request.getParameter("action");
    if (action == null) {
        action = "view";
    }
    
    Connection connection = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        connection = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
        
        // ================ EXTRAGERE DATE UTILIZATOR ================
        String userQuery = "SELECT DISTINCT u.*, " +
                          "t.denumire AS functie, " +
                          "d.nume_dep, " +
                          "t.ierarhie as ierarhie, " +
                          "dp.denumire_completa AS denumire_completa " +
                          "FROM useri u " +
                          "JOIN tipuri t ON u.tip = t.tip " +
                          "JOIN departament d ON u.id_dep = d.id_dep " +
                          "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                          "WHERE u.username = ?";
        
        try (PreparedStatement userStmt = connection.prepareStatement(userQuery)) {
            userStmt.setString(1, username);
            ResultSet userRs = userStmt.executeQuery();
            
            if (userRs.next()) {
                userId = userRs.getInt("id");
                userType = userRs.getInt("tip");
                userDep = userRs.getInt("id_dep");
                functie = userRs.getString("functie");
                numeDep = userRs.getString("nume_dep");
                ierarhie = userRs.getInt("ierarhie");
                denumireCompleta = userRs.getString("denumire_completa");
                
                // Determinare roluri
                isDirector = (ierarhie < 3);
                isSef = (ierarhie >= 4 && ierarhie <= 5);
                isIncepator = (ierarhie >= 10);
                isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                isAdmin = "Administrator".equals(functie);
                
                // Verificare acces
                if (isAdmin) {
                    response.sendRedirect("adminok.jsp");
                    return;
                }
            }
        }
        
        // ================ EXTRAGERE DATA CURENTĂ ================
        String dateQuery = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
        try (PreparedStatement dateStmt = connection.prepareStatement(dateQuery);
             ResultSet dateRs = dateStmt.executeQuery()) {
            if (dateRs.next()) {
                today = dateRs.getString("today");
            }
        }
        
        // ================ EXTRAGERE STATISTICI TASKURI ================
        // Total taskuri vizibile pentru utilizator
        String totalQuery;
        PreparedStatement totalStmt;
        
        if (isDirector) {
            totalQuery = "SELECT COUNT(*) as total FROM tasks";
            totalStmt = connection.prepareStatement(totalQuery);
        } else if (isSef) {
            totalQuery = "SELECT COUNT(*) as total FROM tasks t " +
                        "LEFT JOIN useri u ON t.id_ang = u.id " +
                        "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                        "WHERE t.supervizor = ? OR t.id_ang = ? OR " +
                        "(u.id_dep = ? AND tu.ierarhie > ?)";
            totalStmt = connection.prepareStatement(totalQuery);
            totalStmt.setInt(1, userId);
            totalStmt.setInt(2, userId);
            totalStmt.setInt(3, userDep);
            totalStmt.setInt(4, ierarhie);
        } else {
            totalQuery = "SELECT COUNT(*) as total FROM tasks WHERE supervizor = ? OR id_ang = ?";
            totalStmt = connection.prepareStatement(totalQuery);
            totalStmt.setInt(1, userId);
            totalStmt.setInt(2, userId);
        }
        
        try (ResultSet totalRs = totalStmt.executeQuery()) {
            if (totalRs.next()) {
                totalTaskuri = totalRs.getInt("total");
            }
        }
        
        // Taskuri active (în progres)
        String activeQuery;
        PreparedStatement activeStmt;
        
        if (isDirector) {
            activeQuery = "SELECT COUNT(*) as active FROM tasks WHERE status BETWEEN 1 AND 3";
            activeStmt = connection.prepareStatement(activeQuery);
        } else if (isSef) {
            activeQuery = "SELECT COUNT(*) as active FROM tasks t " +
                         "LEFT JOIN useri u ON t.id_ang = u.id " +
                         "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                         "WHERE (t.supervizor = ? OR t.id_ang = ? OR " +
                         "(u.id_dep = ? AND tu.ierarhie > ?)) AND t.status BETWEEN 1 AND 3";
            activeStmt = connection.prepareStatement(activeQuery);
            activeStmt.setInt(1, userId);
            activeStmt.setInt(2, userId);
            activeStmt.setInt(3, userDep);
            activeStmt.setInt(4, ierarhie);
        } else {
            activeQuery = "SELECT COUNT(*) as active FROM tasks WHERE (supervizor = ? OR id_ang = ?) AND status BETWEEN 1 AND 3";
            activeStmt = connection.prepareStatement(activeQuery);
            activeStmt.setInt(1, userId);
            activeStmt.setInt(2, userId);
        }
        
        try (ResultSet activeRs = activeStmt.executeQuery()) {
            if (activeRs.next()) {
                taskuriActive = activeRs.getInt("active");
            }
        }
        
        // Taskuri finalizate
        String finalizateQuery;
        PreparedStatement finalizateStmt;
        
        if (isDirector) {
            finalizateQuery = "SELECT COUNT(*) as finalizate FROM tasks WHERE status = 4";
            finalizateStmt = connection.prepareStatement(finalizateQuery);
        } else if (isSef) {
            finalizateQuery = "SELECT COUNT(*) as finalizate FROM tasks t " +
                             "LEFT JOIN useri u ON t.id_ang = u.id " +
                             "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                             "WHERE (t.supervizor = ? OR t.id_ang = ? OR " +
                             "(u.id_dep = ? AND tu.ierarhie > ?)) AND t.status = 4";
            finalizateStmt = connection.prepareStatement(finalizateQuery);
            finalizateStmt.setInt(1, userId);
            finalizateStmt.setInt(2, userId);
            finalizateStmt.setInt(3, userDep);
            finalizateStmt.setInt(4, ierarhie);
        } else {
            finalizateQuery = "SELECT COUNT(*) as finalizate FROM tasks WHERE (supervizor = ? OR id_ang = ?) AND status = 4";
            finalizateStmt = connection.prepareStatement(finalizateQuery);
            finalizateStmt.setInt(1, userId);
            finalizateStmt.setInt(2, userId);
        }
        
        try (ResultSet finalizateRs = finalizateStmt.executeQuery()) {
            if (finalizateRs.next()) {
                taskuriFinalizate = finalizateRs.getInt("finalizate");
            }
        }
        
        // Taskuri asignate utilizatorului curent
        String asignateQuery = "SELECT COUNT(*) as asignate FROM tasks WHERE id_ang = ?";
        try (PreparedStatement asignateStmt = connection.prepareStatement(asignateQuery)) {
            asignateStmt.setInt(1, userId);
            try (ResultSet asignateRs = asignateStmt.executeQuery()) {
                if (asignateRs.next()) {
                    taskuriAsignate = asignateRs.getInt("asignate");
                }
            }
        }
        
        // ================ EXTRAGERE TEMA CULOARE ================
        String themeQuery = "SELECT * FROM teme WHERE id_usr = ?";
        try (PreparedStatement themeStmt = connection.prepareStatement(themeQuery)) {
            themeStmt.setInt(1, userId);
            ResultSet themeRs = themeStmt.executeQuery();
            
            if (themeRs.next()) {
                accent = themeRs.getString("accent");
                clr = themeRs.getString("clr");
                sidebar = themeRs.getString("sidebar");
                text = themeRs.getString("text");
                card = themeRs.getString("card");
                hover = themeRs.getString("hover");
            }
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<%!
    // Helper method pentru textul statusului
    private String getStatusText(int status) {
        switch (status) {
            case 0: return "Neînceput";
            case 1: return "În lucru";
            case 2: return "La jumătate";
            case 3: return "Aproape gata";
            case 4: return "Finalizat";
            default: return "Necunoscut";
        }
    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrare Taskuri - <%= functie %></title>
    
    <!-- Fonts & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- External Scripts -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Favicon -->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/png">
    
    <style>
        :root {
            --primary-color: <%= accent %>;
            --background-color: <%= clr %>;
            --sidebar-color: <%= sidebar %>;
            --text-color: <%= text %>;
            --card-color: <%= card %>;
            --hover-color: <%= hover %>;
            --shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            --border-radius: 16px;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            --success-color: #10B981;
            --warning-color: #F59E0B;
            --error-color: #EF4444;
            --info-color: #3B82F6;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, var(--background-color) 0%, var(--sidebar-color) 100%);
            min-height: 100vh;
            color: var(--text-color);
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        .header {
            text-align: center;
            margin-bottom: 3rem;
        }

        .header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }

        .header .subtitle {
            font-size: 1.1rem;
            opacity: 0.8;
            font-weight: 400;
        }

        /* Statistics */
        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .stat-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 2rem;
            box-shadow: var(--shadow);
            text-align: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: var(--primary-color);
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
        }

        .stat-icon {
            font-size: 2.5rem;
            color: var(--primary-color);
            margin-bottom: 1rem;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 0.5rem;
        }

        .stat-label {
            opacity: 0.7;
            font-size: 1rem;
            font-weight: 500;
        }

        /* Action Cards */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 3rem;
        }

        .action-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 2rem;
            box-shadow: var(--shadow);
            transition: var(--transition);
            text-decoration: none;
            color: var(--text-color);
            display: block;
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }

        .action-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
            color: var(--text-color);
        }

        .action-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: var(--primary-color);
            transform: scaleX(0);
            transition: var(--transition);
        }

        .action-card:hover::before {
            transform: scaleX(1);
        }

        .action-icon {
            font-size: 2.5rem;
            color: var(--primary-color);
            margin-bottom: 1rem;
        }

        .action-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .action-description {
            opacity: 0.7;
            line-height: 1.5;
            font-size: 0.95rem;
        }

        /* Forms */
        .form-container {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 2rem;
            box-shadow: var(--shadow);
            margin-bottom: 2rem;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 2px solid #e2e8f0;
            border-radius: 0.5rem;
            font-size: 1rem;
            transition: var(--transition);
            background: white;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .form-control:hover {
            border-color: #cbd5e0;
        }

        .form-control:disabled {
            background: #f8f9fa;
            cursor: not-allowed;
            opacity: 0.7;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }

        .loading-indicator {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--primary-color);
            font-size: 0.875rem;
        }

        .spinner {
            width: 16px;
            height: 16px;
            border: 2px solid #e2e8f0;
            border-top: 2px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 0.5rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.95rem;
        }

        .btn-primary {
            background: var(--primary-color);
            color: white;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }

        .btn-primary:hover {
            background: #1e40af;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
        }

        .btn-back {
            background: #6b7280;
            color: white;
            margin-top: 1rem;
        }

        .btn-back:hover {
            background: #374151;
            color: white;
        }

        /* Tables */
        .table-container {
            background: var(--card-color);
            border-radius: var(--border-radius);
            overflow: hidden;
            box-shadow: var(--shadow);
            margin-bottom: 2rem;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table th,
        .data-table td {
            padding: 1rem;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        .data-table th {
            background: var(--primary-color);
            color: white;
            font-weight: 600;
            text-align: center;
        }

        .data-table td {
            text-align: center;
        }

        .data-table tr:hover {
            background: var(--hover-color);
        }

        .table-button {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.5rem 0.75rem;
            border: none;
            border-radius: 0.375rem;
            cursor: pointer;
            font-size: 0.875rem;
            font-weight: 500;
            transition: var(--transition);
            margin: 0 0.25rem;
            text-decoration: none;
        }

        .btn-edit {
            background: var(--success-color);
            color: white;
        }

        .btn-status {
            background: var(--warning-color);
            color: white;
        }

        .btn-delete {
            background: var(--error-color);
            color: white;
        }

        .table-button:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            color: white;
        }

        /* Status badges */
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.375rem 0.75rem;
            border-radius: 2rem;
            font-size: 0.875rem;
            font-weight: 600;
            color: white;
        }

        .status-0 { background: #6b7280; }
        .status-1 { background: var(--info-color); }
        .status-2 { background: var(--warning-color); color: black; }
        .status-3 { background: #fb7185; }
        .status-4 { background: var(--success-color); }

        /* Section titles */
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-color);
            margin: 2rem 0 1rem 0;
            text-align: center;
        }

        /* Debug info */
        .debug-info {
            display: none;
            background: #f8f9fa;
            border: 1px solid #e2e8f0;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-top: 1rem;
            font-family: monospace;
            font-size: 0.875rem;
            white-space: pre-wrap;
            max-height: 200px;
            overflow-y: auto;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }

            .header h1 {
                font-size: 2rem;
            }

            .actions-grid {
                grid-template-columns: 1fr;
            }

            .quick-stats {
                grid-template-columns: repeat(2, 1fr);
            }

            .form-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .quick-stats {
                grid-template-columns: 1fr;
            }
        }

        /* Animations */
        .fade-in {
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Messages */
        .message {
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
            display: none;
        }

        .message-success {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #a7f3d0;
        }

        .message-error {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .message-info {
            background: #dbeafe;
            color: #1e40af;
            border: 1px solid #93c5fd;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header fade-in">
            <h1>Administrare Taskuri</h1>
            <p class="subtitle">Gestionați task-urile și urmăriți progresul echipei</p>
        </div>

        <!-- Messages -->
        <div id="success-message" class="message message-success"></div>
        <div id="error-message" class="message message-error"></div>
        <div id="info-message" class="message message-info"></div>

        <%
        if ("view".equals(action)) {
        %>
            <!-- Statistics -->
            <div class="quick-stats fade-in">
                <div class="stat-card">
                    <i class="ri-calendar-line stat-icon"></i>
                    <div class="stat-number"><%= today %></div>
                    <div class="stat-label">Data curentă</div>
                </div>
                <div class="stat-card">
                    <i class="ri-task-line stat-icon"></i>
                    <div class="stat-number"><%= totalTaskuri %></div>
                    <div class="stat-label">Total taskuri</div>
                </div>
                <div class="stat-card">
                    <i class="ri-play-circle-line stat-icon"></i>
                    <div class="stat-number"><%= taskuriActive %></div>
                    <div class="stat-label">În progres</div>
                </div>
                <div class="stat-card">
                    <i class="ri-checkbox-circle-line stat-icon"></i>
                    <div class="stat-number"><%= taskuriFinalizate %></div>
                    <div class="stat-label">Finalizate</div>
                </div>
                <div class="stat-card">
                    <i class="ri-user-line stat-icon"></i>
                    <div class="stat-number"><%= taskuriAsignate %></div>
                    <div class="stat-label">Asignate mie</div>
                </div>
            </div>

            <!-- Action Cards -->
            <div class="actions-grid">
                <div class="action-card fade-in" onclick="window.location.href='administrare_taskuri.jsp?action=add'">
                    <i class="ri-add-circle-line action-icon"></i>
                    <h3 class="action-title">Adaugă Task</h3>
                    <p class="action-description">
                        Creați un nou task și asignați-l membrilor echipei pentru a urmări progresul.
                    </p>
                </div>

                <div class="action-card fade-in" style="animation-delay: 0.1s" onclick="window.location.href='administrare_taskuri.jsp?action=list'">
                    <i class="ri-settings-3-line action-icon"></i>
                    <h3 class="action-title">Gestionare Taskuri</h3>
                    <p class="action-description">
                        Vizualizați, modificați și urmăriți toate task-urile din proiectele voastre.
                    </p>
                </div>
            </div>

        <%
        } else if ("add".equals(action)) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Adaugă Task Nou</h2>
                <form method="POST" action="AdaugaTaskServlet" id="addTaskForm">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="nume">
                                <i class="ri-task-line"></i> Nume task
                            </label>
                            <input type="text" id="nume" name="nume" class="form-control" 
                                   placeholder="Introduceți numele task-ului" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="id_prj">
                                <i class="ri-folder-line"></i> Proiect
                            </label>
                            <select id="id_prj" name="id_prj" class="form-control" required onchange="loadTeamMembers(this.value)">
                                <option value="">-- Selectați proiectul --</option>
                                <%
                                try {
                                    String sql = "SELECT id, nume FROM proiecte WHERE end >= CURDATE() ORDER BY nume";
                                    try (Statement stmt = connection.createStatement();
                                         ResultSet rsProiecte = stmt.executeQuery(sql)) {
                                        while (rsProiecte.next()) {
                                %>
                                    <option value="<%= rsProiecte.getInt("id") %>">
                                        <%= rsProiecte.getString("nume") %>
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
                        
                        <div class="form-group">
                            <label for="id_ang">
                                <i class="ri-user-line"></i> Asignat către
                                <span id="loading_members" class="loading-indicator" style="display: none;">
                                    <span class="spinner"></span> Se încarcă...
                                </span>
                            </label>
                            <select id="id_ang" name="id_ang" class="form-control" required>
                                <option value="">-- Selectați mai întâi un proiect --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="supervizor">
                                <i class="ri-user-star-line"></i> Supervizor
                            </label>
                            <select id="supervizor" name="supervizor" class="form-control" required>
                                <option value="<%= userId %>" selected>Eu</option>
                                <%
                                try {
                                    String sql = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                                "JOIN tipuri t ON u.tip = t.tip " +
                                                "WHERE u.id != ? AND u.tip <> 34 AND t.ierarhie <= ? " +
                                                "ORDER BY u.nume, u.prenume";
                                    try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                                        pstmt.setInt(1, userId);
                                        pstmt.setInt(2, ierarhie);
                                        try (ResultSet rsSurvizori = pstmt.executeQuery()) {
                                            while (rsSurvizori.next()) {
                                %>
                                    <option value="<%= rsSurvizori.getInt("id") %>">
                                        <%= rsSurvizori.getString("nume") %> <%= rsSurvizori.getString("prenume") %>
                                    </option>
                                <%
                                            }
                                        }
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="start">
                                <i class="ri-calendar-event-line"></i> Data început
                            </label>
                            <input type="date" id="start" name="start" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="end">
                                <i class="ri-calendar-check-line"></i> Data sfârșit
                            </label>
                            <input type="date" id="end" name="end" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="status">
                                <i class="ri-progress-line"></i> Status inițial
                            </label>
                            <select id="status" name="status" class="form-control" required>
                                <option value="0" selected>0% - Neînceput</option>
                                <option value="1">25% - În lucru</option>
                                <option value="2">50% - La jumătate</option>
                                <option value="3">75% - Aproape gata</option>
                                <option value="4">100% - Finalizat</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">
                            <i class="ri-file-text-line"></i> Descriere
                        </label>
                        <textarea id="descriere" name="descriere" class="form-control" 
                                  placeholder="Descrieți detaliile task-ului (opțional)"></textarea>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Creează Task-ul
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_taskuri.jsp" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi
                    </a>
                </div>
                
                <div id="debug-info" class="debug-info"></div>
            </div>

        <%
        } else if ("list".equals(action)) {
        %>
            <h2 class="section-title fade-in">Lista Task-urilor</h2>
            <div class="table-container fade-in">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Nr.</th>
                            <th>Nume Task</th>
                            <th>Proiect</th>
                            <th>Asignat</th>
                            <th>Status</th>
                            <th>Deadline</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            String sql;
                            PreparedStatement pstmt;
                            
                            // Construiește interogarea în funcție de rolul utilizatorului
                            if (isDirector) {
                                sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume, " +
                                      "s.procent, u.id_dep as asignat_dep, usup.id as supervizor_id, usup.nume as supervizor_nume, " +
                                      "usup.prenume as supervizor_prenume, tu.ierarhie as asignat_ierarhie " +
                                      "FROM tasks t " +
                                      "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                                      "LEFT JOIN useri u ON t.id_ang = u.id " +
                                      "LEFT JOIN useri usup ON t.supervizor = usup.id " +
                                      "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                                      "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                      "ORDER BY t.start DESC";
                                pstmt = connection.prepareStatement(sql);
                            } else if (isSef) {
                                sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume, " +
                                      "s.procent, u.id_dep as asignat_dep, usup.id as supervizor_id, usup.nume as supervizor_nume, " +
                                      "usup.prenume as supervizor_prenume, tu.ierarhie as asignat_ierarhie " +
                                      "FROM tasks t " +
                                      "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                                      "LEFT JOIN useri u ON t.id_ang = u.id " +
                                      "LEFT JOIN useri usup ON t.supervizor = usup.id " +
                                      "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                                      "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                      "WHERE t.supervizor = ? OR t.id_ang = ? OR " +
                                      "(u.id_dep = ? AND tu.ierarhie > ?) " +
                                      "ORDER BY t.start DESC";
                                pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userId);
                                pstmt.setInt(2, userId);
                                pstmt.setInt(3, userDep);
                                pstmt.setInt(4, ierarhie);
                            } else {
                                sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume, " +
                                      "s.procent, u.id_dep as asignat_dep, usup.id as supervizor_id, usup.nume as supervizor_nume, " +
                                      "usup.prenume as supervizor_prenume, tu.ierarhie as asignat_ierarhie " +
                                      "FROM tasks t " +
                                      "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                                      "LEFT JOIN useri u ON t.id_ang = u.id " +
                                      "LEFT JOIN useri usup ON t.supervizor = usup.id " +
                                      "LEFT JOIN tipuri tu ON u.tip = tu.tip " +
                                      "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                      "WHERE t.supervizor = ? OR t.id_ang = ? " +
                                      "ORDER BY t.start DESC";
                                pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userId);
                                pstmt.setInt(2, userId);
                            }
                            
                            try (ResultSet rsTasks = pstmt.executeQuery()) {
                                int counter = 1;
                                Date currentDate = new Date(System.currentTimeMillis());
                                
                                while (rsTasks.next()) {
                                    int status = rsTasks.getInt("status");
                                    int procent = rsTasks.getInt("procent");
                                    int taskId = rsTasks.getInt("id");
                                    int supervisorId = rsTasks.getInt("supervizor_id");
                                    int assignedId = rsTasks.getInt("id_ang");
                                    Date endDate = rsTasks.getDate("end");
                                    
                                    // Determină drepturile utilizatorului pentru acest task
                                    boolean isAssignee = (userId == assignedId);
                                    boolean isSupervisor = (userId == supervisorId);
                                    boolean canModify = isSupervisor || (isDirector && !isSupervisor);
                                    boolean canDelete = canModify;
                                    
                                    // Verifică dacă task-ul este în întârziere
                                    boolean isOverdue = endDate != null && endDate.before(currentDate) && status != 4;
                        %>
                            <tr>
                                <td><%= counter++ %></td>
                                <td><strong><%= rsTasks.getString("nume") %></strong></td>
                                <td><%= rsTasks.getString("proiect_nume") %></td>
                                <td><%= rsTasks.getString("asignat_nume") %> <%= rsTasks.getString("asignat_prenume") %></td>
                                <td>
                                    <span class="status-badge status-<%= status %>">
                                        <% if (status == 0) { %>
                                            <i class="ri-time-line"></i>
                                        <% } else if (status == 4) { %>
                                            <i class="ri-checkbox-circle-line"></i>
                                        <% } else { %>
                                            <i class="ri-play-circle-line"></i>
                                        <% } %>
                                        <%= procent %>% - <%= getStatusText(status) %>
                                    </span>
                                </td>
                                <td>
                                    <span style="<%= isOverdue ? "color: var(--error-color); font-weight: 600;" : "" %>">
                                        <%= endDate != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(endDate) : "N/A" %>
                                        <% if (isOverdue) { %>
                                            <i class="ri-alert-line" title="În întârziere"></i>
                                        <% } %>
                                    </span>
                                </td>
                                <td>
                                    <% if (canModify) { %>
                                        <a href="administrare_taskuri.jsp?action=edit&id=<%= taskId %>" class="table-button btn-edit" title="Modifică task-ul">
                                            <i class="ri-edit-line"></i> Editează
                                        </a>
                                    <% } %>
                                    
                                    <% if (isAssignee && !canModify) { %>
                                        <a href="administrare_taskuri.jsp?action=status&id=<%= taskId %>" class="table-button btn-status" title="Actualizează status">
                                            <i class="ri-progress-line"></i> Status
                                        </a>
                                    <% } %>
                                    
                                    <% if (canDelete) { %>
                                        <button class="table-button btn-delete" onclick="deleteTask(<%= taskId %>)" title="Șterge task-ul">
                                            <i class="ri-delete-bin-line"></i> Șterge
                                        </button>
                                    <% } %>
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
            </div>
            
            <div style="text-align: center;">
                <a href="administrare_taskuri.jsp" class="btn btn-back">
                    <i class="ri-arrow-left-line"></i> Înapoi
                </a>
            </div>

        <%
        } else if ("edit".equals(action)) {
            int idTask = Integer.parseInt(request.getParameter("id"));
            try {
                String sql = "SELECT t.*, p.nume as proiect_nume FROM tasks t " +
                           "LEFT JOIN proiecte p ON t.id_prj = p.id " + 
                           "WHERE t.id = ?";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setInt(1, idTask);
                    try (ResultSet rsTask = pstmt.executeQuery()) {
                        if (rsTask.next()) {
                            // Verifică dacă utilizatorul are drepturi de modificare completă a task-ului
                            int supervisorId = rsTask.getInt("supervizor");
                            boolean canModify = (userId == supervisorId) || (isDirector && userId != supervisorId);
                            
                            if (!canModify) {
                                response.sendRedirect("administrare_taskuri.jsp?action=status&id=" + idTask);
                                return;
                            }
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Modificare Task</h2>
                <form method="POST" action="EditTaskServlet" id="editTaskForm">
                    <input type="hidden" name="id" value="<%= idTask %>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="nume">
                                <i class="ri-task-line"></i> Nume task
                            </label>
                            <input type="text" id="nume" name="nume" class="form-control" 
                                   value="<%= rsTask.getString("nume") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="id_prj">
                                <i class="ri-folder-line"></i> Proiect
                            </label>
                            <select id="id_prj" name="id_prj" class="form-control" required onchange="loadTeamMembersEdit(this.value)">
                                <%
                                String sql2 = "SELECT id, nume FROM proiecte ORDER BY nume";
                                try (Statement stmt2 = connection.createStatement();
                                     ResultSet rs2 = stmt2.executeQuery(sql2)) {
                                    while (rs2.next()) {
                                        boolean selected = rsTask.getInt("id_prj") == rs2.getInt("id");
                                %>
                                    <option value="<%= rs2.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs2.getString("nume") %>
                                    </option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="id_ang">
                                <i class="ri-user-line"></i> Asignat către
                                <span id="loading_members_edit" class="loading-indicator" style="display: none;">
                                    <span class="spinner"></span> Se încarcă...
                                </span>
                            </label>
                            <select id="id_ang" name="id_ang" class="form-control" required>
                                <option value="<%= rsTask.getInt("id_ang") %>">Încărcare membri echipă...</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="supervizor">
                                <i class="ri-user-star-line"></i> Supervizor
                            </label>
                            <select id="supervizor" name="supervizor" class="form-control" required>
                                <%
                                String sql4 = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                            "JOIN tipuri t ON u.tip = t.tip " +
                                            "WHERE u.tip <> 34 AND t.ierarhie <= ? " +
                                            "ORDER BY u.nume, u.prenume";
                                try (PreparedStatement pstmt4 = connection.prepareStatement(sql4)) {
                                    pstmt4.setInt(1, ierarhie);
                                    try (ResultSet rs4 = pstmt4.executeQuery()) {
                                        while (rs4.next()) {
                                            boolean selected = rsTask.getInt("supervizor") == rs4.getInt("id");
                                %>
                                    <option value="<%= rs4.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs4.getString("nume") %> <%= rs4.getString("prenume") %>
                                    </option>
                                <%
                                        }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="start">
                                <i class="ri-calendar-event-line"></i> Data început
                            </label>
                            <input type="date" id="start" name="start" class="form-control" 
                                   value="<%= rsTask.getDate("start") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="end">
                                <i class="ri-calendar-check-line"></i> Data sfârșit
                            </label>
                            <input type="date" id="end" name="end" class="form-control" 
                                   value="<%= rsTask.getDate("end") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="status">
                                <i class="ri-progress-line"></i> Status
                            </label>
                            <select id="status" name="status" class="form-control" required>
                                <%
                                String sql5 = "SELECT id, procent FROM statusuri2 ORDER BY id";
                                try (Statement stmt5 = connection.createStatement();
                                     ResultSet rs5 = stmt5.executeQuery(sql5)) {
                                    while (rs5.next()) {
                                        boolean selected = rsTask.getInt("status") == rs5.getInt("id");
                                %>
                                    <option value="<%= rs5.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs5.getInt("procent") %>% - <%= getStatusText(rs5.getInt("id")) %>
                                    </option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Salvează Modificările
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_taskuri.jsp?action=list" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi la lista
                    </a>
                </div>
                
                <div id="debug-info-edit" class="debug-info"></div>
            </div>
        <%
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else if ("status".equals(action)) {
            int idTask = Integer.parseInt(request.getParameter("id"));
            try {
                String sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume " +
                           "FROM tasks t " +
                           "LEFT JOIN proiecte p ON t.id_prj = p.id " + 
                           "LEFT JOIN useri u ON t.id_ang = u.id " +
                           "WHERE t.id = ?";
                try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
                    pstmt.setInt(1, idTask);
                    try (ResultSet rsTask = pstmt.executeQuery()) {
                        if (rsTask.next()) {
                            int assignedId = rsTask.getInt("id_ang");
                            boolean isAssignee = (userId == assignedId);
                            
                            if (!isAssignee && !isDirector && userId != rsTask.getInt("supervizor")) {
                                response.sendRedirect("administrare_taskuri.jsp?action=list");
                                return;
                            }
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Actualizare Status Task</h2>
                <form method="POST" action="UpdateTaskStatusServlet" id="statusForm">
                    <input type="hidden" name="id" value="<%= idTask %>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="nume">
                                <i class="ri-task-line"></i> Nume task
                            </label>
                            <input type="text" id="nume" name="nume" class="form-control" 
                                   value="<%= rsTask.getString("nume") %>" readonly>
                        </div>
                        
                        <div class="form-group">
                            <label for="proiect">
                                <i class="ri-folder-line"></i> Proiect
                            </label>
                            <input type="text" id="proiect" name="proiect" class="form-control" 
                                   value="<%= rsTask.getString("proiect_nume") %>" readonly>
                        </div>
                        
                        <div class="form-group">
                            <label for="asignat">
                                <i class="ri-user-line"></i> Asignat către
                            </label>
                            <input type="text" id="asignat" name="asignat" class="form-control"
                                   value="<%= rsTask.getString("asignat_nume") %> <%= rsTask.getString("asignat_prenume") %>" 
                                   readonly>
                        </div>
                        
                        <div class="form-group">
                            <label for="perioada">
                                <i class="ri-calendar-line"></i> Perioada
                            </label>
                            <input type="text" id="perioada" name="perioada" class="form-control"
                                   value="<%= rsTask.getDate("start") %> - <%= rsTask.getDate("end") %>" 
                                   readonly>
                        </div>
                        
                        <div class="form-group">
                            <label for="status">
                                <i class="ri-progress-line"></i> Status
                            </label>
                            <select id="status" name="status" class="form-control" required>
                                <%
                                String sql5 = "SELECT id, procent FROM statusuri2 ORDER BY id";
                                try (Statement stmt5 = connection.createStatement();
                                     ResultSet rs5 = stmt5.executeQuery(sql5)) {
                                    while (rs5.next()) {
                                        boolean selected = rsTask.getInt("status") == rs5.getInt("id");
                                %>
                                    <option value="<%= rs5.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs5.getInt("procent") %>% - <%= getStatusText(rs5.getInt("id")) %>
                                    </option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-refresh-line"></i> Actualizează Status
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_taskuri.jsp?action=list" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi la lista
                    </a>
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
        // Funcții pentru afișarea mesajelor
        function showSuccessMessage(message) {
            const messageEl = document.getElementById('success-message');
            messageEl.textContent = message;
            messageEl.style.display = 'block';
            setTimeout(() => {
                messageEl.style.display = 'none';
            }, 5000);
        }

        function showErrorMessage(message) {
            const messageEl = document.getElementById('error-message');
            messageEl.textContent = message;
            messageEl.style.display = 'block';
            setTimeout(() => {
                messageEl.style.display = 'none';
            }, 5000);
        }

        function showInfoMessage(message) {
            const messageEl = document.getElementById('info-message');
            messageEl.textContent = message;
            messageEl.style.display = 'block';
            setTimeout(() => {
                messageEl.style.display = 'none';
            }, 5000);
        }

        // Funcție pentru debug messages
        function addDebugMessage(message, containerId = 'debug-info') {
            const debugContainer = document.getElementById(containerId);
            if (debugContainer) {
                const timestamp = new Date().toLocaleTimeString();
                const formattedMessage = `[${timestamp}] ${message}`;
                debugContainer.innerHTML += formattedMessage + '\n';
                debugContainer.style.display = 'block';
                debugContainer.scrollTop = debugContainer.scrollHeight;
                console.log(message);
            }
        }

        // Încărcare membri echipă pentru adăugare
        function loadTeamMembers(projectId) {
            if (!projectId) {
                document.getElementById('id_ang').innerHTML = '<option value="">-- Selectați mai întâi un proiect --</option>';
                return;
            }
            
            addDebugMessage(`Încărcare membri pentru proiectul ID: ${projectId}`);
            
            document.getElementById('loading_members').style.display = 'inline-flex';
            document.getElementById('id_ang').disabled = true;
            
            const userIerarhie = <%= ierarhie %>;
            
            fetch('GetTeamMembersServlet?projectId=' + projectId + '&userIerarhie=' + userIerarhie)
                .then(response => {
                    addDebugMessage(`Răspuns primit cu status: ${response.status}`);
                    return response.text();
                })
                .then(data => {
                    document.getElementById('id_ang').innerHTML = data;
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members').style.display = 'none';
                    
                    addDebugMessage(`Membri încărcați cu succes, ${document.getElementById('id_ang').options.length} opțiuni disponibile`);
                })
                .catch(error => {
                    addDebugMessage(`Eroare la încărcarea membrilor: ${error}`);
                    document.getElementById('id_ang').innerHTML = '<option value="">Eroare la încărcarea membrilor</option>';
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members').style.display = 'none';
                    showErrorMessage('Eroare la încărcarea membrilor echipei: ' + error);
                });
        }
        
        // Încărcare membri echipă pentru editare
        function loadTeamMembersEdit(projectId) {
            if (!projectId) {
                document.getElementById('id_ang').innerHTML = '<option value="">-- Selectați mai întâi un proiect --</option>';
                return;
            }
            
            addDebugMessage(`Încărcare membri pentru proiectul ID: ${projectId}`, 'debug-info-edit');
            
            document.getElementById('loading_members_edit').style.display = 'inline-flex';
            document.getElementById('id_ang').disabled = true;
            
            const currentAngId = document.getElementById('id_ang').value;
            const userIerarhie = <%= ierarhie %>;
            
            fetch('GetTeamMembersServlet?projectId=' + projectId + '&userIerarhie=' + userIerarhie)
                .then(response => {
                    addDebugMessage(`Răspuns primit cu status: ${response.status}`, 'debug-info-edit');
                    return response.text();
                })
                .then(data => {
                    document.getElementById('id_ang').innerHTML = data;
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members_edit').style.display = 'none';
                    
                    // Selectează angajatul anterior dacă există
                    if (currentAngId) {
                        const options = document.getElementById('id_ang').options;
                        for (let i = 0; i < options.length; i++) {
                            if (options[i].value === currentAngId) {
                                options[i].selected = true;
                                break;
                            }
                        }
                    }
                    
                    addDebugMessage(`Membri încărcați cu succes, ${document.getElementById('id_ang').options.length} opțiuni disponibile`, 'debug-info-edit');
                })
                .catch(error => {
                    addDebugMessage(`Eroare la încărcarea membrilor: ${error}`, 'debug-info-edit');
                    document.getElementById('id_ang').innerHTML = '<option value="">Eroare la încărcarea membrilor</option>';
                    document.getElementById('id_ang').disabled = false;
                    document.getElementById('loading_members_edit').style.display = 'none';
                    showErrorMessage('Eroare la încărcarea membrilor echipei: ' + error);
                });
        }

        // Ștergere task
        function deleteTask(idTask) {
            if (confirm('⚠️ Sigur doriți să ștergeți acest task?\n\nAceastă acțiune nu poate fi anulată!')) {
                fetch('DeleteTaskServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'id=' + idTask
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        showSuccessMessage('Task-ul a fost șters cu succes!');
                        setTimeout(() => {
                            location.reload();
                        }, 1500);
                    } else {
                        showErrorMessage(data.message || 'Eroare la ștergerea task-ului!');
                    }
                })
                .catch(error => {
                    console.error('Delete error:', error);
                    showErrorMessage('Eroare la conectarea cu serverul!');
                });
            }
        }

        // Validare formulare
        function validateForm(form) {
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    field.style.borderColor = 'var(--error-color)';
                    isValid = false;
                } else {
                    field.style.borderColor = '#e2e8f0';
                }
            });
            
            // Validare date
            const startDate = form.querySelector('#start');
            const endDate = form.querySelector('#end');
            
            if (startDate && endDate && startDate.value && endDate.value) {
                if (new Date(startDate.value) > new Date(endDate.value)) {
                    showErrorMessage('Data de început nu poate fi după data de sfârșit!');
                    endDate.style.borderColor = 'var(--error-color)';
                    isValid = false;
                }
            }
            
            return isValid;
        }

        // Event listeners pentru formulare
        document.addEventListener('DOMContentLoaded', function() {
            // Verifică dacă suntem pe pagina de editare
            const editForm = document.getElementById('editTaskForm');
            if (editForm) {
                // Încarcă membrii echipei când se încarcă pagina de editare
                const projectId = document.getElementById('id_prj').value;
                if (projectId) {
                    addDebugMessage(`Pagina de editare încărcată, încărcare automată membri pentru proiectul ID: ${projectId}`, 'debug-info-edit');
                    loadTeamMembersEdit(projectId);
                }
                
                // Validare la submit
                editForm.addEventListener('submit', function(e) {
                    if (!validateForm(this)) {
                        e.preventDefault();
                        showErrorMessage('Vă rugăm să completați toate câmpurile obligatorii!');
                    }
                });
            }
            
            // Validare pentru formularul de adăugare
            const addForm = document.getElementById('addTaskForm');
            if (addForm) {
                addDebugMessage('Pagina de adăugare task încărcată');
                
                addForm.addEventListener('submit', function(e) {
                    if (!validateForm(this)) {
                        e.preventDefault();
                        showErrorMessage('Vă rugăm să completați toate câmpurile obligatorii!');
                    }
                });
                
                // Setează data minimă la azi pentru câmpurile de dată
                const today = new Date().toISOString().split('T')[0];
                const startField = document.getElementById('start');
                const endField = document.getElementById('end');
                
                if (startField) {
                    startField.min = today;
                    startField.addEventListener('change', function() {
                        if (endField) {
                            endField.min = this.value;
                        }
                    });
                }
                
                if (endField) {
                    endField.min = today;
                }
            }
            
            // Validare pentru formularul de status
            const statusForm = document.getElementById('statusForm');
            if (statusForm) {
                statusForm.addEventListener('submit', function(e) {
                    const statusField = document.getElementById('status');
                    if (!statusField.value) {
                        e.preventDefault();
                        showErrorMessage('Vă rugăm să selectați un status!');
                        statusField.style.borderColor = 'var(--error-color)';
                    }
                });
            }
            
            // Animații pentru cardurile de acțiuni
            const actionCards = document.querySelectorAll('.action-card');
            actionCards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
            });
            
            // Animații pentru cardurile de statistici
            const statCards = document.querySelectorAll('.stat-card');
            statCards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.05}s`;
            });
            
            // Tooltip pentru butoanele de acțiuni din tabel
            const tableButtons = document.querySelectorAll('.table-button');
            tableButtons.forEach(button => {
                button.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px) scale(1.05)';
                });
                
                button.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0) scale(1)';
                });
            });
            
            // Evidențiere rânduri în tabel la hover
            const tableRows = document.querySelectorAll('.data-table tbody tr');
            tableRows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.01)';
                    this.style.transition = 'all 0.2s ease';
                });
                
                row.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                });
            });
            
            // Auto-hide pentru mesaje
            setTimeout(() => {
                const messages = document.querySelectorAll('.message');
                messages.forEach(message => {
                    if (message.style.display === 'block') {
                        message.style.opacity = '0';
                        setTimeout(() => {
                            message.style.display = 'none';
                            message.style.opacity = '1';
                        }, 300);
                    }
                });
            }, 5000);
        });

        // Funcție pentru a seta focus pe primul câmp din formular
        function focusFirstField() {
            const firstInput = document.querySelector('.form-control:not([readonly]):not([disabled])');
            if (firstInput) {
                firstInput.focus();
            }
        }
        
        // Apelează la încărcarea paginii dacă este un formular
        window.addEventListener('load', function() {
            if (document.querySelector('.form-container')) {
                setTimeout(focusFirstField, 100);
            }
        });

        // Funcție pentru a salva progresul în sessionStorage (pentru cazul în care utilizatorul navighează greșit)
        function saveFormProgress() {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                const formData = new FormData(form);
                const formObject = {};
                formData.forEach((value, key) => {
                    formObject[key] = value;
                });
                sessionStorage.setItem('formData_' + form.id, JSON.stringify(formObject));
            });
        }

        // Funcție pentru a restaura progresul din sessionStorage
        function restoreFormProgress() {
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                const savedData = sessionStorage.getItem('formData_' + form.id);
                if (savedData) {
                    const formObject = JSON.parse(savedData);
                    Object.keys(formObject).forEach(key => {
                        const field = form.querySelector(`[name="${key}"]`);
                        if (field && field.type !== 'hidden') {
                            field.value = formObject[key];
                        }
                    });
                    // Șterge datele salvate după restaurare
                    sessionStorage.removeItem('formData_' + form.id);
                }
            });
        }

        // Event listeners pentru salvarea progresului
        document.addEventListener('input', function(e) {
            if (e.target.matches('.form-control')) {
                saveFormProgress();
            }
        });

        // Restaurează progresul la încărcarea paginii
        window.addEventListener('load', function() {
            restoreFormProgress();
        });

        // Confirmări pentru acțiuni importante
        function confirmAction(message, callback) {
            if (confirm(message)) {
                callback();
            }
        }

        // Funcție pentru export de date (dacă este necesar în viitor)
        function exportTaskData() {
            showInfoMessage('Funcționalitatea de export va fi implementată în curând!');
        }

        // Funcție pentru filtrarea tabelului (dacă este necesar)
        function filterTable(searchTerm) {
            const table = document.querySelector('.data-table tbody');
            if (!table) return;
            
            const rows = table.querySelectorAll('tr');
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(searchTerm.toLowerCase())) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            // Ctrl+S pentru salvare rapidă
            if (e.ctrlKey && e.key === 's') {
                e.preventDefault();
                const submitButton = document.querySelector('.btn-primary');
                if (submitButton) {
                    submitButton.click();
                }
            }
            
            // Escape pentru a reveni la pagina principală
            if (e.key === 'Escape') {
                const backButton = document.querySelector('.btn-back');
                if (backButton) {
                    window.location.href = backButton.href;
                }
            }
        });

        // Verificare conectivitate pentru funcțiile AJAX
        function checkConnectivity() {
            return navigator.onLine;
        }

        // Retry mechanism pentru cererile AJAX
        function retryRequest(requestFunction, maxRetries = 3) {
            let retries = 0;
            
            function attempt() {
                requestFunction()
                    .catch(error => {
                        retries++;
                        if (retries < maxRetries && checkConnectivity()) {
                            showInfoMessage(`Reîncerc cererea (${retries}/${maxRetries})...`);
                            setTimeout(attempt, 1000 * retries);
                        } else {
                            throw error;
                        }
                    });
            }
            
            attempt();
        }

        // Funcție pentru a detecta modificările nesalvate
        let formChanged = false;
        
        document.addEventListener('input', function(e) {
            if (e.target.matches('.form-control') && !e.target.readOnly) {
                formChanged = true;
            }
        });

        window.addEventListener('beforeunload', function(e) {
            if (formChanged) {
                e.preventDefault();
                e.returnValue = 'Aveți modificări nesalvate. Sigur doriți să părăsiți pagina?';
            }
        });

        // Resetează flag-ul la submit
        document.addEventListener('submit', function() {
            formChanged = false;
        });

        console.log('🚀 Administrare Taskuri - System Ready!');
        console.log('📊 Debug info disponibil în containerele debug');
        console.log('⌨️ Keyboard shortcuts: Ctrl+S (save), Escape (back)');
    </script>
    
    <!-- Script pentru încărcarea CSS-ului core2.css dacă există -->
    <script>
        // Încearcă să încarce CSS-ul existent dacă este disponibil
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'css/core2.css';
        link.onerror = function() {
            console.log('core2.css not found, using embedded styles');
        };
        document.head.appendChild(link);
    </script>
</body>
</html>

<%
    // Închide conexiunea la sfârșitul paginii
    if (connection != null) {
        try {
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>