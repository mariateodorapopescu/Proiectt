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
                    try (ResultSet rs = preparedStatement.executeQuery()) {
                        if (rs.next()) {
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
    <title>Cerere Demisie</title>
    
    <!-- Fonturi Google -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Iconițe -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- jQuery și jQuery UI pentru datepicker -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.js"></script>
    
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
            max-width: 800px;
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
        
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .btn-danger {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-danger:hover {
            opacity: 0.9;
        }
        
        /* Card pentru formular */
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
        
        .alert-warning {
            background-color: rgba(245, 158, 11, 0.1);
            color: var(--warning);
            border: 1px solid rgba(245, 158, 11, 0.2);
        }
        
        /* Info box */
        .info-box {
            background-color: rgba(79, 70, 229, 0.1);
            border: 1px solid rgba(79, 70, 229, 0.2);
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
        
        .info-box-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--accent);
        }
        
        .info-box-list {
            list-style-type: disc;
            padding-left: 1.5rem;
            margin-bottom: 0.5rem;
        }
        
        /* Responsive */
        @media (max-width: 640px) {
            .container {
                padding: 1rem;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
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
            <h1 class="page-title">Cerere de Demisie</h1>
            
            <a href="dashboard.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i>
                Înapoi la Panou
            </a>
        </div>
        
        <% if ("true".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">
                <strong>Eroare!</strong> A apărut o problemă la procesarea cererii de demisie. Vă rugăm să încercați din nou.
            </div>
        <% } else if ("invalidDate".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">
                <strong>Eroare!</strong> Data ultimei zile de lucru trebuie să fie în viitor.
            </div>
        <% } else if ("existingRequest".equals(request.getParameter("error"))) { %>
            <div class="alert alert-warning">
                <strong>Atenție!</strong> Aveți deja o cerere de demisie activă.
            </div>
        <% } else if ("database".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger">
                <strong>Eroare de bază de date!</strong> <%=request.getParameter("message") != null ? request.getParameter("message") : "Contactați administratorul pentru asistență."%>
            </div>
        <% } %>
        
        <div class="info-box">
            <div class="info-box-title">Informații Importante</div>
            <p>Înainte de a depune cererea de demisie, vă rugăm să țineți cont de următoarele:</p>
            <ul class="info-box-list">
                <li>Conform Codului Muncii, perioada de preaviz este de 20 de zile lucrătoare pentru funcțiile de execuție și 45 de zile lucrătoare pentru funcțiile de conducere.</li>
                <li>Cererea de demisie nu poate fi retrasă odată ce a fost aprobată.</li>
                <li>Veți fi contactat de departamentul HR pentru a discuta pașii următori și procesul de predare a atribuțiilor.</li>
                <li>Până la data ultimei zile de lucru, sunteți obligat să vă îndepliniți toate responsabilitățile conform fișei postului.</li>
            </ul>
        </div>
        
        <div class="card">
            <div class="card-header">
                Formular Cerere de Demisie
            </div>
            <div class="card-body">
                <form action="CerereDemisieServlet" method="post" id="demisie-form">
                    <div class="form-group">
                        <label for="nume" class="form-label">Nume și Prenume:</label>
                        <input type="text" class="form-control" id="nume" value="<%= numePrenume %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="departament" class="form-label">Departament:</label>
                        <input type="text" class="form-control" id="departament" value="<%= departament %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label for="data_ultima_zi" class="form-label">Data ultimei zile de lucru:</label>
                        <input type="text" class="form-control datepicker" id="data_ultima_zi" name="data_ultima_zi" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="motiv" class="form-label">Motivul demisiei (opțional):</label>
                        <textarea class="form-control" id="motiv" name="motiv" rows="5" placeholder="Introduceți motivul pentru care doriți să demisionați..."></textarea>
                    </div>
                    
                    <div class="form-group">
                        <div class="alert alert-warning">
                            <strong>Atenție!</strong> Depunerea unei cereri de demisie este o acțiune importantă. Vă rugăm să vă asigurați că ați luat această decizie în mod informat.
                        </div>
                    </div>
                    
                    <button type="button" class="btn btn-danger" id="confirma-submit">
                        <i class="fas fa-paper-plane"></i>
                        Depune Cererea de Demisie
                    </button>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Modal de confirmare -->
    <div id="confirmation-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); z-index: 1000; align-items: center; justify-content: center;">
        <div style="background-color: var(--card); border-radius: 0.75rem; padding: 1.5rem; width: 90%; max-width: 500px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
            <h3 style="margin-bottom: 1rem; font-size: 1.25rem; font-weight: 600; color: var(--text);">Confirmare Demisie</h3>
            <p style="margin-bottom: 1.5rem; color: var(--text);">Sunteți sigur că doriți să depuneți cererea de demisie? Această acțiune nu poate fi anulată.</p>
            <div style="display: flex; gap: 0.75rem; justify-content: flex-end;">
                <button id="cancel-btn" class="btn btn-secondary" style="padding: 0.5rem 1rem;">Anulează</button>
                <button id="confirm-btn" class="btn btn-danger" style="padding: 0.5rem 1rem;">Confirm</button>
            </div>
        </div>
    </div>
    
    <script>
        $(document).ready(function() {
            // Inițializare datepicker cu opțiuni pentru română
            $.datepicker.regional['ro'] = {
                closeText: 'Închide',
                prevText: 'Luna precedentă',
                nextText: 'Luna următoare',
                currentText: 'Azi',
                monthNames: ['Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'],
                monthNamesShort: ['Ian', 'Feb', 'Mar', 'Apr', 'Mai', 'Iun', 'Iul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                dayNames: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
                dayNamesShort: ['Dum', 'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm'],
                dayNamesMin: ['Du', 'Lu', 'Ma', 'Mi', 'Jo', 'Vi', 'Sâ'],
                weekHeader: 'Săpt',
                dateFormat: 'yy-mm-dd',
                firstDay: 1,
                isRTL: false,
                showMonthAfterYear: false,
                yearSuffix: ''
            };
            $.datepicker.setDefaults($.datepicker.regional['ro']);
            
            $(".datepicker").datepicker({
                minDate: '+20D', // Minimum 20 de zile de la data curentă (preaviz minim)
                dateFormat: 'yy-mm-dd',
                changeMonth: true,
                changeYear: true
            });
            
            // Funcționalitate pentru modal de confirmare
            $("#confirma-submit").click(function() {
                // Validare date
                if (!$("#data_ultima_zi").val()) {
                    alert("Vă rugăm să selectați data ultimei zile de lucru.");
                    return;
                }
                
                // Arată modal de confirmare
                $("#confirmation-modal").css("display", "flex");
            });
            
            $("#cancel-btn").click(function() {
                $("#confirmation-modal").css("display", "none");
            });
            
            $("#confirm-btn").click(function() {
                $("#demisie-form").submit();
            });
        });
    </script>
</body>
</html>
<%
                        }
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