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
                    // Doar Admin HR sau Director poate accesa
                    if (userType != 0 && userType != 4 && (userType != 3 || userDep != 1)) {
                        response.sendRedirect(userType == 1 ? "tip1ok.jsp" : userType == 2 ? "tip2ok.jsp" : userType == 3 ? "sefok.jsp" : "adminok.jsp");
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        
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
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
%> 

<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <title>Încetare Contract</title>
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
            color: <%=text%> !important; 
            text-decoration: none;
        }
        
        .card {
            background-color: <%=sidebar%>;
            border-radius: 15px;
            padding: 30px;
            margin: 20px auto;
            max-width: 90%;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            border-color: <%=accent%>;
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
            border-color: <%=accent%>;
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
            background-color: <%=text%>;
            color: <%=sidebar%>;
        }
        
        .page-header {
            text-align: center;
            margin-bottom: 2rem;
            color: <%=accent%>;
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
            background-color: <%=sidebar%>;
            margin: 0.5rem auto 0;
            border-radius: 2px;
        }
        
        .form-label {
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: <%=text%>;
        }
        
        /* Input placeholder color */
        ::placeholder {
            color: <%=text%>;
        }
        
        body {
            background-color: <%=clr%>;
            color: <%=text%>;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
        }
        
        .text-muted {
            color: <%=text%> !important;
            opacity: 0.8;
        }
        
        .alert-warning {
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
            padding: 15px;
            margin: 20px 0;
            border-radius: 8px;
            display: flex;
            align-items: center;
        }
        
        .alert-warning i {
            font-size: 1.5rem;
            margin-right: 10px;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            transition: all 0.3s;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-danger i {
            margin-right: 8px;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
            transform: translateY(-2px);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>">
    <div class="container py-5">
        <div class="card">
            <div class="page-header">
                <h2><i class="ri-file-damage-line me-2"></i>Încetare Contract de Muncă</h2>
                <p class="text-muted">Completați detaliile pentru încetarea contractului de muncă</p>
            </div>
            
            <form id="incetareForm" method="POST" action="IncetareContractServlet" class="needs-validation" novalidate>
                <div class="form-group">
                    <label for="angajat" class="form-label">Selectați Angajatul:</label>
                    <select id="angajat" name="id_ang" class="form-control" required>
                        <option value="">-- Selectați angajatul --</option>
                        <%
                        Connection conn2 = null;
                        PreparedStatement pstmt2 = null;
                        ResultSet rs3 = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            String sql = "SELECT id, nume, prenume FROM useri WHERE id != ? AND activ = 1";
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
                    <label for="dataIncetare" class="form-label">Data Încetării Contractului:</label>
                    <input type="date" id="dataIncetare" name="data_incetare" class="form-control" required>
                    <div class="invalid-feedback">Vă rugăm selectați data încetării contractului.</div>
                </div>
                
                <div class="form-group">
                    <label for="motivIncetare" class="form-label">Motivul Încetării Contractului:</label>
                    <select id="motivIncetare" name="motiv_incetare" class="form-control" required>
                        <option value="">-- Selectați motivul --</option>
                        <option value="demisie">Demisie</option>
                        <option value="concediere_disciplinara">Concediere disciplinară</option>
                        <option value="concediere_colectiva">Concediere colectivă</option>
                        <option value="pensionare">Pensionare</option>
                        <option value="expirare_contract">Expirare contract</option>
                        <option value="acord_parti">Acord părți</option>
                        <option value="incetare_perioada_proba">Încetare în perioada de probă</option>
                        <option value="deces">Deces</option>
                    </select>
                    <div class="invalid-feedback">Vă rugăm selectați motivul încetării contractului.</div>
                </div>
                
                <div class="form-group">
                    <label for="observatii" class="form-label">Observații:</label>
                    <textarea id="observatii" name="observatii" class="form-control" rows="4"></textarea>
                </div>
                
                <div class="alert alert-warning mt-4">
                    <i class="ri-alert-line"></i>
                    <div>
                        <strong>Atenție!</strong> Această acțiune este ireversibilă.
                        Angajatul va fi marcat ca inactiv și nu va mai avea acces la sistem.
                    </div>
                </div>
                
                <div class="form-group d-flex justify-content-between mt-4">
                    <a href="viewang.jsp" class="btn btn-outline-secondary">
                        <i class="ri-arrow-left-line me-1"></i> Înapoi
                    </a>
                    <button type="submit" class="btn btn-danger" onclick="return confirm('Sunteți sigur(ă) că doriți să încetați contractul acestui angajat?')">
                        <i class="ri-delete-bin-line me-1"></i> Încetare Contract
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Validare formular
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('incetareForm');
            
            form.addEventListener('submit', function(e) {
                if (!form.checkValidity()) {
                    e.preventDefault();
                    e.stopPropagation();
                }
                
                const dataIncetare = new Date(document.getElementById('dataIncetare').value);
                const today = new Date();
                
                if (dataIncetare < today) {
                    e.preventDefault();
                    alert('Data încetării nu poate fi în trecut!');
                }
                
                form.classList.add('was-validated');
            });
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