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
            background-color: var(--clr);
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
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            color: var(--text);
            background-color: var(--background);
            min-height: 100vh;
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
            background-color: var(--card);
            padding: 2rem;
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .page-subtitle {
            font-size: 1rem;
            color: var(--muted);
            margin-top: 0.25rem;
            font-weight: 400;
        }

        .search-container {
            background-color: var(--card);
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }

        .search-input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--border);
            border-radius: 0.5rem;
            font-size: 1rem;
            background-color: var(--clr);
            color: var(--text);
            transition: all 0.2s;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .faq-categories {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .category {
            background-color: var(--card);
            border-radius: 0.75rem;
            padding: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            transition: all 0.2s;
            border: 1px solid var(--border);
        }

        .category:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        .category-header {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid var(--border);
        }

        .category-icon {
            font-size: 1.5rem;
            margin-right: 0.75rem;
            color: var(--accent);
        }

        .category-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text);
        }

         .faq-item {
            margin-bottom: 0.75rem;
            border-radius: 0.5rem;
            overflow: hidden;
            transition: all 0.2s;
            border: 1px solid var(--border);
        }

        .faq-question {
            background-color: var(--hover);
            padding: 0.875rem 1rem;
            cursor: pointer;
            font-weight: 500;
            color: var(--text);
            transition: all 0.2s;
            position: relative;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .faq-question:hover {
            background-color: var(--accent);
            color: white;
        }

        .faq-question::after {
            content: '\f067';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            font-size: 0.875rem;
            transition: transform 0.2s;
        }

        .faq-question.active::after {
            transform: rotate(45deg);
        }

        .faq-answer {
            background-color: white;
            padding: 0;
            max-height: 0;
            overflow: hidden;
            transition: all 0.3s ease;
            border-top: 1px solid var(--border);
        }

        .faq-answer.active {
            padding: 1rem;
            max-height: 400px;
            overflow-y: auto;
            overflow-x: hidden;
        }

        /* Stiluri pentru scrollbar */
        .faq-answer.active::-webkit-scrollbar {
            width: 6px;
        }

        .faq-answer.active::-webkit-scrollbar-track {
            background: var(--hover);
            border-radius: 3px;
        }

        .faq-answer.active::-webkit-scrollbar-thumb {
            background: var(--accent);
            border-radius: 3px;
        }

        .faq-answer.active::-webkit-scrollbar-thumb:hover {
            background: var(--text);
        }

        /* Pentru Firefox */
        .faq-answer.active {
            scrollbar-width: thin;
            scrollbar-color: var(--accent) var(--hover);
        }


        .faq-answer.active {
            padding: 1rem;
            max-height: 500px;
        }

        .faq-answer p {
            margin-bottom: 0.75rem;
            color: var(--text);
        }

        .faq-answer ul {
            margin-left: 1.25rem;
            margin-bottom: 1rem;
        }

        .faq-answer li {
            margin-bottom: 0.5rem;
            color: var(--text);
        word-wrap: break-word;
    overflow-wrap: break-word;
    line-height: 1.6;
}

        .highlight {
            background-color: rgba(79, 70, 229, 0.1);
            color: var(--accent);
            padding: 0.125rem 0.375rem;
            border-radius: 0.25rem;
            font-weight: 600;
            word-break: break-word;
    display: inline-block;
        }

        .tip-box {
            background-color: var(--info);
            color: white;
            padding: 1rem;
            border-radius: 0.5rem;
            margin: 1rem 0;
            position: relative;
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
            gap: 0.75rem;
    word-wrap: break-word;
    overflow-wrap: break-word;
    line-height: 1.5;
    flex-shrink: 0;
        }

        .tip-box::before {
            content: '\f0eb';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            font-size: 1rem;
            margin-top: 0.125rem;
        }

        .warning-box {
            background-color: var(--danger);
            color: white;
            padding: 1rem;
            border-radius: 0.5rem;
            margin: 1rem 0;
            display: flex;
            align-items: flex-start;
            gap: 0.5rem;
            gap: 0.75rem;
    word-wrap: break-word;
    overflow-wrap: break-word;
    line-height: 1.5;
    flex-shrink: 0;
        }

        .warning-box::before {
            content: '\f071';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            font-size: 1rem;
            margin-top: 0.125rem;
        }

        .contact-section {
            background-color: var(--card);
            border-radius: 0.75rem;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid var(--border);
        }

        .contact-section h2 {
            color: var(--accent);
            margin-bottom: 1.25rem;
            font-size: 1.5rem;
            font-weight: 600;
        }

        .contact-section p {
            color: var(--text);
            margin-bottom: 1.25rem;
        }

        .contact-section ul {
            text-align: left;
            max-width: 600px;
            margin: 1.25rem auto;
            color: var(--text);
        }

        .contact-section ul li {
            margin-bottom: 0.5rem;
        }

        .no-results {
            text-align: center;
            padding: 2rem;
            color: var(--muted);
            font-style: italic;
            display: none;
            background-color: var(--card);
            border-radius: 0.75rem;
            margin-bottom: 2rem;
        }

        .no-results h3 {
            color: var(--text);
            margin-bottom: 0.5rem;
        }

        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .faq-categories {
                grid-template-columns: 1fr;
            }
            
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
                text-align: left;
            }
            
            .page-title {
                font-size: 1.5rem;
            }
            
            .category {
                padding: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <div>
                <h1 class="page-title">
                    <i class="fas fa-question-circle"></i>
                    Intrebari adresate frecvent
                </h1>
                <p class="page-subtitle">Gaseste rapid raspunsuri la intrebarile tale despre sistemul de management al resurselor umane</p>
            </div>
        </div>

        <div class="search-container">
            <input type="text" class="search-input" placeholder="Cauta o intrebare sau un cuvant cheie..." id="searchInput">
        </div>

        <div class="no-results" id="noResults">
            <h3>Nu s-au gasit rezultate</h3>
            <p>Incearca sa folosesti termeni diferiti sau contacteaza departamentul HR pentru asistenta.</p>
        </div>

        <div class="faq-categories" id="faqCategories">
            <!-- Categoria: Intrebari generale pentru incepatori -->
            <div class="category" data-category="incepatori">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-star"></i></div>
                    <div class="category-title">Intrebari pentru Incepatori</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Sunt angajat nou - cum ma familiarizez cu sistemul?</div>
                    <div class="faq-answer">
                        <p>Bun venit in echipa noastra! Iata pasii pentru a te familiariza cu sistemul HR:</p>
                        <ul>
                            <li><span class="highlight">Autentifica-te</span> in sistem cu username-ul si parola primite de la HR</li>
                            <li>Completeaza-ti <span class="highlight">profilul personal</span> cu toate informatiile necesare</li>
                            <li>Verifica <span class="highlight">departamentul</span> si <span class="highlight">pozitia</span> ta in sistem</li>
                            <li>Exploreaza modulele disponibile: concedii, task-uri, adeverinte</li>
                            <li>Consulta <span class="highlight">regulamentul intern</span> si politicile companiei</li>
                        </ul>
                        <div class="tip-box">
                            <strong>Sfat:</strong> Pastreaza-ti datele de autentificare in siguranta si schimba parola la prima conectare!
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Ce tipuri de utilizatori exista in sistem?</div>
                    <div class="faq-answer">
                        <p>Sistemul recunoaste mai multe tipuri de pozitii, organizate ierarhic:</p>
                        <ul>
                            <li><span class="highlight">Management superior:</span> CEO, CFO, CHRO, COO, Director General</li>
                            <li><span class="highlight">Management mediu:</span> Director, Manager, Coordonator, Responsabil</li>
                            <li><span class="highlight">Specialisti:</span> Senior, Specialist, Analist, Consultant</li>
                            <li><span class="highlight">Executie:</span> Administrator, Asistent, Inginer, Tehnician, Operator</li>
                            <li><span class="highlight">Incepatori:</span> New Graduate, Junior, Intern</li>
                        </ul>
                        <p>Fiecare tip are <span class="highlight">salarii</span> si <span class="highlight">privilegii</span> diferite in sistem.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum imi verific informatiile personale in sistem?</div>
                    <div class="faq-answer">
                        <p>Pentru a vedea informatiile tale complete:</p>
                        <ul>
                            <li>Acceseaza sectiunea <span class="highlight">"Profil"</span></li>
                            <li>Verifica: nume, prenume, email, telefon, adresa</li>
                            <li>Controleaza: departament, pozitie, sediu de lucru</li>
                            <li>Consulta: data angajarii, vechimea, statusul</li>
                            <li>Vezi: echipele si proiectele la care participi</li>
                        </ul>
                        <div class="warning-box">
                            <strong>Atentie:</strong> Daca observi erori in datele personale, contacteaza imediat departamentul HR!
                        </div>
                    </div>
                </div>
            </div>

            <!-- Categoria: Concedii -->
            <div class="category" data-category="concedii">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-umbrella-beach"></i></div>
                    <div class="category-title">Concedii si Timp Liber</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum fac o cerere de concediu?</div>
                    <div class="faq-answer">
                        <p>Pentru a solicita concediu urmeaza acesti pasi:</p>
                        <ul>
                            <li>Acceseaza modulul <span class="highlight">"Concedii"</span></li>
                            <li>Completeaza formularul cu: data inceput, data sfarsit, motiv, locatia</li>
                            <li>Selecteaza <span class="highlight">tipul de concediu</span> (odihna, medical, etc.)</li>
                            <li>Adauga <span class="highlight">mentiuni suplimentare</span> daca este necesar</li>
                            <li>Trimite cererea - va fi procesata automat de sistem</li>
                        </ul>
                        <div class="tip-box">
                            <strong>Sfat:</strong> Sistemul calculeaza automat durata concediului si verifica zilele disponibile!
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Ce tipuri de concedii pot solicita?</div>
                    <div class="faq-answer">
                        <p>Sistemul suporta urmatoarele tipuri de concedii:</p>
                        <ul>
                            <li><span class="highlight">Concediu de odihna:</span> pana la 21 zile/an</li>
                            <li><span class="highlight">Concediu medical:</span> pana la 90 zile (cu documente)</li>
                            <li><span class="highlight">Concediu maternitate:</span> 126 zile</li>
                            <li><span class="highlight">Concediu paternal:</span> 5 zile</li>
                            <li><span class="highlight">Concediu pentru studii:</span> pana la 30 zile</li>
                            <li><span class="highlight">Concediu fara plata:</span> pana la 30 zile</li>
                            <li><span class="highlight">Evenimente familiale:</span> pana la 5 zile</li>
                        </ul>
                        <p>Fiecare tip are <span class="highlight">reguli specifice</span> de aprobare si documentatie necesara.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cate zile de concediu am la dispozitie?</div>
                    <div class="faq-answer">
                        <p>Zilele de concediu depind de <span class="highlight">tipul pozitiei</span> tale:</p>
                        <ul>
                            <li><span class="highlight">Angajati cu norma intreaga:</span> 40 zile/an</li>
                            <li><span class="highlight">Stagiari (Intern):</span> 30 zile/an</li>
                            <li>Plus <span class="highlight">zile suplimentare</span> pentru vechime sau performanta</li>
                        </ul>
                        <p>Poti verifica in timp real:</p>
                        <ul>
                            <li>Zile consumate pana acum</li>
                            <li>Zile ramase disponibile</li>
                            <li>Concedii luate si statusul lor</li>
                            <li>Concedii in asteptare</li>
                        </ul>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Care este procesul de aprobare a concediilor?</div>
                    <div class="faq-answer">
                        <p>Concediile trec prin urmatorul flux de aprobare:</p>
                        <ul>
                            <li><span class="highlight">Statusul "Neaprobat" (0):</span> Cererea a fost trimisa</li>
                            <li><span class="highlight">Statusul "Aprobat sef" (1):</span> Seful direct a aprobat</li>
                            <li><span class="highlight">Statusul "Aprobat director" (2):</span> Aprobare finala</li>
                            <li><span class="highlight">Statusul "Dezaprobat sef" (-1):</span> Respins de sef</li>
                            <li><span class="highlight">Statusul "Dezaprobat director" (-2):</span> Respins de director</li>
                        </ul>
                        <p>Vei primi <span class="highlight">notificari automate</span> la fiecare schimbare de status.</p>
                    </div>
                </div>
            </div>

            <!-- Categoria: Task-uri si Proiecte -->
            <div class="category" data-category="taskuri">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-tasks"></i></div>
                    <div class="category-title">Task-uri si Proiecte</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum prelungesc un task?</div>
                    <div class="faq-answer">
                        <p>Pentru a prelungi un task urmeaza acesti pasi:</p>
                        <ul>
                            <li>Acceseaza modulul <span class="highlight">"Task-uri"</span></li>
                            <li>Identifica task-ul care necesita prelungire</li>
                            <li>Contacteaza <span class="highlight">supervizorul</span> task-ului</li>
                            <li>Justifica motivul prelungirii</li>
                            <li>Propune o noua <span class="highlight">data de finalizare</span></li>
                        </ul>
                        <div class="warning-box">
                            <strong>Important:</strong> Doar supervizorul task-ului poate modifica datele! Nu lasa modificarile pe ultima zi.
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Care sunt statusurile task-urilor?</div>
                    <div class="faq-answer">
                        <p>Task-urile au urmatoarele statusuri de progres:</p>
                        <ul>
                            <li><span class="highlight">0% (0):</span> Task neinceput</li>
                            <li><span class="highlight">25% (1):</span> Task in progres initial</li>
                            <li><span class="highlight">50% (2):</span> Task la jumatatea progresului</li>
                            <li><span class="highlight">75% (3):</span> Task aproape finalizat</li>
                            <li><span class="highlight">100% (4):</span> Task complet finalizat</li>
                        </ul>
                        <p>Actualizeaza regulat statusul pentru <span class="highlight">transparenta</span> in echipa!</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum vad proiectele la care particip?</div>
                    <div class="faq-answer">
                        <p>Pentru a vedea proiectele tale active:</p>
                        <ul>
                            <li>Verifica sectiunea <span class="highlight">"Proiecte"</span> din meniu</li>
                            <li>Consulta <span class="highlight">"Echipele"</span> din care faci parte</li>
                            <li>Vezi task-urile tale din cadrul fiecarui proiect</li>
                            <li>Verifica deadline-urile si prioritatile</li>
                        </ul>
                        <p>Proiectele active au <span class="highlight">data de sfarsit</span> in viitor si status activ.</p>
                    </div>
                </div>
            </div>

            <!-- Categoria: Adeverinte -->
            <div class="category" data-category="adeverinte">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-file-alt"></i></div>
                    <div class="category-title">Adeverinte si Documente</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum fac o cerere pentru o adeverinta de salariat?</div>
                    <div class="faq-answer">
                        <p>Pentru a solicita o adeverinta de salariat:</p>
                        <ul>
                            <li>Acceseaza modulul <span class="highlight">"Adeverinte"</span></li>
                            <li>Selecteaza tipul <span class="highlight">"Adeverinta salariat"</span></li>
                            <li>Completeaza <span class="highlight">motivul</span> cererii (banca, credit, etc.)</li>
                            <li>Specifica <span class="highlight">institutia destinatara</span></li>
                            <li>Trimite cererea pentru procesare</li>
                        </ul>
                        <div class="tip-box">
                            <strong>Timp de procesare:</strong> Adeverintele simple se proceseaza in 1-2 zile lucratoare.
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Ce tipuri de adeverinte pot solicita?</div>
                    <div class="faq-answer">
                        <p>Sistemul permite solicitarea urmatoarelor adeverinte:</p>
                        <ul>
                            <li><span class="highlight">Adeverinta salariat:</span> confirma calitatea de angajat</li>
                            <li><span class="highlight">Adeverinta venit:</span> pentru credite si imprumuturi</li>
                            <li><span class="highlight">Adeverinta medicala:</span> pentru concedii medicale</li>
                            <li><span class="highlight">Adeverinta vechime:</span> pentru pensie sau alte institutii</li>
                            <li><span class="highlight">Adeverinta experienta:</span> pentru CV si cariera</li>
                            <li><span class="highlight">Adeverinta locuinta:</span> pentru contracte de inchiriere</li>
                            <li><span class="highlight">Adeverinta pentru banci:</span> credite si servicii financiare</li>
                        </ul>
                        <p>Fiecare tip are <span class="highlight">format standard</span> si informatii specifice.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Care este statusul cererii mele de adeverinta?</div>
                    <div class="faq-answer">
                        <p>Adeverintele trec prin urmatoarele statusuri:</p>
                        <ul>
                            <li><span class="highlight">"Neaprobat" (0):</span> Cererea este in procesare</li>
                            <li><span class="highlight">"Aprobat sef" (1):</span> Aprobata de seful direct</li>
                            <li><span class="highlight">"Aprobat director" (2):</span> Finalizata si disponibila</li>
                            <li><span class="highlight">Statusuri negative:</span> Cererea a fost respinsa</li>
                        </ul>
                        <p>Vei fi <span class="highlight">notificat automat</span> cand adeverinta este gata pentru ridicare.</p>
                    </div>
                </div>
            </div>

            <!-- Categoria: Cariera si Dezvoltare -->
            <div class="category" data-category="cariera">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-rocket"></i></div>
                    <div class="category-title">Cariera si Dezvoltare</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Ce trebuie sa fac sa ajung la functia X?</div>
                    <div class="faq-answer">
                        <p>Pentru avansare in cariera urmeaza acesti pasi:</p>
                        <ul>
                            <li><span class="highlight">Munceste consistent</span> si depaseste-ti obiectivele</li>
                            <li>Dezvolta-ti <span class="highlight">competentele tehnice</span> si soft skills</li>
                            <li>Participa la <span class="highlight">training-uri si cursuri</span> de specializare</li>
                            <li>Demonstreaza <span class="highlight">leadership</span> si initiativa</li>
                            <li>Solicita feedback regulat de la supervizori</li>
                            <li>Aplica pentru <span class="highlight">pozitii interne</span> cand se deschid</li>
                        </ul>
                        <div class="tip-box">
                            <strong>Ierarhia tipica:</strong> Intern → Junior → Mid → Senior → Manager → Director → C-Level
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum pot aplica pentru un job in cadrul companiei?</div>
                    <div class="faq-answer">
                        <p>Pentru aplicarea la pozitii interne:</p>
                        <ul>
                            <li>Verifica modulul <span class="highlight">"Joburi disponibile"</span></li>
                            <li>Filtreaza dupa departament, nivel, locatie</li>
                            <li>Citeste atent <span class="highlight">cerintele</span> si <span class="highlight">responsabilitatile</span></li>
                            <li>Completeaza formularul de aplicatie</li>
                            <li>Ataseaza CV-ul actualizat</li>
                            <li>Urmareste statusul aplicatiei tale</li>
                        </ul>
                        <p>Angajatii actuali au <span class="highlight">prioritate</span> la mobilitatea interna!</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Ce presupune procesul de recrutare intern?</div>
                    <div class="faq-answer">
                        <p>Procesul de recrutare interna include:</p>
                        <ul>
                            <li><span class="highlight">Verificarea aplicatiei:</span> CV si motivatie</li>
                            <li><span class="highlight">Interviu cu HR:</span> potrivire culturala si motivatie</li>
                            <li><span class="highlight">Interviu tehnic:</span> cu managerul de departament</li>
                            <li><span class="highlight">Verificarea referintelor:</span> de la supervizorul actual</li>
                            <li><span class="highlight">Decizia finala:</span> si comunicarea rezultatului</li>
                        </ul>
                        <p>Intregul proces dureaza de obicei <span class="highlight">2-3 saptamani</span>.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Pot aplica la mai multe pozitii simultan?</div>
                    <div class="faq-answer">
                        <p>Da, poti aplica la mai multe pozitii, dar cu urmatoarele recomandari:</p>
                        <ul>
                            <li>Limiteaza-te la <span class="highlight">maximum 3 pozitii</span> simultan</li>
                            <li>Asigura-te ca indeplinesti <span class="highlight">cerintele</span> pentru fiecare</li>
                            <li>Personalizeaza <span class="highlight">scrisoarea de motivatie</span> pentru fiecare rol</li>
                            <li>Informeaza HR-ul despre <span class="highlight">preferintele</span> tale</li>
                        </ul>
                        <div class="warning-box">
                            <strong>Atentie:</strong> Aplicatiile neserioase pot afecta negativ reputatia ta interna!
                        </div>
                    </div>
                </div>
            </div>

            <!-- Categoria: Politici si Regulamente -->
            <div class="category" data-category="politici">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-clipboard-list"></i></div>
                    <div class="category-title">Politici si Regulamente</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Rezumat politici/regulament companie</div>
                    <div class="faq-answer">
                        <p><strong>Politicile principale ale companiei:</strong></p>
                        <ul>
                            <li><span class="highlight">Program de lucru:</span> 8 ore/zi, 40 ore/saptamana</li>
                            <li><span class="highlight">Concedii:</span> 30-40 zile/an in functie de pozitie</li>
                            <li><span class="highlight">Confidentialitate:</span> Protejarea datelor companiei si clientilor</li>
                            <li><span class="highlight">Conduita profesionala:</span> Respect, integritate, transparenta</li>
                            <li><span class="highlight">Evaluarea performantei:</span> Anuala cu feedback continuu</li>
                            <li><span class="highlight">Dezvoltarea carierei:</span> Training-uri si mobilitate interna</li>
                            <li><span class="highlight">Securitate:</span> Respectarea procedurilor de siguranta</li>
                        </ul>
                        <div class="tip-box">
                            <strong>Important:</strong> Regulamentul complet este disponibil in sistemul de management documentar.
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Pot sa lucrez remote conform politicilor companiei?</div>
                    <div class="faq-answer">
                        <p>Politica de lucru remote variaza in functie de:</p>
                        <ul>
                            <li><span class="highlight">Tipul pozitiei:</span> unele roluri permit remote/hibrid</li>
                            <li><span class="highlight">Departamentul:</span> IT si anumite specialitati au flexibilitate</li>
                            <li><span class="highlight">Senioritatea:</span> angajatii cu experienta au mai multe optiuni</li>
                            <li><span class="highlight">Natura task-urilor:</span> activitati care nu necesita prezenta fizica</li>
                        </ul>
                        <p>Verifica in sistemul de joburi care sunt marcate ca <span class="highlight">"remote"</span> sau <span class="highlight">"hibrid"</span>.</p>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum functioneaza sistemul de penalizari si sporuri?</div>
                    <div class="faq-answer">
                        <p><strong>Sporurile disponibile:</strong></p>
                        <ul>
                            <li><span class="highlight">Spor de noapte:</span> +25% pentru lucrul in ture de noapte</li>
                            <li><span class="highlight">Spor de weekend:</span> +15% pentru lucrul in weekend</li>
                            <li><span class="highlight">Spor de vechime:</span> +10% dupa 3 ani in companie</li>
                            <li><span class="highlight">Spor de confidentialitate:</span> +10% pentru acces la date sensibile</li>
                        </ul>
                        
                        <p><strong>Penalizarile posibile:</strong></p>
                        <ul>
                            <li><span class="highlight">Intarzieri repetate:</span> -10% din salariu</li>
                            <li><span class="highlight">Absente nemotivate:</span> -20% din salariu</li>
                            <li><span class="highlight">Nerespectare regulament:</span> -15% din salariu</li>
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Categoria: Sistem si Suport -->
            <div class="category" data-category="suport">
                <div class="category-header">
                    <div class="category-icon"><i class="fas fa-tools"></i></div>
                    <div class="category-title">Sistem si Suport Tehnic</div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Am uitat parola - cum o resetez?</div>
                    <div class="faq-answer">
                        <p>Pentru resetarea parolei:</p>
                        <ul>
                        
                            <li>Mergei la <span class="highlight">pagina de conectare</span></li>
                            <li>Incarca sa te conectezi <span class="highlight">asa cum o faceai pana acum</span> folosind o parola intentionat gresita</li>
                            <li>Dupa apasarea butonului de conectare <span class="highlight">va aparea un text jos cu Ai uitat parola?</span></li>
                            <li>Da click si vei fi dus intr-o pagina separata in care ti se va cere sa completezi <span class="highlight">codul numeric personal</span></li>
                            <li>Apoi procedura va fi simpla, caci vei fi redirectionat catre o pagina in care completezi direct noua parola.</li>
                        </ul>
                        <div class="warning-box">
                            <strong>Securitate:</strong> Nu impartasi niciodata parola cu alti colegi!
                        </div>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Nu primesc notificari din sistem - ce sa fac?</div>
                    <div class="faq-answer">
                        <p>Pentru problemele cu notificarile:</p>
                        <ul>
                            <li>Notificarile sunt <span class="highlight">numai e-mail</span></li>
                            <li>Controleaza <span class="highlight">folderul de spam</span> din email</li>
                            <li>Asigura-te ca <span class="highlight">email-ul</span> din sistem este corect</li>
                            <li>Contacteaza IT pentru <span class="highlight">suport tehnic</span></li>
                        </ul>
                    </div>
                </div>

                <div class="faq-item">
                    <div class="faq-question">Cum raportez o problema tehnica?</div>
                    <div class="faq-answer">
                        <p>Pentru raportarea problemelor tehnice:</p>
                        <ul>
                            <li>Trimite e-mail la <span class="highlight">monica.moise@example.com</span></li>
                            <li>Descrie <span class="highlight">detaliat problema</span> intalnita</li>
                            <li>Mentioneaza <span class="highlight">pasii</span> care au dus la problema</li>
                            <li>Ataseaza <span class="highlight">screenshot-uri</span> daca este necesar</li>
                            
                        </ul>
                        <p>Echipa IT va raspunde in <span class="highlight">maximum 24 ore</span>.</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="contact-section">
            <h2><i class="fas fa-handshake"></i> Ai nevoie de ajutor suplimentar?</h2>
            <p>Daca nu ai gasit raspunsul la intrebarea ta, nu ezita sa contactezi:</p>
            <ul>
                <li><strong>Departamentul HR:</strong> pentru intrebari legate de concedii, salarii, politici</li>
                <li><strong>Departamentul IT:</strong> pentru probleme tehnice cu sistemul</li>
                <li><strong>Supervizorul direct:</strong> pentru task-uri si proiecte</li>
             
            </ul>
            <div class="tip-box">
                <strong>Tip:</strong> Intotdeauna specifica numarul tau de angajat cand contactezi departamentele pentru asistenta rapida!
            </div>
        </div>
    </div>

    <script>
        // Functionality pentru acordeon FAQ
        document.querySelectorAll('.faq-question').forEach(question => {
            question.addEventListener('click', () => {
                const answer = question.nextElementSibling;
                const isActive = answer.classList.contains('active');
                
                // Inchide toate raspunsurile
                document.querySelectorAll('.faq-answer').forEach(ans => {
                    ans.classList.remove('active');
                });
                document.querySelectorAll('.faq-question').forEach(q => {
                    q.classList.remove('active');
                });
                
                // Deschide raspunsul curent daca nu era activ
                if (!isActive) {
                    answer.classList.add('active');
                    question.classList.add('active');
                }
            });
        });

        // Functionality pentru cautare
        const searchInput = document.getElementById('searchInput');
        const categories = document.querySelectorAll('.category');
        const noResults = document.getElementById('noResults');

        searchInput.addEventListener('input', (e) => {
            const searchTerm = e.target.value.toLowerCase();
            let hasResults = false;

            categories.forEach(category => {
                const categoryText = category.textContent.toLowerCase();
                const faqItems = category.querySelectorAll('.faq-item');
                let categoryHasMatch = false;

                faqItems.forEach(item => {
                    const itemText = item.textContent.toLowerCase();
                    if (itemText.includes(searchTerm)) {
                        item.style.display = 'block';
                        categoryHasMatch = true;
                        hasResults = true;
                    } else {
                        item.style.display = searchTerm === '' ? 'block' : 'none';
                    }
                });

                if (categoryHasMatch || searchTerm === '') {
                    category.style.display = 'block';
                } else {
                    category.style.display = 'none';
                }
            });

            noResults.style.display = !hasResults && searchTerm !== '' ? 'block' : 'none';
        });

        // Animatii la scroll - simplificat pentru a se integra cu stilul sistemului
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -20px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        // Aplicam observerul doar la categoriile care nu sunt vizibile initial
        categories.forEach((category, index) => {
            if (index > 2) { // Doar pentru categoriile dupa primele 3
                category.style.opacity = '0';
                category.style.transform = 'translateY(20px)';
                category.style.transition = 'all 0.4s ease';
                observer.observe(category);
            }
        });
    </script></body>
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