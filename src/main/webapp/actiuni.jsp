<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
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
        return; // Oprește execuția
    }
    
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    String username = currentUser.getUsername();
    
    // Variabile pentru datele utilizatorului
    String functie = "", numeDep = "", denumireCompleta = "";
    int id = 0, userType = 0, userdep = 0, ierarhie = 0;
    int zileramase = 0, conramase = 0, zilecons = 0, conluate = 0;
    
    // Variabile pentru tema de culoare
    String accent = "#10439F", clr = "#d8d9e1", sidebar = "#ECEDFA";
    String text = "#333", card = "#ECEDFA", hover = "#ECEDFA";
    String today = "";
    
    // Variabile pentru permisiuni
    boolean isDirector = false, isSef = false, isIncepator = false;
    boolean isUtilizatorNormal = false, isAdmin = false;
    
    try (Connection connection = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
        
        // ================ EXTRAGERE DATE UTILIZATOR ================
        String userQuery = "SELECT DISTINCT u.*, " +
                          "t.denumire AS functie, " +
                          "d.nume_dep, " +
                          "t.ierarhie as ierarhie, " +
                          "dp.denumire_completa AS denumire_completa, " +
                          "u.zileramase, " +
                          "u.conramase, " +
                          "u.zilecons, " +
                          "u.conluate " +
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
                
                // Extragere date despre concedii
                zileramase = userRs.getInt("zileramase");
                conramase = userRs.getInt("conramase");
                zilecons = userRs.getInt("zilecons");
                conluate = userRs.getInt("conluate");
                
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
        
        // ================ EXTRAGERE TEMA CULOARE ================
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
        
    } catch (SQLException e) {
        out.println("<script>alert('Eroare la baza de date: " + e.getMessage() + "');</script>");
        e.printStackTrace();
        // Redirect bazat pe tipul utilizatorului în caz de eroare
         if (isDirector) {
        	 response.sendRedirect("dashboard.jsp");
        	 return;
        }
        if (isUtilizatorNormal) {
       	 response.sendRedirect("tip2ok.jsp");
       	return;
       }
        if (isAdmin) {
       	 response.sendRedirect("adminok.jsp");
       	return;
       }
        if (isIncepator) {
          	 response.sendRedirect("tip1ok.jsp");
          	return;
          }
        if (isSef) {
          	 response.sendRedirect("sefok.jsp");
          	return;
          }
        return;
    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panou Acțiuni - <%= functie %></title>
    
    <!-- Fonts & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@3.5.0/fonts/remixicon.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
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
            max-width: 1200px;
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

        .user-info {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 1.5rem;
            margin-bottom: 2rem;
            
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: 600;
            overflow: hidden;
            position: relative;
            
            transition: var(--transition);
        }

        .user-avatar:hover {
            transform: scale(1.05);
            
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .user-avatar-fallback {
            position: absolute;
            inset: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--primary-color);
            color: white;
            font-size: 1.5rem;
            font-weight: 600;
        }

        .user-details h3 {
            font-size: 1.2rem;
            margin-bottom: 0.25rem;
        }

        .user-details p {
            opacity: 0.7;
            font-size: 0.9rem;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
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

        .restricted-access {
            opacity: 0.6;
            pointer-events: none;
        }

        .badge {
            display: inline-block;
            background: var(--primary-color);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            margin-left: 0.5rem;
        }

        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--card-color);
            border-radius: var(--border-radius);
            padding: 1.5rem;
           
            text-align: center;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 0.25rem;
        }

        .stat-label {
            opacity: 0.7;
            font-size: 0.9rem;
        }

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

            .user-info {
                flex-direction: column;
                text-align: center;
            }
        }

        /* Animații */
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

        .slide-in {
            animation: slideIn 0.8s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header fade-in">
            <h1>Bun venit înapoi!</h1>
            <p class="subtitle">Alegeți acțiunea pe care doriți să o efectuați</p>
        </div>

        <!-- Informații utilizator -->
        <div class="user-info slide-in">
            <div class="user-avatar">
                <img src="${pageContext.request.contextPath}/ImageServlet?id=<%= id %>" 
                     alt="Imagine profil <%= currentUser.getNume() %>"
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';"
                     onload="this.style.display='block'; this.nextElementSibling.style.display='none';">
                <div class="user-avatar-fallback">
                    <%= username.substring(0, 1).toUpperCase() %>
                </div>
            </div>
            <div class="user-details">
                <h3><%= currentUser.getPrenume() %></h3>
                <p><%= numeDep %> -
                    <% if (isDirector) { %><span class="badge">Director</span><% } %>
                    <% if (isSef) { %><span class="badge">Șef</span><% } %>
                    <% if (isAdmin) { %><span class="badge">Admin</span><% } %>
                </p>
            </div>
        </div>

        <!-- Statistici rapide -->
        <div class="quick-stats fade-in">
            <div class="stat-card">
                <div class="stat-number"><%= today %></div>
                <div class="stat-label">Data curentă</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= zileramase %></div>
                <div class="stat-label">Zile concediu rămase</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= conramase %></div>
                <div class="stat-label">Cereri rămase</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= zilecons %></div>
                <div class="stat-label">Zile consumate</div>
            </div>
        </div>

        <!-- Grid acțiuni -->
        <div class="actions-grid">
            <!-- Adăugare concediu -->
            <a href="addc.jsp" class="action-card fade-in">
                <i class="ri-calendar-check-line action-icon"></i>
                <h3 class="action-title">Solicitare Concediu</h3>
                <p class="action-description">
                    Creați o nouă cerere de concediu și urmăriți statusul acesteia în timp real.
                </p>
            </a>

            <!-- Modificare concedii -->
            <a href="concediinoisef.jsp?pag=1" class="action-card fade-in" style="animation-delay: 0.1s">
                <i class="ri-edit-2-line action-icon"></i>
                <h3 class="action-title">Gestionare Concedii</h3>
                <p class="action-description">
                    Modificați sau ștergeți cererile de concediu existente și urmăriți istoricul.
                </p>
            </a>

            <!-- Vizualizare concedii noi - doar pentru șefi și directori -->
            <% if (isDirector || isSef) { %>
            <a href="concediinoisef.jsp" class="action-card fade-in" style="animation-delay: 0.2s">
                <i class="ri-notification-3-line action-icon"></i>
                <h3 class="action-title">Aprobare Concedii</h3>
                <p class="action-description">
                    Vizualizați și aprobați cererile de concediu ale echipei dumneavoastră.
                </p>
            </a>
            <% } else { %>
            <div class="action-card restricted-access fade-in" style="animation-delay: 0.2s">
                <i class="ri-lock-line action-icon"></i>
                <h3 class="action-title">Aprobare Concedii</h3>
                <p class="action-description">
                    Această funcționalitate este disponibilă doar pentru șefi și directori.
                </p>
            </div>
            <% } %>

            <!-- Rapoarte concedii -->
            <a href="vizualizareconcedii.jsp" class="action-card fade-in" style="animation-delay: 0.3s">
                <i class="ri-bar-chart-box-line action-icon"></i>
                <h3 class="action-title">Rapoarte & Analiză</h3>
                <p class="action-description">
                    Vizualizați rapoarte detaliate și analize privind concediile și planificarea.
                </p>
            </a>

          
        </div>
    </div>

    <script>
        // Smooth scrolling pentru link-uri
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                document.querySelector(this.getAttribute('href')).scrollIntoView({
                    behavior: 'smooth'
                });
            });
        });

        // Animații la scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Observăm toate cardurile
        document.querySelectorAll('.action-card').forEach(card => {
            observer.observe(card);
        });

        // Feedback vizual pentru click-uri
        document.querySelectorAll('.action-card').forEach(card => {
            card.addEventListener('click', function(e) {
                // Creăm un efect de ripple
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