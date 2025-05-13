<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

//structura unei pagini este astfel
//verificare daca exista sesiune activa, utilizator conectat, 
//extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//se mai extrag temele de culoare ale fiecarui utilizator
//apoi se incarca pagina in sine

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizatoir in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                            "dp.denumire_completa AS denumire FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (rs.next()) {
                    	// extrag date despre userul curent
                        int id = rs.getInt("id");
                        int userType = rs.getInt("tip");
                        int userdep = rs.getInt("id_dep");
                        String functie = rs.getString("functie");
                        int ierarhie = rs.getInt("ierarhie");

                        // Functie helper pentru a determina rolul utilizatorului
                        boolean isDirector = (ierarhie < 3) ;
                        boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                        boolean isIncepator = (ierarhie >= 10);
                        boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                        boolean isAdmin = (functie.compareTo("Administrator") == 0);
                        if (!isAdmin) {
                    	// aflu data curenta, tot ca o interogare bd =(
                    	String today = "";
                   	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                               try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                      today =  rs2.getString("today");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
                   	 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                   	 String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
                  	 String clr = "#d8d9e1";
                  	 String sidebar = "#ECEDFA";
                  	 String text = "#333";
                  	 String card = "#ECEDFA";
                  	 String hover = "#ECEDFA";
                  	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
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
                    	%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    
    <!--=============== FONT AWESOME ===============-->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
    <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Hărți și Rute</title>
    
    <style>
        :root {
            --accent-color: <%=accent%>;
            --bg-color: <%=clr%>;
            --sidebar-color: <%=sidebar%>;
            --text-color: <%=text%>;
            --card-color: <%=card%>;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }
        
        .main-container {
            display: flex;
            flex-direction: column;
            padding: 20px;
            max-width: 1200px;
            margin: 0 auto;
            min-height: calc(100vh - 40px);
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            position: relative;
            padding-bottom: 15px;
        }
        
        .header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 3px;
            background-color: var(--accent-color);
            border-radius: 3px;
        }
        
        .header h1 {
            color: var(--accent-color);
            margin-bottom: 5px;
            font-size: 2.2rem;
        }
        
        .header p {
            color: var(--text-color);
            opacity: 0.8;
            margin: 0;
            font-size: 1.1rem;
        }
        
        .menu-container {
            display: flex;
            flex-direction: column;
            gap: 25px;
            flex: 1;
        }
        
        .menu-section {
            background-color: var(--sidebar-color);
            border-radius: 12px;
            padding: 20px;
            
        }
        
        .menu-section h2 {
            color: var(--accent-color);
            margin-top: 0;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            font-size: 1.5rem;
        }
        
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .action-button {
            position: relative;
            background-color: var(--accent-color);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 15px;
            min-height: 60px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 14px;
            font-weight: 500;
            text-align: left;
            
            display: flex;
            align-items: center;
            overflow: hidden;
        }
        
        .action-button:hover {
            transform: translateY(-3px);
            
            background-color: #0e3b8e;
        }
        
        .action-button i {
            margin-right: 12px;
            font-size: 1.3rem;
        }
        
        .action-button::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            height: 100%;
            width: 10px;
            background-color: rgba(255, 255, 255, 0.2);
            transform: skew(-15deg) translateX(10px);
            transition: transform 0.3s ease;
        }
        
        .action-button:hover::after {
            transform: skew(-15deg) translateX(0);
        }
        
        .action-button a {
            color: white !important;
            text-decoration: none;
            display: flex;
            align-items: center;
            width: 100%;
            height: 100%;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding: 15px 0;
            color: var(--text-color);
            opacity: 0.7;
            font-size: 0.9rem;
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .actions-grid {
                grid-template-columns: 1fr;
            }
            
            .header h1 {
                font-size: 1.8rem;
            }
            
            .header p {
                font-size: 1rem;
            }
            
            .menu-section {
                padding: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <div class="header">
            <h1>Hărți și Rute</h1>
            <p>Alegeti opțiunea dorită pentru vizualizarea hărților și rutelor</p>
        </div>
        
        <div class="menu-container">
            <div class="menu-section">
                <h2><i class="fa-solid fa-location-dot"></i> De la locația actuală</h2>
                <div class="actions-grid">
                    <button class="action-button">
                        <a href="NewFile.jsp">
                            <i class="fa-solid fa-house"></i>
                            Acasă
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii1.jsp">
                            <i class="fa-solid fa-building"></i>
                            Sediul departamentului personal
                        </a>
                    </button>
                    
                    <button class="action-button">
                        <a href="rutare_sediu_apropiat.jsp">
                            <i class="fa-solid fa-building-circle-check"></i>
                            Cel mai apropiat sediu
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="rutare_concedii_personale.jsp">
                            <i class="fa-solid fa-calendar-check"></i>
                            Un anumit concediu
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="rutare_urmatorul_concediu.jsp">
                            <i class="fa-solid fa-person-walking-luggage"></i>
                            Cel mai apropiat concediu
                        </a>
                    </button>
                    <% if (isDirector) { %>
                    <button class="action-button">
                        <a href="rutare_departament.jsp">
                            <i class="fa-solid fa-sitemap"></i>
                            Sediul unui anumit departament
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="rutare_sediu_select.jsp">
                            <i class="fa-solid fa-building-user"></i>
                            Un anumit sediu
                        </a>
                    </button>
                    <% } %>
                </div>
            </div>
            
            <div class="menu-section">
                <h2><i class="fa-solid fa-house"></i> De acasă</h2>
                <div class="actions-grid">
                    <button class="action-button">
                        <a href="harta_concedii1.jsp">
                            <i class="fa-solid fa-building"></i>
                            Sediul departamentului personal
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-building-circle-check"></i>
                            Cel mai apropiat sediu
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-calendar-check"></i>
                            Un anumit concediu
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-person-walking-luggage"></i>
                            Cel mai apropiat concediu
                        </a>
                    </button>
                    <% if (isDirector) { %>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-sitemap"></i>
                            Sediul unui anumit departament
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-building-user"></i>
                            Un anumit sediu
                        </a>
                    </button>
                    <% } %>
                </div>
            </div>
            
            <div class="menu-section">
                <h2><i class="fa-solid fa-building"></i> De la sediul meu</h2>
                <div class="actions-grid">
                    <button class="action-button">
                        <a href="harta_concedii1.jsp">
                            <i class="fa-solid fa-building"></i>
                            Sediul departamentului personal
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-calendar-check"></i>
                            Un anumit concediu
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-person-walking-luggage"></i>
                            Cel mai apropiat concediu
                        </a>
                    </button>
                    <% if (isDirector) { %>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-sitemap"></i>
                            Sediul unui anumit departament
                        </a>
                    </button>
                    <button class="action-button">
                        <a href="harta_concedii2.jsp">
                            <i class="fa-solid fa-building-user"></i>
                            Un anumit sediu
                        </a>
                    </button>
                    <% } %>
                </div>
            </div>
        </div>
        
        <div class="footer">
            &copy; <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %> Toate drepturile rezervate
        </div>
    </div>

    <script src="./responsive-login-form-main/assets/js/index.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>

</body>
</html>
                       <%
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
                e.printStackTrace();
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