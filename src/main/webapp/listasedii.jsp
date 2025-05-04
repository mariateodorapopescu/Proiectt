<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
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
                        int userId = rs.getInt("id");
                        int userType = rs.getInt("tip");
                        int userDep = rs.getInt("id_dep");
                        String functie = rs.getString("functie");
                        int ierarhie = rs.getInt("ierarhie");
                        if (functie.compareTo("Administrator") != 0) {  
                          
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
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
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrare Sedii</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Script-uri ArcGIS -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.27/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.27/"></script>
    
    <style>
        :root {
            --accent: <%=accent%>;
            --background: <%=clr%>;
            --card: <%=sidebar%>;
            --text: <%=text%>;
            --border: #e5e7eb;
            --hover: <%=hover%>;
            --danger: #ef4444;
            --danger-hover: #dc2626;
            --success: #10b981;
            --warning: #f59e0b;
            --info: #3b82f6;
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
        
        .search-bar {
            position: relative;
            width: 100%;
            max-width: 400px;
        }
        
        .search-bar input {
            width: 100%;
            padding: 0.75rem 1rem 0.75rem 2.5rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            background-color: var(--card);
            color: var(--text);
            font-size: 0.875rem;
            outline: none;
            transition: all 0.2s;
        }
        
        .search-bar input:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        
        .search-icon {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
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
        }
        
        .btn-primary {
            background-color: var(--accent);
            color: white;
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-outline {
            background-color: transparent;
            border: 1px solid var(--border);
            color: var(--text);
        }
        
        .btn-outline:hover {
            background-color: var(--hover);
        }
        
        .btn-danger {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-danger:hover {
            background-color: var(--danger-hover);
        }
        
        .btn-sm {
            padding: 0.375rem 0.75rem;
            font-size: 0.75rem;
        }
        
        .btn-icon {
            padding: 0.375rem;
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
        
        .sedii-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        .sedii-table th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        .sedii-table td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        .sedii-table tr:last-child td {
            border-bottom: none;
        }
        
        .sedii-table tr:hover td {
            background-color: var(--hover);
        }
        
        /* Badge pentru tipul de sediu */
        .sediu-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.625rem;
            font-size: 0.75rem;
            font-weight: 500;
            border-radius: 9999px;
            white-space: nowrap;
        }
        
        .badge-principal {
            background-color: var(--success);
            color: white;
        }
        
        .badge-secundar {
            background-color: var(--info);
            color: white;
        }
        
        .badge-punct-lucru {
            background-color: var(--warning);
            color: white;
        }
        
        /* Acțiuni în tabel */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        /* Modal */
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
            max-width: 600px;
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
        .form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-group.full-width {
            grid-column: span 2;
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
        
        /* Notificări toast */
        .toast-container {
            position: fixed;
            bottom: 1.5rem;
            right: 1.5rem;
            z-index: 100;
        }
        
        .toast {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            background-color: white;
            border-left: 4px solid var(--accent);
            border-radius: 0.375rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            padding: 1rem 1.25rem;
            margin-top: 0.75rem;
            max-width: 24rem;
            transform: translateX(100%);
            opacity: 0;
            transition: all 0.3s;
        }
        
        .toast.show {
            transform: translateX(0);
            opacity: 1;
        }
        
        .toast-success {
            border-left-color: var(--success);
        }
        
        .toast-error {
            border-left-color: var(--danger);
        }
        
        .toast-icon {
            font-size: 1.25rem;
        }
        
        .toast-success .toast-icon {
            color: var(--success);
        }
        
        .toast-error .toast-icon {
            color: var(--danger);
        }
        
        .toast-content {
            flex: 1;
        }
        
        .toast-title {
            font-weight: 600;
            font-size: 0.875rem;
            margin-bottom: 0.125rem;
        }
        
        .toast-message {
            font-size: 0.875rem;
            color: #6b7280;
        }
        
        .toast-close {
            background: transparent;
            border: none;
            color: #9ca3af;
            cursor: pointer;
            transition: color 0.2s;
        }
        
        .toast-close:hover {
            color: var(--text);
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .form-group.full-width {
                grid-column: span 1;
            }
            
            .action-row {
                flex-direction: column;
                align-items: stretch;
                gap: 1rem;
            }
            
            .search-bar {
                max-width: none;
            }
        }
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0079c1;
            margin-top: 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #0079c1;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .action-btn {
            display: inline-block;
            padding: 6px 12px;
            margin: 0 5px;
            background-color: #0079c1;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
        }
        .action-btn.edit {
            background-color: #4CAF50;
        }
        .action-btn.delete {
            background-color: #f44336;
        }
        .action-btn.map {
            background-color: #FF9800;
        }
        .action-btn:hover {
            opacity: 0.8;
        }
        .add-btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            margin-bottom: 20px;
            font-weight: bold;
        }
        .add-btn:hover {
            background-color: #45a049;
        }
        .button-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .search-container {
            display: flex;
            align-items: center;
        }
        .search-container input {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-right: 10px;
        }
        .search-container button {
            padding: 8px 16px;
            background-color: #0079c1;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-container button:hover {
            background-color: #005a91;
        }
        .no-data {
            text-align: center;
            padding: 20px;
            color: #666;
            font-style: italic;
        }
        .status-message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #dff2bf;
            color: #4F8A10;
        }
        .error {
            background-color: #ffbaba;
            color: #D8000C;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="button-container">
            <h1>Lista Sedii</h1>
            <a href="adaugaresediu.jsp" class="add-btn"><i class="fas fa-plus"></i> Adaugă Sediu Nou</a>
        </div>
        
        <div class="search-container">
            <input type="text" id="searchInput" placeholder="Caută după nume, oraș sau tip sediu...">
            <button onclick="searchTable()"><i class="fas fa-search"></i> Caută</button>
        </div>
        
        <%
        // Afișăm mesajul de status dacă există
        String message = request.getParameter("message");
        String status = request.getParameter("status");
        if (message != null && !message.isEmpty()) {
            String statusClass = "success";
            if (status != null && status.equals("error")) {
                statusClass = "error";
            }
        %>
        <div class="status-message <%= statusClass %>">
            <%= message %>
        </div>
        <% } %>
        
        <table id="sediiTable">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nume Sediu</th>
                    <th>Tip</th>
                    <th>Adresă</th>
                    <th>Contact</th>
                    <th>Acțiuni</th>
                </tr>
            </thead>
            <tbody>
            <%
            try {
                // Conectare la baza de date
                Class.forName("com.mysql.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                
                // Executare query
                String sql = "SELECT * FROM sedii ORDER BY id_sediu DESC";
                Statement stmt = conn.createStatement();
                ResultSet rs2 = stmt.executeQuery(sql);
                
                // Verificăm dacă există înregistrări
                boolean hasRecords = false;
                
                // Afișare rezultate
                while(rs2.next()) {
                    hasRecords = true;
                    int id = rs2.getInt("id_sediu");
                    String numeSediu = rs2.getString("nume_sediu");
                    String tipSediu = rs2.getString("tip_sediu");
                    String strada = rs2.getString("strada");
                    String oras = rs2.getString("oras");
                    String judet = rs2.getString("judet");
                    String tara = rs2.getString("tara");
                    String telefon = rs2.getString("telefon");
                    String email = rs2.getString("email");
                    
                    // Formatare adresă
                    String adresa = strada + ", " + oras + ", " + judet + ", " + tara;
                    
                    // Formatare contact
                    String contact = "";
                    if (telefon != null && !telefon.isEmpty()) {
                        contact += telefon;
                    }
                    if (email != null && !email.isEmpty()) {
                        if (!contact.isEmpty()) contact += " | ";
                        contact += email;
                    }
                    if (contact.isEmpty()) {
                        contact = "N/A";
                    }
            %>
                <tr>
                    <td><%= id %></td>
                    <td><%= numeSediu %></td>
                    <td>
                        <% 
                            if ("principal".equals(tipSediu)) { 
                                out.print("Principal");
                            } else if ("secundar".equals(tipSediu)) {
                                out.print("Secundar");
                            } else if ("punct_lucru".equals(tipSediu)) {
                                out.print("Punct de lucru");
                            } else {
                                out.print(tipSediu);
                            }
                        %>
                    </td>
                    <td><%= adresa %></td>
                    <td><%= contact %></td>
                    <td>
                        <a href="adaugaresediu.jsp?id_sediu=<%= id %>" class="action-btn edit"><i class="fas fa-edit"></i> Editează</a>
                        <a href="javascript:confirmDelete(<%= id %>)" class="action-btn delete"><i class="fas fa-trash"></i> Șterge</a>
                        <a href="vizualizaresediu.jsp?id_sediu=<%= id %>" class="action-btn map"><i class="fas fa-map-marker-alt"></i> Hartă</a>
                    </td>
                </tr>
            <%
                }
                
                // Dacă nu există înregistrări, afișăm un mesaj
                if (!hasRecords) {
            %>
                <tr>
                    <td colspan="6" class="no-data">Nu există sedii înregistrate. Adăugați un sediu nou pentru a începe.</td>
                </tr>
            <%
                }
                
                // Închidere resurse
                rs2.close();
                stmt.close();
                conn.close();
            } catch(Exception e) {
                e.printStackTrace();
                out.println("<tr><td colspan='6' class='no-data'>Eroare la încărcarea datelor: " + e.getMessage() + "</td></tr>");
            }
            %>
            </tbody>
        </table>
    </div>
    
    <script>
        function confirmDelete(id) {
            if (confirm("Sunteți sigur că doriți să ștergeți acest sediu? Această acțiune este ireversibilă.")) {
                window.location.href = "DeleteSediu?id_sediu=" + id;
            }
        }
        
        function searchTable() {
            var input, filter, table, tr, td, i, j, txtValue, found;
            input = document.getElementById("searchInput");
            filter = input.value.toUpperCase();
            table = document.getElementById("sediiTable");
            tr = table.getElementsByTagName("tr");
            
            for (i = 1; i < tr.length; i++) {
                found = false;
                td = tr[i].getElementsByTagName("td");
                
                for (j = 1; j < 5; j++) { // Căutăm în coloanele 1-4 (nume, tip, adresa)
                    if (td[j]) {
                        txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
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