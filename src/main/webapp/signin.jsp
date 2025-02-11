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
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, id, prenume from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("4") != 0) {
                        if (rs.getString("tip").compareTo("1") == 0) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("0") == 0) {
                            response.sendRedirect("dashboard.jsp");
                        }
                    } else {
                        int id = rs.getInt("id");
                        String prenume = rs.getString("prenume");
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;
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
%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Adaugare utilizator nou</title>

    <!-- CSS -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
   
    <!-- JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
 
 <style>
     @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
    
     :root{
     /*========== culori de baza ==========*/
      --first-color: #2a2a2a;
	  --second-color: hsl(249, 64%, 47%);
	  /*========== cuulori text ==========*/
	  --title-color-light: hsl(244, 12%, 12%);
	  --text-color-light: hsl(244, 4%, 36%);
	  --title-color-dark: hsl(0, 0%, 95%);
	  --text-color-dark: hsl(0, 0%, 80%);
	  /*========== cuulori corp ==========*/
	  --body-color-light: hsl(208, 97%, 85%);
	  --body-color-dark: #1a1a1a;
	  --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
	  --form-border-color-light: hsla(244, 16%, 92%, 0.75);
	  --form-bg-color-dark: #333;
	  --form-border-color-dark: #3a3a3a;
	  /*========== Font ==========*/
	  --body-font: "Poppins", sans-serif;
	  --h2-font-size: 1.25rem;
	  --small-font-size: .813rem;
	  --smaller-font-size: .75rem;
	  --font-medium: 500;
	  --font-semi-bold: 600;
	 }
	 
	 * {
	    margin: 0;
	    padding: 0;
	    box-sizing: border-box;
	    font-family: 'Poppins', sans-serif;
		}
		        
	::placeholder {
	  color: var(--text);
	  opacity: 1; /* Firefox */
	}
	
	::-ms-input-placeholder { /* Edge 12-18 */
	  color: var(--text);
	}
     
     input[type="date"] {
     background-color: <%=accent%>; 
	    color: <%=accent%>; 
	    border: 2px solid <%=accent%>; 
	}
	
	.pika-single {
	    background-color: <%=sidebar%>;
	    color: <%=text%>;
	}
	
	input[type="date"]:focus {
	    border-color: <%=accent%>; 
	    box-shadow: 0 0 8px 0 <%=accent%>; 
	}
	       
    .flex-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        gap: 2rem;
        margin: 2rem;
    }
    
    .calendar-container, .form-container {
        background-color: #2a2a2a;
        padding: 1rem;
        border-radius: 8px;
    }
    
    .calendar-container {
        max-width: 300px;
    }
    
     th.calendar, td.calendar {
        border: 1px solid #1a1a1a;
        text-align: center;
        padding: 8px;
        font-size: 12px;
    }
    
    th.calendar {
        background-color: #333;
    }
    
    .highlight {
        color: white;
    }
	    
	.pika-button:hover, .pika-button:active {
	    background: <%=accent%>;
	    color: #fff; 
	}
	
	.pika-label {
	    color: <%=accent%>;
	    font-size: 16px;
	    background: <%=sidebar%>;
	}
	
	.pika-prev, .pika-next {
	    cursor: pointer;
	    color: <%=text%>;
	    background: <%=sidebar%>;
	    border: none;
	}
	
	.pika-button {
	    border: none;
	    padding: 5px; 
	    color: <%=text%>;
	    background: <%=sidebar%>;
	}
	
	.pika-button:hover {
	    background: <%=clr%>;
	    color: <%=text%>; 
	}
	
	.pika-single .is-today .pika-button {
	    color: <%=accent%>;
	    font-weight: bold;
	}
	
	.pika-single .is-selected .pika-button {
	    background: <%=accent%>; 
	    color: #fff; 
	}
	
	.pika-weekday {
	    font-weight: normal;
	}
	
	.pika-single .is-selected {
	    background: <%=accent%>;
	    color: #fff; 
	}
	
	.pika-single .is-today {
	    border: 2px solid <%=accent%> ;
	    color: <%=accent%>;
	}
	.pika-title {
	    background: <%=sidebar%>; 
	    color: <%=accent%>; 
	    text-align: center; 
	    padding: 5px 0; 
	    border-top-left-radius: 8px; 
	    border-top-right-radius: 8px;
	}
	
	.pika-month, .pika-year {
	    color: <%=accent%>; 
	    background: <%=sidebar%>; 
	    border: none; 
	}
	
	.pika-single {
	    background: <%=sidebar%>; 
	    border-radius: 1rem;
	}
	
	table.picka-table tr {
	    background-color: <%=accent%>; 
	}
	
	.pika-single .pika-week {
	    background:  <%=clr%>; 
	}
    </style>
