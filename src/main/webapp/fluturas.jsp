<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.text.NumberFormat" %>

<%
    HttpSession sesi = request.getSession(false);
    int pag = -1;
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver");
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
                    int userId = rs.getInt("id");
                    int userDep = rs.getInt("id_dep");// doar director
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);
                    
                    if (!isDirector) {  
                        
                        if (isAdmin) {
                            response.sendRedirect("adminok.jsp");
                        }
                        if (isUtilizatorNormal) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (isSef) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (isIncepator) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                        } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("ro", "RO"));
                        
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
    <title>Generare Fluturas Salariu</title>
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
        
        /* Fluturas styles */
        .fluturas {
            background: white;
            padding: 20px;
            margin: 20px 0;
            border: 1px solid #ddd;
            border-radius: 8px;
            color: #333;
        }
        
        .fluturas-header {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }
        
        .fluturas-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .fluturas-table th, .fluturas-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        
        .fluturas-table th {
            background-color: #f4f4f4;
        }
        
        .total-row {
            font-weight: bold;
            background-color: #f9f9f9;
        }
        
        /* Button to generate PDF */
        .pdf-button {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>">
    <div class="container py-5">
        <div class="card">
            <div class="page-header">
                <h2><i class="ri-money-dollar-circle-line me-2"></i>Generare Fluturaș Salariu</h2>
                <p class="text-muted">Creați și descărcați fluturașul de salariu pentru angajați</p>
            </div>
            
            <form id="fluturasForm" method="GET" class="needs-validation" novalidate>
                <div class="form-group">
                    <label for="angajat" class="form-label">Selectați Angajatul:</label>
                    <select id="angajat" name="id_ang" class="form-control" required>
                        <option value="">-- Selectați angajatul --</option>
                        <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs3 = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                            String sql = "SELECT id, nume, prenume FROM useri WHERE id_dep = ? AND id != ?";
                            pstmt = conn.prepareStatement(sql);
                            pstmt.setInt(1, userDep);
                            pstmt.setInt(2, userId);
                            rs3 = pstmt.executeQuery();
                            
                            while (rs3.next()) {
                        %>
                                <option value="<%= rs3.getInt("id") %>" 
                                    <%= request.getParameter("id_ang") != null && 
                                        request.getParameter("id_ang").equals(String.valueOf(rs3.getInt("id"))) ? 
                                        "selected" : "" %>>
                                    <%= rs3.getString("nume") %> <%= rs3.getString("prenume") %>
                                </option>
                        <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                        %>
                    </select>
                    <div class="invalid-feedback">Vă rugăm selectați un angajat.</div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="luna" class="form-label">Luna:</label>
                            <select id="luna" name="luna" class="form-control" required>
                                <option value="">-- Selectați luna --</option>
                                <%
                                for (int i = 1; i <= 12; i++) {
                                    String selected = request.getParameter("luna") != null && 
                                                    request.getParameter("luna").equals(String.valueOf(i)) ? 
                                                    "selected" : "";
                                %>
                                    <option value="<%= i %>" <%= selected %>><%= new String[]{"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"}[i-1] %></option>
                                <%
                                }
                                %>
                            </select>
                            <div class="invalid-feedback">Vă rugăm selectați luna.</div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="an" class="form-label">An:</label>
                            <select id="an" name="an" class="form-control" required>
                                <option value="">-- Selectați anul --</option>
                                <%
                                int currentYear = LocalDate.now().getYear();
                                for (int i = currentYear - 2; i <= currentYear; i++) {
                                    String selected = request.getParameter("an") != null && 
                                                    request.getParameter("an").equals(String.valueOf(i)) ? 
                                                    "selected" : "";
                                %>
                                    <option value="<%= i %>" <%= selected %>><%= i %></option>
                                <%
                                }
                                %>
                            </select>
                            <div class="invalid-feedback">Vă rugăm selectați anul.</div>
                        </div>
                    </div>
                </div>
                
                <div class="form-group d-flex justify-content-between">
                    <a href="viewang.jsp" class="btn btn-outline-secondary">
                        <i class="ri-arrow-left-line me-1"></i> Înapoi
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="ri-file-list-3-line me-1"></i> Generare Fluturaș
                    </button>
                </div>
            </form>
            
            <%
            if (request.getParameter("id_ang") != null && 
                request.getParameter("luna") != null && 
                request.getParameter("an") != null) {
                
                int idAng = Integer.parseInt(request.getParameter("id_ang"));
                int luna = Integer.parseInt(request.getParameter("luna"));
                int an = Integer.parseInt(request.getParameter("an"));
                
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs4 = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    
                    // Date angajat
                    String sql = "SELECT u.*, t.salariu as salariu_baza, t.denumire as functie, " +
                               "d.nume_dep, s.procent as procent_spor, p.procent as procent_penalizare, " +
                               "s.denumire as denumire_spor, p.denumire as denumire_penalizare " +
                               "FROM useri u " +
                               "JOIN tipuri t ON u.tip = t.tip " +
                               "JOIN departament d ON u.id_dep = d.id_dep " +
                               "LEFT JOIN tipuri_sporuri s ON u.sporuri = s.id " +
                               "LEFT JOIN tipuri_penalizari p ON u.penalizari = p.id " +
                               "";
                    pstmt2 = conn2.prepareStatement(sql);
                    // pstmt2.setInt(1, idAng);
                    rs4 = pstmt2.executeQuery();
                    
                    if (rs4.next()) {
                        double salariuBaza = rs4.getDouble("salariu_baza");
                        double procentSpor = rs4.getDouble("procent_spor");
                        double procentPenalizare = rs4.getDouble("procent_penalizare");
                        String denumireSpor = rs4.getString("denumire_spor");
                        String denumirePenalizare = rs4.getString("denumire_penalizare");
                        
                        // Calculare salariu
                        double spor = salariuBaza * procentSpor / 100;
                        double penalizare = salariuBaza * procentPenalizare / 100;
                        double salariuBrut = salariuBaza + spor - penalizare;
                        
                        // Calcul contribuții
                        double cas = salariuBrut * 0.25;
                        double cass = salariuBrut * 0.10;
                        double impozit = (salariuBrut - cas - cass) * 0.10;
                        double salariuNet = salariuBrut - cas - cass - impozit;
                        
                        // Datele angajatului și detaliile salariale pentru PDF
                        String numeLuna = new String[]{"Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie", "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"}[luna-1];
            %>
                        <div class="fluturas">
                            <div class="fluturas-header">
                                <h3>FLUTURAȘ DE SALARIU</h3>
                                <p><%= numeLuna %> <%= an %></p>
                            </div>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th colspan="2">Date angajat</th>
                                </tr>
                                <tr>
                                    <td>Nume și prenume:</td>
                                    <td><%= rs4.getString("nume") %> <%= rs4.getString("prenume") %></td>
                                </tr>
                                <tr>
                                    <td>CNP:</td>
                                    <td><%= rs4.getString("cnp") %></td>
                                </tr>
                                <tr>
                                    <td>Funcție:</td>
                                    <td><%= rs4.getString("functie") %></td>
                                </tr>
                                <tr>
                                    <td>Departament:</td>
                                    <td><%= rs4.getString("nume_dep") %></td>
                                </tr>
                            </table>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th>Venituri</th>
                                    <th>Suma</th>
                                </tr>
                                <tr>
                                    <td>Salariu de bază</td>
                                    <td><%= currencyFormat.format(salariuBaza) %></td>
                                </tr>
                                <% if (spor > 0) { %>
                                <tr>
                                    <td><%= denumireSpor %> (<%= procentSpor %>%)</td>
                                    <td><%= currencyFormat.format(spor) %></td>
                                </tr>
                                <% } %>
                                <% if (penalizare > 0) { %>
                                <tr>
                                    <td><%= denumirePenalizare %> (-<%= procentPenalizare %>%)</td>
                                    <td>-<%= currencyFormat.format(penalizare) %></td>
                                </tr>
                                <% } %>
                                <tr class="total-row">
                                    <td>Total brut</td>
                                    <td><%= currencyFormat.format(salariuBrut) %></td>
                                </tr>
                            </table>
                            
                            <table class="fluturas-table">
                                <tr>
                                    <th>Contribuții</th>
                                    <th>Suma</th>
                                </tr>
                                <tr>
                                    <td>CAS (25%)</td>
                                    <td><%= currencyFormat.format(cas) %></td>
                                </tr>
                                <tr>
                                    <td>CASS (10%)</td>
                                    <td><%= currencyFormat.format(cass) %></td>
                                </tr>
                                <tr>
                                    <td>Impozit (10%)</td>
                                    <td><%= currencyFormat.format(impozit) %></td>
                                </tr>
                                <tr class="total-row">
                                    <td>Total net de plată</td>
                                    <td><%= currencyFormat.format(salariuNet) %></td>
                                </tr>
                            </table>
                            
                            <div class="pdf-button">
                                <button id="generatePDF" class="btn btn-primary">
                                    <i class="ri-file-pdf-line me-1"></i> Descărcare PDF
                                </button>
                            </div>
                        </div>
                        <%
                        String cevaa = "";
                        if (userType == 4 || userType >= 15) cevaa += "Consiliul director"; else cevaa += "-";
                        %>
                        <script>
                     // Actualizare cod JavaScript pentru fluturas.jsp
                     // Inlocuieste codul existent pentru butonul generatePDF

                     document.getElementById('generatePDF').addEventListener('click', function() {
                         // Construieste datele pentru noul format de fluturas
                         const pdfData = {
                             // Informatii generale
                             companie: "<%=request.getParameter("companie") != null ? request.getParameter("companie") : "Firma XYZ SRL"%>",
                             luna: "<%= numeLuna %> <%= an %>",
                             nume: "<%= rs4.getString("nume") %> <%= rs4.getString("prenume") %>",
                             cnp: "<%= rs4.getString("cnp") %>",
                             functie: "<%= rs4.getString("functie") %>",
                             departament: "<%= rs4.getString("nume_dep") %>",
                             
                             // Date salariu
                             salariu_baza: <%= salariuBaza %>,
                             valoare_spor: <%= spor %>,
                             nume_spor: "<%= denumireSpor %>",
                             procent_spor: <%= procentSpor %>,
                             valoare_penalizare: <%= penalizare %>,
                             nume_penalizare: "<%= denumirePenalizare %>",
                             procent_penalizare: <%= procentPenalizare %>,
                             
                             // Zile si ore
                             ore_suplimentare: <%= request.getParameter("ore_suplimentare") != null ? request.getParameter("ore_suplimentare") : 0 %>,
                             valoare_ore_suplimentare: <%= salariuBaza * 0.015 * (request.getParameter("ore_suplimentare") != null ? Integer.parseInt(request.getParameter("ore_suplimentare")) : 0) %>,
                             zile_lucrate: <%= request.getParameter("zile_lucrate") != null ? request.getParameter("zile_lucrate") : 21 %>,
                             zile_absente: <%= request.getParameter("zile_absente") != null ? request.getParameter("zile_absente") : 0 %>,
                             
                             // Valori calculate
                             salariu_brut: <%= salariuBrut %>,
                             cas: <%= cas %>,
                             cass: <%= cass %>,
                             impozit: <%= impozit %>,
                             salariu_net: <%= salariuNet %>
                         };
                         
                         // Trimite datele catre noul generator PDF
                         fetch('generatePDFNou.jsp', {
                             method: 'POST',
                             headers: {
                                 'Content-Type': 'application/json'
                             },
                             body: JSON.stringify(pdfData)
                         })
                         .then(response => response.blob())
                         .then(blob => {
                             const url = window.URL.createObjectURL(blob);
                             const a = document.createElement('a');
                             a.style.display = 'none';
                             a.href = url;
                             a.download = 'fluturas_<%= rs4.getString("nume") %>_<%= rs4.getString("prenume") %>_<%= numeLuna %>_<%= an %>.pdf';
                             document.body.appendChild(a);
                             a.click();
                             window.URL.revokeObjectURL(url);
                         })
                         .catch(error => {
                             console.error('Eroare la generarea PDF:', error);
                             alert('A aparut o eroare la generarea PDF-ului. Va rugam incercati din nou.');
                         });
                     });
                        </script>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger mt-3'><i class='ri-error-warning-line me-2'></i>A apărut o eroare la generarea fluturașului de salariu: " + e.getMessage() + "</div>");
                } finally {
                    if (rs4 != null) try { rs4.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn2 != null) try { conn2.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
            %>
        </div>
    </div>

    <script>
        // Form validation
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('fluturasForm');
            
            form.addEventListener('submit', function(e) {
                if (!form.checkValidity()) {
                    e.preventDefault();
                    e.stopPropagation();
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