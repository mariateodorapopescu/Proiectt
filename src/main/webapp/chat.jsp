<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"%>
      
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.DecimalFormat" %>
<%

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizator in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extrag usernameul, care e unic
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                            "dp.denumire_completa AS denumire FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?")) {
                    preparedStatement.setString(1, username);
                    ResultSet rs = preparedStatement.executeQuery();
                    if (!rs.next()) {
                        out.println("<script type='text/javascript'>");
                        out.println("alert('Date introduse incorect sau nu exista date!');");
                        out.println("</script>");
                    } else {
                        int userType = rs.getInt("tip");
                        int id = rs.getInt("id");
                        int userDep = rs.getInt("id_dep");
                        int ierarhie = rs.getInt("ierarhie");
                        String functie = rs.getString("functie");
                        String nume_dep = rs.getString("nume_dep");
                        int userSediuId = rs.getInt("id_sediu");
                        
                        // Funcție helper pentru a determina rolul utilizatorului
                        boolean isDirector = (ierarhie < 3);
                        boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                        boolean isIncepator = (ierarhie >= 10);
                        boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                        boolean isAdmin = (functie.compareTo("Administrator") == 0);
                        
                        if (!isAdmin) {  
                          // data curenta, tot ca o interogare bd =(
                          String today = "";
                          try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                              String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                              try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                      if (rs2.next()) {
                                        today = rs2.getString("today");
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
                         
                         // Obținem informații despre sediul utilizatorului
                         String userSediuNume = "";
                         String userSediuTip = "";
                         String userSediuAdresa = "";
                         double userSediuLat = 0;
                         double userSediuLong = 0;
                         
                         try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             String query = "SELECT s.id_sediu, s.nume_sediu, s.tip_sediu, s.strada, s.oras, s.judet, s.tara, s.latitudine, s.longitudine " +
                                          "FROM sedii s " +
                                          "JOIN useri u ON s.id_sediu = u.id_sediu " +
                                          "WHERE u.id = ?";
                             try (PreparedStatement stmt = con.prepareStatement(query)) {
                                 stmt.setInt(1, id);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next()) {
                                         userSediuNume = rs2.getString("nume_sediu");
                                         userSediuTip = rs2.getString("tip_sediu");
                                         userSediuAdresa = rs2.getString("strada") + ", " + 
                                                         rs2.getString("oras") + ", " + 
                                                         rs2.getString("judet") + ", " + 
                                                         rs2.getString("tara");
                                         userSediuLat = rs2.getDouble("latitudine");
                                         userSediuLong = rs2.getDouble("longitudine");
                                     }
                                 }
                             }
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                         
                         // Obținem informații despre sediul departamentului
                         String depSediuNume = "";
                         String depDepartament = "";
                         String depSediuAdresa = "";
                         double depSediuLat = 0;
                         double depSediuLong = 0;
                         double distantaKm = 0;
                         
                         try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             String query = "SELECT ld.id_dep, ld.strada, ld.oras, ld.judet, ld.tara, ld.latitudine, ld.longitudine, " +
                                          "d.nume_dep " +
                                          "FROM locatii_departamente ld " +
                                          "JOIN departament d ON ld.id_dep = d.id_dep " +
                                          "WHERE ld.id_dep = ?";
                             try (PreparedStatement stmt = con.prepareStatement(query)) {
                                 stmt.setInt(1, userDep);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next()) {
                                         depDepartament = rs2.getString("nume_dep");
                                         depSediuNume = "Sediul " + depDepartament;
                                         depSediuAdresa = rs2.getString("strada") + ", " + 
                                                         rs2.getString("oras") + ", " + 
                                                         rs2.getString("judet") + ", " + 
                                                         rs2.getString("tara");
                                         depSediuLat = rs2.getDouble("latitudine");
                                         depSediuLong = rs2.getDouble("longitudine");
                                         
                                         // Calculăm distanța dintre cele două locații
                                         if (userSediuLat != 0 && userSediuLong != 0 && depSediuLat != 0 && depSediuLong != 0) {
                                             // Convertim din grade în radiani
                                             double lat1 = Math.toRadians(userSediuLat);
                                             double lon1 = Math.toRadians(userSediuLong);
                                             double lat2 = Math.toRadians(depSediuLat);
                                             double lon2 = Math.toRadians(depSediuLong);
                                             
                                             // Formula Haversine
                                             double dlon = lon2 - lon1;
                                             double dlat = lat2 - lat1;
                                             double a = Math.pow(Math.sin(dlat / 2), 2) + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dlon / 2), 2);
                                             double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                                             
                                             // Raza Pământului în kilometri
                                             double R = 6371.0;
                                             distantaKm = Math.round((R * c) * 100.0) / 100.0;
                                         }
                                     }
                                 }
                             }
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                         
                         // Formatăm distanța pentru afișare 
                         DecimalFormat df = new DecimalFormat("0.00");
                         String distantaFormatata = df.format(distantaKm);
