<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

//structura unei pagini este astfel
//verificare daca exista sesiune activa, utilizator conectat, 
//extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//se mai extrag temele de culoare ale fiecarui utilizator
//apoi se incarca pagina in sine

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizatoir in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername();
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
                        int id = rs.getInt("id");
                        int userType = rs.getInt("tip");
                        int userdep = rs.getInt("id_dep");
                        String functie = rs.getString("functie");
                        if (functie.compareTo("Administrator") != 0) {   
                    	// aflu data curenta, tot ca o interogare bd =(
                    	String today = "";
                   	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                               try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                      today =  rs2.getString("today");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
                   	 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                   	 String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
                  	 String clr = "#d8d9e1";
                  	 String sidebar = "#ECEDFA";
                  	 String text = "#333";
                  	 String card = "#ECEDFA";
                  	 String hover = "#ECEDFA";
                  	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                         String query = "SELECT * from teme where id_usr = ?";
                         try (PreparedStatement stmt = connection.prepareStatement(query)) {
                             stmt.setInt(1, id);
                             try (ResultSet rs2 = stmt.executeQuery()) {
                                 if (rs2.next()) {
                                   accent =  rs2.getString("accent");
                                   clr =  rs2.getString("clr");
                                   sidebar =  rs2.getString("sidebar");
                                   text = rs2.getString("text");
                                   card =  rs2.getString("card");
                                   hover = rs2.getString("hover");
                                 }
                             }
                         }
                    } catch (SQLException e) {
                         out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                         e.printStackTrace();
                     }
                    	%>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <style>
        a, a:visited, a:hover, a:active{color:white !important}
        .suggestions-container {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin: 10px 20px;
}

.suggestion-button {
    background-color: #f1f1f1;
    border: 1px solid #ddd;
    border-radius: 18px;
    padding: 8px 16px;
    font-size: 14px;
    cursor: pointer;
    transition: background-color 0.2s, transform 0.1s;
    white-space: nowrap;
}

.suggestion-button:hover {
    background-color: #e6e6e6;
    transform: translateY(-1px);
}

.suggestion-button:active {
    transform: translateY(1px);
}

