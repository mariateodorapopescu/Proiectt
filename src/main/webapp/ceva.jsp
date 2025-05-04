<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                     "dp.denumire_completa AS denumire FROM useri u " +
                     "JOIN tipuri t ON u.tip = t.tip " +
                     "JOIN departament d ON u.id_dep = d.id_dep " +
                     "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                     "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    // Extract user data
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");
                    String userFullName = rs.getString("nume") + " " + rs.getString("prenume");
                    String depName = rs.getString("nume_dep");
                    
                    if (functie.compareTo("Administrator") != 0) {  
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        // Get theme preferences
                        String accent = "#4F46E5"; // Default color
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
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistem de Management - Administrare Sedii</title>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --accent: <%= accent %>;
            --background: <%= clr %>;
            --sidebar: <%= sidebar %>;
            --text: <%= text %>;
            --card: <%= card %>;
            --hover: <%= hover %>;
            --border: #e5e7eb;
            --danger: #ef4444;
            --success: #10b981;
            --warning: #f59e0b;
            --info: #3b82f6;
            --sidebar-width: 280px;
            --header-height: 64px;
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
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            width: var(--sidebar-width);
            height: 100vh;
            background-color: var(--sidebar);
            border-right: 1px solid var(--border);
            padding: 1.5rem;
            overflow-y: auto;
            transition: transform 0.3s ease;
            z-index: 50;
        }
        
        .sidebar-header {
            display: flex;
            align-items: center;
            margin-bottom: 2rem;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--accent);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .logo i {
            font-size: 1.75rem;
        }
        
        .nav-section {
            margin-bottom: 1.5rem;
        }
        
        .nav-section-title {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            color: #6b7280;
            margin-bottom: 0.75rem;
            padding-left: 0.5rem;
        }
        
        .nav-menu {
            list-style: none;
        }
        
        .nav-item {
            margin-bottom: 0.25rem;
        }
        
        .nav-link {
            display: flex;
            align-items: center;
            padding: 0.75rem 1rem;
            border-radius: 0.5rem;
            text-decoration: none;
            color: var(--text);
            font-weight: 500;
            font-size: 0.875rem;
            transition: all 0.2s;
        }
        
        .nav-link:hover {
            background-color: var(--hover);
        }
        
        .nav-link.active {
            background-color: var(--accent);
            color: white;
        }
        
        .nav-link i {
            font-size: 1.25rem;
            margin-right: 0.75rem;
        }
        
        .nav-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background-color: var(--accent);
            color: white;
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: 9999px;
            padding: 0.125rem 0.5rem;
            margin-left: auto;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            margin-top: auto;
            padding: 1rem;
            background-color: var(--hover);
            border-radius: 0.5rem;
            margin-top: 2rem;
        }
        
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 9999px;
            background-color: var(--accent);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            margin-right: 0.75rem;
        }
        
        .user-info {
            flex: 1;
        }
        
        .user-name {
            font-weight: 600;
            font-size: 0.875rem;
            margin-bottom: 0.125rem;
        }
        
        .user-role {
            font-size: 0.75rem;
            color: #6b7280;
        }
        
        .user-dropdown {
            background: transparent;
            border: none;
            color: #6b7280;
            cursor: pointer;
        }
        
        /* Header Styles */
        .header {
            height: var(--header-height);
            background-color: var(--card);
            border-bottom: 1px solid var(--border);
            padding: 0 1.5rem;
            display: flex;
            align-items: center;
            position: fixed;
            top: 0;
            left: var(--sidebar-width);
            right: 0;
            z-index: 40;
        }
        
        .mobile-menu-trigger {
            display: none;
            background: transparent;
            border: none;
            font-size: 1.5rem;
            color: var(--text);
            cursor: pointer;
            margin-right: 1rem;
        }
        
        .header-search {
            position: relative;
            margin-right: auto;
            max-width: 400px;
            width: 100%;
        }
        
        .search-input {
            width: 100%;
            padding: 0.5rem 0.75rem 0.5rem 2.25rem;
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            background-color: var(--background);
            color: var(--text);
            font-size: 0.875rem;
            outline: none;
            transition: all 0.2s;
        }
        
        .search-input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        
        .search-icon {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
        }
        
        .header-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .action-button {
            background: transparent;
            border: none;
            color: var(--text);
            font-size: 1.25rem;
            cursor: pointer;
            position: relative;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 9999px;
            transition: background-color 0.2s;
        }
        
        .action-button:hover {
            background-color: var(--hover);
        }
        
        .notification-indicator {
            position: absolute;
            top: 3px;
            right: 3px;
            width: 10px;
            height: 10px;
            border-radius: 9999px;
            background-color: var(--danger);
            border: 2px solid var(--card);
        }
        
        /* Main Content Styles */
        .main-content {
            padding-top: var(--header-height);
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: calc(var(--header-height) + 1.5rem) 1.5rem 1.5rem;
            transition: margin-left 0.3s ease;
        }
        
        .content-wrapper {
            max-width: 1280px;
            margin: 0 auto;
        }
        
        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text);
        }
        
        .breadcrumb {
            display: flex;
            align-items: center;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
            color: #6b7280;
        }
        
        .breadcrumb-item {
            display: flex;
            align-items: center;
        }
        
        .breadcrumb-item a {
            color: #6b7280;
            text-decoration: none;
            transition: color 0.2s;
        }
        
        .breadcrumb-item a:hover {
            color: var(--accent);
        }
        
        .breadcrumb-separator {
            margin: 0 0.5rem;
            font-size: 0.75rem;
        }
        
        .breadcrumb-item.active {
            color: var(--accent);
            font-weight: 500;
        }
        
        .content-actions {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.5rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        
        .btn-primary {
            background-color: var(--accent);
            color: white;
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-outline {
            background-color: transparent;
            border: 1px solid var(--border);
            color: var(--text);
        }
        
        .btn-outline:hover {
            background-color: var(--hover);
        }
        
        /* Cards and Boxes */
        .card {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 1.5rem;
        }
        
        .card-header {
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .card-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--text);
        }
        
        .card-body {
            padding: 1.5rem;
        }
        
        .card-footer {
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border);
        }
        
        /* Widgets for Dashboard */
        .widget-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .widget {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 1.5rem;
        }
        
        .widget-title {
            font-size: 0.875rem;
            font-weight: 500;
            color: #6b7280;
            margin-bottom: 0.75rem;
        }
        
        .widget-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 0.5rem;
        }
        
        .widget-info {
            display: flex;
            align-items: center;
            font-size: 0.875rem;
        }
        
        .widget-info.positive {
            color: var(--success);
        }
        
        .widget-info.negative {
            color: var(--danger);
        }
        
        .widget-info i {
            margin-right: 0.375rem;
        }
        
        /* Iframe for content embedding */
        .content-frame {
            width: 100%;
            height: calc(100vh - var(--header-height) - 3rem);
            border: none;
            border-radius: 0.75rem;
            background-color: var(--card);
        }
        
        /* Responsive Styles */
        @media (max-width: 1024px) {
            .sidebar {
                transform: translateX(-100%);
            }
            
            .sidebar.open {
                transform: translateX(0);
            }
            
            .header {
                left: 0;
            }
            
            .mobile-menu-trigger {
                display: block;
            }
            
            .main-content {
                margin-left: 0;
            }
        }
        
        @media (max-width: 640px) {
            .widget-grid {
                grid-template-columns: 1fr;
            }
            
            .header-search {
                display: none;
            }
            
            .content-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }
            
            .content-actions {
                width: 100%;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <div class="logo">
                <i class="fas fa-building"></i>
                <span>ManagementHRM</span>
            </div>
        </div>
        
        <div class="nav-section">
            <h3 class="nav-section-title">Navigare Generala</h3>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link active" data-page="dashboard">
                        <i class="fas fa-tachometer-alt"></i>
                        <span>Dashboard</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="profile">
                        <i class="fas fa-user"></i>
                        <span>Profilul Meu</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="notifications">
                        <i class="fas fa-bell"></i>
                        <span>Notificări</span>
                        <span class="nav-badge">5</span>
                    </a>
                </li>
            </ul>
        </div>
        
        <div class="nav-section">
            <h3 class="nav-section-title">Administrare</h3>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="users">
                        <i class="fas fa-users"></i>
                        <span>Utilizatori</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="departments">
                        <i class="fas fa-sitemap"></i>
                        <span>Departamente</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="sedii">
                        <i class="fas fa-building"></i>
                        <span>Administrare Sedii</span>
                    </a>
                </li>
            </ul>
        </div>
        
        <div class="nav-section">
            <h3 class="nav-section-title">Resurse Umane</h3>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="concedii">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Concedii</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="pontaj">
                        <i class="fas fa-clock"></i>
                        <span>Pontaj</span>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="javascript:void(0)" class="nav-link" data-page="adeverinte">
                        <i class="fas fa-file-alt"></i>
                        <span>Adeverințe</span>
                    </a>
                </li>
            </ul>
        </div>
        
        <div class="user-profile">
            <div class="user-avatar">
                <%= userFullName.substring(0, 1).toUpperCase() %>
            </div>
            <div class="user-info">
                <div class="user-name"><%= userFullName %></div>
                <div class="user-role"><%= functie %> - <%= depName %></div>
            </div>
            <button class="user-dropdown">
                <i class="fas fa-ellipsis-v"></i>
            </button>
        </div>
    </aside>
    
    <!-- Header -->
    <header class="header">
        <button class="mobile-menu-trigger" id="mobile-menu-trigger">
            <i class="fas fa-bars"></i>
        </button>
        
        <div class="header-search">
            <i class="fas fa-search search-icon"></i>
            <input type="text" class="search-input" placeholder="Caută...">
        </div>
        
        <div class="header-actions">
            <button class="action-button">
                <i class="fas fa-bell"></i>
                <span class="notification-indicator"></span>
            </button>
            <button class="action-button">
                <i class="fas fa-cog"></i>
            </button>
            <button class="action-button">
                <i class="fas fa-sign-out-alt"></i>
            </button>
        </div>
    </header>
    
    <!-- Main Content Area -->
    <main class="main-content">
        <div class="content-wrapper">
            <!-- Content Header -->
            <div class="content-header">
                <div>
                    <div class="breadcrumb">
                        <div class="breadcrumb-item"><a href="#">Acasă</a></div>
                        <div class="breadcrumb-separator"><i class="fas fa-chevron-right"></i></div>
                        <div class="breadcrumb-item active" id="current-page-title">Dashboard</div>
                    </div>
                    <h1 class="page-title" id="page-title">Dashboard</h1>
                </div>
                
                <div class="content-actions" id="content-actions">
                    <!-- Action buttons will be dynamically inserted here -->
                </div>
            </div>
            
            <!-- Dynamic Content Area -->
            <div id="content-area">
                <!-- Default Dashboard View -->
                <div id="dashboard-content">
                    <div class="widget-grid">
                        <div class="widget">
                            <div class="widget-title">Total Utilizatori</div>
                            <div class="widget-value">125</div>
                            <div class="widget-info positive">
                                <i class="fas fa-arrow-up"></i>
                                <span>+12% din luna trecută</span>
                            </div>
                        </div>
                        
                        <div class="widget">
                            <div class="widget-title">Total Departamente</div>
                            <div class="widget-value">8</div>
                            <div class="widget-info">
                                <i class="fas fa-equals"></i>
                                <span>Neschimbat</span>
                            </div>
                        </div>
                        
                        <div class="widget">
                            <div class="widget-title">Total Sedii</div>
                            <div class="widget-value">12</div>
                            <div class="widget-info positive">
                                <i class="fas fa-arrow-up"></i>
                                <span>+2 din luna trecută</span>
                            </div>
                        </div>
                        
                        <div class="widget">
                            <div class="widget-title">Cereri de Concediu</div>
                            <div class="widget-value">8</div>
                            <div class="widget-info negative">
                                <i class="fas fa-arrow-down"></i>
                                <span>-15% din luna trecută</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Activitate Recentă</h2>
                        </div>
                        <div class="card-body">
                            <p>Bine ați venit în sistemul de management! Alegeți o opțiune din meniu pentru a începe.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Iframe container for content pages -->
                <div id="iframe-container" style="display: none;">
                    <iframe id="content-frame" class="content-frame" src=""></iframe>
                </div>
            </div>
        </div>
    </main>
    
    <script>
        // Mobile menu toggle
        document.getElementById('mobile-menu-trigger').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('open');
        });
        
        // Page navigation
        const navLinks = document.querySelectorAll('.nav-link');
        const dashboardContent = document.getElementById('dashboard-content');
        const iframeContainer = document.getElementById('iframe-container');
        const contentFrame = document.getElementById('content-frame');
        const pageTitle = document.getElementById('page-title');
        const currentPageTitle = document.getElementById('current-page-title');
        const contentActions = document.getElementById('content-actions');
        
        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                // Remove active class from all links
                navLinks.forEach(item => item.classList.remove('active'));
                
                // Add active class to clicked link
                this.classList.add('active');
                
                // Get page identifier
                const page = this.getAttribute('data-page');
                
                // Update page title and breadcrumb
                let title = this.querySelector('span').textContent;
                pageTitle.textContent = title;
                currentPageTitle.textContent = title;
                
                // Handle different pages
                if (page === 'dashboard') {
                    dashboardContent.style.display = 'block';
                    iframeContainer.style.display = 'none';
                    
                    // Clear content actions
                    contentActions.innerHTML = '';
                } else if (page === 'sedii') {
                    // Show iframe and load sedii list
                    dashboardContent.style.display = 'none';
                    iframeContainer.style.display = 'block';
                    contentFrame.src = 'listasedii.jsp';
                    
                    // Update content actions for sedii management
                    contentActions.innerHTML = `
                        <a href="adaugaresediu.jsp" class="btn btn-primary" target="content-frame">
                            <i class="fas fa-plus"></i>
                            <span>Adaugă Sediu</span>
                        </a>
                        <button class="btn btn-outline" onclick="refreshIframe()">
                            <i class="fas fa-sync-alt"></i>
                            <span>Reîmprospătează</span>
                        </button>
                    `;
                } else {
                    // For other pages, show a placeholder
                    dashboardContent.style.display = 'none';
                    iframeContainer.style.display = 'block';
                    contentFrame.src = page + '.jsp';
                    
                    // Clear content actions
                    contentActions.innerHTML = '';
                }
                
                // On mobile, close the sidebar after clicking a link
                if (window.innerWidth <= 1024) {
                    document.getElementById('sidebar').classList.remove('open');
                }
            });
        });
        
        // Function to refresh iframe content
        function refreshIframe() {
            document.getElementById('content-frame').contentWindow.location.reload();
        }
    </script>
</body>
</html>
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