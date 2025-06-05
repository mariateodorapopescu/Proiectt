<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int id = rs.getInt("id");
                    
                    String prenume = rs.getString("prenume");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");
                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    
               
                    String accent = null;
                 	 String clr = null;
                 	 String sidebar = null;
                 	 String text = null;
                 	 String card = null;
                 	 String hover = null;
                 	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        // Check for upcoming leaves in 3 days
                        String query = "SELECT * from teme where id_usr = ?";
                        try (PreparedStatement stmt = connection.prepareStatement(query)) {
                            stmt.setInt(1, id);
                            try (ResultSet rs2 = stmt.executeQuery()) {
                                if (rs2.next()) {
                                  accent =  rs2.getString("accent");
                                  clr =  rs2.getString("clr");
                                  sidebar =  rs2.getString("sidebar");
                                  text = rs2.getString("text");
                                  card =  rs2.getString("card");
                                  hover = rs2.getString("hover");
                                }
                            }
                        }
                        
                    } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
                    if (isAdmin) {
                        response.sendRedirect("adminok.jsp");
                    } else {
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
                        
                        %>
<html>
<head>
    <title>Profil utilizator</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
     <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link href="https://cdn.jsdelivr.net/npm/remixicons@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@200;300;400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/date-fns@2.29.3/index.min.js"></script>
    <style>
        body {
            background-color: var(--clr);
           
        }
       @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}
        .main-content {
            
            padding: 20px;
            color: var(--text);
        }
        .header {
            background-color: var(--sd);
            padding: 20px;
            border-radius: 10px;
            color: var(--text);
            margin-bottom: 20px;
        }
        .card {
            
            padding: 20px;
            border-radius: 10px;
             background-color: var(--sd);
            margin-bottom: 20px;
            color: var(--text);
        }
        .card h3 {
            margin-bottom: 20px;
            color: var(--text);
        }
        .card .info div {
            margin-bottom: 10px;
            font-size: 16px;
            color: #555;
            
        }
        .card .info div span {
            font-weight: bold;
            color: var(--text);
        }
        .btn-primary {
            background-color: var(--bg);
            
        }
        .btn-primary:hover {
            background-color: black;
           
        }

        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, var(--bg-color) 0%, var(--hover-color) 100%);
            color: var(--text-color);
            min-height: 100vh;
            line-height: 1.6;
        }

        .dashboard-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .header-section {
            background: linear-gradient(135deg, var(--accent-color), var(--info-color));
            border-radius: var(--border-radius);
            padding: 30px;
            margin-bottom: 30px;
            color: white;
            box-shadow: var(--shadow);
            position: relative;
            overflow: hidden;
        }

        .header-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20px;
            width: 200px;
            height: 200px;
            background: rgba(255,255,255,0.1);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }

        .header-content {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 20px;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .user-info h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .user-role {
            background: rgba(255,255,255,0.2);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 500;
            display: inline-block;
            margin-bottom: 10px;
        }

        .current-date {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        .quick-actions {
            display: flex;
            gap: 10px;
        }

        .quick-btn {
            background: rgba(255,255,255,0.2);
            border: none;
            padding: 12px;
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.2rem;
        }

        .quick-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--shadow);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-color), var(--info-color));
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            color: white;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--accent-color);
            margin: 10px 0;
        }

        .stat-label {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 8px;
        }

        .stat-trend {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 0.8rem;
        }

        .trend-up { color: var(--success-color); }
        .trend-down { color: var(--danger-color); }
        .trend-neutral { color: #666; }

        .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--shadow);
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .chart-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-color);
        }

        .chart-filter {
            padding: 5px 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.8rem;
            background: var(--bg-color);
        }

        .canvas-container {
            position: relative;
            height: 300px;
        }

        .activity-section {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
        }

        .activity-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--shadow);
        }

        .activity-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 2px solid var(--bg-color);
            padding-bottom: 15px;
        }

        .timeline-item {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            padding: 15px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .timeline-item:hover {
            background: var(--hover-color);
        }

        .timeline-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1rem;
            flex-shrink: 0;
        }

        .timeline-content h4 {
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .timeline-content p {
            font-size: 0.8rem;
            color: #666;
            line-height: 1.4;
        }

        .timeline-date {
            font-size: 0.7rem;
            color: #999;
            margin-top: 5px;
        }

        .notification-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            margin-bottom: 20px;
        }

        .notification-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .alert-item {
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 10px;
            transition: all 0.3s ease;
        }

        .alert-item:hover {
            background: rgba(255,255,255,0.2);
        }

        .pdf-btn {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background: var(--accent-color);
            color: white;
            border: none;
            padding: 15px 20px;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: var(--shadow);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .pdf-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.2);
        }

        .progress-bar {
            width: 100%;
            height: 8px;
            background: var(--bg-color);
            border-radius: 4px;
            overflow: hidden;
            margin: 10px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--accent-color), var(--success-color));
            transition: width 0.5s ease;
        }

        @media (max-width: 768px) {
            .charts-section {
                grid-template-columns: 1fr;
            }
            
            .activity-section {
                grid-template-columns: 1fr;
            }
            
            .header-content {
                grid-template-columns: 1fr;
                text-align: center;
            }
            
            .user-info h1 {
                font-size: 2rem;
            }
        }

        /* Animații pentru încărcare */
        .fade-in {
            animation: fadeIn 0.6s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .slide-in {
            animation: slideIn 0.8s ease-out;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-30px); }
            to { opacity: 1; transform: translateX(0); }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Header Section -->
        <div class="header-section fade-in">
            <div class="header-content">
                <div class="user-info">
                    <h1 id="userName">Vasile Fabian</h1>
                    <span class="user-role" id="userRole">Director HR</span>
                    <div class="current-date" id="currentDate">Vineri, 06 Iunie 2025</div>
                </div>
                <div class="quick-actions">
                    <button class="quick-btn" title="Notificări">
                        <i class="ri-notification-line"></i>
                    </button>
                    <button class="quick-btn" title="Setări">
                        <i class="ri-settings-line"></i>
                    </button>
                    <button class="quick-btn" title="Profil">
                        <i class="ri-user-line"></i>
                    </button>
                </div>
            </div>
        </div>

        <!-- Stats Grid -->
        <div class="stats-grid fade-in">
            <!-- Statistici Concedii -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Concedii Luate</div>
                        <div class="stat-value" id="concediiLuate">2</div>
                        <div class="stat-trend trend-up">
                            <i class="ri-arrow-up-line"></i>
                            <span>din 3 disponibile</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="background: var(--info-color);">
                        <i class="ri-calendar-check-line"></i>
                    </div>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 67%;"></div>
                </div>
            </div>

            <!-- Zile Concediu -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Zile Concediu</div>
                        <div class="stat-value" id="zileUsed">16</div>
                        <div class="stat-trend trend-neutral">
                            <i class="ri-calendar-line"></i>
                            <span>din 40 disponibile</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="background: var(--success-color);">
                        <i class="ri-time-line"></i>
                    </div>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: 40%;"></div>
                </div>
            </div>

            <!-- Proiecte Active -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Proiecte Active</div>
                        <div class="stat-value" id="proiecteActive">2</div>
                        <div class="stat-trend trend-up">
                            <i class="ri-arrow-up-line"></i>
                            <span>+1 față de luna trecută</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="background: var(--warning-color);">
                        <i class="ri-briefcase-line"></i>
                    </div>
                </div>
            </div>

            <!-- Salariu Curent -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Salariu Net</div>
                        <div class="stat-value" style="font-size: 1.8rem;" id="salariuNet">7,605 RON</div>
                        <div class="stat-trend trend-up">
                            <i class="ri-arrow-up-line"></i>
                            <span>Cu sporuri incluse</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="background: var(--success-color);">
                        <i class="ri-money-dollar-circle-line"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- Charts Section -->
        <div class="charts-section slide-in">
            <!-- Grafic Concedii -->
            <div class="chart-card">
                <div class="chart-header">
                    <h3 class="chart-title">Evoluția Concediilor</h3>
                    <select class="chart-filter">
                        <option>Ultimele 6 luni</option>
                        <option>Ultimul an</option>
                        <option>Tot timpul</option>
                    </select>
                </div>
                <div class="canvas-container">
                    <canvas id="concediiChart"></canvas>
                </div>
            </div>

            <!-- Grafic Status Concedii -->
            <div class="chart-card">
                <div class="chart-header">
                    <h3 class="chart-title">Status Concedii</h3>
                    <select class="chart-filter">
                        <option>Anul curent</option>
                        <option>Anul trecut</option>
                        <option>Totale</option>
                    </select>
                </div>
                <div class="canvas-container">
                    <canvas id="statusChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Activity Section -->
        <div class="activity-section slide-in">
            <!-- Activitate Recentă -->
            <div class="activity-card">
                <div class="activity-header">
                    <h3>Activitate Recentă</h3>
                    <button class="quick-btn" style="position: relative; background: var(--accent-color);">
                        <i class="ri-refresh-line"></i>
                    </button>
                </div>
                
                <div class="timeline-item">
                    <div class="timeline-icon" style="background: var(--success-color);">
                        <i class="ri-check-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Concediu aprobat</h4>
                        <p>Cererea ta de concediu pentru perioada 01-10 Iulie a fost aprobată de directorul de departament.</p>
                        <div class="timeline-date">Acum 2 ore</div>
                    </div>
                </div>

                <div class="timeline-item">
                    <div class="timeline-icon" style="background: var(--info-color);">
                        <i class="ri-file-text-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Task nou asignat</h4>
                        <p>Ai fost asignat la task-ul "Implementare modul HR" în proiectul ERP Implementation.</p>
                        <div class="timeline-date">Ieri, 14:30</div>
                    </div>
                </div>

                <div class="timeline-item">
                    <div class="timeline-icon" style="background: var(--warning-color);">
                        <i class="ri-star-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Evaluare performanță</h4>
                        <p>A fost programată evaluarea ta de performanță pentru săptămâna viitoare.</p>
                        <div class="timeline-date">25 Mai, 09:15</div>
                    </div>
                </div>

                <div class="timeline-item">
                    <div class="timeline-icon" style="background: var(--accent-color);">
                        <i class="ri-team-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Adăugat în echipă</h4>
                        <p>Ai fost adăugat în echipa "HR Management System" pentru proiectul de digitalizare.</p>
                        <div class="timeline-date">20 Mai, 16:45</div>
                    </div>
                </div>
            </div>

            <!-- Notificări și Alerte -->
            <div>
                <div class="notification-card">
                    <div class="notification-header">
                        <h3>Notificări</h3>
                        <span style="background: rgba(255,255,255,0.3); padding: 4px 8px; border-radius: 12px; font-size: 0.8rem;">3 noi</span>
                    </div>
                    
                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Ședință echipă</strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;">Mâine la ora 10:00</p>
                            </div>
                            <i class="ri-calendar-event-line"></i>
                        </div>
                    </div>

                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Deadline proiect</strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;">în 3 zile</p>
                            </div>
                            <i class="ri-alarm-warning-line"></i>
                        </div>
                    </div>

                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Adeverință gata</strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;">Poate fi ridicată</p>
                            </div>
                            <i class="ri-file-download-line"></i>
                        </div>
                    </div>
                </div>

                <!-- Progress Card pentru Proiecte -->
                <div class="activity-card">
                    <div class="activity-header">
                        <h3>Proiectele Tale</h3>
                    </div>
                    
                    <div style="margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                            <span style="font-weight: 600;">ERP Implementation</span>
                            <span style="color: var(--success-color); font-weight: 600;">75%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: 75%;"></div>
                        </div>
                        <p style="font-size: 0.8rem; color: #666; margin-top: 5px;">Deadline: 31 Dec 2025</p>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                            <span style="font-weight: 600;">HR Management System</span>
                            <span style="color: var(--warning-color); font-weight: 600;">45%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: 45%; background: linear-gradient(90deg, var(--warning-color), var(--accent-color));"></div>
                        </div>
                        <p style="font-size: 0.8rem; color: #666; margin-top: 5px;">Deadline: 31 Jul 2025</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- PDF Download Button -->
    <button class="pdf-btn" id="generatePDF">
        <i class="ri-download-line"></i>
        Descarcă PDF
    </button>

    <script>
        // Inițializare Dashboard
        document.addEventListener('DOMContentLoaded', function() {
            // Simulare date dinamice (în producție acestea vor veni din JSP/servletul Java)
            const userData = {
                nume: 'Vasile',
                prenume: 'Fabian',
                functie: 'Director HR',
                ierarhie: 2,
                concediiLuate: 2,
                concediiRamase: 1,
                zileLuate: 16,
                zileRamase: 24,
                salariuBrut: 13000,
                salariuNet: 7605,
                proiecteActive: 2
            };

            // Update informații user
            updateUserInfo(userData);
            
            // Inițializare grafice
            initializeCharts();
            
            // Setare dată curentă
            updateCurrentDate();
            
            // Event listeners
            setupEventListeners();
        });

        function updateUserInfo(data) {
            document.getElementById('userName').textContent = `${data.nume} ${data.prenume}`;
            document.getElementById('userRole').textContent = determineRole(data.ierarhie, data.functie);
            document.getElementById('concediiLuate').textContent = data.concediiLuate;
            document.getElementById('zileUsed').textContent = data.zileLuate;
            document.getElementById('proiecteActive').textContent = data.proiecteActive;
            document.getElementById('salariuNet').textContent = `${data.salariuNet.toLocaleString()} RON`;
        }

        function determineRole(ierarhie, functie) {
            if (ierarhie < 3) return `Director ${functie}`;
            if (ierarhie >= 4 && ierarhie <= 5) return `Șef ${functie}`;
            if (ierarhie >= 10) return `Stagiar ${functie}`;
            return functie;
        }

        function updateCurrentDate() {
            const now = new Date();
            const options = { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
            };
            document.getElementById('currentDate').textContent = 
                now.toLocaleDateString('ro-RO', options);
        }

        function initializeCharts() {
            // Grafic evoluție concedii
            const concediiCtx = document.getElementById('concediiChart').getContext('2d');
            new Chart(concediiCtx, {
                type: 'line',
                data: {
                    labels: ['Ian', 'Feb', 'Mar', 'Apr', 'Mai', 'Iun'],
                    datasets: [{
                        label: 'Zile Concediu',
                        data: [0, 5, 8, 12, 16, 16],
                        borderColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-color'),
                        backgroundColor: getComputedStyle(document.documentElement).getPropertyValue('--accent-color') + '20',
                        fill: true,
                        tension: 0.4,
                        pointRadius: 6,
                        pointHoverRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 40,
                            grid: {
                                color: '#f0f0f0'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // Grafic status concedii - Donut Chart
            const statusCtx = document.getElementById('statusChart').getContext('2d');
            new Chart(statusCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Aprobate Director', 'Aprobate Șef', 'În Așteptare', 'Respinse'],
                    datasets: [{
                        data: [2, 4, 1, 0],
                        backgroundColor: [
                            '#28a745',
                            '#17a2b8', 
                            '#ffc107',
                            '#dc3545'
                        ],
                        borderWidth: 0,
                        cutout: '60%'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true
                            }
                        }
                    }
                }
            });
        }

        function setupEventListeners() {
            // PDF generation
            document.getElementById('generatePDF').addEventListener('click', function() {
                // Simulare generare PDF
                this.innerHTML = '<i class="ri-loader-line"></i> Generez...';
                this.style.pointerEvents = 'none';
                
                setTimeout(() => {
                    this.innerHTML = '<i class="ri-check-line"></i> Gata!';
                    setTimeout(() => {
                        this.innerHTML = '<i class="ri-download-line"></i> Descarcă PDF';
                        this.style.pointerEvents = 'auto';
                    }, 2000);
                }, 3000);
            });

            // Refresh button pentru activitate
            document.querySelector('.activity-header button').addEventListener('click', function() {
                this.style.transform = 'rotate(360deg)';
                setTimeout(() => {
                    this.style.transform = 'rotate(0deg)';
                }, 500);
            });
        }

        // Simulare actualizări în timp real
        setInterval(() => {
            // Update random pentru demonstrație
            const stats = document.querySelectorAll('.stat-value');
            stats.forEach(stat => {
                stat.style.transform = 'scale(1.05)';
                setTimeout(() => {
                    stat.style.transform = 'scale(1)';
                }, 200);
            });
        }, 30000);
    </script>
</body>
</html>
 <%
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
               
                out.println("</script>");
               
                e.printStackTrace();
            }
        } else {
            out.println("<script type='text/javascript'>");
            out.println("alert('Utilizator neconectat!');");
            out.println("</script>");
            response.sendRedirect("logout");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
