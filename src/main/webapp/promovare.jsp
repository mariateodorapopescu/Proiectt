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

                    // Doar Director poate accesa
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
    <title>Promovare Angajați</title>
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
            position: fixed;
            top: 0;
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
        
        /* Table styles */
.table {
    width: 100%;
    margin-bottom: 1rem;
    color: <%=text%>;
    border-collapse: separate;
    border-spacing: 0;
    border-radius: 8px;
    overflow: hidden;
}

.table th,
.table td {
    padding: 12px 15px;
    vertical-align: middle;
    border-top: none;
    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.table thead th {
    vertical-align: bottom;
    background-color: <%=accent%> !important;
    color: white;
    font-weight: 600;
    border: none;
    padding: 15px;
}

.table tbody tr {
    background-color: rgba(255, 255, 255, 0.03);
    transition: all 0.2s;
}

.table-hover tbody tr:hover {
    background-color: rgba(0, 0, 0, 0.03);
    transform: translateY(-2px);
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
}

.table .form-check-input {
    width: 18px;
    height: 18px;
    margin-top: 0;
}

.table .form-select {
    border-radius: 6px;
    border: 1px solid #ddd;
    padding: 8px 12px;
    font-size: 0.95rem;
    background-color: transparent;
}

.table .form-select:focus {
    border-color: <%=accent%>;
    box-shadow: 0 0 0 0.2rem rgba(var(--bs-primary-rgb), 0.25);
}

.badge {
    padding: 6px 12px;
    font-weight: 500;
    border-radius: 6px;
    letter-spacing: 0.5px;
}
        
        .badge-primary {
            color: #fff;
            background-color: <%=accent%>;
        }
        
        .badge-secondary {
            color: #fff;
            background-color: #6c757d;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; --card:<%out.println(card);%>; --hover:<%out.println(hover);%>">
    <div class="container py-5">
        <div class="card">
            <div class="page-header">
                <h2><i class="ri-award-line me-2"></i>Promovare Angajați</h2>
                <p class="text-muted">Gestionați evoluția profesională a angajaților prin promovări</p>
            </div>
            
            <div class="form-group">
                <form id="tipPromovareForm" method="GET" class="needs-validation" novalidate>
                    <label for="tipPromovare" class="form-label">Tip Promovare:</label>
                    <select id="tipPromovare" name="tip_promovare" class="form-control" required onchange="this.form.submit()">
                        <option value="">-- Selectați tipul de promovare --</option>
                        <option value="rang" <%= "rang".equals(request.getParameter("tip_promovare")) ? "selected" : "" %>>
                            Promovare în Rang
                        </option>
                        <option value="grad" <%= "grad".equals(request.getParameter("tip_promovare")) ? "selected" : "" %>>
                            Promovare în Grad
                        </option>
                    </select>
                    <div class="invalid-feedback">Vă rugăm selectați un tip de promovare.</div>
                    <small class="text-muted mt-2">
                        <i class="ri-information-line"></i> 
                        Promovare în Rang - pentru angajații cu vechime mai mare de 2 ani.
                        Promovare în Grad - pentru angajații fără concedii în ultimul an.
                    </small>
                </form>
            </div>
            
            <%
            String tipPromovare = request.getParameter("tip_promovare");
            if (tipPromovare != null && !tipPromovare.isEmpty()) {
                String sql = "";
                boolean hasEligibleEmployees = false;
                
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs3 = null;
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                    
                    if ("rang".equals(tipPromovare)) {
                        // Promovare in rang - angajatii cu vechime >2 ani
                        sql = "SELECT u.id, u.nume, u.prenume, t.denumire as functie_curenta, t.tip as tip_curent, " +
                              "DATEDIFF(CURDATE(), u.data_ang) / 365 as vechime_ani " +
                              "FROM useri u " +
                              "JOIN tipuri t ON u.tip = t.tip " +
                              " " +
                              "HAVING vechime_ani >= 2 ";
                    } else if ("grad".equals(tipPromovare)) {
                        // Promovare in grad - angajații peste 50% in ultimul an 
                        sql = "SELECT u.id, u.nume, u.prenume, t.denumire as functie_curenta, t.tip as tip_curent, " +
                              "(SELECT COUNT(*) FROM concedii c " +
                              "WHERE c.id_ang = u.id AND c.start_c >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR) " +
                              "AND c.status = 2) as zile_concediu " +
                              "FROM useri u " +
                              "JOIN tipuri t ON u.tip = t.tip " +
                              "WHERE u.activ = 1 " +
                              "HAVING zile_concediu = 0";
                    }
                    
                    // Prima interogare pentru a verifica dacă există angajați eligibili
                    pstmt2 = conn2.prepareStatement(sql);
                    // pstmt2.setInt(1, userDep);
                    rs3 = pstmt2.executeQuery();
                    
                    hasEligibleEmployees = rs3.next(); // Verifică dacă există cel puțin un rezultat
                    rs3.close(); // Închide rezultatul pentru a putea rula din nou interogarea
                    
                    // Afișează titlul secțiunii
                    %>
                    <div class="subheader mt-4">
                        <i class="ri-user-follow-line me-2"></i>
                        Angajați eligibili pentru <%= tipPromovare.equals("rang") ? "promovare în rang" : "promovare în grad" %>
                    </div>
                    
                    <form id="selectPromovare" method="POST" action="PromovareServlet" class="mt-4">
                        <input type="hidden" name="tip_promovare" value="<%= tipPromovare %>">
                        
                        <% 
                        // Verifică dacă există angajați eligibili
                        if (!hasEligibleEmployees) {
                        %>
                            <div class="alert alert-info" role="alert">
                                <i class="ri-information-line me-2"></i>
                                Nu există angajați eligibili pentru acest tip de promovare în acest moment.
                            </div>
                        <%
                        } else {
                            // Execută din nou interogarea pentru a afișa rezultatele
                            pstmt2 = conn2.prepareStatement(sql);
                            //pstmt2.setInt(1, userDep);
                            rs3 = pstmt2.executeQuery();
                        %>
                            

<div class="table-responsive">
    <table class="table table-hover">
        <thead style="background-color: <%=accent%>; color: white;">
            <tr>
                <th style="width: 5%">
                    <input type="checkbox" id="selectAll" class="form-check-input">
                </th>
                <th style="width: 15%">Nume</th>
                <th style="width: 15%">Prenume</th>
                <th style="width: 20%">Funcție Curentă</th>
                <th style="width: 25%">Criterii Îndeplinite</th>
                <th style="width: 20%">Funcție Nouă</th>
            </tr>
        </thead>
        <tbody>
        <%
        while (rs3.next()) {
            String criterii = "";
            int functieActuala = rs3.getInt("tip_curent");
            int functieNoua = functieActuala + 1; // Inițial setăm la următoarea funcție în ordine
            String functieNouaDenumire = "";
            boolean eligibilPentruPromovare = true;
            
            // Verificăm dacă funcția nu este 4 sau între 15-19
            if (functieActuala == 4 || functieActuala >= 15) {
                eligibilPentruPromovare = false;
            }
            
            if ("rang".equals(tipPromovare)) {
                double vechime = rs3.getDouble("vechime_ani");
                criterii = String.format("Vechime: %.1f ani", vechime);
            } else {
                int zileConcediu = rs3.getInt("zile_concediu");
                criterii = String.format("Concedii în ultimul an: %d zile", zileConcediu);
            }
            
            // Obținem denumirea funcției noi
            Connection conn3 = null;
            PreparedStatement pstmtFunctii = null;
            ResultSet rsFunctii = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn3 = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                String sqlFunctii = "SELECT denumire FROM tipuri WHERE tip = ?";
                pstmtFunctii = conn3.prepareStatement(sqlFunctii);
                pstmtFunctii.setInt(1, functieNoua);
                rsFunctii = pstmtFunctii.executeQuery();
                
                if (rsFunctii.next()) {
                    functieNouaDenumire = rsFunctii.getString("denumire");
                } else {
                    functieNouaDenumire = "Nu există funcție superioară";
                    eligibilPentruPromovare = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
                functieNouaDenumire = "Eroare la determinarea funcției";
                eligibilPentruPromovare = false;
            } finally {
                if (rsFunctii != null) try { rsFunctii.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (pstmtFunctii != null) try { pstmtFunctii.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (conn3 != null) try { conn3.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
            <tr>
                <td>
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input employee-checkbox" 
                               name="angajat_id" value="<%= rs3.getInt("id") %>"
                               <%= !eligibilPentruPromovare ? "disabled" : "" %>>
                        <!-- Input ascuns pentru funcția nouă -->
                        <input type="hidden" name="functie_noua_<%= rs3.getInt("id") %>" value="<%= functieNoua %>">
                    </div>
                </td>
                <td><%= rs3.getString("nume") %></td>
                <td><%= rs3.getString("prenume") %></td>
                <td>
                    <span class="badge" style="background-color: #6c757d;"><%= rs3.getString("functie_curenta") %></span>
                </td>
                <td style="color: <%=accent%>; font-weight: 600;"><%= criterii %></td>
                <td>
                    <% if (eligibilPentruPromovare) { %>
                        <span class="badge" style="background-color: <%=accent%>;"><%= functieNouaDenumire %></span>
                    <% } else { %>
                        <span class="badge" style="background-color: <%=accent%>;"><%= functieActuala == 4 || functieActuala >= 15 ? "Nu se poate promova" : "Nu se poate promova" %></span>
                    <% } %>
                </td>
            </tr>
        <%
        }
        %>
        </tbody>
    </table>
</div>
                            
                            <div class="form-group d-flex justify-content-between mt-4">
                                
                                <button type="submit" id="submitBtn" class="btn btn-primary">
                                    <i class="ri-user-star-line me-1"></i> Promovează Angajații Selectați
                                </button>
                            </div>
                        <% } %>
                    </form>
            <%
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<div class='alert alert-danger'><i class='ri-error-warning-line me-2'></i>A apărut o eroare la încărcarea datelor: " + e.getMessage() + "</div>");
                } finally {
                    if (rs3 != null) try { rs3.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (pstmt2 != null) try { pstmt2.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn2 != null) try { conn2.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
            %>
            <div class="form-group d-flex justify-content-between mt-4">
    <a href="viewang.jsp" class="btn btn-outline-secondary">
        <i class="ri-arrow-left-line me-1"></i> Înapoi la meniul de actiuni
    </a>
    
</div>
        </div>
    </div>

    <script>
        // Validare formular
        document.addEventListener('DOMContentLoaded', function() {
            // Validare pentru formularul de tip promovare
            const tipPromovareForm = document.getElementById('tipPromovareForm');
            if (tipPromovareForm) {
                tipPromovareForm.addEventListener('submit', function(e) {
                    if (!this.checkValidity()) {
                        e.preventDefault();
                        e.stopPropagation();
                    }
                    this.classList.add('was-validated');
                });
            }
            
            // Validare pentru formularul de selectare a angajaților
            const selectPromovareForm = document.getElementById('selectPromovare');
            if (selectPromovareForm) {
                selectPromovareForm.addEventListener('submit', function(e) {
                    const selectedEmployees = document.querySelectorAll('input[name="angajat_id"]:checked');
                    
                    if (selectedEmployees.length === 0) {
                        e.preventDefault();
                        alert('Vă rugăm selectați cel puțin un angajat pentru promovare.');
                        return;
                    }
                });
            }
            
            // Selectare/Deselectare toți angajații
            const selectAllCheckbox = document.getElementById('selectAll');
            if (selectAllCheckbox) {
                selectAllCheckbox.addEventListener('change', function() {
                    const checkboxes = document.querySelectorAll('.employee-checkbox');
                    checkboxes.forEach(checkbox => {
                        checkbox.checked = this.checked;
                    });
                });
            }
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