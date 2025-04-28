<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    // Utilizăm sesiunea existentă
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            
            // Variabile pentru datele utilizatorului
            String numePrenume = "";
            String departament = "";
            int userId = 0;
            int userDep = 0;
            int userTip = -1;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT u.tip, u.id, u.id_dep, u.nume, u.prenume, d.nume_dep FROM useri u JOIN departament d ON u.id_dep = d.id_dep WHERE u.username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (!rs.next()) {
                        out.println("<script type='text/javascript'>");
                        out.println("alert('Date introduse incorect sau nu exista date!');");
                        out.println("</script>");
                    } else {
                        userTip = rs.getInt("tip");
                        userId = rs.getInt("id");
                        userDep = rs.getInt("id_dep");
                        numePrenume = rs.getString("nume") + " " + rs.getString("prenume");
                        departament = rs.getString("nume_dep");
                        
                        // Obținere preferințe de temă
                        String accent = "#4F46E5"; // Culoare implicită
                        String clr = "#f9fafb";
                        String sidebar = "#ffffff";
                        String text = "#1f2937";
                        String card = "#ffffff";
                        String hover = "#f3f4f6";
                        
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
                            out.println("<script>console.error('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cerere Adeverință</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    
    <style>
        :root {
            --accent: <%=accent%>;
            --background: <%=clr%>;
            --card: <%=sidebar%>;
            --text: <%=text%>;
            --border: #e5e7eb;
            --hover: <%=hover%>;
            --danger: #ef4444;
            --success: #10b981;
            --warning: #f59e0b;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--text);
            line-height: 1.5;
        }
        
        .container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }
        
        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text);
        }
        
        .action-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            font-size: 0.875rem;
            font-weight: 500;
            border-radius: 0.5rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            color: white;
        }
        
        .btn-primary {
            background-color: var(--accent);
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-secondary {
            background-color: #6c757d;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .btn-small {
            padding: 0.375rem 0.75rem;
            font-size: 0.75rem;
        }
        
        /* Card pentru tabel */
        .card {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            margin-bottom: 2rem;
        }
        
        .card-header {
            background-color: var(--accent);
            color: white;
            font-weight: bold;
            padding: 1rem;
            border-radius: 0.75rem 0.75rem 0 0;
        }
        
        .card-body {
            padding: 1.5rem;
        }
        
        /* Stiluri pentru tabel */
        .table-container {
            overflow-x: auto;
        }
        
        .table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        .table th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        .table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        .table-striped tbody tr:nth-of-type(odd) {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .text-success {
            color: var(--success) !important;
        }
        
        .text-warning {
            color: var(--warning) !important;
        }
        
        .text-danger {
            color: var(--danger) !important;
        }
        
        .text-center {
            text-align: center;
        }
        
        /* Formular */
        .form-group {
            margin-bottom: 1.25rem;
        }
        
        .form-label {
            display: block;
            margin-bottom: 0.375rem;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text);
        }
        
        .form-control {
            width: 100%;
            padding: 0.625rem 0.75rem;
            font-size: 0.875rem;
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            background-color: white;
            color: var(--text);
            transition: all 0.2s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }
        
        /* Alerte */
        .alert {
            padding: 1rem;
            margin-bottom: 1rem;
            border-radius: 0.5rem;
            font-weight: 500;
        }
        
        .alert-success {
            background-color: rgba(16, 185, 129, 0.1);
            color: var(--success);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        
        .alert-danger {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--danger);
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        
        /* Spațiere */
        .mt-4 {
            margin-top: 1.5rem;
        }
        
        .ml-2 {
            margin-left: 0.5rem;
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .action-row {
                flex-direction: column;
                align-items: stretch;
                gap: 1rem;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Cerere Adeverință</h1>
            
        </div>
        
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success" role="alert">
                Cererea dumneavoastră a fost înregistrată cu succes! Șeful departamentului a fost notificat.
            </div>
        <% } %>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger" role="alert">
                A apărut o eroare la procesarea cererii. Vă rugăm să încercați din nou.
            </div>
        <% } %>
        
        <div class="card">
            <div class="card-header">
                Formular Cerere Adeverință
            </div>
            <div class="card-body">
                <form action="CerereAdeverintaServlet" method="post">
                    <div class="form-group">
                        <label for="nume">Nume și Prenume:</label>
                        <input type="text" class="form-control" id="nume" value="<%= numePrenume %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="departament">Departament:</label>
                        <input type="text" class="form-control" id="departament" value="<%= departament %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="tip">Tip Adeverință:</label>
                        <select class="form-control" id="tip" name="tip" required>
                            <option value="">-- Selectați tipul de adeverință --</option>
                            <%
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                        String sql = "SELECT id, denumire FROM tip_adev ORDER BY denumire";
                                        try (PreparedStatement pstmt = conn.prepareStatement(sql);
                                             ResultSet rs3 = pstmt.executeQuery()) {
                                            while (rs3.next()) {
                                                out.println("<option value=\"" + rs3.getInt("id") + "\">" + rs3.getString("denumire") + "</option>");
                                            }
                                        }
                                    }
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="pentru_servi">Motivul Solicitării:</label>
                        <textarea class="form-control" id="pentru_servi" name="pentru_servi" rows="3" required 
                                  placeholder="Introduceți motivul pentru care solicitați această adeverință..."></textarea>
                    </div>
                    
                    <button type="submit" class="btn btn-primary">Trimite Cererea</button>
                    <a href="actiuni2.jsp" class="btn btn-secondary ml-2">Înapoi la Panou</a>
                </form>
            </div>
        </div>
        
        <div class="card mt-4">
            <div class="card-header">
                Cererile Mele Anterioare
            </div>
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Nr.</th>
                            <th>Tip Adeverință</th>
                            <th>Data Cererii</th>
                            <th>Status</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                    String sql = "SELECT a.id, t.denumire, a.creare, s.nume_status, a.status " +
                                                 "FROM adeverinte a " +
                                                 "JOIN tip_adev t ON a.tip = t.id " +
                                                 "JOIN statusuri s ON a.status = s.status " +
                                                 "WHERE a.id_ang = ? ORDER BY a.creare DESC";
                                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                        pstmt.setInt(1, userId);
                                        try (ResultSet rs4 = pstmt.executeQuery()) {
                                            int count = 1;
                                            boolean hasRecords = false;
                                            
                                            while (rs4.next()) {
                                                hasRecords = true;
                                                out.println("<tr>");
                                                out.println("<td>" + count++ + "</td>");
                                                out.println("<td>" + rs4.getString("denumire") + "</td>");
                                                out.println("<td>" + rs4.getDate("creare") + "</td>");
                                                
                                                String status = rs4.getString("nume_status");
                                                String statusClass = "";
                                                if (status.contains("Aprobat")) {
                                                    statusClass = "text-success";
                                                } else if (status.contains("Dezaprobat")) {
                                                    statusClass = "text-danger";
                                                } else {
                                                    statusClass = "text-warning";
                                                }
                                                
                                                out.println("<td class='" + statusClass + "'>" + status + "</td>");
                                                
                                                // Adăugăm coloana de acțiuni
                                                out.println("<td>");
                                                if (rs4.getInt("status") == 2) { // Status aprobat
                                                    out.println("<a href='DescarcaAdeverintaServlet?id=" + rs4.getInt("id") + "' class='btn btn-sm btn-primary'><i class='fas fa-download'></i> Descarcă</a>");
                                                } else {
                                                    out.println("<span class='text-muted'>Nu este disponibilă</span>");
                                                }
                                                out.println("</td>");
                                                
                                                out.println("</tr>");
                                            }
                                            
                                            if (!hasRecords) {
                                                out.println("<tr><td colspan='5' class='text-center'>Nu aveți cereri anterioare</td></tr>");
                                            }
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<tr><td colspan='5' class='text-center text-danger'>Eroare la încărcarea cererilor</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>
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