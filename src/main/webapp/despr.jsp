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
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri natural join departament natural join tipuri WHERE username = ?")) {
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
                    String functie = rs.getString("denumire");
                    
                    // Variabile pentru tema
                    String accent = "#3B82F6";
                    String clr = "#F8FAFC";
                    String sidebar = "#FFFFFF";
                    String text = "#1E293B";
                    String card = "#FFFFFF";
                    String hover = "#F1F5F9";
                    
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        String query = "SELECT * from teme where id_usr = ?";
                        try (PreparedStatement stmt = connection.prepareStatement(query)) {
                            stmt.setInt(1, id);
                            try (ResultSet rs2 = stmt.executeQuery()) {
                                if (rs2.next()) {
                                    String tempAccent = rs2.getString("accent");
                                    String tempClr = rs2.getString("clr");
                                    String tempSidebar = rs2.getString("sidebar");
                                    String tempText = rs2.getString("text");
                                    String tempCard = rs2.getString("card");
                                    String tempHover = rs2.getString("hover");
                                    
                                    if (tempAccent != null && !tempAccent.isEmpty()) accent = tempAccent;
                                    if (tempClr != null && !tempClr.isEmpty()) clr = tempClr;
                                    if (tempSidebar != null && !tempSidebar.isEmpty()) sidebar = tempSidebar;
                                    if (tempText != null && !tempText.isEmpty()) text = tempText;
                                    if (tempCard != null && !tempCard.isEmpty()) card = tempCard;
                                    if (tempHover != null && !tempHover.isEmpty()) hover = tempHover;
                                }
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                        e.printStackTrace();
                    }
                    
                    if (rs.getString("tip").compareTo("5") == 0) {
                        response.sendRedirect("adminok.jsp");
                    } else {
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profil Utilizator - <%=prenume%></title>
    <link href="https://cdn.jsdelivr.net/npm/remixicons@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: <%=accent%>;
            --background: <%=clr%>;
            --surface: <%=sidebar%>;
            --text-primary: <%=text%>;
            --text-secondary: #64748B;
            --border: #E2E8F0;
            --hover: <%=hover%>;
            --success: #10B981;
            --warning: #F59E0B;
            --error: #EF4444;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, var(--background) 0%, var(--hover) 100%);
            color: var(--text-primary);
            min-height: 100vh;
            line-height: 1.6;
            overflow-x: hidden;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 1rem;
            min-height: 100vh;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding-top: 2rem;
        }

        .profile-wrapper {
            width: 100%;
            max-width: 1200px;
            display: grid;
            grid-template-columns: 350px 1fr;
            gap: 2rem;
            align-items: start;
        }

        /* Profile Card */
        .profile-card {
            background: var(--surface);
            border-radius: 2rem;
            padding: 2rem;
           
            text-align: center;
            position: relative;
            overflow: hidden;
            min-width: 300px;
            max-width: 400px;
            margin: 0 auto;
        }

        .profile-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: linear-gradient(90deg, var(--primary), var(--hover));
        }

        .profile-image-container {
            position: relative;
            display: inline-block;
            margin-bottom: 1.5rem;
        }

        .profile-image {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid var(--primary);
            
            transition: all 0.3s ease;
        }

        .profile-image:hover {
            transform: scale(1.05);
            border: 4px solid var(--surface);
        }

        .status-indicator {
            position: absolute;
            bottom: 10px;
            right: 10px;
            width: 20px;
            height: 20px;
            background: var(--success);
            border: 3px solid white;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            background: var(--primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .profile-role {
            font-size: 1.1rem;
            color: var(--text);
            margin-bottom: 2rem;
            font-weight: 500;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: var(--surface);
            padding: 1.5rem;
            border-radius: 1rem;
            box-shadow: var(--shadow);
            text-align: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
        }

        .stat-icon {
            width: 3rem;
            height: 3rem;
            margin: 0 auto 1rem;
            background: linear-gradient(135deg, var(--primary), var(--hover));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.25rem;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 0.875rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 1rem 1.5rem;
            border: none;
            border-radius: 1rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
            cursor: pointer;
            font-size: 0.95rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--hover));
            color: white;
            box-shadow: var(--shadow);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
        }

        .btn-secondary {
            background: var(--hover);
            color: var(--text-primary);
            border: 2px solid var(--border);
        }

        .btn-secondary:hover {
            background: var(--border);
            transform: translateY(-2px);
        }

        /* Details Card */
        .details-card {
            background: var(--surface);
            border-radius: 2rem;
            padding: 2rem;
            box-shadow: var(--shadow-lg);
            min-width: 0;
            width: 100%;
        }

        .details-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--border);
        }

        .details-icon {
            width: 3rem;
            height: 3rem;
            background: linear-gradient(135deg, var(--primary), var(--hover));
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
        }

        .details-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .info-grid {
            display: grid;
            gap: 1.5rem;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            padding: 1rem;
            background: var(--hover);
            border-radius: 1rem;
            transition: all 0.3s ease;
        }

        .info-item:hover {
            background: var(--border);
            transform: translateX(4px);
        }

        .info-icon {
            width: 2.5rem;
            height: 2.5rem;
            background: var(--primary);
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1rem;
            flex-shrink: 0;
        }

        .info-content {
            flex: 1;
        }

        .info-label {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.25rem;
        }

        .info-value {
            font-size: 1rem;
            font-weight: 500;
            color: var(--text-primary);
            word-break: break-word;
            overflow-wrap: break-word;
        }

        /* Back Button */
        .back-button {
            position: fixed;
            top: 2rem;
            left: 2rem;
            width: 3rem;
            height: 3rem;
            background: var(--primary);
            border: none;
            border-radius: 50%;
           color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            z-index: 100;
        }

        .back-button:hover {
            background: black;
            color: white;
            transform: scale(1.1);
        }

        /* Responsive Design */
        @media (max-width: 1024px) {
            .profile-wrapper {
                grid-template-columns: 320px 1fr;
                gap: 1.5rem;
            }
            
            .container {
                padding: 1rem;
            }
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
                align-items: flex-start;
                padding-top: 1rem;
            }

            .profile-wrapper {
                grid-template-columns: 1fr;
                gap: 1.5rem;
                max-width: 100%;
            }
            
            .profile-card {
                max-width: 100%;
                min-width: auto;
            }

            .profile-name {
                font-size: 1.75rem;
            }

            .details-card {
                padding: 1.5rem;
            }

            .back-button {
                top: 1rem;
                left: 1rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 480px) {
            .container {
                padding: 0.5rem;
            }
            
            .profile-card,
            .details-card {
                padding: 1.5rem;
                border-radius: 1.5rem;
            }

            .profile-image {
                width: 120px;
                height: 120px;
            }

            .action-buttons {
                gap: 0.75rem;
            }

            .btn {
                padding: 0.875rem 1.25rem;
                font-size: 0.875rem;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
                gap: 0.75rem;
            }
            
            .stat-card {
                padding: 1rem;
            }
            
            .info-item {
                padding: 0.875rem;
                flex-direction: column;
                text-align: center;
                gap: 0.75rem;
            }
            
            .info-icon {
                margin: 0 auto;
            }
        }

        @media (max-width: 360px) {
            .profile-name {
                font-size: 1.5rem;
            }
            
            .details-title {
                font-size: 1.25rem;
            }
            
            .btn {
                padding: 0.75rem 1rem;
                font-size: 0.8rem;
            }
        }

        /* Loading Animation */
        .loading {
            opacity: 0;
            animation: fadeIn 0.6s ease-out forwards;
        }

        @keyframes fadeIn {
            to { opacity: 1; }
        }
    </style>
