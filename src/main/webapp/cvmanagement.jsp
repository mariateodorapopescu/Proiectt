<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%

// Verificare sesiune și obținere user curent
HttpSession sesi = request.getSession(false);

if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

    if (currentUser != null) {
        String username = currentUser.getUsername();
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
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
                if (rs.next()) {
                    // extrag date despre userul curent
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    // Această pagină poate fi accesată de orice utilizator autentificat
                    // Fiecare utilizator poate gestiona propriul CV
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Management CV</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .cv-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin: 40px 0;
        }
        
        .cv-action-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 30px;
            text-align: center;
            width: 250px;
            transition: transform 0.3s;
        }
        
        .cv-action-card:hover {
            transform: translateY(-5px);
        }
        
        .cv-action-card i {
            font-size: 48px;
            color: #3498db;
            margin-bottom: 20px;
        }
        
        .cv-action-card h3 {
            margin: 0 0 10px 0;
            color: #2c3e50;
        }
        
        .cv-action-card p {
            color: #7f8c8d;
            margin-bottom: 20px;
        }
        
        .btn {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            color: white;
            background: #3498db;
            transition: background 0.3s;
        }
        
        .btn:hover {
            background: #2980b9;
        }
        
        .btn-secondary {
            background: #95a5a6;
        }
        
        .btn-secondary:hover {
            background: #7f8c8d;
        }
    </style>
</head>
<body class="bg" onload="getTheme()">
   
            <h1>Management CV</h1>
            
            <div class="cv-actions">
                <div class="cv-action-card">
                    <i>📄</i>
                    <h3>Generează CV</h3>
                    <p>Generează CV-ul tău bazat pe toate informațiile din profil</p>
                    <a href="CVGeneratorServlet?action=generate" class="btn">Generează</a>
                </div>
                
                <div class="cv-action-card">
                    <i>✏️</i>
                    <h3>Editează Informații</h3>
                    <p>Actualizează informațiile tale pentru CV</p>
                    <a href="CVServlet?action=edit" class="btn btn-secondary">Editează</a>
                </div>
                
                <div class="cv-action-card">
                    <i>📥</i>
                    <h3>Exportă CV</h3>
                    <p>Descarcă CV-ul în format PDF</p>
                    <a href="CVGeneratorServlet?action=export" class="btn">Exportă PDF</a>
                </div>
            </div>
        </section>
    </main>
    
    <script src="js/core2.js"></script>
</body>
</html>

<%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
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