<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, com.fasterxml.jackson.databind.ObjectMapper, bean.MyUser, jakarta.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>

<%
    // Obținem sesiunea curentă
    HttpSession sesi = request.getSession(false);
    if (sesi == null) {
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Nu există sesiune activă\"}");
        } else {
            out.println("<script>alert('Nu există sesiune activă!');</script>");
            response.sendRedirect("logout");
        }
        return;
    }

    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser == null) {
        if ("true".equals(request.getParameter("json"))) {
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Utilizator neconectat\"}");
        } else {
            out.println("<script>alert('Utilizator neconectat!');</script>");
            response.sendRedirect("logout");
        }
        return;
    }

    String username = currentUser.getUsername();
    int userdep = 0, id = 0, userType = 0;

    // Setăm culorile implicite
    String accent = "#10439F";
    String clr = "#d8d9e1";
    String sidebar = "#ECEDFA";
    String text = "#333";
    String card = "#ECEDFA";
    String hover = "#ECEDFA";

    Class.forName("com.mysql.cj.jdbc.Driver");

    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {

        preparedStatement.setString(1, username);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            id = rs.getInt("id");
            userType = rs.getInt("tip");
            userdep = rs.getInt("id_dep");

            if (userType != 4) {
                String query = "SELECT * FROM teme WHERE id_usr = ?";
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
            }
        }
    }

  
%>

