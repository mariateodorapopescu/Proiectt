<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            try {
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
    <title>Adeverințele Mele</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
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
        
        .btn-success {
            background-color: var(--success);
        }
        
        .btn-success:hover {
            opacity: 0.9;
        }
        
        .btn-download {
            background-color: #3b82f6;
        }
        
        .btn-download:hover {
            opacity: 0.9;
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
        
        /* Stiluri pentru tabel */
        .table-container {
            overflow-x: auto;
        }
        
        .adeverinte-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        .adeverinte-table th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        .adeverinte-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        .adeverinte-table tr:last-child td {
            border-bottom: none;
        }
        
        .adeverinte-table tr:hover td {
            background-color: var(--hover);
        }
        
        .status-aprobat {
            color: var(--success);
            font-weight: 600;
        }
        
        .status-asteptare {
            color: var(--warning);
            font-weight: 600;
        }
        
        .status-respins {
            color: var(--danger);
            font-weight: 600;
        }
        
        /* Modal pentru cerere adeverință */
        .modal-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 50;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s;
        }
        
        .modal-backdrop.active {
            opacity: 1;
            visibility: visible;
        }
        
        .modal {
            background-color: var(--card);
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            width: 100%;
            max-width: 500px;
            max-height: 90vh;
            overflow-y: auto;
            transition: all 0.3s;
            transform: scale(0.95);
        }
        
        .modal-backdrop.active .modal {
            transform: scale(1);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid var(--border);
        }
        
        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text);
        }
        
        .modal-close {
            background: transparent;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            font-size: 1.25rem;
            transition: color 0.2s;
        }
        
        .modal-close:hover {
            color: var(--text);
        }
        
        .modal-body {
            padding: 1.5rem;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
            padding: 1.25rem 1.5rem;
            border-top: 1px solid var(--border);
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
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 16px;
            padding-right: 2.5rem;
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
        
        /* Stiluri pentru nicio adeverință */
        .empty-state {
            padding: 2rem;
            text-align: center;
            color: #6b7280;
        }
        
        .empty-state-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: #d1d5db;
        }
        
        .empty-state-title {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--text);
        }
        
        .empty-state-description {
            margin-bottom: 1.5rem;
        }
        
        /* Alerte */
        .alert {
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
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
        
        .alert-icon {
            font-size: 1.25rem;
        }
        
        .text-muted {
            color: #6b7280;
            font-style: italic;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Adeverințele Mele</h1>
            <a href="dashboard.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Înapoi la Panou
            </a>
        </div>
        
        <div id="alert-container"></div>
        
        <div class="action-row">
            <a href="cerere_adeverinta.jsp" class="btn btn-primary">
                <i class="fas fa-plus"></i>
                Solicită Adeverință Nouă
            </a>
        </div>
        
        <div class="card">
            <div class="table-container">
                <table class="adeverinte-table">
                    <thead>
                        <tr>
                            <th>Tip Adeverință</th>
                            <th>Pentru</th>
                            <th>Status</th>
                            <th>Data Cererii</th>
                            <th>Data Modificării</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            
                            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                                String sql = "SELECT a.*, ta.denumire as tip_adeverinta, s.nume_status " +
                                            "FROM adeverinte a " +
                                            "JOIN tip_adev ta ON a.tip = ta.id " +
                                            "JOIN statusuri s ON a.status = s.status " +
                                            "WHERE a.id_ang = ? " +
                                            "ORDER BY a.creare DESC";
                                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                    pstmt.setInt(1, userId);
                                    try (ResultSet rs2 = pstmt.executeQuery()) {
                                        boolean hasAdeverinte = false;
                                        
                                        while (rs2.next()) {
                                            hasAdeverinte = true;
                                            String statusClass = "";
                                            switch (rs2.getInt("status")) {
                                                case 2: statusClass = "status-aprobat"; break;
                                                case 0: case 1: statusClass = "status-asteptare"; break;
                                                case -1: case -2: statusClass = "status-respins"; break;
                                            }
                        %>
                        <tr>
                            <td><%= rs2.getString("tip_adeverinta") %></td>
                            <td><%= rs2.getString("pentru_servi") %></td>
                            <td class="<%= statusClass %>"><%= rs2.getString("nume_status") %></td>
                            <td><%= rs2.getDate("creare") %></td>
                            <td><%= rs2.getDate("modif") != null ? rs2.getDate("modif") : "-" %></td>
                            <td>
                                <% if (rs2.getInt("status") == 2) { %>
                                <a href="DescarcaAdeverintaServlet?id=<%= rs2.getInt("id") %>"
                                   class="btn btn-small btn-download">
                                   <i class="fas fa-download"></i> Descarcă
                                </a>
                                <% } else { %>
                                <span class="text-muted">Nu este disponibilă</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                        }
                                        
                                        if (!hasAdeverinte) {
                        %>
                        <tr>
                            <td colspan="6">
                                <div class="empty-state">
                                    <div class="empty-state-icon">
                                        <i class="fas fa-file-alt"></i>
                                    </div>
                                    <h3 class="empty-state-title">Nicio adeverință solicitată</h3>
                                    <p class="empty-state-description">Nu ați solicitat încă nicio adeverință. Apăsați butonul "Solicită Adeverință Nouă" pentru a crea o cerere.</p>
                                    <a href="cerere_adeverinta.jsp" class="btn btn-primary">
                                        <i class="fas fa-plus"></i>
                                        Solicită Adeverință
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                                        }
                                    }
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            out.println("<tr><td colspan='6'>Eroare la interogarea bazei de date: " + e.getMessage() + "</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>
        // Verificare parametri URL pentru afișare mesaje
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            
            if (urlParams.get('success') === 'true') {
                showAlert('success', 'Cererea a fost trimisă cu succes!');
            }
            
            if (urlParams.get('error') === 'true') {
                showAlert('danger', 'A apărut o eroare în timpul procesării cererii.');
            }
            
            if (urlParams.get('unauthorized') === 'true') {
                showAlert('danger', 'Nu aveți permisiunea să accesați această adeverință.');
            }
        });
        
        function showAlert(type, message) {
            const icon = type === 'success' ? 'check-circle' : 'exclamation-circle';
            const alertHtml = `
                <div class="alert alert-${type}">
                    <i class="fas fa-${icon} alert-icon"></i>
                    <div>${message}</div>
                </div>
            `;
            
            $('#alert-container').html(alertHtml);
            
            // Ascundem alerta după 5 secunde
            setTimeout(function() {
                $('#alert-container').html('');
            }, 5000);
        }
        
        // Adăugăm listener pentru click pe butonul de descărcare
        document.querySelectorAll('.btn-download').forEach(button => {
            button.addEventListener('click', function(e) {
                const url = this.getAttribute('href');
                
                // Adăugăm o animație minimală de încărcare
                this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Se descarcă...';
                this.style.pointerEvents = 'none';
                
                // Urmărim dacă descărcarea începe în 3 secunde
                setTimeout(() => {
                    if (this.style.pointerEvents === 'none') {
                        this.innerHTML = '<i class="fas fa-download"></i> Descarcă';
                        this.style.pointerEvents = 'auto';
                    }
                }, 3000);
                
                // Nu blocăm navigarea implicită
            });
        });
    </script>
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