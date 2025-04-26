<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.NumberFormat" %>

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
                    if (userType != 0 && userType != 4 && (userType != 3 || userDep != 1)) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("ro", "RO"));
                        
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
    <title>Generare Fluturas Salariu</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="responsive-login-form-main/assets/css/core2.css">
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
    
        .fluturas {
            background: white;
            padding: 20px;
            margin: 20px 0;
            border: 1px solid #ddd;
            border-radius: 8px;
        }
        .fluturas-header {
            text-align: center;
            margin-bottom: 20px;
        }
        .fluturas-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .fluturas-table th, .fluturas-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        .fluturas-table th {
            background-color: #f4f4f4;
        }
        .total-row {
            font-weight: bold;
            background-color: #f9f9f9;
        }
        @media print {
            body * {
                visibility: hidden;
            }
            .fluturas, .fluturas * {
                visibility: visible;
            }
            .fluturas {
                position: absolute;
                left: 0;
                top: 0;
            }
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
    
            <h2>Generare Fluturas Salariu</h2>
            
            <form id="fluturasForm" method="GET">
                <label for="angajat">Selectati Angajatul:</label>
                <select id="angajat" name="id_ang" required>
                    <option value="">-- Selectati --</option>
                    <%
                    Connection conn = null;
                    PreparedStatement pstmt = null;
                    ResultSet rs3 = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                        String sql = "SELECT id, nume, prenume FROM useri WHERE id_dep = ? AND id != ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, userDep);
                        pstmt.setInt(2, userId);
                        rs3 = pstmt.executeQuery();
                        
                        while (rs3.next()) {
                    %>
                            <option value="<%= rs3.getInt("id") %>" 
                                <%= request.getParameter("id_ang") != null && 
                                    request.getParameter("id_ang").equals(String.valueOf(rs3.getInt("id"))) ? 
                                    "selected" : "" %>>
                                <%= rs3.getString("nume") %> <%= rs3.getString("prenume") %>
                            </option>
                    <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                    %>
                </select>
                
                <label for="luna">Luna:</label>
                <select id="luna" name="luna" required>
                    <%
                    for (int i = 1; i <= 12; i++) {
                        String selected = request.getParameter("luna") != null && 
                                        request.getParameter("luna").equals(String.valueOf(i)) ? 
                                        "selected" : "";
                    %>
                        <option value="<%= i %>" <%= selected %>><%= new String[]{"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"}[i-1] %></option>
                    <%
                    }
                    %>
                </select>
                
                <label for="an">An:</label>
                <select id="an" name="an" required>
                    <%
                    int currentYear = LocalDate.now().getYear();
                    for (int i = currentYear - 2; i <= currentYear; i++) {
                        String selected = request.getParameter("an") != null && 
                                        request.getParameter("an").equals(String.valueOf(i)) ? 
                                        "selected" : "";
                    %>
                        <option value="<%= i %>" <%= selected %>><%= i %></option>
                    <%
                    }
                    %>
                </select>
                
                <button type="submit" class="btn">Generare Fluturas</button>
            </form>
            
            <%
            if (request.getParameter("id_ang") != null && 
                request.getParameter("luna") != null && 
                request.getParameter("an") != null) {
                
                int idAng = Integer.parseInt(request.getParameter("id_ang"));
                int luna = Integer.parseInt(request.getParameter("luna"));
                int an = Integer.parseInt(request.getParameter("an"));
                
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs4 = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    
                    // Date angajat
                    String sql = "SELECT u.*, t.salariu as salariu_baza, t.denumire as functie, " +
                               "d.nume_dep, s.procent as procent_spor, p.procent as procent_penalizare, " +
                               "s.denumire as denumire_spor, p.denumire as denumire_penalizare " +
                               "FROM useri u " +
                               "JOIN tipuri t ON u.tip = t.tip " +
                               "JOIN departament d ON u.id_dep = d.id_dep " +
                               "LEFT JOIN tipuri_sporuri s ON u.sporuri = s.id " +
                               "LEFT JOIN tipuri_penalizari p ON u.penalizari = p.id " +
                               "WHERE u.id = ?";
                    pstmt2 = conn2.prepareStatement(sql);
                    pstmt2.setInt(1, idAng);
                    rs4 = pstmt2.executeQuery();
                    
                    if (rs4.next()) {
                        double salariuBaza = rs4.getDouble("salariu_baza");
                        double procentSpor = rs4.getDouble("procent_spor");
                        double procentPenalizare = rs4.getDouble("procent_penalizare");
                        String denumireSpor = rs4.getString("denumire_spor");
                        String denumirePenalizare = rs4.getString("denumire_penalizare");
                        
                        // Calculare salariu
                        double spor = salariuBaza * procentSpor / 100;
                        double penalizare = salariuBaza * procentPenalizare / 100;
                        double salariuBrut = salariuBaza + spor - penalizare;
                        
                        // Calcul contribuții
                        double cas = salariuBrut * 0.25;
                        double cass = salariuBrut * 0.10;
                        double impozit = (salariuBrut - cas - cass) * 0.10;
                        double salariuNet = salariuBrut - cas - cass - impozit;
            %>
                        <div class="fluturas">
                            <div class="fluturas-header">
                                <h3>FLUTURAS DE SALARIU</h3>
                                <p><%= new String[]{"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"}[luna-1] %> <%= an %></p>
                            </div>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th colspan="2">Date angajat</th>
                                </tr>
                                <tr>
                                    <td>Nume si prenume:</td>
                                    <td><%= rs4.getString("nume") %> <%= rs4.getString("prenume") %></td>
                                </tr>
                                <tr>
                                    <td>CNP:</td>
                                    <td><%= rs4.getString("cnp") %></td>
                                </tr>
                                <tr>
                                    <td>Funcție:</td>
                                    <td><%= rs4.getString("functie") %></td>
                                </tr>
                                <tr>
                                    <td>Departament:</td>
                                    <td><%= rs4.getString("nume_dep") %></td>
                                </tr>
                            </table>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th>Venituri</th>
                                    <th>Suma</th>
                                </tr>
                                <tr>
                                    <td>Salariu de baza</td>
                                    <td><%= currencyFormat.format(salariuBaza) %></td>
                                </tr>
                                <% if (spor > 0) { %>
                                <tr>
                                    <td><%= denumireSpor %> (<%= procentSpor %>%)</td>
                                    <td><%= currencyFormat.format(spor) %></td>
                                </tr>
                                <% } %>
                                <% if (penalizare > 0) { %>
                                <tr>
                                    <td><%= denumirePenalizare %> (-<%= procentPenalizare %>%)</td>
                                    <td>-<%= currencyFormat.format(penalizare) %></td>
                                </tr>
                                <% } %>
                                <tr class="total-row">
                                    <td>Total brut</td>
                                    <td><%= currencyFormat.format(salariuBrut) %></td>
                                </tr>
                            </table>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th>Contributii</th>
                                    <th>Suma</th>
                                </tr>
                                <tr>
                                    <td>CAS (25%)</td>
                                    <td><%= currencyFormat.format(cas) %></td>
                                </tr>
                                <tr>
                                    <td>CASS (10%)</td>
                                    <td><%= currencyFormat.format(cass) %></td>
                                </tr>
                                <tr>
                                    <td>Impozit (10%)</td>
                                    <td><%= currencyFormat.format(impozit) %></td>
                                </tr>
                                <tr class="total-row">
                                    <td>Total net de plata</td>
                                    <td><%= currencyFormat.format(salariuNet) %></td>
                                </tr>
                            </table>
                            
                            <div style="text-align: right; margin-top: 20px;">
                                <button onclick="window.print()" class="btn">Descarcare pdf</button>
                            </div>
                        </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs4 != null) try { rs4.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn2 != null) try { conn2.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
            %>
       

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