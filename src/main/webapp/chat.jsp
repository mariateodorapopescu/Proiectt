<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

// Verificare sesiune și extragere date utilizator
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement("SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                        "dp.denumire_completa AS denumire FROM useri u " +
                        "JOIN tipuri t ON u.tip = t.tip " +
                        "JOIN departament d ON u.id_dep = d.id_dep " +
                        "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                        "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int id = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    
                    // Extragere data curentă
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
                    
                    // Extragere tematică de culoare
                    String accent = "#10439F";
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
    <title>🤖 Asistent HR AI</title>

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
        
        /* Container și layout principal */
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .chat-container {
            background-color: #fff;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
            overflow: hidden;
            /* FLEXBOX WITH FULL PREFIXES */
            -webkit-box: block;
            -webkit-flex: block;
            -ms-flexbox: block;
            -webkit-box-orient: vertical;
            -webkit-box-direction: normal;
            -webkit-flex-direction: column;
            -ms-flex-direction: column;
            flex-direction: column;
            height: calc(100vh - 40px);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        /* Header chat */
        .chat-header {
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%);
            color: white;
            padding: 20px;
            font-weight: bold;
            font-size: 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: -webkit-box;
            display: -webkit-flex;
            display: -ms-flexbox;
            display: flex;
            -webkit-box-pack: justify;
            -webkit-justify-content: space-between;
            -ms-flex-pack: justify;
            justify-content: space-between;
            -webkit-box-align: center;
            -webkit-align-items: center;
            -ms-flex-align: center;
            align-items: center;
            position: relative;
        }
        
        .chat-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255,255,255,0.1) 50%, transparent 70%);
            animation: shimmer 3s infinite;
        }
        
        .chat-title {
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 1;
        }
        
        .ai-badge {
            background: rgba(255,255,255,0.2);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            backdrop-filter: blur(10px);
        }
        
        .chat-status {
            font-size: 14px;
            opacity: 0.9;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 1;
        }
        
        .status-dot {
            width: 8px;
            height: 8px;
            background: #4CAF50;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }
        
        .help-tooltip {
            position: relative;
            display: inline-block;
            margin-left: 10px;
            cursor: pointer;
        }
        
        .help-icon {
            width: 24px;
            height: 24px;
            background-color: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            font-weight: bold;
            transition: all 0.3s ease;
        }
        
        .help-icon:hover {
            background-color: rgba(255,255,255,0.3);
            transform: scale(1.1);
        }
        
        .tooltip-content {
            position: absolute;
            top: 35px;
            right: 0;
            background-color: white;
            color: #333;
            padding: 15px;
            border-radius: 10px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            width: 280px;
            z-index: 100;
            display: none;
            font-weight: normal;
            text-align: left;
            font-size: 13px;
            line-height: 1.5;
            border: 1px solid rgba(0,0,0,0.1);
        }
        
        .help-tooltip:hover .tooltip-content {
            display: block;
            animation: fadeInDown 0.3s ease;
        }
        
        /* Zona mesaje */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 25px;
            scroll-behavior: smooth;
            background: linear-gradient(to bottom, #f8f9fa 0%, #ffffff 100%);
        }
        
        .message {
            margin-bottom: 20px;
            max-width: 85%;
            animation: slideInUp 0.4s ease;
            position: relative;
        }
        
        .user-message {
            margin-left: auto;
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%);
            color: white;
            border-radius: 20px 20px 5px 20px;
            padding: 15px 20px;
            box-shadow: 0 4px 15px rgba(0,123,255,0.3);
            position: relative;
            overflow: hidden;
        }
        
        .user-message::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: left 0.5s;
        }
        
        .user-message:hover::before {
            left: 100%;
        }
        
        .bot-message {
            margin-right: auto;
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
            border-radius: 20px 20px 20px 5px;
            padding: 15px 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            border: 1px solid rgba(0,0,0,0.05);
            position: relative;
        }
        
        .message-time {
            font-size: 11px;
            color: rgba(255,255,255,0.7);
            margin-top: 8px;
            text-align: right;
        }
        
        .bot-message .message-time {
            color: #888;
            text-align: left;
        }
        
        /* Indicator de typing */
        .bot-typing {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            opacity: 0.8;
        }
        
        .typing-indicator {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            background: linear-gradient(135deg, #f1f1f1 0%, #e9e9e9 100%);
            border-radius: 20px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        }
        
        .typing-dot {
            height: 10px;
            width: 10px;
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%);
            border-radius: 50%;
            margin: 0 3px;
            animation: bounce 1.5s infinite;
        }
        
        .typing-dot:nth-child(2) { animation-delay: 0.3s; }
        .typing-dot:nth-child(3) { animation-delay: 0.6s; }
        
        /* Sugestii */
        .suggestions-container {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin: 15px 25px;
            animation: fadeIn 0.6s ease;
            padding: 15px;
            background: linear-gradient(135deg, rgba(255,255,255,0.9) 0%, rgba(248,249,250,0.9) 100%);
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }

        .suggestion-button {
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
            border: 2px solid var(--bg, #007bff);
            border-radius: 25px;
            padding: 10px 18px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            white-space: nowrap;
            box-shadow: 0 4px 15px rgba(0,123,255,0.15);
            color: var(--bg, #007bff);
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }

        .suggestion-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: var(--bg, #007bff);
            transition: left 0.3s ease;
            z-index: -1;
        }

        .suggestion-button:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,123,255,0.3);
        }

        .suggestion-button:hover::before {
            left: 0;
        }

        .suggestion-button:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(0,123,255,0.2);
        }
        
        /* Zona input */
        .chat-input {
            display: flex;
            padding: 20px;
            border-top: 1px solid rgba(0,0,0,0.08);
            background: linear-gradient(135deg, #fff 0%, #f8f9fa 100%);
            position: relative;
        }
        
        .chat-input::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--bg, #007bff), transparent);
        }
        
        .chat-input textarea {
            flex: 1;
            border: 2px solid #e9ecef;
            border-radius: 25px;
            padding: 15px 50px 15px 20px;
            font-size: 16px;
            resize: none;
            outline: none;
            max-height: 120px;
            min-height: 50px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
            background: #fff;
            font-family: inherit;
        }
        
        .chat-input textarea:focus {
            border-color: var(--bg, #007bff);
            box-shadow: 0 4px 20px rgba(0,123,255,0.2);
            transform: translateY(-1px);
        }
        
        .chat-input button {
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%);
            color: white;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            margin-left: 15px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 15px rgba(0,123,255,0.3);
            position: relative;
            overflow: hidden;
        }
        
        .chat-input button::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255,255,255,0.3);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: all 0.3s ease;
        }
        
        .chat-input button:hover {
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 8px 25px rgba(0,123,255,0.4);
        }
        
        .chat-input button:hover::before {
            width: 100%;
            height: 100%;
        }
        
        .chat-input button:active {
            transform: translateY(-1px) scale(1.02);
        }
        
        .chat-input button:disabled {
            background: linear-gradient(135deg, #cccccc 0%, #999999 100%);
            cursor: not-allowed;
            transform: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        /* Tabele */
        .result-table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
            font-size: 14px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            background: #fff;
            /* IMPORTANT: Force visibility */
            display: table !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .result-table th {
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%);
            color: white;
            font-weight: 600;
            text-align: left;
            padding: 15px;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .result-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #f1f3f4;
            transition: all 0.2s ease;
        }
        
        .result-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        
        .result-table tr:hover {
            background: linear-gradient(135deg, rgba(0,123,255,0.05) 0%, rgba(0,123,255,0.02) 100%);
            transform: scale(1.01);
        }
        
        .result-table tr:last-child td {
            border-bottom: none;
        }
        
        /* Container pentru tabele mari */
        .table-container {
            max-height: 400px;
            overflow-y: auto;
            margin: 15px 0;
            border-radius: 12px;
            border: 1px solid #e9ecef;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            background: white;
            /* IMPORTANT: Ensure visibility */
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        /* Acțiuni pentru tabele */
        .table-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin: 8px 0 15px;
        }
        
        .table-action-button {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 8px 12px;
            font-size: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            color: #495057;
        }
        
        .table-action-button:hover {
            background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
            transform: translateY(-1px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        /* Animații */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .message {
                max-width: 95%;
            }
            
            .suggestions-container {
                justify-content: center;
                margin: 10px 15px;
                padding: 10px;
            }
            
            .suggestion-button {
                font-size: 12px;
                padding: 8px 14px;
            }
            
            .chat-header {
                padding: 15px;
                font-size: 20px;
            }
            
            .chat-input {
                padding: 15px;
            }
            
            .chat-input textarea {
                padding: 12px 40px 12px 15px;
                font-size: 14px;
            }
            
            .chat-input button {
                width: 45px;
                height: 45px;
                margin-left: 10px;
            }
        }
        
        /* Scrollbar personalizat */
        .chat-messages::-webkit-scrollbar {
            width: 6px;
        }
        
        .chat-messages::-webkit-scrollbar-track {
            background: #f1f3f4;
            border-radius: 10px;
        }
        
        .chat-messages::-webkit-scrollbar-thumb {
            background: var(--bg, #007bff);
            border-radius: 10px;
        }
        
        .chat-messages::-webkit-scrollbar-thumb:hover {
            background: var(--hover, #0056b3);
        }
        
        /* FORȚARE vizibilitate pentru tabele */
        .table-message-forced {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
            background: white !important;
            border-radius: 20px !important;
            padding: 15px 20px !important;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08) !important;
            border: 1px solid rgba(0,0,0,0.05) !important;
            position: relative !important;
            z-index: 10 !important;
            clear: both !important;
            margin-right: auto !important;
            margin-left: 0 !important;
            margin-bottom: 20px !important;
            max-width: 95% !important;
        }
        
        .table-message-forced * {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .table-message-forced table {
            display: table !important;
            width: 100% !important;
            border-collapse: collapse !important;
            background: white !important;
            position: relative !important;
            z-index: 100 !important;
        }
        
        .table-message-forced th {
            display: table-cell !important;
            background: linear-gradient(135deg, var(--bg) 0%, var(--hover) 100%) !important;
            color: white !important;
            padding: 12px !important;
        }
        
        .table-message-forced td {
            display: table-cell !important;
            padding: 12px !important;
            border-bottom: 1px solid #f1f3f4 !important;
            background: white !important;
        }
        
        .table-message-forced .table-actions {
            display: -webkit-box !important;
            display: -webkit-flex !important;
            display: -ms-flexbox !important;
            display: flex !important;
            -webkit-box-pack: end !important;
            -webkit-justify-content: flex-end !important;
            -ms-flex-pack: end !important;
            justify-content: flex-end !important;
            gap: 10px !important;
            margin: 8px 0 15px !important;
        }
        
        /* CSS safe pentru template HTML */
        .safe-table-container {
            max-height: 400px !important;
            overflow-y: auto !important;
            margin: 15px 0 !important;
            border-radius: 12px !important;
            border: 1px solid #e9ecef !important;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08) !important;
            background: white !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .safe-actions-container {
            margin: 8px 0 15px !important;
            text-align: right !important;
        }
        
        .safe-export-button {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%) !important;
            border: 1px solid #dee2e6 !important;
            border-radius: 8px !important;
            padding: 8px 12px !important;
            font-size: 12px !important;
            cursor: pointer !important;
            color: #495057 !important;
            transition: all 0.2s ease !important;
        }
        
        .safe-export-button:hover {
            background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%) !important;
            transform: translateY(-1px) !important;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1) !important;
        }
        
        .table-message {
            margin-bottom: 20px !important;
            max-width: 95% !important;
            background: white !important;
            border-radius: 15px !important;
            padding: 20px !important;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08) !important;
            border: 1px solid rgba(0,0,0,0.05) !important;
        }
        
        .simple-table {
            width: 100% !important;
            border-collapse: collapse !important;
            margin: 0 !important;
            background: white !important;
            border-radius: 8px !important;
            overflow: hidden !important;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1) !important;
        }
        
        .simple-table th {
            background: linear-gradient(135deg, var(--bg, #007bff) 0%, var(--hover, #0056b3) 100%) !important;
            color: white !important;
            padding: 15px 12px !important;
            text-align: left !important;
            font-weight: 600 !important;
            font-size: 13px !important;
        }
        
        .simple-table td {
            padding: 12px !important;
            border-bottom: 1px solid #f1f3f4 !important;
            background: white !important;
            font-size: 14px !important;
        }
        
        .simple-table tr:nth-child(even) td {
            background: #f8f9fa !important;
        }
        
        .simple-table tr:hover td {
            background: rgba(0,123,255,0.08) !important;
        }
        
        .table-container {
            max-height: 400px !important;
            overflow-y: auto !important;
            border-radius: 8px !important;
            margin: 15px 0 !important;
        }
        
        .export-button {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%) !important;
            border: 1px solid #dee2e6 !important;
            border-radius: 6px !important;
            padding: 8px 12px !important;
            font-size: 12px !important;
            cursor: pointer !important;
            color: #495057 !important;
            margin-top: 10px !important;
            float: right !important;
        }
        
        .export-button:hover {
            background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%) !important;
            transform: translateY(-1px) !important;
        }
        
        /* Override any conflicting styles */
        .bot-message table {
            display: table !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        
        .bot-message th,
        .bot-message td {
            display: table-cell !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
    </style>
    
    <!--=============== icon ===============-->
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>;">

    <div class="container">
        <div class="chat-container">
            <div class="chat-header">
                <div class="chat-title">
                    <i class="ri-robot-2-line" style="font-size: 28px;"></i>
                    <div>
                        <div>🤖 Asistent HR AI</div>
                        <div class="ai-badge">Powered by NaturalLanguageToSQL</div>
                    </div>
                </div>
                <div class="chat-status">
                    <div class="status-dot"></div>
                    <span id="statusText">Online</span>
                    <div class="help-tooltip">
                        <div class="help-icon">?</div>
                        <div class="tooltip-content">
                            <strong>🤖 Cum să folosești asistentul:</strong><br><br>
                            • <strong>Întreabă natural:</strong> "Câți angajați sunt în HR?"<br>
                            • <strong>Solicită detalii:</strong> Spune "Da" pentru mai multe informații<br>
                            • <strong>Folosește sugestiile:</strong> Click pe butoanele de mai jos<br>
                            • <strong>Teme disponibile:</strong> Angajați, departamente, concedii, proiecte<br><br>
                            <em>💡 Algoritmul înțelege limba română!</em>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="chat-messages" id="chatMessages">
                <div class="message bot-message">
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 10px;">
                        <i class="ri-sparkling-line" style="font-size: 20px; color: var(--bg);"></i>
                        <strong>Bine ați venit în viitorul HR-ului!</strong>
                    </div>
                    <p>Sunt asistentul HR cu inteligență artificială, alimentat de algoritmi avansați de procesare a limbajului natural. Vă pot oferi informații detaliate despre:</p>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin: 15px 0;">
                        <div style="padding: 10px; background: rgba(0,123,255,0.05); border-radius: 8px; border-left: 3px solid var(--bg);">
                            <strong>👥 Resurse Umane</strong><br>
                            <small>Angajați, departamente, organigrame</small>
                        </div>
                        <div style="padding: 10px; background: rgba(0,123,255,0.05); border-radius: 8px; border-left: 3px solid var(--bg);">
                            <strong>🏖️ Management Concedii</strong><br>
                            <small>Planificare, aprobare, statistici</small>
                        </div>
                        <div style="padding: 10px; background: rgba(0,123,255,0.05); border-radius: 8px; border-left: 3px solid var(--bg);">
                            <strong>💰 Analize Salariale</strong><br>
                            <small>Poziții, remunerații, beneficii</small>
                        </div>
                        <div style="padding: 10px; background: rgba(0,123,255,0.05); border-radius: 8px; border-left: 3px solid var(--bg);">
                            <strong>📋 Gestiune Proiecte</strong><br>
                            <small>Echipe, task-uri, progres</small>
                        </div>
                    </div>
                    <p style="margin-top: 15px;"><strong>🚀 Cum funcționează:</strong> Îmi scrieți întrebarea în română, eu o transform automat în interogări SQL și vă ofer răspunsurile într-un format ușor de înțeles!</p>
                </div>
            </div>
            
            <div class="suggestions-container" id="suggestionsContainer">
                <div style="width: 100%; text-align: center; margin-bottom: 10px; color: var(--bg); font-weight: 600;">
                    <i class="ri-lightbulb-line"></i> Exemple de întrebări inteligente:
                </div>
                <!-- Sugestiile vor fi adăugate dinamic -->
            </div>
            
            <div class="chat-input">
                <textarea id="userInput" placeholder="Scrieți întrebarea dvs. aici... (ex: 'Câți angajați din IT sunt în concediu?')" rows="1" oninput="adjustTextareaHeight(this)"></textarea>
                <button id="sendButton" onclick="sendMessage()">
                    <i class="ri-send-plane-2-line" style="font-size: 20px;"></i>
                </button>
            </div>
        </div>
    </div>
    
    <script>
    // Inițializare chat
    document.addEventListener('DOMContentLoaded', function() {
        console.log('🤖 Chat AI interface initialized');
        
        // Adaugă sugestii default
        addDefaultSuggestions();
        
        // Focus pe input
        document.getElementById('userInput').focus();
        
        // Setup event listeners
        setupEventListeners();
        
        // Verifică starea sistemului
        checkSystemStatus();
    });
    
    // Elemente DOM
    const chatMessages = document.getElementById('chatMessages');
    const userInput = document.getElementById('userInput');
    const sendButton = document.getElementById('sendButton');
    const suggestionsContainer = document.getElementById('suggestionsContainer');
    
    // Storage pentru follow-up
    let lastQueryData = null;
    let lastQueryContext = '';
    
    // Setup event listeners
    function setupEventListeners() {
        // Enter pentru trimitere
        userInput.addEventListener('keydown', function(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        });
        
        // Click pentru trimitere
        sendButton.addEventListener('click', sendMessage);
    }

    // Adaugă sugestii default
    function addDefaultSuggestions() {
        const suggestions = [
            'Câți angajați sunt în departamentul HR? 👥',
            'Cine este în concediu astăzi? 🏖️',
            'Arată-mi departamentele din firmă 🏢',
            'Care sunt salariile pozițiilor din IT? 💻',
            'Ce tipuri de poziții există în HR? 📋',
            'Proiecte active în prezent 🚀',
            'Adeverințe în așteptare 📄',
            'Care departament are cei mai mulți angajați? 📊'
        ];
        
        // Păstrează textul de introducere
        const introText = suggestionsContainer.querySelector('div');
        suggestionsContainer.innerHTML = '';
        if (introText) {
            suggestionsContainer.appendChild(introText);
        }
        
        suggestions.forEach(suggestion => {
            const button = document.createElement('button');
            button.className = 'suggestion-button';
            button.innerHTML = suggestion;
            button.addEventListener('click', function() {
                // Elimină emoji-ul din text
                const cleanSuggestion = suggestion.replace(/[^\w\s\u0080-\uFFFF]/g, '').trim();
                userInput.value = cleanSuggestion;
                adjustTextareaHeight(userInput);
                sendMessage();
            });
            
            suggestionsContainer.appendChild(button);
        });
    }
    
    // Adaugă sugestii contextuale
    function addContextSuggestions(context) {
        const contextSuggestions = {
            'angajați': [
                'Câți angajați sunt în total? 📊',
                'Care sunt angajații din IT? 💻',
                'Angajații cu cele mai mari salarii 💰',
                'Angajații noi din această lună 🆕'
            ],
            'departamente': [
                'Care departament are cei mai mulți angajați? 📈',
                'Câte departamente avem în firmă? 🏢',
                'Locațiile departamentelor 📍',
                'Managerii de departament 👔'
            ],
            'concedii': [
                'Cine este în concediu săptămâna aceasta? 📅',
                'Concedii planificate pentru luna aceasta 🗓️',
                'Concedii de Crăciun 🎄',
                'Concedii medicale 🏥'
            ],
            'poziții': [
                'Ce tipuri de poziții există? 📋',
                'Pozițiile din IT 💻',
                'Pozițiile cu cele mai mari salarii 💎',
                'Poziții disponibile 🔍'
            ],
            'salarii': [
                'Care este salariul mediu în firmă? 💰',
                'Top 5 cele mai mari salarii 🏆',
                'Salarii pe departamente 📊',
                'Comparație salarii IT vs HR 📈'
            ],
            'proiecte': [
                'Câte proiecte active avem? 🚀',
                'Cine lucrează la proiectele active? 👥',
                'Status-ul taskurilor din proiecte ✅',
                'Proiecte finalizate recent 🎯'
            ]
        };
        
        let suggestions = [];
        for (const [key, value] of Object.entries(contextSuggestions)) {
            if (context.toLowerCase().includes(key)) {
                suggestions = value;
                break;
            }
        }
        
        if (suggestions.length === 0) {
            return;
        }
        
        // Update sugestii
        const introText = suggestionsContainer.querySelector('div');
        suggestionsContainer.innerHTML = '';
        if (introText) {
            suggestionsContainer.appendChild(introText);
        }
        
        suggestions.forEach(suggestion => {
            const button = document.createElement('button');
            button.className = 'suggestion-button';
            button.innerHTML = suggestion;
            button.addEventListener('click', function() {
                // Elimină emoji-ul din text
                const cleanSuggestion = suggestion.replace(/[^\w\s\u0080-\uFFFF]/g, '').trim();
                userInput.value = cleanSuggestion;
                adjustTextareaHeight(userInput);
                sendMessage();
            });
            
            suggestionsContainer.appendChild(button);
        });
    }
    
    // Verifică starea sistemului
    function checkSystemStatus() {
        // Simulează verificarea stării
        const statusText = document.getElementById('statusText');
        const statusDot = document.querySelector('.status-dot');
        
        // Setează ca online
        statusText.textContent = 'Online';
        statusDot.style.background = '#4CAF50';
        
        console.log('✅ System status: Online');
    }
    
    // Trimite mesaj
    function sendMessage() {
        const message = userInput.value.trim();
        if (message === '') return;
        
        console.log('📤 Sending message:', message);
        
        // Adaugă mesajul utilizatorului
        addMessage(message, 'user');
        
        // Curăță input-ul
        userInput.value = '';
        adjustTextareaHeight(userInput);
        
        // Arată indicatorul de typing
        showTypingIndicator();
        
        // Dezactivează input-ul
        setInputEnabled(false);
        
        // URL-ul servlet-ului 
        const contextPath = '<%= request.getContextPath() %>';
        const servletUrl = contextPath + '/ChatServlet';
        
        console.log('🔗 Using servlet URL:', servletUrl);
        
        // Trimite la server
        fetch(servletUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            },
            body: 'query=' + encodeURIComponent(message)
        })
        .then(response => {
            console.log('📡 Response status:', response.status);
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.status);
            }
            return response.text().then(text => {
                console.log('📜 Raw response:', text);
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('❌ JSON parse error:', e);
                    throw new Error('Invalid JSON response: ' + e.message);
                }
            });
        })
        .then(data => {
            console.log('✅ Parsed data:', data);
            
            // Ascunde indicatorul de typing
            hideTypingIndicator();
            
            // Reactivează input-ul
            setInputEnabled(true);
            
            // Procesează diferite tipuri de răspuns
            if (data.type === 'text' || data.type === 'enhanced_text') {
                // Handle both 'text' and 'enhanced_text' types
                addMessage(data.message, 'bot');
                
                // Add context suggestions based on entity type or message content
                if (data.entityType) {
                    addContextSuggestions(data.entityType);
                } else {
                    addContextSuggestions(data.message);
                }
            } else if (data.type === 'table') {
                // Adaugă mesajul înainte de tabel
                addMessage(data.message, 'bot');
                
                if (data.data && data.data.length > 0) {
                    // Stochează datele pentru follow-up
                    lastQueryData = data.data;
                    lastQueryContext = getContextFromData(data.data);
                    
                    console.log('📊 Displaying table with', data.data.length, 'rows');
                    
                    // Afișează tabelul imediat (fără să aștepte confirmare)
                    setTimeout(() => {
                        addTableMessage(data.data, 'bot');
                        addContextSuggestions(lastQueryContext);
                    }, 300);
                } else {
                    console.log('⚠️ No data in table response');
                }
            } else if (data.type === 'error') {
                addMessage('❌ ' + data.message, 'bot', 'error');
                setTimeout(addDefaultSuggestions, 500);
            } else {
                // Fallback pentru orice alt tip de răspuns
                console.log('🔄 Unknown response type:', data.type, 'treating as text');
                addMessage(data.message || 'Răspuns primit', 'bot');
                
                if (data.entityType) {
                    addContextSuggestions(data.entityType);
                }
            }
        })
        .catch(error => {
            console.error('❌ Fetch error:', error);
            
            hideTypingIndicator();
            setInputEnabled(true);
            
            addMessage('❌ Îmi pare rău, a apărut o eroare în comunicarea cu serverul: ' + error.message, 'bot', 'error');
            setTimeout(addDefaultSuggestions, 500);
        });
    }
    
    // Determină contextul din date
    function getContextFromData(data) {
        if (!data || data.length === 0) return '';
        
        const sample = data[0];
        let contextString = '';
        
        if (sample.departament || sample.nume_dep) contextString += ' departamente';
        if (sample.nume && sample.prenume) contextString += ' angajați';
        if (sample.data_inceput || sample.start_c) contextString += ' concedii';
        if (sample.functie || sample.denumire || sample.salariu) contextString += ' poziții salarii';
        if (sample.nume_proiect || sample.nume_task) contextString += ' proiecte';
        if (sample.tip_adeverinta) contextString += ' adeverințe';
        
        return contextString;
    }
    
    // Adaugă butoane de confirmare
    function addConfirmationButtons() {
        const confirmationDiv = document.createElement('div');
        confirmationDiv.className = 'confirmation-buttons';
        confirmationDiv.style.cssText = `
            display: flex;
            gap: 12px;
            margin-top: 15px;
            justify-content: center;
        `;
        
        const yesButton = document.createElement('button');
        yesButton.className = 'suggestion-button';
        yesButton.innerHTML = '✅ Da, vreau să văd detaliile';
        yesButton.style.cssText = `
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            border: none;
            font-weight: 600;
        `;
        yesButton.addEventListener('click', function() {
            confirmationDiv.remove();
            if (lastQueryData && lastQueryData.length > 0) {
                addTableMessage(lastQueryData, 'bot');
                addContextSuggestions(lastQueryContext);
                lastQueryData = null;
            }
        });
        
        const noButton = document.createElement('button');
        noButton.className = 'suggestion-button';
        noButton.innerHTML = '❌ Nu, mulțumesc';
        noButton.style.cssText = `
            background: linear-gradient(135deg, #dc3545 0%, #fd7e14 100%);
            color: white;
            border: none;
            font-weight: 600;
        `;
        noButton.addEventListener('click', function() {
            confirmationDiv.remove();
            lastQueryData = null;
            addMessage('✅ În regulă. Cu ce altceva vă pot ajuta?', 'bot');
            addDefaultSuggestions();
        });
        
        confirmationDiv.appendChild(yesButton);
        confirmationDiv.appendChild(noButton);
        
        // Adaugă la ultimul mesaj bot
        const lastBotMessage = Array.from(chatMessages.querySelectorAll('.bot-message'))
            .filter(el => !el.classList.contains('bot-typing'))
            .pop();
            
        if (lastBotMessage) {
            lastBotMessage.appendChild(confirmationDiv);
        }
    }

    // Adaugă mesaj text
    function addMessage(message, sender, type) {
        console.log('💬 Adding message:', { message, sender, type });
        
        const messageElement = document.createElement('div');
        messageElement.classList.add('message');
        messageElement.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
        
        if (type === 'error') {
            messageElement.style.cssText = `
                background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
                color: #c62828;
                border-left: 4px solid #c62828;
            `;
        }
        
        messageElement.innerHTML = formatMessage(message);
        
        chatMessages.appendChild(messageElement);
        
        // Adaugă timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                 now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        scrollToBottom();
        
        console.log('✅ Message added successfully');
    }
    
 // Your current addTableMessage function is good! Here are some small improvements to make it even more stable:

    function addTableMessage(data, sender) {
        if (!data || data.length === 0) {
            addMessage('Nu există date disponibile.', sender);
            return;
        }
        
        console.log('Rendering table with data:', data);
        
        // Create message container with explicit inline styles (most reliable)
        const messageElement = document.createElement('div');
        messageElement.classList.add('message', 'bot-message');
        messageElement.style.cssText = `
            max-width: 95% !important;
            width: auto !important;
            overflow-x: auto !important;
            background-color: #f8f9fa !important;
            border-radius: 18px !important;
            padding: 12px 18px !important;
            margin-bottom: 15px !important;
            margin-right: auto !important;
        `;
        
        // Get column names from first row
        const columns = Object.keys(data[0]);
        
        // Build table HTML with explicit styling for maximum compatibility
        let tableHTML = '';
        tableHTML += '<div style="overflow-x:auto; margin:10px 0; border-radius: 8px; border: 1px solid #ddd;">';
        tableHTML += '<table style="width:100%; border-collapse:collapse; color:#000; background-color:#fff; font-size: 14px;">';
        
        // Create header row with strong inline styles
        tableHTML += '<thead>';
        tableHTML += '<tr>';
        columns.forEach(column => {
            const friendlyName = formatColumnName(column);
            tableHTML += `<th style="padding:10px; text-align:left; background-color:#f5f5f5; color:#333; border:1px solid #ddd; font-weight: bold;">${friendlyName}</th>`;
        });
        tableHTML += '</tr>';
        tableHTML += '</thead>';
        
        // Create data rows with alternating colors
        tableHTML += '<tbody>';
        data.forEach((row, index) => {
            const bgColor = index % 2 === 0 ? '#ffffff' : '#f9f9f9';
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
                if (cellValue === true) cellValue = '✅ Da';
                if (cellValue === false) cellValue = '❌ Nu';
                
                // Escape HTML to prevent issues
                cellValue = String(cellValue).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                
                tableHTML += `<td style="padding:8px; border:1px solid #ddd; color:#333;">${cellValue}</td>`;
            });
            tableHTML += '</tr>';
        });
        tableHTML += '</tbody>';
        tableHTML += '</table>';
        tableHTML += '</div>';
        
        // Create export button with safe event binding
        tableHTML += '<div style="text-align: right; margin-top: 5px;">';
        tableHTML += `<button id="export-btn-${Date.now()}" style="background-color: #f1f1f1; border: 1px solid #ddd; border-radius: 4px; padding: 5px 10px; font-size: 12px; cursor: pointer; color: #333;">📁 Export CSV</button>`;
        tableHTML += '</div>';
        
        // Set the HTML content
        messageElement.innerHTML = tableHTML;
        
        // Add the export functionality after DOM insertion
        const exportButton = messageElement.querySelector('button[id^="export-btn-"]');
        if (exportButton) {
            exportButton.addEventListener('click', function() {
                exportTableToCSV(data);
            });
            
            // Add hover effect
            exportButton.addEventListener('mouseenter', function() {
                this.style.backgroundColor = '#e0e0e0';
            });
            exportButton.addEventListener('mouseleave', function() {
                this.style.backgroundColor = '#f1f1f1';
            });
        }
        
        // Add to chat
        chatMessages.appendChild(messageElement);
        
        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        timeElement.style.cssText = 'font-size: 12px; color: #666; margin-top: 5px; text-align: left;';
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                  now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        // Ensure good scrolling
        setTimeout(scrollToBottom, 100);
        
        console.log('✅ Table rendered successfully');
    }// COMPLETE FIXED addTableMessage function
    function addTableMessage(data, sender) {
        if (!data || data.length === 0) {
            addMessage('Nu există date disponibile.', sender);
            return;
        }
        
        console.log('Rendering table with data:', data);
        
        // Create message container
        const messageElement = document.createElement('div');
        messageElement.classList.add('message', 'bot-message');
        messageElement.style.cssText = `
            max-width: 95% !important;
            width: auto !important;
            overflow-x: auto !important;
            background-color: #f8f9fa !important;
            border-radius: 18px !important;
            padding: 12px 18px !important;
            margin-bottom: 15px !important;
            margin-right: auto !important;
        `;
        
        // Get column names from first row
        const columns = Object.keys(data[0]);
        
        // Build table HTML with complete syntax
        let tableHTML = '';
        tableHTML += '<div style="overflow-x:auto; margin:10px 0; border-radius: 8px; border: 1px solid #ddd;">';
        tableHTML += '<table style="width:100%; border-collapse:collapse; color:#000; background-color:#fff; font-size: 14px;">';
        
        // Create header row
        tableHTML += '<thead><tr>';
        columns.forEach(column => {
            const friendlyName = formatColumnName(column);
            tableHTML += `<th style="padding:10px; text-align:left; background-color:#f5f5f5; color:#333; border:1px solid #ddd; font-weight: bold;">${friendlyName}</th>`;
        });
        tableHTML += '</tr></thead>';
        
        // Create data rows
        tableHTML += '<tbody>';
        data.forEach((row, index) => {
            const bgColor = index % 2 === 0 ? '#ffffff' : '#f9f9f9';
            tableHTML += `<tr style="background-color:${bgColor};">`;
            columns.forEach(column => {
                let cellValue = row[column] != null ? row[column] : '';
                
                // Format dates
                if (typeof cellValue === 'string' && 
                    (cellValue.match(/^\d{4}-\d{2}-\d{2}$/) || 
                     cellValue.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/))) {
                    cellValue = formatDateString(cellValue);
                }
                
                // Format booleans
                if (cellValue === true) cellValue = '✅ Da';
                if (cellValue === false) cellValue = '❌ Nu';
                
                // Escape HTML
                cellValue = String(cellValue).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                
                tableHTML += `<td style="padding:8px; border:1px solid #ddd; color:#333;">${cellValue}</td>`;
            });
            tableHTML += '</tr>';
        });
        tableHTML += '</tbody></table></div>';
        
        // Create export button
        const uniqueId = 'export-btn-' + Date.now();
        tableHTML += '<div style="text-align: right; margin-top: 5px;">';
        tableHTML += `<button id="${uniqueId}" style="background-color: #f1f1f1; border: 1px solid #ddd; border-radius: 4px; padding: 5px 10px; font-size: 12px; cursor: pointer; color: #333;">📁 Export CSV</button>`;
        tableHTML += '</div>';
        
        // Set the HTML content
        messageElement.innerHTML = tableHTML;
        
        // Add export functionality after DOM insertion
        const exportButton = messageElement.querySelector('#' + uniqueId);
        if (exportButton) {
            exportButton.addEventListener('click', function() {
                exportTableToCSV(data);
            });
            
            // Add hover effect
            exportButton.addEventListener('mouseenter', function() {
                this.style.backgroundColor = '#e0e0e0';
            });
            exportButton.addEventListener('mouseleave', function() {
                this.style.backgroundColor = '#f1f1f1';
            });
        }
        
        // Add to chat
        chatMessages.appendChild(messageElement);
        
        // Add timestamp
        const timeElement = document.createElement('div');
        timeElement.classList.add('message-time');
        timeElement.style.cssText = 'font-size: 12px; color: #666; margin-top: 5px; text-align: left;';
        const now = new Date();
        timeElement.textContent = now.getHours().toString().padStart(2, '0') + ':' + 
                                  now.getMinutes().toString().padStart(2, '0');
        messageElement.appendChild(timeElement);
        
        // Scroll to bottom
        setTimeout(scrollToBottom, 100);
        
        console.log('✅ Table rendered successfully');
    }

    // MISSING FUNCTIONS - Add these to your script:

    // Arată indicator typing
    function showTypingIndicator() {
        const typingElement = document.createElement('div');
        typingElement.classList.add('message', 'bot-message', 'bot-typing');
        typingElement.id = 'typingIndicator';
        
        const typingIndicator = document.createElement('div');
        typingIndicator.classList.add('typing-indicator');
        
        typingIndicator.innerHTML = `
            <i class="ri-robot-2-line" style="margin-right: 10px; color: var(--bg);"></i>
            <span style="margin-right: 10px;">Procesez cu AI...</span>
        `;
        
        for (let i = 0; i < 3; i++) {
            const dot = document.createElement('div');
            dot.classList.add('typing-dot');
            typingIndicator.appendChild(dot);
        }
        
        typingElement.appendChild(typingIndicator);
        chatMessages.appendChild(typingElement);
        
        scrollToBottom();
    }

    // Ascunde indicator typing
    function hideTypingIndicator() {
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }

    // Activează/dezactivează input-ul
    function setInputEnabled(enabled) {
        userInput.disabled = !enabled;
        sendButton.disabled = !enabled;
        
        const statusText = document.getElementById('statusText');
        
        if (enabled) {
            userInput.focus();
            statusText.textContent = 'Online';
        } else {
            statusText.textContent = 'Procesează...';
        }
    }

    // Formatează mesajul
    function formatMessage(message) {
        if (typeof message !== 'string') {
            return message;
        }
        
        // Convert URLs to links
        message = message.replace(
            /(https?:\/\/[^\s]+)/g,
            '<a href="$1" target="_blank" style="color: #0078d4; text-decoration: underline;">$1</a>'
        );
        
        // Convert bullet points to HTML lists
        if ((message.includes('* ') || message.includes('- ')) && message.includes('\n')) {
            let lines = message.split('\n');
            let inList = false;
            let formattedLines = [];
            
            for (let line of lines) {
                if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
                    if (!inList) {
                        formattedLines.push('<ul style="margin: 8px 0; padding-left: 20px;">');
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

    // Formatează numele coloanelor
    function formatColumnName(columnName) {
        // Romanian column names dictionary
        const romanianColumns = {
            'id': 'ID',
            'nume': 'Nume',
            'prenume': 'Prenume',
            'departament': 'Departament',
            'functie': 'Funcție',
            'email': 'Email',
            'telefon': 'Telefon',
            'salariu': 'Salariu',
            'data_angajare': 'Data Angajare',
            'data_inceput': 'Data Început',
            'data_final': 'Data Final',
            'tip_concediu': 'Tip Concediu',
            'numar_angajati': 'Număr Angajați',
            'nume_dep': 'Nume Departament',
            'id_dep': 'ID Departament'
        };
        
        // Check if we have a Romanian translation
        if (romanianColumns[columnName]) {
            return romanianColumns[columnName];
        }
        
        // Otherwise, format normally
        let result = columnName.replace(/_/g, ' ');
        result = result.replace(/\b\w/g, l => l.toUpperCase());
        return result;
    }

    // Formatează stringurile de dată
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
            console.warn('Date formatting error:', e);
            return dateString;
        }
    }

    // Export tabel în CSV
    function exportTableToCSV(data) {
        try {
            if (!data || data.length === 0) {
                addMessage('❌ Nu există date pentru export.', 'bot');
                return;
            }
            
            console.log('📥 Starting CSV export with', data.length, 'rows');
            
            // Get column names
            const columns = Object.keys(data[0]);
            
            // Create CSV content
            let csvContent = '\uFEFF'; // UTF-8 BOM for Excel compatibility
            csvContent += columns.map(formatColumnName).join(',') + '\n';
            
            data.forEach(row => {
                let rowContent = columns.map(column => {
                    let value = row[column] != null ? row[column] : '';
                    
                    // Convert to string and handle special characters
                    value = String(value);
                    
                    // Format dates for CSV
                    if (value.match(/^\d{4}-\d{2}-\d{2}/)) {
                        try {
                            const date = new Date(value);
                            value = date.toLocaleDateString('ro-RO');
                        } catch (e) {
                            // Keep original value if date parsing fails
                        }
                    }
                    
                    // Quote values with commas, quotes, or newlines
                    if (value.includes(',') || value.includes('"') || value.includes('\n')) {
                        value = '"' + value.replace(/"/g, '""') + '"';
                    }
                    
                    return value;
                }).join(',');
                
                csvContent += rowContent + '\n';
            });
            
            // Create and trigger download
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            
            // Generate filename with timestamp
            const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
            link.setAttribute('href', url);
            link.setAttribute('download', `hr_export_${timestamp}.csv`);
            link.style.visibility = 'hidden';
            
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            // Clean up
            URL.revokeObjectURL(url);
            
            // Success notification
            addMessage('✅ Fișierul CSV a fost descărcat cu succes!', 'bot');
            
            console.log('✅ CSV export completed successfully');
            
        } catch (error) {
            console.error('❌ CSV export error:', error);
            addMessage('❌ Eroare la exportul CSV: ' + error.message, 'bot', 'error');
        }
    }

    // Ajustează înălțimea textarea
    function adjustTextareaHeight(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = (textarea.scrollHeight) + 'px';
    }

    // Scroll la sfârșit
    function scrollToBottom() {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

 // 1. MISSING: adjustTextareaHeight function
 function adjustTextareaHeight(textarea) {
     textarea.style.height = 'auto';
     textarea.style.height = (textarea.scrollHeight) + 'px';
 }

 // 2. MISSING: sendMessage function
 function sendMessage() {
     const message = userInput.value.trim();
     if (message === '') return;
     
     console.log('📤 Sending message:', message);
     
     // Add user message
     addMessage(message, 'user');
     
     // Clear input
     userInput.value = '';
     adjustTextareaHeight(userInput);
     
     // Show typing indicator
     showTypingIndicator();
     
     // Disable input
     setInputEnabled(false);
     
     // Get servlet URL
     const contextPath = '<%= request.getContextPath() %>';
     const servletUrl = contextPath + '/ChatServlet';
     
     console.log('🔗 Using servlet URL:', servletUrl);
     
     // Send to server
     fetch(servletUrl, {
         method: 'POST',
         headers: {
             'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
         },
         body: 'query=' + encodeURIComponent(message)
     })
     .then(response => {
         console.log('📡 Response status:', response.status);
         if (!response.ok) {
             throw new Error('Network response was not ok: ' + response.status);
         }
         return response.text().then(text => {
             console.log('📜 Raw response:', text);
             try {
                 return JSON.parse(text);
             } catch (e) {
                 console.error('❌ JSON parse error:', e);
                 throw new Error('Invalid JSON response: ' + e.message);
             }
         });
     })
     .then(data => {
         console.log('✅ Parsed data:', data);
         
         // Hide typing indicator
         hideTypingIndicator();
         
         // Re-enable input
         setInputEnabled(true);
         
         // Process different response types
         if (data.type === 'text' || data.type === 'enhanced_text') {
             addMessage(data.message, 'bot');
             
             if (data.entityType) {
                 addContextSuggestions(data.entityType);
             } else {
                 addContextSuggestions(data.message);
             }
         } else if (data.type === 'table') {
             // Add message before table
             addMessage(data.message, 'bot');
             
             if (data.data && data.data.length > 0) {
                 // Store data for follow-up
                 lastQueryData = data.data;
                 lastQueryContext = getContextFromData(data.data);
                 
                 console.log('📊 Displaying table with', data.data.length, 'rows');
                 
                 // Display table immediately
                 setTimeout(() => {
                     addTableMessage(data.data, 'bot');
                     addContextSuggestions(lastQueryContext);
                 }, 300);
             } else {
                 console.log('⚠️ No data in table response');
             }
         } else if (data.type === 'error') {
             addMessage('❌ ' + data.message, 'bot', 'error');
             setTimeout(addDefaultSuggestions, 500);
         } else {
             // Fallback
             console.log('🔄 Unknown response type:', data.type, 'treating as text');
             addMessage(data.message || 'Răspuns primit', 'bot');
             
             if (data.entityType) {
                 addContextSuggestions(data.entityType);
             }
         }
     })
     .catch(error => {
         console.error('❌ Fetch error:', error);
         
         hideTypingIndicator();
         setInputEnabled(true);
         
         addMessage('❌ Îmi pare rău, a apărut o eroare în comunicarea cu serverul: ' + error.message, 'bot', 'error');
         setTimeout(addDefaultSuggestions, 500);
     });
 }

 // 3. MISSING: addMessage function  
 function addMessage(message, sender, type) {
     console.log('💬 Adding message:', { message, sender, type });
     
     const messageElement = document.createElement('div');
     messageElement.classList.add('message');
     messageElement.classList.add(sender === 'user' ? 'user-message' : 'bot-message');
     
     if (type === 'error') {
         messageElement.style.cssText = `
             background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
             color: #c62828;
             border-left: 4px solid #c62828;
         `;
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
     
     scrollToBottom();
     
     console.log('✅ Message added successfully');
 }

 // 4. MISSING: showTypingIndicator function
 function showTypingIndicator() {
     const typingElement = document.createElement('div');
     typingElement.classList.add('message', 'bot-message', 'bot-typing');
     typingElement.id = 'typingIndicator';
     
     const typingIndicator = document.createElement('div');
     typingIndicator.classList.add('typing-indicator');
     
     typingIndicator.innerHTML = `
         <i class="ri-robot-2-line" style="margin-right: 10px; color: var(--bg);"></i>
         <span style="margin-right: 10px;">Procesez cu AI...</span>
     `;
     
     for (let i = 0; i < 3; i++) {
         const dot = document.createElement('div');
         dot.classList.add('typing-dot');
         typingIndicator.appendChild(dot);
     }
     
     typingElement.appendChild(typingIndicator);
     chatMessages.appendChild(typingElement);
     
     scrollToBottom();
 }

 // 5. MISSING: hideTypingIndicator function
 function hideTypingIndicator() {
     const typingIndicator = document.getElementById('typingIndicator');
     if (typingIndicator) {
         typingIndicator.remove();
     }
 }

 // 6. MISSING: setInputEnabled function
 function setInputEnabled(enabled) {
     userInput.disabled = !enabled;
     sendButton.disabled = !enabled;
     
     const statusText = document.getElementById('statusText');
     
     if (enabled) {
         userInput.focus();
         statusText.textContent = 'Online';
     } else {
         statusText.textContent = 'Procesează...';
     }
 }

 // 7. MISSING: formatMessage function
 function formatMessage(message) {
     if (typeof message !== 'string') {
         return message;
     }
     
     // Convert URLs to links
     message = message.replace(
         /(https?:\/\/[^\s]+)/g,
         '<a href="$1" target="_blank" style="color: #0078d4; text-decoration: underline;">$1</a>'
     );
     
     // Convert bullet points to HTML lists
     if ((message.includes('* ') || message.includes('- ')) && message.includes('\n')) {
         let lines = message.split('\n');
         let inList = false;
         let formattedLines = [];
         
         for (let line of lines) {
             if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
                 if (!inList) {
                     formattedLines.push('<ul style="margin: 8px 0; padding-left: 20px;">');
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

 // 8. MISSING: scrollToBottom function
 function scrollToBottom() {
     chatMessages.scrollTop = chatMessages.scrollHeight;
 }

 // 9. MISSING: getContextFromData function
 function getContextFromData(data) {
     if (!data || data.length === 0) return '';
     
     const sample = data[0];
     let contextString = '';
     
     if (sample.departament || sample.nume_dep) contextString += ' departamente';
     if (sample.nume && sample.prenume) contextString += ' angajați';
     if (sample.data_inceput || sample.start_c) contextString += ' concedii';
     if (sample.functie || sample.denumire || sample.salariu) contextString += ' poziții salarii';
     if (sample.nume_proiect || sample.nume_task) contextString += ' proiecte';
     if (sample.tip_adeverinta) contextString += ' adeverințe';
     
     return contextString;
 }

 // 10. GLOBAL: Export CSV function (make sure this exists)
 window.exportTableToCSV = function(data) {
     console.log('📥 Exporting CSV with data:', data);
     
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
     
     // Download
     const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
     const url = URL.createObjectURL(blob);
     const link = document.createElement('a');
     link.setAttribute('href', url);
     link.setAttribute('download', 'hr_export_' + new Date().toISOString().slice(0, 10) + '.csv');
     link.style.visibility = 'hidden';
     
     document.body.appendChild(link);
     link.click();
     document.body.removeChild(link);
     
     // Notification
     addMessage('📁 Fișierul CSV a fost descărcat cu succes!', 'bot');
     
     console.log('✅ CSV export completed');
 };
    </script>
         <%
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date: " + e.getMessage() + "');");
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