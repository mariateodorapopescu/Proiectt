<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dosare Angajati - Sistem HR</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255, 255, 255, 0.95);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            text-align: center;
        }
        
        .header h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
            font-weight: 700;
        }
        
        .header p {
            color: #666;
            font-size: 1.1em;
        }
        
        .search-section {
            background: rgba(255, 255, 255, 0.95);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .search-controls {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            margin-bottom: 8px;
            color: #555;
        }
        
        .form-group input, .form-group select {
            padding: 12px;
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .btn-search {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            white-space: nowrap;
        }
        
        .btn-search:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .results-section {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .employees-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 20px;
            padding: 25px;
        }
        
        .employee-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            border: 1px solid #f0f0f0;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .employee-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.15);
            border-color: #667eea;
        }
        
        .employee-header {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f8f9fa;
        }
        
        .employee-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            font-size: 20px;
            margin-right: 15px;
        }
        
        .employee-info h3 {
            color: #333;
            font-size: 1.3em;
            margin-bottom: 5px;
        }
        
        .employee-info .position {
            color: #667eea;
            font-weight: 600;
            font-size: 0.9em;
        }
        
        .employee-details {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-bottom: 15px;
        }
        
        .detail-item {
            display: flex;
            flex-direction: column;
        }
        
        .detail-label {
            font-size: 0.8em;
            color: #888;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .detail-value {
            font-weight: 600;
            color: #333;
            margin-top: 2px;
        }
        
        .status-badges {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-top: 10px;
        }
        
        .badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75em;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .badge-active {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-bonus {
            background: #fff3cd;
            color: #856404;
        }
        
        .badge-penalty {
            background: #f8d7da;
            color: #721c24;
        }
        
        .badge-promoted {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        /* Modal pentru dosarul complet */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
        }
        
        .modal-content {
            background-color: white;
            margin: 2% auto;
            padding: 0;
            border-radius: 15px;
            width: 95%;
            max-width: 1200px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        
        .modal-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h2 {
            font-size: 1.8em;
            margin: 0;
        }
        
        .close {
            color: white;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            transition: background-color 0.3s;
        }
        
        .close:hover {
            background-color: rgba(255,255,255,0.2);
        }
        
        .modal-body {
            padding: 25px;
        }
        
        .tabs {
            display: flex;
            border-bottom: 2px solid #f0f0f0;
            margin-bottom: 25px;
        }
        
        .tab {
            padding: 12px 24px;
            background: none;
            border: none;
            cursor: pointer;
            font-weight: 600;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.3s ease;
        }
        
        .tab.active {
            color: #667eea;
            border-bottom-color: #667eea;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .info-card {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-card h4 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.1em;
        }
        
        .history-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .history-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        .history-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .history-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        .history-table tr:hover {
            background-color: #e8f0fe;
        }
        
        .timeline {
            position: relative;
            padding-left: 30px;
        }
        
        .timeline::before {
            content: '';
            position: absolute;
            left: 15px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .timeline-item {
            position: relative;
            margin-bottom: 20px;
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -22px;
            top: 20px;
            width: 12px;
            height: 12px;
            background: #667eea;
            border-radius: 50%;
            border: 3px solid white;
        }
        
        .timeline-date {
            color: #667eea;
            font-weight: 600;
            font-size: 0.9em;
        }
        
        .timeline-content {
            margin-top: 5px;
        }
        
        .no-results {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .no-results h3 {
            margin-bottom: 10px;
            color: #667eea;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #667eea;
        }
        
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
        }
        
        @media (max-width: 768px) {
            .search-controls {
                grid-template-columns: 1fr;
            }
            
            .employees-grid {
                grid-template-columns: 1fr;
            }
            
            .modal-content {
                width: 98%;
                margin: 1% auto;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1> Dosare Angajati</h1>
            <p>Sistem integrat cu date din baza de date existenta</p>
        </div>
        
        <div class="search-section">
            <div class="search-controls">
                <div class="form-group">
                    <label for="searchName">Cautare nume:</label>
                    <input type="text" id="searchName" placeholder="Introduceti numele sau prenumele...">
                </div>
                
                <div class="form-group">
                    <label for="filterDept">Departament:</label>
                    <select id="filterDept">
                        <option value="">Toate departamentele</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="filterPosition">Pozitie:</label>
                    <select id="filterPosition">
                        <option value="">Toate pozitiile</option>
                    </select>
                </div>
                
                <button class="btn-search" onclick="loadEmployees()">
                     Cautare
                </button>
            </div>
        </div>
        
        <div class="results-section">
            <div id="employeesContainer" class="employees-grid">
                <div class="loading">
                    <h3> Se incarca datele din baza de date...</h3>
                    <p>Va rugam sa asteptati...</p>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Modal pentru dosarul complet -->
    <div id="employeeModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 id="modalTitle">Dosarul Angajatului</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <div class="tabs">
                    <button class="tab active" onclick="openTab(event, 'generalInfo')">📝 Informatii Generale</button>
                    <button class="tab" onclick="openTab(event, 'salaryHistory')"> Istoric Salarial</button>
                    <button class="tab" onclick="openTab(event, 'positionHistory')"> Istoric Pozitii</button>
                    <button class="tab" onclick="openTab(event, 'bonusPenalty')"> Sporuri & Penalizari</button>
                    <button class="tab" onclick="openTab(event, 'leaveHistory')"> Istoric Concedii</button>
                    <button class="tab" onclick="openTab(event, 'projects')"> Proiecte & Task-uri</button>
                </div>
                
                <div id="generalInfo" class="tab-content active">
                    <div class="info-grid" id="generalInfoContent">
                        <!-- Continut generat dinamic din BD -->
                    </div>
                </div>
                
                <div id="salaryHistory" class="tab-content">
                    <h3> Istoricul Salarial</h3>
                    <table class="history-table" id="salaryTable">
                        <thead>
                            <tr>
                                <th>Perioada</th>
                                <th>Salariu Brut</th>
                                <th>Salariu Net</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="salaryTableBody">
                            <!-- Date generate dinamic din BD -->
                        </tbody>
                    </table>
                </div>
                
                <div id="positionHistory" class="tab-content">
                    <h3> Istoricul Pozitiilor si Promovarilor</h3>
                    <div class="timeline" id="positionTimeline">
                        <!-- Timeline generat dinamic din BD -->
                    </div>
                </div>
                
                <div id="bonusPenalty" class="tab-content">
                    <h3> Sporuri si Penalizari</h3>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div>
                            <h4 style="color: #28a745;"> Sporuri Active</h4>
                            <table class="history-table" id="bonusTable">
                                <thead>
                                    <tr>
                                        <th>Tip Spor</th>
                                        <th>Procent</th>
                                        <th>Perioada</th>
                                        <th>Motiv</th>
                                    </tr>
                                </thead>
                                <tbody id="bonusTableBody">
                                    <!-- Date generate dinamic din BD -->
                                </tbody>
                            </table>
                        </div>
                        <div>
                            <h4 style="color: #dc3545;"> Penalizari Active</h4>
                            <table class="history-table" id="penaltyTable">
                                <thead>
                                    <tr>
                                        <th>Tip Penalizare</th>
                                        <th>Procent</th>
                                        <th>Perioada</th>
                                        <th>Motiv</th>
                                    </tr>
                                </thead>
                                <tbody id="penaltyTableBody">
                                    <!-- Date generate dinamic din BD -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <div id="leaveHistory" class="tab-content">
                    <h3> Istoricul Concediilor</h3>
                    <table class="history-table" id="leaveTable">
                        <thead>
                            <tr>
                                <th>Tip Concediu</th>
                                <th>Data Start</th>
                                <th>Data Sfarsit</th>
                                <th>Zile</th>
                                <th>Status</th>
                                <th>Motiv</th>
                            </tr>
                        </thead>
                        <tbody id="leaveTableBody">
                            <!-- Date generate dinamic din BD -->
                        </tbody>
                    </table>
                </div>
                
                <div id="projects" class="tab-content">
                    <h3> Proiecte si Task-uri</h3>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div>
                            <h4 style="color: #667eea;"> Proiecte Active</h4>
                            <div id="activeProjects"></div>
                        </div>
                        <div>
                            <h4 style="color: #ffc107;"> Task-uri Asignate</h4>
                            <div id="assignedTasks"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Variabile globale
        let currentEmployeeId = null;
        let allEmployees = [];
        
        // Initializare cand se incarca pagina
        document.addEventListener('DOMContentLoaded', function() {
            console.log(' Initializare sistemul de dosare angajati...');
            loadFilters();
            loadEmployees();
        });

        // Functie pentru API call-uri
        async function apiCall(url, params = {}) {
            try {
                const urlParams = new URLSearchParams(params);
                const fullUrl = url + '?' + urlParams.toString();
                
                console.log(' API Call:', fullUrl);
                
                const response = await fetch(fullUrl);
                const data = await response.json();
                
                console.log(' API Response:', data);
                
                if (!data.success) {
                    throw new Error(data.error || 'Eroare API necunoscuta');
                }
                
                return data;
            } catch (error) {
                console.error(' API Error:', error);
                throw error;
            }
        }

        // incarca filtrele (departamente si pozitii)
        async function loadFilters() {
            try {
                console.log(' Se incarca filtrele...');
                const result = await apiCall('EmployeeFileServlet', { action: 'loadFilters' });
                
                const deptSelect = document.getElementById('filterDept');
                const posSelect = document.getElementById('filterPosition');
                
                // Resetare optiuni
                deptSelect.innerHTML = '<option value="">Toate departamentele</option>';
                posSelect.innerHTML = '<option value="">Toate pozitiile</option>';
                
                // Adauga departamentele
                if (result.filters.departments) {
                    result.filters.departments.forEach(dept => {
                        const option = document.createElement('option');
                        option.value = dept;
                        option.textContent = dept;
                        deptSelect.appendChild(option);
                    });
                }
                
                // Adauga pozitiile
                if (result.filters.positions) {
                    result.filters.positions.forEach(pos => {
                        const option = document.createElement('option');
                        option.value = pos;
                        option.textContent = pos;
                        posSelect.appendChild(option);
                    });
                }
                
                console.log(' Filtrele au fost incarcate cu succes');
                
            } catch (error) {
                console.error(' Eroare la incarcarea filtrelor:', error);
                showError('Nu s-au putut incarca filtrele: ' + error.message);
            }
        }

        // incarca lista angajatilor
        async function loadEmployees() {
            try {
                console.log(' Se incarca angajatii...');
                
                const searchName = document.getElementById('searchName').value;
                const filterDept = document.getElementById('filterDept').value;
                const filterPosition = document.getElementById('filterPosition').value;
                
                const params = {
                    action: 'loadEmployees',
                    searchName: searchName,
                    filterDept: filterDept,
                    filterPosition: filterPosition
                };
                
                const result = await apiCall('EmployeeFileServlet', params);
                
                allEmployees = result.data;
                displayEmployees(allEmployees);
                
                console.log(' Au fost incarcati ' + allEmployees.length + ' angajati');
                
            } catch (error) {
                console.error(' Eroare la incarcarea angajatilor:', error);
                showContainerError(document.getElementById('employeesContainer'), error);
            }
        }

        // Afiseaza angajatii in grid
        function displayEmployees(employees) {
            const container = document.getElementById('employeesContainer');
            
            if (employees.length === 0) {
                container.innerHTML = 
                    '<div class="no-results">' +
                        '<h3> Niciun angajat gasit</h3>' +
                        '<p>incercati sa modificati criteriile de cautare.</p>' +
                    '</div>';
                return;
            }

            container.innerHTML = employees.map(function(employee) {
                const initials = employee.nume.charAt(0) + employee.prenume.charAt(0);
                
                // Calculeaza badge-urile de status
                const badges = [];
                if (employee.activ) badges.push('<span class="badge badge-active">Activ</span>');
                if (employee.sporuri_active) badges.push('<span class="badge badge-bonus">Sporuri</span>');
                if (employee.penalizari_active) badges.push('<span class="badge badge-penalty">Penalizari</span>');
                if (employee.numar_promovari > 0) badges.push('<span class="badge badge-promoted">Promovat</span>');
                
                const experienta = employee.data_ang ? 
                    Math.floor((new Date() - new Date(employee.data_ang)) / (365.25 * 24 * 60 * 60 * 1000)) : 0;
                
                return '<div class="employee-card" onclick="openEmployeeModal(' + employee.id + ')">' +
                            '<div class="employee-header">' +
                                '<div class="employee-avatar">' + initials + '</div>' +
                                '<div class="employee-info">' +
                                    '<h3>' + employee.nume + ' ' + employee.prenume + '</h3>' +
                                    '<div class="position">' + employee.pozitie + ' - ' + employee.departament + '</div>' +
                                '</div>' +
                            '</div>' +
                            
                            '<div class="employee-details">' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Email</span>' +
                                    '<span class="detail-value">' + (employee.email || 'N/A') + '</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Telefon</span>' +
                                    '<span class="detail-value">' + (employee.telefon || 'N/A') + '</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Salariu</span>' +
                                    '<span class="detail-value">' + employee.salariu.toLocaleString() + ' RON</span>' +
                                '</div>' +
                                '<div class="detail-item">' +
                                    '<span class="detail-label">Experienta</span>' +
                                    '<span class="detail-value">' + experienta + ' ani</span>' +
                                '</div>' +
                            '</div>' +
                            
                            '<div class="status-badges">' +
                                badges.join('') +
                            '</div>' +
                        '</div>';
            }).join('');
        }

        // Deschide modalul cu detaliile angajatului
        async function openEmployeeModal(employeeId) {
            try {
                console.log(' Se deschide dosarul pentru angajatul ID:', employeeId);
                currentEmployeeId = employeeId;
                
                // Gaseste angajatul in lista existenta
                const employee = allEmployees.find(emp => emp.id === employeeId);
                if (!employee) {
                    throw new Error('Angajatul nu a fost gasit');
                }
                
                // Seteaza titlul modalului
                document.getElementById('modalTitle').textContent = 
                    'Dosarul lui ' + employee.nume + ' ' + employee.prenume;
                
                // incarca informatiile generale
                loadGeneralInfo(employee);
                
                // Afiseaza modalul
                document.getElementById('employeeModal').style.display = 'block';
                
                // Seteaza primul tab ca activ
                openTab(null, 'generalInfo');
                
                console.log(' Modalul a fost deschis cu succes');
                
            } catch (error) {
                console.error(' Eroare la deschiderea modalului:', error);
                showError('Nu s-a putut deschide dosarul: ' + error.message);
            }
        }

        // inchide modalul
        function closeModal() {
            document.getElementById('employeeModal').style.display = 'none';
            currentEmployeeId = null;
        }

        // Gestioneaza tab-urile din modal
        function openTab(evt, tabName) {
            // Ascunde toate tab-urile
            const tabContents = document.getElementsByClassName('tab-content');
            for (let i = 0; i < tabContents.length; i++) {
                tabContents[i].classList.remove('active');
            }
            
            // Elimina clasa active de la toate tab-urile
            const tabs = document.getElementsByClassName('tab');
            for (let i = 0; i < tabs.length; i++) {
                tabs[i].classList.remove('active');
            }
            
            // Afiseaza tab-ul selectat
            document.getElementById(tabName).classList.add('active');
            
            // Marcheaza tab-ul ca activ
            if (evt) {
                evt.currentTarget.classList.add('active');
            } else {
                // Pentru primul tab (cand se deschide modalul)
                document.querySelector('.tab').classList.add('active');
            }
            
            // incarca datele specifice pentru tab
            if (currentEmployeeId) {
                loadTabData(tabName);
            }
        }

        // incarca datele pentru un tab specific
        async function loadTabData(tabName) {
            if (!currentEmployeeId) return;
            
            try {
                console.log(' Se incarca datele pentru tab-ul:', tabName);
                
                switch (tabName) {
                    case 'salaryHistory':
                        await loadSalaryHistory(currentEmployeeId);
                        break;
                    case 'positionHistory':
                        await loadPositionHistory(currentEmployeeId);
                        break;
                    case 'bonusPenalty':
                        await loadBonusPenalty(currentEmployeeId);
                        break;
                    case 'leaveHistory':
                        await loadLeaveHistory(currentEmployeeId);
                        break;
                    case 'projects':
                        await loadProjectsAndTasks(currentEmployeeId);
                        break;
                }
                
            } catch (error) {
                console.error(' Eroare la incarcarea datelor pentru tab:', error);
                showError('Nu s-au putut incarca datele: ' + error.message);
            }
        }

        // incarca informatiile generale
        function loadGeneralInfo(employee) {
            const container = document.getElementById('generalInfoContent');
            
            const experienta = employee.data_ang ? 
                Math.floor((new Date() - new Date(employee.data_ang)) / (365.25 * 24 * 60 * 60 * 1000)) : 0;
            
            container.innerHTML = 
                '<div class="info-card">' +
                    '<h4> Informatii Personale</h4>' +
                    '<p><strong>Nume complet:</strong> ' + employee.nume + ' ' + employee.prenume + '</p>' +
                    '<p><strong>Email:</strong> ' + (employee.email || 'N/A') + '</p>' +
                    '<p><strong>Telefon:</strong> ' + (employee.telefon || 'N/A') + '</p>' +
                    '<p><strong>Status:</strong> <span class="badge ' + (employee.activ ? 'badge-active' : 'badge-penalty') + '">' + (employee.activ ? 'Activ' : 'Inactiv') + '</span></p>' +
                '</div>' +
                
                '<div class="info-card">' +
                    '<h4> Informatii Profesionale</h4>' +
                    '<p><strong>Departament:</strong> ' + employee.departament + '</p>' +
                    '<p><strong>Pozitie:</strong> ' + employee.pozitie + '</p>' +
                    '<p><strong>Salariu actual:</strong> ' + employee.salariu.toLocaleString() + ' RON</p>' +
                    '<p><strong>Data angajarii:</strong> ' + (employee.data_ang ? formatDate(employee.data_ang) : 'N/A') + '</p>' +
                '</div>' +
                
                '<div class="info-card">' +
                    '<h4> Status Current</h4>' +
                    '<p><strong>Sporuri active:</strong> ' + (employee.sporuri_active || 'Niciun spor activ') + '</p>' +
                    '<p><strong>Penalizari active:</strong> ' + (employee.penalizari_active || 'Nicio penalizare activa') + '</p>' +
                    '<p><strong>Numarul de promovari:</strong> ' + (employee.numar_promovari || 0) + '</p>' +
                '</div>' +
                
                '<div class="info-card">' +
                    '<h4> Statistici Concedii</h4>' +
                    '<p><strong>Experienta in companie:</strong> ' + experienta + ' ani</p>' +
                    '<p><strong>Zile concediu consumate:</strong> ' + (employee.conluate || 0) + '</p>' +
                    '<p><strong>Zile concediu ramase:</strong> ' + (employee.zilecons || 0) + '</p>' +
                '</div>';
        }

        // incarca istoricul salarial
        async function loadSalaryHistory(employeeId) {
            try {
                const result = await apiCall('EmployeeDataServlet', {
                    action: 'salaryHistory',
                    employeeId: employeeId
                });
                
                const tbody = document.getElementById('salaryTableBody');
                
                if (result.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #666;">Nu exista date salariale inregistrate</td></tr>';
                    return;
                }

                tbody.innerHTML = result.data.map(function(record) {
                    return '<tr>' +
                            '<td>' + record.luna.toString().padStart(2, '0') + '/' + record.an + '</td>' +
                            '<td>' + record.salariu_brut.toLocaleString() + ' RON</td>' +
                            '<td>' + record.salariu_net.toLocaleString() + ' RON</td>' +
                            '<td><span class="badge badge-active">Generat</span></td>' +
                        '</tr>';
                }).join('');
                
            } catch (error) {
                document.getElementById('salaryTableBody').innerHTML = 
                    '<tr><td colspan="4" style="text-align: center; color: #dc3545;">Eroare la incarcarea datelor: ' + error.message + '</td></tr>';
            }
        }

        // incarca istoricul de pozitii
        async function loadPositionHistory(employeeId) {
            try {
                const result = await apiCall('EmployeeDataServlet', {
                    action: 'positionHistory',
                    employeeId: employeeId
                });
                
                const timeline = document.getElementById('positionTimeline');
                
                if (result.data.length === 0) {
                    timeline.innerHTML = '<p style="text-align: center; color: #666;">Nu exista promovari inregistrate</p>';
                    return;
                }

                timeline.innerHTML = result.data.map(function(promo) {
                    return '<div class="timeline-item">' +
                            '<div class="timeline-date">' + formatDate(promo.data_promovare) + '</div>' +
                            '<div class="timeline-content">' +
                                '<h4 style="color: #667eea; margin-bottom: 5px;"> Promovare</h4>' +
                                '<p>De la <strong>' + promo.pozitie_veche + '</strong> la <strong>' + promo.pozitie_noua + '</strong></p>' +
                                '<small style="color: #666;">Tip: ' + promo.tip_promovare + '</small>' +
                            '</div>' +
                        '</div>';
                }).join('');
                
            } catch (error) {
                document.getElementById('positionTimeline').innerHTML = 
                    '<p style="color: #dc3545; text-align: center;">Eroare la incarcarea datelor: ' + error.message + '</p>';
            }
        }

        // incarca sporurile si penalizarile
        async function loadBonusPenalty(employeeId) {
            try {
                // Sporuri
                const bonusResult = await apiCall('EmployeeDataServlet', {
                    action: 'bonusHistory',
                    employeeId: employeeId
                });
                
                const bonusTbody = document.getElementById('bonusTableBody');
                
                if (bonusResult.data.length === 0) {
                    bonusTbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #28a745;">Nu exista sporuri active</td></tr>';
                } else {
                    bonusTbody.innerHTML = bonusResult.data.map(function(bonus) {
                        return '<tr>' +
                                '<td>' + bonus.tip_spor + '</td>' +
                                '<td style="color: #28a745; font-weight: bold;">+' + bonus.procent + '%</td>' +
                                '<td>' + formatDate(bonus.data_start) + ' - ' + formatDate(bonus.data_final) + '</td>' +
                                '<td>' + (bonus.motiv || 'N/A') + '</td>' +
                            '</tr>';
                    }).join('');
                }

                // Penalizari
                const penaltyResult = await apiCall('EmployeeDataServlet', {
                    action: 'penaltyHistory',
                    employeeId: employeeId
                });
                
                const penaltyTbody = document.getElementById('penaltyTableBody');
                
                if (penaltyResult.data.length === 0) {
                    penaltyTbody.innerHTML = '<tr><td colspan="4" style="text-align: center; color: #28a745;">Nu exista penalizari active</td></tr>';
                } else {
                    penaltyTbody.innerHTML = penaltyResult.data.map(function(penalty) {
                        return '<tr>' +
                                '<td>' + penalty.tip_penalizare + '</td>' +
                                '<td style="color: #dc3545; font-weight: bold;">-' + penalty.procent + '%</td>' +
                                '<td>' + formatDate(penalty.data_start) + ' - ' + formatDate(penalty.data_final) + '</td>' +
                                '<td>' + (penalty.motiv || 'N/A') + '</td>' +
                            '</tr>';
                    }).join('');
                }
                
            } catch (error) {
                document.getElementById('bonusTableBody').innerHTML = 
                    '<tr><td colspan="4" style="text-align: center; color: #dc3545;">Eroare: ' + error.message + '</td></tr>';
                document.getElementById('penaltyTableBody').innerHTML = 
                    '<tr><td colspan="4" style="text-align: center; color: #dc3545;">Eroare: ' + error.message + '</td></tr>';
            }
        }

        // incarca istoricul de concedii
        async function loadLeaveHistory(employeeId) {
            try {
                const result = await apiCall('EmployeeDataServlet', {
                    action: 'leaveHistory',
                    employeeId: employeeId
                });
                
                const tbody = document.getElementById('leaveTableBody');
                
                if (result.data.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #666;">Nu exista concedii inregistrate</td></tr>';
                    return;
                }

                tbody.innerHTML = result.data.map(function(leave) {
                    return '<tr>' +
                            '<td>' + leave.tip_concediu + '</td>' +
                            '<td>' + formatDate(leave.start_c) + '</td>' +
                            '<td>' + formatDate(leave.end_c) + '</td>' +
                            '<td><strong>' + leave.zile + ' zile</strong></td>' +
                            '<td><span class="badge ' + getStatusBadgeClass(leave.status) + '">' + leave.status + '</span></td>' +
                            '<td>' + (leave.motiv || 'N/A') + '</td>' +
                        '</tr>';
                }).join('');
                
            } catch (error) {
                document.getElementById('leaveTableBody').innerHTML = 
                    '<tr><td colspan="6" style="text-align: center; color: #dc3545;">Eroare: ' + error.message + '</td></tr>';
            }
        }

        // incarca proiectele si task-urile
        async function loadProjectsAndTasks(employeeId) {
            try {
                const result = await apiCall('EmployeeDataServlet', {
                    action: 'projectsAndTasks',
                    employeeId: employeeId
                });
                
                // Proiecte active
                const projectsContainer = document.getElementById('activeProjects');
                
                if (result.data.projects.length === 0) {
                    projectsContainer.innerHTML = '<p style="color: #666;">Nu participa la proiecte active</p>';
                } else {
                    projectsContainer.innerHTML = result.data.projects.map(function(project) {
                        return '<div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 10px;">' +
                                '<h5 style="color: #667eea; margin-bottom: 5px;"> ' + project.nume_proiect + '</h5>' +
                                '<p style="margin-bottom: 5px;"><strong>Echipa:</strong> ' + project.nume_echipa + '</p>' +
                                '<p style="margin-bottom: 5px;"><strong>Perioada:</strong> ' + formatDate(project.start) + ' - ' + formatDate(project.end) + '</p>' +
                                '<p style="color: #666; font-size: 0.9em;">' + (project.descriere || 'Fara descriere') + '</p>' +
                            '</div>';
                    }).join('');
                }

                // Task-uri asignate
                const tasksContainer = document.getElementById('assignedTasks');
                
                if (result.data.tasks.length === 0) {
                    tasksContainer.innerHTML = '<p style="color: #666;">Nu are task-uri asignate</p>';
                } else {
                    tasksContainer.innerHTML = result.data.tasks.map(function(task) {
                        return '<div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 10px;">' +
                                '<h5 style="color: #ffc107; margin-bottom: 5px;"> ' + task.nume_task + '</h5>' +
                                '<p style="margin-bottom: 5px;"><strong>Proiect:</strong> ' + (task.nume_proiect || 'N/A') + '</p>' +
                                '<p style="margin-bottom: 5px;"><strong>Deadline:</strong> ' + (task.end ? formatDate(task.end) : 'Nu este setat') + '</p>' +
                                '<div style="background: #e9ecef; height: 8px; border-radius: 4px; margin-top: 5px;">' +
                                    '<div style="background: #ffc107; height: 100%; width: ' + (task.progres || 0) + '%; border-radius: 4px;"></div>' +
                                '</div>' +
                                '<p style="font-size: 0.8em; color: #666; margin-top: 2px;">Progres: ' + (task.progres || 0) + '%</p>' +
                            '</div>';
                    }).join('');
                }
                
            } catch (error) {
                document.getElementById('activeProjects').innerHTML = '<p style="color: #dc3545;">Eroare: ' + error.message + '</p>';
                document.getElementById('assignedTasks').innerHTML = '<p style="color: #dc3545;">Eroare: ' + error.message + '</p>';
            }
        }

        // HELPER FUNCTIONS

        // Formateaza o data
        function formatDate(dateStr) {
            if (!dateStr) return 'N/A';
            const date = new Date(dateStr);
            return date.toLocaleDateString('ro-RO');
        }

        // Obtine clasa CSS pentru status badge
        function getStatusBadgeClass(status) {
            if (status && status.toLowerCase().includes('aprobat')) return 'badge-active';
            if (status && status.toLowerCase().includes('respins')) return 'badge-penalty';
            if (status && status.toLowerCase().includes('pending')) return 'badge-bonus';
            return 'badge-active';
        }

        // Afiseaza eroare simpla
        function showError(message) {
            alert(' Eroare: ' + message);
        }

        // Afiseaza eroare in container
        function showContainerError(container, error) {
            container.innerHTML = 
                '<div class="error">' +
                    '<h3> Eroare la incarcarea datelor</h3>' +
                    '<p>' + error.message + '</p>' +
                    '<button onclick="loadEmployees()" style="margin-top: 10px; padding: 8px 16px; background: #667eea; color: white; border: none; border-radius: 4px; cursor: pointer;">🔄 Reincearca</button>' +
                '</div>';
        }

        // inchide modalul cand se da click in afara lui
        window.onclick = function(event) {
            const modal = document.getElementById('employeeModal');
            if (event.target === modal) {
                closeModal();
            }
        }

        // Handler pentru Enter in campul de cautare
        document.getElementById('searchName').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                loadEmployees();
            }
        });

        console.log(' Sistemul de dosare angajati a fost initializat cu succes!');
    </script>
</body>
</html>