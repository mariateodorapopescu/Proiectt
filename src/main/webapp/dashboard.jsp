<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
//fisier per tabela (schmea, insert)
	// cum se salveaza o bd
	// !! clean code!
    // interogare de baza
    // primire/cerere adeverinta, incarcare acte, adeverinte
    // cv/date personale
    // salarii + fluturas
    // hosting: infr comp -> domeniu (=local) sau se poate face prin servicii cloud prn furnizori (public, privat, hibrid, local, remote)
    HttpSession sesi = request.getSession(false);

    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");

        if (currentUser != null) {
            String username = currentUser.getUsername();
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
                 PreparedStatement preparedStatement = connection.prepareStatement("select tip, prenume, id from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (!rs.next()) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
                } else {
                    if (rs.getString("tip").compareTo("0") != 0) {
                        if (rs.getString("tip").compareTo("1") == 0) {
                            response.sendRedirect("tip1ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("2") == 0) {
                            response.sendRedirect("tip2ok.jsp");
                        }
                        if (rs.getString("tip").compareTo("3") == 0) {
                            response.sendRedirect("sefok.jsp");
                        }
                        if (rs.getString("tip").compareTo("4") == 0) {
                            response.sendRedirect("adminok.jsp");
                        }
                    } else {
                    	int id = rs.getInt("id");
                    	String nume = rs.getString("prenume");
                    	 int cate = -1;
                    	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
                             String query = "SELECT COUNT(*) AS count FROM concedii WHERE start_c + 3 <= CURDATE() AND id_ang = ?";
                             try (PreparedStatement stmt = connection.prepareStatement(query)) {
                                 stmt.setInt(1, id);
                                 try (ResultSet rs2 = stmt.executeQuery()) {
                                     if (rs2.next() && rs2.getInt("count") > 0) {
                                        cate =  rs2.getInt("count");
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
                    	 String accent = null;
                      	 String clr = null;
                      	 String sidebar = null;
                      	 String text = null;
                      	 String card = null;
                      	 String hover = null;
                      	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                             // Check for upcoming leaves in 3 days
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
                             
                            
                             // Display the user dashboard or related information
                             //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                             // Add additional user-specific content here
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
    
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
    <title>Concedii</title>
    <style>
     iframe {
    width: 100%;
    height: 100vh; /* Ajustează înălțimea pentru a se potrivi cu viewport-ul */
    overflow: hidden; /* Ascunde scroll bar-urile */
    border: none;
    border-radius: 2em;
    transition: height 0.5s ease;
}

		iframe::-webkit-scrollbar {
		    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}

::-webkit-scrollbar {
		    display: none; /* Ascunde scrollbar pentru Chrome, Safari și Opera */
		}
		
        @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
		
		* {
		    margin: 0;
		    padding: 0;
		    box-sizing: border-box;
		    font-family: 'Poppins', sans-serif;
		}
		
		body {
		    min-height: 100vh;
		    background: var(--clr);
		    display: flex;
		}
		
		.sidebar {
		    width: 4rem;
		    background: var(--sd);
		    transition: 0.5s;
		    padding-left: 1rem;
		    overflow: hidden;
		    border-radius: 1rem;
		    display: flex;
		    flex-direction: column;
		    justify-content: space-between;
		    position: relative;
		    color: <%=text%>;
		}
		
		.sidebar.active {
		    width: 20rem;
		}
		
		.sidebar ul {
		    flex-grow: 1;
		    color: <%=text%>;
		}
		
		.sidebar ul li {
		    list-style: none;
		    position: relative;
		    color: <%=text%>;
		}
		
		.sidebar ul li.active {
		    background: var(--clr);
		    border-top-left-radius: 1.5rem;
		    border-bottom-left-radius: 1.5rem;
		    color: <%=text%>;
		}
		
		.sidebar ul li.active::before{
		    content: '';
		    position: absolute;
		    background: transparent;
		    width: 1rem;
		    height: 2rem;
		    border-bottom-right-radius: 2rem;
		    top: -1.93rem;
		    right: 0;
		    box-shadow: 1rem 1rem 0 1rem var(--clr);
		    color: <%=text%>;
		}
		
		.sidebar ul li.active::after {
		    content: '';
		    position: absolute;
		    background: transparent;
		    width: 1rem;
		    height: 2rem;
		    border-top-right-radius: 2rem;
		    top: -1.93rem;
		    right: 0;
		    box-shadow: 1rem -1rem 0 1rem var(--clr);
		    z-index: 20;
		    color: <%=text%>;
		}
		
		.sidebar ul li.active::after {
		    bottom: -1.93rem;
		    right: 0;
		    box-shadow: 1rem -1rem 0 1rem var(--sd);
		    z-index: 20;
		    color: <%=text%>;
		}
		
		.sidebar ul li.logo {
		    margin-bottom: 4rem;
		}
		
		.sidebar ul li.logo a .siicon {
		    font-size: 2em;
		    color: var(--clr);
		    display: flex;
		    justify-content: center;
		    align-items: center;
		    min-width: 2rem;
		    height: 3rem;
		    font-size: 1.5em;
		    color: var(--text);
		    transition: 0.5s;
		    padding-left: 0.3rem;
		}
		
		.sidebar ul li.logo a .sitext {
		    font-size: 1.2em;
		    font-weight: 500;
		   
		    display: flex;
		    align-items: center;
		    font-size: 1em;
		    
		    padding-left: 1.5rem;
		    letter-spacing: 0.05em;
		    transition: 0.5s;
		    color: <%=text%>;
		}
		
		.sidebar ul li a,
		.sidebar ul li .logo a {
		    display: flex;
		    white-space: nowrap;
		    text-decoration: none;
		     color: <%=text%>;
		}
		
		.sidebar ul li a .siiconn {
		    display: flex;
		    justify-content: center;
		    align-items: center;
		    min-width: 2rem;
		    height: 3rem;
		    font-size: 1.5em;
		     color: <%=text%>;
		    transition: 0.5s;
		    z-index: 22;
		}
		
		.sidebar ul li.active a .siiconn {
		    color: #fff;
		    padding-left: 0.7rem;
		}
		
		.sidebar ul li.active a .sitextt {
		    margin-left: 1rem;
		     color: <%=text%>;
		}
		
		.sidebar ul li.active a .siiconn::before {
		    content: '';
		    position: absolute;
		    background: var(--bg);
		    inset: 0.2rem;
		    width: 2.7rem;
		    border-radius: 50%;
		    transition: 0.5s;
		}
		
		.sidebar ul li.active:hover a .siiconn::before {
		    background: #fff;
		}
		
		.sidebar ul li.active a .sitextt {
		    color: var(--active-bg);
		    padding-left: 0.5rem;
		}
		
		.sidebar ul li:hover a .sitextt,
		.sidebar ul li:hover a .siiconn {
		    color: var(--bg);
		}
		
		.sidebar ul li a .sitextt {
		    height: 3rem;
		    display: flex;
		    align-items: center;
		    font-size: 1em;
		    color: #333;
		    padding-left: 1.5rem;
		    text-transform: uppercase;
		    letter-spacing: 0.08em;
		    transition: 0.5s;
		    font-weight: 80;
		}
		
		.sidebar ul li:hover a .siiconn,
		.sidebar ul li:hover a .sitextt {
		    color: var(--bg);
		}
		
		.sibottom {
		    width: 100%;
		}
		
		.sidebar ul li.sibottom a .sitextt {
		    display: none;
		}
		
		.sidebar.active ul li.sibottom a .sitextt {
		    display: inline;
		}
		
		.imgbx {
		    width: 2rem;
		    height: 2rem;
		    border-radius: 50%;
		    overflow: hidden;
		}
		
		.imgbx img {
		    width: 100%;
		    height: 100%;
		    object-fit: cover;
		}
		
		.menuToggle {
		    /* position: absolute; */
		    left: 0%;
		    top: 10%;
		    width: 30px;
		    height: 30px;
		    background-color: var(--bg);
		    z-index: 80;
		    cursor: pointer;
		    border-radius: 0.5rem;
		    justify-content: center;
		    align-items: center;
		}
		
		.dark-mode .menuToggle {
		    background-color:  var(--text);
		}
		
		.menuToggle::before {
		    content: '';
		    position: absolute;
		    width: 20px;
		    height: 1.5px;
		    background: var(--text);
		    transform: translate(5px, 7px);
		    transition: 0.5s;
		    box-shadow: 0 8px 0 var(--text);
		}
		
		.menuToggle.active::before {
		    transform: translate(5px, 15px) rotate(45deg);
		    box-shadow: 0 0 0 var(--text);
		}
		
		.menuToggle.active::after {
		    transform: translate(5px, 15px) rotate(-45deg);
		}
		
		.menuToggle::after {
		    content: '';
		    position: absolute;
		    width: 20px;
		    height: 1.5px;
		    background:  var(--text);
		    transform: translate(5px, 23px);
		    transition: 0.5s;
		}
		
		.main-content {
		    flex-grow: 1;
		    padding: 20px;
		    position: relative;
		    overflow-y: hidden;
		}
		
		.header {
		    display: flex;
		    justify-content: space-between;
		    align-items: center;
		    margin-bottom: 20px;
		}
		
		.header h1 {
		    margin: 0;
		}
		
		.search-bar {
		    display: flex;
		    align-items: center;
		}
		
		.search-bar input {
		    padding: 10px;
		    border-radius: 5px;
		    border: none;
		    margin-right: 10px;
		}
		
		.search-bar button {
		    padding: 10px 20px;
		    border: none;
		    border-radius: 5px;
		    background-color: var(--bg);
		    color: #eaeaea;
		    cursor: pointer;
		}
		
		.search-bar button:hover {
		    background-color: black;
		}
		
		.content {
		    display: flex;
		    flex-direction: column;
		     background: var(--sd);
		      overflow-y: hidden;
		}
		
		.intro {
		    background: var(--sd);
		    padding: 20px;
		    border-radius: 10px;
		    margin-bottom: 20px;
		   
		}
		
		.chart {
		    background: var(--sd);
		    padding: 20px;
		    border-radius: 10px;
		    margin-bottom: 20px;
		   
		}
		
		.events {
		    background: var(--sd);
		    padding: 20px;
		    border-radius: 10px;
		    margin-bottom: 20px;
		   
		}
		.intro h2 {
		    margin-top: 0;
		    color: var(--text);
		}
		
		.intro button {
		    padding: 10px 20px;
		    border: none;
		    border-radius: 5px;
		    background-color: var(--bg);
		    color: white;
		    cursor: pointer;
		}
		
		.intro button:hover {
		    background-color: black;
		}
		
		.chart h3 {
		    margin-top: 0;
		}
		
		.chart canvas {
		    width: 100%;
		    height: 200px;
		    background-color: var(--bg);
		}
		
		.timeframe button {
		    padding: 10px;
		    border: none;
		    border-radius: 5px;
		    background-color: var(--sd);
		    color: var(--text);
		    cursor: pointer;
		    margin-right: 10px;
		}
		
		.timeframe button:hover {
		    background-color: black;
		    color: white;
		}
		
		.events table {
		    width: 100%;
		    border-collapse: collapse;
		}
		
		.events th,
		.events td {
		    padding: 10px;
		    text-align: left;
		    border-bottom: 1px solid var(--bg);
		}
		
		.events th {
		    background-color: var(--bg);
		    color: var(--text);
		}
		
		.toggle-buttons {
		    display: flex;
		    justify-content: flex-end;
		    margin-top: 10px;
		}
		
		.toggle-buttons button {
		    padding: 10px 20px;
		    border: none;
		    border-radius: 5px;
		    background-color: var(--bg);
		    color: white;
		    cursor: pointer;
		    margin-left: 10px;
		}
		
		.toggle-buttons button:hover {
		    background-color: black;
		}
		.menu {
			display: flex;
			 flex-direction: row;
		     flex-wrap: wrap;
		     justify-content: space-evenly;
		     position: absolute;
		     top: 0;
		     left: 0;
		     width: 100%;
		     height: 100%;
		     padding: 10%;
			
		}
		.menu button {
		    padding: 10px 20px;
		    border: none;
		    border-radius: 5px;
		    background-color: var(--bg);
		    color: var(--text);
		    cursor: pointer;
		    border-color: rgba(0,0,0,0);
		    width: 20%;
		    height: 20%;
		}
		
		.menu button:hover {
		    background-color: black;
		}
		.sidebar ul li a .sitextt {
		    color: <%=text%>;  
		}
		.content{
		    overflow-y: hidden; /* Permite scroll-ul orizontal */
		    width: 100%; /* Asigură că folosește întreaga lățime disponibilă */
		    height: 100%;
		}
		.main-content {
		    overflow: auto; /* Permite scroll-ul orizontal */
		    width: 100%; /* Asigură că folosește întreaga lățime disponibilă */
		    height: 100%;
		}
		iframe {
		    height: 100%;  /* sau o valoare specifică suficient de mare */
		    overflow: hidden;
		}
		
		

    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

                    	
                    	<div class="sidebar" style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>">
        <ul>
            <li class="logo" style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>">
                <a href="#">
                    <div class="siicon" style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>">
                        <ion-icon name="airplane"></ion-icon>
                    </div>
                    <div style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>" class="sitext">Concedii</div>
                </a>
            </li>
            <div style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>" class="menuToggle"></div>
            <div style="background:<%out.println(sidebar); %>; color: <%out.println(text); %>" class="menulist">
                <li style="--bg:<%out.println(accent); %> " class='active'>
                     <a style=" color: <%out.println(text); %>" href="homedir.jsp" class="load-content" target="iframe">
                        <div class="siiconn" >
                            <ion-icon name="home"></ion-icon>
                        </div>
                        <div  class="sitextt">Acasa</div>
                    </a>
                </li>
                <li style="--bg: <%out.println(accent); %>">
                    <a href="viewang.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="people"></ion-icon>
                        </div>
                        <div  class="sitextt">Angajati</div>
                    </a>
                </li>
                <li style="--bg: <%out.println(accent); %>">
                     <a href="concediinoisef.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="today"></ion-icon>
                        </div>
                        <div  class="sitextt">Notificari</div>
                    </a>
                </li>
                <li style="--bg: <%out.println(accent); %>">
                     <a href="vizualizareconcedii.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="stats"></ion-icon>
                        </div>
                        <div  class="sitextt">Rapoarte</div>
                    </a>
                </li>
                
                <li style="--bg: <%out.println(accent); %>;">
                    <a href="actiuni.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="apps"></ion-icon>
                        </div>
                        <div  class="sitextt">Actiuni</div>
                    </a>
                </li>
                        <li style="--bg: <%out.println(accent); %>;">
                    <a href="actiuni_harti.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="globe"></ion-icon>
                        </div>
                        <div  class="sitextt">Harti</div>
                    </a>
                </li>
                 
                <li style="--bg: <%out.println(accent); %>">
                    <a href="viewdep.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="briefcase"></ion-icon>
                        </div>
                        <div  class="sitextt">Departamente</div>
                    </a>
                </li>
                <li style="--bg: <%out.println(accent); %>;">
                     <a href="setari.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="switch"></ion-icon>
                        </div>
                        <div  class="sitextt">Configurari</div>
                    </a>
                </li>
            </div>
            
            <div class="sibottom">
                <li style="--bg:<%out.println(text); %>;">
                    <a href="despr.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <div class="imgbx">
                                <img src="${pageContext.request.contextPath}/ImageServlet" alt="Profile Image" />
                            </div>
                        </div>
                        <div  class="sitextt"> <% out.println(nume);%></div>
                    </a>
                </li>
                <li style="--bg: <%out.println(text); %>;">
                   <a href="logout">
                        <div class="siiconn">
                            <ion-icon name="share-alt"></ion-icon>
                        </div>
                        
                        
                        <div id="logout_btn" class="sitextt">Deconectare</div>
                    </a>
                </li>
                
            </div>
        </ul>
    </div>
    <div style="margin: 0; padding: 0; " class="main-content">
        <iframe style="overflow: hidden;" name="iframe" id='iframe' src="homedir.jsp"></iframe>
    </div>
    <script src="./responsive-login-form-main/assets/js/index.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>
   <script>
let fullToken = '<%= session.getAttribute("token") %>'; // Assuming 'token' is stored as a session attribute
if (fullToken.startsWith("Bearer ")) {
    let token = fullToken.substring(7); // Correct the substring index to skip "Bearer "
    localStorage.setItem('jwtToken', token);
}
</script>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const iframe = document.getElementById('iframe');
            const links = document.querySelectorAll('.load-content');
            
            
            links.forEach(link => {
                link.addEventListener('click', function(event) {
                    event.preventDefault();
                    iframe.src = this.href;
                });
            });

            iframe.onload = function() {
                const iframeDocument = iframe.contentDocument || iframe.contentWindow.document;
                iframe.style.height = iframeDocument.documentElement.scrollHeight * 1.07 + 'px';
            };
        });
    </script>
    <script>
// Ascultă pentru evenimentul 'load' al iframe-ului
window.addEventListener('load', function() {
    var iframe = document.getElementById('iframe');
    // document.querySelectorAll("li.active")[0].classList.remove('active');
    // Salvăm URL-ul curent la fiecare încărcare a iframe-ului
    iframe.addEventListener('load', function() {
        // localStorage.setItem('lastIframeSrc', iframe.src);
        var active = document.querySelectorAll('li.active')[0];
    });
});
</script>
    <script>
window.addEventListener('DOMContentLoaded', (event) => {
    var iframe = document.getElementById('iframe');
    // var lastSrc = localStorage.getItem('lastIframeSrc');
    var active = localStorage.getItem('active');
    // Setăm sursa iframe-ului la ultima sursă salvată, dacă există
    if (lastSrc) {
       //  iframe.src = lastSrc;
        active.classList.add('active');
    }
});
document.getElementById('logout_btn').addEventListener('click', (event) => {
    localStorage.removeItem('jwtToken');
    <% // session.removeAttribute("token"); %>
    console.log('Deconectare cu succes!');
  });

</script>
                       <%
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
