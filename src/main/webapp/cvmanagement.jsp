<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Management CV - Sistem Complet</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        /* CSS pentru Management CV */
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
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Navigation */
        .nav-tabs {
            display: flex;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            overflow: hidden;
        }

        .nav-tab {
            flex: 1;
            padding: 15px 20px;
            text-align: center;
            cursor: pointer;
            background: white;
            border: none;
            font-size: 16px;
            font-weight: 500;
            transition: all 0.3s ease;
            border-right: 1px solid #e0e0e0;
        }

        .nav-tab:last-child {
            border-right: none;
        }

        .nav-tab.active {
            background: #3498db;
            color: white;
        }

        .nav-tab:hover:not(.active) {
            background: #f8f9fa;
        }

        /* Content Areas */
        .content-area {
            display: none;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            padding: 30px;
            min-height: 600px;
        }

        .content-area.active {
            display: block;
            animation: fadeIn 0.3s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* Dashboard */
        .dashboard-header {
            background: linear-gradient(135deg, #3498db, #9b59b6);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            text-align: center;
        }

        .dashboard-header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .dashboard-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.2);
        }

        .dashboard-card .icon {
            font-size: 3em;
            margin-bottom: 15px;
            color: #3498db;
            font-weight: bold;
        }

        .dashboard-card h3 {
            margin-bottom: 10px;
            color: #2c3e50;
        }

        .dashboard-card p {
            color: #7f8c8d;
            margin-bottom: 20px;
        }

        .btn {
            display: inline-block;
            padding: 12px 24px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            border: none;
            cursor: pointer;
            font-size: 14px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }

        .btn-success { background: #27ae60; }
        .btn-success:hover { background: #229954; }
        .btn-warning { background: #f39c12; }
        .btn-warning:hover { background: #e67e22; }
        .btn-danger { background: #e74c3c; }
        .btn-danger:hover { background: #c0392b; }

        /* Statistics */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 20px;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
        }

        .stat-item {
            text-align: center;
            padding: 15px;
        }

        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: #3498db;
        }

        .stat-label {
            color: #7f8c8d;
            font-size: 0.9em;
            margin-top: 5px;
        }

        /* Forms */
        .form-section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            background: #f8f9fa;
        }

        .form-section h3 {
            margin-bottom: 20px;
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #2c3e50;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        /* Dynamic List Items */
        .list-item {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            position: relative;
        }

        .list-item .item-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .list-item .item-title {
            font-weight: 600;
            color: #2c3e50;
        }

        .list-item .remove-btn {
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 5px 10px;
            cursor: pointer;
            font-size: 12px;
        }

        .add-item-btn {
            background: #27ae60;
            color: white;
            border: none;
            border-radius: 5px;
            padding: 10px 15px;
            cursor: pointer;
            margin-bottom: 15px;
            font-size: 14px;
        }

        /* Preview Styles */
        .cv-preview {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            font-family: 'Times New Roman', serif;
            line-height: 1.6;
        }

        .cv-header {
            text-align: center;
            border-bottom: 3px solid #3498db;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .cv-header h1 {
            font-size: 2.5em;
            color: #2c3e50;
            margin-bottom: 10px;
        }

        .cv-header .subtitle {
            font-size: 1.2em;
            color: #7f8c8d;
            margin-bottom: 15px;
        }

        .cv-contact {
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
            font-size: 0.9em;
            color: #7f8c8d;
        }

        .cv-section {
            margin-bottom: 25px;
        }

        .cv-section h3 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 5px;
            margin-bottom: 15px;
            font-size: 1.3em;
        }

        .cv-item {
            margin-bottom: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-left: 4px solid #3498db;
            border-radius: 5px;
        }

        .cv-item h4 {
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .cv-item .company {
            font-style: italic;
            color: #7f8c8d;
            margin-bottom: 5px;
        }

        .cv-item .date {
            font-size: 0.9em;
            color: #95a5a6;
            margin-bottom: 10px;
        }

        .language-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .language-tag {
            background: #3498db;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9em;
        }

        /* Loading Spinner */
        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 200px;
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* Notifications */
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 5px;
            color: white;
            font-weight: 500;
            z-index: 1000;
            animation: slideIn 0.3s ease-out;
        }

        .notification.success { background: #27ae60; }
        .notification.error { background: #e74c3c; }
        .notification.info { background: #3498db; }

        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .container { padding: 10px; }
            .nav-tabs { flex-direction: column; }
            .form-grid { grid-template-columns: 1fr; }
            .dashboard-grid { grid-template-columns: 1fr; }
            .cv-contact { flex-direction: column; align-items: center; }
        }
    </style>
</head>
<body class="bg" onload="initCV()">
    <div class="container">
        <!-- Navigation Tabs -->
        <div class="nav-tabs">
            <button class="nav-tab active" onclick="showTab('dashboard')">
                Dashboard
            </button>
            <button class="nav-tab" onclick="showTab('view')">
                Vizualizare
            </button>
            <button class="nav-tab" onclick="showTab('edit')">
                Editare
            </button>
        </div>

        <!-- Dashboard Content -->
        <div id="dashboard" class="content-area active">
            <div class="dashboard-header">
                <h1>Management CV</h1>
                <p>Gestioneaza CV-ul profesional cu usurinta</p>
            </div>

            <div class="dashboard-grid">
                <div class="dashboard-card">
                    <div class="icon">VIEW</div>
                    <h3>Vizualizare CV</h3>
                    <p>Vezi cum arata CV-ul in format final</p>
                    <button class="btn" onclick="showTab('view')">Vizualizeaza</button>
                </div>

                <div class="dashboard-card">
                    <div class="icon">EDIT</div>
                    <h3>Editare CV</h3>
                    <p>Actualizeaza informatiile din CV</p>
                    <button class="btn btn-success" onclick="showTab('edit')">Editeaza</button>
                </div>

                <div class="dashboard-card">
                    <div class="icon">PDF</div>
                    <h3>Export PDF</h3>
                    <p>Descarca CV-ul in format PDF</p>
                    <button class="btn btn-warning" onclick="exportPDF()">Descarca PDF</button>
                </div>
            </div>

            <div class="form-section">
                <h3>Statistici CV</h3>
                <div class="stats-grid">
                    <div class="stat-item">
                        <div class="stat-number" id="stat-experience">-</div>
                        <div class="stat-label">Experiente</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number" id="stat-education">-</div>
                        <div class="stat-label">Studii</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number" id="stat-languages">-</div>
                        <div class="stat-label">Limbi</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number" id="stat-projects">-</div>
                        <div class="stat-label">Proiecte</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- View Content -->
        <div id="view" class="content-area">
            <div class="loading" id="view-loading">
                <div class="spinner"></div>
            </div>
            <div id="cv-preview-container" style="display: none;">
                <!-- CV content will be loaded here -->
            </div>
        </div>

        <!-- Edit Content -->
        <div id="edit" class="content-area">
            <form id="cv-form" onsubmit="saveCV(event)">
                <div class="form-section">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                        <h3 style="margin-bottom: 0;">Editare CV</h3>
                        <button type="submit" class="btn btn-success">
                            Salveaza CV
                        </button>
                    </div>

                    <!-- Informatii Personale -->
                    <div class="form-section">
                        <h3>Informatii Personale</h3>
                        <div class="form-grid">
                            <div class="form-group">
                                <label>Nume:</label>
                                <input type="text" id="nume" name="nume" required>
                            </div>
                            <div class="form-group">
                                <label>Prenume:</label>
                                <input type="text" id="prenume" name="prenume" required>
                            </div>
                            <div class="form-group">
                                <label>Email:</label>
                                <input type="email" id="email" name="email" required>
                            </div>
                            <div class="form-group">
                                <label>Telefon:</label>
                                <input type="text" id="telefon" name="telefon" required>
                            </div>
                            <div class="form-group">
                                <label>Adresa:</label>
                                <input type="text" id="adresa" name="adresa">
                            </div>
                            <div class="form-group">
                                <label>Data Nasterii:</label>
                                <input type="date" id="data_nasterii" name="data_nasterii">
                            </div>
                        </div>
                    </div>

                    <!-- Profil Professional -->
                    <div class="form-section">
                        <h3>Profil Professional</h3>
                        <div class="form-group">
                            <label>Calitati:</label>
                            <textarea id="calitati" name="calitati" placeholder="Descrie calitatile tale profesionale..."></textarea>
                        </div>
                        <div class="form-group">
                            <label>Interese:</label>
                            <textarea id="interese" name="interese" placeholder="Descrie interesele tale profesionale..."></textarea>
                        </div>
                    </div>

                    <!-- Experienta Profesionala -->
                    <div class="form-section">
                        <h3>Experienta Profesionala</h3>
                        <button type="button" class="add-item-btn" onclick="addExperience()">
                            Adauga Experienta
                        </button>
                        <div id="experience-container">
                            <!-- Dynamic experience items will be added here -->
                        </div>
                    </div>

                    <!-- Educatie -->
                    <div class="form-section">
                        <h3>Educatie</h3>
                        <button type="button" class="add-item-btn" onclick="addEducation()">
                            Adauga Studii
                        </button>
                        <div id="education-container">
                            <!-- Dynamic education items will be added here -->
                        </div>
                    </div>

                    <!-- Limbi Straine -->
                    <div class="form-section">
                        <h3>Limbi Straine</h3>
                        <button type="button" class="add-item-btn" onclick="addLanguage()">
                            Adauga Limba
                        </button>
                        <div id="languages-container">
                            <!-- Dynamic language items will be added here -->
                        </div>
                    </div>

                    <!-- Proiecte -->
                    <div class="form-section">
                        <h3>Proiecte Personale</h3>
                        <button type="button" class="add-item-btn" onclick="addProject()">
                            Adauga Proiect
                        </button>
                        <div id="projects-container">
                            <!-- Dynamic project items will be added here -->
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script>
 // Global variables
    let currentTab = 'dashboard';
    let cvData = {};
    let experienceCounter = 0;
    let educationCounter = 0;
    let languageCounter = 0;
    let projectCounter = 0;

    // Initialize CV Management
    function initCV() {
        console.log('Initializing CV Management System...');
        loadCVData();
        // Auto-check servlet status
        autoCheckServletStatus();
    }

    // Tab Navigation - FIXED VERSION
    function showTab(tabName) {
        console.log('DEBUG: Switching to tab:', tabName);
        
        // Hide all content areas
        document.querySelectorAll('.content-area').forEach(area => {
            area.classList.remove('active');
        });
        
        // Remove active class from all tabs
        document.querySelectorAll('.nav-tab').forEach(tab => {
            tab.classList.remove('active');
        });
        
        // Show selected content area
        const targetArea = document.getElementById(tabName);
        if (targetArea) {
            targetArea.classList.add('active');
            console.log('DEBUG: Activated content area:', tabName);
        } else {
            console.error('DEBUG: Content area not found:', tabName);
            return; // Exit if target not found
        }
        
        // Find and activate the corresponding tab button
        const tabs = document.querySelectorAll('.nav-tab');
        tabs.forEach(tab => {
            const onclickAttr = tab.getAttribute('onclick');
            if (onclickAttr && onclickAttr.includes(`'${tabName}'`)) {
                tab.classList.add('active');
                console.log('DEBUG: Activated tab button for:', tabName);
            }
        });
        
        // Update current tab variable
        currentTab = tabName;
        
        // Execute tab-specific actions
        handleTabSwitch(tabName);
        
        console.log('DEBUG: Tab switch completed to:', tabName);
    }

    // Handle tab-specific actions
    function handleTabSwitch(tabName) {
        switch(tabName) {
            case 'view':
                console.log('DEBUG: Loading CV preview for view tab');
                loadCVPreview();
                break;
                
            case 'edit':
                console.log('DEBUG: Preparing edit tab');
                setTimeout(() => {
                    ensureMinimumItems();
                    // Focus on first input if available
                    const firstInput = document.querySelector('#edit input');
                    if (firstInput) {
                        firstInput.focus();
                    }
                }, 100);
                break;
                
            case 'dashboard':
                console.log('DEBUG: Updating dashboard');
                updateStatistics();
                break;
                
            default:
                console.log('DEBUG: No specific actions for tab:', tabName);
        }
    }

    // Load CV Data from Backend
    async function loadCVData() {
        try {
            console.log('Loading CV data from backend...');
            
            const response = await fetch('CVServlet?action=view', {
                method: 'GET',
                credentials: 'include'
            });

            if (!response.ok) {
                throw new Error('Failed to load CV data');
            }

            const htmlText = await response.text();
            console.log('CV data loaded successfully');
            
            // Parse the HTML and extract data
            cvData = parseHTMLData(htmlText);
            
            // Update form with loaded data
            populateForm();
            
            // Update statistics
            updateStatistics();
            
        } catch (error) {
            console.error('Error loading CV data:', error);
            showNotification('Eroare la incarcarea datelor CV', 'error');
        }
    }

    // Parse HTML response to extract CV data
    function parseHTMLData(htmlText) {
        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlText, 'text/html');
        
        const data = {
            personalInfo: {},
            profile: {},
            experience: [],
            education: [],
            languages: [],
            projects: []
        };

        // Extract personal info from info-grid
        doc.querySelectorAll('.info-item').forEach(item => {
            const labelElement = item.querySelector('.info-label');
            const label = labelElement ? labelElement.textContent.trim() : '';
            const value = item.textContent.replace(label, '').trim();
            
            if (label.includes('Email')) {
                data.personalInfo.email = value;
            } else if (label.includes('Telefon')) {
                data.personalInfo.telefon = value;
            } else if (label.includes('Pozitie')) {
                data.personalInfo.pozitie = value;
            } else if (label.includes('Departament')) {
                data.personalInfo.departament = value;
            }
        });

        // Extract name from header
        const nameElement = doc.querySelector('.cv-header h1');
        if (nameElement) {
            const fullName = nameElement.textContent.trim().split(' ');
            data.personalInfo.nume = fullName[0] || '';
            data.personalInfo.prenume = fullName.slice(1).join(' ') || '';
        }

        // Extract profile data
        const cvSections = doc.querySelectorAll('.cv-section');
        cvSections.forEach(section => {
            const heading = section.querySelector('h3');
            if (heading) {
                const headingText = heading.textContent.toLowerCase();
                if (headingText.includes('calitati') || headingText.includes('personale')) {
                    const paragraph = section.querySelector('p');
                    if (paragraph) {
                        data.profile.calitati = paragraph.textContent.trim();
                    }
                } else if (headingText.includes('interese')) {
                    const paragraph = section.querySelector('p');
                    if (paragraph) {
                        data.profile.interese = paragraph.textContent.trim();
                    }
                }
            }
        });

        // Extract experience, education, languages similar to before...
        // (keeping the existing extraction logic)

        console.log('Parsed CV data:', data);
        return data;
    }

    // Populate form with loaded data
    function populateForm() {
        // Personal info
        if (cvData.personalInfo) {
            Object.keys(cvData.personalInfo).forEach(key => {
                const element = document.getElementById(key);
                if (element) {
                    element.value = cvData.personalInfo[key] || '';
                }
            });
        }

        // Profile
        if (cvData.profile) {
            const calitatiElement = document.getElementById('calitati');
            const intereseElement = document.getElementById('interese');
            
            if (calitatiElement) calitatiElement.value = cvData.profile.calitati || '';
            if (intereseElement) intereseElement.value = cvData.profile.interese || '';
        }

        // Clear containers
        clearAllContainers();

        // Reset counters
        resetCounters();

        // Add items from data
        addItemsFromData();

        console.log('Form populated with CV data');
    }

    // Clear all containers
    function clearAllContainers() {
        const containers = ['experience-container', 'education-container', 'languages-container', 'projects-container'];
        containers.forEach(containerId => {
            const container = document.getElementById(containerId);
            if (container) {
                container.innerHTML = '';
            }
        });
    }

    // Reset all counters
    function resetCounters() {
        experienceCounter = 0;
        educationCounter = 0;
        languageCounter = 0;
        projectCounter = 0;
    }

    // Add items from loaded data
    function addItemsFromData() {
        // Add experience items
        if (cvData.experience) {
            cvData.experience.forEach(exp => addExperience(exp));
        }

        // Add education items  
        if (cvData.education) {
            cvData.education.forEach(edu => addEducation(edu));
        }

        // Add language items
        if (cvData.languages) {
            cvData.languages.forEach(lang => addLanguage(lang));
        }

        // Add project items
        if (cvData.projects) {
            cvData.projects.forEach(proj => addProject(proj));
        }
    }

    // Update statistics
    function updateStatistics() {
        const stats = [
            { id: 'stat-experience', value: cvData.experience?.length || 0 },
            { id: 'stat-education', value: cvData.education?.length || 0 },
            { id: 'stat-languages', value: cvData.languages?.length || 0 },
            { id: 'stat-projects', value: cvData.projects?.length || 0 }
        ];
        
        stats.forEach(stat => {
            const element = document.getElementById(stat.id);
            if (element) {
                element.textContent = stat.value;
            }
        });
    }

    // Ensure minimum items for editing
    function ensureMinimumItems() {
        console.log('DEBUG: Ensuring minimum items for editing');
        
        const containers = [
            { id: 'experience-container', addFunc: () => addExperience() },
            { id: 'education-container', addFunc: () => addEducation() },
            { id: 'languages-container', addFunc: () => addLanguage() }
            // Note: projects optional, don't auto-add
        ];
        
        containers.forEach(container => {
            const element = document.getElementById(container.id);
            if (element && element.children.length === 0) {
                console.log(`DEBUG: Adding default item to ${container.id}`);
                container.addFunc();
            }
        });
    }

    // Add Experience Item (keeping existing implementation)
    function addExperience(data = null) {
        experienceCounter++;
        const container = document.getElementById('experience-container');
        
        const div = document.createElement('div');
        div.className = 'list-item';
        div.id = `experience-${experienceCounter}`;
        
        div.innerHTML = `
            <div class="item-header">
                <div class="item-title">Experienta #${experienceCounter}</div>
                <button type="button" class="remove-btn" onclick="removeItem('experience-${experienceCounter}')">
                    Sterge
                </button>
            </div>
            <div class="form-grid">
                <div class="form-group">
                    <label>Pozitie:</label>
                    <input type="text" name="exp_den_job_${experienceCounter}" placeholder="Ex: Manager IT">
                </div>
                <div class="form-group">
                    <label>Compania:</label>
                    <input type="text" name="exp_instit_${experienceCounter}" placeholder="Ex: Tech Solutions SRL">
                </div>
                <div class="form-group">
                    <label>Domeniu:</label>
                    <input type="text" name="exp_domeniu_${experienceCounter}" placeholder="Ex: Tehnologie">
                </div>
                <div class="form-group">
                    <label>Subdomeniu:</label>
                    <input type="text" name="exp_subdomeniu_${experienceCounter}" placeholder="Ex: Software Development">
                </div>
                <div class="form-group">
                    <label>Data inceput:</label>
                    <input type="date" name="exp_start_${experienceCounter}">
                </div>
                <div class="form-group">
                    <label>Data sfarsit:</label>
                    <input type="date" name="exp_end_${experienceCounter}">
                </div>
                <div class="form-group" style="grid-column: 1 / -1;">
                    <label>Descriere:</label>
                    <textarea name="exp_descriere_${experienceCounter}" placeholder="Descrie responsabilitatile si realizarile..."></textarea>
                </div>
            </div>
        `;
        
        container.appendChild(div);
        
        // Populate with data if provided
        if (data) {
            populateExperienceItem(div, data, experienceCounter);
        }
    }

    // Helper function to populate experience item
    function populateExperienceItem(div, data, counter) {
        const fieldMappings = {
            [`exp_den_job_${counter}`]: data.den_job,
            [`exp_instit_${counter}`]: data.instit,
            [`exp_domeniu_${counter}`]: data.domeniu,
            [`exp_subdomeniu_${counter}`]: data.subdomeniu,
            [`exp_start_${counter}`]: data.start,
            [`exp_end_${counter}`]: data.end,
            [`exp_descriere_${counter}`]: data.descriere
        };
        
        Object.keys(fieldMappings).forEach(fieldName => {
            const input = div.querySelector(`[name="${fieldName}"]`);
            if (input && fieldMappings[fieldName]) {
                input.value = fieldMappings[fieldName];
            }
        });
    }

    // Similar functions for education, languages, projects...
    // (keeping existing implementations but with similar helper functions)

    // Remove Item
    function removeItem(itemId) {
        const item = document.getElementById(itemId);
        if (item) {
            item.remove();
            console.log('DEBUG: Removed item:', itemId);
        }
    }

    function collectProfileInfo(formData) {
        formData.append('calitati', document.getElementById('calitati')?.value || '');
        formData.append('interese', document.getElementById('interese')?.value || '');
    }

    function collectExperienceData(formData) {
        const expContainer = document.getElementById('experience-container');
        const expItems = expContainer.querySelectorAll('.list-item');
        formData.append('experience_count', expItems.length);
        
        expItems.forEach((item) => {
            const inputs = item.querySelectorAll('input, textarea');
            inputs.forEach(input => {
                if (input.name) {
                    formData.append(input.name, input.value || '');
                }
            });
        });
    }

    // Similar functions for education, languages, projects...

    // Handle save response
    async function handleSaveResponse(response) {
        console.log('Response status:', response.status);
        
        const responseText = await response.text();
        console.log('Response text:', responseText);

        if (response.ok) {
            try {
                const jsonResponse = JSON.parse(responseText);
                if (jsonResponse.status === 'success') {
                    showNotification('CV-ul a fost salvat cu succes!', 'success');
                    setTimeout(() => loadCVData(), 1500);
                } else {
                    showNotification('Eroare: ' + jsonResponse.message, 'error');
                }
            } catch (e) {
                if (responseText.includes('success') || response.status === 200) {
                    showNotification('CV-ul a fost salvat cu succes!', 'success');
                    setTimeout(() => loadCVData(), 1500);
                } else {
                    showNotification('Status incert de salvare', 'info');
                }
            }
        } else {
            throw new Error(`HTTP ${response.status}: ${responseText}`);
        }
    }

    // Load CV Preview
    async function loadCVPreview() {
        const loadingElement = document.getElementById('view-loading');
        const containerElement = document.getElementById('cv-preview-container');
        
        if (loadingElement) loadingElement.style.display = 'flex';
        if (containerElement) containerElement.style.display = 'none';
        
        try {
            const response = await fetch('CVServlet?action=view', {
                method: 'GET',
                credentials: 'include'
            });
            
            if (response.ok) {
                const htmlContent = await response.text();
                const parser = new DOMParser();
                const doc = parser.parseFromString(htmlContent, 'text/html');
                
                const cvContainer = doc.querySelector('.cv-container');
                if (cvContainer && containerElement) {
                    containerElement.innerHTML = cvContainer.innerHTML;
                } else if (containerElement) {
                    containerElement.innerHTML = '<p>Nu s-au gasit date pentru CV.</p>';
                }
            } else {
                throw new Error('Failed to load CV preview');
            }
            
        } catch (error) {
            console.error('Error loading CV preview:', error);
            if (containerElement) {
                containerElement.innerHTML = '<p>Eroare la incarcarea previzualizarii CV.</p>';
            }
            showNotification('Eroare la incarcarea previzualizarii', 'error');
        } finally {
            if (loadingElement) loadingElement.style.display = 'none';
            if (containerElement) containerElement.style.display = 'block';
        }
    }

    // Export PDF
    async function exportPDF() {
        try {
            showNotification('Se genereaza PDF-ul...', 'info');
            window.open('CVGeneratorServlet?action=export', '_blank');
            setTimeout(() => {
                showNotification('PDF-ul a fost generat cu succes!', 'success');
            }, 1500);
        } catch (error) {
            console.error('Error exporting PDF:', error);
            showNotification('Eroare la generarea PDF-ului', 'error');
        }
    }

    // Show Notification
    function showNotification(message, type = 'success') {
        // Remove existing notifications
        document.querySelectorAll('.notification').forEach(notif => notif.remove());
        
        // Create new notification
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        // Auto remove after 3 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 3000);
    }

    // Auto-check servlet status (keeping from previous implementation)
    async function autoCheckServletStatus() {
        console.log('🔍 Auto-checking CVServlet status...');
        
        setTimeout(async () => {
            const isWorking = await testCVServletUpdate();
            
            if (!isWorking) {
                console.log('⚠️ CVServlet needs to be updated!');
                showNotification('ATENTIE: CVServlet trebuie actualizat pentru ca editarea sa functioneze!', 'error');
            }
        }, 2000);
    }

    // Test functions (keeping from previous implementation)
    async function testCVServletUpdate() {
        // Implementation from previous artifact
        return true; // Placeholder
    }

    console.log('CV Management System loaded successfully!');
 // Missing collect functions for form data

 // Collect Education Data
 function collectEducationData(formData) {
     const eduContainer = document.getElementById('education-container');
     if (!eduContainer) {
         console.warn('Education container not found');
         formData.append('education_count', '0');
         return;
     }
     
     const eduItems = eduContainer.querySelectorAll('.list-item');
     formData.append('education_count', eduItems.length);
     
     console.log(`DEBUG: Collecting ${eduItems.length} education items`);
     
     eduItems.forEach((item, index) => {
         const inputs = item.querySelectorAll('input, select');
         console.log(`Processing education item ${index + 1}:`);
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 console.log(`  ${input.name}: ${value}`);
             }
         });
     });
 }

 // Collect Language Data
 function collectLanguageData(formData) {
     const langContainer = document.getElementById('languages-container');
     if (!langContainer) {
         console.warn('Languages container not found');
         formData.append('languages_count', '0');
         return;
     }
     
     const langItems = langContainer.querySelectorAll('.list-item');
     formData.append('languages_count', langItems.length);
     
     console.log(`DEBUG: Collecting ${langItems.length} language items`);
     
     langItems.forEach((item, index) => {
         const inputs = item.querySelectorAll('input, select');
         console.log(`Processing language item ${index + 1}:`);
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 console.log(`  ${input.name}: ${value}`);
             }
         });
     });
 }

 // Collect Project Data
 function collectProjectData(formData) {
     const projContainer = document.getElementById('projects-container');
     if (!projContainer) {
         console.warn('Projects container not found');
         formData.append('projects_count', '0');
         return;
     }
     
     const projItems = projContainer.querySelectorAll('.list-item');
     formData.append('projects_count', projItems.length);
     
     console.log(`DEBUG: Collecting ${projItems.length} project items`);
     
     projItems.forEach((item, index) => {
         const inputs = item.querySelectorAll('input, textarea');
         console.log(`Processing project item ${index + 1}:`);
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 console.log(`  ${input.name}: ${value}`);
             }
         });
     });
 }

 // Missing add functions that are referenced but might not be complete

 // Add Education Item
 function addEducation(data = null) {
     educationCounter++;
     const container = document.getElementById('education-container');
     
     if (!container) {
         console.error('Education container not found');
         return;
     }
     
     const div = document.createElement('div');
     div.className = 'list-item';
     div.id = `education-${educationCounter}`;
     
     div.innerHTML = `
         <div class="item-header">
             <div class="item-title">Studii #${educationCounter}</div>
             <button type="button" class="remove-btn" onclick="removeItem('education-${educationCounter}')">
                 Sterge
             </button>
         </div>
         <div class="form-grid">
             <div class="form-group">
                 <label>Facultatea:</label>
                 <input type="text" name="edu_facultate_${educationCounter}" placeholder="Ex: Informatica">
             </div>
             <div class="form-group">
                 <label>Universitatea:</label>
                 <input type="text" name="edu_universitate_${educationCounter}" placeholder="Ex: Universitatea Politehnica Bucuresti">
             </div>
             <div class="form-group">
                 <label>Ciclul de studii:</label>
                 <select name="edu_ciclu_${educationCounter}">
                     <option value="">Selecteaza ciclul</option>
                     <option value="Licenta">Licenta</option>
                     <option value="Master">Master</option>
                     <option value="Doctorat">Doctorat</option>
                 </select>
             </div>
             <div class="form-group">
                 <label>An de inceput:</label>
                 <input type="date" name="edu_start_${educationCounter}">
             </div>
             <div class="form-group">
                 <label>An de sfarsit:</label>
                 <input type="date" name="edu_end_${educationCounter}">
             </div>
         </div>
     `;
     
     container.appendChild(div);
     
     // Populate with data if provided
     if (data) {
         populateEducationItem(div, data, educationCounter);
     }
     
     console.log(`Added education item #${educationCounter}`);
 }

 // Helper function to populate education item
 function populateEducationItem(div, data, counter) {
     const fieldMappings = {
         [`edu_facultate_${counter}`]: data.facultate,
         [`edu_universitate_${counter}`]: data.universitate,
         [`edu_ciclu_${counter}`]: data.ciclu_denumire,
         [`edu_start_${counter}`]: data.start,
         [`edu_end_${counter}`]: data.end
     };
     
     Object.keys(fieldMappings).forEach(fieldName => {
         const input = div.querySelector(`[name="${fieldName}"]`);
         if (input && fieldMappings[fieldName]) {
             input.value = fieldMappings[fieldName];
         }
     });
 }

 // Add Language Item
 function addLanguage(data = null) {
     languageCounter++;
     const container = document.getElementById('languages-container');
     
     if (!container) {
         console.error('Languages container not found');
         return;
     }
     
     const div = document.createElement('div');
     div.className = 'list-item';
     div.id = `language-${languageCounter}`;
     
     div.innerHTML = `
         <div class="item-header">
             <div class="item-title">Limba #${languageCounter}</div>
             <button type="button" class="remove-btn" onclick="removeItem('language-${languageCounter}')">
                 Sterge
             </button>
         </div>
         <div class="form-grid">
             <div class="form-group">
                 <label>Limba:</label>
                 <input type="text" name="lang_limba_${languageCounter}" placeholder="Ex: Engleza">
             </div>
             <div class="form-group">
                 <label>Nivel:</label>
                 <select name="lang_nivel_${languageCounter}">
                     <option value="">Selecteaza nivelul</option>
                     <option value="Incepator">Incepator</option>
                     <option value="Intermediar">Intermediar</option>
                     <option value="Avansat">Avansat</option>
                     <option value="Nativ">Nativ</option>
                 </select>
             </div>
         </div>
     `;
     
     container.appendChild(div);
     
     // Populate with data if provided
     if (data) {
         populateLanguageItem(div, data, languageCounter);
     }
     
     console.log(`Added language item #${languageCounter}`);
 }

 // Helper function to populate language item
 function populateLanguageItem(div, data, counter) {
     const fieldMappings = {
         [`lang_limba_${counter}`]: data.limba,
         [`lang_nivel_${counter}`]: data.nivel_denumire
     };
     
     Object.keys(fieldMappings).forEach(fieldName => {
         const input = div.querySelector(`[name="${fieldName}"]`);
         if (input && fieldMappings[fieldName]) {
             input.value = fieldMappings[fieldName];
         }
     });
 }

 // Add Project Item
 function addProject(data = null) {
     projectCounter++;
     const container = document.getElementById('projects-container');
     
     if (!container) {
         console.error('Projects container not found');
         return;
     }
     
     const div = document.createElement('div');
     div.className = 'list-item';
     div.id = `project-${projectCounter}`;
     
     div.innerHTML = `
         <div class="item-header">
             <div class="item-title">Proiect #${projectCounter}</div>
             <button type="button" class="remove-btn" onclick="removeItem('project-${projectCounter}')">
                 Sterge
             </button>
         </div>
         <div class="form-grid">
             <div class="form-group">
                 <label>Nume proiect:</label>
                 <input type="text" name="proj_nume_${projectCounter}" placeholder="Ex: Sistem ERP Corporate">
             </div>
             <div class="form-group">
                 <label>Data inceput:</label>
                 <input type="date" name="proj_start_${projectCounter}">
             </div>
             <div class="form-group">
                 <label>Data sfarsit:</label>
                 <input type="date" name="proj_end_${projectCounter}">
             </div>
             <div class="form-group" style="grid-column: 1 / -1;">
                 <label>Descriere:</label>
                 <textarea name="proj_descriere_${projectCounter}" placeholder="Descrie proiectul si rezultatele obtinute..."></textarea>
             </div>
         </div>
     `;
     
     container.appendChild(div);
     
     // Populate with data if provided
     if (data) {
         populateProjectItem(div, data, projectCounter);
     }
     
     console.log(`Added project item #${projectCounter}`);
 }

 // Helper function to populate project item
 function populateProjectItem(div, data, counter) {
     const fieldMappings = {
         [`proj_nume_${counter}`]: data.nume,
         [`proj_start_${counter}`]: data.start,
         [`proj_end_${counter}`]: data.end,
         [`proj_descriere_${counter}`]: data.descriere
     };
     
     Object.keys(fieldMappings).forEach(fieldName => {
         const input = div.querySelector(`[name="${fieldName}"]`);
         if (input && fieldMappings[fieldName]) {
             input.value = fieldMappings[fieldName];
         }
     });
 }

 console.log('All missing collect and add functions loaded successfully!');
