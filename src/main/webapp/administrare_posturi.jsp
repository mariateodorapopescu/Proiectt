<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<%
    // ================ PARTEA DE AUTENTIFICARE ȘI EXTRAGERE DATE ================
    HttpSession sesi = request.getSession(false);
    
    // Verificăm dacă există sesiune activă și utilizator logat
    if (sesi == null || sesi.getAttribute("currentUser") == null) {
        out.println("<script>alert('Nu există nicio sesiune activă!');</script>");
        response.sendRedirect("logout");
        return;
    }
    
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    String username = currentUser.getUsername();
    
    // Variabile pentru datele utilizatorului
    String functie = "", numeDep = "", denumireCompleta = "";
    int id = 0, userType = 0, userdep = 0, ierarhie = 0;
    int totalPosturi = 0, posturiActive = 0, posturiExpire = 0;
    int aplicariPendinte = 0;
    
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
    
    try (Connection connection = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
        
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
                id = userRs.getInt("id");
                userType = userRs.getInt("tip");
                userdep = userRs.getInt("id_dep");
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
        
        // ================ EXTRAGERE STATISTICI POSTURI ================
        // Total posturi
        String totalQuery = "SELECT COUNT(*) as total FROM joburi";
        try (PreparedStatement totalStmt = connection.prepareStatement(totalQuery);
             ResultSet totalRs = totalStmt.executeQuery()) {
            if (totalRs.next()) {
                totalPosturi = totalRs.getInt("total");
            }
        }
        
        // Posturi active
        String activeQuery = "SELECT COUNT(*) as active FROM joburi WHERE activ = 1";
        try (PreparedStatement activeStmt = connection.prepareStatement(activeQuery);
             ResultSet activeRs = activeStmt.executeQuery()) {
            if (activeRs.next()) {
                posturiActive = activeRs.getInt("active");
            }
        }
        
        // Posturi care expiră în 30 de zile
        String expireQuery = "SELECT COUNT(*) as expire FROM joburi WHERE activ = 1 AND end <= DATE_ADD(CURDATE(), INTERVAL 30 DAY)";
        try (PreparedStatement expireStmt = connection.prepareStatement(expireQuery);
             ResultSet expireRs = expireStmt.executeQuery()) {
            if (expireRs.next()) {
                posturiExpire = expireRs.getInt("expire");
            }
        }
        
        // Aplicări în așteptare (assumând că există un tabel aplicari)
        String aplicariQuery = "SELECT COUNT(*) as pending FROM aplicari a JOIN joburi j ON a.job_id = j.id WHERE j.activ = 1";
        try (PreparedStatement aplicariStmt = connection.prepareStatement(aplicariQuery);
             ResultSet aplicariRs = aplicariStmt.executeQuery()) {
            if (aplicariRs.next()) {
                aplicariPendinte = aplicariRs.getInt("pending");
            }
        } catch (SQLException e) {
            // Dacă tabelul aplicari nu există, setăm 0
            aplicariPendinte = 0;
        }
        
        // ================ EXTRAGERE TEMA CULOARE ================
        if (isAdmin || isDirector) {
            String themeQuery = "SELECT * FROM teme WHERE id_usr = ?";
            try (PreparedStatement themeStmt = connection.prepareStatement(themeQuery)) {
                themeStmt.setInt(1, id);
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
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrare Posturi - <%= functie %></title>
    
    <!-- Fonts & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/remixicons@3.5.0/fonts/remixicon.css" rel="stylesheet">
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
            
            transition: var(--transition);
            text-decoration: none;
            color: var(--text-color);
            display: block;
            position: relative;
            overflow: hidden;
        }

        .action-card:hover {
            transform: translateY(-4px);
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
            
        }

        .form-control:hover {
            border-color: #cbd5e0;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
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
            
        }

        .btn-primary:hover {
            background: #1e40af;
            transform: translateY(-2px);
            
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
        }

        .btn-edit {
            background: var(--success-color);
            color: white;
        }

        .btn-delete {
            background: var(--error-color);
            color: white;
        }

        .table-button:hover {
            transform: translateY(-1px);
            
        }

        /* Status indicators */
        .status-active {
            color: var(--success-color);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.25rem;
            justify-content: center;
        }

        .status-inactive {
            color: var(--error-color);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.25rem;
            justify-content: center;
        }

        .status-expiring {
            color: var(--warning-color);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.25rem;
            justify-content: center;
        }

        /* Section titles */
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-color);
            margin: 2rem 0 1rem 0;
            text-align: center;
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
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header fade-in">
            <h1>Administrare Posturi</h1>
            <p class="subtitle">Gestionați posturile de angajare și procesul de recrutare</p>
        </div>

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
                    <i class="ri-briefcase-line stat-icon"></i>
                    <div class="stat-number"><%= totalPosturi %></div>
                    <div class="stat-label">Total posturi</div>
                </div>
                <div class="stat-card">
                    <i class="ri-play-circle-line stat-icon"></i>
                    <div class="stat-number"><%= posturiActive %></div>
                    <div class="stat-label">Posturi active</div>
                </div>
                <div class="stat-card">
                    <i class="ri-time-line stat-icon"></i>
                    <div class="stat-number"><%= posturiExpire %></div>
                    <div class="stat-label">Expiră în 30 zile</div>
                </div>
            </div>

            <!-- Action Cards -->
            <div class="actions-grid">
                <a href="administrare_posturi.jsp?action=add" class="action-card fade-in">
                    <i class="ri-add-circle-line action-icon"></i>
                    <h3 class="action-title">Adaugă Post</h3>
                    <p class="action-description">
                        Creați un nou post de angajare cu toate detaliile necesare pentru candidați.
                    </p>
                </a>

                <a href="administrare_posturi.jsp?action=list" class="action-card fade-in" style="animation-delay: 0.1s">
                    <i class="ri-settings-3-line action-icon"></i>
                    <h3 class="action-title">Gestionare Posturi</h3>
                    <p class="action-description">
                        Vizualizați, modificați și gestionați toate posturile de angajare existente.
                    </p>
                </a>
            </div>

        <%
        } else if ("add".equals(action)) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Adaugă Post de Angajare</h2>
                <form method="POST" action="AdaugaPostServlet">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="titlu">
                                <i class="ri-briefcase-line"></i> Titlu post
                            </label>
                            <input type="text" id="titlu" name="titlu" class="form-control" 
                                   placeholder="Ex: Dezvoltator Software Senior" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="departament">
                                <i class="ri-building-line"></i> Departament
                            </label>
                            <select id="departament" name="departament" class="form-control" required>
                                <option value="">-- Selectați departamentul --</option>
                                <%
                                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                    String sql = "SELECT id_dep, nume_dep FROM departament ORDER BY nume_dep";
                                    try (Statement stmt = conn.createStatement();
                                         ResultSet rs = stmt.executeQuery(sql)) {
                                        while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("id_dep") %>">
                                        <%= rs.getString("nume_dep") %>
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
                            <label for="pozitie">
                                <i class="ri-user-star-line"></i> Poziție
                            </label>
                            <select id="pozitie" name="pozitie" class="form-control" required>
                                <option value="">-- Selectați poziția --</option>
                                <%
                                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                    String sql = "SELECT tip, denumire FROM tipuri ORDER BY denumire";
                                    try (Statement stmt = conn.createStatement();
                                         ResultSet rs = stmt.executeQuery(sql)) {
                                        while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("tip") %>">
                                        <%= rs.getString("denumire") %>
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
                            <label for="dom">
                                <i class="ri-bookmark-line"></i> Domeniu
                            </label>
                            <input type="text" id="dom" name="dom" class="form-control" 
                                   placeholder="Ex: Tehnologie, Marketing, Vânzări" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="subdom">
                                <i class="ri-bookmark-2-line"></i> Subdomeniu
                            </label>
                            <input type="text" id="subdom" name="subdom" class="form-control" 
                                   placeholder="Ex: Dezvoltare Web, SEO, B2B">
                        </div>
                        
                        <div class="form-group">
                            <label for="ore">
                                <i class="ri-time-line"></i> Ore pe săptămână
                            </label>
                            <input type="number" id="ore" name="ore" class="form-control" 
                                   min="1" max="40" placeholder="Ex: 40" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tip">
                                <i class="ri-calendar-check-line"></i> Tip program
                            </label>
                            <select id="tip" name="tip" class="form-control" required>
                                <option value="1">Full-time</option>
                                <option value="0">Part-time</option>
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
                    </div>
                    
                    <!-- Textarea fields -->
                    <div class="form-group">
                        <label for="req">
                            <i class="ri-list-check-line"></i> Cerințe
                        </label>
                        <textarea id="req" name="req" class="form-control" 
                                  placeholder="Descrieți cerințele pentru această poziție..." required></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="resp">
                            <i class="ri-clipboard-line"></i> Responsabilități
                        </label>
                        <textarea id="resp" name="resp" class="form-control" 
                                  placeholder="Descrieți responsabilitățile pentru această poziție..." required></textarea>
                    </div>
                    
                    <!-- Location fields -->
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="judet">
                                <i class="ri-map-line"></i> Județ
                            </label>
                            <select id="judet" name="judet" class="form-control" required onchange="loadLocalitati()">
                                <option value="">-- Selectați județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="localitate">
                                <i class="ri-map-pin-line"></i> Localitate
                            </label>
                            <select id="localitate" name="localitate" class="form-control" required disabled>
                                <option value="">-- Selectați mai întâi județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="strada">
                                <i class="ri-road-map-line"></i> Adresă
                            </label>
                            <input type="text" id="strada" name="strada" class="form-control" 
                                   placeholder="Strada, numărul, etc." required>
                        </div>
                        
                        <div class="form-group">
                            <label for="keywords">
                                <i class="ri-hashtag"></i> Cuvinte cheie
                            </label>
                            <input type="text" id="keywords" name="keywords" class="form-control" 
                                   placeholder="Separate prin virgulă">
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Creează Postul
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_posturi.jsp" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi
                    </a>
                </div>
            </div>

        <%
        } else if ("list".equals(action)) {
        %>
            <h2 class="section-title fade-in">Lista Posturilor de Angajare</h2>
            <div class="table-container fade-in">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Nr.</th>
                            <th>Titlu Post</th>
                            <th>Departament</th>
                            <th>Program</th>
                            <th>Status</th>
                            <th>Expiră</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String sql = "SELECT j.*, d.nume_dep, t.denumire as pozitie_nume " +
                                       "FROM joburi j " +
                                       "JOIN departament d ON j.departament = d.id_dep " +
                                       "JOIN tipuri t ON j.pozitie = t.tip " +
                                       "ORDER BY j.titlu";
                            try (Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(sql)) {
                                
                                int counter = 1;
                                java.util.Date currentDate = new java.util.Date();
                                
                                while (rs.next()) {
                                    boolean isActiv = rs.getBoolean("activ");
                                    boolean isFullTime = rs.getBoolean("tip");
                                    java.sql.Date endDateSql = rs.getDate("end");
                                    
                                    // Calculăm dacă postul expiră în curând
                                    boolean isExpiring = false;
                                    if (endDateSql != null && isActiv) {
                                        java.util.Date endDate = new java.util.Date(endDateSql.getTime());
                                        long diffTime = endDate.getTime() - currentDate.getTime();
                                        long diffDays = diffTime / (1000 * 60 * 60 * 24);
                                        isExpiring = diffDays <= 30 && diffDays > 0;
                                    }
                        %>
                            <tr>
                                <td><%= counter++ %></td>
                                <td><strong><%= rs.getString("titlu") %></strong></td>
                                <td><%= rs.getString("nume_dep") %></td>
                                <td>
                                    <span style="background: <%= isFullTime ? "#10b981" : "#f59e0b" %>; color: white; padding: 0.25rem 0.5rem; border-radius: 0.25rem; font-size: 0.875rem;">
                                        <%= isFullTime ? "Full-time" : "Part-time" %>
                                    </span>
                                </td>
                                <td>
                                    <% if (!isActiv) { %>
                                        <span class="status-inactive">
                                            <i class="ri-close-circle-line"></i> Inactiv
                                        </span>
                                    <% } else if (isExpiring) { %>
                                        <span class="status-expiring">
                                            <i class="ri-time-line"></i> Expiră curând
                                        </span>
                                    <% } else { %>
                                        <span class="status-active">
                                            <i class="ri-checkbox-circle-line"></i> Activ
                                        </span>
                                    <% } %>
                                </td>
                                <td>
                                    <%= endDateSql != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(endDateSql) : "N/A" %>
                                </td>
                                <td>
                                    <button class="table-button btn-edit" 
                                            onclick="window.location.href='administrare_posturi.jsp?action=edit&id=<%= rs.getInt("id") %>'"
                                            title="Modifică postul">
                                        <i class="ri-edit-line"></i> Editează
                                    </button>
                                    <button class="table-button btn-delete" 
                                            onclick="deletePost(<%= rs.getInt("id") %>)"
                                            title="Șterge postul">
                                        <i class="ri-delete-bin-line"></i> Șterge
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
            </div>
            
            <div style="text-align: center;">
                <a href="administrare_posturi.jsp" class="btn btn-back">
                    <i class="ri-arrow-left-line"></i> Înapoi
                </a>
            </div>

        <%
        } else if ("edit".equals(action)) {
            int idPost = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                String sql = "SELECT j.*, l.strada, l.oras as localitate, l.judet " +
                           "FROM joburi j " +
                           "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                           "WHERE j.id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idPost);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            String judet = rs.getString("judet");
                            String localitate = rs.getString("localitate");
                            String strada = rs.getString("strada");
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Modificare Post de Angajare</h2>
                <form method="POST" action="EditPostServlet">
                    <input type="hidden" name="id" value="<%= idPost %>">
                    
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="titlu">
                                <i class="ri-briefcase-line"></i> Titlu post
                            </label>
                            <input type="text" id="titlu" name="titlu" class="form-control" 
                                   value="<%= rs.getString("titlu") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="departament">
                                <i class="ri-building-line"></i> Departament
                            </label>
                            <select id="departament" name="departament" class="form-control" required>
                                <%
                                String sql2 = "SELECT id_dep, nume_dep FROM departament ORDER BY nume_dep";
                                try (Statement stmt2 = conn.createStatement();
                                     ResultSet rs2 = stmt2.executeQuery(sql2)) {
                                    while (rs2.next()) {
                                        boolean selected = rs.getInt("departament") == rs2.getInt("id_dep");
                                %>
                                    <option value="<%= rs2.getInt("id_dep") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs2.getString("nume_dep") %>
                                    </option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="pozitie">
                                <i class="ri-user-star-line"></i> Poziție
                            </label>
                            <select id="pozitie" name="pozitie" class="form-control" required>
                                <%
                                String sql3 = "SELECT tip, denumire FROM tipuri ORDER BY denumire";
                                try (Statement stmt3 = conn.createStatement();
                                     ResultSet rs3 = stmt3.executeQuery(sql3)) {
                                    while (rs3.next()) {
                                        boolean selected = rs.getInt("pozitie") == rs3.getInt("tip");
                                %>
                                    <option value="<%= rs3.getInt("tip") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs3.getString("denumire") %>
                                    </option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="dom">
                                <i class="ri-bookmark-line"></i> Domeniu
                            </label>
                            <input type="text" id="dom" name="dom" class="form-control" 
                                   value="<%= rs.getString("dom") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="subdom">
                                <i class="ri-bookmark-2-line"></i> Subdomeniu
                            </label>
                            <input type="text" id="subdom" name="subdom" class="form-control" 
                                   value="<%= rs.getString("subdom") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="ore">
                                <i class="ri-time-line"></i> Ore pe săptămână
                            </label>
                            <input type="number" id="ore" name="ore" class="form-control" 
                                   value="<%= rs.getInt("ore") %>" min="1" max="40" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tip">
                                <i class="ri-calendar-check-line"></i> Tip program
                            </label>
                            <select id="tip" name="tip" class="form-control" required>
                                <option value="1" <%= rs.getBoolean("tip") ? "selected" : "" %>>Full-time</option>
                                <option value="0" <%= !rs.getBoolean("tip") ? "selected" : "" %>>Part-time</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="activ">
                                <i class="ri-toggle-line"></i> Status
                            </label>
                            <select id="activ" name="activ" class="form-control" required>
                                <option value="1" <%= rs.getBoolean("activ") ? "selected" : "" %>>Activ</option>
                                <option value="0" <%= !rs.getBoolean("activ") ? "selected" : "" %>>Inactiv</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="start">
                                <i class="ri-calendar-event-line"></i> Data început
                            </label>
                            <input type="date" id="start" name="start" class="form-control" 
                                   value="<%= rs.getDate("start") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="end">
                                <i class="ri-calendar-check-line"></i> Data sfârșit
                            </label>
                            <input type="date" id="end" name="end" class="form-control" 
                                   value="<%= rs.getDate("end") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="keywords">
                                <i class="ri-hashtag"></i> Cuvinte cheie
                            </label>
                            <input type="text" id="keywords" name="keywords" class="form-control" 
                                   value="<%= rs.getString("keywords") %>" placeholder="Separate prin virgulă">
                        </div>
                    </div>
                    
                    <!-- Textarea fields -->
                    <div class="form-group">
                        <label for="req">
                            <i class="ri-list-check-line"></i> Cerințe
                        </label>
                        <textarea id="req" name="req" class="form-control" required><%= rs.getString("req") %></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="resp">
                            <i class="ri-clipboard-line"></i> Responsabilități
                        </label>
                        <textarea id="resp" name="resp" class="form-control" required><%= rs.getString("resp") %></textarea>
                    </div>
                    
                    <!-- Location fields pentru modificare -->
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="judet">
                                <i class="ri-map-line"></i> Județ
                            </label>
                            <select id="judet" name="judet" class="form-control" required onchange="loadLocalitati()">
                                <option value="">-- Selectați județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="localitate">
                                <i class="ri-map-pin-line"></i> Localitate
                            </label>
                            <select id="localitate" name="localitate" class="form-control" required>
                                <option value="">-- Selectați mai întâi județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="strada">
                                <i class="ri-road-map-line"></i> Adresă
                            </label>
                            <input type="text" id="strada" name="strada" class="form-control" 
                                   value="<%= strada != null ? strada : "" %>" required>
                        </div>
                    </div>
                    
                    <input type="hidden" id="currentJudet" value="<%= judet != null ? judet : "" %>">
                    <input type="hidden" id="currentLocalitate" value="<%= localitate != null ? localitate : "" %>">
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Salvează Modificările
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_posturi.jsp?action=list" class="btn btn-back">
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
        // Încărcare județe și localități
        $(document).ready(function() {
            loadJudete();
        });

        function loadJudete() {
            $.ajax({
                url: 'JudeteProxyServlet',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    const judetSelect = document.getElementById('judet');
                    
                    // Sortare județe alfabetic
                    data.sort(function(a, b) {
                        return a.nume.localeCompare(b.nume);
                    });
                    
                    // Adăugare opțiuni județe
                    $.each(data, function(index, judet) {
                        const option = document.createElement('option');
                        option.value = judet.auto;
                        option.textContent = judet.nume;
                        judetSelect.appendChild(option);
                    });
                    
                    // Selectare județ curent pentru editare
                    const currentJudet = document.getElementById('currentJudet');
                    if (currentJudet && currentJudet.value) {
                        const judetOptions = Array.from(judetSelect.options);
                        for (let i = 0; i < judetOptions.length; i++) {
                            const opt = judetOptions[i];
                            if (opt.textContent.toLowerCase() === currentJudet.value.toLowerCase()) {
                                opt.selected = true;
                                loadLocalitati(true);
                                break;
                            }
                        }
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('Error loading counties:', textStatus, errorThrown);
                    showErrorMessage('Eroare la încărcarea județelor! ' + errorThrown);
                }
            });
        }

        function loadLocalitati(isEdit) {
            const judetSelect = document.getElementById('judet');
            const localitateSelect = document.getElementById('localitate');
            
            localitateSelect.innerHTML = '<option value="">-- Selectați localitatea --</option>';
            
            if (judetSelect.value === '') {
                localitateSelect.disabled = true;
                return;
            }
            
            localitateSelect.disabled = false;
            
            $.ajax({
                url: 'LocalitatiProxyServlet',
                type: 'GET',
                data: { judet: judetSelect.value },
                dataType: 'json',
                success: function(data) {
                    data.sort(function(a, b) {
                        return a.nume.localeCompare(b.nume);
                    });
                    
                    $.each(data, function(index, localitate) {
                        const option = document.createElement('option');
                        option.value = localitate.nume;
                        option.textContent = localitate.nume;
                        localitateSelect.appendChild(option);
                    });
                    
                    // Selectare localitatea curentă pentru editare
                    if (isEdit) {
                        const currentLocalitate = document.getElementById('currentLocalitate');
                        if (currentLocalitate && currentLocalitate.value) {
                            const localitateOptions = Array.from(localitateSelect.options);
                            for (let i = 0; i < localitateOptions.length; i++) {
                                const opt = localitateOptions[i];
                                if (opt.textContent.toLowerCase() === currentLocalitate.value.toLowerCase()) {
                                    opt.selected = true;
                                    break;
                                }
                            }
                        }
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('Error loading localities:', textStatus, errorThrown);
                    localitateSelect.disabled = true;
                    showErrorMessage('Eroare la încărcarea localităților! ' + errorThrown);
                }
            });
        }

        function deletePost(id) {
            if (confirm('⚠️ Sigur doriți să ștergeți acest post?\n\nAceastă acțiune nu poate fi anulată!')) {
                $.ajax({
                    url: 'DeletePostServlet',
                    type: 'POST',
                    data: { id: id },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showSuccessMessage('Postul a fost șters cu succes!');
                            setTimeout(() => {
                                window.location.reload();
                            }, 1500);
                        } else {
                            showErrorMessage(response.message || 'Eroare la ștergerea postului!');
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Error deleting post:', textStatus, errorThrown);
                        showErrorMessage('Eroare la conectarea cu serverul: ' + textStatus);
                    }
                });
            }
        }

        // Funcții pentru mesaje
        function showSuccessMessage(message) {
            const alert = document.createElement('div');
            alert.innerHTML = `
                <div style="position: fixed; top: 20px; right: 20px; z-index: 1000; 
                           background: var(--success-color); color: white; padding: 1rem 1.5rem; 
                           border-radius: 0.5rem; 
                           display: flex; align-items: center; gap: 0.5rem;">
                    <i class="ri-checkbox-circle-line"></i>
                    ${message}
                </div>
            `;
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 3000);
        }
        
        function showErrorMessage(message) {
            const alert = document.createElement('div');
            alert.innerHTML = `
                <div style="position: fixed; top: 20px; right: 20px; z-index: 1000; 
                           background: var(--error-color); color: white; padding: 1rem 1.5rem; 
                           border-radius: 0.5rem;  
                           display: flex; align-items: center; gap: 0.5rem;">
                    <i class="ri-error-warning-line"></i>
                    ${message}
                </div>
            `;
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 4000);
        }

        // Validare formular
        document.addEventListener('DOMContentLoaded', function() {
            // Validare date
            const startDate = document.getElementById('start');
            const endDate = document.getElementById('end');
            
            if (startDate && endDate) {
                function validateDates() {
                    if (startDate.value && endDate.value) {
                        if (new Date(startDate.value) >= new Date(endDate.value)) {
                            endDate.setCustomValidity('Data de sfârșit trebuie să fie după data de început');
                        } else {
                            endDate.setCustomValidity('');
                        }
                    }
                }
                
                startDate.addEventListener('change', validateDates);
                endDate.addEventListener('change', validateDates);
            }
            
            // Efecte ripple pentru carduri și butoane
            document.querySelectorAll('.action-card, .btn').forEach(element => {
                element.addEventListener('click', function(e) {
                    const ripple = document.createElement('div');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    
                    ripple.style.width = ripple.style.height = size + 'px';
                    ripple.style.left = e.clientX - rect.left - size / 2 + 'px';
                    ripple.style.top = e.clientY - rect.top - size / 2 + 'px';
                    ripple.style.position = 'absolute';
                    ripple.style.borderRadius = '50%';
                    ripple.style.background = 'rgba(255, 255, 255, 0.3)';
                    ripple.style.transform = 'scale(0)';
                    ripple.style.animation = 'ripple 0.6s linear';
                    ripple.style.pointerEvents = 'none';
                    
                    this.appendChild(ripple);
                    
                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });
        });
        
        // CSS pentru efectul ripple
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
    <script>
        // ================ FUNCȚII PENTRU LOCAȚII ================
        
        // Încărcare județe și localități cu păstrarea datelor în edit
        $(document).ready(function() {
            loadJudete();
            
            // Debug pentru modul edit
            const currentJudet = document.getElementById('currentJudet');
            const currentLocalitate = document.getElementById('currentLocalitate');
            
            if (currentJudet && currentLocalitate) {
                console.log('🏠 Edit mode detected - Location data:');
                console.log('   Județ salvat:', currentJudet.value);
                console.log('   Localitate salvată:', currentLocalitate.value);
            }
        });

        function loadJudete() {
            console.log('🌍 Loading județe...');
            
            $.ajax({
                url: 'JudeteProxyServlet',
                type: 'GET',
                dataType: 'json',
                success: function(data) {
                    const judetSelect = document.getElementById('judet');
                    
                    if (!judetSelect) {
                        console.error('❌ Element #judet not found');
                        return;
                    }
                    
                    // Clear și adaugă opțiunea default
                    judetSelect.innerHTML = '<option value="">-- Selectați județul --</option>';
                    
                    // Sortare județe alfabetic
                    data.sort(function(a, b) {
                        return a.nume.localeCompare(b.nume);
                    });
                    
                    // Adăugare opțiuni județe
                    $.each(data, function(index, judet) {
                        const option = document.createElement('option');
                        option.value = judet.auto;
                        option.textContent = judet.nume;
                        judetSelect.appendChild(option);
                    });
                    
                    console.log('✅ Județe încărcate:', data.length);
                    
                    // Pentru modul edit - selectează județul salvat
                    const currentJudet = document.getElementById('currentJudet');
                    if (currentJudet && currentJudet.value.trim()) {
                        console.log('🔍 Searching for saved județ:', currentJudet.value);
                        
                        // Caută județul în lista de opțiuni
                        const judetOptions = Array.from(judetSelect.options);
                        let found = false;
                        
                        for (let i = 0; i < judetOptions.length; i++) {
                            const opt = judetOptions[i];
                            const optText = opt.textContent.toLowerCase().trim();
                            const savedText = currentJudet.value.toLowerCase().trim();
                            
                            if (optText === savedText || 
                                optText.includes(savedText) || 
                                savedText.includes(optText)) {
                                opt.selected = true;
                                found = true;
                                console.log('✅ Județ găsit și selectat:', opt.textContent);
                                
                                // Încarcă localitățile pentru acest județ
                                setTimeout(() => {
                                    loadLocalitati(true);
                                }, 100);
                                break;
                            }
                        }
                        
                        if (!found) {
                            console.warn('⚠️ Județ salvat nu a fost găsit:', currentJudet.value);
                            // Încercăm să adăugăm manual județul
                            const option = document.createElement('option');
                            option.value = 'MANUAL';
                            option.textContent = currentJudet.value;
                            option.selected = true;
                            judetSelect.appendChild(option);
                            console.log('📝 Județ adăugat manual:', currentJudet.value);
                        }
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('❌ Error loading județe:', textStatus, errorThrown);
                    showErrorMessage('Eroare la încărcarea județelor! ' + errorThrown);
                }
            });
        }

        function loadLocalitati(isEditMode = false) {
            const judetSelect = document.getElementById('judet');
            const localitateSelect = document.getElementById('localitate');
            
            if (!judetSelect || !localitateSelect) {
                console.error('❌ Select elements not found');
                return;
            }
            
            console.log('🏘️ Loading localități for județ:', judetSelect.value);
            
            // Reset localități
            localitateSelect.innerHTML = '<option value="">-- Selectați localitatea --</option>';
            
            if (judetSelect.value === '') {
                localitateSelect.disabled = true;
                console.log('ℹ️ No județ selected, disabling localități');
                return;
            }
            
            localitateSelect.disabled = false;
            localitateSelect.innerHTML = '<option value="">-- Se încarcă localitățile... --</option>';
            
            $.ajax({
                url: 'LocalitatiProxyServlet',
                type: 'GET',
                data: { judet: judetSelect.value },
                dataType: 'json',
                success: function(data) {
                    console.log('✅ Localități încărcate:', data.length);
                    
                    // Clear loading message
                    localitateSelect.innerHTML = '<option value="">-- Selectați localitatea --</option>';
                    
                    // Sortare alfabetică
                    data.sort(function(a, b) {
                        return a.nume.localeCompare(b.nume);
                    });
                    
                    // Adăugare opțiuni localități
                    $.each(data, function(index, localitate) {
                        const option = document.createElement('option');
                        option.value = localitate.nume;
                        option.textContent = localitate.nume;
                        localitateSelect.appendChild(option);
                    });
                    
                    // Pentru modul edit - selectează localitatea salvată
                    if (isEditMode) {
                        const currentLocalitate = document.getElementById('currentLocalitate');
                        if (currentLocalitate && currentLocalitate.value.trim()) {
                            console.log('🔍 Searching for saved localitate:', currentLocalitate.value);
                            
                            const localitateOptions = Array.from(localitateSelect.options);
                            let found = false;
                            
                            for (let i = 0; i < localitateOptions.length; i++) {
                                const opt = localitateOptions[i];
                                const optText = opt.textContent.toLowerCase().trim();
                                const savedText = currentLocalitate.value.toLowerCase().trim();
                                
                                if (optText === savedText || 
                                    optText.includes(savedText) || 
                                    savedText.includes(optText)) {
                                    opt.selected = true;
                                    found = true;
                                    console.log('✅ Localitate găsită și selectată:', opt.textContent);
                                    break;
                                }
                            }
                            
                            if (!found) {
                                console.warn('⚠️ Localitate salvată nu a fost găsită:', currentLocalitate.value);
                                // Adăugăm manual localitatea
                                const option = document.createElement('option');
                                option.value = currentLocalitate.value;
                                option.textContent = currentLocalitate.value;
                                option.selected = true;
                                localitateSelect.appendChild(option);
                                console.log('📝 Localitate adăugată manual:', currentLocalitate.value);
                            }
                        }
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    console.error('❌ Error loading localități:', textStatus, errorThrown);
                    localitateSelect.disabled = true;
                    localitateSelect.innerHTML = '<option value="">-- Eroare la încărcare --</option>';
                    showErrorMessage('Eroare la încărcarea localităților! ' + errorThrown);
                }
            });
        }

        // ================ FUNCȚII PENTRU ȘTERGERE ================
        
        function deletePost(id) {
            if (confirm('⚠️ Sigur doriți să ștergeți acest post?\n\nAceastă acțiune nu poate fi anulată!')) {
                console.log('🗑️ Deleting post with ID:', id);
                
                $.ajax({
                    url: 'DeletePostServlet',
                    type: 'POST',
                    data: { id: id },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showSuccessMessage('Postul a fost șters cu succes!');
                            setTimeout(() => {
                                window.location.reload();
                            }, 1500);
                        } else {
                            showErrorMessage(response.message || 'Eroare la ștergerea postului!');
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('❌ Error deleting post:', textStatus, errorThrown);
                        showErrorMessage('Eroare la conectarea cu serverul: ' + textStatus);
                    }
                });
            }
        }

        // ================ FUNCȚII PENTRU MESAJE ================
        
        function showSuccessMessage(message) {
            const alert = document.createElement('div');
            alert.innerHTML = `
                <div style="position: fixed; top: 20px; right: 20px; z-index: 1000; 
                           background: var(--success-color); color: white; padding: 1rem 1.5rem; 
                           border-radius: 0.5rem; box-shadow: var(--shadow);
                           display: flex; align-items: center; gap: 0.5rem;">
                    <i class="ri-checkbox-circle-line"></i>
                    ${message}
                </div>
            `;
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 3000);
        }
        
        function showErrorMessage(message) {
            const alert = document.createElement('div');
            alert.innerHTML = `
                <div style="position: fixed; top: 20px; right: 20px; z-index: 1000; 
                           background: var(--error-color); color: white; padding: 1rem 1.5rem; 
                           border-radius: 0.5rem; box-shadow: var(--shadow);
                           display: flex; align-items: center; gap: 0.5rem;">
                    <i class="ri-error-warning-line"></i>
                    ${message}
                </div>
            `;
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 4000);
        }

        // ================ VALIDĂRI ȘI EFECTE ================
        
        // Validare formular
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Document ready - initializing form validations');
            
            // Validare date
            const startDate = document.getElementById('start');
            const endDate = document.getElementById('end');
            
            if (startDate && endDate) {
                function validateDates() {
                    if (startDate.value && endDate.value) {
                        if (new Date(startDate.value) >= new Date(endDate.value)) {
                            endDate.setCustomValidity('Data de sfârșit trebuie să fie după data de început');
                        } else {
                            endDate.setCustomValidity('');
                        }
                    }
                }
                
                startDate.addEventListener('change', validateDates);
                endDate.addEventListener('change', validateDates);
            }
            
            // Efecte ripple pentru carduri și butoane
            document.querySelectorAll('.action-card, .btn').forEach(element => {
                element.addEventListener('click', function(e) {
                    const ripple = document.createElement('div');
                    const rect = this.getBoundingClientRect();
                    const size = Math.max(rect.width, rect.height);
                    
                    ripple.style.width = ripple.style.height = size + 'px';
                    ripple.style.left = e.clientX - rect.left - size / 2 + 'px';
                    ripple.style.top = e.clientY - rect.top - size / 2 + 'px';
                    ripple.style.position = 'absolute';
                    ripple.style.borderRadius = '50%';
                    ripple.style.background = 'rgba(255, 255, 255, 0.3)';
                    ripple.style.transform = 'scale(0)';
                    ripple.style.animation = 'ripple 0.6s linear';
                    ripple.style.pointerEvents = 'none';
                    
                    this.appendChild(ripple);
                    
                    setTimeout(() => {
                        ripple.remove();
                    }, 600);
                });
            });
        });
        
        // CSS pentru efectul ripple
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>