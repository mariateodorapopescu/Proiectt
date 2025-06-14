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
    int totalAngajati = 0, angajatiActivi = 0, angajatiInactivi = 0;
    int angajatiDepartament = 0;
    
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
                
                // Verificăm dacă utilizatorul are permisiuni pentru această pagină
                if (!isDirector) {
                    if (isAdmin) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    } else if (isUtilizatorNormal) {
                        response.sendRedirect("tip1ok.jsp");
                        return;
                    } else if (isSef) {
                        response.sendRedirect("sefok.jsp");
                        return;
                    } else if (isIncepator) {
                        response.sendRedirect("tip2ok.jsp");
                        return;
                    }
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
        
        // ================ EXTRAGERE STATISTICI ANGAJAȚI ================
        // Total angajați din instituție
        String totalQuery = "SELECT COUNT(*) as total FROM useri WHERE username != 'test'";
        try (PreparedStatement totalStmt = connection.prepareStatement(totalQuery);
             ResultSet totalRs = totalStmt.executeQuery()) {
            if (totalRs.next()) {
                totalAngajati = totalRs.getInt("total");
            }
        }
        
        // Angajați activi
        String activiQuery = "SELECT COUNT(*) as activi FROM useri WHERE activ = 1 AND username != 'test'";
        try (PreparedStatement activiStmt = connection.prepareStatement(activiQuery);
             ResultSet activiRs = activiStmt.executeQuery()) {
            if (activiRs.next()) {
                angajatiActivi = activiRs.getInt("activi");
            }
        }
        
        angajatiInactivi = totalAngajati - angajatiActivi;
        
        // Angajați din departamentul curent
        String depQuery = "SELECT COUNT(*) as dep_count FROM useri WHERE id_dep = ? AND username != 'test'";
        try (PreparedStatement depStmt = connection.prepareStatement(depQuery)) {
            depStmt.setInt(1, userdep);
            ResultSet depRs = depStmt.executeQuery();
            if (depRs.next()) {
                angajatiDepartament = depRs.getInt("dep_count");
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
    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestionare Angajați - <%= functie %></title>
    
    <!-- Fonts & Icons -->
    <link href="https://cdn.jsdelivr.net/npm/remixicons@3.5.0/fonts/remixicon.css" rel="stylesheet">
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
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
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
            transition: var(--transition);
        }

        .stat-card:hover {
            transform: translateY(-2px);
            
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

        /* Categorii de acțiuni */
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-color);
            margin: 2rem 0 1rem 0;
            text-align: center;
        }

        .visualization-section {
            margin-bottom: 2rem;
        }

        .management-section {
            margin-bottom: 2rem;
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

            .quick-stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 480px) {
            .quick-stats {
                grid-template-columns: 1fr;
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
            <h1>Gestionare Angajați</h1>
            <p class="subtitle">Administrați și monitorizați echipa dumneavoastră</p>
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
                <p><%=numeDep%> - 
                    <% if (isDirector) { %><span class="badge">Director</span><% } %>
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
                <div class="stat-number"><%= totalAngajati %></div>
                <div class="stat-label">Total angajați</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= angajatiActivi %></div>
                <div class="stat-label">Angajați activi</div>
            </div>
            <div class="stat-card">
                <div class="stat-number"><%= angajatiDepartament %></div>
                <div class="stat-label">Din departamentul meu</div>
            </div>
        </div>

        <!-- Secțiunea de vizualizare -->
        <h2 class="section-title fade-in">📊 Vizualizare & Rapoarte</h2>
        <div class="actions-grid visualization-section">
            <!-- Vizualizare toți angajații -->
            <a href="viewcolegi.jsp" class="action-card fade-in">
                <i class="ri-team-line action-icon"></i>
                <h3 class="action-title">Toți Angajații</h3>
                <p class="action-description">
                    Vizualizați lista completă a tuturor angajaților din instituție cu detalii complete.
                </p>
            </a>

            <!-- Vizualizare pe departamente -->
            <a href="viewangdep.jsp" class="action-card fade-in" style="animation-delay: 0.1s">
                <i class="ri-building-2-line action-icon"></i>
                <h3 class="action-title">Pe Departamente</h3>
                <p class="action-description">
                    Explorați angajații organizați pe departamente pentru o vizualizare structurată.
                </p>
            </a>

            <!-- Departamentul meu -->
            <a href="viewcolegidep.jsp" class="action-card fade-in" style="animation-delay: 0.2s">
                <i class="ri-group-line action-icon"></i>
                <h3 class="action-title">Departamentul Meu</h3>
                <p class="action-description">
                    Vizualizați și gestionați echipa din departamentul dumneavoastră.
                </p>
            </a>

            <!-- Angajați activi -->
            <a href="activi.jsp" class="action-card fade-in" style="animation-delay: 0.3s">
                <i class="ri-user-star-line action-icon"></i>
                <h3 class="action-title">Angajați Activi</h3>
                <p class="action-description">
                    Consultați lista angajaților activi și statusul lor curent în organizație.
                </p>
            </a>
        </div>

        <!-- Secțiunea de management -->
        <h2 class="section-title fade-in">⚙️ Gestionare & Administrare</h2>
        <div class="actions-grid management-section">
            <!-- Acordare sporuri -->
            <a href="sporuri.jsp" class="action-card fade-in" style="animation-delay: 0.4s">
                <i class="ri-award-line action-icon"></i>
                <h3 class="action-title">Acordare Sporuri</h3>
                <p class="action-description">
                    Gestionați și acordați sporuri salariale pentru performanță sau condiții speciale.
                </p>
            </a>

            <!-- Penalizări -->
            <a href="penalizari.jsp" class="action-card fade-in" style="animation-delay: 0.5s">
                <i class="ri-alert-line action-icon"></i>
                <h3 class="action-title">Gestionare Penalizări</h3>
                <p class="action-description">
                    Aplicați și monitorizați penalizările pentru nerespectarea regulamentelor.
                </p>
            </a>

            <!-- Promovări -->
            <a href="promovare.jsp" class="action-card fade-in" style="animation-delay: 0.6s">
                <i class="ri-arrow-up-circle-line action-icon"></i>
                <h3 class="action-title">Promovare Angajați</h3>
                <p class="action-description">
                    Procesați promovările angajaților și actualizați pozițiile și salariile.
                </p>
            </a>

            <!-- Gestionare salarii -->
            <a href="fluturas.jsp" class="action-card fade-in" style="animation-delay: 0.7s">
                <i class="ri-money-dollar-circle-line action-icon"></i>
                <h3 class="action-title">Gestionare Salarii</h3>
                <p class="action-description">
                    Administrați salariile, generați fluturași și gestionați compensațiile.
                </p>
            </a>

            <!-- Încetare contracte -->
            <a href="incetare_contract.jsp" class="action-card fade-in" style="animation-delay: 0.8s">
                <i class="ri-user-unfollow-line action-icon"></i>
                <h3 class="action-title">Încetare Contracte</h3>
                <p class="action-description">
                    Procesați încetările de contracte și gestionați procedurile de plecare.
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

        // Highlight pentru statistici
        document.querySelectorAll('.stat-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.background = 'var(--hover-color)';
            });
            
            card.addEventListener('mouseleave', function() {
                this.style.background = 'var(--card-color)';
            });
        });
    </script>
</body>
</html>