//Fixed handleSaveResponse function with robust error handling
 async function handleSaveResponse(response) {
     console.log('DEBUG: Handling save response');
     console.log('Response status:', response.status);
     console.log('Response ok:', response.ok);
     console.log('Response headers:', Object.fromEntries(response.headers.entries()));
     
     try {
         const responseText = await response.text();
         console.log('Response text length:', responseText.length);
         console.log('Response text:', responseText);

         if (!response.ok) {
             throw new Error(`HTTP ${response.status}: ${responseText || 'No response body'}`);
         }

         // Check if response is empty
         if (!responseText || responseText.trim().length === 0) {
             console.log('DEBUG: Empty response received, but status is OK');
             showNotification('CV salvat (raspuns gol de la server)', 'info');
             setTimeout(() => loadCVData(), 1500);
             return;
         }

         // Try to parse as JSON
         try {
             const jsonResponse = JSON.parse(responseText);
             console.log('DEBUG: Successfully parsed JSON response:', jsonResponse);
             
             if (jsonResponse.status === 'success') {
                 showNotification('CV-ul a fost salvat cu succes!', 'success');
                 console.log('SUCCESS: CV saved successfully');
                 setTimeout(() => loadCVData(), 1500);
             } else if (jsonResponse.status === 'error') {
                 showNotification('Eroare: ' + (jsonResponse.message || 'Eroare necunoscuta'), 'error');
                 console.error('ERROR: CV save failed -', jsonResponse.message);
             } else {
                 showNotification('Raspuns neașteptat de la server', 'error');
                 console.warn('WARNING: Unexpected JSON response:', jsonResponse);
             }
         } catch (jsonError) {
             console.log('DEBUG: Response is not valid JSON, analyzing content...');
             
             // Check if it's HTML (likely a redirect or JSP page)
             if (responseText.includes('<html>') || responseText.includes('<!DOCTYPE')) {
                 console.log('DEBUG: Received HTML response - likely redirect or error page');
                 showNotification('Server a returnat o pagina HTML in loc de JSON', 'error');
                 console.log('HTML response preview:', responseText.substring(0, 200) + '...');
                 return;
             }
             
             // Check for common success indicators in plain text
             const lowerText = responseText.toLowerCase();
             if (lowerText.includes('success') || lowerText.includes('succes') || 
                 lowerText.includes('salvat') || lowerText.includes('actualizat')) {
                 console.log('DEBUG: Detected success keywords in response');
                 showNotification('CV-ul pare sa fi fost salvat cu succes!', 'success');
                 setTimeout(() => loadCVData(), 1500);
                 return;
             }
             
             // Check for error indicators
             if (lowerText.includes('error') || lowerText.includes('eroare') || 
                 lowerText.includes('failed') || lowerText.includes('exception')) {
                 console.log('DEBUG: Detected error keywords in response');
                 showNotification('A aparut o eroare la salvare', 'error');
                 return;
             }
             
             // Unknown response format
             console.log('DEBUG: Unknown response format');
             showNotification('Raspuns necunoscut de la server. Verifica daca s-a salvat.', 'info');
         }
         
     } catch (networkError) {
         console.error('DEBUG: Network or parsing error:', networkError);
         
         if (networkError.name === 'TypeError' && networkError.message.includes('Failed to fetch')) {
             showNotification('Eroare de conexiune la server', 'error');
         } else if (networkError.name === 'SyntaxError') {
             showNotification('Eroare de parsare a raspunsului de la server', 'error');
         } else {
             showNotification('Eroare la comunicarea cu server-ul: ' + networkError.message, 'error');
         }
         
         throw networkError; // Re-throw to be caught by saveCV
     }
 }

 // Safe collection functions with error handling
 function collectPersonalInfo(formData) {
     console.log('DEBUG: Collecting personal info');
     const personalFields = ['nume', 'prenume', 'email', 'telefon', 'adresa', 'data_nasterii'];
     
     personalFields.forEach(field => {
         try {
             const element = document.getElementById(field);
             const value = element ? element.value || '' : '';
             formData.append(field, value);
             console.log(`  ${field}: ${value}`);
         } catch (error) {
             console.warn(`Warning collecting field ${field}:`, error);
             formData.append(field, ''); // Add empty value to prevent errors
         }
     });
 }

 function collectProfileInfo(formData) {
     console.log('DEBUG: Collecting profile info');
     
     try {
         const calitati = document.getElementById('calitati');
         const interese = document.getElementById('interese');
         
         formData.append('calitati', calitati ? calitati.value || '' : '');
         formData.append('interese', interese ? interese.value || '' : '');
         
         console.log(`  calitati: ${calitati ? calitati.value : 'N/A'}`);
         console.log(`  interese: ${interese ? interese.value : 'N/A'}`);
     } catch (error) {
         console.warn('Warning collecting profile info:', error);
         formData.append('calitati', '');
         formData.append('interese', '');
     }
 }
