<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        if (currentUser != null) {
            String user = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement(
                		 "SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                                 "dp.denumire_completa AS denumire FROM useri u " +
                                 "JOIN tipuri t ON u.tip = t.tip " +
                                 "JOIN departament d ON u.id_dep = d.id_dep " +
                                 "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                                 "WHERE u.username = ?")) {
                preparedStatement.setString(1, user);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    int userdep = rs.getInt("id_dep");
                    String functie = rs.getString("functie");
                    int ierarhie = rs.getInt("ierarhie");

                    // Funcție helper pentru a determina rolul utilizatorului
                    boolean isDirector = (ierarhie < 3) ;
                    boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                    boolean isIncepator = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                    boolean isAdmin = (functie.compareTo("Administrator") == 0);

                    if (isAdmin) {
                        response.sendRedirect("homeadmin.jsp"); 
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
                        try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT * from teme where id_usr = ?";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>

    <title>Vizualizare concedii</title>
</head>
<body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

    <div class="container" style="position: fixed; top:1rem; left: 28%; border-radius: 2rem; padding: 0; margin: 0; background: <%out.println(clr);%>">
        <div class="login__content" style="overflow: auto; position: fixed; top: 1rem; border-radius: 2rem; margin: 0; height: 100vh; border-radius: 2rem; margin: 0; padding: 0; background:<%out.println(clr);%>; color:<%out.println(text);%>">
            
            <div style="overflow: auto; position: fixed; top: 6rem; border-radius: 2rem; margin: 0; border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(sidebar);%>; color:<%out.println(accent);%>" id="searchForm" class="login__form">
                <div>
                    <h1 class="login__title"><span style="color:<%out.println(accent);%>">Vizualizare concedii dintr-un anumit departament</span></h1>
                </div>
                
                <div class="login__inputs">
                    <div>
                                            <label style="color:<%out.println(text);%>" class="login__label">Departament</label>
                                            <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name='dep' id='dep' class="login__input">
                                                <%
                                                try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM departament;")) {
                                                    try (ResultSet rs1 = stm.executeQuery()) {
                                                        if (rs1.next()) {
                                                            do {
                                                                int id = rs1.getInt("id_dep");
                                                                String nume = rs1.getString("nume_dep");
                                                                out.println("<option value='" + id + "'>" + nume + "</option>");
                                                            } while (rs1.next());
                                                        } else {
                                                            out.println("<option value=''>Nu exista departamente disponibile.</option>");
                                                        }
                                                    }
                                                }
                                                %>
                                            </select>
                                        </div>
                    
                    <div>
                        <label style="color:<%out.println(text);%>" class="login__label">Status</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" id="status" class="login__input">
                            <option value="3">Oricare</option>
                            <%
                            try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM statusuri;")) {
                                try (ResultSet rs1 = stm.executeQuery()) {
                                    if (rs1.next()) {
                                        do {
                                            int id = rs1.getInt("status");
                                            String nume = rs1.getString("nume_status");
                                            out.println("<option value='" + id + "'>" + nume + "</option>");
                                        } while (rs1.next());
                                    } else {
                                        out.println("<option value=''>Nu exista statusuri disponibile.</option>");
                                    }
                                }
                            }
                            %>
                        </select>
                    </div>
                    
                    <div>
                        <label style="color:<%out.println(text);%>" class="login__label">Tip</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" id="tip" class="login__input">
                            <option value="-1">Oricare</option>
                            <%
                            try (PreparedStatement stm = connection.prepareStatement("SELECT * FROM tipcon;")) {
                                try (ResultSet rs1 = stm.executeQuery()) {
                                    if (rs1.next()) {
                                        do {
                                            int id = rs1.getInt("tip");
                                            String nume = rs1.getString("motiv");
                                            out.println("<option value='" + id + "'>" + nume + "</option>");
                                        } while (rs1.next());
                                    } else {
                                        out.println("<option value=''>Nu exista tipuri disponibile.</option>");
                                    }
                                }
                            }
                            %>
                        </select>
                    </div>

                    <div class="login__check">
                        <input type="checkbox" id="an" class="login__check-input"/>
                        <label style="color:<%out.println(text);%>" for="an" class="login__check-label">An</label>
                    </div>
                       
                    <div class="date-input-container" style="position: relative;">
                        <div id="startt">
                            <label style="color:<%out.println(text);%>" class="login__label">Inceput</label>
                            <input type="hidden" id="start-hidden">
                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" id="start" min="1954-01-01" max="2036-12-31" class="login__input"/>
                        </div>
                    </div>
             
                    <div class="date-input-container" style="position: relative;">
                        <div id="endd">
                            <label style="color:<%out.println(text);%>" class="login__label">Final</label>
                            <input type="hidden" id="end-hidden">
                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" id="end" min="1954-01-01" max="2036-12-31" class="login__input"/>
                        </div>
                    </div>
                </div>
                
                <!-- Campuri ascunse pentru a pastra compatibilitatea -->
                <input type="hidden" name="userId" id="userId" value="<%= userId %>"/>
                                    <input type="hidden" name="pag" id="pag" value="7"/>
                                    <input type="hidden" id="id" name="id" value="-1"/>
                
                <div class="login__buttons">
                    <button 
                        style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                        class="login__button" 
                        id="searchButton"
                        type="button">Cautati</button>
                </div>
            </div>
        </div>
    </div>
<form id="postForm" action="masina1.jsp" method="post">
    <input type="hidden" name="json" id="jsonInput" />
</form>

    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>

    <script>
    document.addEventListener("DOMContentLoaded", function() {
        // Inițializare date pickers
        initializeDatePickers();
        
        // Adaugă listener pentru checkbox-ul de an
        document.getElementById('an').addEventListener('change', toggleDateInputs);
        
        // Inițial verifică starea checkbox-ului
        toggleDateInputs();
        
        // Adaugă listener pentru butonul de căutare
        document.getElementById('searchButton').addEventListener('click', searchLeaves);
    });

    // Inițializează date pickers
    function initializeDatePickers() {
        var picker1 = new Pikaday({
            field: document.getElementById('start'),
            format: 'YYYY-MM-DD',
            minDate: new Date(2000, 0, 1),
            maxDate: new Date(2025, 12, 31),
            yearRange: [2000, 2025],
            disableWeekends: false,
            showWeekNumber: true,
            isRTL: false,
            theme: 'current',
            i18n: {
                previousMonth: 'Luna precedentă',
                nextMonth: 'Luna următoare',
                months: ['Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'],
                weekdays: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
                weekdaysShort: ['Dum', 'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm']
            },
            firstDay: 1,
            onSelect: function() {
                var date = this.getDate();
                date.setDate(date.getDate() + 1);
                if (date) {
                    var formattedDate = date.toISOString().substring(0, 10);
                    document.getElementById('start-hidden').value = formattedDate;
                }
            }
        });
        
        var picker2 = new Pikaday({
            field: document.getElementById('end'),
            format: 'YYYY-MM-DD',
            minDate: new Date(2000, 0, 1),
            maxDate: new Date(2025, 12, 31),
            yearRange: [2000, 2025],
            disableWeekends: false,
            showWeekNumber: true,
            isRTL: false,
            theme: 'current',
            i18n: {
                previousMonth: 'Luna precedentă',
                nextMonth: 'Luna următoare',
                months: ['Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie'],
                weekdays: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
                weekdaysShort: ['Dum', 'Lun', 'Mar', 'Mie', 'Joi', 'Vin', 'Sâm']
            },
            firstDay: 1,
            onSelect: function() {
                var date = this.getDate();
                date.setDate(date.getDate() + 1);
                if (date) {
                    var formattedDate = date.toISOString().substring(0, 10);
                    document.getElementById('end-hidden').value = formattedDate;
                }
            }
        });
    }

    // Funcție pentru a arăta/ascunde câmpurile de dată în funcție de checkbox
    function toggleDateInputs() {
        var radioPer = document.getElementById('an');
        var startInput = document.getElementById('startt');
        var endInput = document.getElementById('endd');
        
        if (radioPer.checked) {
startInput.style.display = 'none';
            endInput.style.display = 'none';
        } else {
            startInput.style.display = 'block';
            endInput.style.display = 'block';
        }
    }

    function searchLeaves() {
        const data = {
            id: document.getElementById('id').value,
            status: document.getElementById('status').value,
            tip: document.getElementById('tip').value,
            dep: document.getElementById('dep').value,
            pag: document.getElementById('pag').value,
            userId: document.getElementById('userId').value,
            an: document.getElementById('an').checked ? "1" : "1",
            start: document.getElementById('start-hidden').value || '',
            end: document.getElementById('end-hidden').value || ''
        };
        
        console.log("Trimit date:", data);  // Debug log
        
        fetch('masina1.jsp', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
        .then(response => {
            console.log("Status răspuns:", response.status); // Debug log
            return response.json();
        })
        .then(responseData => {
            console.log("Date primite:", responseData); // Debug log
            
            // Salvăm datele în sessionStorage
            sessionStorage.setItem('tableData', JSON.stringify(responseData));
            console.log("Date salvate în sessionStorage"); // Debug log
            
            // Redirectăm către pagina de afișare
            window.location.href = 'masina2.jsp';
        })
        .catch(error => {
            console.error("Eroare:", error);
            alert("A apărut o eroare: " + error.message);
        });
    }
    </script>
                        <%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
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