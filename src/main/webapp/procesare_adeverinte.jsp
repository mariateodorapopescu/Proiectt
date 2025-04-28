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
                        
                        // Verificăm permisiunile - doar directorul (tip=0) și șefii de departament (tip=3) pot accesa această pagină
                        if (userTip != 0 && userTip != 3) {
                            response.sendRedirect("dashboard.jsp");
                            return;
                        }
                        
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
    <title>Aprobare Adeverințe</title>
    
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
        }
        
        .btn-primary {
            background-color: var(--accent);
            color: white;
        }
        
        .btn-primary:hover {
            opacity: 0.9;
        }
        
        .btn-success {
            background-color: var(--success);
            color: white;
        }
        
        .btn-success:hover {
            opacity: 0.9;
        }
        
        .btn-danger {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-danger:hover {
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
        
        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            font-size: 0.875rem;
        }
        
        th {
            background-color: var(--hover);
            color: var(--text);
            font-weight: 600;
            text-align: left;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            white-space: nowrap;
        }
        
        td {
            padding: 0.75rem 1rem;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        
        tr:last-child td {
            border-bottom: none;
        }
        
        tr:hover td {
            background-color: var(--hover);
        }
        
        /* Status */
        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.625rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .status-asteptare {
            background-color: rgba(245, 158, 11, 0.1);
            color: var(--warning);
        }
        
        .status-aprobat-sef {
            background-color: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }
        
        .status-aprobat {
            background-color: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }
        
        .status-respins {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--danger);
        }
        
        /* Alerte și mesaje */
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
        
        /* Acțiuni în tabel */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }
        
        .action-button {
            padding: 0.375rem;
            border-radius: 0.375rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            color: var(--text);
            background-color: transparent;
        }
        
        .action-button:hover {
            background-color: var(--hover);
        }
        
        .action-button.approve {
            color: var(--success);
        }
        
        .action-button.reject {
            color: var(--danger);
        }
        
        /* Spinner pentru încărcare */
        .spinner {
            border: 0.25rem solid rgba(0, 0, 0, 0.1);
            border-top-color: var(--accent);
            border-radius: 50%;
            width: 1.5rem;
            height: 1.5rem;
            animation: spin 1s linear infinite;
            display: inline-block;
            vertical-align: middle;
            margin-right: 0.5rem;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
                margin-bottom: 1.5rem;
            }
            
            th, td {
                padding: 0.625rem 0.75rem;
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
        
        /* Tooltip */
        .tooltip {
            position: relative;
            display: inline-block;
        }
        
        .tooltip .tooltip-text {
            visibility: hidden;
            background-color: var(--text);
            color: white;
            text-align: center;
            border-radius: 0.375rem;
            padding: 0.5rem;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            transition: opacity 0.3s;
            white-space: nowrap;
            font-size: 0.75rem;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .tooltip:hover .tooltip-text {
            visibility: visible;
            opacity: 1;
        }
        
        /* Paginare */
        .pagination {
            display: flex;
            justify-content: flex-end;
            margin-top: 1.5rem;
            gap: 0.25rem;
        }
        
        .pagination-button {
            padding: 0.5rem 0.75rem;
            background-color: var(--card);
            color: var(--text);
            border: 1px solid var(--border);
            border-radius: 0.375rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .pagination-button:hover {
            background-color: var(--hover);
        }
        
        .pagination-button.active {
            background-color: var(--accent);
            color: white;
            border-color: var(--accent);
        }
        
        .pagination-button.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 2rem;
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
        }
        
        /* Spațiere suplimentară */
        .mt-3 {
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h1 class="page-title">
                <% if (userTip == 0) { %>
                    Aprobare Adeverințe (Director)
                <% } else { %>
                    Aprobare Adeverințe (Șef Departament)
                <% } %>
            </h1>
            
            <a href="dashboard.jsp" class="btn btn-primary">
                <i class="fas fa-arrow-left"></i>
                Înapoi la Panou
            </a>
        </div>
        
        <div id="alert-container"></div>
        
        <div class="card">
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Nr.</th>
                            <th>Angajat</th>
                            <th>Departament</th>
                            <th>Tip Adeverință</th>
                            <th>Motiv</th>
                            <th>Data Cererii</th>
                            <th>Status</th>
                            <th>Acțiuni</th>
                        </tr>
                    </thead>
                    <tbody id="adeverinte-table-body">
                        <tr>
                            <td colspan="8">
                                <div class="empty-state">
                                    <div class="spinner"></div>
                                    <p>Se încarcă adeverințele...</p>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="pagination" id="pagination-container"></div>
    </div>
    
    <script>
        $(document).ready(function() {
            // Variabile pentru paginare
            let currentPage = 1;
            const itemsPerPage = 10;
            let totalItems = 0;
            
            // Încărcăm adeverințele pentru procesare
            loadAdeverinte();
            
            function loadAdeverinte() {
                const userTip = <%= userTip %>;
                
                // Determinăm ce adeverințe să încărcăm în funcție de tipul utilizatorului
                let url = 'GetAdeverinteServlet';
                let params = {
                    page: currentPage,
                    itemsPerPage: itemsPerPage,
                    userTip: userTip
                };
                
                // Adăugăm departamentul pentru șefi
                <% if (userTip == 3) { %>
                    params.departament = <%= userDep %>;
                <% } %>
                
                // Facem cererea AJAX
                $.ajax({
                    url: url,
                    type: 'GET',
                    data: params,
                    dataType: 'json',
                    success: function(response) {
                        // Verificăm dacă există date
                        if (response.success && response.adeverinte && response.adeverinte.length > 0) {
                            displayAdeverinte(response.adeverinte);
                            totalItems = response.totalItems;
                            setupPagination();
                        } else {
                            displayEmptyState();
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Eroare la încărcarea adeverințelor:', error);
                        displayErrorState();
                    }
                });
            }
            
            function displayAdeverinte(adeverinte) {
                let tableHtml = '';
                
                adeverinte.forEach((adeverinta, index) => {
                    // Calculăm numărul real în funcție de pagină
                    const rowNumber = (currentPage - 1) * itemsPerPage + index + 1;
                    
                    // Status badge class
                    let statusClass = '';
                    switch(adeverinta.status) {
                        case 0: statusClass = 'status-asteptare'; break;
                        case 1: statusClass = 'status-aprobat-sef'; break;
                        case 2: statusClass = 'status-aprobat'; break;
                        case -1: statusClass = 'status-respins'; break;
                        case -2: statusClass = 'status-respins'; break;
                    }
                    
                    // Construim rândul pentru fiecare adeverință
                    tableHtml += `
                        <tr data-id="${adeverinta.id}">
                            <td>${rowNumber}</td>
                            <td>${adeverinta.numeAngajat}</td>
                            <td>${adeverinta.departament}</td>
                            <td>${adeverinta.tipAdeverinta}</td>
                            <td>${adeverinta.motiv}</td>
                            <td>${adeverinta.dataCerere}</td>
                            <td>
                                <span class="status-badge ${statusClass}">
                                    ${adeverinta.statusText}
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                    `;
                    
                    // Adăugăm butoanele în funcție de tipul de utilizator și status
                    if (<%= userTip %> == 3 && adeverinta.status == 0) {
                        // Șef de departament poate aproba sau respinge cererile în așteptare
                        tableHtml += `
                            <button class="action-button approve" onclick="aprobaAdeverinta(${adeverinta.id}, 1)">
                                <i class="fas fa-check"></i>
                            </button>
                            <button class="action-button reject" onclick="respingeAdeverinta(${adeverinta.id}, -1)">
                                <i class="fas fa-times"></i>
                            </button>
                        `;
                    } else if (<%= userTip %> == 0 && adeverinta.status == 1) {
                        // Directorul poate aproba sau respinge cererile aprobate de șef
                        tableHtml += `
                            <button class="action-button approve" onclick="aprobaAdeverinta(${adeverinta.id}, 2)">
                                <i class="fas fa-check"></i>
                            </button>
                            <button class="action-button reject" onclick="respingeAdeverinta(${adeverinta.id}, -2)">
                                <i class="fas fa-times"></i>
                            </button>
                        `;
                    } else {
                        // Altfel afișăm un mesaj că nu sunt disponibile acțiuni
                        tableHtml += `
                            <span class="tooltip">
                                <i class="fas fa-info-circle"></i>
                                <span class="tooltip-text">Nu sunt disponibile acțiuni pentru acest status</span>
                            </span>
                        `;
                    }
                    
                    tableHtml += `
                                </div>
                            </td>
                        </tr>
                    `;
                });
                
                $('#adeverinte-table-body').html(tableHtml);
            }
            
            function displayEmptyState() {
                const emptyHtml = `
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <i class="fas fa-inbox empty-state-icon"></i>
                                <h3 class="empty-state-title">Nu există adeverințe de procesat</h3>
                                <p>În acest moment nu aveți adeverințe care necesită aprobarea dumneavoastră.</p>
                            </div>
                        </td>
                    </tr>
                `;
                
                $('#adeverinte-table-body').html(emptyHtml);
                $('#pagination-container').hide();
            }
            
            function displayErrorState() {
                const errorHtml = `
                    <tr>
                        <td colspan="8">
                            <div class="empty-state">
                                <i class="fas fa-exclamation-triangle empty-state-icon" style="color: var(--danger);"></i>
                                <h3 class="empty-state-title">Eroare la încărcare</h3>
                                <p>A apărut o eroare la încărcarea adeverințelor. Vă rugăm să reîncărcați pagina.</p>
                                <button class="btn btn-primary mt-3" onclick="location.reload()">Reîncarcă pagina</button>
                            </div>
                        </td>
                    </tr>
                `;
                
                $('#adeverinte-table-body').html(errorHtml);
                $('#pagination-container').hide();
            }
            
            function setupPagination() {
                const totalPages = Math.ceil(totalItems / itemsPerPage);
                
                if (totalPages <= 1) {
                    $('#pagination-container').hide();
                    return;
                }
                
                let paginationHtml = '';
                
                // Buton înapoi
                const prevDisabled = currentPage === 1 ? 'disabled' : '';
                paginationHtml += `
                    <button class="pagination-button ${prevDisabled}" ${prevDisabled ? 'disabled' : 'onclick="changePage(' + (currentPage - 1) + ')"'}>
                        <i class="fas fa-chevron-left"></i>
                    </button>
                `;
                
                // Pagini
                for (let i = 1; i <= totalPages; i++) {
                    const active = i === currentPage ? 'active' : '';
                    paginationHtml += `
                        <button class="pagination-button ${active}" onclick="changePage(${i})">${i}</button>
                    `;
                }
                
                // Buton înainte
                const nextDisabled = currentPage === totalPages ? 'disabled' : '';
                paginationHtml += `
                    <button class="pagination-button ${nextDisabled}" ${nextDisabled ? 'disabled' : 'onclick="changePage(' + (currentPage + 1) + ')"'}>
                        <i class="fas fa-chevron-right"></i>
                    </button>
                `;
                
                $('#pagination-container').html(paginationHtml);
                $('#pagination-container').show();
            }
            
            // Funcție pentru a schimba pagina - definită ca funcție globală pentru a fi accesibilă din HTML
            window.changePage = function(page) {
                currentPage = page;
                loadAdeverinte();
            };
            
            // Funcții pentru aprobarea/respingerea adeverințelor - definite ca funcții globale pentru a fi accesibile din HTML
            window.aprobaAdeverinta = function(id, status) {
                procesareAdeverinta(id, status);
            };
            
            window.respingeAdeverinta = function(id, status) {
                procesareAdeverinta(id, status);
            };
            
            function procesareAdeverinta(id, status) {
                // Adăugăm spinner pentru a indica procesarea
                const row = $(`tr[data-id="${id}"]`);
                const actionsCell = row.find('.action-buttons');
                actionsCell.html('<div class="spinner"></div> Procesare...');
                
                $.ajax({
                    url: 'ProcesareAdeverintaServlet',
                    type: 'POST',
                    data: {
                        id: id,
                        status: status
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.success) {
                            showAlert('success', 'Adeverința a fost procesată cu succes!');
                            
                            // Reîncărcăm lista de adeverințe
                            setTimeout(function() {
                                loadAdeverinte();
                            }, 1000);
                        } else {
                            showAlert('danger', response.message || 'A apărut o eroare la procesare.');
                            loadAdeverinte(); // Reîncărcăm pentru a reseta interfața
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Eroare la procesarea adeverinței:', error);
                        showAlert('danger', 'A apărut o eroare la procesare. Vă rugăm să încercați din nou.');
                        loadAdeverinte(); // Reîncărcăm pentru a reseta interfața
                    }
                });
            }
            
            function showAlert(type, message) {
                const alertHtml = `
                    <div class="alert alert-${type}">
                        <i class="fas fa-${type === 'success' ? 'check-circle' : 'exclamation-triangle'} alert-icon"></i>
                        <div>${message}</div>
                    </div>
                `;
                
                $('#alert-container').html(alertHtml);
                
                // Ascundem alerta după 5 secunde
                setTimeout(function() {
                    $('#alert-container').html('');
                }, 5000);
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