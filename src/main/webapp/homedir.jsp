<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
SimpleDateFormat dateFormatter = new SimpleDateFormat("dd.MM.yyyy");
SimpleDateFormat dateFormatterRO = new SimpleDateFormat("dd MMMM yyyy", new java.util.Locale("ro", "RO"));

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
                    int iddep = rs.getInt("id_dep");
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
                        <%
// Verifică și creează tema pentru director dacă nu există
if (accent == null || sidebar == null || text == null) {
    System.out.println("Tema lipsește pentru directorul: " + id);
    
    try (Connection themeConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
        // Verifică dacă există tema
        String checkThemeQuery = "SELECT COUNT(*) as count FROM teme WHERE id_usr = ?";
        try (PreparedStatement checkStmt = themeConn.prepareStatement(checkThemeQuery)) {
            checkStmt.setInt(1, id);
            try (ResultSet checkRs = checkStmt.executeQuery()) {
                if (checkRs.next() && checkRs.getInt("count") == 0) {
                    // Creează tema implicit
                    String insertThemeQuery = "INSERT INTO teme (id_usr, accent, clr, sidebar, card, text, hover) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement insertStmt = themeConn.prepareStatement(insertThemeQuery)) {
                        insertStmt.setInt(1, id);
                        insertStmt.setString(2, "#10439F");  // accent
                        insertStmt.setString(3, "#d8d9e1");  // clr
                        insertStmt.setString(4, "#ECEDFA");  // sidebar
                        insertStmt.setString(5, "#ECEDFA");  // card
                        insertStmt.setString(6, "#333");     // text
                        insertStmt.setString(7, "#ECEDFA");  // hover
                        insertStmt.executeUpdate();
                        
                        System.out.println("Tema creată pentru directorul: " + id);
                        
                        // Setează variabilele
                        accent = "#10439F";
                        clr = "#d8d9e1";
                        sidebar = "#ECEDFA";
                        text = "#333";
                        card = "#ECEDFA";
                        hover = "#ECEDFA";
                    }
                }
            }
        }
    } catch (SQLException e) {
        System.out.println("Eroare la crearea temei: " + e.getMessage());
        // Setează valori default
        accent = "#10439F";
        clr = "#d8d9e1";
        sidebar = "#ECEDFA";
        text = "#333";
        card = "#ECEDFA";
        hover = "#ECEDFA";
    }
}

// Verifică din nou și setează valori default dacă încă sunt null
if (accent == null) accent = "#10439F";
if (clr == null) clr = "#d8d9e1";
if (sidebar == null) sidebar = "#ECEDFA";
if (text == null) text = "#333";
if (card == null) card = "#ECEDFA";
if (hover == null) hover = "#ECEDFA";

System.out.println("Tema finală pentru user " + id + ": accent=" + accent + ", sidebar=" + sidebar + ", text=" + text);
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
        :root {
    --bg: <%=accent != null ? accent : "#10439F"%>;
    --clr: <%=clr != null ? clr : "#d8d9e1"%>;
    --sd: <%=sidebar != null ? sidebar : "#ECEDFA"%>;
    --text: <%=text != null ? text : "#333"%>;
    --succes-color: #28a745;
    --danger-color: #dc3545;
    --waining-color: #ffc107;
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
        
        .pdf-section {
    margin-bottom: 30px;
}

.pdf-preview {
    background: <%=clr%>;
    border: 2px dashed <%=accent%>;
    padding: 20px;
}

.pdf-icon {
    background: linear-gradient(135deg, <%=clr%>,<%=accent%>);
    border-radius: 2rem;
    /* PDF colors */
}
.pdf-btn-integrated {
    background: <%=accent%>;
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    transition: all 0.3s ease;
}

.pdf-btn-integrated:hover {
    background: black;
    transform: translateY(-1px);
}

.pdf-preview {
    background: <%=clr%>;
    border: 2px dashed <%=accent%>;
    padding: 20px;
    border-radius: 8px;
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
                      
                            out.println(functie);
                       
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
                     <button class="quick-btn" title="Profil">
                       <a style="text-decoration:none; color: white;" href="cvmanagement.jsp"> <i class="ri-user-line"></i> </a>
                       
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
                        <div class="stat-trend trend-up" >
                            <i class="ri-arrow-up-line" style="color: <%=accent%>;"></i>
                            <span>din 3 disponibile</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="color: <%=accent%>;">
                        <i class="ri-calendar-check-line" ></i>
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
                            <i class="ri-calendar-line" style="color: <%=accent%>;"></i>
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
                                out.println("30");
                            }
                            %> disponibile</span>
                        </div>
                    </div>
                    <div class="stat-icon" style="color: <%=accent%>;">
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
                        <div class="stat-trend trend-up" style="color: <%=accent%>;">
                            <i class="ri-arrow-up-line"></i>
                           
                        </div>
                    </div>
                    <div class="stat-icon" style="color: <%=accent%>;">
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
                            <i style="color:<%=accent%>;" class="ri-arrow-up-line"></i>
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
                    <div class="stat-icon" style="color: <%=accent%>;">
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
                    <select class="chart-filter" id="concediiFilter">
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
                    <select class="chart-filter" id="concediiFilter">
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
     PreparedStatement stmt = connection.prepareStatement(
         "SELECT c.id, c.start_c, c.end_c, c.motiv, s.nume_status, " +
         "DATE(c.added) as data_adaugare, " +
         "DATE(c.modified) as data_modificare " +
         "FROM concedii c " +
         "JOIN statusuri s ON c.status = s.status " +
         "WHERE c.id_ang = ? " +
         "ORDER BY c.modified DESC, c.added DESC LIMIT 3")) {
    
    stmt.setInt(1, id);
    ResultSet rs3 = stmt.executeQuery();
    
    while (rs3.next()) {
        String status = rs3.getString("nume_status");
        String iconClass = "";
        String accentColor = "";
        
        if (status.contains("Aprobat")) {
            iconClass = "ri-check-line";
            accentColor = "var(--success-color)";
        } else if (status.contains("Respins")) {
            iconClass = "ri-close-line";
            accentColor = "var(--danger-color)";
        } else {
            iconClass = "ri-time-line";
            accentColor = "var(--warning-color)";
        }
        
        // Folosește data_modificare pentru afișare (fără oră)
        Date dataAfisare = rs3.getDate("data_modificare");
        if (dataAfisare == null) {
            dataAfisare = rs3.getDate("data_adaugare");
        }
%>

<div class="timeline-item">
    <div class="timeline-icon" style="background: <%=accentColor%>;">
        <i class="<%=iconClass%>"></i>
    </div>
    <div class="timeline-content">
        <h4>Concediu <%=status.toLowerCase()%></h4>
        <p><%=rs3.getString("motiv")%> pentru perioada <%=dateFormatter.format(rs3.getDate("start_c"))%> - <%=dateFormatter.format(rs3.getDate("end_c"))%></p>
        <div class="timeline-date"><%=dateFormatterRO.format(dataAfisare)%></div>
    </div>
</div>

<%
    }
} catch (SQLException e) {
    // Handle error
}
%>

