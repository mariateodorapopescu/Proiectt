<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="stylesheet.css">
    <title>Acasa</title>
    <style>
        iframe {
            width: 100%;
            border: none;
            transition: height 0.5s ease;
            overflow: hidden; /* Hide scrollbars */
            overflow-y: hidden; /* Hide vertical scrollbar */
            /* Hide scrollbar for Chrome, Safari and Opera */
             -ms-overflow-style: none;  /* IE and Edge */
  scrollbar-width: none;  /* Firefox */
height: 90%;
border-radius: 2em;
        }
        iframe::-webkit-scrollbar {
  display: none;
}
        
    </style>
</head>
<body>
<%
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
                    if (rs.getString("tip").compareTo("1") != 0) {
                        if (rs.getString("tip").compareTo("0") == 0) {
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
                    	%>
                    	
                    	<div class="sidebar">
        <ul>
            <li class="logo" style="--bg: #333;">
                <a href="#">
                    <div class="siicon">
                        <ion-icon name="airplane"></ion-icon>
                    </div>
                    <div class="sitext">Concedii</div>
                </a>
            </li>
            <div class="menuToggle"></div>
            <div class="menulist">
                <li style="--bg: #3F48CC;;"  class="active">
                     <a href="homedir.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="home"></ion-icon>
                        </div>
                        <div class="sitextt">Acasa</div>
                    </a>
                </li>
               
                <li style="--bg: #3F48CC;;">
                     <a href="concediinoidir.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="today"></ion-icon>
                        </div>
                        <div class="sitextt">Notificari</div>
                    </a>
                </li>
                <li style="--bg: #3F48CC;">
                     <a href="vizualizareconcedii.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="stats"></ion-icon>
                        </div>
                        <div class="sitextt">Statistici</div>
                    </a>
                </li>
                
                <li style="--bg: #3F48CC;;">
                    <a href="actiuni.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <ion-icon name="apps"></ion-icon>
                        </div>
                        <div class="sitextt">Actiuni</div>
                    </a>
                </li>
                
                <li style="--bg: #3F48CC;;">
                    <a href="#">
                        <div class="siiconn">
                            <ion-icon name="switch"></ion-icon>
                        </div>
                        <div class="sitextt">Configurari</div>
                    </a>
                </li>
            </div>
            
            <div class="sibottom">
                <li style="--bg:#333;">
                    <a href="despr.jsp" class="load-content" target="iframe">
                        <div class="siiconn">
                            <div class="imgbx">
                                <img src="https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png">
                            </div>
                        </div>
                        <div class="sitextt"> <% out.println(nume);%></div>
                    </a>
                </li>
                <li style="--bg: #333;">
                   <a href="logout">
                        <div class="siiconn">
                            <ion-icon name="share-alt"></ion-icon>
                        </div>
                        
                        
                        <div class="sitextt">Deconectare</div>
                    </a>
                </li>
                
            </div>
        </ul>
    </div>
    <div class="main-content">
        <iframe name="iframe" id='iframe' src="homedir.jsp"></iframe>
    </div>
    <script src="main.js"></script>
    <script src="https://unpkg.com/ionicons@4.5.10-0/dist/ionicons.js"></script>
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
                iframe.style.height = iframeDocument.documentElement.scrollHeight + 'px';
            };
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
