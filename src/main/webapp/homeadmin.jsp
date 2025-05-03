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
                PreparedStatement preparedStatement = connection.prepareStatement(
                		"SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
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
                    if (!isAdmin) {
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
<div class="main-content">
    
    <div class="card">
        <h3>Statistici la data de <% 
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
                
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                     PreparedStatement stmt = connection.prepareStatement("SELECT count(*) as total from departament")) {
                    
                    ResultSet rs1 = stmt.executeQuery();
                    if (rs1.next()) {
                        
                        out.println("<div><span>Total departamente:</span> " + rs1.getString("total") + "</div>");
                       
                    } else {
                        out.println("<div>Nu exista date.</div>");
                    }
                } catch (SQLException e) {
                    out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                    e.printStackTrace();
                }
          
          
                try (Connection connn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                    PreparedStatement stmt2 = connection.prepareStatement("SELECT count(*) as total FROM useri where id <> 38");
                   
                        ResultSet rs2 = stmt2.executeQuery();
                        if (rs2.next()) {
                        	 out.println("<div><span>Total angajati:</span> " + rs2.getString("total") + "</div>");
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
