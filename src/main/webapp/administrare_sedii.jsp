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
                    
                    // Verificare restricții de acces
                    if (userType != 4 || userType >= 15) {
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
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Administrare Sedii</h1>
        </div>
        
        <div class="action-row">
            <div class="search-bar">
                <i class="fas fa-search search-icon"></i>
                <input type="text" id="searchInput" placeholder="Caută sediu după nume, adresă, oraș..." onkeyup="filterSedii()">
            </div>
            <button class="btn btn-primary" onclick="openAddModal()">
                <i class="fas fa-plus"></i>
                Adaugă Sediu Nou
            </button>
        </div>
        
        <div class="card">
            <div class="table-container">
                <table class="sedii-table" id="sediiTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nume Sediu</th>
                            <th>Tip</th>
                            <th>Adresă</th>
                            <th>Oraș</th>
                            <th>Județ</th>
                            <th>Telefon</th>
                            <th>Email</th>
                            <th>Nr. Angajați</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        Connection conn = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            // Query pentru a obține toate sediile și numărul de angajați
                            String sql = "SELECT s.*, COUNT(u.id) as nr_angajati " +
                                        "FROM sedii s " +
                                        "LEFT JOIN locatii_useri lu ON s.id_sediu = lu.id_sediu " +
                                        "LEFT JOIN useri u ON lu.id_user = u.id AND u.activ = 1 " +
                                        "GROUP BY s.id_sediu " +
                                        "ORDER BY s.nume_sediu";
                            Statement stmt = conn.createStatement();
                            ResultSet rs2 = stmt.executeQuery(sql);
                            
                            while (rs2.next()) {
                                String tipClass = "";
                                String tipText = "";
                                switch (rs2.getString("tip_sediu")) {
                                    case "principal":
                                        tipClass = "badge-principal";
                                        tipText = "Principal";
                                        break;
                                    case "secundar":
                                        tipClass = "badge-secundar";
                                        tipText = "Secundar";
                                        break;
                                    case "punct_lucru":
                                        tipClass = "badge-punct-lucru";
                                        tipText = "Punct de lucru";
                                        break;
                                }
                        %>
                        <tr>
                            <td><%= rs2.getInt("id_sediu") %></td>
                            <td><strong><%= rs2.getString("nume_sediu") %></strong></td>
                            <td><span class="sediu-badge <%= tipClass %>"><%= tipText %></span></td>
                            <td><%= rs2.getString("strada") %></td>
                            <td><%= rs2.getString("oras") %></td>
                            <td><%= rs2.getString("judet") %></td>
                            <td><%= rs2.getString("telefon") != null ? rs2.getString("telefon") : "-" %></td>
                            <td><%= rs2.getString("email") != null ? rs2.getString("email") : "-" %></td>
                            <td><%= rs2.getInt("nr_angajati") %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn btn-outline btn-sm" onclick="editSediu(<%= rs2.getInt("id_sediu") %>)" title="Editează">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <% if (rs2.getDouble("latitudine") != 0 && rs2.getDouble("longitudine") != 0) { %>
                                    <button class="btn btn-outline btn-sm" onclick="showMap(<%= rs2.getDouble("latitudine") %>, <%= rs2.getDouble("longitudine") %>)" title="Vezi pe hartă">
                                        <i class="fas fa-map-marker-alt"></i>
                                    </button>
                                    <% } %>
                                    <% if (rs2.getInt("nr_angajati") == 0 && !rs2.getString("tip_sediu").equals("principal")) { %>
                                    <button class="btn btn-danger btn-sm" onclick="deleteSediu(<%= rs2.getInt("id_sediu") %>)" title="Șterge">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                    <% } else { %>
                                    <button class="btn btn-danger btn-sm" disabled title="Nu se poate șterge un sediu cu angajați sau sediul principal">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                            rs2.close();
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
            </div>
        </div>
        
        <!-- Container pentru hartă - Modificat pentru ArcGIS -->
        <div id="mapContainer" class="card" style="display: none; padding: 0; height: 400px; position: relative;">
            <div id="mapView" style="width: 100%; height: 100%; border-radius: 0.75rem;"></div>
            <button class="btn btn-outline" style="position: absolute; top: 10px; right: 10px; z-index: 10;" onclick="closeMap()">
                <i class="fas fa-times"></i> Închide
            </button>
        </div>
    </div>
    
    <!-- Modal Adăugare Sediu -->
    <div id="addSediuModal" class="modal-backdrop">
        <div class="modal">
            <div class="modal-header">
                <h3 class="modal-title">Adaugă Sediu Nou</h3>
                <button class="modal-close" onclick="closeAddModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form id="addSediuForm" method="POST" action="AdaugaSediuServlet">
                <div class="modal-body">
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="nume_sediu" class="form-label">Nume Sediu</label>
                            <input type="text" id="nume_sediu" name="nume_sediu" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tip_sediu" class="form-label">Tip Sediu</label>
                            <select id="tip_sediu" name="tip_sediu" class="form-control" required>
                                <option value="">-- Selectați --</option>
                                <option value="secundar">Sediu Secundar</option>
                                <option value="punct_lucru">Punct de Lucru</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="telefon" class="form-label">Telefon</label>
                            <input type="tel" id="telefon" name="telefon" class="form-control">
                        </div>
                        
                        <div class="form-group full-width">
                            <label for="strada" class="form-label">Stradă</label>
                            <input type="text" id="strada" name="strada" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="oras" class="form-label">Oraș</label>
                            <input type="text" id="oras" name="oras" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="judet" class="form-label">Județ</label>
                            <input type="text" id="judet" name="judet" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="cod" class="form-label">Cod Poștal</label>
                            <input type="text" id="cod" name="cod" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="tara" class="form-label">Țară</label>
                            <input type="text" id="tara" name="tara" value="România" class="form-control" required>
                        </div>
                        
                        <div class="form-group full-width">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" id="email" name="email" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="latitudine" class="form-label">Latitudine</label>
                            <input type="number" step="any" id="latitudine" name="latitudine" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="longitudine" class="form-label">Longitudine</label>
                            <input type="number" step="any" id="longitudine" name="longitudine" class="form-control">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeAddModal()">Anulează</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Salvează
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Editare Sediu -->
    <div id="editSediuModal" class="modal-backdrop">
        <div class="modal">
            <div class="modal-header">
                <h3 class="modal-title">Editare Sediu</h3>
                <button class="modal-close" onclick="closeEditModal()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form id="editSediuForm" method="POST" action="EditSediuServlet">
                <input type="hidden" id="edit_id_sediu" name="id_sediu">
                <div class="modal-body">
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="edit_nume_sediu" class="form-label">Nume Sediu</label>
                            <input type="text" id="edit_nume_sediu" name="nume_sediu" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_tip_sediu" class="form-label">Tip Sediu</label>
                            <select id="edit_tip_sediu" name="tip_sediu" class="form-control" required>
                                <option value="secundar">Sediu Secundar</option>
                                <option value="punct_lucru">Punct de Lucru</option>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_telefon" class="form-label">Telefon</label>
                            <input type="tel" id="edit_telefon" name="telefon" class="form-control">
                        </div>
                        
                        <div class="form-group full-width">
                            <label for="edit_strada" class="form-label">Stradă</label>
                            <input type="text" id="edit_strada" name="strada" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_oras" class="form-label">Oraș</label>
                            <input type="text" id="edit_oras" name="oras" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_judet" class="form-label">Județ</label>
                            <input type="text" id="edit_judet" name="judet" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_cod" class="form-label">Cod Poștal</label>
                            <input type="text" id="edit_cod" name="cod" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_tara" class="form-label">Țară</label>
                            <input type="text" id="edit_tara" name="tara" class="form-control" required>
                        </div>
                        
                        <div class="form-group full-width">
                            <label for="edit_email" class="form-label">Email</label>
                            <input type="email" id="edit_email" name="email" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_latitudine" class="form-label">Latitudine</label>
                            <input type="number" step="any" id="edit_latitudine" name="latitudine" class="form-control">
                        </div>
                        
                        <div class="form-group">
                            <label for="edit_longitudine" class="form-label">Longitudine</label>
                            <input type="number" step="any" id="edit_longitudine" name="longitudine" class="form-control">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" onclick="closeEditModal()">Anulează</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i>
                        Salvează Modificările
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Toasts container -->
    <div class="toast-container" id="toastContainer"></div>

    <script>
        // Variabilă globală pentru view-ul hărții
        let view;
        
        // Funcție pentru filtrarea sediilor
        function filterSedii() {
            const input = document.getElementById('searchInput');
            const filter = input.value.toLowerCase();
            const table = document.getElementById('sediiTable');
            const tr = table.getElementsByTagName('tr');
            
            for (let i = 1; i < tr.length; i++) {
                const td = tr[i].getElementsByTagName('td');
                let textValue = '';
                
                // Exclude ultima coloană (acțiuni)
                for (let j = 0; j < td.length - 1; j++) {
                    if (td[j]) {
                        textValue += td[j].textContent || td[j].innerText;
                    }
                }
                
                if (textValue.toLowerCase().indexOf(filter) > -1) {
                    tr[i].style.display = '';
                } else {
                    tr[i].style.display = 'none';
                }
            }
        }
        
        // Funcții pentru modal
        function openAddModal() {
            document.getElementById('addSediuModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeAddModal() {
            document.getElementById('addSediuModal').classList.remove('active');
            document.body.style.overflow = '';
            document.getElementById('addSediuForm').reset();
            closeMap(); // Închide și harta, dacă este vizibilă
        }
        
        function openEditModal() {
            document.getElementById('editSediuModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        
        function closeEditModal() {
            document.getElementById('editSediuModal').classList.remove('active');
            document.body.style.overflow = '';
            closeMap(); // Închide și harta, dacă este vizibilă
        }
        
        // Funcție pentru editare sediu
        function editSediu(idSediu) {
            $.ajax({
                url: 'GetSediuServlet',
                type: 'GET',
                data: { id: idSediu },
                success: function(sediu) {
                    document.getElementById('edit_id_sediu').value = sediu.id_sediu;
                    document.getElementById('edit_nume_sediu').value = sediu.nume_sediu;
                    document.getElementById('edit_tip_sediu').value = sediu.tip_sediu;
                    document.getElementById('edit_strada').value = sediu.strada;
                    document.getElementById('edit_cod').value = sediu.cod;
                    document.getElementById('edit_oras').value = sediu.oras;
                    document.getElementById('edit_judet').value = sediu.judet;
                    document.getElementById('edit_tara').value = sediu.tara;
                    document.getElementById('edit_telefon').value = sediu.telefon || '';
                    document.getElementById('edit_email').value = sediu.email || '';
                    document.getElementById('edit_latitudine').value = sediu.latitudine || '';
                    document.getElementById('edit_longitudine').value = sediu.longitudine || '';
                    
                    openEditModal();
                },
                error: function() {
                    showToast('Eroare', 'Nu s-au putut încărca datele sediului', 'error');
                }
            });
        }
        
        // Funcție pentru ștergere sediu
        function deleteSediu(idSediu) {
            if (confirm('Sigur doriți să ștergeți acest sediu? Această acțiune este ireversibilă!')) {
                $.ajax({
                    url: 'DeleteSediuServlet',
                    type: 'POST',
                    data: { id_sediu: idSediu },
                    success: function(response) {
                        if (response.success) {
                            showToast('Succes', response.message || 'Sediul a fost șters cu succes', 'success');
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showToast('Eroare', response.message || 'Eroare la ștergerea sediului', 'error');
                        }
                    },
                    error: function() {
                        showToast('Eroare', 'Eroare la conectarea cu serverul', 'error');
                    }
                });
            }
        }
        
        // Funcție pentru afișare hartă cu ArcGIS
        function showMap(lat, lng) {
            if (!lat || !lng) {
                showToast('Informație', 'Nu există coordonate pentru acest sediu', 'error');
                return;
            }
            
            const mapContainer = document.getElementById('mapContainer');
            mapContainer.style.display = 'block';
            mapContainer.scrollIntoView({ behavior: 'smooth' });
            
            // Încărcăm modulele ArcGIS necesare
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/geometry/Point",
                "esri/symbols/SimpleMarkerSymbol"
            ], function(esriConfig, Map, MapView, Graphic, Point, SimpleMarkerSymbol) {
                // Setăm cheia API
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";
                
                // Creăm harta
                const map = new Map({
                    basemap: "arcgis-navigation" // Harta de bază
                });
                
                // Inițializăm view-ul
                view = new MapView({
                    container: "mapView",
                    map: map,
                    center: [lng, lat], // Longitudine, latitudine
                    zoom: 15
                });
                
                // Creăm un punct pentru marker
                const point = new Point({
                    longitude: lng,
                    latitude: lat
                });
                
                // Stilizăm markerul
                const simpleMarkerSymbol = new SimpleMarkerSymbol({
                    color: [226, 119, 40], // Orange
                    outline: {
                        color: [255, 255, 255], // White
                        width: 2
                    },
                    size: 12
                });
                
                // Creăm graficul (marcatorul)
                const pointGraphic = new Graphic({
                    geometry: point,
                    symbol: simpleMarkerSymbol
                });
                
                // Adăugăm marcatorul pe hartă
                view.graphics.add(pointGraphic);
            });
        }
        
        // Funcție pentru închiderea hărții
        function closeMap() {
            const mapContainer = document.getElementById('mapContainer');
            mapContainer.style.display = 'none';
            
            // Opțional, curățăm și distrugem view-ul pentru a elibera resurse
            if (view) {
                view.container = null;
                view = null;
            }
        }
        
        // Funcție pentru afișarea toasturilor
        function showToast(title, message, type = 'success') {
            const toastContainer = document.getElementById('toastContainer');
            
            const toast = document.createElement('div');
            toast.className = `toast toast-${type}`;
            
            const icon = type === 'success' ? 'check-circle' : 'exclamation-circle';
            
            toast.innerHTML = `
                <div class="toast-icon">
                    <i class="fas fa-${icon}"></i>
                </div>
                <div class="toast-content">
                    <div class="toast-title">${title}</div>
                    <div class="toast-message">${message}</div>
                </div>
                <button class="toast-close" onclick="this.parentNode.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            toastContainer.appendChild(toast);
            
            // Afișare cu un mic delay pentru efect
            setTimeout(() => {
                toast.classList.add('show');
            }, 10);
            
            // Ascundere automată după 5 secunde
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    toast.remove();
                }, 300);
            }, 5000);
        }
        
        // Închide modalele când se dă click în afara lor
        window.addEventListener('click', function(event) {
            if (event.target.classList.contains('modal-backdrop')) {
                event.target.classList.remove('active');
                document.body.style.overflow = '';
            }
        });
        
        // Event listeners pentru formulare
        document.getElementById('addSediuForm').addEventListener('submit', function(e) {
            // e.preventDefault(); // Decomentează pentru a preveni submit-ul și a adăuga logică personalizată
            
            // Aici poți adăuga logică pentru validare, geocoding etc.
        });
        
        document.getElementById('editSediuForm').addEventListener('submit', function(e) {
            // e.preventDefault(); // Decomentează pentru a preveni submit-ul și a adăuga logică personalizată
            
            // Aici poți adăuga logică pentru validare, geocoding etc.
        });
        
        // Verificare parametri URL pentru afișare mesaje
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            
            if (urlParams.get('success') === 'true') {
                showToast('Succes', 'Operația a fost realizată cu succes', 'success');
            }
            
            if (urlParams.get('error') === 'true') {
                showToast('Eroare', 'A apărut o eroare în timpul operației', 'error');
            }
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