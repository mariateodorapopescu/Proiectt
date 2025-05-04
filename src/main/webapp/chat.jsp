<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

//Structura unei pagini este astfel
//Verificare daca exista sesiune activa, utilizator conectat, 
//Extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//Se mai extrag temele de culoare ale fiecarui utilizator
//Apoi se incarca pagina in sine

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
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    
    <!-- =============== JQUERY =============== -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- =============== ANIMATIONS =============== -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
    
    <style>
        a, a:visited, a:hover, a:active{color:white !important}
        
        /* Suggestions styling */
        .suggestions-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 10px 20px;
            animation: fadeIn 0.5s;
        }

        .suggestion-button {
            background-color: <%=clr%>;
            border: 1px solid <%=accent%>;
            border-radius: 18px;
            padding: 8px 16px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
           color: <%=text%>;
        }

        .suggestion-button:hover {
            background-color: black;
            color: white;
            transform: translateY(-2px);
           
        }

        .suggestion-button:active {
            transform: translateY(0);
            
        }

        .input-container {
            display: flex;
            padding: 15px;
            border-top: 1px solid #e0e0e0;
        }
        
        /* Chat container and messages */
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        
        
        .chat-container {
            background-color: <%=sidebar%>;
            border-radius: 10px;
            
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 40px);
        }
        
        .chat-header {
            background-color: <%=accent%>;
            color: white;
            padding: 15px 20px;
            font-weight: bold;
            font-size: 22px;
            border-bottom: 1px solid <%=clr%>;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .chat-status {
            font-size: 14px;
            opacity: 0.8;
        }
        
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            scroll-behavior: smooth;
        }
        
        .message {
            margin-bottom: 15px;
            max-width: 80%;
            animation: fadeInUp 0.3s;
            position: relative;
        }
        
        .user-message {
            margin-left: auto;
            background-color: <%=accent%>;
            color: white;
            border-radius: 18px 18px 3px 18px;
            padding: 12px 18px;
        }
        
        .bot-message {
            margin-right: auto;
            background-color: <%=clr%>;
            color: <%=text%>;
            border-radius: 18px 18px 18px 3px;
            padding: 12px 18px;        
        }

        .message-time {
            font-size: 12px;
            color: white;
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
            padding: 10px 15px;
            background-color: <%=accent%>;
            border-radius: 18px;
        }
        
        .typing-dot {
            height: 8px;
            width: 8px;
            background-color: <%=accent%>;
            border-radius: 50%;
            margin: 0 2px;
            animation: bounce 1.5s infinite;
        }
        
        .typing-dot:nth-child(2) {
            animation-delay: 0.3s;
        }
        
        .typing-dot:nth-child(3) {
            animation-delay: 0.6s;
        }
        
        /* Input area */
        .chat-input {
            display: flex;
            padding: 15px;
            border-top: 1px solid <%=accent%>;
            background-color: <%=accent%>;
            position: relative;
        }
        
        .chat-input textarea {
            flex: 1;
            border: 1px solid <%=accent%>;
            border-radius: 22px;
            padding: 12px 45px 12px 15px;
            font-size: 16px;
            resize: none;
            outline: none;
            max-height: 120px;
            min-height: 24px;
            transition: all 0.3s;
            background-color: <%=clr%>;
            color: white;
        }
        
        .chat-input textarea:focus, .chat-input textarea:active, .chat-input textarea:hover {
            background-color: <%=sidebar%>;
        }
        
        .chat-input button {
            background-color: <%=sidebar%>;
            color: <%=accent%>;
            border: none;
            border-radius: 50%;
            width: 48px;
            height: 48px;
            margin-left: 10px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .chat-input button:hover {
            background-color: black;
            color: white;
            transform: translateY(-2px);
            
        }
        
        .chat-input button:active {
            transform: translateY(0);
        }
        
        .chat-input button:disabled {
            background-color: #cccccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        /* Table styling */
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: 14px;
            border-radius: 8px;
            overflow: hidden;
            
        }
        
        table th {
            background-color: <%=clr%>;
            color: #333;
            font-weight: bold;
            text-align: left;
            padding: 12px;
            border-bottom: 2px solid <%=clr%>;
        }
        
        table td {
            padding: 10px 12px;
            border-top: 1px solid <%=accent%>;
        }
        
        table tr:nth-child(even) {
            background-color: <%=sidebar%>;
        }
        
        table tr:hover {
            background-color: <%=accent%>;
        }
        
        /* Scrollable table container for larger datasets */
        .table-container {
            max-height: 400px;
            overflow-y: auto;
            margin: 10px 0;
            border-radius: 8px;
            border: 1px solid <%=accent%>;
        }
        
        /* Action buttons near tables for export, etc. */
        .table-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin: 5px 0 15px;
        }
        
        .table-action-button {
            background-color: <%=accent%>;
            color: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 5px 10px;
            font-size: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .table-action-button:hover {
            background-color: black;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-5px); }
        }
        
        /* Help tooltip */
        .help-tooltip {
            position: relative;
            display: inline-block;
            margin-left: 10px;
            cursor: pointer;
            z-index: 200;
        }
        
        .help-icon {
            width: 22px;
            height: 22px;
            background-color: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: bold;
        }
        
        .tooltip-content {
            position: absolute;
            top: 30px;
            right: 0;
            background-color: white;
            color: #333;
            padding: 15px;
            border-radius: 8px;
           
            width: 250px;
            z-index: 100;
            display: none;
            font-weight: normal;
            text-align: left;
            font-size: 13px;
            line-height: 1.4;
            
        }
        
        .help-tooltip:hover .tooltip-content {
            display: block;
            animation: fadeIn 0.3s;
           
        }
        
        .help-tooltip.tooltip-content {
            display: block;
            animation: fadeIn 0.3s;
            
        }
                
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .message {
                max-width: 90%;
            }
            
            .suggestions-container {
                justify-content: center;
            }
            
            .suggestion-button {
                font-size: 12px;
                padding: 6px 12px;
            }
            
            .chat-header {
                padding: 12px 15px;
                font-size: 18px;
            }
       
    </style>
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    
    <!--=============== titlu ===============-->
    <title>Asistent HR</title>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">

    <div class="container">
        <div class="chat-container">
            <div class="chat-header">
                <div>Asistent HR</div>
                <div class="chat-status">
                    <span id="statusText">Online</span>
                    
                </div>
            </div>
            <div class="chat-messages" id="chatMessages">
                <div class="message bot-message">
                <strong>Cum să folosești asistentul:</strong><br>
                            - Întreabă despre angajați, departamente, concedii<br>
                            - Solicită informații specifice sau statistici<br>
                            - Folosește limbaj natural în întrebări<br>
                            - Spune "Da" pentru a vedea detalii<br>
                            - Încearcă sugestiile de mai jos
                    
                </div>
                 <div class="message bot-message">
                <p>Bine ați venit! Sunt asistentul HR virtual. Vă pot oferi informații despre:</p>
                    <ul>
                        <li>Angajați și departamente</li>
                        <li>Concedii și adeverințe</li>
                        <li>Poziții, roluri și salarii</li>
                        <li>Proiecte și echipe</li>
                    </ul>
                    <p>Cum vă pot ajuta astăzi?</p>
                    </div>
            </div>
            <div class="suggestions-container" id="suggestionsContainer">
                <!-- Suggestions will be added here dynamically -->
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
    // Chat component initialization
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Chat interface initialized');
        
        // Add default suggestions
        addDefaultSuggestions();
        
        // Focus input field
        document.getElementById('userInput').focus();
        
        // Set up event listeners
        setupEventListeners();
    });
    
    // DOM elements
    const chatMessages = document.getElementById('chatMessages');
    const userInput = document.getElementById('userInput');
    const sendButton = document.getElementById('sendButton');
    const suggestionsContainer = document.getElementById('suggestionsContainer');
    
    // Setup event listeners
    function setupEventListeners() {
        // Enter key to send message
        userInput.addEventListener('keydown', function(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        });
        
        // Click event for send button
        sendButton.addEventListener('click', sendMessage);
        
        // Click event for chat messages (for handling follow-ups)
        chatMessages.addEventListener('click', function(event) {
            if (event.target && event.target.closest('.user-message')) {
                const text = event.target.closest('.user-message').textContent.toLowerCase().trim();
                if (isFollowUpResponse(text)) {
                    handleFollowUp();
                }
            }
        });
    }

    // Add default suggestions
    function addDefaultSuggestions() {
        const suggestions = [
            'Câți angajați sunt în departamentul HR?',
            'Cine este în concediu astăzi?',
            'Arată-mi departamentele din firmă',
            'Care sunt salariile pozițiilor din IT?',
            'Ce tipuri de poziții există în departamentul HR?',
            'Proiecte active în prezent',
            'Adeverințe în așteptare'
        ];
        
        suggestionsContainer.innerHTML = '';
        
        suggestions.forEach(suggestion => {
            const button = document.createElement('button');
            button.className = 'suggestion-button';
            button.textContent = suggestion;
            button.addEventListener('click', function() {
                userInput.value = suggestion;
                adjustTextareaHeight(userInput);
                sendMessage();
            });
            
            suggestionsContainer.appendChild(button);
        });
    }
    
    // Add context-aware suggestions based on previous interactions
    function addContextSuggestions(context) {
        const contextSuggestions = {
            'angajați': [
                'Câți angajați sunt în total?',
                'Care sunt angajații din departamentul IT?',
                'Angajații cu cele mai mari salarii'
            ],
            'departamente': [
                'Care departament are cei mai mulți angajați?',
                'Câte departamente avem în firmă?',
                'Locațiile departamentelor'
            ],
            'concedii': [
                'Cine este în concediu astăzi?',
                'Concedii planificate pentru luna aceasta',
                'Concedii de Crăciun'
            ],
            'poziții': [
                'Ce tipuri de poziții există?',
                'Care sunt pozițiile din IT?',
                'Pozițiile cu cele mai mari salarii'
            ],
            'salarii': [
                'Care este salariul mediu în firmă?',
                'Top 5 cele mai mari salarii',
                'Salarii pe departamente'
            ],
            'proiecte': [
                'Câte proiecte active avem?',
                'Cine lucrează la proiectele active?',
                'Status-ul taskurilor din proiecte'
            ]
        };
        
        // Find the appropriate context
        let suggestions = [];
        for (const [key, value] of Object.entries(contextSuggestions)) {
            if (context.toLowerCase().includes(key)) {
                suggestions = value;
                break;
            }
        }
        
        // If no specific context found, use default suggestions
        if (suggestions.length === 0) {
            return;
        }
        
        // Update suggestions
        suggestionsContainer.innerHTML = '';
        
        suggestions.forEach(suggestion => {
            const button = document.createElement('button');
            button.className = 'suggestion-button';
            button.textContent = suggestion;
            button.addEventListener('click', function() {
                userInput.value = suggestion;
                adjustTextareaHeight(userInput);
                sendMessage();
            });
            
            suggestionsContainer.appendChild(button);
        });
    }
    
    // Check if text is a follow-up response
    function isFollowUpResponse(text) {
        const followUpPhrases = [
            'da', 'te rog', 'sigur', 'bineințeles', 'bineinteles', 'vreau', 
            'arata-mi mai multe', 'arată-mi mai multe', 'detalii'
        ];
        
        return followUpPhrases.some(phrase => text.includes(phrase));
    }
    
    // Handle follow-up responses
    function handleFollowUp() {
        // This will be handled by the server when the message is sent
        // The server has stored the previous query context and data
    }
    
    // Send message to server
    function sendMessage() {
        const message = userInput.value.trim();
        if (message === '') return;
        
        console.log('Sending message:', message);
        
        // Add user message to chat
        addMessage(message, 'user');
        
        // Clear input and adjust height
        userInput.value = '';
        adjustTextareaHeight(userInput);
        
        // Show typing indicator
        showTypingIndicator();
        
        // Disable input while processing
        setInputEnabled(false);
        
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
            
            // Re-enable input
            setInputEnabled(true);
            
            // Handle different response types
            if (data.type === 'text') {
                // Simple text response
                addMessage(data.message, 'bot');
                
                // Update suggestions based on message context
                if (data.message && data.message.length > 10) {
                    addContextSuggestions(data.message);
                }
            } else if (data.type === 'table') {
                // Table response with initial message
                addMessage(data.message, 'bot');
                
                // If data is available and the message is asking for confirmation,
                // show the confirmation buttons
                if (data.data && data.data.length > 0 && 
                    (data.message.includes('Doriți') || data.message.includes('doriti'))) {
                    
                    // Store data for possible confirmation
                    window.lastQueryData = data.data;
                    
                    // Add confirmation buttons
                    addConfirmationButtons();
                    
                    // Update suggestions based on data context
                    let contextString = getContextFromData(data.data);
                    addContextSuggestions(contextString);
                    
                } else if (data.data && data.data.length > 0) {
                    // If the message is not asking for confirmation, show the data immediately
                    setTimeout(() => {
                        addTableMessage(data.data, 'bot');
                        
                        // Update suggestions based on data context
                        let contextString = getContextFromData(data.data);
                        addContextSuggestions(contextString);
                    }, 500);
                }
            } else if (data.type === 'error') {
                // Error response
                addMessage(data.message, 'bot', 'error');
                
                // Reset to default suggestions
                setTimeout(addDefaultSuggestions, 500);
            }
        })
        .catch(error => {
            console.error('Fetch error:', error);
            
            // Hide typing indicator
            hideTypingIndicator();
            
            // Re-enable input
            setInputEnabled(true);
            
            // Show error message
            addMessage('Îmi pare rău, a apărut o eroare în comunicarea cu serverul: ' + error.message, 'bot', 'error');
            
            // Reset to default suggestions
            setTimeout(addDefaultSuggestions, 500);
        });
    }
    
    // Try to determine context from data for suggestion generation
    function getContextFromData(data) {
        if (!data || data.length === 0) return '';
        
        // Get the first row as a sample
        const sample = data[0];
        let contextString = '';
        
        // Check for known column names to determine context
        if (sample.departament) contextString += ' departamente';
        if (sample.nume && sample.prenume) contextString += ' angajați';
        if (sample.data_inceput || sample.start_c) contextString += ' concedii';
        if (sample.functie || sample.denumire || sample.salariu) contextString += ' poziții salarii';
        if (sample.nume_proiect || sample.nume_task) contextString += ' proiecte';
        if (sample.tip_adeverinta) contextString += ' adeverințe';
        
        return contextString;
    }
    
    // Add confirmation buttons after a table response that needs confirmation
    function addConfirmationButtons() {
        const confirmationDiv = document.createElement('div');
        confirmationDiv.className = 'confirmation-buttons';
        confirmationDiv.style.display = 'flex';
        confirmationDiv.style.gap = '10px';
        confirmationDiv.style.marginTop = '10px';
        
        const yesButton = document.createElement('button');
        yesButton.className = 'suggestion-button';
        yesButton.textContent = 'Da, vreau să văd detaliile';
        yesButton.style.backgroundColor = '#4CAF50';
        yesButton.style.color = 'white';
        yesButton.addEventListener('click', function() {
            // Remove confirmation buttons
            confirmationDiv.remove();
            
            // Show the table
            if (window.lastQueryData && window.lastQueryData.length > 0) {
                addTableMessage(window.lastQueryData, 'bot');
                window.lastQueryData = null;
            }
        });
        
        const noButton = document.createElement('button');
        noButton.className = 'suggestion-button';
        noButton.textContent = 'Nu, mulțumesc';
        noButton.addEventListener('click', function() {
            // Remove confirmation buttons
            confirmationDiv.remove();
            
            // Clear stored data
            window.lastQueryData = null;
            
            // Add a confirmation message
            addMessage('În regulă. Cu ce altceva vă pot ajuta?', 'bot');
        });
        
        confirmationDiv.appendChild(yesButton);
        confirmationDiv.appendChild(noButton);
        
        // Add to the last bot message
        const lastBotMessage = Array.from(chatMessages.querySelectorAll('.bot-message'))
            .filter(el => !el.classList.contains('bot-typing'))
            .pop();
            
        if (lastBotMessage) {
            lastBotMessage.appendChild(confirmationDiv);
        }
    }

    // Add a text message to chat
    function addMessage(message, sender, type) {
        const messageElement = document.createElement('div');
        messageElement.classList.add('message');
        messageElement.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
        
        if (type === 'error') {
            messageElement.style.backgroundColor = '#ffebee';
            messageElement.style.color = '#c62828';
            messageElement.style.borderLeft = '3px solid #c62828';
        }
        
        messageElement.innerHTML = formatMessage(message);
        
        chatMessages.appendChild(messageElement);
        
        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                 now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        // Scroll to bottom
        scrollToBottom();
    }
    
    function addTableMessage(data, sender) {
        if (!data || data.length === 0) {
            addMessage('Nu există date disponibile.', sender);
            return;
        }
        
        console.log('Rendering table with data:', data);
        
        // Creăm containerul pentru mesaj
        const messageElement = document.createElement('div');
        messageElement.classList.add('message');
        messageElement.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
        messageElement.style.maxWidth = "95%";
        messageElement.style.width = "auto";
        messageElement.style.overflowX = "auto";
        
        // Get column names from first row
        const columns = Object.keys(data[0]);
        
        // Build table HTML directly using StringBuilder pattern
        let tableHTML = '';
        tableHTML += '<div style="overflow-x:auto; margin:10px 0;">';
        tableHTML += '<table style="width:100%; border-collapse:collapse; color:#000; background-color:#fff; border:1px solid #ddd;">';
        
        // Create header row
        tableHTML += '<thead>';
        tableHTML += '<tr>';
        columns.forEach(column => {
            // Convert column names to friendly format
            const friendlyName = formatColumnName(column);
            tableHTML += '<th style="padding:8px; text-align:left; background-color:#f5f5f5; color:#333; border:1px solid #ddd;">' + friendlyName + '</th>';
        });
        tableHTML += '</tr>';
        tableHTML += '</thead>';
        
        // Create data rows
        tableHTML += '<tbody>';
        data.forEach((row, index) => {
            const bgColor = index % 2 === 0 ? '#ffffff' : '#f9f9f9';
            tableHTML += '<tr style="background-color:' + bgColor + ';">';
            columns.forEach(column => {
                let cellValue = row[column] != null ? row[column] : '';
                
                // Format dates if they look like dates
                if (typeof cellValue === 'string' && 
                    (cellValue.match(/^\d{4}-\d{2}-\d{2}$/) || 
                     cellValue.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/))) {
                    cellValue = formatDateString(cellValue);
                }
                
                // Format boolean values
                if (cellValue === true) cellValue = 'Da';
                if (cellValue === false) cellValue = 'Nu';
                
                tableHTML += '<td style="padding:8px; border:1px solid #ddd; color:#333;">' + cellValue + '</td>';
            });
            tableHTML += '</tr>';
        });
        tableHTML += '</tbody>';
        tableHTML += '</table>';
        tableHTML += '</div>';
        
        // Create the table element and add it to the message
        const tableContainer = document.createElement('div');
        tableContainer.innerHTML = tableHTML;
        messageElement.appendChild(tableContainer);
        
        // Export button
        const exportButton = document.createElement('button');
        exportButton.textContent = 'Export CSV';
        exportButton.style.backgroundColor = '#f1f1f1';
        exportButton.style.border = '1px solid #ddd';
        exportButton.style.borderRadius = '4px';
        exportButton.style.padding = '5px 10px';
        exportButton.style.fontSize = '12px';
        exportButton.style.cursor = 'pointer';
        exportButton.style.margin = '5px 0';
        exportButton.addEventListener('click', function() {
            exportTableToCSV(data);
        });
        
        messageElement.appendChild(exportButton);
        
        // Add to chat
        chatMessages.appendChild(messageElement);
        
        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                  now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        // Ensure good scrolling
        setTimeout(scrollToBottom, 100);
    }
    
    // Show typing indicator
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
        scrollToBottom();
    }
    
    // Hide typing indicator
    function hideTypingIndicator() {
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }
    
    // Format message with links, lists, etc.
    function formatMessage(message) {
        if (typeof message !== 'string') {
            return message;
        }
        
        // Convert URLs to links
        message = message.replace(
            /(https?:\/\/[^\s]+)/g,
            '<a href="$1" target="_blank" style="color: #0078d4; text-decoration: underline;">$1</a>'
        );
        
        // Convert bullet points (* or -) to HTML lists
        if ((message.includes('* ') || message.includes('- ')) && message.includes('\n')) {
            let lines = message.split('\n');
            let inList = false;
            let formattedLines = [];
            
            for (let line of lines) {
                if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
                    if (!inList) {
                        formattedLines.push('<ul style="margin: 5px 0; padding-left: 20px;">');
                        inList = true;
                    }
                    formattedLines.push('<li>' + line.trim().substring(2) + '</li>');
                } else {
                    if (inList) {
                        formattedLines.push('</ul>');
                        inList = false;
                    }
                    formattedLines.push(line);
                }
            }
            
            if (inList) {
                formattedLines.push('</ul>');
            }
            
            message = formattedLines.join('\n');
        }
        
        // Convert newlines to <br>
        message = message.replace(/\n/g, '<br>');
        
        return message;
    }
    
    function createTableFromData(data) {
        if (!data || data.length === 0) return '<p>Nu există date disponibile.</p>';
        
        // Log datele pentru debugging
        console.log("Date pentru tabel:", data);
        
        // Get column names from first row
        const columns = Object.keys(data[0]);
        
        let tableHTML = '<table class="result-table" style="width:100%; border-collapse:collapse; margin:10px 0; color:#333; background-color:#fff;">';
        
        // Create header row
        tableHTML += '<tr>';
        columns.forEach(column => {
            // Convert column names to friendly format
            const friendlyName = formatColumnName(column);
            tableHTML += `<th style="background-color:#f5f5f5; color:#333; text-align:left; padding:10px; border:1px solid #ddd;">${friendlyName}</th>`;
        });
        tableHTML += '</tr>';
        
        // Create data rows
        data.forEach((row, rowIndex) => {
            const bgColor = rowIndex % 2 === 0 ? '#fff' : '#f9f9f9';
            tableHTML += `<tr style="background-color:${bgColor};">`;
            columns.forEach(column => {
                let cellValue = row[column] != null ? row[column] : '';
                
                // Format dates if they look like dates
                if (typeof cellValue === 'string' && 
                    (cellValue.match(/^\d{4}-\d{2}-\d{2}$/) || 
                     cellValue.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/))) {
                    cellValue = formatDateString(cellValue);
                }
                
                // Format boolean values
                if (cellValue === true) cellValue = 'Da';
                if (cellValue === false) cellValue = 'Nu';
                
                tableHTML += `<td style="padding:8px; border:1px solid #ddd; color:#333;">${cellValue}</td>`;
            });
            tableHTML += '</tr>';
        });
        
        tableHTML += '</table>';
        
        return tableHTML;
    }
    
    // Format column names for display
    function formatColumnName(columnName) {
        // Replace underscores with spaces
        let result = columnName.replace(/_/g, ' ');
        
        // Capitalize first letter of each word
        result = result.replace(/\b\w/g, l => l.toUpperCase());
        
        return result;
    }
    
    // Format date strings to Romanian format
    function formatDateString(dateString) {
        if (!dateString) return '';
        
        try {
            const date = new Date(dateString);
            if (isNaN(date.getTime())) return dateString;
            
            return date.toLocaleDateString('ro-RO', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric'
            });
        } catch (e) {
            return dateString;
        }
    }
    
    // Export table data to CSV
    function exportTableToCSV(data) {
        if (!data || data.length === 0) return;
        
        // Get column names
        const columns = Object.keys(data[0]);
        
        // Create CSV content
        let csvContent = columns.map(formatColumnName).join(',') + '\n';
        
        data.forEach(row => {
            let rowContent = columns.map(column => {
                let value = row[column] != null ? row[column] : '';
                
                // Quote values with commas
                if (typeof value === 'string' && value.includes(',')) {
                    return `"${value}"`;
                }
                
                return value;
            }).join(',');
            
            csvContent += rowContent + '\n';
        });
        
        // Create download link
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.setAttribute('href', url);
        link.setAttribute('download', 'export_' + new Date().toISOString().slice(0, 10) + '.csv');
        link.style.visibility = 'hidden';
        
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    
    // Enable/disable input while processing
    function setInputEnabled(enabled) {
        userInput.disabled = !enabled;
        sendButton.disabled = !enabled;
        
        if (enabled) {
            userInput.focus();
            document.getElementById('statusText').textContent = 'Online';
        } else {
            document.getElementById('statusText').textContent = 'Procesează...';
        }
    }
    
    // Adjust textarea height based on content
    function adjustTextareaHeight(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = (textarea.scrollHeight) + 'px';
    }
    
    // Scroll chat to bottom
    function scrollToBottom() {
        chatMessages.scrollTop = chatMessages.scrollHeight;
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