<%
// Pentru tasks - modifică și această secțiune:
try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
     PreparedStatement stmt = connection.prepareStatement(
         "SELECT t.nume, t.start, t.end, s.procent " +
         "FROM tasks t " +
         "LEFT JOIN statusuri2 s ON t.status = s.id " +
         "WHERE t.id_ang = ? " +
         "ORDER BY t.start DESC LIMIT 2")) {
    
    stmt.setInt(1, id);
    ResultSet rs4 = stmt.executeQuery();
    
    while (rs4.next()) {
%>

<div class="timeline-item">
    <div class="timeline-icon" style="background: <%=accent%>;">
        <i class="ri-task-line"></i>
    </div>
    <div class="timeline-content">
        <h4>Task: <%=rs4.getString("nume")%></h4>
        <p>Progres: <%=rs4.getInt("procent")%>% - Deadline: <%=dateFormatter.format(rs4.getDate("end"))%></p>
        <div class="timeline-date"><%=dateFormatterRO.format(rs4.getDate("start"))%></div>
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
                        <h3>Proiectele mele</h3>
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
                           <!-- PDF Download Button -->
                           </div>
     
                
                
        <!-- PDF Report Section -->
        <div class="pdf-section slide-in">
            <div class="chart-card">
                <div class="chart-header">
                    <h3 class="chart-title">
                        <i class="ri-file-text-line"></i>
                        Raport Personal
                    </h3>
                    <div style="display: flex; gap: 10px; align-items: center;">
                        <select class="chart-filter" id="reportType">
                            <option value="lunar">Raport Lunar</option>
                            <option value="trimestrial">Raport Trimestrial</option>
                            <option value="anual">Raport Anual</option>
                            <option value="complet">Raport Complet</option>
                        </select>
                        <button class="pdf-btn-integrated" id="generatePDF" type="button" onclick="generatePDFReport()">
                            <i class="ri-download-line"></i>
                            Generează PDF
                        </button>
                    </div>
                </div>
                
                <div class="pdf-preview">
                    <div class="pdf-info">
                        <div class="pdf-icon">
                            <i class="ri-file-pdf-line"></i>
                        </div>
                        <div class="pdf-details">
                            <h4>Raport Activitate - <%=rs.getString("nume")%> <%=rs.getString("prenume")%></h4>
                            <p>Raportul va include: statistici concedii, proiecte active, tasks, istoric salarizare și activitate recentă</p>
                            <div class="pdf-meta">
                                <span><i class="ri-calendar-line"></i> 
                                <%
                                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                     PreparedStatement preparedStatement2 = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%d %M %Y') as today")) {
                                    ResultSet rs2 = preparedStatement2.executeQuery();
                                    if (rs2.next()) {
                                        out.println(rs2.getString("today"));
                                    }
                                } catch (SQLException e) {
                                    out.println("Data curentă");
                                }
                                %>
                                </span>
                                <span><i class="ri-user-line"></i> <%=functie%></span>
                                <span><i class="ri-building-line"></i> <%=rs.getString("nume_dep")%></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
 
<%
// Date pentru ultimele 6 luni - FĂRĂ GROUP BY status
String[] luni6 = {"Ian", "Feb", "Mar", "Apr", "Mai", "Iun"};
int[] data6Luni = new int[6];

String query6Luni = "SELECT " +
        "SUM(CASE WHEN MONTH(start_c) = 1 THEN durata ELSE 0 END) as ian, " +
        "SUM(CASE WHEN MONTH(start_c) = 2 THEN durata ELSE 0 END) as feb, " +
        "SUM(CASE WHEN MONTH(start_c) = 3 THEN durata ELSE 0 END) as mar, " +
        "SUM(CASE WHEN MONTH(start_c) = 4 THEN durata ELSE 0 END) as apr, " +
        "SUM(CASE WHEN MONTH(start_c) = 5 THEN durata ELSE 0 END) as mai, " +
        "SUM(CASE WHEN MONTH(start_c) = 6 THEN durata ELSE 0 END) as iun " +
        "FROM concedii JOIN useri ON concedii.id_ang = useri.id " +
        "WHERE YEAR(start_c) = YEAR(CURDATE()) AND status >= 0";

if (isDirector) {
    // Director vede concediile din departamentul său
    query6Luni += " AND useri.id_dep = " + rs.getInt("id_dep");
} else if (isSef) {
    query6Luni += " AND useri.id_dep = " + rs.getInt("id_dep");
} else {
    query6Luni += " AND useri.id = " + id;
}

try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
     PreparedStatement stmt = connection.prepareStatement(query6Luni)) {
    ResultSet rs_6luni = stmt.executeQuery();
    if (rs_6luni.next()) {
        data6Luni[0] = rs_6luni.getInt("ian");
        data6Luni[1] = rs_6luni.getInt("feb");
        data6Luni[2] = rs_6luni.getInt("mar");
        data6Luni[3] = rs_6luni.getInt("apr");
        data6Luni[4] = rs_6luni.getInt("mai");
        data6Luni[5] = rs_6luni.getInt("iun");
    }
} catch (SQLException e) {
    System.out.println("Eroare query 6 luni: " + e.getMessage());
}

