<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<%
    // Obținem sesiunea curentă
    HttpSession sesi = request.getSession(false);
    if (sesi == null) {
        out.println("<script>alert('Nu există sesiune activă!');</script>");
        response.sendRedirect("logout");
        return;
    }

    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser == null) {
        out.println("<script>alert('Utilizator neconectat!');</script>");
        response.sendRedirect("logout");
        return;
    }

    String username = currentUser.getUsername();
    int userdep = 0, id = 0, userType = 0, ierarhie = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";
    String functie = "";

    // Obținem acțiunea din URL (parametrul "action")
    String action = request.getParameter("action");
    if (action == null) {
        action = "view"; // Acțiunea implicită
    }

    // Stocăm tipul utilizatorului în sesiune pentru servleturi
    Class.forName("com.mysql.cj.jdbc.Driver");


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
                id = rs.getInt("id");
                userType = rs.getInt("tip");
                userdep = rs.getInt("id_dep");
                functie = rs.getString("functie");
                ierarhie = rs.getInt("ierarhie");
                if (functie.compareTo("Administrator") == 0) {  
                  
                      
                String query = "SELECT * FROM teme WHERE id_usr = ?";
                try (PreparedStatement stmt = connection.prepareStatement(query)) {
                    stmt.setInt(1, id);
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
            }
        }
    }

    // Funcție helper pentru a determina rolul utilizatorului
    boolean isDirector = (ierarhie < 3) ;
    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
    boolean isUtilizatorNormal = !isDirector && !isSef; // tipuri 1, 2, 5-9
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <title>Administrare Posturi</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
    <!--=============== jQuery ===============-->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <style>
        body {
            
            background-color: <%= clr %>;
            color: <%= text %>;
            margin: 0;
            padding: 0;
        }
        
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: <%=clr%>;
            border-radius: 2rem;
        }
        
        .modal-content {
            background-color: <%=sidebar%>;
            border-radius: 2rem;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid <%=sidebar%>;
            width: 80%;
        }
        
        .close {
            background-color: <%=sidebar%>;
            color: <%=accent%>;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
        
        a, a:visited, a:hover, a:active {
            color: <%=text%> !important;
            text-decoration: none;
        }
        
        .main-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 20px;
            background: <%=sidebar%>;
            border-radius: 8px;
            
        }
        
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .action-button {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
            background-color: <%=accent%>;
            color: white;
        }
        
        .action-button:hover {
            color: white;
            background-color: black;
        }
        
        .form-container {
            background: <%=clr%>;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
        }
        
        .form-container h2 {
            margin-bottom: 20px;
            color: <%=accent%>;
            text-align: center;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid <%=sidebar%>;
            border-radius: 5px;
            font-size: 16px;
        }
        
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        
        .submit-button {
            background-color: <%=accent%>;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        
        .submit-button:hover {
            background-color: black;
        }
        
        .proiecte-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        
        .proiecte-table th, .proiecte-table td {
            padding: 10px;
            border: 1px solid <%=text%>;
            text-align: center;
        }
        
        .proiecte-table th {
            background-color: <%=accent%>;
            color: white;
        }
        
        .proiecte-table tr:nth-child(even) {
            background-color: <%=sidebar%>;
        }
        
        .table-button {
            padding: 5px 10px;
            margin: 0 5px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .modify-button {
            background-color: #4CAF50;
            color: white;
        }
        
        .team-button {
            background-color: #2196F3;
            color: white;
        }
        
        .delete-button {
            background-color: #f44336;
            color: white;
        }
        
        .back-button {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: <%=accent%>;
            color: white !important;
            text-decoration: none;
            border-radius: 5px;
        }
        
        .member-checkbox {
            margin-right: 10px;
        }
        
        .members-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 10px;
            text-align: left;
            margin-top: 15px;
        }
        
        h1, h2, h3 {
            color: <%=accent%>;
        }
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        
        .alert-success {
            color: #3c763d;
            background-color: #dff0d8;
            border-color: #d6e9c6;
        }
        
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
        .main-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: <%=sidebar%>;
            border-radius: 8px;
        }
        .action-buttons {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 30px;
        }
        .action-button {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .action-button.active {
            background-color: <%=accent%>;
            color: white;
        }
        .action-button:not(.active) {
            background-color: black;
            color: white;
        }
        .action-button:hover {
            opacity: 0.9;
        }
        .form-container {
            background: <%=clr%>;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
            text-align: center;
        }
        .form-container h2 {
            margin-bottom: 20px;
            color: <%=text%>;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid <%=text%>;
            border-radius: 5px;
            font-size: 16px;
        }
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        .submit-button {
            background-color: <%=accent%>;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .submit-button:hover {
            background-color: black;
        }
        .posturi-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .posturi-table th, .posturi-table td {
            padding: 10px;
            border: 1px solid <%=clr%>;
            text-align: center;
        }
        .posturi-table th {
            background-color: <%=accent%>;
            color: white;
        }
        
        .posturi-table tr:nth-child(even) {
            background-color: <%=clr%>;
        }
        
        .posturi-table tr:hover {
            background-color: <%=accent%>;
            color: white;
        }
        
        .table-button {
            padding: 5px 10px;
            margin: 0 5px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 14px;
        }
        .modify-button {
            background-color: #4CAF50;
            color: white;
        }
        .delete-button {
            background-color: #f44336;
            color: white;
        }
        .back-button {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: <%=accent%>;
            color: white !important;
            text-decoration: none;
            border-radius: 5px;
        }
        .table-button:hover, .modify-button:hover, .delete-button:hover, .back-button:hover {
        	background-color: black;
        	color: white;
        }
        .status-activ {
            color: green;
            font-weight: bold;
        }
        .status-inactiv {
            color: red;
            font-weight: bold;
        }
   </style>
</head>
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>;">
        <div class="main-container">
            <h1>Administrare Posturi de Angajare</h1>
            
            <% if ("view".equals(action)) { %>
                <div class="action-buttons">
                    <button class="action-button active" onclick="window.location.href='administrare_posturi.jsp?action=add'">
                        Adaugă post de angajare
                    </button>
                    <button class="action-button active" onclick="window.location.href='administrare_posturi.jsp?action=list'">
                        Vizualizare și modificare posturi
                    </button>
                </div>
                
            <% } else if ("add".equals(action)) { %>
                <div class="form-container">
                    <h2 style="color:<%=accent%>">Adaugă post de angajare</h2>
                    <form method="POST" action="AdaugaPostServlet">
                        <div class="form-group">
                            <label for="titlu">Titlu post:</label>
                            <input style="border-color:<%=accent%>;" type="text" id="titlu" name="titlu" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="departament">Departament:</label>
                            <select style="border-color:<%=accent%>;" id="departament" name="departament" required>
                                <option value="">-- Selectați --</option>
                                <%
                                Connection conn = null;
                                try {
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                    String sql = "SELECT id_dep, nume_dep FROM departament ORDER BY nume_dep";
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("id_dep") %>">
                                        <%= rs.getString("nume_dep") %>
                                    </option>
                                <%
                                    }
                                    rs.close();
                                    stmt.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (conn != null) {
                                        try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="pozitie">Poziție:</label>
                            <select style="border-color:<%=accent%>;" id="pozitie" name="pozitie" required>
                                <option value="">-- Selectați --</option>
                                <%
                                try {
                                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                    String sql = "SELECT tip, denumire FROM tipuri ORDER BY denumire";
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery(sql);
                                    
                                    while (rs.next()) {
                                %>
                                    <option value="<%= rs.getInt("tip") %>">
                                        <%= rs.getString("denumire") %>
                                    </option>
                                <%
                                    }
                                    rs.close();
                                    stmt.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (conn != null) {
                                        try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                                    }
                                }
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="req">Cerințe:</label>
                            <textarea style="border-color:<%=accent%>;" id="req" name="req" required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="resp">Responsabilități:</label>
                            <textarea style="border-color:<%=accent%>;" id="resp" name="resp" required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="dom">Domeniu:</label>
                            <input style="border-color:<%=accent%>;" type="text" id="dom" name="dom" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="subdom">Subdomeniu:</label>
                            <input style="border-color:<%=accent%>;" type="text" id="subdom" name="subdom">
                        </div>
                        
                        <div class="form-group">
                            <label for="start">Data început:</label>
                            <input style="border-color:<%=accent%>;" type="date" id="start" name="start" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="end">Data sfârșit:</label>
                            <input style="border-color:<%=accent%>;" type="date" id="end" name="end" required>
                        </div>
                        
                        <!-- Județe și Localități din Roloca API -->
                        <div class="form-group">
                            <label for="judet">Județ:</label>
                            <select style="border-color:<%=accent%>;" id="judet" name="judet" required onchange="loadLocalitati()">
                                <option value="">-- Selectați județul --</option>
                                <!-- Județele vor fi încărcate prin JavaScript -->
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="localitate">Localitate:</label>
                            <select style="border-color:<%=accent%>;" id="localitate" name="localitate" required disabled>
                                <option value="">-- Selectați mai întâi județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="strada">Adresa (strada, număr, etc.):</label>
                            <input style="border-color:<%=accent%>;" type="text" id="strada" name="strada" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="ore">Ore pe săptămână:</label>
                            <input style="border-color:<%=accent%>;" type="number" id="ore" name="ore" min="1" max="40" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tip">Tip:</label>
                            <select style="border-color:<%=accent%>;" id="tip" name="tip" required>
                                <option value="1">Full-time</option>
                                <option value="0">Part-time</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="keywords">Cuvinte cheie:</label>
                            <input style="border-color:<%=accent%>;" type="text" id="keywords" name="keywords" placeholder="Separate prin virgulă">
                        </div>
                        
                        <button type="submit" class="submit-button">Adaugă Post</button>
                    </form>
                    <a style="color:white;" href="administrare_posturi.jsp" class="back-button">Înapoi</a>
                </div>
                
            <% } else if ("list".equals(action)) { %>
                <h2>Vizualizare și modificare posturi</h2>
                <table class="posturi-table">
                    <thead>
                        <tr>
                            <th>Nr. crt</th>
                            <th>Titlu post</th>
                            <th>Departament</th>
                            <th>Status</th>
                            <th>Modificare</th>
                            <th>Ștergere</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Connection conn = null;
                        try {
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            String sql = "SELECT j.*, d.nume_dep, t.denumire as pozitie_nume " +
                                       "FROM joburi j " +
                                       "JOIN departament d ON j.departament = d.id_dep " +
                                       "JOIN tipuri t ON j.pozitie = t.tip " +
                                       "ORDER BY j.titlu";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            int counter = 1;
                            
                            while (rs.next()) {
                                boolean isActiv = rs.getBoolean("activ");
                        %>
                            <tr>
                                <td><%= counter++ %></td>
                                <td><%= rs.getString("titlu") %></td>
                                <td><%= rs.getString("nume_dep") %></td>
                                <td>
                                    <span class="<%= isActiv ? "status-activ" : "status-inactiv" %>">
                                        <%= isActiv ? "Activ" : "Inactiv" %>
                                    </span>
                                </td>
                                <td>
                                    <button class="table-button modify-button" 
                                            onclick="window.location.href='administrare_posturi.jsp?action=edit&id=<%= rs.getInt("id") %>'">
                                        ✏
                                    </button>
                                </td>
                                <td>
                                    <button class="table-button delete-button" 
                                            onclick="deletePost(<%= rs.getInt("id") %>)">
                                        X
                                    </button>
                                </td>
                            </tr>
                        <%
                            }
                            rs.close();
                            stmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        } finally {
                            if (conn != null) {
                                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                        }
                        %>
                    </tbody>
                </table>
                <a href="administrare_posturi.jsp" class="back-button">Înapoi</a>
                
            <% } else if ("edit".equals(action)) { 
                int idPost = Integer.parseInt(request.getParameter("id"));
                Connection conn = null;
                try {
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    String sql = "SELECT j.*, l.strada, l.oras as localitate, l.judet " +
                                 "FROM joburi j " +
                                 "LEFT JOIN locatii_joburi l ON j.id_locatie = l.id_locatie " +
                                 "WHERE j.id = ?";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, idPost);
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        String judet = rs.getString("judet");
                        String localitate = rs.getString("localitate");
                        String strada = rs.getString("strada");
            %>
                <div class="form-container">
                    <h2>Modificare post de angajare</h2>
                    <form method="POST" action="EditPostServlet">
                        <input type="hidden" name="id" value="<%= idPost %>">
                        
                        <div class="form-group">
                            <label for="titlu">Titlu post:</label>
                            <input type="text" id="titlu" name="titlu" value="<%= rs.getString("titlu") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="departament">Departament:</label>
                            <select id="departament" name="departament" required>
                                <%
                                String sql2 = "SELECT id_dep, nume_dep FROM departament ORDER BY nume_dep";
                                Statement stmt2 = conn.createStatement();
                                ResultSet rs2 = stmt2.executeQuery(sql2);
                                
                                while (rs2.next()) {
                                    boolean selected = rs.getInt("departament") == rs2.getInt("id_dep");
                                %>
                                    <option value="<%= rs2.getInt("id_dep") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs2.getString("nume_dep") %>
                                    </option>
                                <%
                                }
                                rs2.close();
                                stmt2.close();
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="pozitie">Poziție:</label>
                            <select id="pozitie" name="pozitie" required>
                                <%
                                String sql3 = "SELECT tip, denumire FROM tipuri ORDER BY denumire";
                                Statement stmt3 = conn.createStatement();
                                ResultSet rs3 = stmt3.executeQuery(sql3);
                                
                                while (rs3.next()) {
                                    boolean selected = rs.getInt("pozitie") == rs3.getInt("tip");
                                %>
                                    <option value="<%= rs3.getInt("tip") %>" <%= selected ? "selected" : "" %>>
                                        <%= rs3.getString("denumire") %>
                                    </option>
                                <%
                                }
                                rs3.close();
                                stmt3.close();
                                %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="req">Cerințe:</label>
                            <textarea id="req" name="req" required><%= rs.getString("req") %></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="resp">Responsabilități:</label>
                            <textarea id="resp" name="resp" required><%= rs.getString("resp") %></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="dom">Domeniu:</label>
                            <input type="text" id="dom" name="dom" value="<%= rs.getString("dom") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="subdom">Subdomeniu:</label>
                            <input type="text" id="subdom" name="subdom" value="<%= rs.getString("subdom") %>">
                        </div>
                        
                        <div class="form-group">
                            <label for="start">Data început:</label>
                            <input type="date" id="start" name="start" value="<%= rs.getDate("start") %>" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="end">Data sfârșit:</label>
                            <input type="date" id="end" name="end" value="<%= rs.getDate("end") %>" required>
                        </div>
                        
                        <!-- Județe și Localități din Roloca API pentru modificare -->
                        <div class="form-group">
                            <label for="judet">Județ:</label>
                            <select id="judet" name="judet" required onchange="loadLocalitati()">
                                <option value="">-- Selectați județul --</option>
                                <!-- Județele vor fi încărcate prin JavaScript -->
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="localitate">Localitate:</label>
                            <select id="localitate" name="localitate" required>
                                <option value="">-- Selectați mai întâi județul --</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="strada">Adresa (strada, număr, etc.):</label>
                            <input type="text" id="strada" name="strada" value="<%= strada != null ? strada : "" %>" required>
                        </div>
                        
                        <input type="hidden" id="currentJudet" value="<%= judet != null ? judet : "" %>">
                        <input type="hidden" id="currentLocalitate" value="<%= localitate != null ? localitate : "" %>">
                        
                        <div class="form-group">
                            <label for="ore">Ore pe săptămână:</label>
                            <input type="number" id="ore" name="ore" value="<%= rs.getInt("ore") %>" min="1" max="40" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tip">Tip:</label>
                            <select id="tip" name="tip" required>
                                <option value="1" <%= rs.getBoolean("tip") ? "selected" : "" %>>Full-time</option>
                                <option value="0" <%= !rs.getBoolean("tip") ? "selected" : "" %>>Part-time</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="keywords">Cuvinte cheie:</label>
                            <input type="text" id="keywords" name="keywords" value="<%= rs.getString("keywords") %>" placeholder="Separate prin virgulă">
                        </div>
                        
                        <div class="form-group">
                            <label for="activ">Status:</label>
                            <select id="activ" name="activ" required>
                                <option value="1" <%= rs.getBoolean("activ") ? "selected" : "" %>>Activ</option>
                                <option value="0" <%= !rs.getBoolean("activ") ? "selected" : "" %>>Inactiv</option>
                            </select>
                        </div>
                        
                        <button type="submit" class="submit-button">Salvează Modificările</button>
                    </form>
                    <a href="administrare_posturi.jsp?action=list" class="back-button">Înapoi</a>
                </div>
            <%
                    
                
            }
                    rs.close();
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (conn != null) {
                        try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                    }
                }
            }
            %>
        </div>

    <script>
 // Încărcare județe și localități folosind servleturile locale cu date hardcodate
    $(document).ready(function() {
        loadJudete();
    });

    function loadJudete() {
        $.ajax({
            url: 'JudeteProxyServlet',
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                const judetSelect = document.getElementById('judet');
                
                // Sortare județe alfabetic
                data.sort(function(a, b) {
                    return a.nume.localeCompare(b.nume);
                });
                
                // Adăugare opțiuni județe
                $.each(data, function(index, judet) {
                    const option = document.createElement('option');
                    option.value = judet.auto; // Auto code as value
                    option.textContent = judet.nume; // County name as text
                    judetSelect.appendChild(option);
                });
                
                // Dacă suntem în modul de editare, selectăm județul curent
                const currentJudet = document.getElementById('currentJudet');
                if (currentJudet && currentJudet.value) {
                    // Găsim județul după nume
                    const judetOptions = Array.from(judetSelect.options);
                    for (let i = 0; i < judetOptions.length; i++) {
                        const opt = judetOptions[i];
                        if (opt.textContent.toLowerCase() === currentJudet.value.toLowerCase()) {
                            opt.selected = true;
                            loadLocalitati(true);
                            break;
                        }
                    }
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.error('Error loading counties:', textStatus, errorThrown);
                alert('Eroare la încărcarea județelor! ' + errorThrown);
            }
        });
    }

    function loadLocalitati(isEdit) {
        const judetSelect = document.getElementById('judet');
        const localitateSelect = document.getElementById('localitate');
        
        // Reset the localities dropdown
        localitateSelect.innerHTML = '<option value="">-- Selectați localitatea --</option>';
        
        if (judetSelect.value === '') {
            localitateSelect.disabled = true;
            return;
        }
        
        // Enable the localities dropdown
        localitateSelect.disabled = false;
        
        // Get localities for the selected county via our servlet with hardcoded data
        $.ajax({
            url: 'LocalitatiProxyServlet',
            type: 'GET',
            data: { judet: judetSelect.value },
            dataType: 'json',
            success: function(data) {
                // Sort localities alphabetically
                data.sort(function(a, b) {
                    return a.nume.localeCompare(b.nume);
                });
                
                // Add options to the localities dropdown
                $.each(data, function(index, localitate) {
                    const option = document.createElement('option');
                    option.value = localitate.nume;
                    option.textContent = localitate.nume;
                    localitateSelect.appendChild(option);
                });
                
                // If editing, set the current locality
                if (isEdit) {
                    const currentLocalitate = document.getElementById('currentLocalitate');
                    if (currentLocalitate && currentLocalitate.value) {
                        // Find the locality by name
                        const localitateOptions = Array.from(localitateSelect.options);
                        for (let i = 0; i < localitateOptions.length; i++) {
                            const opt = localitateOptions[i];
                            if (opt.textContent.toLowerCase() === currentLocalitate.value.toLowerCase()) {
                                opt.selected = true;
                                break;
                            }
                        }
                    }
                }
            },
            error: function(jqXHR, textStatus, errorThrown) {
                console.error('Error loading localities:', textStatus, errorThrown);
                localitateSelect.disabled = true;
                alert('Eroare la încărcarea localităților! ' + errorThrown);
            }
        });
    }
    function deletePost(id) {
        if (confirm('Sunteți sigur că doriți să ștergeți acest post?')) {
            $.ajax({
                url: 'DeletePostServlet',
                type: 'POST',
                data: { id: id },
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        // Refresh the page to show updated list
                        window.location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    alert('Eroare la ștergerea postului: ' + textStatus);
                }
            });
        }
    }
    </script>
    <script src="js/core2.js"></script>

</body>
</html>