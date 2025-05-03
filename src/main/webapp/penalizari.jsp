<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>

<%
    HttpSession sesi = request.getSession(false);
int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                PreparedStatement preparedStatement = connection.prepareStatement(
                		"SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
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
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    if (!isDirector) {
                        response.sendRedirect(isUtilizatorNormal ? "tip1ok.jsp" : isIncepator ? "tip2ok.jsp" : isSef ? "sefok.jsp" : "adminok.jsp");
                    }  else {
                    	 String accent = null;
                      	 String clr = null;
                      	 String sidebar = null;
                      	 String text = null;
                      	 String card = null;
                      	 String hover = null;
                      	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT * from teme where id_usr = ?";
                             try (PreparedStatement stmt = con.prepareStatement(query)) {
                                 stmt.setInt(1, userId);
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
                             // Display the user dashboard or related information
                             //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                             // Add additional user-specific content here
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                      
                      	 %> 

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Acordare Penalizări</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- REMIXICONS -->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="images/favicon.ico">

    <!-- BOOTSTRAP & CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
    <link rel="stylesheet" href="responsive-login-form-main/assets/css/core2.css">
   
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        a, a:visited, a:hover, a:active {
            color:  <%=text%> !important; 
            text-decoration: none;
        }
        
        .card {
            background-color: <%=sidebar%>;
            border-radius: 15px;
            
            padding: 30px;
            margin: 20px auto;
            max-width: 800px;
            transition: all 0.3s ease;
        }
        
        .card:hover {
           border-color:  <%=accent%>
            transform: translateY(-5px);
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-control {
            border-radius: 8px;
            padding: 10px 15px;
            
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color:  <%=accent%>;
            
        }
        
        select.form-control {
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%23333' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M6 9l6 6 6-6'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 16px;
            padding-right: 40px;
        }
        
        .btn-primary {
            background-color: <%=accent%>;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .btn-primary:hover {
            background-color: <%=text%>;
            transform: translateY(-2px);
            
        }
        
        .btn-outline-secondary {
            border: 1px solid <%=text%>;
            background-color: transparent;
            color: <%=text%>;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-outline-secondary:hover {
           background-color:  <%=text%>;
            color: <%=sidebar%>;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
            color:  <%=accent%>;
            position: relative;
        }
        
        .page-header h2 {
            font-weight: 700;
            margin-bottom: 1rem;
            font-size: 2.5rem;
            
        }
        
        .page-header:after {
            content: '';
            display: block;
            width: 80px;
            height: 4px;
            background-color:  <%=sidebar%>;
            margin: 0.5rem auto 0;
            border-radius: 2px;
        }
        
        .form-label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color:  <%=text%>;
        }
        
        /* Tooltip styles */
        .tooltip {
            position: relative;
            display: inline-block;
        }
        
        .tooltip .tooltiptext {
            visibility: hidden;
            width: 200px;
            background-color: rgba(0, 0, 0, 0.8);
            color: white;
            text-align: center;
            padding: 10px;
            border-radius: 8px;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            left: 50%;
            transform: translateX(-50%);
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 14px;
            
        }
        
        .tooltip:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
        }
        
        /* Date picker customization */
        input[type="date"] {
            position: relative;
        }
        
        /* Input placeholder color */
        ::placeholder {
            color:  <%=text%>;
        }
        
        /* Option for removing penalizare */
        .remove-penalizare-option {
            font-weight: bold;
            color:  <%=accent%>;
            border-top: 1px solid  <%=accent%>;
            margin-top: 5px;
            padding-top: 5px;
        }
        
        body {
            background-color:  <%=clr%>;
            color:  <%=text%>;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
        }
        
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        .text-muted {
        color: <%=text%> !important;}
    </style>
    
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>">
    <div class="container py-5">
        <div class="card">
            <div class="page-header">
                <!-- <h2><i class="ri-alarm-warning-line me-2"></i>Acordare Penalizări</h2> -->
                <h2>Acordare Penalizări</h2>
                <p class="text-muted" style="color: <%=text%>;">Gestionați penalizările angajaților pentru nereguli sau abateri</p>
            </div>
            
            <form id="penalizariForm" method="POST" action="${pageContext.request.contextPath}/PenalizariServlet" class="needs-validation" novalidate>
                <div class="form-group">
                    <label for="angajat" class="form-label">Selectați Angajatul:</label>
                    <select id="angajat" name="id_ang" class="form-control" required>
                        <option value="">-- Selectați un angajat --</option>
                        <%
                        Connection conn2 = null;
                        PreparedStatement pstmt2 = null;
                        ResultSet rs3 = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            String sql = "SELECT id, nume, prenume FROM useri WHERE id != ?";
                            pstmt2 = conn2.prepareStatement(sql);
                           // pstmt2.setInt(1, userDep);
                            pstmt2.setInt(1, userId);
                            rs3 = pstmt2.executeQuery();
                            
                            while (rs3.next()) {
                        %>
                                <option value="<%= rs3.getInt("id") %>">
                                    <%= rs3.getString("nume") %> <%= rs3.getString("prenume") %>
                                </option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn2 != null) try { conn2.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                        %>
                    </select>
                    <div class="invalid-feedback">Vă rugăm selectați un angajat.</div>
                </div>
                
                <div class="form-group">
                    <label for="tipPenalizare" class="form-label">Tip Penalizare:</label>
                    <select id="tipPenalizare" name="tip_penalizare" class="form-control" required>
                        <option value="">-- Selectați tipul de penalizare --</option>
                        <option value="0" class="remove-penalizare-option">Eliminare penalizare curentă</option>
                        <%
                        Connection conn3 = null;
                        Statement stmt3 = null;
                        ResultSet rs4 = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn3 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            String sql = "SELECT * FROM tipuri_penalizari ORDER BY id";
                            stmt3 = conn3.createStatement();
                            rs4 = stmt3.executeQuery(sql);
                            
                            while (rs4.next()) {
                                // Verifică dacă id-ul este 0 și sari peste această înregistrare
                                if (rs4.getInt("id") == 0) continue;
                        %>
                                <option value="<%= rs4.getInt("id") %>">
                                    <%= rs4.getString("denumire") %> (<%= rs4.getInt("procent") %>%)
                                </option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (rs4 != null) try { rs4.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (stmt3 != null) try { stmt3.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn3 != null) try { conn3.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                        %>
                    </select>
                    <div class="invalid-feedback">Vă rugăm selectați un tip de penalizare.</div>
                    <small class="text-muted mt-2" style="color:  <%=text%>;">
                        <i class="ri-information-line"></i> 
                        Selectați "Eliminare penalizare curentă" pentru a anula orice penalizare existentă.
                    </small>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="dataStart" class="form-label">Data Început:</label>
                            <input type="date" id="dataStart" name="data_start" class="form-control" required>
                            <div class="invalid-feedback">Vă rugăm selectați data de început.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="dataFinal" class="form-label">Data Sfârșit:</label>
                            <input type="date" id="dataFinal" name="data_final" class="form-control" required>
                            <div class="invalid-feedback">Vă rugăm selectați data de sfârșit.</div>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="motiv" class="form-label">Motiv Penalizare:</label>
                    <textarea id="motiv" name="motiv" rows="4" class="form-control" placeholder="Introduceți motivul pentru acordarea/eliminarea penalizării..." required></textarea>
                    <div class="invalid-feedback">Vă rugăm introduceți un motiv.</div>
                </div>
                
                <div class="form-group d-flex justify-content-between">
                    <button type="button" class="btn btn-outline-secondary" onclick="history.back()">
                        <i class="ri-arrow-left-line me-1"></i> Înapoi
                    </button>
                    <button type="submit" id="submitBtn" class="btn btn-primary">
                        <i class="ri-check-line me-1"></i> <span id="buttonText">Acordare Penalizare</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Form validation and submission handling
        document.getElementById('penalizariForm').addEventListener('submit', function(e) {
            if (!this.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
            }
            
            const dataStart = new Date(document.getElementById('dataStart').value);
            const dataFinal = new Date(document.getElementById('dataFinal').value);
            
            if (dataFinal < dataStart) {
                e.preventDefault();
                alert('Data de sfârșit nu poate fi înainte de data de început!');
            }
            
            this.classList.add('was-validated');
        });
        
        // Update button text based on selection
        document.getElementById('tipPenalizare').addEventListener('change', function() {
            const submitButton = document.getElementById('submitBtn');
            const buttonText = document.getElementById('buttonText');
            
            if (this.value === '0') {
                buttonText.textContent = 'Eliminare Penalizare';
                submitButton.classList.remove('btn-primary');
                submitButton.classList.add('btn-danger');
            } else {
                buttonText.textContent = 'Acordare Penalizare';
                submitButton.classList.remove('btn-danger');
                submitButton.classList.add('btn-primary');
            }
        });
        
        // Set default dates
        window.addEventListener('DOMContentLoaded', (event) => {
            const today = new Date();
            const nextMonth = new Date();
            nextMonth.setMonth(today.getMonth() + 1);
            
            const formatDate = (date) => {
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const day = String(date.getDate()).padStart(2, '0');
                return `${year}-${month}-${day}`;
            };
            
            document.getElementById('dataStart').value = formatDate(today);
            document.getElementById('dataFinal').value = formatDate(nextMonth);
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/core2.js"></script>
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
</body>
</html>