// Date pentru ultimul an (pe trimestre)
int[] dataAn = new int[4];
String queryAn = "SELECT " +
        "SUM(CASE WHEN QUARTER(start_c) = 1 THEN durata ELSE 0 END) as q1, " +
        "SUM(CASE WHEN QUARTER(start_c) = 2 THEN durata ELSE 0 END) as q2, " +
        "SUM(CASE WHEN QUARTER(start_c) = 3 THEN durata ELSE 0 END) as q3, " +
        "SUM(CASE WHEN QUARTER(start_c) = 4 THEN durata ELSE 0 END) as q4 " +
        "FROM concedii JOIN useri ON concedii.id_ang = useri.id " +
        "WHERE YEAR(start_c) = YEAR(CURDATE()) AND status >= 0";

if (isDirector) {
    queryAn += " AND useri.id_dep = " + rs.getInt("id_dep");
} else if (isSef) {
    queryAn += " AND useri.id_dep = " + rs.getInt("id_dep");
} else {
    queryAn += " AND useri.id = " + id;
}

try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
     PreparedStatement stmt = connection.prepareStatement(queryAn)) {
    ResultSet rs_an = stmt.executeQuery();
    if (rs_an.next()) {
        dataAn[0] = rs_an.getInt("q1");
        dataAn[1] = rs_an.getInt("q2");
        dataAn[2] = rs_an.getInt("q3");
        dataAn[3] = rs_an.getInt("q4");
    }
} catch (SQLException e) {
    System.out.println("Eroare query an: " + e.getMessage());
}

