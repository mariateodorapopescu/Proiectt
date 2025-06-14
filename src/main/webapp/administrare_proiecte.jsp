<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.util.Date, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser" %>
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
    int totalProiecte = 0, proiecteActive = 0, totalEchipe = 0;
    
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
                
                // Setăm valorile în sesiune
                sesi.setAttribute("userTip", userType);
                sesi.setAttribute("userDep", userdep);
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
        
        // ================ EXTRAGERE STATISTICI PROIECTE ================
        // Total proiecte
        String totalQuery = "SELECT COUNT(*) as total FROM proiecte";
        try (PreparedStatement totalStmt = connection.prepareStatement(totalQuery);
             ResultSet totalRs = totalStmt.executeQuery()) {
            if (totalRs.next()) {
                totalProiecte = totalRs.getInt("total");
            }
        }
        
        // Proiecte active (în curs)
        String activeQuery = "SELECT COUNT(*) as active FROM proiecte WHERE start <= CURDATE() AND end >= CURDATE()";
        try (PreparedStatement activeStmt = connection.prepareStatement(activeQuery);
             ResultSet activeRs = activeStmt.executeQuery()) {
            if (activeRs.next()) {
                proiecteActive = activeRs.getInt("active");
            }
        }
        
        // Total echipe
        String echipeQuery = "SELECT COUNT(*) as total FROM echipe";
        try (PreparedStatement echipeStmt = connection.prepareStatement(echipeQuery);
             ResultSet echipeRs = echipeStmt.executeQuery()) {
            if (echipeRs.next()) {
                totalEchipe = echipeRs.getInt("total");
            }
        }
        
        // ================ EXTRAGERE TEMA CULOARE ================
        if (isDirector) {
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
    <title>Administrare Proiecte - <%= functie %></title>
    
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

        /* Alerts */
        .alert {
            padding: 1rem 1.5rem;
            margin-bottom: 2rem;
            border-radius: var(--border-radius);
            border: none;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            animation: slideDown 0.3s ease-out;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.1);
            color: var(--success-color);
            border-left: 4px solid var(--success-color);
        }

        .alert-danger {
            background: rgba(239, 68, 68, 0.1);
            color: var(--error-color);
            border-left: 4px solid var(--error-color);
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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

        /* Action Buttons */
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

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
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

        .btn-team {
            background: #3b82f6;
            color: white;
        }

        .btn-delete {
            background: var(--error-color);
            color: white;
        }

        .table-button:hover {
            transform: translateY(-1px);
            
        }

        /* Members List */
        .members-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 0.75rem;
            margin-top: 1rem;
        }

        .member-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.75rem;
            background: var(--hover-color);
            border-radius: 0.5rem;
            transition: var(--transition);
        }

        .member-item:hover {
            background: #e2e8f0;
        }

        .member-checkbox {
            width: 1.25rem;
            height: 1.25rem;
            accent-color: var(--primary-color);
        }

        /* Section Titles */
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

            .members-grid {
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
            <h1>Administrare Proiecte</h1>
            <p class="subtitle">Gestionați proiectele și echipele din organizație</p>
        </div>

        <!-- Alerts -->
        <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        
        if ("true".equals(success)) {
        %>
            <div class="alert alert-success">
                <i class="ri-checkbox-circle-line"></i>
                Operațiunea a fost efectuată cu succes!
            </div>
        <%
        } else if (error != null && !error.isEmpty()) {
        %>
            <div class="alert alert-danger">
                <i class="ri-error-warning-line"></i>
                <%
                switch(error) {
                    case "accessDenied":
                        out.println("Nu aveți permisiunile necesare pentru această acțiune.");
                        break;
                    case "invalidData":
                        out.println("Datele introduse nu sunt valide.");
                        break;
                    case "invalidDates":
                        out.println("Data de început trebuie să fie înainte de data de sfârșit.");
                        break;
                    case "databaseError":
                        out.println("Eroare la baza de date.");
                        break;
                    case "noMembersSelected":
                        out.println("Nu ați selectat niciun membru.");
                        break;
                    default:
                        out.println("A apărut o eroare.");
                }
                %>
            </div>
        <%
        }
        %>

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
                    <i class="ri-folder-line stat-icon"></i>
                    <div class="stat-number"><%= totalProiecte %></div>
                    <div class="stat-label">Total proiecte</div>
                </div>
                <div class="stat-card">
                    <i class="ri-play-circle-line stat-icon"></i>
                    <div class="stat-number"><%= proiecteActive %></div>
                    <div class="stat-label">Proiecte active</div>
                </div>
                <div class="stat-card">
                    <i class="ri-team-line stat-icon"></i>
                    <div class="stat-number"><%= totalEchipe %></div>
                    <div class="stat-label">Total echipe</div>
                </div>
            </div>

            <!-- Action Cards -->
            <div class="actions-grid">
                <a href="administrare_proiecte.jsp?action=add" class="action-card fade-in">
                    <i class="ri-add-circle-line action-icon"></i>
                    <h3 class="action-title">Adaugă Proiect</h3>
                    <p class="action-description">
                        Creați un nou proiect și definiți obiectivele, termenele și managerii responsabili.
                    </p>
                </a>

                <a href="administrare_proiecte.jsp?action=list" class="action-card fade-in" style="animation-delay: 0.1s">
                    <i class="ri-settings-3-line action-icon"></i>
                    <h3 class="action-title">Gestionare Proiecte</h3>
                    <p class="action-description">
                        Vizualizați, modificați și ștergeți proiectele existente din organizație.
                    </p>
                </a>
            </div>

        <%
        } else if ("add".equals(action)) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Adaugă Proiect Nou</h2>
                <form method="POST" action="AAA">
                    <div class="form-group">
                        <label for="nume">
                            <i class="ri-folder-line"></i> Nume proiect
                        </label>
                        <input type="text" id="nume" name="nume" class="form-control" 
                               placeholder="Introduceți numele proiectului" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">
                            <i class="ri-file-text-line"></i> Descriere
                        </label>
                        <textarea id="descriere" name="descriere" class="form-control" 
                                  placeholder="Descrieți obiectivele și scopul proiectului" required></textarea>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
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
                    
                    <div class="form-group">
                        <label for="manager">
                            <i class="ri-user-star-line"></i> Manager proiect
                        </label>
                        <select id="manager" name="supervizor" class="form-control" required>
                            <option value="">-- Selectați managerul --</option>
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                String sql = "SELECT id, nume, prenume FROM useri WHERE tip >= 10 ORDER BY nume, prenume";
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
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Creează Proiectul
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_proiecte.jsp" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi
                    </a>
                </div>
            </div>

        <%
        } else if ("list".equals(action)) {
        %>
            <h2 class="section-title fade-in">Lista Proiectelor</h2>
            <div class="table-container fade-in">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Nr.</th>
                            <th>Nume Proiect</th>
                            <th>Manager</th>
                            <th>Status</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String sql = "SELECT p.id, p.nume, p.start, p.end, u.nume as manager_nume, u.prenume as manager_prenume " +
                                       "FROM proiecte p " +
                                       "LEFT JOIN useri u ON p.supervizor = u.id " +
                                       "ORDER BY p.nume";
                            try (Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(sql)) {
                                
                                int counter = 1;
                                while (rs.next()) {
                                    Date startDate = rs.getDate("start");
                                    Date endDate = rs.getDate("end");
                                    Date currentDate = new Date(System.currentTimeMillis());
                                    
                                    String status = "Planificat";
                                    String statusColor = "#6b7280";
                                    
                                    if (startDate != null && endDate != null) {
                                        if (currentDate.before(startDate)) {
                                            status = "Planificat";
                                            statusColor = "#3b82f6";
                                        } else if (currentDate.after(endDate)) {
                                            status = "Finalizat";
                                            statusColor = "#6b7280";
                                        } else {
                                            status = "În curs";
                                            statusColor = "#10b981";
                                        }
                                    }
                        %>
                            <tr>
                                <td><%= counter++ %></td>
                                <td><strong><%= rs.getString("nume") %></strong></td>
                                <td><%= rs.getString("manager_nume") %> <%= rs.getString("manager_prenume") %></td>
                                <td>
                                    <span style="color: <%= statusColor %>; font-weight: 600;">
                                        <%= status %>
                                    </span>
                                </td>
                                <td>
                                    <button class="table-button btn-edit" 
                                            onclick="window.location.href='administrare_proiecte.jsp?action=edit&id=<%= rs.getInt("id") %>'"
                                            title="Modifică proiectul">
                                        <i class="ri-edit-line"></i> Editează
                                    </button>
                                    <button class="table-button btn-team" 
                                            onclick="window.location.href='administrare_proiecte.jsp?action=teams&id=<%= rs.getInt("id") %>'"
                                            title="Gestionează echipele">
                                        <i class="ri-team-line"></i> Echipe
                                    </button>
                                    <button class="table-button btn-delete" 
                                            onclick="deleteProiect(<%= rs.getInt("id") %>)"
                                            title="Șterge proiectul">
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
                <a href="administrare_proiecte.jsp" class="btn btn-back">
                    <i class="ri-arrow-left-line"></i> Înapoi
                </a>
            </div>

        <%
        } else if ("edit".equals(action)) { 
            int idProiect = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                String sql = "SELECT * FROM proiecte WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, idProiect);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Modificare Proiect</h2>
                <form method="POST" action="blaaaa">
                    <input type="hidden" name="id" value="<%= idProiect %>">
                    
                    <div class="form-group">
                        <label for="nume">
                            <i class="ri-folder-line"></i> Nume proiect
                        </label>
                        <input type="text" id="nume" name="nume" class="form-control" 
                               value="<%= rs.getString("nume") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">
                            <i class="ri-file-text-line"></i> Descriere
                        </label>
                        <textarea id="descriere" name="descriere" class="form-control" required><%= rs.getString("descriere") %></textarea>
                    </div>
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
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
                    </div>
                    
                    <div class="form-group">
                        <label for="manager">
                            <i class="ri-user-star-line"></i> Manager proiect
                        </label>
                        <select id="manager" name="supervizor" class="form-control" required>
                            <%
                            String sql2 = "SELECT id, nume, prenume FROM useri WHERE tip >= 10 ORDER BY nume, prenume";
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
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-save-line"></i> Salvează Modificările
                        </button>
                    </div>
                </form>
                
                <div style="text-align: center;">
                    <a href="administrare_proiecte.jsp?action=list" class="btn btn-back">
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
        } else if ("teams".equals(action)) { 
            int idProiect = Integer.parseInt(request.getParameter("id"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                String sqlProiect = "SELECT * FROM proiecte WHERE id = ?";
                try (PreparedStatement pstmtProiect = conn.prepareStatement(sqlProiect)) {
                    pstmtProiect.setInt(1, idProiect);
                    try (ResultSet rsProiect = pstmtProiect.executeQuery()) {
                        if (rsProiect.next()) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Gestionare Echipe - <%= rsProiect.getString("nume") %></h2>
                
                <!-- Formular adăugare echipă -->
                <form method="POST" action="AdaugaEchipaServlet">
                    <input type="hidden" name="id_prj" value="<%= idProiect %>">
                    
                    <div class="form-group">
                        <label for="nume_echipa">
                            <i class="ri-team-line"></i> Nume echipă
                        </label>
                        <input type="text" id="nume_echipa" name="nume" class="form-control" 
                               placeholder="Introduceți numele echipei" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="supervizor_echipa">
                            <i class="ri-user-star-line"></i> Supervizor echipă
                        </label>
                        <select id="supervizor_echipa" name="supervizor" class="form-control" required>
                            <option value="">-- Selectați supervizorul --</option>
                            <%
                            String sqlSupervizori = "SELECT id, nume, prenume FROM useri WHERE tip >= 8 ORDER BY nume, prenume";
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
                        <label>
                            <i class="ri-user-add-line"></i> Selectați membrii echipei
                        </label>
                        <div class="members-grid">
                            <%
                            String sqlAngajati = "SELECT id, nume, prenume FROM useri ORDER BY nume, prenume";
                            try (Statement stmtAngajati = conn.createStatement();
                                 ResultSet rsAngajati = stmtAngajati.executeQuery(sqlAngajati)) {
                                
                                while (rsAngajati.next()) {
                            %>
                                <div class="member-item">
                                    <input type="checkbox" name="membri" value="<%= rsAngajati.getInt("id") %>" 
                                           class="member-checkbox" id="member_<%= rsAngajati.getInt("id") %>">
                                    <label for="member_<%= rsAngajati.getInt("id") %>">
                                        <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                                    </label>
                                </div>
                            <%
                                }
                            }
                            %>
                        </div>
                    </div>
                    
                    <div style="text-align: center; margin-top: 2rem;">
                        <button type="submit" class="btn btn-primary">
                            <i class="ri-add-line"></i> Creează Echipa
                        </button>
                    </div>
                </form>
                
                <!-- Lista echipelor existente -->
                <h3 class="section-title">Echipe Existente</h3>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Nume Echipă</th>
                                <th>Supervizor</th>
                                <th>Membri</th>
                                <th>Acțiuni</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            String sqlEchipe = "SELECT e.*, u.nume as supervizor_nume, u.prenume as supervizor_prenume, " +
                                             "(SELECT COUNT(*) FROM membrii_echipe me WHERE me.id_echipa = e.id) as nr_membri " +
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
                                    <td><strong><%= rsEchipe.getString("nume") %></strong></td>
                                    <td><%= rsEchipe.getString("supervizor_nume") %> <%= rsEchipe.getString("supervizor_prenume") %></td>
                                    <td>
                                        <span style="background: var(--primary-color); color: white; padding: 0.25rem 0.5rem; border-radius: 0.25rem; font-size: 0.875rem;">
                                            <%= rsEchipe.getInt("nr_membri") %> membri
                                        </span>
                                    </td>
                                    <td>
                                        <button class="table-button btn-team" 
                                                onclick="window.location.href='administrare_proiecte.jsp?action=members&id_echipa=<%= rsEchipe.getInt("id") %>&id_prj=<%= idProiect %>'"
                                                title="Gestionează membrii">
                                            <i class="ri-user-settings-line"></i> Membri
                                        </button>
                                        <button class="table-button btn-delete" 
                                                onclick="deleteEchipa(<%= rsEchipe.getInt("id") %>, <%= idProiect %>)"
                                                title="Șterge echipa">
                                            <i class="ri-delete-bin-line"></i> Șterge
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                    if (!hasTeams) {
                            %>
                                <tr>
                                    <td colspan="4" style="text-align: center; padding: 2rem; opacity: 0.7;">
                                        <i class="ri-team-line" style="font-size: 2rem; margin-bottom: 0.5rem; display: block;"></i>
                                        Nu există echipe create pentru acest proiect
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
                
                <div style="text-align: center;">
                    <a href="administrare_proiecte.jsp?action=list" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi la proiecte
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
        } else if ("members".equals(action)) {
            int idEchipa = Integer.parseInt(request.getParameter("id_echipa"));
            int idProiect = Integer.parseInt(request.getParameter("id_prj"));
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                String sqlEchipa = "SELECT e.*, u.nume as supervizor_nume, u.prenume as supervizor_prenume " +
                                "FROM echipe e " +
                                "LEFT JOIN useri u ON e.supervizor = u.id " +
                                "WHERE e.id = ?";
                try (PreparedStatement pstmtEchipa = conn.prepareStatement(sqlEchipa)) {
                    pstmtEchipa.setInt(1, idEchipa);
                    try (ResultSet rsEchipa = pstmtEchipa.executeQuery()) {
                        if (rsEchipa.next()) {
        %>
            <div class="form-container fade-in">
                <h2 class="section-title">Membri Echipa: <%= rsEchipa.getString("nume") %></h2>
                <div style="text-align: center; margin-bottom: 2rem; padding: 1rem; background: var(--hover-color); border-radius: 0.5rem;">
                    <strong>Supervizor:</strong> <%= rsEchipa.getString("supervizor_nume") %> <%= rsEchipa.getString("supervizor_prenume") %>
                </div>
                
                <!-- Formular adăugare membri -->
                <form method="POST" action="AdaugaMembruEchipaServlet">
                    <input type="hidden" name="id_echipa" value="<%= idEchipa %>">
                    <input type="hidden" name="id_prj" value="<%= idProiect %>">
                    
                    <div class="form-group">
                        <label>
                            <i class="ri-user-add-line"></i> Adaugă membri noi
                        </label>
                        <div class="members-grid">
                            <%
                            String sqlAngajatiNeinclusi = "SELECT u.id, u.nume, u.prenume FROM useri u " +
                                                        "WHERE u.id NOT IN (SELECT me.id_ang FROM membrii_echipe me WHERE me.id_echipa = ?) " +
                                                        "ORDER BY u.nume, u.prenume";
                            try (PreparedStatement pstmtAngajati = conn.prepareStatement(sqlAngajatiNeinclusi)) {
                                pstmtAngajati.setInt(1, idEchipa);
                                try (ResultSet rsAngajati = pstmtAngajati.executeQuery()) {
                                    boolean hasCandidates = false;
                                    while (rsAngajati.next()) {
                                        hasCandidates = true;
                            %>
                                <div class="member-item">
                                    <input type="checkbox" name="membri" value="<%= rsAngajati.getInt("id") %>" 
                                           class="member-checkbox" id="new_member_<%= rsAngajati.getInt("id") %>">
                                    <label for="new_member_<%= rsAngajati.getInt("id") %>">
                                        <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                                    </label>
                                </div>
                            <%
                                    }
                                    if (!hasCandidates) {
                            %>
                                <div style="text-align: center; padding: 2rem; opacity: 0.7;">
                                    <i class="ri-user-line" style="font-size: 2rem; margin-bottom: 0.5rem; display: block;"></i>
                                    Nu mai există angajați disponibili pentru adăugare
                                </div>
                            <%
                                    } else {
                            %>
                                <div style="grid-column: 1 / -1; text-align: center; margin-top: 1rem;">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="ri-user-add-line"></i> Adaugă Membrii Selectați
                                    </button>
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
                <h3 class="section-title">Membri Actuali</h3>
                <div class="table-container">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Avatar</th>
                                <th>Nume Complet</th>
                                <th>Poziție</th>
                                <th>Departament</th>
                                <th>Acțiuni</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            String sqlMembri = "SELECT u.id, u.nume, u.prenume, t.denumire as pozitie, d.nume_dep, me.id as id_membru " +
                                            "FROM membrii_echipe me " +
                                            "JOIN useri u ON me.id_ang = u.id " +
                                            "JOIN tipuri t ON u.tip = t.tip " +
                                            "JOIN departament d ON u.id_dep = d.id_dep " +
                                            "WHERE me.id_echipa = ? " +
                                            "ORDER BY u.nume, u.prenume";
                            try (PreparedStatement pstmtMembri = conn.prepareStatement(sqlMembri)) {
                                pstmtMembri.setInt(1, idEchipa);
                                try (ResultSet rsMembri = pstmtMembri.executeQuery()) {
                                    boolean hasMembers = false;
                                    while (rsMembri.next()) {
                                        hasMembers = true;
                            %>
                                <tr>
                                    <td>
                                        <img src="${pageContext.request.contextPath}/ImageServlet?id=<%= rsMembri.getInt("id") %>" 
                                             alt="Avatar" 
                                             style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;"
                                             onerror="this.src='https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'">
                                    </td>
                                    <td><strong><%= rsMembri.getString("nume") %> <%= rsMembri.getString("prenume") %></strong></td>
                                    <td><%= rsMembri.getString("pozitie") %></td>
                                    <td><%= rsMembri.getString("nume_dep") %></td>
                                    <td>
                                        <button class="table-button btn-delete" 
                                                onclick="removeMembru(<%= rsMembri.getInt("id_membru") %>, <%= idEchipa %>, <%= idProiect %>)"
                                                title="Elimină din echipă">
                                            <i class="ri-user-unfollow-line"></i> Elimină
                                        </button>
                                    </td>
                                </tr>
                            <%
                                    }
                                    if (!hasMembers) {
                            %>
                                <tr>
                                    <td colspan="5" style="text-align: center; padding: 2rem; opacity: 0.7;">
                                        <i class="ri-user-line" style="font-size: 2rem; margin-bottom: 0.5rem; display: block;"></i>
                                        Echipa nu are membri încă
                                    </td>
                                </tr>
                            <%
                                    }
                                }
                            }
                            %>
                        </tbody>
                    </table>
                </div>
                
                <div style="text-align: center;">
                    <a href="administrare_proiecte.jsp?action=teams&id=<%= idProiect %>" class="btn btn-back">
                        <i class="ri-arrow-left-line"></i> Înapoi la echipe
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
        // Funcții pentru ștergere cu confirmări
        function deleteProiect(idProiect) {
            if (confirm('⚠️ Sigur doriți să ștergeți acest proiect?\n\nAceastă acțiune va șterge și toate echipele asociate!')) {
                $.ajax({
                    url: 'DeleteProiectServlet',
                    type: 'POST',
                    data: { id: idProiect },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showSuccessMessage('Proiectul a fost șters cu succes!');
                            setTimeout(() => {
                                window.location.href = 'administrare_proiecte.jsp?action=list&success=true';
                            }, 1500);
                        } else {
                            showErrorMessage(response.message || 'Eroare la ștergerea proiectului!');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Eroare AJAX:", status, error);
                        showErrorMessage('Eroare la conectarea cu serverul: ' + error);
                    }
                });
            }
        }
        
        function deleteEchipa(idEchipa, idProiect) {
            if (confirm('⚠️ Sigur doriți să ștergeți această echipă?\n\nToți membrii vor fi eliminați din echipă.')) {
                $.ajax({
                    url: 'DeleteEchipaServlet',
                    type: 'POST',
                    data: { id: idEchipa },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showSuccessMessage('Echipa a fost ștearsă cu succes!');
                            setTimeout(() => {
                                window.location.href = 'administrare_proiecte.jsp?action=teams&id=' + idProiect + '&success=true';
                            }, 1500);
                        } else {
                            showErrorMessage(response.message || 'Eroare la ștergerea echipei!');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Eroare AJAX:", status, error);
                        showErrorMessage('Eroare la conectarea cu serverul: ' + error);
                    }
                });
            }
        }
        
        function removeMembru(idMembru, idEchipa, idProiect) {
            if (confirm('Sigur doriți să eliminați acest membru din echipă?')) {
                $.ajax({
                    url: 'RemoveMembruEchipaServlet',
                    type: 'POST',
                    data: { id: idMembru },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showSuccessMessage('Membrul a fost eliminat cu succes!');
                            setTimeout(() => {
                                window.location.href = 'administrare_proiecte.jsp?action=members&id_echipa=' + idEchipa + '&id_prj=' + idProiect + '&success=true';
                            }, 1500);
                        } else {
                            showErrorMessage(response.message || 'Eroare la eliminarea membrului!');
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("Eroare AJAX:", status, error);
                        showErrorMessage('Eroare la conectarea cu serverul: ' + error);
                    }
                });
            }
        }
        
        // Funcții pentru mesaje
        function showSuccessMessage(message) {
            const alert = document.createElement('div');
            alert.className = 'alert alert-success';
            alert.innerHTML = '<i class="ri-checkbox-circle-line"></i>' + message;
            alert.style.position = 'fixed';
            alert.style.top = '20px';
            alert.style.right = '20px';
            alert.style.zIndex = '1000';
            alert.style.minWidth = '300px';
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 3000);
        }
        
        function showErrorMessage(message) {
            const alert = document.createElement('div');
            alert.className = 'alert alert-danger';
            alert.innerHTML = '<i class="ri-error-warning-line"></i>' + message;
            alert.style.position = 'fixed';
            alert.style.top = '20px';
            alert.style.right = '20px';
            alert.style.zIndex = '1000';
            alert.style.minWidth = '300px';
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 4000);
        }
        
        // Validare formular
        document.addEventListener('DOMContentLoaded', function() {
            // Validare date pentru formular proiect
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
            
            // Efecte ripple pentru butoane
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