<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🤖 Advanced HR AI Assistant</title>
    <style>
        /* Enhanced styles for advanced features */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .chat-container {
            max-width: 1000px;
            margin: 20px auto;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            backdrop-filter: blur(10px);
        }

        .chat-header {
            background: linear-gradient(45deg, #667eea, #764ba2);
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
            background: #f8f9fa;
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
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .message.user .message-content {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
        }

        .message.bot .message-content {
            background: white;
            color: #333;
            border: 1px solid #e0e0e0;
        }

        .ai-analysis {
            background: #f0f7ff;
            border: 1px solid #b3d9ff;
            border-radius: 10px;
            padding: 10px;
            margin-top: 10px;
            font-size: 0.9rem;
        }

        .ai-analysis-header {
            font-weight: bold;
            color: #0066cc;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .data-table th {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 12px;
            text-align: left;
            font-weight: 600;
        }

        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .data-table tr:hover {
            background: #f8f9fa;
        }

        .chat-input-container {
            padding: 20px;
            background: white;
            border-top: 1px solid #e0e0e0;
        }

        .chat-input-wrapper {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .chat-input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 25px;
            font-size: 16px;
            outline: none;
            transition: all 0.3s ease;
        }

        .chat-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .send-button {
            padding: 15px 25px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .send-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
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
            border: 1px solid #e0e0e0;
            padding: 15px 20px;
        }

        .typing-dots {
            display: inline-flex;
            gap: 4px;
        }

        .typing-dots span {
            width: 8px;
            height: 8px;
            background: #667eea;
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
            background: #f8f9fa;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .tool-button {
            padding: 8px 16px;
            background: white;
            border: 1px solid #ddd;
            border-radius: 15px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .tool-button:hover {
            background: #667eea;
            color: white;
            border-color: #667eea;
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
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-header">
            <h1>🤖 Advanced HR AI Assistant</h1>
            <div class="ai-features">
                <div class="feature-badge">🇷🇴 RoGPT2</div>
                <div class="feature-badge">🧠 Romanian BERT</div>
                <div class="feature-badge">🤖 TensorFlow</div>
                <div class="feature-badge">💬 Memory</div>
                <div class="feature-badge">⚡ Real-time</div>
            </div>
            <div class="status-indicator" id="statusIndicator">
                <div class="status-dot"></div>
                <span id="statusText">Online</span>
            </div>
        </div>

        <div class="chat-messages" id="chatMessages">
            <div class="message bot">
                <div class="message-content">
                    <strong>🤖 Bine ai venit!</strong><br>
                    Sunt asistentul HR avansat cu inteligență artificială românească. 
                    Pot să te ajut cu:
                    <ul style="margin: 10px 0; padding-left: 20px;">
                        <li>📊 Informații despre angajați și departamente</li>
                        <li>🏖️ Gestionarea concediilor și absențelor</li>
                        <li>💰 Întrebări despre salarii și beneficii</li>
                        <li>📋 Proiecte și task-uri</li>
                        <li>📄 Adeverințe și documente HR</li>
                    </ul>
                    <em>Întreabă-mă orice în română! Înțeleg contextul și țin minte conversația. 🧠</em>
                </div>
            </div>
        </div>

        <div class="typing-indicator" id="typingIndicator">
            <div class="message-content">
                🤖 Procesez cu AI...
                <div class="typing-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>

        <div class="conversation-tools">
            <button class="tool-button" onclick="clearConversation()">🗑️ Șterge conversația</button>
            <button class="tool-button" onclick="exportConversation()">💾 Exportă</button>
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
                    🚀 Trimite
                </button>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let conversationHistory = [];
        let isProcessing = false;

        // Initialize chat
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('messageInput').focus();
            checkSystemStatus();
            loadConversationHistory();
        });

        function handleKeyPress(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        }

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
                const response = await fetch('/api/chat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ message: message })
                });

                const result = await response.json();
                
                // Hide typing indicator
                hideTypingIndicator();
                
                // Add bot response
                addBotResponse(result);
                
            } catch (error) {
                console.error('Error:', error);
                hideTypingIndicator();
                addMessage('❌ Eroare de conexiune. Te rog încearcă din nou.', 'bot');
            } finally {
                isProcessing = false;
                updateSendButton(true);
                messageInput.focus();
            }
        }

        function addMessage(content, sender) {
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.innerHTML = content;
            
            messageDiv.appendChild(contentDiv);
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function addBotResponse(result) {
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message bot';
            
            let content = `<strong>🤖 ${result.message || 'Răspuns primit'}</strong>`;
            
            // Add data table if present
            if (result.type === 'table' && result.data && result.data.length > 0) {
                content += createDataTable(result.data);
            }
            
            // Add AI analysis if present
            if (result.ai_analysis) {
                content += createAIAnalysis(result.ai_analysis);
            }
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.innerHTML = content;
            
            messageDiv.appendChild(contentDiv);
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function createDataTable(data) {
            if (!data || data.length === 0) return '';
            
            const columns = Object.keys(data[0]);
            
            let tableHTML = '<table class="data-table"><thead><tr>';
            columns.forEach(col => {
                tableHTML += `<th>${col.charAt(0).toUpperCase() + col.slice(1)}</th>`;
            });
            tableHTML += '</tr></thead><tbody>';
            
            data.forEach(row => {
                tableHTML += '<tr>';
                columns.forEach(col => {
                    const value = row[col] || '-';
                    tableHTML += `<td>${value}</td>`;
                });
                tableHTML += '</tr>';
            });
            
            tableHTML += '</tbody></table>';
            return tableHTML;
        }

        function createAIAnalysis(analysis) {
            let analysisHTML = '<div class="ai-analysis">';
            analysisHTML += '<div class="ai-analysis-header">🧠 Analiza AI</div>';
            
            if (analysis.category) {
                analysisHTML += `<div><strong>Categorie:</strong> ${analysis.category}</div>`;
            }
            
            if (analysis.confidence) {
                const confidence = Math.round(analysis.confidence * 100);
                analysisHTML += `<div><strong>Încredere:</strong> ${confidence}%</div>`;
            }
            
            if (analysis.rogpt2_enhanced) {
                analysisHTML += '<div><strong>🇷🇴 RoGPT2:</strong> Răspuns îmbunătățit în română</div>';
            }
            
            if (analysis.conversation_aware) {
                analysisHTML += '<div><strong>💬 Context:</strong> Conversație continuă</div>';
            }
            
            if (analysis.sql_explanation) {
                analysisHTML += `<div><strong>SQL:</strong> ${analysis.sql_explanation}</div>`;
            }
            
            if (analysis.execution_time) {
                analysisHTML += `<div><strong>Timp execuție:</strong> ${analysis.execution_time}</div>`;
            }
            
            analysisHTML += '</div>';
            return analysisHTML;
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
            sendButton.innerHTML = enabled ? '🚀 Trimite' : '⏳ Procesez...';
        }

     // 🔧 FIXED: Funcția checkSystemStatus
        async function checkSystemStatus() {
            try {
                console.log('🔍 Checking system status...');
                
                // Încearcă mai multe URL-uri
                const possibleUrls = [
                    '/health',
                    'http://localhost:5000/health',
                    'http://127.0.0.1:5000/health'
                ];
                
                let response = null;
                let lastError = null;
                
                for (const url of possibleUrls) {
                    try {
                        console.log(`🔗 Trying: ${url}`);
                        response = await fetch(url);
                        if (response.ok) {
                            console.log(`✅ Success with: ${url}`);
                            break;
                        }
                    } catch (error) {
                        console.log(`❌ Failed with ${url}:`, error);
                        lastError = error;
                        continue;
                    }
                }
                
                if (!response || !response.ok) {
                    throw lastError || new Error('All URLs failed');
                }
                
                const status = await response.json();
                console.log('📊 Status received:', status);
                
                const statusText = document.getElementById('statusText');
                const statusDot = document.querySelector('.status-dot');
                
                if (status.nlp_processor === 'ready' && status.queryservlet_connected) {
                    statusText.textContent = 'Online';
                    statusText.style.color = '#4CAF50';
                    statusDot.style.background = '#4CAF50';
                } else if (status.queryservlet_connected) {
                    statusText.textContent = 'Parțial';
                    statusText.style.color = '#FF9800';
                    statusDot.style.background = '#FF9800';
                } else {
                    statusText.textContent = 'Parțial';
                    statusText.style.color = '#FF9800';
                    statusDot.style.background = '#FF9800';
                }
                
            } catch (error) {
                console.error('❌ Status check failed:', error);
                const statusText = document.getElementById('statusText');
                const statusDot = document.querySelector('.status-dot');
                statusText.textContent = 'Conectând...';
                statusText.style.color = '#FF5722';
                statusDot.style.background = '#FF5722';
            }
        }

        // 🔧 FIXED: Funcția sendMessage
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
                console.log('📤 Sending message:', message);
                
                // Încearcă mai multe URL-uri pentru chat
                const possibleUrls = [
                    '/api/chat',
                    'http://localhost:5000/api/chat',
                    'http://127.0.0.1:5000/api/chat'
                ];
                
                let response = null;
                let lastError = null;
                
                for (const url of possibleUrls) {
                    try {
                        console.log(`🔗 Trying chat URL: ${url}`);
                        response = await fetch(url, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                            },
                            body: JSON.stringify({ message: message })
                        });
                        
                        if (response.ok) {
                            console.log(`✅ Chat success with: ${url}`);
                            break;
                        }
                    } catch (error) {
                        console.log(`❌ Chat failed with ${url}:`, error);
                        lastError = error;
                        continue;
                    }
                }
                
                if (!response || !response.ok) {
                    throw lastError || new Error('All chat URLs failed');
                }

                const result = await response.json();
                console.log('📨 Response received:', result);
                
                // Hide typing indicator
                hideTypingIndicator();
                
                // Add bot response
                addBotResponse(result);
                
            } catch (error) {
                console.error('❌ Send message error:', error);
                hideTypingIndicator();
                addMessage(`❌ Eroare de conexiune: ${error.message}. Flask rulează pe localhost:5000?`, 'bot');
            } finally {
                isProcessing = false;
                updateSendButton(true);
                messageInput.focus();
            }
        }

        async function clearConversation() {
            if (confirm('Sigur vrei să ștergi conversația?')) {
                try {
                    await fetch('/clear-conversation', { method: 'POST' });
                    
                    // Clear chat messages except welcome message
                    const chatMessages = document.getElementById('chatMessages');
                    const messages = chatMessages.querySelectorAll('.message');
                    for (let i = 1; i < messages.length; i++) {
                        messages[i].remove();
                    }
                    
                    conversationHistory = [];
                    
                } catch (error) {
                    console.error('Error clearing conversation:', error);
                }
            }
        }

        async function loadConversationHistory() {
            try {
                const response = await fetch('/conversation-history');
                const data = await response.json();
                conversationHistory = data.conversation_history || [];
            } catch (error) {
                console.error('Error loading conversation history:', error);
            }
        }

     // 🔧 FIXED: Escape JavaScript pentru JSP
        function exportConversation() {
            const messages = document.querySelectorAll('.message');
            let conversation = 'Conversație HR AI Assistant\n';
            conversation += '================================\n\n';
            
            messages.forEach(message => {
                const isUser = message.classList.contains('user');
                const content = message.querySelector('.message-content').textContent;
                conversation += (isUser ? 'Tu' : 'AI') + ': ' + content + '\n\n';
            });
            
            const blob = new Blob([conversation], { type: 'text/plain' });
            const url = URL.createObjectURL(blob);
            
            const a = document.createElement('a');
            a.href = url;
            // 🔧 FIXED: Evită EL expression în JavaScript
            const today = new Date();
            const dateStr = today.getFullYear() + '-' + 
                          String(today.getMonth() + 1).padStart(2, '0') + '-' + 
                          String(today.getDate()).padStart(2, '0');
            a.download = 'conversatie-hr-' + dateStr + '.txt';
            a.click();
            
            URL.revokeObjectURL(url);
        }
        
        // 🔧 FIXED: Toate funcțiile JavaScript corectate
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
                // 🔧 FIXED: Escape single quotes
                const escapedSuggestion = suggestion.replace(/'/g, "\\'");
                suggestionsHTML += '<div style="margin: 5px 0; padding: 5px; background: #f0f0f0; border-radius: 5px; cursor: pointer;" onclick="setSuggestion(\'' + escapedSuggestion + '\')">' + suggestion + '</div>';
            });
            suggestionsHTML += '</div>';
            
            addMessage(suggestionsHTML, 'bot');
        }
        
        // 🔧 NEW: Helper function pentru suggestions
        function setSuggestion(suggestion) {
            document.getElementById('messageInput').value = suggestion;
        }
        // Check status periodically
        setInterval(checkSystemStatus, 30000); // Every 30 seconds
    </script>
</body>
</html>