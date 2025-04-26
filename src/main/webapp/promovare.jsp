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
                    // Doar Director poate accesa
                    if (userType != 0) {
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
    <title>Promovare Angajati</title>
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
        .promotion-criteria {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
        }
        .criteria-met {
            color: green;
            font-weight: bold;
        }
        .criteria-not-met {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
            <h2>Promovare Angajati</h2>
            
            <form id="promovareForm" method="GET">
                <label for="tipPromovare">Tip Promovare:</label>
                <select id="tipPromovare" name="tip_promovare" required onchange="this.form.submit()">
                    <option value="">-- Selectati --</option>
                    <option value="rang" <%= "rang".equals(request.getParameter("tip_promovare")) ? "selected" : "" %>>Promovare in Rang</option>
                    <option value="grad" <%= "grad".equals(request.getParameter("tip_promovare")) ? "selected" : "" %>>Promovare in Grad</option>
                </select>
            </form>
            
            <%
            String tipPromovare = request.getParameter("tip_promovare");
            if (tipPromovare != null && !tipPromovare.isEmpty()) {
                
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs3 = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    String sql = "";
                    
                    if ("rang".equals(tipPromovare)) {
                        // Promovare in rang - angajatii cu vechime >2 ani
                        sql = "SELECT u.id, u.nume, u.prenume, t.denumire as functie_curenta, t.tip as tip_curent, " +
                              "DATEDIFF(CURDATE(), u.data_ang) / 365 as vechime_ani " +
                              "FROM useri u " +
                              "JOIN tipuri t ON u.tip = t.tip " +
                              "WHERE u.id_dep = ? " +
                              "HAVING vechime_ani >= 2 ";
                    } else if ("grad".equals(tipPromovare)) {
                        // Promovare in grad - angajații peste 50% in ultimul an 
                        sql = "SELECT u.id, u.nume, u.prenume, t.denumire as functie_curenta, t.tip as tip_curent, " +
                              "(SELECT COUNT(*) FROM concedii c " +
                              "WHERE c.id_ang = u.id AND c.start_c >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) " +
                              "AND c.status = 2) as zile_concediu " +
                              "FROM useri u " +
                              "JOIN tipuri t ON u.tip = t.tip " +
                              "WHERE u.activ = 1 AND u.id_dep = ? " +
                              "HAVING zile_concediu = 0";
                    }
                    
                    pstmt2 = conn2.prepareStatement(sql);
                    pstmt2.setInt(1, userDep);
                    rs3 = pstmt2.executeQuery();
            %>
                    <h3>Angajati eligibili pentru <%= tipPromovare.equals("rang") ? "promovare in rang" : "promovare in grad" %></h3>
                    
                    <form id="selectPromovare" method="POST" action="PromovareServlet">
                        <input type="hidden" name="tip_promovare" value="<%= tipPromovare %>">
                        
                        <table class="full-width">
                            <thead>
                                <tr>
                                    <th>Select</th>
                                    <th>Nume</th>
                                    <th>Prenume</th>
                                    <th>Functie Curenta</th>
                                    <th>Criterii Indeplinite</th>
                                    <th>Functie Noua</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                            while (rs3.next()) {
                                String criterii = "";
                                if ("rang".equals(tipPromovare)) {
                                    double vechime = rs3.getDouble("vechime_ani");
                                    double productivitate = rs3.getDouble("productivitate");
                                    criterii = String.format("Vechime: %.1f ani, Productivitate: %.0f%%", vechime, productivitate != 0 ? productivitate : 0);
                                } else {
                                    double productivitate = rs3.getDouble("productivitate_an");
                                    int zileConcediu = rs3.getInt("zile_concediu");
                                    criterii = String.format("Productivitate an: %.0f%%, Concedii: %d zile", productivitate != 0 ? productivitate : 0, zileConcediu);
                                }
                            %>
                                <tr>
                                    <td><input type="checkbox" name="angajat_id" value="<%= rs3.getInt("id") %>"></td>
                                    <td><%= rs3.getString("nume") %></td>
                                    <td><%= rs3.getString("prenume") %></td>
                                    <td><%= rs3.getString("functie_curenta") %></td>
                                    <td><%= criterii %></td>
                                    <td>
                                        <select name="functie_noua_<%= rs3.getInt("id") %>">
                                            <%
                                            // Lista funcțiilor disponibile pentru promovare
                                            Connection conn3 = null;
                                            PreparedStatement pstmtFunctii = null;
                                            ResultSet rsFunctii = null;
                                            try {
                                                Class.forName("com.mysql.cj.jdbc.Driver");
                                                conn3 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                                String sqlFunctii = "SELECT tip, denumire FROM tipuri WHERE tip > ? ORDER BY tip";
                                                pstmtFunctii = conn3.prepareStatement(sqlFunctii);
                                                pstmtFunctii.setInt(1, rs3.getInt("tip_curent"));
                                                rsFunctii = pstmtFunctii.executeQuery();
                                                
                                                while (rsFunctii.next()) {
                                            %>
                                                <option value="<%= rsFunctii.getInt("tip") %>">
                                                    <%= rsFunctii.getString("denumire") %>
                                                </option>
                                            <%
                                                }
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            } finally {
                                                if (rsFunctii != null) try { rsFunctii.close(); } catch (SQLException e) { e.printStackTrace(); }
                                                if (pstmtFunctii != null) try { pstmtFunctii.close(); } catch (SQLException e) { e.printStackTrace(); }
                                                if (conn3 != null) try { conn3.close(); } catch (SQLException e) { e.printStackTrace(); }
                                            }
                                            %>
                                        </select>
                                    </td>
                                </tr>
                            <%
                            }
                            %>
                            </tbody>
                        </table>
                        
                        <div style="margin-top: 20px;">
                            <button type="submit" class="btn">Promovează Selectați</button>
                        </div>
                    </form>
            <%
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
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