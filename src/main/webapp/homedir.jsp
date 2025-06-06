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
            color: <%=text%>;
        }
        .header {
            background-color: <%=sidebar%>;
            padding: 20px;
            border-radius: 10px;
            color: <%=text%>;
            margin-bottom: 20px;
        }
        .card {
            
            padding: 20px;
            border-radius: 10px;
             background-color: <%=sidebar%>;
            margin-bottom: 20px;
            color: <%=text%>;
        }
        .card h3 {
            margin-bottom: 20px;
            color: <%=text%>;
        }
        .card .info div {
            margin-bottom: 10px;
            font-size: 16px;
            color: <%=text%>;
            
        }
        .card .info div span {
            font-weight: bold;
            color: <%=text%>;
        }
        .btn-primary {
            background-color: <%=clr%>;
            
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
            background: linear-gradient(135deg, <%=clr%>; 0%, <%=accent%> 100%);
            color: <%=text%>;
            min-height: 100vh;
            line-height: 1.6;
        }

        .dashboard-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        .header-section {
            background: linear-gradient(135deg, <%=accent%>, <%=clr%>);
            border-radius: 2rem;
            padding: 30px;
            margin-bottom: 30px;
            color: white;
           
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
            background: <%=clr%>;
            opacity: 50%;
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
            background: <%=accent%>;
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
            background: <%=accent%>;
            border: none;
            padding: 12px;
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
           
            font-size: 1.2rem;
        }

        .quick-btn:hover {
            background: black;
            transform: translateY(-2px);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: <%=sidebar%>;
            border-radius: 2rem;
            padding: 25px;
           
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, <%=accent%>, <%=sidebar%>);
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
            color: <%=accent%>;
            margin: 10px 0;
        }

        .stat-label {
            font-size: 0.9rem;
            color: <%=text%>;
            margin-bottom: 8px;
        }

        .stat-trend {
            display: flex;
            align-items: center;
            gap: 5px;
            font-size: 0.8rem;
            color: <%=text%>;
        }

        .trend-up { color: <%=text%>; }
        .trend-down { color: <%=text%>; }
        .trend-neutral { color: <%=text%>; }

        .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .chart-card {
            background: <%=sidebar%>;
            border-radius: 2rem;
            padding: 25px;
           
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
            color: <%=text%>;
        }

        .chart-filter {
            padding: 5px 10px;
            border: 1px solid <%=accent%>;
            border-radius: 6px;
            font-size: 0.8rem;
            background: <%=accent%>;
            color: white;
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
            background: <%=sidebar%>;
            border-radius: 2rem;
            padding: 25px;
           
        }

        .activity-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 2px solid <%=sidebar%>;
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
            background: <%=hover%>;
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
            background: <%=accent%>;
            color: white;
            border: none;
            padding: 15px 20px;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
           
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .pdf-btn:hover {
            transform: translateY(-3px);
            
        }

        .progress-bar {
            width: 100%;
            height: 8px;
            background: <%=accent%>;
            border-radius: 4px;
            overflow: hidden;
            margin: 10px 0;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, <%=sidebar%>, <%=accent%>);
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
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>; --text:<%=text%>; background:<%=clr%>">

    <%
    // Verifică dacă există concedii în ziua curentă care să aibă locații
    boolean hasLocationsForTodayLeaves = false;
    int todayLeavesCount = 0;
    int todayLeavesWithLocationCount = 0;

    try {
        // Interogare pentru a verifica concediile din ziua curentă folosind direct CURDATE()
        String checkQuery = "SELECT c.id FROM concedii c WHERE c.added = CURDATE() and c.id_ang =" + id;

        try (Connection connection2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
             PreparedStatement checkStmt = connection2.prepareStatement(checkQuery)) {
            
            try (ResultSet checkRs = checkStmt.executeQuery()) {
                // Numără concediile din ziua curentă
                while (checkRs.next()) {
                    todayLeavesCount++;

                    // Pentru fiecare concediu, verifică dacă are o locație
                    int concediuId = checkRs.getInt("id");
                    String locatieQuery = "SELECT COUNT(*) AS count FROM locatii_concedii join concedii on locatii_concedii.id_concediu = concedii.id join useri on concedii.id_Ang = useri.id WHERE id_concediu = ? and useri.id = " + id;

                    try (PreparedStatement locatieStmt = connection2.prepareStatement(locatieQuery)) {
                        locatieStmt.setInt(1, concediuId);
                        try (ResultSet locatieRs = locatieStmt.executeQuery()) {
                            if (locatieRs.next() && locatieRs.getInt("count") > 0) {
                                todayLeavesWithLocationCount++;
                            }
                        }
                    }
                }
            }
        }

        // Există locații pentru concediile din ziua curentă dacă cel puțin un concediu are locație
        hasLocationsForTodayLeaves = (todayLeavesWithLocationCount > 0);

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script type='text/javascript'>");
        out.println("console.error('Eroare la verificarea concediilor: " + e.getMessage() + "');");
        out.println("</script>");
    }
    %>

    <!-- Alertă pentru concedii fără locații -->
    <% if (todayLeavesCount > todayLeavesWithLocationCount) { %>
    <div id="noLocationsBanner" style="
        position: fixed;
        top: 10px;
        left: 50%;
        transform: translateX(-50%);
        z-index: 9999;
        background-color: <%= accent %>;
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        font-family: 'Poppins', sans-serif;
        display: flex;
        align-items: center;
        gap: 10px;
        width: 80%;
        max-width: 600px;
    ">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="min-width: 24px;">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
        </svg>
        <div>
            <strong>Atenție!</strong> Există <%= todayLeavesCount %> concedii adăugate astăzi, dar numai <%=todayLeavesWithLocationCount %> are locație asociată.
        </div>
        <button onclick="document.getElementById('noLocationsBanner').style.display='none';" style="
            background: transparent;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 20px;
            margin-left: 10px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        ">&times;</button>
    </div>
    <% } %>

    <div class="dashboard-container">
        <!-- Header Section -->
        <div class="header-section fade-in">
            <div class="header-content">
                <div class="user-info">
                    <h1 id="userName"><%=rs.getString("nume")%> <%=rs.getString("prenume")%></h1>
                    <span class="user-role" id="userRole">
                        <%
                        if (isDirector) {
                            out.println("Director " + functie);
                        } else if (isSef) {
                            out.println("Șef " + functie);
                        } else if (isIncepator) {
                            out.println("Stagiar " + functie);
                        } else {
                            out.println(functie);
                        }
                        %>
                    </span>
                    <div class="current-date" id="currentDate">
                        <%
                        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                             PreparedStatement preparedStatement2 = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%W, %d %M %Y') as today")) {
                            ResultSet rs2 = preparedStatement2.executeQuery();
                            if (rs2.next()) {
                                out.println(rs2.getString("today"));
                            }
                        } catch (SQLException e) {
                            out.println("Data curentă");
                        }
                        %>
                    </div>
                </div>
                <div class="quick-actions">
                    <button class="quick-btn" title="Info">
                        <a style="text-decoration:none; color: white;" href="faq.jsp"><i class="ri-question-mark"></i></a>
                    </button>
                    <button class="quick-btn" title="Setări">
                       <a style="text-decoration:none; color: white;" href="setari.jsp"> <i class="ri-settings-line"></i></a>
                    </button>
                    <button class="quick-btn" title="Profil">
                       <a style="text-decoration:none; color: white;" href="despr.jsp"> <i class="ri-user-line"></i> </a>
                       
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
                        <div class="stat-value" id="concediiLuate">
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT conluate FROM useri WHERE id = ?")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next()) {
                                    out.println(rs1.getString("conluate"));
                                } else {
                                    out.println("0");
                                }
                            } catch (SQLException e) {
                                out.println("0");
                            }
                            %>
                        </div>
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
                    <%
                    int conluate = 0;
                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                         PreparedStatement stmt = connection.prepareStatement("SELECT conluate FROM useri WHERE id = ?")) {
                        stmt.setInt(1, id);
                        ResultSet rs1 = stmt.executeQuery();
                        if (rs1.next()) {
                            conluate = rs1.getInt("conluate");
                        }
                    } catch (SQLException e) {
                        // Handle error
                    }
                    double progressPercent = (conluate / 3.0) * 100;
                    %>
                    <div class="progress-fill" style="width: <%=progressPercent%>%;"></div>
                </div>
            </div>

            <!-- Zile Concediu -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Zile Concediu</div>
                        <div class="stat-value" id="zileUsed">
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT zilecons, zileramase FROM useri WHERE id = ?")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next()) {
                                    out.println(rs1.getString("zilecons"));
                                } else {
                                    out.println("0");
                                }
                            } catch (SQLException e) {
                                out.println("0");
                            }
                            %>
                        </div>
                        <div class="stat-trend trend-neutral">
                            <i class="ri-calendar-line"></i>
                            <span>din 
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT zilecons, zileramase FROM useri WHERE id = ?")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next()) {
                                    int zilecons = rs1.getInt("zilecons");
                                    int zileramase = rs1.getInt("zileramase");
                                    out.println(zilecons + zileramase);
                                } else {
                                    out.println("40");
                                }
                            } catch (SQLException e) {
                                out.println("40");
                            }
                            %> disponibile</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="background: var(--success-color);">
                        <i class="ri-time-line"></i>
                    </div>
                </div>
                <div class="progress-bar">
                    <%
                    int zilecons = 0;
                    int totalZile = 40;
                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                         PreparedStatement stmt = connection.prepareStatement("SELECT zilecons, zileramase FROM useri WHERE id = ?")) {
                        stmt.setInt(1, id);
                        ResultSet rs1 = stmt.executeQuery();
                        if (rs1.next()) {
                            zilecons = rs1.getInt("zilecons");
                            int zileramase = rs1.getInt("zileramase");
                            totalZile = zilecons + zileramase;
                        }
                    } catch (SQLException e) {
                        // Handle error
                    }
                    double zileProgressPercent = totalZile > 0 ? (zilecons / (double)totalZile) * 100 : 0;
                    %>
                    <div class="progress-fill" style="width: <%=zileProgressPercent%>%;"></div>
                </div>
            </div>

            <!-- Proiecte Active -->
            <div class="stat-card">
                <div class="stat-header">
                    <div>
                        <div class="stat-label">Proiecte Active</div>
                        <div class="stat-value" id="proiecteActive">
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT COUNT(DISTINCT p.id) as total FROM proiecte p JOIN echipe e ON p.id = e.id_prj JOIN membrii_echipe me ON e.id = me.id_echipa WHERE me.id_ang = ? AND p.start <= CURDATE() AND p.end >= CURDATE()")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next()) {
                                    out.println(rs1.getString("total"));
                                } else {
                                    out.println("0");
                                }
                            } catch (SQLException e) {
                                out.println("0");
                            }
                            %>
                        </div>
                        <div class="stat-trend trend-up">
                            <i class="ri-arrow-up-line"></i>
                           
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
                        <div class="stat-value" style="font-size: 1.8rem;" id="salariuNet">
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT salariu_net FROM istoric_fluture WHERE id_ang = ? ORDER BY an DESC, luna DESC LIMIT 1")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next()) {
                                    out.println(String.format("%,.0f RON", rs1.getDouble("salariu_net")));
                                } else {
                                    // Fallback la salariul din tipuri
                                    try (PreparedStatement stmt2 = connection.prepareStatement("SELECT t.salariu FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE u.id = ?")) {
                                        stmt2.setInt(1, id);
                                        ResultSet rs2 = stmt2.executeQuery();
                                        if (rs2.next()) {
                                            double salariuBrut = rs2.getDouble("salariu");
                                            double salariuNet = salariuBrut * 0.585; // Aprox calculation
                                            out.println(String.format("%,.0f RON", salariuNet));
                                        } else {
                                            out.println("N/A");
                                        }
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("N/A");
                            }
                            %>
                        </div>
                        <div class="stat-trend trend-up">
                            <i class="ri-arrow-up-line"></i>
                            <span>
                            <%
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                 PreparedStatement stmt = connection.prepareStatement("SELECT COUNT(*) as sporuri FROM istoric_sporuri WHERE id_ang = ? AND data_start <= CURDATE() AND data_final >= CURDATE()")) {
                                stmt.setInt(1, id);
                                ResultSet rs1 = stmt.executeQuery();
                                if (rs1.next() && rs1.getInt("sporuri") > 0) {
                                    out.println("Cu " + rs1.getInt("sporuri") + " spor(uri)");
                                } else {
                                    out.println("Salariu de bază");
                                }
                            } catch (SQLException e) {
                                out.println("Salariu curent");
                            }
                            %>
                            </span>
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
                    <button class="quick-btn" style="position: relative; background: <%=accent%>;;">
                        <i class="ri-refresh-line"></i>
                    </button>
                </div>
                
                <%
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement stmt = connection.prepareStatement("SELECT c.id, c.start_c, c.end_c, c.motiv, s.nume_status, c.added, c.modified FROM concedii c JOIN statusuri s ON c.status = s.status WHERE c.id_ang = ? ORDER BY c.modified DESC, c.added DESC LIMIT 3")) {
                    stmt.setInt(1, id);
                    ResultSet rs3 = stmt.executeQuery();
                    while (rs3.next()) {
                        String status = rs3.getString("nume_status");
                        String iconClass = "";
                        String bgColor = "";
                        
                        if (status.contains("Aprobat")) {
                            iconClass = "ri-check-line";
                            bgColor = "var(--success-color)";
                        } else if (status.contains("Respins")) {
                            iconClass = "ri-close-line";
                            bgColor = "var(--danger-color)";
                        } else {
                            iconClass = "ri-time-line";
                            bgColor = "var(--warning-color)";
                        }
                %>
                
                <div class="timeline-item">
                    <div class="timeline-icon" style="background: <%=bgColor%>;">
                        <i class="<%=iconClass%>"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Concediu <%=status.toLowerCase()%></h4>
                        <p><%=rs3.getString("motiv")%> pentru perioada <%=rs3.getDate("start_c")%> - <%=rs3.getDate("end_c")%></p>
                        <div class="timeline-date"><%=rs3.getTimestamp("modified") != null ? rs3.getTimestamp("modified") : rs3.getTimestamp("added")%></div>
                    </div>
                </div>
                
                <%
                    }
                } catch (SQLException e) {
                    // Fallback content
                %>
                <div class="timeline-item">
                    <div class="timeline-icon" style="background: var(--info-color);">
                        <i class="ri-information-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Bun venit!</h4>
                        <p>Explorează dashboard-ul pentru a vedea statistici și activități recente.</p>
                        <div class="timeline-date">Acum</div>
                    </div>
                </div>
                <%
                }
                %>

                <%
                // Task-uri recente
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement stmt = connection.prepareStatement("SELECT t.nume, t.start, t.end, s.procent FROM tasks t LEFT JOIN statusuri2 s ON t.status = s.id WHERE t.id_ang = ? ORDER BY t.start DESC LIMIT 2")) {
                    stmt.setInt(1, id);
                    ResultSet rs4 = stmt.executeQuery();
                    while (rs4.next()) {
                %>
                
                <div class="timeline-item">
                    <div class="timeline-icon" style="background: <%=accent%>;;">
                        <i class="ri-task-line"></i>
                    </div>
                    <div class="timeline-content">
                        <h4>Task: <%=rs4.getString("nume")%></h4>
                        <p>Progres: <%=rs4.getInt("procent")%>% - Deadline: <%=rs4.getDate("end")%></p>
                        <div class="timeline-date"><%=rs4.getDate("start")%></div>
                    </div>
                </div>
                
                <%
                    }
                } catch (SQLException e) {
                    // Handle error silently
                }
                %>
            </div>

            <!-- Notificări și Alerte -->
            <!-- 
            <div>
                <div class="notification-card">
                    <div class="notification-header">
                        <h3>Notificări</h3>
                        <%
                        int notificariCount = 0;
                        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                             PreparedStatement stmt = connection.prepareStatement("SELECT COUNT(*) as count FROM notificari_general WHERE id_destinatar = ? AND citit = FALSE")) {
                            stmt.setInt(1, id);
                            ResultSet rs5 = stmt.executeQuery();
                            if (rs5.next()) {
                                notificariCount = rs5.getInt("count");
                            }
                        } catch (SQLException e) {
                            // Handle error
                        }
                        %>
                        <span style="background: rgba(255,255,255,0.3); padding: 4px 8px; border-radius: 12px; font-size: 0.8rem;"><%=notificariCount%> noi</span>
                    </div>
                   
                    <%
                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                         PreparedStatement stmt = connection.prepareStatement("SELECT tip, mesaj, data_creare FROM notificari_general WHERE id_destinatar = ? ORDER BY data_creare DESC LIMIT 3")) {
                        stmt.setInt(1, id);
                        ResultSet rs6 = stmt.executeQuery();
                        while (rs6.next()) {
                            String tip = rs6.getString("tip");
                            String icon = "";
                            
                            if (tip.contains("SEDINTA") || tip.contains("MEETING")) {
                                icon = "ri-calendar-event-line";
                            } else if (tip.contains("DEADLINE") || tip.contains("URGENT")) {
                                icon = "ri-alarm-warning-line";
                            } else {
                                icon = "ri-information-line";
                            }
                    %>
                    
                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong><%=tip%></strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;"><%=rs6.getString("mesaj")%></p>
                            </div>
                            <i class="<%=icon%>"></i>
                        </div>
                    </div>
                    
                    <%
                        }
                        if (notificariCount == 0) {
                    %>
                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Nicio notificare</strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;">Toate notificările sunt la zi</p>
                            </div>
                            <i class="ri-check-line"></i>
                        </div>
                    </div>
                    <%
                        }
                    } catch (SQLException e) {
                        // Fallback content
                    %>
                    <div class="alert-item">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div>
                                <strong>Sistem activ</strong>
                                <p style="margin: 5px 0; font-size: 0.85rem;">Dashboard funcționează normal</p>
                            </div>
                            <i class="ri-check-line"></i>
                        </div>
                    </div>
                    <%
                    }
                    %>
                </div>
                  -->

                <!-- Progress Card pentru Proiecte -->
                <div class="activity-card">
                    <div class="activity-header">
                        <h3>Proiectele Tale</h3>
                    </div>
                    
                    <%
                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                         PreparedStatement stmt = connection.prepareStatement(
                             "SELECT DISTINCT p.nume, p.start, p.end, " +
                             "COUNT(t.id) as total_tasks, " +
                             "AVG(IFNULL(s.procent, 0)) as avg_progress " +
                             "FROM proiecte p " +
                             "JOIN echipe e ON p.id = e.id_prj " +
                             "JOIN membrii_echipe me ON e.id = me.id_echipa " +
                             "LEFT JOIN tasks t ON p.id = t.id_prj AND t.id_ang = ? " +
                             "LEFT JOIN statusuri2 s ON t.status = s.id " +
                             "WHERE me.id_ang = ? AND p.start <= CURDATE() AND p.end >= CURDATE() " +
                             "GROUP BY p.id, p.nume, p.start, p.end " +
                             "LIMIT 2")) {
                        stmt.setInt(1, id);
                        stmt.setInt(2, id);
                        ResultSet rs7 = stmt.executeQuery();
                        
                        boolean hasProjects = false;
                        while (rs7.next()) {
                            hasProjects = true;
                            String numeProiect = rs7.getString("nume");
                            Date deadline = rs7.getDate("end");
                            double progress = rs7.getDouble("avg_progress");
                            
                            String progressColor = "var(--success-color)";
                            if (progress < 30) {
                                progressColor = "var(--danger-color)";
                            } else if (progress < 70) {
                                progressColor = "var(--warning-color)";
                            }
                    %>
                    
                    <div style="margin-bottom: 20px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                            <span style="font-weight: 600;"><%=numeProiect%></span>
                            <span style="color: <%=progressColor%>; font-weight: 600;"><%=String.format("%.0f", progress)%>%</span>
                        </div>
                        <div class="progress-bar">
                            <div class="progress-fill" style="width: <%=progress%>%; background: linear-gradient(90deg, <%=progressColor%>, <%=accent%>;);"></div>
                        </div>
                        <p style="font-size: 0.8rem; color: #666; margin-top: 5px;">Deadline: <%=deadline%></p>
                    </div>
                    
                    <%
                        }
                        
                        if (!hasProjects) {
                    %>
                    <div style="text-align: center; padding: 20px; color: #666;">
                        <i class="ri-briefcase-line" style="font-size: 2rem; margin-bottom: 10px; display: block;"></i>
                        <p>Nu ai proiecte active momentan</p>
                    </div>
                    <%
                        }
                    } catch (SQLException e) {
                        // Fallback content
                    %>
                    <div style="text-align: center; padding: 20px; color: #666;">
                        <i class="ri-error-warning-line" style="font-size: 2rem; margin-bottom: 10px; display: block;"></i>
                        <p>Eroare la încărcarea proiectelor</p>
                    </div>
                    <%
                    }
                    %>
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
        // Inițializare Dashboard cu date din JSP
        document.addEventListener('DOMContentLoaded', function() {
        	
        	function hexToRgba(hex, alpha) {
        	    hex = hex.replace('#', '');
        	    if (hex.length === 3) {
        	        hex = hex.split('').map(c => c + c).join('');
        	    }
        	    const r = parseInt(hex.substring(0, 2), 16);
        	    const g = parseInt(hex.substring(2, 4), 16);
        	    const b = parseInt(hex.substring(4, 6), 16);
        	    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
        	}

        	document.addEventListener('DOMContentLoaded', () => {
        	    const btn = document.querySelector('.quick-btn');
        	    const computedColor = getComputedStyle(btn).backgroundColor;

        	    // Convert doar dacă e hex — aici presupunem că inițial e hex (de ex: #007bff injectat ca stil inline/server)
        	    // Alternativ, folosește deja valoarea RGB obținută
        	    if (computedColor.startsWith('rgb') && !computedColor.startsWith('rgba')) {
        	        const rgba = computedColor.replace('rgb', 'rgba').replace(')', ', 0.25)');
        	        btn.style.backgroundColor = rgba;
        	    }

        	    // Dacă știi sigur că e hex:
        	    // const rgba = hexToRgba('<%=accent%>', 0.25);
        	    // btn.style.backgroundColor = rgba;
        	});
        	
            // Date preluate din JSP
            const userData = {
                nume: '<%=rs.getString("nume")%>',
                prenume: '<%=rs.getString("prenume")%>',
                functie: '<%=functie%>',
                ierarhie: <%=ierarhie%>,
                id: <%=id%>
            };

           
            // Inițializare grafice cu date reale
            initializeCharts();
            
            // Event listeners
            setupEventListeners();
        });

        function initializeCharts() {
            // Grafic evoluție concedii cu date din JSP
            const concediiCtx = document.getElementById('concediiChart').getContext('2d');
            const gradient = concediiCtx.createLinearGradient(0, 0, 0, 400);
            gradient.addColorStop(0, '<%=accent%>');       // Start color
            gradient.addColorStop(1, '<%=clr%>');    // End color
            
            // Preluare date pentru grafic (ar trebui să vină din JSP cu un query separat)
            <%
            // Query pentru ultimele 6 luni de concedii
            String concediiData = "[0, 0, 0, 0, 0, 0]"; // Default
            String labelsData = "['Ian', 'Feb', 'Mar', 'Apr', 'Mai', 'Iun']"; // Default
            
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement stmt = connection.prepareStatement(
                     "SELECT " +
                     "SUM(CASE WHEN MONTH(start_c) = 1 THEN durata ELSE 0 END) as ian, " +
                     "SUM(CASE WHEN MONTH(start_c) = 2 THEN durata ELSE 0 END) as feb, " +
                     "SUM(CASE WHEN MONTH(start_c) = 3 THEN durata ELSE 0 END) as mar, " +
                     "SUM(CASE WHEN MONTH(start_c) = 4 THEN durata ELSE 0 END) as apr, " +
                     "SUM(CASE WHEN MONTH(start_c) = 5 THEN durata ELSE 0 END) as mai, " +
                     "SUM(CASE WHEN MONTH(start_c) = 6 THEN durata ELSE 0 END) as iun " +
                     "FROM concedii WHERE id_ang = ? AND YEAR(start_c) = YEAR(CURDATE()) AND status >= 0")) {
                stmt.setInt(1, id);
                ResultSet rs8 = stmt.executeQuery();
                if (rs8.next()) {
                    concediiData = String.format("[%d, %d, %d, %d, %d, %d]",
                        rs8.getInt("ian"), rs8.getInt("feb"), rs8.getInt("mar"),
                        rs8.getInt("apr"), rs8.getInt("mai"), rs8.getInt("iun"));
                }
            } catch (SQLException e) {
                // Use default data
            }
            %>
            
            new Chart(concediiCtx, {
                type: 'line',
                data: {
                    labels: <%=labelsData%>,
                    datasets: [{
                        label: 'Zile Concediu',
                        data: <%=concediiData%>,
                        borderColor: '<%=accent%>',
                        backgroundColor: gradient,
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

            // Grafic status concedii - Donut Chart cu date reale
            const statusCtx = document.getElementById('statusChart').getContext('2d');
            
            <%
            // Query pentru statusurile concediilor
            int[] statusCounts = {0, 0, 0, 0}; // [aprobate_director, aprobate_sef, in_asteptare, respinse]
            
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement stmt = connection.prepareStatement("SELECT status, COUNT(*) as count FROM concedii WHERE id_ang = ? GROUP BY status")) {
                stmt.setInt(1, id);
                ResultSet rs9 = stmt.executeQuery();
                while (rs9.next()) {
                    int status = rs9.getInt("status");
                    int count = rs9.getInt("count");
                    
                    if (status == 2) statusCounts[0] = count; // Aprobate director
                    else if (status == 1) statusCounts[1] = count; // Aprobate sef
                    else if (status == 0) statusCounts[2] = count; // In asteptare
                    else if (status < 0) statusCounts[3] += count; // Respinse
                }
            } catch (SQLException e) {
                // Use default data
            }
            %>
            
            new Chart(statusCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Aprobate Director', 'Aprobate Șef', 'În Așteptare', 'Respinse'],
                    datasets: [{
                        data: [<%=statusCounts[0]%>, <%=statusCounts[1]%>, <%=statusCounts[2]%>, <%=statusCounts[3]%>],
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
            // PDF generation cu funcționalitatea existentă
            document.getElementById('generatePDF').addEventListener('click', function() {
                const element = document.querySelector('.dashboard-container');
                
                // Verificăm dacă html2pdf este disponibil (din JSP original)
                if (typeof html2pdf !== 'undefined') {
                    html2pdf().set({
                        pagebreak: { mode: ['css', 'legacy'] },
                        html2canvas: {
                            scale: 1,
                            logging: true,
                            dpi: 192,
                            letterRendering: true,
                            useCORS: true
                        },
                        jsPDF: {
                            unit: 'in',
                            format: 'a4',
                            orientation: 'portrait'
                        }
                    }).from(element).save('Dashboard-<%=rs.getString("nume")%>-<%=rs.getString("prenume")%>.pdf');
                } else {
                    // Fallback pentru simulare
                    this.innerHTML = '<i class="ri-loader-line"></i> Generez...';
                    this.style.pointerEvents = 'none';
                    
                    setTimeout(() => {
                        this.innerHTML = '<i class="ri-check-line"></i> Gata!';
                        setTimeout(() => {
                            this.innerHTML = '<i class="ri-download-line"></i> Descarcă PDF';
                            this.style.pointerEvents = 'auto';
                        }, 2000);
                    }, 3000);
                }
            });

            // Refresh button pentru activitate
            const refreshBtn = document.querySelector('.activity-header button');
            if (refreshBtn) {
                refreshBtn.addEventListener('click', function() {
                    this.style.transform = 'rotate(360deg)';
                    setTimeout(() => {
                        this.style.transform = 'rotate(0deg)';
                        // Refresh pagina pentru date noi
                        location.reload();
                    }, 500);
                });
            }
        }

        // Animații pentru stats la încărcare
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(() => {
                const stats = document.querySelectorAll('.stat-value');
                stats.forEach((stat, index) => {
                    setTimeout(() => {
                        stat.style.transform = 'scale(1.1)';
                        setTimeout(() => {
                            stat.style.transform = 'scale(1)';
                        }, 300);
                    }, index * 100);
                });
            }, 500);
        });
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