.input-container {
    display: flex;
    padding: 15px;
    border-top: 1px solid #e0e0e0;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .suggestions-container {
        justify-content: center;
    }
    
    .suggestion-button {
        font-size: 12px;
        padding: 6px 12px;
    }
}
    </style>
    
   <!--=============== icon ===============-->
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Acasa</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            color: #333;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .chat-container {
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 40px);
        }
        
        .chat-header {
            background-color: #007bff;
            color: white;
            padding: 15px 20px;
            font-weight: bold;
            font-size: 20px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
        }
        
        .message {
            margin-bottom: 15px;
            max-width: 80%;
            animation: fadeIn 0.3s;
        }
        
        .user-message {
            margin-left: auto;
            background-color: #007bff;
            color: white;
            border-radius: 18px 18px 3px 18px;
            padding: 10px 15px;
        }
        
        .bot-message {
            margin-right: auto;
            background-color: #f1f1f1;
            border-radius: 18px 18px 18px 3px;
            padding: 10px 15px;
        }
        
        .message-time {
            font-size: 12px;
            color: #888;
            margin-top: 5px;
            text-align: right;
        }
        
        .bot-typing {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            opacity: 0.8;
        }
        
        .typing-indicator {
            display: flex;
            align-items: center;
        }
        
        .typing-dot {
            height: 8px;
            width: 8px;
            background-color: #888;
            border-radius: 50%;
            margin: 0 2px;
            animation: pulse 1.5s infinite;
        }
        
        .typing-dot:nth-child(2) {
            animation-delay: 0.5s;
        }
        
        .typing-dot:nth-child(3) {
            animation-delay: 1s;
        }
        
        .chat-input {
            display: flex;
            padding: 15px;
            border-top: 1px solid #e0e0e0;
            background-color: #fff;
        }
        
        .chat-input textarea {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 20px;
            padding: 12px 15px;
            font-size: 16px;
            resize: none;
            outline: none;
            max-height: 120px;
            min-height: 24px;
        }
        
        .chat-input button {
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 50%;
            width: 48px;
            height: 48px;
            margin-left: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s;
        }
        
        .chat-input button:hover {
            background-color: #0069d9;
        }
        
        .chat-input button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
        }
        
        /* Table styling */
        .result-table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: 14px;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .result-table th {
            background-color: #f1f1f1;
            color: #333;
            font-weight: bold;
            text-align: left;
            padding: 10px;
        }
        
        .result-table td {
            padding: 8px 10px;
            border-top: 1px solid #eee;
        }
        
        .result-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        /* Pre formatted text */
        pre {
            background-color: #f8f8f8;
            padding: 10px;
            border-radius: 5px;
            white-space: pre-wrap;
            font-family: Consolas, Monaco, 'Andale Mono', monospace;
            font-size: 14px;
            overflow-x: auto;
            max-width: 100%;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 0.4; transform: scale(1); }
            50% { opacity: 1; transform: scale(1.1); }
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .message {
                max-width: 90%;
            }
        }
    </style>
  
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

    <div class="container">
        <div class="chat-container">
            <div class="chat-header">
                HR Chat Assistant
            </div>
            <div class="chat-messages" id="chatMessages">
                <div class="message bot-message">
                    Bine ați venit! Sunt asistentul HR virtual. Îmi puteți adresa întrebări despre angajați, departamente, concedii, adeverințe sau proiecte, iar eu voi extrage informațiile necesare din baza de date. Cum vă pot ajuta astăzi?
                </div>
            </div>
            <div class="chat-input">
                <textarea id="userInput" placeholder="Scrieți un mesaj..." rows="1" oninput="adjustTextareaHeight(this)"></textarea>
                <button id="sendButton" onclick="sendMessage()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                    </svg>
                </button>
            </div>
        </div>
    </div>
    
    <script>
 // Add a console debug line to check if script is loading
    console.log('Chat script initialized');

    // DOM elements
    const chatMessages = document.getElementById('chatMessages');
    const userInput = document.getElementById('userInput');
    const sendButton = document.getElementById('sendButton');

    // Add event listener for Enter key
    userInput.addEventListener('keydown', function(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            sendMessage();
        }
    });

    // Function to send user message
    function sendMessage() {
        const message = userInput.value.trim();
        if (message === '') return;
        
        console.log('Sending message:', message);
        
        // Add user message to chat
        addMessage(message, 'user');
        
        // Clear input
        userInput.value = '';
        adjustTextareaHeight(userInput);
        
        // Show typing indicator
        showTypingIndicator();
        
        // Get the context path
        const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
        const servletUrl = contextPath + '/ChatServlet';
        
        console.log('Using servlet URL:', servletUrl);
        
        // Send message to server
        fetch(servletUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'query=' + encodeURIComponent(message)
        })
        .then(response => {
            console.log('Response status:', response.status);
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.status);
            }
            return response.text().then(text => {
                console.log('Raw response:', text);
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('JSON parse error:', e);
                    throw new Error('Invalid JSON response: ' + e.message);
                }
            });
        })
        .then(data => {
            console.log('Parsed data:', data);
            
            // Hide typing indicator
            hideTypingIndicator();
            
            // Handle different response types
            if (data.type === 'text') {
                // Simple text response
                addMessage(data.message, 'bot');
            } else if (data.type === 'table') {
                // Table response with initial message
                addMessage(data.message, 'bot');
                
                // If data is available and the message is asking for confirmation,
                // store the data for later use in follow-up responses
                if (data.data && data.data.length > 0 && 
                    (data.message.includes('Doriți') || data.message.includes('doriti'))) {
                    window.lastQueryData = data.data;
                } else if (data.data && data.data.length > 0) {
                    // If the message is not asking for confirmation, show the data immediately
                    setTimeout(() => {
                        addMessage({
                            content: createTableFromData(data.data)
                        }, 'bot');
                    }, 1000);
                }
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            
            // Hide typing indicator
            hideTypingIndicator();
            
            // Show error message
            addMessage('Îmi pare rău, a apărut o eroare în comunicarea cu serverul: ' + error.message, 'bot');
            
            // Fallback to local processing
            console.warn('Falling back to local processing due to server error');
            processQueryLocally(message);
        });
    }

    // Function to process query locally as a fallback
    function processQueryLocally(query) {
        setTimeout(() => {
            const response = processQuery(query);
            hideTypingIndicator();
            addMessage(response, 'bot');
        }, 1000);
    }

    // Function to add a message to the chat
    function addMessage(message, sender) {
        const messageElement = document.createElement('div');
        messageElement.classList.add('message');
        messageElement.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
        
        if (typeof message === 'string') {
            messageElement.innerHTML = message;
        } else {
            // If message is an object with HTML content
            messageElement.innerHTML = message.content;
        }
        
        chatMessages.appendChild(messageElement);
        
        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                 now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Function to show typing indicator
    function showTypingIndicator() {
        const typingElement = document.createElement('div');
        typingElement.classList.add('message', 'bot-message', 'bot-typing');
        typingElement.id = 'typingIndicator';
        
        const typingIndicator = document.createElement('div');
        typingIndicator.classList.add('typing-indicator');
        
        for (let i = 0; i < 3; i++) {
            const dot = document.createElement('div');
            dot.classList.add('typing-dot');
            typingIndicator.appendChild(dot);
        }
        
        typingElement.appendChild(typingIndicator);
        chatMessages.appendChild(typingElement);
        
        // Scroll to bottom
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Function to hide typing indicator
    function hideTypingIndicator() {
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }

    // Function to create HTML table from data
    function createTableFromData(data) {
        if (!data || data.length === 0) return '<p>Nu există date disponibile.</p>';
        
        // Get column names from first row
        const columns = Object.keys(data[0]);
        
        let tableHTML = '<table class="result-table">';
        
        // Create header row
        tableHTML += '<tr>';
        columns.forEach(column => {
            // Convert column names to friendly format
            const friendlyName = formatColumnName(column);
            tableHTML += `<th>${friendlyName}</th>`;
        });
        tableHTML += '</tr>';
        
        // Create data rows
        data.forEach(row => {
            tableHTML += '<tr>';
            columns.forEach(column => {
                tableHTML += `<td>${row[column] != null ? row[column] : ''}</td>`;
            });
            tableHTML += '</tr>';
        });
        
        tableHTML += '</table>';
        return tableHTML;
    }

    // Function to format column names for display
    function formatColumnName(columnName) {
        // Replace underscores with spaces
        let result = columnName.replace(/_/g, ' ');
        
        // Capitalize first letter of each word
        result = result.replace(/\b\w/g, l => l.toUpperCase());
        
        return result;
    }

    // Function to adjust textarea height
    function adjustTextareaHeight(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = (textarea.scrollHeight) + 'px';
    }

    // Listen for click on user messages with "da" to handle follow-up
    document.addEventListener('click', function(event) {
        if (event.target && event.target.closest('.user-message')) {
            const text = event.target.closest('.user-message').textContent.toLowerCase().trim();
            if (text === 'da' || text.includes('detalii')) {
                handleFollowUp();
            }
        }
    });

    // Function to handle follow-up responses when user clicks "yes"
    function handleFollowUp() {
        if (window.lastQueryData && window.lastQueryData.length > 0) {
            addMessage({
                content: createTableFromData(window.lastQueryData)
            }, 'bot');
            
            // Clear the stored data after showing it
            window.lastQueryData = null;
        } else {
            addMessage('Îmi pare rău, nu am informații suplimentare disponibile.', 'bot');
        }
    }

    // Initialize when the page loads
    document.addEventListener('DOMContentLoaded', function() {
        // Set up conversation context storage
        window.lastQueryData = null;
        console.log('DOM fully loaded, chat ready');
        
        // Add some helpful suggestions
        addSuggestions();
    });

    // Local fallback methods (for when the server is not available)
    // Sample data for fallback mode
    const sampleData = {
        angajati: [
            { id: 1, nume: "Vasile", prenume: "Fabian", departament: "HR", functie: "Director", email: "vasile.fabian@example.com", telefon: "0700000000" },
            { id: 2, nume: "Popescu", prenume: "Maria", departament: "HR", functie: "New Graduate", email: "maria.popescu2812@example.com", telefon: "0787763178" },
            { id: 3, nume: "Girnita", prenume: "Claudia", departament: "HR", functie: "Intern", email: "claudia.girnita@example.com", telefon: "0771000002" },
            { id: 4, nume: "Costache", prenume: "Irina", departament: "HR", functie: "Sef", email: "irina.costache@example.com", telefon: "0700000001" },
            { id: 5, nume: "Moise", prenume: "Monica", departament: "HR", functie: "CEO", email: "monica.moise@example.com", telefon: "0736000003" }
        ],
        concedii: [
            { id: 1, id_ang: 1, nume: "Vasile", prenume: "Fabian", departament: "HR", functie: "Director", start_c: "2024-12-24", end_c: "2024-12-29", durata: 6, motiv: "Concediu odihna", locatie: "Brasov", status: "Aprobat director" },
            { id: 2, id_ang: 3, nume: "Girnita", prenume: "Claudia", departament: "HR", functie: "Intern", start_c: "2024-12-24", end_c: "2024-12-26", durata: 3, motiv: "Concediu odihna", locatie: "Cluj", status: "Aprobat director" }
        ],
        departamente: [
            { id_dep: 1, nume_dep: "HR", nr_angajati: 5 },
            { id_dep: 2, nume_dep: "Finante", nr_angajati: 5 },
            { id_dep: 3, nume_dep: "IT", nr_angajati: 10 }
        ]
    };

    // Keep track of last response for follow-up questions in local mode
    let lastResponse = null;

    // Main function to process the query locally (fallback)
    function processQuery(query) {
        const normalizedQuery = query.toLowerCase();
        
        // Check if it's a follow-up question
        if (normalizedQuery.includes('da') && lastResponse && lastResponse.type) {
            return handleLocalFollowUp();
        }
        
        // Check for greeting
        if (containsGreeting(normalizedQuery)) {
            return "Bună ziua! Cu ce vă pot ajuta astăzi? Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte.";
        }
        
        // Check query type
        if (normalizedQuery.includes('concediu') && normalizedQuery.includes('craciun')) {
            return handleLocalChristmasLeaveQuery();
        } else if (normalizedQuery.includes('angajati') || normalizedQuery.includes('angajații')) {
            return handleLocalEmployeeQuery(normalizedQuery);
        } else if (normalizedQuery.includes('departament') || normalizedQuery.includes('departamente')) {
            return handleLocalDepartmentQuery(normalizedQuery);
        } else if (normalizedQuery.includes('concediu') || normalizedQuery.includes('concedii')) {
            return handleLocalLeaveQuery(normalizedQuery);
        } else {
            return "Îmi pare rău, nu am înțeles întrebarea. Puteți să-mi adresați întrebări despre angajați, departamente, concedii, adeverințe sau proiecte. De exemplu: \"Câți angajați sunt în departamentul HR?\" sau \"Cine este în concediu de Crăciun?\"";
        }
    }

    // Helper functions for local processing
    function containsGreeting(text) {
        const greetings = ['buna', 'salut', 'hello', 'hi', 'hey', 'bună ziua', 'neața', 'ziua bună'];
        return greetings.some(greeting => text.includes(greeting));
    }

    function formatLocalDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('ro-RO');
    }

    // Handle Christmas leave query locally
    function handleLocalChristmasLeaveQuery() {
        // Filter concedii that overlap with Christmas (24-25 December)
        const christmasLeave = sampleData.concedii.filter(c => {
            const startDate = new Date(c.start_c);
            const endDate = new Date(c.end_c);
            const christmasStart = new Date('2024-12-24');
            const christmasEnd = new Date('2024-12-25');
            
            return (startDate <= christmasEnd && endDate >= christmasStart);
        });
        
        // Store this for follow-up questions
        lastResponse = {
            type: 'christmas_leave',
            data: christmasLeave
        };
        
        return `Desigur, imediat. După o analiză detaliată, am descoperit că ${christmasLeave.length} angajați au luat concediu care include perioada Crăciunului. Doriți să aflați mai multe detalii?`;
    }

 // Handle local follow-up questions
    function handleLocalFollowUp() {
        if (!lastResponse) {
            return "Îmi pare rău, nu înțeleg la ce vă referiți. Puteți să-mi adresați o întrebare mai detaliată?";
        }
        
        if (lastResponse.type === 'christmas_leave') {
            const data = lastResponse.data;
            if (data.length === 0) {
                return "Nu sunt angajați în concediu în această perioadă.";
            }
            
            let tableHTML = `<p>Imediat. Mai jos aveți un tabel cu numele angajaților, departamentul, funcția, locația concediului, motivul concediului, data de început și numărul de zile ale concediului:</p>`;
            
            tableHTML += createTableFromData(data);
            return { content: tableHTML };
        } else if (lastResponse.type === 'employee_query') {
            return { content: createTableFromData(lastResponse.data) };
        } else if (lastResponse.type === 'department_query') {
            return { content: createTableFromData(lastResponse.data) };
        }
        
        return "Îmi pare rău, nu am informații suplimentare disponibile.";
    }

    // Handle employee queries locally
    function handleLocalEmployeeQuery(query) {
        let filteredEmployees = sampleData.angajati;
        
        // Apply filters based on query
        if (query.includes('hr')) {
            filteredEmployees = filteredEmployees.filter(emp => emp.departament.toLowerCase() === 'hr');
        } else if (query.includes('finante') || query.includes('finanțe')) {
            filteredEmployees = filteredEmployees.filter(emp => emp.departament.toLowerCase() === 'finante');
        } else if (query.includes('it')) {
            filteredEmployees = filteredEmployees.filter(emp => emp.departament.toLowerCase() === 'it');
        }
        
        if (query.includes('director')) {
            filteredEmployees = filteredEmployees.filter(emp => emp.functie.toLowerCase() === 'director');
        } else if (query.includes('intern')) {
            filteredEmployees = filteredEmployees.filter(emp => emp.functie.toLowerCase() === 'intern');
        }
        
        // Store for follow-up
        lastResponse = {
            type: 'employee_query',
            data: filteredEmployees
        };
        
        // Count results
        const count = filteredEmployees.length;
        
        if (query.includes('câți') || query.includes('cati') || query.includes('număr') || query.includes('numar')) {
            return `În urma analizei, am găsit ${count} angajați care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?`;
        } else {
            return `Am găsit informații despre ${count} angajați. Doriți să vedeți detaliile complete?`;
        }
    }

    // Handle department queries locally
    function handleLocalDepartmentQuery(query) {
        let filteredDepartments = sampleData.departamente;
        
        // Apply filters based on query
        if (query.includes('hr')) {
            filteredDepartments = filteredDepartments.filter(dep => dep.nume_dep.toLowerCase() === 'hr');
        } else if (query.includes('finante') || query.includes('finanțe')) {
            filteredDepartments = filteredDepartments.filter(dep => dep.nume_dep.toLowerCase() === 'finante');
        } else if (query.includes('it')) {
            filteredDepartments = filteredDepartments.filter(dep => dep.nume_dep.toLowerCase() === 'it');
        }
        
        // Store for follow-up
        lastResponse = {
            type: 'department_query',
            data: filteredDepartments
        };
        
        // Count results
        const count = filteredDepartments.length;
        
        if (query.includes('câți') || query.includes('cati') || query.includes('număr') || query.includes('numar')) {
            if (query.includes('angajați') || query.includes('angajati')) {
                // Calculate total employees if asking about employee count
                const totalEmployees = filteredDepartments.reduce((sum, dep) => sum + dep.nr_angajati, 0);
                return `În departamentele selectate lucrează un total de ${totalEmployees} angajați. Doriți să vedeți detaliile fiecărui departament?`;
            } else {
                return `Am găsit ${count} departamente care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?`;
            }
        } else {
            return `Am găsit informații despre ${count} departamente. Doriți să vedeți detaliile complete?`;
        }
    }

    // Handle leave queries locally
    function handleLocalLeaveQuery(query) {
        let filteredLeaves = sampleData.concedii;
        
        // Apply filters based on query
        if (query.includes('decembrie') || query.includes('decembrie')) {
            filteredLeaves = filteredLeaves.filter(leave => {
                const startDate = new Date(leave.start_c);
                return startDate.getMonth() === 11; // December is month 11 (0-indexed)
            });
        }
        
        if (query.includes('hr')) {
            filteredLeaves = filteredLeaves.filter(leave => leave.departament.toLowerCase() === 'hr');
        } else if (query.includes('finante') || query.includes('finanțe')) {
            filteredLeaves = filteredLeaves.filter(leave => leave.departament.toLowerCase() === 'finante');
        }
        
        // Store for follow-up
        lastResponse = {
            type: 'leave_query',
            data: filteredLeaves
        };
        
        // Count results
        const count = filteredLeaves.length;
        
        if (query.includes('câți') || query.includes('cati') || query.includes('număr') || query.includes('numar')) {
            return `În urma analizei, am găsit ${count} concedii care corespund criteriilor dvs. Doriți să vedeți detaliile acestora?`;
        } else {
            return `Am găsit informații despre ${count} concedii. Doriți să vedeți detaliile complete?`;
        }
    }

    // Add a greeting message when the chat starts
    function addInitialMessage() {
        setTimeout(() => {
            addMessage('Bună ziua! Sunt asistentul virtual al departamentului HR. Cu ce vă pot ajuta astăzi?', 'bot');
        }, 500);
    }

    // Enhanced textarea auto-resize
    userInput.addEventListener('input', function() {
        adjustTextareaHeight(this);
    });

    // Initialize the chat with greeting
    // addInitialMessage(); - already added in HTML

    // Add click event listener to sendButton
    sendButton.addEventListener('click', sendMessage);

    // Function to show error message
    function showError(message) {
        const errorElement = document.createElement('div');
        errorElement.classList.add('error-message');
        errorElement.textContent = message;
        
        document.querySelector('.chat-container').appendChild(errorElement);
        
        // Remove after 5 seconds
        setTimeout(() => {
            errorElement.remove();
        }, 5000);
    }

    // Function to save chat history
    function saveChatHistory() {
        const messages = Array.from(chatMessages.children).map(el => {
            const isUser = el.classList.contains('user-message');
            const text = el.textContent.trim();
            return { sender: isUser ? 'user' : 'bot', message: text, timestamp: new Date().toISOString() };
        });
        
        localStorage.setItem('chatHistory', JSON.stringify(messages));
    }

    // Function to load chat history
    function loadChatHistory() {
        const history = localStorage.getItem('chatHistory');
        if (history) {
            try {
                const messages = JSON.parse(history);
                // Clear existing messages
                chatMessages.innerHTML = '';
                // Add saved messages
                messages.forEach(msg => {
                    addMessage(msg.message, msg.sender === 'user' ? 'user' : 'bot');
                });
            } catch (e) {
                console.error('Failed to load chat history:', e);
            }
        }
    }

    // Save chat history periodically
    setInterval(saveChatHistory, 30000);

    // Optional: Function to clear chat history
    function clearChatHistory() {
        localStorage.removeItem('chatHistory');
        chatMessages.innerHTML = '';
        addInitialMessage();
    }

    // Add some helpful suggestions that the user can click on
    function addSuggestions() {
        const suggestions = [
            'Câți angajați sunt în departamentul HR?',
            'Cine este în concediu de Crăciun?',
            'Arată-mi departamentele',
            'Informații despre concedii'
        ];
        
        const suggestionsContainer = document.createElement('div');
        suggestionsContainer.classList.add('suggestions-container');
        
        suggestions.forEach(suggestion => {
            const suggestionButton = document.createElement('button');
            suggestionButton.classList.add('suggestion-button');
            suggestionButton.textContent = suggestion;
            suggestionButton.addEventListener('click', () => {
                userInput.value = suggestion;
                adjustTextareaHeight(userInput);
                sendMessage();
            });
            
            suggestionsContainer.appendChild(suggestionButton);
        });
        
        // Insert the suggestions before the chat input area
        document.querySelector('.chat-container').insertBefore(
            suggestionsContainer, 
            document.querySelector('.chat-input')
        );
    }
    </script>
         <%
                    }
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
</body>
</html>