</head>
<body style="--bg:<%=accent%>; --clr:<%=clr%>; --sd:<%=sidebar%>; --text:<%=text%>; background:<%=clr%>">
    <div class="container">
        <div class="login__content" style="position: fixed; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; border-radius: 2rem; background:<%=clr%>; color:<%=clr%>">
            <form action="<%= request.getContextPath() %>/register" method="post" class="login__form" style="background:<%=sidebar%>; color:<%=clr%>; border-color: <%=clr%>">
                <div>
                    <h1 class="login__title">
                        <span style="color: <%=accent%>">Adaugare utilizator nou</span>
                    </h1>
                </div>
                <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Nume</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="nume" placeholder="Introduceti numele" required class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Prenume</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="prenume" placeholder="Introduceti prenumele" required class="login__input">
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Data nasterii</label>
                                                           
    <input type="date" id="start-hidden" name="data_nasterii" value="2001-07-22" min="1954-01-01" max="2036-12-31" class="login__input" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">

                    </div>
                    
                   <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Pozitie</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="pozitie" class="login__input" required>
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT tip, denumire FROM tipuri;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs1 = stmt.executeQuery();

                                if (!rs1.next()) {
                                    out.println("Nu exista date sau date incorecte");
                                } else {
                                    do {
                                        out.println("<option value='" + rs1.getString("tip") + "' required>" + rs1.getString("denumire") + "</option>");
                                    } while (rs1.next());
                                }
                                rs1.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                               
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>
                     
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">E-mail</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="email" placeholder="Introduceti e-mailul" required class="login__input">
                    </div>
					
                </div></td>              
                
                <td>
                
                <div class="form__section" style="margin:0; top:-10px;">
                    
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Departament</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="departament" class="login__input" required>
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "SELECT id_dep, nume_dep FROM departament;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs1 = stmt.executeQuery();

                                if (!rs1.next()) {
                                    out.println("Nu exista date sau date incorecte");
                                } else {
                                    do {
                                        out.println("<option value='" + rs1.getString("id_dep") + "' required>" + rs1.getString("nume_dep") + "</option>");
                                    } while (rs1.next());
                                }
                                rs1.close();
                                stmt.close();
                                con.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                               
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>

                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Rang</label>
                        <select style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" name="rang" class="login__input">
                            <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                                String sql = "select tip, denumire from tipuri;";
                                PreparedStatement stmt = con.prepareStatement(sql);
                                ResultSet rs2 = stmt.executeQuery();
                                if (rs2.next() == false) {
                                    out.println("No Records in the table");
                                } else {
                                    do {
                                        out.println("<option value='" + rs2.getString("tip") + "' required>" + rs2.getString("denumire") + "</option>");
                                    } while (rs2.next());
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                out.println("<script type='text/javascript'>");
                                out.println("alert('Date introduse incorect sau nu exista date!');");
                                out.println("alert('" + e.getMessage() + "');");
                                out.println("</script>");
                            }
                            %>
                        </select>
                    </div>
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Telefon</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="telefon" placeholder="Introduceti telefonul" required class="login__input">
                    </div>
                     <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">CNP</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="cnp" placeholder="Introduceti codul numeric personal" required class="login__input">
                    </div>
                    
                </div>
                 
                </td></tr>
</table>
 <a href="viewang3.jsp" class="login__forgot" style="margin:0; top:-10px; color:<%out.println(accent);%> ">Inapoi</a>
                <div class="login__buttons">
                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button">
                </div>
                
            </form>
            
        </div>
    </div>
<script>

document.addEventListener("DOMContentLoaded", function() {
	var picker = new Pikaday({
	    field: document.getElementById('start'),
	    format: 'YYYY-MM-DD', // Make sure this format is supported by your version of Pikaday or Moment.js
	    minDate: new Date(1954, 0, 1), // Minimum date
	    maxDate: new Date(2025, 12, 31), // Maximum date
	    yearRange: [1954, 2025],
	    disableWeekends: false,
	    showWeekNumber: true,
	    isRTL: false, // Right-to-left languages
	    theme: 'current',
	    i18n: {
	        previousMonth: 'Prec.',
	        nextMonth: 'Urm.',
	        months: ['Ian.', 'Febr.', 'Mar.', 'Apr.', 'Mai', 'Iun.', 'Iul.', 'Aug.', 'Sept.', 'Oct.', 'Nov.', 'Dec.'],
	        weekdays: ['Duminică', 'Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
	        weekdaysShort: ['Du.', 'Lu.', 'Ma.', 'Mi.', 'Joi', 'Vi.', 'Sâ.']
	    },
	    
	    firstDay: 1,
	    onSelect: function() {
	        var date = this.getDate();
	        date.setDate(date.getDate() + 1);
	        // console.log(date); // Check what you get here
	        if (date) {
	        	  var formattedDate = moment(date).format('YYYY-MM-DD');
	            // var formattedDate = date.toISOString().substring(0, 10);
	            console.log(formattedDate); // Ensure format is correct
	            document.getElementById('start-hidden').value = formattedDate;
	            document.getElementById('start').value = formattedDate;
	        } else {
	            console.error('No date returned from date picker');
	        }
	    }
	});
	
});

}

</script>

    <% 
    if ("true".equals(request.getParameter("p"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Trebuie sa alegeti o parola mai complexa!');");
        out.println("</script>");
        out.println("<br>Parola trebuie sa contina:<br>");
        out.println("- minim 8 caractere<br>");
        out.println("- un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>");
        out.println("- o litera mare<br>");
        out.println("- o litera mica<br>");
        out.println("- o cifra<br>");
        out.println("- cifrele alaturate sa nu fie egale sau consecutive<br>");
        out.println("- literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele");
    }
    
    if ("true".equals(request.getParameter("cnp"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('CNP scris incorect! Verificati log-ul serverului pentru detalii!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("n"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("pn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Prenume scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("t"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Telefon scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("e"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('E-mail scris incorect!');");
        out.println("</script>");
    }

    if ("true".equals(request.getParameter("dn"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Utilizatorul trebuie sa aiba minim 18 ani!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pms"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un sef / departament!');");
        out.println("</script>");
    }   

    if ("true".equals(request.getParameter("pmd"))) {
        out.println("<script type='text/javascript'>");
        out.println("alert('Poate fi maxim un director / departament!');");
        out.println("</script>");
    }   
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
