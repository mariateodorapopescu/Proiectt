
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
    int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT tip, id, id_dep FROM useri WHERE username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    int userType = rs.getInt("tip");
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    // Doar Admin HR sau Director poate accesa
                    if (userType != 0 && userType != 4 && (userType != 3 || userDep != 1)) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * from teme where id_usr = ?";
                            try (PreparedStatement stmt = con.prepareStatement(query)) {
                                stmt.setInt(1, userId);
                                try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                        accent = rs2.getString("accent");
                                        clr = rs2.getString("clr");
                                        sidebar = rs2.getString("sidebar");
                                        text = rs2.getString("text");
                                        card = rs2.getString("card");
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
    <title>Încetare Contract</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="responsive-login-form-main/assets/css/core2.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    
    <link rel="stylesheet" href="css/core2.css">
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
        
        .status-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 14px;
        }
        .status-neaprobat { background-color: #88aedb; }
        .status-dezaprobat-sef { background-color: #b37142; }
        .status-dezaprobat-director { background-color: #873931; }
        .status-aprobat-director { background-color: #40854a; }
        .status-aprobat-sef { background-color: #ccc55e; }
        .status-pending { background-color: #e0a800; }
       
        .tooltip {
            position: relative;
            display: inline-block;
            border-bottom: 1px dotted black;
        }

        .tooltip .tooltiptext {
            visibility: hidden;
            width: 120px;
            background-color: rgba(0,0,0,0.5);
            color: white;
            text-align: center;
            padding: 5px 0;
            border-radius: 6px;
            position: absolute;
            z-index: 1;
        }

        .tooltip:hover .tooltiptext {
            visibility: visible;
        }
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .btn-danger {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
            border-radius: 4px;
        }
        .btn-danger:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
            <h2>Incetare Contract de Munca</h2>
            <form id="incetareForm" method="POST" action="IncetareContractServlet">
                <label for="angajat">Selectati Angajatul:</label>
                <select id="angajat" name="id_ang" required>
                    <option value="">-- Selectati --</option>
                    <%
                    Connection conn2 = null;
                    PreparedStatement pstmt2 = null;
                    ResultSet rs3 = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT id, nume, prenume FROM useri WHERE id_dep = ? AND id != ? AND activ = 1";
                        pstmt2 = conn2.prepareStatement(sql);
                        pstmt2.setInt(1, userDep);
                        pstmt2.setInt(2, userId);
                        rs3 = pstmt2.executeQuery();
                        
                        while (rs3.next()) {
                    %>
                            <option value="<%= rs3.getInt("id") %>">
                                <%= rs3.getString("nume") %> <%= rs3.getString("prenume") %>
                            </option>
                    <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (conn2 != null) try { conn2.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                    %>
                </select>
                
                <label for="dataIncetare">Data Incetare Contract:</label>
                <input type="date" id="dataIncetare" name="data_incetare" required>
                
                <label for="motivIncetare">Motiv Incetare:</label>
                <select id="motivIncetare" name="motiv_incetare" required>
                    <option value="">-- Selectati --</option>
                    <option value="demisie">Demisie</option>
                    <option value="concediere_disciplinara">Concediere disciplinara</option>
                    <option value="concediere_colectiva">Concediere colectiva</option>
                    <option value="pensionare">Pensionare</option>
                    <option value="expirare_contract">Expirare contract</option>
                    <option value="acord_parti">Acord parti</option>
                    <option value="incetare_perioada_proba">Incetare in perioada de proba</option>
                    <option value="deces">Deces</option>
                </select>
                
                <label for="observatii">Observatii:</label>
                <textarea id="observatii" name="observatii" rows="4"></textarea>
                
                <div class="alert alert-warning">
                    <strong>Atenție!</strong> Aceasta actiune este ireversibila. 
                    Angajatul va fi marcat ca inactiv si nu va mai avea acces la sistem.
                </div>
                
                <button type="submit" class="btn btn-danger" onclick="return confirm('Sunteti sigur(a) ca doriti sa incetati contractul acestui angajat?')">
                    Incetare Contract
                </button>
            </form>
       

    <script>
        document.getElementById('incetareForm').addEventListener('submit', function(e) {
            const dataIncetare = new Date(document.getElementById('dataIncetare').value);
            const today = new Date();
            
            if (dataIncetare < today) {
                e.preventDefault();
                alert('Data incetării nu poate fi in trecut!');
            }
        });
    </script>
    <script src="js/core2.js"></script>
<%
                    }
                }
                            
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Eroare la baza de date!');");
                                out.println("</script>");
                                response.sendRedirect("login.jsp");
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
</body>
</html>