%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistent Baza de Date</title>
     <style>
        :root {
            --primary: <%=accent%>;
            --background: <%=clr%>;
            --surface: <%=sidebar%>;
            --text-primary: <%=text%>;
            --card: <%=card%>;
            --hover: <%=hover%>;
            --text-secondary: #64748B;
            --border: #E2E8F0;
            --success: #10B981;
            --warning: #F59E0B;
            --error: #EF4444;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        /* Enhanced styles for advanced features */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: var(--background);
            min-height: 100vh;
            color: var(--text-primary);
        }

        .chat-container {
            max-width: 1000px;
            margin: 20px auto;
            background: var(--surface);
            border-radius: 20px;
           
            overflow: hidden;
            backdrop-filter: blur(10px);
            border: 1px solid var(--border);
        }

        .chat-header {
            background: linear-gradient(45deg, var(--primary), var(--card));
            color: white;
            padding: 20px;
            text-align: center;
            position: relative;
        }

        .chat-header h1 {
            margin: 0;
            font-size: 1.8rem;
            font-weight: 600;
        }

        .ai-features {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 10px;
            flex-wrap: wrap;
        }

        .feature-badge {
            background: rgba(255,255,255,0.2);
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.8rem;
            backdrop-filter: blur(5px);
        }

        .chat-messages {
            height: 500px;
            overflow-y: auto;
            padding: 20px;
            background: var(--surface);
            scroll-behavior: smooth;
        }

        .message {
            margin-bottom: 20px;
            animation: fadeInUp 0.3s ease;
        }

        .message.user {
            text-align: right;
        }

        .message.bot {
            text-align: left;
        }

        .message-content {
            display: inline-block;
            max-width: 80%;
            padding: 15px 20px;
            border-radius: 20px;
            
        }

        .message.user .message-content {
            background: var(--primary);
            color: white;
        }

        .message.bot .message-content {
            background: var(--background);
            color: var(--primary-text);
            border: 1px solid var(--primary);
        }

        .ai-analysis {
            background: var(--background);
            border: 1px solid var(--primary);
            border-radius: 10px;
            padding: 10px;
            margin-top: 10px;
            font-size: 0.9rem;
        }

        .ai-analysis-header {
            font-weight: bold;
            color: white;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: var(--background);
            border-radius: 8px;
            overflow: hidden;
            
        }

        .data-table th {
            background: var(--primary);
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }

        .data-table td {
            padding: 12px;
            border-bottom: 1px solid var(--primary);
            color: var(--text-primary);
        }

        .data-table tr:hover {
            background: var(--hover);
        }

        .chat-input-container {
            padding: 20px;
            background: var(--surface);
            border-top: 1px solid var(--primary);
        }

        .chat-input-wrapper {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .chat-input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid var(--border);
            border-radius: 25px;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
            background: var(--background);
            color: var(--text-primary);
        }

        .chat-input:focus {
            border-color: var(--primary);
            
        }

        .send-button {
            padding: 15px 25px;
            background: var(--primary);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .send-button:hover {
            transform: translateY(-2px);
            background: black;
          
        }

        .send-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .typing-indicator {
            display: none;
            text-align: left;
            margin-bottom: 20px;
        }

        .typing-indicator .message-content {
            background: white;
            border: 1px solid var(--primary);
            padding: 15px 20px;
        }

        .typing-dots {
            display: inline-flex;
            gap: 4px;
        }

        .typing-dots span {
            width: 8px;
            height: 8px;
            background: var(--primary);
            border-radius: 50%;
            animation: typing 1.4s infinite;
        }

        .typing-dots span:nth-child(2) { animation-delay: 0.2s; }
        .typing-dots span:nth-child(3) { animation-delay: 0.4s; }

        .status-indicator {
            position: absolute;
            top: 15px;
            right: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            background: rgba(255,255,255,0.2);
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.8rem;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #4CAF50;
            animation: pulse 2s infinite;
        }

        .conversation-tools {
            padding: 10px 20px;
            background: var(--background);
            border-top: 1px solid var(--border);
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .tool-button {
            padding: 8px 16px;
            background: var(--surface);
            border: 1px solid var(--primary);
            border-radius: 15px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            color: var(--text-primary);
        }

        .tool-button:hover {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        /* Suggestions styling */
        .suggestions-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 10px 20px;
            animation: fadeIn 0.5s;
        }

        .suggestion-button {
            background-color: var(--card);
            border: 1px solid var(--primary);
            border-radius: 18px;
            padding: 8px 16px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
            color: var(--text-primary);
        }

        .suggestion-button:hover {
            background-color: var(--primary);
            color: white;
            transform: translateY(-2px);
        }

        .suggestion-button:active {
            transform: translateY(0);
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-10px); }
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .chat-container {
                margin: 10px;
                border-radius: 15px;
            }
            
            .chat-messages {
                height: 400px;
                padding: 15px;
            }
            
            .ai-features {
                gap: 8px;
            }
            
            .feature-badge {
                font-size: 0.7rem;
                padding: 3px 8px;
            }

            .message-content {
                max-width: 90%;
            }
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            <h1>🤖 Asistent Baza de Date</h1>
            <div class="ai-features">
                <div class="feature-badge">🇷🇴 Romanian</div>
                <div class="feature-badge">🧠 Data Base</div>
                <div class="feature-badge">⚡ Real-time</div>
            </div>
            <div class="status-indicator" id="statusIndicator">
                <div class="status-dot"></div>
                <span id="statusText">Connecting...</span>
            </div>
        </div>

        <div class="chat-messages" id="chatMessages">
            <div class="message bot">
                <div class="message-content">
                    <strong>🤖 Bine ați venit!</strong><br>
                    Sunt asistentul HR ce face legatura cu baza de date a companiei. 
                    Pot să vă ajut cu:
                    <ul style="margin: 10px 0; padding-left: 20px;">
                        <li>📊 Informații despre angajați și departamente</li>
                        <li>🏖️ Gestionarea concediilor și absențelor</li>
                        <li>💰 Întrebări despre salarii și beneficii</li>
                        <li>📋 Proiecte și task-uri</li>
                        <li>📄 Adeverințe și documente HR</li>
                    </ul>
                    <em>Întrebați-mă orice în română! 🧠</em>
                </div>
            </div>
        </div>

        <div class="suggestions-container" id="suggestionsContainer">
            <!-- Suggestions will be added here dynamically -->
        </div>

        <div class="typing-indicator" id="typingIndicator">
            <div class="message-content">
                🤖 Caut...
                <div class="typing-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>

        <div class="conversation-tools">
            <button class="tool-button" onclick="clearConversation()">🗑️ Ștergeți conversația</button>
            <button class="tool-button" onclick="exportConversation()">💾 Exportați</button>
            <button class="tool-button" onclick="showSuggestions()">💡 Sugestii</button>
        </div>

        <div class="chat-input-container">
            <div class="chat-input-wrapper">
                <input 
                    type="text" 
                    id="messageInput" 
                    class="chat-input" 
                    placeholder="Scrie mesajul tău aici... (ex: 'Câți angajați sunt în departamentul IT?')"
                    onkeypress="handleKeyPress(event)"
                />
                <button 
                    id="sendButton" 
                    class="send-button" 
                    onclick="sendMessage()"
                >
                    🚀 Trimiteți
                </button>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let conversationHistory = [];
        let isProcessing = false;

        // Flask configuration - FIXED to match chat.jsp
        const FLASK_CONFIG = {
            baseUrl: 'http://localhost:5000',
            queryEndpoint: '/query',  // Changed from /api/chat to /query like chat.jsp
            healthEndpoint: '/health',
            timeout: 30000,
            retryAttempts: 3
        };

        // Initialize chat - ENHANCED
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Advanced HR Assistant initialized');
            console.log('🔗 Flask endpoint:', FLASK_CONFIG.baseUrl + FLASK_CONFIG.queryEndpoint);
            
            document.getElementById('messageInput').focus();
            checkFlaskConnection();
            addDefaultSuggestions();
            loadConversationHistory();
        });

        // FIXED: Flask connection check like chat.jsp
        function checkFlaskConnection() {
            fetch(FLASK_CONFIG.baseUrl + FLASK_CONFIG.healthEndpoint, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (response.ok) {
                    console.log('✅ The server is accessible');
                    updateStatus('Online', '#4CAF50');
                } else {
                    console.warn('⚠️ The server responded with error:', response.status);
                    updateStatus('Server issue', '#FF9800');
                }
            })
            .catch(error => {
                console.error('❌ Cannot connect to the server:', error);
                updateStatus('Offline', '#FF5722');
                
                // Show connection error message
                addMessage('❌ Nu pot să mă conectez la server. Verificați dacă aplicația rulează pe portul 5000.', 'bot');
            });
        }

        // Helper function to update status
        function updateStatus(text, color) {
            const statusText = document.getElementById('statusText');
            const statusDot = document.querySelector('.status-dot');
            statusText.textContent = text;
            statusText.style.color = color;
            statusDot.style.background = color;
        }

        // Add default suggestions like chat.jsp
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
            
            const suggestionsContainer = document.getElementById('suggestionsContainer');
            suggestionsContainer.innerHTML = '';
            
            suggestions.forEach(suggestion => {
                const button = document.createElement('button');
                button.className = 'suggestion-button';
                button.textContent = suggestion;
                button.addEventListener('click', function() {
                    document.getElementById('messageInput').value = suggestion;
                    sendMessage();
                });
                
                suggestionsContainer.appendChild(button);
            });
        }

        function handleKeyPress(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        }

        // FIXED: sendMessage function based on chat.jsp
        async function sendMessage() {
            const messageInput = document.getElementById('messageInput');
            const message = messageInput.value.trim();

            if (!message || isProcessing) {
                return;
            }

            // Add user message to chat
            addMessage(message, 'user');
            messageInput.value = '';
            
            // Show typing indicator
            showTypingIndicator();
            isProcessing = true;
            updateSendButton(false);

            try {
                console.log('📤 Sending message to the server:', message);
                
                // FIXED: Use the correct Flask endpoint and format like chat.jsp
                const response = await fetch(FLASK_CONFIG.baseUrl + FLASK_CONFIG.queryEndpoint, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({
                        query: message,  // Flask expects 'query' in JSON like chat.jsp
                        session_id: 'web_session_' + Date.now(),
                        timestamp: Date.now()
                    })
                });

                console.log('📨 Server response status:', response.status);
                
                if (!response.ok) {
                    throw new Error(`Network response was not ok: ${response.status} ${response.statusText}`);
                }

                const result = await response.json();
                console.log('📊 Server parsed data:', result);
                
                // Hide typing indicator
                hideTypingIndicator();
                
                // ENHANCED: Handle different Flask response types like chat.jsp
                if (result.type === 'success' && result.result) {
                    const res = result.result;
                    
                    if (res.type === 'count_result') {
                        addMessage(res.message, 'bot');
                    } else if (res.type === 'top_salaries') {
                        addMessage(res.message, 'bot');
                        if (res.data && res.data.length > 0) {
                            setTimeout(() => {
                                addTableMessage(res.data, 'bot');
                            }, 500);
                        }
                    } else if (res.type === 'active_leaves') {
                        addMessage(res.message, 'bot');
                        if (res.data && res.data.length > 0) {
                            setTimeout(() => {
                                addTableMessage(res.data, 'bot');
                            }, 500);
                        } else {
                            addMessage('Nu există angajați în concediu astăzi.', 'bot');
                        }
                    } else if (res.data && res.data.length > 0) {
                        addMessage(res.message || 'Rezultate găsite:', 'bot');
                        setTimeout(() => {
                            addTableMessage(res.data, 'bot');
                        }, 500);
                    } else {
                        addMessage(res.message || 'Nu am găsit rezultate.', 'bot');
                    }
                    
                    // Add context suggestions
                    if (res.message && res.message.length > 10) {
                        addContextSuggestions(res.message);
                    }
                    
                } else if (result.type === 'text') {
                    addMessage(result.message, 'bot');
                    if (result.message && result.message.length > 10) {
                        addContextSuggestions(result.message);
                    }
                } else if (result.type === 'error') {
                    addMessage(result.message || 'A apărut o eroare neașteptată.', 'bot');
                    setTimeout(addDefaultSuggestions, 500);
                } else {
                    const message = result.message || result.response || JSON.stringify(result);
                    addMessage(message, 'bot');
                }
                
            } catch (error) {
                console.error('❌ Server fetch error:', error);
                
                hideTypingIndicator();
                
                let errorMessage = '❌ Eroare de conexiune cu serverul Flask:\n\n';
                
                if (error.message.includes('Failed to fetch')) {
                    errorMessage += '🔍 Nu pot să mă conectez la server =(.\n';
                    errorMessage += '💡 Verifică că app.py rulează pe http://localhost:5000\n';
                    errorMessage += '🔧 Și că nu sunt probleme de comunicare.';
                } else if (error.message.includes('404')) {
                    errorMessage += '🔍 Endpoint-ul /query nu a fost găsit.\n';
                    errorMessage += '💡 Verificați faptul că serverul folosește endpoint-ul /query.';
                } else if (error.message.includes('500')) {
                    errorMessage += '🔍 Eroare internă în server.\n';
                    errorMessage += '💡 Verificațu logurile serverului pentru detalii.';
                } else {
                    errorMessage += error.message;
                }
                
                addMessage(errorMessage, 'bot');
                setTimeout(addDefaultSuggestions, 500);
                
            } finally {
                isProcessing = false;
                updateSendButton(true);
                messageInput.focus();
            }
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
            const suggestionsContainer = document.getElementById('suggestionsContainer');
            suggestionsContainer.innerHTML = '';
            
            suggestions.forEach(suggestion => {
                const button = document.createElement('button');
                button.className = 'suggestion-button';
                button.textContent = suggestion;
                button.addEventListener('click', function() {
                    document.getElementById('messageInput').value = suggestion;
                    sendMessage();
                });
                
                suggestionsContainer.appendChild(button);
            });
        }

        function addMessage(content, sender) {
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.innerHTML = formatMessage(content);
            
            messageDiv.appendChild(contentDiv);
            chatMessages.appendChild(messageDiv);
            
            // Add timestamp
            const timeElement = document.createElement('div');
            timeElement.style.fontSize = '12px';
            timeElement.style.color = sender === 'user' ? 'rgba(255,255,255,0.7)' : '#666';
            timeElement.style.marginTop = '5px';
            timeElement.style.textAlign = sender === 'user' ? 'right' : 'left';
            const now = new Date();
            timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                     now.getMinutes().toString().padStart(2, '0');
            messageDiv.appendChild(timeElement);
            
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        // FIXED: addTableMessage function like chat.jsp
        function addTableMessage(data, sender) {
            if (!data || data.length === 0) {
                addMessage('Nu există date disponibile.', sender);
                return;
            }
            
            console.log('Rendering table with data:', data);
            
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.style.maxWidth = "95%";
            contentDiv.style.width = "auto";
            contentDiv.style.overflowX = "auto";
            
            // Get column names from first row
            const columns = Object.keys(data[0]);
            
            // Build table HTML
            let tableHTML = '';
            tableHTML += '<div style="overflow-x:auto; margin:10px 0;">';
            tableHTML += '<table class="data-table" style="width:100%; border-collapse:collapse; color:#000; background-color:#fff; border:1px solid #ddd;">';
            
            // Create header row
            tableHTML += '<thead><tr>';
            columns.forEach(column => {
                const friendlyName = formatColumnName(column);
                tableHTML += '<th style="padding:8px; text-align:left; background-color:#667eea; color:white; border:1px solid #ddd;">' + friendlyName + '</th>';
            });
            tableHTML += '</tr></thead>';
            
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
            tableHTML += '</tbody></table></div>';
            
            contentDiv.innerHTML = tableHTML;
            
            // Export button
            const exportButton = document.createElement('button');
            exportButton.textContent = 'Export CSV';
            exportButton.style.backgroundColor = '#667eea';
            exportButton.style.color = 'white';
            exportButton.style.border = 'none';
            exportButton.style.borderRadius = '4px';
            exportButton.style.padding = '5px 10px';
            exportButton.style.fontSize = '12px';
            exportButton.style.cursor = 'pointer';
            exportButton.style.margin = '5px 0';
            exportButton.addEventListener('click', function() {
                exportTableToCSV(data);
            });
            
            contentDiv.appendChild(exportButton);
            messageDiv.appendChild(contentDiv);
            
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.appendChild(messageDiv);
            
            setTimeout(() => {
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }, 100);
        }

        // Helper functions from chat.jsp
        function formatColumnName(columnName) {
            let result = columnName.replace(/_/g, ' ');
            result = result.replace(/\b\w/g, l => l.toUpperCase());
            return result;
        }
        
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

        function exportTableToCSV(data) {
            if (!data || data.length === 0) return;
            
            const columns = Object.keys(data[0]);
            let csvContent = columns.map(formatColumnName).join(',') + '\n';
            
            data.forEach(row => {
                let rowContent = columns.map(column => {
                    let value = row[column] != null ? row[column] : '';
                    if (typeof value === 'string' && value.includes(',')) {
                        return `"${value}"`;
                    }
                    return value;
                }).join(',');
                
                csvContent += rowContent + '\n';
            });
            
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

        function formatMessage(message) {
            if (typeof message !== 'string') {
                return message;
            }
            
            // Convert URLs to links
            message = message.replace(
                /(https?:\/\/[^\s]+)/g,
                '<a href="$1" target="_blank" style="color: #667eea; text-decoration: underline;">$1</a>'
            );
            
            // Convert newlines to <br>
            message = message.replace(/\n/g, '<br>');
            
            return message;
        }

        function showTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'block';
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function hideTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'none';
        }

        function updateSendButton(enabled) {
            const sendButton = document.getElementById('sendButton');
            sendButton.disabled = !enabled;
            sendButton.innerHTML = enabled ? '🚀 Trimiteți' : '⏳ Procesez...';
        }

        function clearConversation() {
            if (confirm('Sigur doriți să ștergeți conversația?')) {
                const chatMessages = document.getElementById('chatMessages');
                const messages = chatMessages.querySelectorAll('.message');
                for (let i = 1; i < messages.length; i++) {
                    messages[i].remove();
                }
                conversationHistory = [];
                addDefaultSuggestions();
            }
        }

        function loadConversationHistory() {
            // This would load from backend if implemented
            conversationHistory = [];
        }

        function exportConversation() {
            const messages = document.querySelectorAll('.message');
            let conversation = 'Conversație Asistent Baza de date\n';
            conversation += '================================\n\n';
            
            messages.forEach(message => {
                const isUser = message.classList.contains('user');
                const content = message.querySelector('.message-content').textContent;
                conversation += (isUser ? 'Tu' : 'BD') + ': ' + content + '\n\n';
            });
            
            const blob = new Blob([conversation], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            const today = new Date();
            const dateStr = today.getFullYear() + '-' + 
                          String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                          String(today.getDate()).padStart(2, '0');
            a.download = 'conversatie-hr-' + dateStr + '.txt';
            a.click();
            
            URL.revokeObjectURL(url);
        }
        
        function showSuggestions() {
            const suggestions = [
                "Câți angajați sunt în departamentul IT?",
                "Care sunt pozițiile disponibile în HR?",
                "Cine este în concediu săptămâna aceasta?",
                "Ce salarii sunt în departamentul financiar?",
                "Lista managerilor din toate departamentele",
                "Proiectele active pentru anul acesta"
            ];
            
            let suggestionsHTML = '<div style="margin-top: 10px;"><strong>💡 Sugestii de întrebări:</strong><br>';
            suggestions.forEach(function(suggestion) {
                suggestionsHTML += '<div style="margin: 5px 0; padding: 8px; background: #f0f7ff; border: 1px solid #b3d9ff; border-radius: 5px; cursor: pointer;" onclick="setSuggestion(\'' + suggestion.replace(/'/g, "\\'") + '\')">' + suggestion + '</div>';
            });
            suggestionsHTML += '</div>';
            
            addMessage(suggestionsHTML, 'bot');
        }
        
        function setSuggestion(suggestion) {
            document.getElementById('messageInput').value = suggestion;
            document.getElementById('messageInput').focus();
        }

        // Check status periodically
        setInterval(checkFlaskConnection, 30000); // Every 30 seconds
    </script>

    <%
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                out.println("alert('" + e.getMessage() + "');");
                out.println("</script>");
                if (currentUser.getTip() == 1) {
                    response.sendRedirect("tip1ok.jsp");
                }
                if (currentUser.getTip() == 2) {
                    response.sendRedirect("tip2ok.jsp");
                }
                if (currentUser.getTip() == 3) {
                    response.sendRedirect("sefok.jsp");
                }
                if (currentUser.getTip() == 0) {
                    response.sendRedirect("dashboard.jsp");
                }
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