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
                    if (rs.getString("tip").compareTo("5") == 0) {
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
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

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

<div class="main-content">
    
    <div class="card">
        <h3>Statistici personale la data de <% 
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement2 = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today")) {
                ResultSet rs2 = preparedStatement2.executeQuery();
                if (rs2.next()) {
                    out.println(rs2.getString("today"));
                }
            } catch (SQLException e) {
                out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                e.printStackTrace();
            }
        %></h3>
        <div class="info">
            <%
                String email = "";
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement stmt = connection.prepareStatement("SELECT nume, prenume, data_nasterii, adresa, email, telefon, username, denumire, nume_dep, zilecons, zileramase, conluate, conramase FROM useri NATURAL JOIN tipuri NATURAL JOIN departament WHERE username = ?")) {
                    stmt.setString(1, username);
                    ResultSet rs1 = stmt.executeQuery();
                    if (rs1.next()) {
                        email = rs1.getString("email");
                        out.println("<div><span>Concedii luate:</span> " + rs1.getString("conluate") + "</div>");
                        out.println("<div><span>Concedii ramase:</span> " + rs1.getString("conramase") + "</div>");
                        out.println("<div><span>Zile luate:</span> " + rs1.getString("zilecons") + "</div>");
                        out.println("<div><span>Zile ramase:</span> " + rs1.getString("zileramase") + "</div>");
                    } else {
                        out.println("<div>Nu exista date.</div>");
                    }
                } catch (SQLException e) {
                    out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                    e.printStackTrace();
                }
            %>
        </div>
        <%
        int cate = -1;
   	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
            // Check for upcoming leaves in 3 days
            String query = "SELECT COUNT(*) AS count FROM concedii WHERE start_c + 3 >= date(NOW()) AND id_ang = ?";
            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                stmt.setInt(1, id);
                try (ResultSet rs2 = stmt.executeQuery()) {
                    if (rs2.next() && rs2.getInt("count") > 0) {
                       cate =  rs2.getInt("count");
                    }
                }
            }
           // System.out.println(cate);
            // Display the user dashboard or related information
            //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
            // Add additional user-specific content here
        } catch (SQLException e) {
            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
            e.printStackTrace();
        }
   	 
        int cate2 = -1;
     	if (cate >= 1) {
     		 String query2 = "SELECT CASE WHEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) between 0 and 4 THEN DATEDIFF(start_c, (SELECT date_checked FROM date_logs ORDER BY date_checked DESC LIMIT 1)) ELSE -1 END AS dif FROM concedii WHERE id_ang = ? order by dif desc limit 1";
             try (PreparedStatement stmt = connection.prepareStatement(query2)) {
                 stmt.setInt(1, id);
                 try (ResultSet rs2 = stmt.executeQuery()) {
                     if (rs2.next() && rs2.getInt("dif") > 0) {
                        cate2 =  rs2.getInt("dif");
                        
                     }
                 }
             }
             // System.out.println(cate2);
             if (cate2 > 0)
	     		{
            	 //out.println ("Aveti un concediu in mai putin de " + cate2 + " zile!");
            	 // isi ia deconectare dupa si nu inteleg de ce + nu merge redirectarea ok + cum automatizez?
            		System.out.println("ok");
	     		}
     	}
        %>
    </div>
    <div class="card">
        <h3>Statistici concedii la data de <% 
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement2 = connection.prepareStatement("SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today")) {
                ResultSet rs2 = preparedStatement2.executeQuery();
                if (rs2.next()) {
                    out.println(rs2.getString("today"));
                }
            } catch (SQLException e) {
                out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                e.printStackTrace();
            }
        %></h3>
        <div class="info">
            <%
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total FROM concedii WHERE status = ?");
                    int[] statuses = {-2, -1, 2, 1, 0};
                    String[] labels = {"Respinse director", "Respinse sef", "Aprobate director", "Aprobate sef", "In asteptare"};
                    for (int i = 0; i < statuses.length; i++) {
                        stmt.setInt(1, statuses[i]);
                        ResultSet rs2 = stmt.executeQuery();
                        if (rs2.next()) {
                            out.println("<div><span>" + labels[i] + ":</span> " + rs2.getString("total") + "</div>");
                        }
                    }
                } catch (SQLException e) {
                    out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                    e.printStackTrace();
                }
            %>
        </div>
    </div>
    
</div>

        <button style="box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" id="generate" class="btn btn-primary" onclick="generate()">Descarcati PDF</button>

 <%
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
               
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                } else if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                } else if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                } else if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }  else if (currentUser.getTip() == 4) {
                    response.sendRedirect("homeadmin.jsp");
                }
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
<script>
function generate() {
    const element = document.querySelector('.main-content');
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
    }).from(element).save();
}
</script>
</body>
</html>