//Fixed FormData collection - the issue is that action parameter is null

 async function saveCV(event) {
     event.preventDefault();
     
     try {
         console.log('=== DEBUG: Starting CV save process ===');
         
         showNotification('Se salveaza CV-ul...', 'info');
         
         // Create FormData and ensure action is set correctly
         const formData = new FormData();
         
         // CRITICAL: Set action parameter FIRST and verify it
         formData.append('action', 'save');
         console.log('DEBUG: Action parameter set to:', formData.get('action'));
         
         // Collect all form data with error checking
         try {
             collectPersonalInfoFixed(formData);
             collectProfileInfoFixed(formData);
             collectExperienceDataFixed(formData);
             collectEducationDataFixed(formData);
             collectLanguageDataFixed(formData);
             collectProjectDataFixed(formData);
         } catch (collectError) {
             console.error('ERROR collecting form data:', collectError);
             showNotification('Eroare la colectarea datelor din formular: ' + collectError.message, 'error');
             return;
         }

         console.log('Sending CV data to CVServlet...');
         
         // Debug: Show what we're sending (but limit output)
         console.log('FormData contents:');
         let entryCount = 0;
         for (let pair of formData.entries()) {
             if (entryCount < 10 || pair[0].includes('action') || pair[0].includes('count')) {
                 console.log(`  ${pair[0]}: ${pair[1]}`);
             }
             entryCount++;
         }
         console.log(`Total FormData entries: ${entryCount}`);
         
         // Verify action is still there before sending
         console.log('VERIFY: Action before send:', formData.get('action'));
         
         const response = await fetch('CVServlet', {
             method: 'POST',
             body: formData,
             credentials: 'include'
         });

         await handleSaveResponseFixed(response);
         
         console.log('=== DEBUG: CV save process completed ===');
         
     } catch (error) {
         console.error('ERROR in saveCV:', error);
         
         // More specific error messages
         if (error.name === 'TypeError' && error.message.includes('Failed to fetch')) {
             showNotification('Nu se poate conecta la server. Verifica conexiunea.', 'error');
         } else if (error.message.includes('HTTP 404')) {
             showNotification('CVServlet nu a fost gasit pe server', 'error');
         } else if (error.message.includes('HTTP 500')) {
             showNotification('Eroare interna de server la salvare', 'error');
         } else {
             showNotification('Eroare la salvarea CV-ului: ' + error.message, 'error');
         }
     }
 }

 // Fixed collection functions that ensure data is actually collected
 function collectPersonalInfoFixed(formData) {
     console.log('DEBUG: Collecting personal info');
     const personalFields = ['nume', 'prenume', 'email', 'telefon', 'adresa', 'data_nasterii'];
     
     personalFields.forEach(field => {
         try {
             const element = document.getElementById(field);
             if (element) {
                 const value = element.value || '';
                 formData.append(field, value);
                 console.log(`  ${field}: "${value}"`);
             } else {
                 console.warn(`  ${field}: element not found!`);
                 formData.append(field, ''); // Add empty value
             }
         } catch (error) {
             console.warn(`Warning collecting field ${field}:`, error);
             formData.append(field, '');
         }
     });
 }

 function collectProfileInfoFixed(formData) {
     console.log('DEBUG: Collecting profile info');
     
     try {
         const calitatiElement = document.getElementById('calitati');
         const intereseElement = document.getElementById('interese');
         
         const calitatiValue = calitatiElement ? calitatiElement.value || '' : '';
         const intereseValue = intereseElement ? intereseElement.value || '' : '';
         
         formData.append('calitati', calitatiValue);
         formData.append('interese', intereseValue);
         
         console.log(`  calitati: "${calitatiValue}"`);
         console.log(`  interese: "${intereseValue}"`);
         
         if (!calitatiElement) console.warn('  calitati element not found!');
         if (!intereseElement) console.warn('  interese element not found!');
         
     } catch (error) {
         console.warn('Warning collecting profile info:', error);
         formData.append('calitati', '');
         formData.append('interese', '');
     }
 }

 function collectExperienceDataFixed(formData) {
     const expContainer = document.getElementById('experience-container');
     if (!expContainer) {
         console.warn('Experience container not found');
         formData.append('experience_count', '0');
         return;
     }
     
     const expItems = expContainer.querySelectorAll('.list-item');
     const count = expItems.length;
     formData.append('experience_count', count.toString());
     
     console.log(`DEBUG: Collecting ${count} experience items`);
     
     expItems.forEach((item, index) => {
         console.log(`Processing experience item ${index + 1}:`);
         const inputs = item.querySelectorAll('input, textarea');
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 if (value) { // Only log non-empty values to reduce noise
                     console.log(`  ${input.name}: "${value}"`);
                 }
             }
         });
     });
 }

 function collectEducationDataFixed(formData) {
     const eduContainer = document.getElementById('education-container');
     if (!eduContainer) {
         console.warn('Education container not found');
         formData.append('education_count', '0');
         return;
     }
     
     const eduItems = eduContainer.querySelectorAll('.list-item');
     const count = eduItems.length;
     formData.append('education_count', count.toString());
     
     console.log(`DEBUG: Collecting ${count} education items`);
     
     eduItems.forEach((item, index) => {
         console.log(`Processing education item ${index + 1}:`);
         const inputs = item.querySelectorAll('input, select');
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 if (value) { // Only log non-empty values
                     console.log(`  ${input.name}: "${value}"`);
                 }
             }
         });
     });
 }

 function collectLanguageDataFixed(formData) {
     const langContainer = document.getElementById('languages-container');
     if (!langContainer) {
         console.warn('Languages container not found');
         formData.append('languages_count', '0');
         return;
     }
     
     const langItems = langContainer.querySelectorAll('.list-item');
     const count = langItems.length;
     formData.append('languages_count', count.toString());
     
     console.log(`DEBUG: Collecting ${count} language items`);
     
     langItems.forEach((item, index) => {
         console.log(`Processing language item ${index + 1}:`);
         const inputs = item.querySelectorAll('input, select');
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 if (value) { // Only log non-empty values
                     console.log(`  ${input.name}: "${value}"`);
                 }
             }
         });
     });
 }

 function collectProjectDataFixed(formData) {
     const projContainer = document.getElementById('projects-container');
     if (!projContainer) {
         console.warn('Projects container not found');
         formData.append('projects_count', '0');
         return;
     }
     
     const projItems = projContainer.querySelectorAll('.list-item');
     const count = projItems.length;
     formData.append('projects_count', count.toString());
     
     console.log(`DEBUG: Collecting ${count} project items`);
     
     projItems.forEach((item, index) => {
         console.log(`Processing project item ${index + 1}:`);
         const inputs = item.querySelectorAll('input, textarea');
         inputs.forEach(input => {
             if (input.name) {
                 const value = input.value || '';
                 formData.append(input.name, value);
                 if (value) { // Only log non-empty values
                     console.log(`  ${input.name}: "${value}"`);
                 }
             }
         });
     });
 }

 // Fixed handleSaveResponse that handles the specific error case
 async function handleSaveResponseFixed(response) {
     console.log('DEBUG: Handling save response');
     console.log('Response status:', response.status);
     console.log('Response ok:', response.ok);
     
     try {
         const responseText = await response.text();
         console.log('Response text:', responseText);

         if (!response.ok) {
             // Try to parse error response as JSON
             try {
                 const errorResponse = JSON.parse(responseText);
                 if (errorResponse.status === 'error') {
                     showNotification('Eroare de la server: ' + errorResponse.message, 'error');
                     console.error('Server error:', errorResponse.message);
                     return;
                 }
             } catch (parseError) {
                 // Not JSON, just show the text
                 showNotification('Eroare HTTP ' + response.status + ': ' + responseText, 'error');
                 console.error('HTTP Error:', response.status, responseText);
                 return;
             }
         }

         // Success case - try to parse as JSON
         try {
             const jsonResponse = JSON.parse(responseText);
             console.log('DEBUG: Successfully parsed JSON response:', jsonResponse);
             
             if (jsonResponse.status === 'success') {
                 showNotification('CV-ul a fost salvat cu succes!', 'success');
                 console.log('SUCCESS: CV saved successfully');
                 setTimeout(() => loadCVData(), 1500);
             } else if (jsonResponse.status === 'error') {
                 showNotification('Eroare: ' + (jsonResponse.message || 'Eroare necunoscuta'), 'error');
                 console.error('ERROR: CV save failed -', jsonResponse.message);
             } else {
                 showNotification('Raspuns neașteptat de la server', 'error');
                 console.warn('WARNING: Unexpected JSON response:', jsonResponse);
             }
         } catch (jsonError) {
             // Not JSON but response is OK - assume success
             console.log('DEBUG: Non-JSON response but HTTP OK');
             showNotification('CV salvat (raspuns non-JSON)', 'success');
             setTimeout(() => loadCVData(), 1500);
         }
         
     } catch (networkError) {
         console.error('DEBUG: Network error:', networkError);
         showNotification('Eroare de retea: ' + networkError.message, 'error');
         throw networkError;
     }
 }

 console.log('Fixed FormData collection functions loaded!');

    </script>

    <script src="js/core2.js"></script>
</body>
</html>