System.out.println("Date grafice: 6luni=" + java.util.Arrays.toString(data6Luni) + ", an=" + java.util.Arrays.toString(dataAn));
%>
    <script>
 // ============= VERIFICĂRI ȘI DEBUGGING =============
    console.log('=== CHART SCRIPT START ===');

    // Verifică dacă Chart.js este încărcat
    function checkChartJS() {
        if (typeof Chart === 'undefined') {
            console.error('❌ Chart.js is NOT loaded!');
            return false;
        } else {
            console.log('✅ Chart.js is loaded, version:', Chart.version || 'unknown');
            return true;
        }
    }

    // ============= VARIABILE GLOBALE =============
    window.concediiChart = null;
    window.statusChart = null;
    window.cssVars = null;

    // ============= FUNCȚIE PENTRU CSS VARIABLES =============
    function getCSSVariables() {
        try {
            const root = document.documentElement;
            const styles = getComputedStyle(root);
            
            const cssVars = {
                accent: styles.getPropertyValue('--bg').trim() || styles.getPropertyValue('--theme-accent').trim() || '#10439F',
                clr: styles.getPropertyValue('--clr').trim() || styles.getPropertyValue('--theme-clr').trim() || '#d8d9e1',
                sidebar: styles.getPropertyValue('--sd').trim() || styles.getPropertyValue('--theme-sidebar').trim() || '#ECEDFA',
                text: styles.getPropertyValue('--text').trim() || styles.getPropertyValue('--theme-text').trim() || '#333'
            };
            
            // Verifică dacă valorile sunt valide
            Object.keys(cssVars).forEach(key => {
                if (!cssVars[key] || cssVars[key] === '' || cssVars[key] === 'undefined') {
                    console.warn(`CSS Variable ${key} is invalid, using fallback`);
                    switch(key) {
                        case 'accent': cssVars[key] = '#10439F'; break;
                        case 'clr': cssVars[key] = '#d8d9e1'; break;
                        case 'sidebar': cssVars[key] = '#ECEDFA'; break;
                        case 'text': cssVars[key] = '#333'; break;
                    }
                }
                
                // Asigură-te că culoarea începe cu #
                if (!cssVars[key].startsWith('#')) {
                    cssVars[key] = '#' + cssVars[key];
                }
            });
            
            console.log('✅ CSS Variables extracted:', cssVars);
            return cssVars;
            
        } catch (error) {
            console.error('❌ Error getting CSS variables:', error);
            return {
                accent: '#10439F',
                clr: '#d8d9e1',
                sidebar: '#ECEDFA',
                text: '#333'
            };
        }
    }

    // ============= FUNCȚII GRAFICE CORECTATE =============

    function updateConcediiChart(period = '6luni') {
        console.log('=== updateConcediiChart START ===', period);
        
        // Verificări preliminare
        if (!checkChartJS()) {
            console.error('Chart.js not available, aborting');
            return false;
        }
        
        const canvas = document.getElementById('concediiChart');
        if (!canvas) {
            console.error('❌ Canvas concediiChart not found!');
            return false;
        }
        
        const ctx = canvas.getContext('2d');
        if (!ctx) {
            console.error('❌ Could not get 2D context!');
            return false;
        }
        
        // Obține CSS variables (CORECTAREA PROBLEMEI 1: ccsVars -> cssVars)
        window.cssVars = getCSSVariables();
        
        // Distruge graficul existent
        if (window.concediiChart && typeof window.concediiChart.destroy === 'function') {
            console.log('Destroying existing chart...');
            window.concediiChart.destroy();
            window.concediiChart = null;
        }
        
        // Configurare date
        let labels, data, maxValue;
        
        switch(period) {
            case '6luni':
            case 'Ultimele 6 luni':
                labels = ['Ian', 'Feb', 'Mar', 'Apr', 'Mai', 'Iun'];
                data = [<%=data6Luni[0]%>, <%=data6Luni[1]%>, <%=data6Luni[2]%>, <%=data6Luni[3]%>, <%=data6Luni[4]%>, <%=data6Luni[5]%>];
                maxValue = 40;
                break;
            case '1an':
            case 'Ultimul an':
                labels = ['T1', 'T2', 'T3', 'T4'];
                data = [<%=dataAn[0]%>, <%=dataAn[1]%>, <%=dataAn[2]%>, <%=dataAn[3]%>];
                maxValue = 40;
                break;
            case 'total':
            case 'Tot timpul':
                labels = ['2023', '2024', '2025'];
                data = [10, 15, 8]; // Date exemple
                maxValue = 50;
                break;
            default:
                labels = ['Ian', 'Feb', 'Mar', 'Apr', 'Mai', 'Iun'];
                data = [<%=data6Luni[0]%>, <%=data6Luni[1]%>, <%=data6Luni[2]%>, <%=data6Luni[3]%>, <%=data6Luni[4]%>, <%=data6Luni[5]%>];
                maxValue = 40;
        }
        
        console.log('Chart data:', { labels, data, maxValue, cssVars: window.cssVars });
        
        // Verifică dacă avem date valide
        if (!data || data.length === 0) {
            console.error('❌ No valid data for chart');
            return false;
        }
        
        try {
            // Creează gradient cu culorile CSS (CORECTAREA PROBLEMEI 2)
            const gradient = ctx.createLinearGradient(0, 0, 0, 300);
            gradient.addColorStop(0, window.cssVars.accent + '40'); // Hex transparency
            gradient.addColorStop(1, window.cssVars.accent + '10');
            
            // Creează graficul
            window.concediiChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [{
                        label: 'Zile Concediu',
                        data: data,
                        borderColor: window.cssVars.accent,
                        backgroundColor: gradient,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 6,
                        pointHoverRadius: 8,
                        pointBackgroundColor: window.cssVars.accent,
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        pointHoverBackgroundColor: window.cssVars.text,
                        pointHoverBorderColor: window.cssVars.accent,
                        pointHoverBorderWidth: 3,
                        borderWidth: 3
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            backgroundColor: window.cssVars.sidebar,
                            titleColor: window.cssVars.text,
                            bodyColor: window.cssVars.text,
                            borderColor: window.cssVars.accent,
                            borderWidth: 1,
                            cornerRadius: 8,
                            displayColors: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: maxValue,
                            grid: {
                                color: window.cssVars.text + '20',
                                borderDash: [5, 5]
                            },
                            ticks: {
                                color: window.cssVars.text,
                                font: {
                                    family: 'Poppins',
                                    size: 12
                                },
                                stepSize: 5
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                color: window.cssVars.text,
                                font: {
                                    family: 'Poppins',
                                    size: 12
                                }
                            }
                        }
                    },
                    animation: {
                        duration: 1000,
                        easing: 'easeInOutQuart'
                    }
                }
            });
            
            console.log('✅ Concedii chart created successfully!');
            return true;
            
        } catch (error) {
            console.error('❌ Error creating concedii chart:', error);
            
            // Afișează eroare pe canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.font = '16px Poppins';
            ctx.fillStyle = window.cssVars.text;
            ctx.textAlign = 'center';
            ctx.fillText('Eroare la încărcarea graficului', canvas.width / 2, canvas.height / 2);
            ctx.fillText(error.message, canvas.width / 2, canvas.height / 2 + 20);
            
            return false;
        }
    }

    function updateStatusChart(period = 'curent') {
        console.log('=== updateStatusChart START ===', period);
        
        // Verificări preliminare
        if (!checkChartJS()) {
            console.error('Chart.js not available, aborting');
            return false;
        }
        
        const canvas = document.getElementById('statusChart');
        if (!canvas) {
            console.error('❌ Canvas statusChart not found!');
            return false;
        }
        
        const ctx = canvas.getContext('2d');
        if (!ctx) {
            console.error('❌ Could not get 2D context!');
            return false;
        }
        
        // Obține CSS variables dacă nu există
        if (!window.cssVars) {
            window.cssVars = getCSSVariables();
        }
        
        // Distruge graficul existent
        if (window.statusChart && typeof window.statusChart.destroy === 'function') {
            console.log('Destroying existing status chart...');
            window.statusChart.destroy();
            window.statusChart = null;
        }
        
        // Date pentru diferite perioade (CORECTAREA PROBLEMEI 3: JSP code în funcție JS)
        let data;

        <%
                  // Date pentru anul curent
                  int[] statusCurent = {0, 0, 0, 0}; // [aprobate_director, aprobate_sef, in_asteptare, respinse]
                  String queryStatusCurent = "SELECT status, COUNT(*) as count FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE YEAR(start_c) = YEAR(CURDATE())";
                  
                  if (isDirector) {
                      queryStatusCurent += "";
                  } else if (isSef) {
                      queryStatusCurent += " AND useri.id_dep = " + rs.getInt("id_dep");
                  } else {
                      queryStatusCurent += " AND useri.id = " + id;
                  }
                  queryStatusCurent += " GROUP BY status";
                  
                  try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                       PreparedStatement stmt = connection.prepareStatement(queryStatusCurent)) {
                      ResultSet rs_status = stmt.executeQuery();
                      while (rs_status.next()) {
                          int status = rs_status.getInt("status");
                          int count = rs_status.getInt("count");
                          if (status == 2) statusCurent[0] = count;
                          else if (status == 1) statusCurent[1] = count;
                          else if (status == 0) statusCurent[2] = count;
                          else if (status < 0) statusCurent[3] += count;
                      }
                  } catch (SQLException e) {
                      System.out.println("Eroare query status curent: " + e.getMessage());
                  }
                  
                  // Date pentru anul trecut
                  int[] statusTrecut = {0, 0, 0, 0};
                  String queryStatusTrecut = "SELECT status, COUNT(*) as count FROM concedii JOIN useri ON concedii.id_ang = useri.id WHERE YEAR(start_c) = YEAR(CURDATE()) - 1";
                  
                  if (isDirector) {
                      queryStatusTrecut += "";
                  } else if (isSef) {
                      queryStatusTrecut += " AND useri.id_dep = " + rs.getInt("id_dep");
                  } else {
                      queryStatusTrecut += " AND useri.id = " + id;
                  }
                  queryStatusTrecut += " GROUP BY status";
                  
                  try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                       PreparedStatement stmt = connection.prepareStatement(queryStatusTrecut)) {
                      ResultSet rs_status = stmt.executeQuery();
                      while (rs_status.next()) {
                          int status = rs_status.getInt("status");
                          int count = rs_status.getInt("count");
                          if (status == 2) statusTrecut[0] = count;
                          else if (status == 1) statusTrecut[1] = count;
                          else if (status == 0) statusTrecut[2] = count;
                          else if (status < 0) statusTrecut[3] += count;
                      }
                  } catch (SQLException e) {
                      System.out.println("Eroare query status trecut: " + e.getMessage());
                  }
                  
                  // Date pentru total
                  int[] statusTotal = {0, 0, 0, 0};
                  String queryStatusTotal = "SELECT status, COUNT(*) as count FROM concedii JOIN useri ON concedii.id_ang = useri.id";
                  
                  if (isDirector) {
                      queryStatusTotal += "";
                  } else if (isSef) {
                      queryStatusTotal += " WHERE useri.id_dep = " + rs.getInt("id_dep");
                  } else {
                      queryStatusTotal += " WHERE useri.id = " + id;
                  }
                  queryStatusTotal += " GROUP BY status";
                  
                  try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                       PreparedStatement stmt = connection.prepareStatement(queryStatusTotal)) {
                      ResultSet rs_status = stmt.executeQuery();
                      while (rs_status.next()) {
                          int status = rs_status.getInt("status");
                          int count = rs_status.getInt("count");
                          if (status == 2) statusTotal[0] = count;
                          else if (status == 1) statusTotal[1] = count;
                          else if (status == 0) statusTotal[2] = count;
                          else if (status < 0) statusTotal[3] += count;
                      }
                  } catch (SQLException e) {
                      System.out.println("Eroare query status total: " + e.getMessage());
                  }
                  %>

        // IMPORTANT: Aceste date trebuie să fie calculate în JSP, nu în funcția JS
        // Voi folosi date statice pentru demonstrație
        const statusData = {
            curent: [<%=statusCurent[0]%>, <%=statusCurent[1]%>, <%=statusCurent[2]%>, <%=statusCurent[3]%>],
            trecut: [<%=statusTrecut[0]%>, <%=statusTrecut[1]%>, <%=statusTrecut[2]%>, <%=statusTrecut[3]%>],
            total: [<%=statusTotal[0]%>, <%=statusTotal[1]%>, <%=statusTotal[2]%>, <%=statusTotal[3]%>]
        };
        
        switch(period) {
            case 'curent':
            case 'Anul curent':
                data = statusData.curent;
                break;
            case 'trecut':
            case 'Anul trecut':
                data = statusData.trecut;
                break;
            case 'total':
            case 'Totale':
                data = statusData.total;
                break;
            default:
                data = statusData.curent;
        }
        
        console.log('Status chart data:', { period, data, cssVars: window.cssVars });
        
        // Verifică dacă există date
        const total = data.reduce((a, b) => a + b, 0);
        if (total === 0) {
            console.log('⚠️ No status data available');
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.font = '16px Poppins';
            ctx.fillStyle = window.cssVars.text;
            ctx.textAlign = 'center';
            ctx.fillText('Nu există date pentru', canvas.width / 2, canvas.height / 2 - 10);
            ctx.fillText('perioada selectată', canvas.width / 2, canvas.height / 2 + 10);
            return false;
        }
        
        try {
            // Creează paletă de culori bazată pe tema curentă
            const colors = [
                window.cssVars.accent,                    // Aprobate Director
                lightenColor(window.cssVars.accent, 20), // Aprobate Șef
                lightenColor(window.cssVars.accent, 40), // În Așteptare
                darkenColor(window.cssVars.accent, 30)   // Respinse
            ];
            
            // Creează graficul
            window.statusChart = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Aprobate Director', 'Aprobate Șef', 'În Așteptare', 'Respinse'],
                    datasets: [{
                        data: data,
                        backgroundColor: colors,
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        cutout: '60%',
                        hoverOffset: 8,
                        hoverBorderWidth: 4
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
                                usePointStyle: true,
                                pointStyle: 'circle',
                                color: window.cssVars.text,
                                font: {
                                    family: 'Poppins',
                                    size: 12
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: window.cssVars.sidebar,
                            titleColor: window.cssVars.text,
                            bodyColor: window.cssVars.text,
                            borderColor: window.cssVars.accent,
                            borderWidth: 1,
                            cornerRadius: 8,
                            callbacks: {
                                label: function(context) {
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const value = context.parsed;
                                    const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                    return `${context.label}: ${value} (${percentage}%)`;
                                }
                            }
                        }
                    },
                    animation: {
                        animateRotate: true,
                        animateScale: true,
                        duration: 1000,
                        easing: 'easeInOutQuart'
                    }
                }
            });
            
            console.log('✅ Status chart created successfully!');
            return true;
            
        } catch (error) {
            console.error('❌ Error creating status chart:', error);
            
            // Afișează eroare pe canvas
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.font = '16px Poppins';
            ctx.fillStyle = window.cssVars.text;
            ctx.textAlign = 'center';
            ctx.fillText('Eroare la încărcarea graficului', canvas.width / 2, canvas.height / 2);
            
            return false;
        }
    }

    // ============= HELPER FUNCTIONS =============

    function lightenColor(color, percent) {
        const num = parseInt(color.replace("#", ""), 16);
        const amt = Math.round(2.55 * percent);
        const R = Math.min(255, (num >> 16) + amt);
        const G = Math.min(255, (num >> 8 & 0x00FF) + amt);
        const B = Math.min(255, (num & 0x0000FF) + amt);
        return "#" + (0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1);
    }

    function darkenColor(color, percent) {
        const num = parseInt(color.replace("#", ""), 16);
        const amt = Math.round(2.55 * percent);
        const R = Math.max(0, (num >> 16) - amt);
        const G = Math.max(0, (num >> 8 & 0x00FF) - amt);
        const B = Math.max(0, (num & 0x0000FF) - amt);
        return "#" + (0x1000000 + R * 0x10000 + G * 0x100 + B).toString(16).slice(1);
    }

    // ============= INIȚIALIZARE ȘI EVENT LISTENERS =============

    function initializeCharts() {
        console.log('=== INITIALIZING CHARTS ===');
        
        // Verificări preliminare
        if (!checkChartJS()) {
            console.error('Chart.js not available, cannot initialize charts');
            return false;
        }
        
        // Verifică canvas-urile
        const concediiCanvas = document.getElementById('concediiChart');
        const statusCanvas = document.getElementById('statusChart');
        
        console.log('Canvas elements:', {
            concediiChart: !!concediiCanvas,
            statusChart: !!statusCanvas
        });
        
        if (!concediiCanvas && !statusCanvas) {
            console.error('❌ No canvas elements found!');
            return false;
        }
        
        // Obține CSS variables
        window.cssVars = getCSSVariables();
        
        // Inițializează graficele cu o mică întârziere
        setTimeout(() => {
            let success = true;
            
            if (concediiCanvas) {
                const result1 = updateConcediiChart('6luni');
                success = success && result1;
            }
            
            if (statusCanvas) {
                const result2 = updateStatusChart('curent');
                success = success && result2;
            }
            
            console.log('Charts initialization result:', success ? '✅ SUCCESS' : '❌ FAILED');
            
            // Retry dacă a eșuat
            if (!success) {
                console.log('Retrying chart initialization in 2 seconds...');
                setTimeout(() => {
                    if (concediiCanvas && !window.concediiChart) {
                        updateConcediiChart('6luni');
                    }
                    if (statusCanvas && !window.statusChart) {
                        updateStatusChart('curent');
                    }
                }, 2000);
            }
        }, 200);
        
        return true;
    }

    function setupEventListeners() {
        console.log('=== SETUP EVENT LISTENERS ===');
        
        // Event listeners pentru filtre grafice
        const allFilters = document.querySelectorAll('.chart-filter');
        console.log('Found chart filters:', allFilters.length);
        
        allFilters.forEach((filter, index) => {
            const chartCard = filter.closest('.chart-card');
            if (!chartCard) return;
            
            const isConcediiChart = chartCard.querySelector('#concediiChart');
            const isStatusChart = chartCard.querySelector('#statusChart');
            
            console.log(`Filter ${index}:`, {
                isConcediiChart: !!isConcediiChart,
                isStatusChart: !!isStatusChart
            });
            
            filter.addEventListener('change', function(e) {
                console.log('Filter changed:', e.target.value);
                
                if (isConcediiChart) {
                    updateConcediiChart(e.target.value);
                } else if (isStatusChart) {
                    updateStatusChart(e.target.value);
                }
            });
        });
        
        // Event listener pentru PDF (CORECTAREA PROBLEMEI 4: verifică dacă butonul există)
        const pdfBtn = document.getElementById('generatePDF');
        if (pdfBtn) {
            pdfBtn.addEventListener('click', generatePDFReport);
            console.log('✅ PDF button event listener attached');
        } else {
            console.warn('⚠️ PDF button not found, will try again later');
        }
        
        // Refresh button pentru activitate
        const refreshBtn = document.querySelector('.activity-header button');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', function() {
                this.style.transform = 'rotate(360deg)';
                setTimeout(() => {
                    this.style.transform = 'rotate(0deg)';
                    location.reload();
                }, 500);
            });
            console.log('✅ Refresh button event listener attached');
        }
    }

    // ============= FUNCȚIA PDF (CORECTATĂ) =============

    function generatePDFReport() {
        console.log('=== PDF Report Generation ===');
        
        const reportType = document.getElementById('reportType')?.value || 'lunar';
        const btn = document.getElementById('generatePDF');
        
        console.log('Report type:', reportType);
        console.log('User ID: <%=id%>');
        
        if (btn) {
            btn.innerHTML = '<i class="ri-loader-line"></i> Generez...';
            btn.style.pointerEvents = 'none';
        }
        
        try {
            // Creează form pentru a trimite cererea către server
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'generatePDFReport.jsp';
            form.target = '_blank';
            form.style.display = 'none';
            
            // Adaugă parametrii
            const reportTypeInput = document.createElement('input');
            reportTypeInput.type = 'hidden';
            reportTypeInput.name = 'reportType';
            reportTypeInput.value = reportType;
            form.appendChild(reportTypeInput);
            
            const userIdInput = document.createElement('input');
            userIdInput.type = 'hidden';
            userIdInput.name = 'userId';
            userIdInput.value = '<%=id%>';
            form.appendChild(userIdInput);
            
            document.body.appendChild(form);
            form.submit();
            
            // Cleanup
            setTimeout(() => {
                if (document.body.contains(form)) {
                    document.body.removeChild(form);
                }
            }, 2000);
            
            console.log('✅ PDF form submitted successfully');
            
        } catch (error) {
            console.error('❌ PDF generation error:', error);
        }
        
        // Reset button
        setTimeout(() => {
            if (btn) {
                btn.innerHTML = '<i class="ri-download-line"></i> Generează PDF';
                btn.style.pointerEvents = 'auto';
            }
        }, 4000);
    }

    // ============= EVENT LISTENERS PENTRU ÎNCĂRCARE =============

    document.addEventListener('DOMContentLoaded', function() {
        console.log('=== DOM CONTENT LOADED ===');
        
        // Verifică Chart.js
        if (!checkChartJS()) {
            console.log('Chart.js not ready, will retry...');
            setTimeout(() => {
                if (checkChartJS()) {
                    initializeCharts();
                    setupEventListeners();
                } else {
                    console.error('Chart.js failed to load after retry');
                }
            }, 1000);
        } else {
            // Inițializează imediat
            initializeCharts();
            setupEventListeners();
        }
        
        // Date utilizator pentru debugging
        const userData = {
            nume: '<%=rs.getString("nume")%>',
            prenume: '<%=rs.getString("prenume")%>',
            functie: '<%=functie%>',
            ierarhie: <%=ierarhie%>,
            id: <%=id%>
        };
        console.log('User data:', userData);
    });

    window.addEventListener('load', function() {
        console.log('=== WINDOW FULLY LOADED ===');
        
        // Verificare finală după 3 secunde
        setTimeout(() => {
            console.log('=== FINAL VERIFICATION ===');
            
            const concediiExists = !!window.concediiChart;
            const statusExists = !!window.statusChart;
            const chartJsLoaded = typeof Chart !== 'undefined';
            
            console.log('Final status:', {
                chartJsLoaded,
                concediiChart: concediiExists,
                statusChart: statusExists,
                cssVars: !!window.cssVars
            });
            
            // Re-inițializează graficele lipsă
            if (chartJsLoaded && (!concediiExists || !statusExists)) {
                console.log('Re-initializing missing charts...');
                if (!concediiExists) updateConcediiChart('6luni');
                if (!statusExists) updateStatusChart('curent');
            }
            
            // Verifică din nou PDF button
            const pdfBtn = document.getElementById('generatePDF');
            if (pdfBtn && !pdfBtn.onclick) {
                pdfBtn.addEventListener('click', generatePDFReport);
                console.log('✅ Late PDF button attachment successful');
            }
            
            if (concediiExists && statusExists) {
                console.log('🎉 ALL CHARTS ARE WORKING CORRECTLY!');
            }
        }, 3000);
    });

    // ============= EXPORT PENTRU DEBUGGING =============

    window.chartDebug = {
        checkChartJS,
        getCSSVariables,
        updateConcediiChart,
        updateStatusChart,
        initializeCharts,
        setupEventListeners,
        generatePDFReport,
        cssVars: () => window.cssVars,
        charts: () => ({
            concedii: window.concediiChart,
            status: window.statusChart
        })
    };

    console.log('=== CHART SCRIPT LOADED COMPLETELY ===');
    console.log('Use window.chartDebug for manual testing');

    // Animații pentru stats la încărcare (păstrat din codul original)
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
    <script>
