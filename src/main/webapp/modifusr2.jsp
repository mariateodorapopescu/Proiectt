<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>


<%
String cnp = "";
cnp = request.getParameter("cnp");
if (cnp == null){
	cnp = "";
}
System.out.println(cnp); // ok
String idd = request.getParameter("id");

if (idd == null || idd.trim().isEmpty()) {
 idd = "0"; 
} else {
	idd = idd.replaceAll("[^0-9]", ""); // Păstrează doar cifre
}
if (idd.isEmpty()) {
 idd = "0";
}
int idd2 = 0;
try {
 idd2 = Integer.parseInt(idd);
 System.out.println("ID-ul este: " + idd2); // ✅ Va afișa un număr valid
} catch (NumberFormatException e) {
 System.err.println("Eroare: ID invalid! Valoarea primită: " + idd);
}

HttpSession sesi = request.getSession(false);
    		String username = null;
if (sesi != null) {
	 username = (String) sesi.getAttribute("username");
	 System.out.println(username); // ok
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        username = currentUser.getUsername();
       
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            preparedStatement = connection.prepareStatement(
            		"SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie" +
                            "dp.denumire_completa AS denumire_specifică FROM useri u " +
                            "JOIN tipuri t ON u.tip = t.tip " +
                            "JOIN departament d ON u.id_dep = d.id_dep " +
                            "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                            "WHERE u.username = ?");
            preparedStatement.setString(1, username);
            rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                out.println("<script type='text/javascript'>alert('Date introduse incorect sau nu exista date!');</script>");
            } else {
                int userId = 0;
                userId = rs.getInt("id");
                System.out.println(userId); // ok
                int userType = 0;
                userType = rs.getInt("tip");
                System.out.println(userType); // ok
                String functie = rs.getString("functie");
                int ierarhie = rs.getInt("ierarhie");

                // Funcție helper pentru a determina rolul utilizatorului
                boolean isDirector = (ierarhie < 3) ;
                boolean isSef = (ierarhie >= 4 && ierarhie <=5);
                boolean isIncepator = (ierarhie >= 10);
                boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator; // tipuri 1, 2, 5-9
                boolean isAdmin = (functie.compareTo("Administrator") == 0);

                String accent = "##03346E";
                String clr = "#d8d9e1";
                String sidebar =  "#ecedfa";
                String text = "#333";
                String card =  "#ecedfa";
               	String hover = "#ecedfa";
                // Retrieve user theme settings
                try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM teme WHERE id_usr = ?")) {
                    stmt.setInt(1, userId);
                    try (ResultSet rs2 = stmt.executeQuery()) {
                        if (rs2.next()) {
                           	accent = rs2.getString("accent");
                            clr = rs2.getString("clr");
                            sidebar = rs2.getString("sidebar");
                            text = rs2.getString("text");
                            card = rs2.getString("card");
                            hover = rs2.getString("hover");

                            // Output user-specific style settings
                            out.println("<style>:root {--bg:" + accent + "; --clr:" + clr + "; --sd:" + sidebar + "; --text:" + text + "; background:" + clr + ";}</style>");
                        }
                    }
                }

                // Check if the user type is not admin
                if (!isAdmin) {
                    // Logic for non-admin users
                     try (PreparedStatement stmt = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                            stmt.setString(1, cnp);
                            try (ResultSet rs1 = stmt.executeQuery()) {
                                if (!rs1.next()) {
                                    out.println("<script type='text/javascript'>alert('Cod incorect sau acces neautorizat!'); location='modifdel.jsp';</script>");
                                    return;
                                }
                                userId = rs1.getInt("id");
                                System.out.println(userId);
                            } catch (Exception e) {
                            	out.println("<script type='text/javascript'>alert('Cod incorect sau acces neautorizat!'); location='modifdel.jsp';</script>");
                                return;
                            }
                        } catch (Exception e) {
                        	out.println("<script type='text/javascript'>alert('Cod incorect sau acces neautorizat!'); location='modifdel.jsp';</script>");
                            return;
                        }
                } else {
                	userId = idd2;
                	System.out.println(userId);
                }
                              
                %>
                <html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <title>Modificare Utilizator</title>
    <style>
    
    
  
/* Hover Effect on Date Buttons */
.pika-button:hover, .pika-button:active {
    background: <%=accent%>;
    color: #fff; /* White text for hover */
}

/* Styling for the navigation header */
.pika-label {
    color: <%=accent%>; /* Light grey color for the month and year */
    font-size: 16px; /* Larger font size */
    background: <%=sidebar%>;
}

/* Navigation buttons */
.pika-prev, .pika-next {
    cursor: pointer;
    color: <%=text%>;
    background: <%=sidebar%>;
    border: none;
}

/* Table cells */
.pika-button {
    border: none; /* Remove default borders */
    padding: 5px; /* Padding for the date numbers */
    color: <%=text%>; /* Default date color */
    background: <%=sidebar%>;
}

/* Hover effect on date cells */
.pika-button:hover {
    background: <%=clr%>; /* Darker background on hover */
    color: <%=text%>; /* White text on hover */
}

/* Special styles for today */
.pika-single .is-today .pika-button {
    color: <%=accent%>; /* Green color for today's date */
    font-weight: bold; /* Make it bold */
}

/* Styles for the selected date */
.pika-single .is-selected .pika-button {
    background: <%=accent%>; /* Bright color for selection */
    color: #fff; /* White text for selected date */
}

/* Weekday labels */
.pika-weekday {
    /* color: #aaa; */ /* Light gray for weekdays */
    font-weight: normal;
}

/* Styling for the Selected Date */
.pika-single .is-selected {
    background: <%=accent%>;
    color: #fff; /* White text for selected date */
}

/* Styling for Today's Date */
.pika-single .is-today {
    border: 2px solid <%=accent%> /* White border for today */
    color: <%=accent%> /* White text for today */
}
.pika-title {
    background: <%=sidebar%>; /* Darker shade for the header */
    color: <%=accent%>; /* White text for clarity */
    text-align: center; /* Center the month and year */
    padding: 5px 0; /* Padding for better spacing */
    border-top-left-radius: 8px; /* Rounded corners at the top */
    border-top-right-radius: 8px;
}
/* If you use dropdowns for month/year selection, style them too */
.pika-month, .pika-year {
    color: <%=accent%>; /* Matching text color */
    background: <%=sidebar%>; /* Transparent background to blend in with the header */
    border: none; /* Remove borders for a cleaner look */
}
.pika-single {
    background: <%=sidebar%>; /* Change to your desired color */
    border-radius: 1rem;
}

table.picka-table tr {
    background-color: <%=accent%>; /* Golden color for the header */
}


.pika-single .pika-week {
    background:  <%=clr%>; /* Change week numbers background */
}

    </style>
</head>
                <body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

<div class="container" style="position: fixed; top:0; left: 28%; border-radius: 2rem; padding: 0;  margin: 0; background: <%out.println(clr);%>">
        <div class="login__content" style="position: fixed; top: 0; border-radius: 2rem; margin: 0; height: 100vh; justify-content: center; border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
  
                <%
                
               out.println("        <form style=\"position: fixed; top: 1rem;  border-radius: 2rem; margin: 0; background:" +  sidebar + "; border-color: " + sidebar + "; color: " + accent + "; \" action=" +  request.getContextPath() + "/modifusr" +" method=\"post\" class=\"login__form\">");
            	out.println("            <div>");
            	out.println("                <h1 style=\"color: " + accent + "; class=\"login__title\">");
            	out.println("                    <span>Modificare Utilizator</span>");
            	out.println("                </h1>");
            	out.println("            </div>");
            	
            			
            	String query2 = "SELECT * from useri where id = ?";
            	try (PreparedStatement stmt1 = connection.prepareStatement(query2)) {
            	    stmt1.setInt(1, userId);
            	    try (ResultSet rs2 = stmt1.executeQuery()) {
            	        if (rs2.next()) {
            	        	out.println("<table width=\"100%\" style=\"margin:0; top:-10px;\"> <tr><td>");
                        	out.println("            <div class=\"form__section\" style=\"margin:0; top:-10px;\">");
                        	out.println("                <div>");
                        	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Nume</label>");		
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"nume\" placeholder=\"Introduceti numele\" value=\"" +  rs2.getString("nume") + "\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Prenume</label>");
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"prenume\" placeholder=\"Introduceti prenumele\" value=\"" +  rs2.getString("prenume") + "\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Data nasterii</label>");
			            			%>
			            			
			            			<input type="hidden" id="start-hidden" name="data_nasterii" value=<%=rs2.getDate("data_nasterii") %>>
                                            <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" id="start" name="data_nasterii" value="2001-07-22" min="1954-01-01" max="2036-12-31" value = <%=rs2.getDate("data_nasterii") %> class="login__input">
                    
			            			
			            			<%
			            	// out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"date\" name=\"data_nasterii\" value=\""+ rs2.getDate("data_nasterii") + "\" min=\"1954-01-01\" max=\"2036-12-31\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">E-mail</label>");
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"email\" name=\"email\" placeholder=\"Introduceti e-mailul\" value=\" "+ rs2.getString("email") +"\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	out.println(" </div></td> <td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><p>   </p></td><td><div class=\"form__section\" style=\"margin:0; top:-10px;\">");
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Telefon</label>");
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"telefon\" placeholder=\"Introduceti telefonul\" value=\""+ rs2.getString("telefon") +"\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Departament</label>");
			            	out.println("                    <select style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" name=\"departament\" class=\"login__input\">");
			
			                     String id_dep = "";
			                     String den_dep = "";
			                                String sql = "SELECT u.id_dep as id_d, d.nume_dep as den_dep FROM useri u JOIN departament d ON u.id_dep = d.id_dep WHERE id = ?";
			                                PreparedStatement stm = connection.prepareStatement(sql);
			                                stm.setInt(1, userId);
			                                ResultSet rs7 = stm.executeQuery();
			                                if (rs7.next()) {
			                                    id_dep = rs7.getString("id_d");
			                                    den_dep = rs7.getString("den_dep");
			                                }
			                                rs7.close();
			                      
			                        try {
			                            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
			                            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
			                            String sql2 = "SELECT id_dep, nume_dep FROM departament;";
			                            PreparedStatement stmt2 = connection.prepareStatement(sql2);
			                            ResultSet rs8 = stmt2.executeQuery();
			
			                            while (rs8.next()) {
			                                String depId = rs8.getString("id_dep");
			                                String depName = rs8.getString("nume_dep");
			                                String selected = "";
			                                if (depId.equals(id_dep)) {
			                                    selected = "selected";
			                                }
			                                out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
			                            }
			                            rs8.close();
			                           
			                        } catch (Exception e) {
			                            e.printStackTrace();
			                            out.println("<script type='text/javascript'>");
			                            out.println("alert('Date introduse incorect sau nu exista date!');");
			                            out.println("alert('" + e.getMessage() + "');");
			                            out.println("</script>");
			                        }
			                        
			                        out.println("                    </select>");
			                        out.println("                </div>");
			                        out.println("                <div>");
			                        out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Pozitie</label>");
			                        out.println("                    <select style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" name=\"tip\" class=\"login__input\">");
			                        
			                        String tip = null;
			                        String nume = null;
			                       
			                        try {
			                            String sql3 = "SELECT u.tip as tiip, t.denumire as den_tip FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE id = ?";
			                            PreparedStatement stmt3 = connection.prepareStatement(sql3);
			                            stmt3.setInt(1, userId);
			                            ResultSet rs9 = stmt3.executeQuery();
			                            if (rs9.next()) {
			                                tip = rs9.getString("tiip");
			                                nume = rs9.getString("den_tip");
			                                
			                            }
			                            rs9.close();
			                           
			                            
			                        } catch (Exception e) {
			                            e.printStackTrace();
			                            out.println("<script type='text/javascript'>");
			                            out.println("alert('Date introduse incorect sau nu exista date!');");
			                            out.println("alert('" + e.getMessage() + "');");
			                            out.println("</script>");
			                        }
			                        
			                        try {
			                            String sql4 = "SELECT tip, denumire FROM tipuri;";
			                            PreparedStatement stmt4 = connection.prepareStatement(sql4);
			                            ResultSet rs10 = stmt4.executeQuery();
			
			                            while (rs10.next()) {
			                                String tip_id = rs10.getString("tip");
			                                String depName = rs10.getString("denumire");
			                                String selected = "";
			                                if (tip_id.equals(tip)) {
			                                    selected = "selected";
			                                }
			                                out.println("<option value='" + tip + "' " + selected + ">" + nume + "</option>");
			                            }
			                            rs10.close();
			                            stmt4.close();
			                          
			                        } catch (Exception e) {
			                            e.printStackTrace();
			                            out.println("<script type='text/javascript'>");
			                            out.println("alert('Date introduse incorect sau nu exista date!');");
			                            out.println("alert('" + e.getMessage() + "');");
			                            out.println("</script>");
			                        }
			                        
				            out.println("                        </select>");
				            out.println("                    </div>");
				            out.println("                <div>");
	                        out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Rang</label>");
	                        out.println("                    <select style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" name=\"tip\" class=\"login__input\">");
	                        
	                        String tip2 = null;
	                        String nume2 = null;
	                       
	                        try {
	                            String sql3 = "SELECT u.tip as tiip, t.denumire as den_tip FROM useri u JOIN tipuri t ON u.tip = t.tip WHERE id = ?";
	                            PreparedStatement stmt3 = connection.prepareStatement(sql3);
	                            stmt3.setInt(1, userId);
	                            ResultSet rs9 = stmt3.executeQuery();
	                            if (rs9.next()) {
	                                tip2 = rs9.getString("tiip");
	                                nume2 = rs9.getString("den_tip");
	                            }
	                            rs9.close();
	                           
	                            
	                        } catch (Exception e) {
	                            e.printStackTrace();
	                            out.println("<script type='text/javascript'>");
	                            out.println("alert('Date introduse incorect sau nu exista date!');");
	                            out.println("alert('" + e.getMessage() + "');");
	                            out.println("</script>");
	                        }
	                        
	                        try {
	                            String sql4 = "SELECT tip, denumire FROM tipuri;";
	                            PreparedStatement stmt4 = connection.prepareStatement(sql4);
	                            ResultSet rs10 = stmt4.executeQuery();
	
	                            while (rs10.next()) {
	                                String rang_id = rs10.getString("tip");
	                                String rang_nume = rs10.getString("denumire");
	                                String selected = "";
	                                if (rang_id.equals(tip2)) {
	                                    selected = "selected";
	                                }
	                                out.println("<option value='" + rang_id + "' " + selected + ">" + rang_nume + "</option>");
	                            }
	                            rs10.close();
	                            stmt4.close();
	                          
	                        } catch (Exception e) {
	                            e.printStackTrace();
	                            out.println("<script type='text/javascript'>");
	                            out.println("alert('Date introduse incorect sau nu exista date!');");
	                            out.println("alert('" + e.getMessage() + "');");
	                            out.println("</script>");
	                        }
	                        
		            out.println("                        </select>");
		            out.println("                    </div>");
		            out.println("                <div>");
	            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">CNP</label>");
	            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"cnp\" placeholder=\"Introduceti codul...\" value=\"" +  rs2.getString("cnp") + "\" required class=\"login__input\">");
	            	out.println("                </div>");
				            out.println("                </div>");
				            
				            out.println("</td></tr></table>");
				            
				            out.println("<a style=\"color: " + accent + "\" href ='modifdel.jsp' class='login__forgot''>Inapoi</a>");
		                    %>
		                        <div class="login__buttons">
		                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
		                    type="submit" value="Modificati" class="login__button">
		                </div>
		                <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
<script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>

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
	        // console.log(date); // Check what you get here
	        if (date) {
	            var formattedDate = date.toISOString().substring(0, 10);
	            console.log(formattedDate); // Ensure format is correct
	            document.getElementById('start-hidden').value = formattedDate;
	        } else {
	            console.error('No date returned from date picker');
	        }
	    }
	});
	
});
</script>
		                <%
				            	        }
				            	    }
				            	}
            out.println("                <input type=\"hidden\" name=\"id\" value=\"" + userId + "\"/>");
            out.println("            </form>");
            out.println("        </div>");
            out.println("    </div>");
                
                
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script type='text/javascript'>alert('Eroare la baza de date!'); location='logout';</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException ignore) {}
            if (connection != null) try { connection.close(); } catch (SQLException ignore) {}
        }
    } else {
        out.println("<script type='text/javascript'>alert('Utilizator neconectat!'); location='login.jsp';</script>");
    }
} else {
    out.println("<script type='text/javascript'>alert('Nu e nicio sesiune activa!'); location='login.jsp';</script>");
}
%>

</body>
</html>