<!DOCTYPE html>
<html lang="ro">
   <head>
        <title>Concedii</title>
         <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
        <!--=============== REMIXICONS ===============-->
        <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    
        <!--=============== CSS ===============-->
        <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css"> 
       <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
       <style>
            a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
            
        </style>
       
       <!--=============== icon ===============-->
        <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
       
        <!--=============== scripts ===============-->
        <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
         <style>
		.modal {
		    display: none;
		    position: fixed;
		    z-index: 1;
		    left: 0;
		    top: 0;
		    width: 100%;
		    height: 100%;
		    overflow: auto;
		    background-color: <%=clr%>;
		    border-radius: 2rem;
		}
		
		.modal-content {
		    background-color: <%=sidebar%>;
		    border-radius: 2rem;
		    margin: 15% auto;
		    padding: 20px;
		    border: 1px solid #888;
		    width: 80%;
		}
		
		.close {
			background-color: <%=sidebar%>;
		    color: <%=accent%>;
		    float: right;
		    font-size: 28px;
		    font-weight: bold;
		}
		
		.close:hover,
		.close:focus {
		    color: black;
		    text-decoration: none;
		    cursor: pointer;
		}
		
		body {
			top: 0;
			left: 0;
			position: fixed;
			width: 100vh;
			height: 100vh;
			padding: 0;
			margin: 0;
		}
		
        a, a:visited, a:hover, a:active{color:#eaeaea !important; text-decoration: none;}
  
        .status-icon {
            display: inline-block;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            text-align: center;
            line-height: 20px;
            color: white;
            font-size: 14px;
        }
        
        .status-neaprobat { background-color: #88aedb; }
        .status-dezaprobat-sef { background-color: #b37142; }
        .status-dezaprobat-director { background-color: #873931; }
        .status-aprobat-director { background-color: #40854a; }
        .status-aprobat-sef { background-color: #ccc55e; }
        .status-pending { background-color: #e0a800; }
       
       	/* Tooltip */
       	.tooltip {
		  position: relative; 
		  border-bottom: 1px dotted black; 
		}
		
		.tooltip .tooltiptext {
		  visibility: hidden;
		  width: 120px;
		  background-color: rgba(0,0,0,0.5);
		  color: white;
		  text-align: center;
		  padding: 5px 0;
		  border-radius: 6px;
		  position: absolute;
		  z-index: 1;
		}
		
		.tooltip:hover .tooltiptext {
		  visibility: visible;
		}
		
       .content, .main-content {
		    overflow: auto; /* Permite scroll-ul orizontal */
		    width: 100%; /* Asigură că folosește întreaga lățime disponibilă */
		}
       
		::-webkit-scrollbar {
			    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
		.status-icon {
    display: inline-block;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    text-align: center;
    line-height: 24px;
    color: white;
}

.tooltip {
    position: relative;
    display: inline-block;
}

.tooltip .tooltiptext {
    visibility: hidden;
    width: 120px;
    background-color: rgba(0, 0, 0, 0.8);
    color: white;
    text-align: center;
    padding: 5px;
    border-radius: 6px;
    position: absolute;
    z-index: 1;
    bottom: 125%;
    left: 50%;
    transform: translateX(-50%);
    opacity: 0;
    transition: opacity 0.3s;
}

.tooltip:hover .tooltiptext {
    visibility: visible;
    opacity: 1;
}

.status-neaprobat { background-color: #88aedb; }
.status-dezaprobat-sef { background-color: #b37142; }
.status-dezaprobat-director { background-color: #873931; }
.status-aprobat-director { background-color: #40854a; }
.status-aprobat-sef { background-color: #ccc55e; }
.status-pending { background-color: #e0a800; }

/* Stiluri pentru mesajul "nu sunt date disponibile" */
.no-data {
    text-align: center;
    color: var(--text);
    padding: 20px;
    font-style: italic;
}
    </style>
        
    </head>
    <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>">
    
    
    
<div style="position: fixed; top: 4rem; left: 0; margin: 0; padding-left:1rem; padding-right:1rem;" class="main-content">
            <div style=" border-radius: 2rem; padding-right:2rem;" class="content">
                <div class="intro" style=" border-radius:2rem; background:<%out.println(sidebar);%>; color:<%out.println(text);%>; padding-right: 2rem;">
                    <div class="events"  style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>; padding-right: 2rem;" id="content">

       <h3 id="tableDate"></h3>
                        <table id="employeeTable">
                            <thead>
                                <tr style="color:<%out.println("white");%>">
                                     <th style="color:white">Nr.crt</th>
                    <th style="color:white">Nume</th>
                    <th style="color:white">Prenume</th>
                    <th style="color:white">Fct.</th>
                    <th style="color:white">Dep.</th>
                    <th style="color:white">Start</th>
                    <th style="color:white">Fine</th>
                    <th style="color:white">Motiv</th>
                    <th style="color:white">Loc</th>
                    <th style="color:white">Tip</th>
                    <th style="color:white">Adaug.</th>
                    <th style="color:white">Modif.</th>
                     <th style="color:white">Vzt.</th>
                    <th style="color:white">Status</th>
                    
                    </tr>

                            </thead>
                            <tbody id="tableBody" style="background:<%out.println(sidebar);%>; color:<%out.println(text);%>">
                                <!-- Se încarcă dinamic -->
                            </tbody>
                        </table>
                    </div>
                    
                    <button id="generate" onclick="sendJsonToPDFServer()">Descarcati PDF</button>
                   <button id="inapoi" ><a href ="viewang4.jsp">Inapoi</a></button>
                
                </div>
            </div>
        </div>
<script>
     // Funcții helper pentru status
 	function getStatusClass(status) {
 	    switch(status.toLowerCase()) {
 	        case 'neaprobat': return 'neaprobat';
 	        case 'aprobat sef': return 'aprobat-sef';
 	        case 'aprobat director': return 'aprobat-director';
 	        case 'dezaprobat director': return 'dezaprobat-director';
 	        case 'dezaprobat sef': return 'dezaprobat-sef';
 	        default: return 'neaprobat';
 	    }
 	}

 	function getStatusIcon(status) {
 	    switch(status.toLowerCase()) {
 	        case 'neaprobat': return 'ri-focus-line';
 	        case 'aprobat sef':
 	        case 'aprobat director': return 'ri-checkbox-circle-line';
 	        case 'dezaprobat sef':
 	        case 'dezaprobat director': return 'ri-close-line';
 	        default: return 'ri-focus-line';
 	    }
 	}
 	</script>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        try {
            const jsonStr = sessionStorage.getItem('tableData');
            console.log('Raw data from sessionStorage:', jsonStr);
            
            if (!jsonStr) {
                throw new Error('No data found in sessionStorage');
            }

            const parsedData = JSON.parse(jsonStr);
            console.log('Parsed data:', parsedData);

            // Setăm data și titlul
            document.getElementById('tableDate').textContent = parsedData.today || '';
            if (parsedData.header) {
                const h1 = document.createElement('h1');
                h1.textContent = parsedData.header;
                document.querySelector('.events').insertBefore(h1, document.getElementById('tableDate'));
            }

            // Verificăm dacă avem date
            if (!parsedData.data || parsedData.data.length === 0) {
                document.getElementById('tableBody').innerHTML = '<tr><td colspan="14" style="text-align: center;">Nu sunt date disponibile</td></tr>';
                return;
            }

            const tbody = document.getElementById('tableBody');
            tbody.innerHTML = '';
            
            parsedData.data.forEach((row, index) => {
                const tr = document.createElement('tr');
                
                // Adăugăm celulele normale
                [
                    row.NrCrt || (index + 1),
                    row.Nume || '',
                    row.Prenume || '',
                    row.Functie || '',
                    row.Departament || '',
                    row.Inceput || '',
                    row.Final || '',
                    row.Motiv || '',
                    row.Locatie || '',
                    row.Tip || '',
                    row.Adaugat || '',
                    row.Modificat || '',
                    row.Vazut || ''
                ].forEach(value => {
                    const td = document.createElement('td');
                    td.textContent = value;
                    tr.appendChild(td);
                });

                // Adăugăm celula de status special
                const statusTd = document.createElement('td');
                statusTd.className = 'tooltip';

                const tooltipSpan = document.createElement('span');
                tooltipSpan.className = 'tooltiptext';
                tooltipSpan.textContent = row.Status || 'Neaprobat';

                const statusSpan = document.createElement('span');
                statusSpan.className = 'status-icon status-' + getStatusClass(row.Status);

                const icon = document.createElement('i');
                icon.className = getStatusIcon(row.Status);

                statusSpan.appendChild(icon);
                statusTd.appendChild(tooltipSpan);
                statusTd.appendChild(statusSpan);
                tr.appendChild(statusTd);

                tbody.appendChild(tr);
            });

            // Curățăm sessionStorage după ce am folosit datele
            sessionStorage.removeItem('tableData');

        } catch (error) {
            console.error('Error:', error);
            document.getElementById('tableBody').innerHTML = 
                '<tr><td colspan="14" style="text-align: center;">Nu sunt date disponibile</td></tr>';
        }
    });
    </script>
</body>
</html>