console.log('=== DEBUG GRAFICE DIRECTOR ===');
console.log('Data pentru grafice:');
console.log('6 luni:', [<%=data6Luni[0]%>, <%=data6Luni[1]%>, <%=data6Luni[2]%>, <%=data6Luni[3]%>, <%=data6Luni[4]%>, <%=data6Luni[5]%>]);
console.log('An:', [<%=dataAn[0]%>, <%=dataAn[1]%>, <%=dataAn[2]%>, <%=dataAn[3]%>]);
console.log('Status curent:', [<%=statusCurent[0]%>, <%=statusCurent[1]%>, <%=statusCurent[2]%>, <%=statusCurent[3]%>]);
console.log('CSS Variables:');
console.log('--bg:', '<%=accent%>');
console.log('--clr:', '<%=clr%>');
console.log('--sd:', '<%=sidebar%>');
console.log('--text:', '<%=text%>');
</script>
    <script>
// Test de verificare finală
window.addEventListener('load', function() {
    setTimeout(() => {
        console.log('=== VERIFICARE FINALĂ ===');
        console.log('Chart.js loaded:', typeof Chart !== 'undefined');
        console.log('Grafic concedii exists:', !!window.concediiChart);
        console.log('Grafic status exists:', !!window.statusChart);
        
        // Verifică dacă canvas-urile sunt vizibile
        const canvases = document.querySelectorAll('canvas');
        canvases.forEach((canvas, index) => {
            const rect = canvas.getBoundingClientRect();
            console.log(`Canvas ${index} vizibil:`, {
                width: rect.width,
                height: rect.height,
                visible: rect.width > 0 && rect.height > 0
            });
        });
    }, 5000);
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