</head>
<body>
    <!-- Back Button -->
    <button class="back-button" onclick="history.back()" title="Înapoi">
        <i class="ri-arrow-left-line"></i>
    </button>

    <div class="container">
        <div class="profile-wrapper loading">
            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-image-container">
                    <img src="${pageContext.request.contextPath}/ImageServlet" 
                         alt="Imagine profil <%=prenume%>" 
                         class="profile-image"
                         onerror="this.src='https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'">
                    <div class="status-indicator" title="Online"></div>
                </div>
                
                <h1 class="profile-name"><%=rs.getString("nume")%> <%=prenume%></h1>
                <p class="profile-role"><%=functie%></p>

                <!-- Quick Stats -->
                <div class="stats-grid">
                    <%
                    // Obține statistici rapide
                    int concediiLuate = 0;
                    int zileConcediu = 0;
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT conluate, zilecons FROM useri WHERE id = ?")) {
                        stmt.setInt(1, id);
                        ResultSet rsStats = stmt.executeQuery();
                        if (rsStats.next()) {
                            concediiLuate = rsStats.getInt("conluate");
                            zileConcediu = rsStats.getInt("zilecons");
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                    
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="ri-calendar-check-line"></i>
                        </div>
                        <div class="stat-value"><%=concediiLuate%></div>
                        <div class="stat-label">Concedii Luate</div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="ri-time-line"></i>
                        </div>
                        <div class="stat-value"><%=zileConcediu%></div>
                        <div class="stat-label">Zile Concediu</div>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <a href="modifydata.jsp" class="btn btn-primary">
                        <i class="ri-edit-line"></i>
                        Modifică Datele Personale
                    </a>
                    <a href="addpic.jsp" class="btn btn-secondary">
                        <i class="ri-image-edit-line"></i>
                        Schimbă Imaginea de Profil
                    </a>
                </div>
            </div>

            <!-- Details Card -->
            <div class="details-card">
                <div class="details-header">
                    <div class="details-icon">
                        <i class="ri-user-settings-line"></i>
                    </div>
                    <h2 class="details-title">Informații Personale</h2>
                </div>

                <div class="info-grid">
                    <%
                    try (PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, data_nasterii, adresa, email, telefon, username, denumire, nume_dep FROM useri NATURAL JOIN tipuri NATURAL JOIN departament WHERE username = ?")) {
                        stmt.setString(1, username);
                        ResultSet rs1 = stmt.executeQuery();
                        if (rs1.next()) {
                    %>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-user-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Nume Complet</div>
                            <div class="info-value"><%=rs1.getString("nume")%> <%=rs1.getString("prenume")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-calendar-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Data Nașterii</div>
                            <div class="info-value"><%=rs1.getString("data_nasterii")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-map-pin-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Adresa</div>
                            <div class="info-value"><%=(rs1.getString("adresa") != null ? rs1.getString("adresa") : "Nespecificată")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-mail-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">E-mail</div>
                            <div class="info-value"><%=rs1.getString("email")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-phone-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Telefon</div>
                            <div class="info-value"><%=rs1.getString("telefon")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-at-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Nume Utilizator</div>
                            <div class="info-value"><%=rs1.getString("username")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-briefcase-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Funcție</div>
                            <div class="info-value"><%=rs1.getString("denumire")%></div>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-building-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Departament</div>
                            <div class="info-value"><%=rs1.getString("nume_dep")%></div>
                        </div>
                    </div>

                    <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    %>
                    
                    <div class="info-item">
                        <div class="info-icon">
                            <i class="ri-error-warning-line"></i>
                        </div>
                        <div class="info-content">
                            <div class="info-label">Eroare</div>
                            <div class="info-value">Nu s-au putut încărca datele</div>
                        </div>
                    </div>
                    
                    <%
                    }
                    %>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Animation on load
        document.addEventListener('DOMContentLoaded', function() {
            const elements = document.querySelectorAll('.loading');
            elements.forEach((el, index) => {
                setTimeout(() => {
                    el.style.animationDelay = index * 0.1 + 's';
                }, 100);
            });
        });

        // Profile image error handling
        const profileImage = document.querySelector('.profile-image');
        if (profileImage) {
            profileImage.addEventListener('error', function() {
                this.src = 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
            });
        }

        // Handle URL parameters for alerts
        const urlParams = new URLSearchParams(window.location.search);
        
        if (urlParams.get('n') === 'true') {
            alert('Nume scris incorect!');
        }
        if (urlParams.get('pn') === 'true') {
            alert('Prenume scris incorect!');
        }
        if (urlParams.get('t') === 'true') {
            alert('Telefon scris incorect!');
        }
        if (urlParams.get('e') === 'true') {
            alert('E-mail scris incorect!');
        }
        if (urlParams.get('dn') === 'true') {
            alert('Utilizatorul trebuie sa aiba minim 18 ani!');
        }
        if (urlParams.get('pms') === 'true') {
            alert('Poate fi maxim un sef / departament!');
        }
        if (urlParams.get('pmd') === 'true') {
            alert('Poate fi maxim un director / departament!');
        }
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