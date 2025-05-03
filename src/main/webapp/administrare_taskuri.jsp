<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
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
                    
                    // Verificare acces pentru administrare taskuri
                    // Acces permis: Director, Șef, Manager sau Admin
                    if (isAdmin) {
                        response.sendRedirect("adminok.jsp");
                        return;
                    }

                    String action = request.getParameter("action");
                    if (action == null) {
                        action = "view";  // Default action
                    }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Administrare Taskuri</title>
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">
    <link rel="stylesheet" href="css/core2.css">
    <script src="js/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        .main-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
            background-color: #6c5ce7;
            color: white;
        }
        .action-button:not(.active) {
            background-color: #f0f0f0;
            color: #333;
        }
        .action-button:hover {
            opacity: 0.9;
        }
        .form-container {
            background: #f5f5f5;
            padding: 30px;
            border-radius: 20px;
            margin-top: 20px;
            text-align: center;
        }
        .form-container h2 {
            margin-bottom: 20px;
            color: #333;
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
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        .form-group textarea {
            min-height: 100px;
            resize: vertical;
        }
        .submit-button {
            background-color: #6c5ce7;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 20px;
        }
        .submit-button:hover {
            background-color: #5a4bd1;
        }
        .taskuri-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .taskuri-table th, .taskuri-table td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: center;
        }
        .taskuri-table th {
            background-color: #6c5ce7;
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
            background-color: #666;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        .status-badge {
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.9em;
            color: white;
        }
        .status-0 { background-color: #6c757d; }
        .status-1 { background-color: #17a2b8; }
        .status-2 { background-color: #ffc107; color: black; }
        .status-3 { background-color: #fd7e14; }
        .status-4 { background-color: #28a745; }
    </style>
</head>

<body>
    <div class="main-container">
        <h1>Administrare Taskuri</h1>
        
        <% if ("view".equals(action)) { %>
            <div class="action-buttons">
                <button class="action-button active" onclick="window.location.href='administrare_taskuri.jsp?action=add'">
                    Adaugă task
                </button>
                <button class="action-button active" onclick="window.location.href='administrare_taskuri.jsp?action=list'">
                    Vizualizare și modificare taskuri
                </button>
            </div>
            
        <% } else if ("add".equals(action)) { %>
            <div class="form-container">
                <h2>Adaugă task</h2>
                <form method="POST" action="AdaugaTaskServlet">
                    <div class="form-group">
                        <label for="nume">Nume task:</label>
                        <input type="text" id="nume" name="nume" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">Descriere:</label>
                        <textarea id="descriere" name="descriere"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_prj">Proiect:</label>
                        <select id="id_prj" name="id_prj" required>
                            <option value="">-- Selectați --</option>
                            <%
                            try {
                                String sql = "SELECT id, nume FROM proiecte WHERE end >= CURDATE() ORDER BY nume";
                                Statement stmt = connection.createStatement();
                                ResultSet rsProiecte = stmt.executeQuery(sql);
                                
                                while (rsProiecte.next()) {
                            %>
                                <option value="<%= rsProiecte.getInt("id") %>">
                                    <%= rsProiecte.getString("nume") %>
                                </option>
                            <%
                                }
                                rsProiecte.close();
                                stmt.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_ang">Asignat către:</label>
                        <select id="id_ang" name="id_ang" required>
                            <option value="">-- Selectați --</option>
                            <%
                            try {
                                String sql = "SELECT id, nume, prenume FROM useri WHERE activ = 1 AND id_dep = ? ORDER BY nume, prenume";
                                PreparedStatement pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userDep);
                                ResultSet rsAngajati = pstmt.executeQuery();
                                
                                while (rsAngajati.next()) {
                            %>
                                <option value="<%= rsAngajati.getInt("id") %>">
                                    <%= rsAngajati.getString("nume") %> <%= rsAngajati.getString("prenume") %>
                                </option>
                            <%
                                }
                                rsAngajati.close();
                                pstmt.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="supervizor">Supervizor:</label>
                        <select id="supervizor" name="supervizor" required>
                            <option value="<%= userId %>" selected>Eu</option>
                            <%
                            try {
                                String sql = "SELECT id, nume, prenume FROM useri WHERE activ = 1 AND tip >= 8 AND id != ? ORDER BY nume, prenume";
                                PreparedStatement pstmt = connection.prepareStatement(sql);
                                pstmt.setInt(1, userId);
                                ResultSet rsSurvizori = pstmt.executeQuery();
                                
                                while (rsSurvizori.next()) {
                            %>
                                <option value="<%= rsSurvizori.getInt("id") %>">
                                    <%= rsSurvizori.getString("nume") %> <%= rsSurvizori.getString("prenume") %>
                                </option>
                            <%
                                }
                                rsSurvizori.close();
                                pstmt.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Status inițial:</label>
                        <select id="status" name="status" required>
                            <option value="0" selected>0% - Neînceput</option>
                            <option value="1">25% - În lucru</option>
                            <option value="2">50% - La jumătate</option>
                            <option value="3">75% - Aproape gata</option>
                            <option value="4">100% - Finalizat</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="submit-button">Adaugă Task</button>
                </form>
                <a href="administrare_taskuri.jsp" class="back-button">Înapoi</a>
            </div>
            
        <% } else if ("list".equals(action)) { %>
            <h2>Vizualizare și modificare taskuri</h2>
            <table class="taskuri-table">
                <thead>
                    <tr>
                        <th>Nr. crt</th>
                        <th>Nume task</th>
                        <th>Proiect</th>
                        <th>Asignat</th>
                        <th>Status</th>
                        <th>Modificare</th>
                        <th>Ștergere</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        String sql = "SELECT t.*, p.nume as proiect_nume, u.nume as asignat_nume, u.prenume as asignat_prenume, s.procent " +
                                   "FROM tasks t " +
                                   "LEFT JOIN proiecte p ON t.id_prj = p.id " +
                                   "LEFT JOIN useri u ON t.id_ang = u.id " +
                                   "LEFT JOIN statusuri2 s ON t.status = s.id " +
                                   "WHERE t.supervizor = ? OR t.id_ang = ? " +
                                   "ORDER BY t.start DESC";
                        PreparedStatement pstmt = connection.prepareStatement(sql);
                        pstmt.setInt(1, userId);
                        pstmt.setInt(2, userId);
                        ResultSet rsTasks = pstmt.executeQuery();
                        int counter = 1;
                        
                        while (rsTasks.next()) {
                            int status = rsTasks.getInt("status");
                            int procent = rsTasks.getInt("procent");
                    %>
                        <tr>
                            <td><%= counter++ %></td>
                            <td><%= rsTasks.getString("nume") %></td>
                            <td><%= rsTasks.getString("proiect_nume") %></td>
                            <td><%= rsTasks.getString("asignat_nume") %> <%= rsTasks.getString("asignat_prenume") %></td>
                            <td>
                                <span class="status-badge status-<%= status %>">
                                    <%= procent %>%
                                </span>
                            </td>
                            <td>
                                <button class="table-button modify-button" 
                                        onclick="window.location.href='administrare_taskuri.jsp?action=edit&id=<%= rsTasks.getInt("id") %>'">
                                    ✏
                                </button>
                            </td>
                            <td>
                                <button class="table-button delete-button" 
                                        onclick="deleteTask(<%= rsTasks.getInt("id") %>)">
                                    X
                                </button>
                            </td>
                        </tr>
                    <%
                        }
                        rsTasks.close();
                        pstmt.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </tbody>
            </table>
            <a href="administrare_taskuri.jsp" class="back-button">Înapoi</a>
            
        <% } else if ("edit".equals(action)) { 
            int idTask = Integer.parseInt(request.getParameter("id"));
            try {
                String sql = "SELECT * FROM tasks WHERE id = ?";
                PreparedStatement pstmt = connection.prepareStatement(sql);
                pstmt.setInt(1, idTask);
                ResultSet rsTask = pstmt.executeQuery();
                
                if (rsTask.next()) {
        %>
            <div class="form-container">
                <h2>Modificare task</h2>
                <form method="POST" action="EditTaskServlet">
                    <input type="hidden" name="id" value="<%= idTask %>">
                    
                    <div class="form-group">
                        <label for="nume">Nume task:</label>
                        <input type="text" id="nume" name="nume" value="<%= rsTask.getString("nume") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="descriere">Descriere:</label>
                        <textarea id="descriere" name="descriere"><%= rsTask.getString("descriere") %></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_prj">Proiect:</label>
                        <select id="id_prj" name="id_prj" required>
                            <%
                            String sql2 = "SELECT id, nume FROM proiecte ORDER BY nume";
                            Statement stmt2 = connection.createStatement();
                            ResultSet rs2 = stmt2.executeQuery(sql2);
                            
                            while (rs2.next()) {
                                boolean selected = rsTask.getInt("id_prj") == rs2.getInt("id");
                            %>
                                <option value="<%= rs2.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs2.getString("nume") %>
                                </option>
                            <%
                            }
                            rs2.close();
                            stmt2.close();
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="id_ang">Asignat către:</label>
                        <select id="id_ang" name="id_ang" required>
                            <%
                            String sql3 = "SELECT id, nume, prenume FROM useri WHERE activ = 1 ORDER BY nume, prenume";
                            Statement stmt3 = connection.createStatement();
                            ResultSet rs3 = stmt3.executeQuery(sql3);
                            
                            while (rs3.next()) {
                                boolean selected = rsTask.getInt("id_ang") == rs3.getInt("id");
                            %>
                                <option value="<%= rs3.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs3.getString("nume") %> <%= rs3.getString("prenume") %>
                                </option>
                            <%
                            }
                            rs3.close();
                            stmt3.close();
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="supervizor">Supervizor:</label>
                        <select id="supervizor" name="supervizor" required>
                            <%
                            String sql4 = "SELECT id, nume, prenume FROM useri WHERE activ = 1 AND tip >= 8 ORDER BY nume, prenume";
                            Statement stmt4 = connection.createStatement();
                            ResultSet rs4 = stmt4.executeQuery(sql4);
                            
                            while (rs4.next()) {
                                boolean selected = rsTask.getInt("supervizor") == rs4.getInt("id");
                            %>
                                <option value="<%= rs4.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs4.getString("nume") %> <%= rs4.getString("prenume") %>
                                </option>
                            <%
                            }
                            rs4.close();
                            stmt4.close();
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="start">Data început:</label>
                        <input type="date" id="start" name="start" value="<%= rsTask.getDate("start") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="end">Data sfârșit:</label>
                        <input type="date" id="end" name="end" value="<%= rsTask.getDate("end") %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="status">Status:</label>
                        <select id="status" name="status" required>
                            <%
                            String sql5 = "SELECT id, procent FROM statusuri2 ORDER BY id";
                            Statement stmt5 = connection.createStatement();
                            ResultSet rs5 = stmt5.executeQuery(sql5);
                            
                            while (rs5.next()) {
                                boolean selected = rsTask.getInt("status") == rs5.getInt("id");
                            %>
                                <option value="<%= rs5.getInt("id") %>" <%= selected ? "selected" : "" %>>
                                    <%= rs5.getInt("procent") %>% - <%= getStatusText(rs5.getInt("id")) %>
                                </option>
                            <%
                            }
                            rs5.close();
                            stmt5.close();
                            %>
                        </select>
                    </div>
                    
                    <button type="submit" class="submit-button">Salvează Modificările</button>
                </form>
                <a href="administrare_taskuri.jsp?action=list" class="back-button">Înapoi</a>
            </div>
        <%
                }
                rsTask.close();
                pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        %>
    </div>

    <%!
    private String getStatusText(int status) {
        switch (status) {
            case 0: return "Neînceput";
            case 1: return "În lucru";
            case 2: return "La jumătate";
            case 3: return "Aproape gata";
            case 4: return "Finalizat";
            default: return "Necunoscut";
        }
    }
    %>

    <script>
        function deleteTask(idTask) {
            if (confirm('Sigur doriți să ștergeți acest task?')) {
                $.ajax({
                    url: 'DeleteTaskServlet',
                    type: 'POST',
                    data: { id: idTask },
                    success: function(response) {
                        if (response.success) {
                            location.reload();
                        } else {
                            alert(response.message || 'Eroare la ștergerea taskului!');
                        }
                    },
                    error: function() {
                        alert('Eroare la conectarea cu serverul!');
                    }
                });
            }
        }
    </script>
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