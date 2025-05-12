

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%

//structura unei pagini este astfel
//verificare daca exista sesiune activa, utilizator conectat, 
//extragere date despre user, cum ar fi tipul, ca sa se stie ce pagina sa deschida, 
//se mai extrag temele de culoare ale fiecarui utilizator
//apoi se incarca pagina in sine

    HttpSession sesi = request.getSession(false); // aflu sa vad daca exista o sesiune activa
    if (sesi != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser"); // daca exista un utilizatoir in sesiune aka daca e cineva logat
        if (currentUser != null) {
            String username = currentUser.getUsername(); // extrag usernameul, care e unic si asta cam transmit in formuri (mai transmit si id dar deocmadata ma bazez pe username)
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance(); // driver bd
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student"); // conexiune bd
                PreparedStatement preparedStatement = connection.prepareStatement(
                		"SELECT DISTINCT u.*, t.denumire AS functie, d.nume_dep, t.ierarhie as ierarhie," +
                                "dp.denumire_completa AS denumire FROM useri u " +
                                "JOIN tipuri t ON u.tip = t.tip " +
                                "JOIN departament d ON u.id_dep = d.id_dep " +
                                "LEFT JOIN denumiri_pozitii dp ON t.tip = dp.tip_pozitie AND d.id_dep = dp.id_dep " +
                                "WHERE u.username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                	// extrag date despre userul curent
                    int id = rs.getInt("id");
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
                    	// aflu data curenta, tot ca o interogare bd =(
                    	String today = "";
                   	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                            String query = "SELECT DATE_FORMAT(NOW(), '%d/%m/%Y') as today";
                            try (PreparedStatement stmt = connection.prepareStatement(query)) {
                               try (ResultSet rs2 = stmt.executeQuery()) {
                                    if (rs2.next()) {
                                      today =  rs2.getString("today");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                            e.printStackTrace();
                        }
                   	 // acum aflu tematica de culoare ce variaza de la un utilizator la celalalt
                   	 String accent = "#10439F"; // mai intai le initializez cu cele implicite/de baza, asta in cazul in care sa zicem ca e o eroare la baza de date
                  	 String clr = "#d8d9e1";
                  	 String sidebar = "#ECEDFA";
                  	 String text = "#333";
                  	 String card = "#ECEDFA";
                  	 String hover = "#ECEDFA";
                  	 try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
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
                    } catch (SQLException e) {
                         out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                         e.printStackTrace();
                     }
                    	%>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Adaugare Adresa Angajat</title>
  <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
  <script src="https://js.arcgis.com/4.30/"></script>
  <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <meta charset="UTF-8">
    
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <script src="https://raw.githack.com/eKoopmans/html2pdf/master/dist/html2pdf.bundle.js"></script>
   
    <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <link rel="stylesheet" type="text/css" href="./responsive-login-form-main/assets/css/stylesheet.css">
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
		
    </style>
  <style>
    html, body, #viewDiv {
      padding: 0;
      margin: 0;
      height: 100%;
      width: 100%;
    }
    .form-container {
      position: absolute;
      top: 20px;
      left: 20px;
      z-index: 100;
      background-color: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
      font-family: Arial, sans-serif;
    }
    .form-container input {
      display: block;
      margin-bottom: 10px;
      padding: 8px;
      width: calc(100% - 16px);
    }
    .form-container button {
      background-color: #0079c1;
      color: white;
      border: none;
      padding: 10px;
      cursor: pointer;
      border-radius: 5px;
    }
    .form-container button:hover {
      background-color: #005a91;
    }
  </style>
</head>
<body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0;">
  <div id="viewDiv"></div>
  <div class="form-container" style="background:<%=sidebar%>; color:<%=clr%>; border-color: <%=clr%>">
    <h3 style="color: <%=accent%>">Adaugare adresa angajat</h3>
    <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Strada</label>
        <input id="street" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="street" placeholder="Introduceti strada..." required class="login__input">
    </div>
    <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Numarul</label>
        <input id="number" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="number" placeholder="Introduceti numarul strazii..." required class="login__input">
    </div>
     <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Localitatea</label>
        <input id="city" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="city" placeholder="Introduceti localitatea..." required class="login__input">
    </div>
    <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Judetul/Sectorul</label>
        <input id="sector" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="sector" placeholder="Introduceti judetul/sectorul..." required class="login__input">
    </div>
    <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Tara</label>
        <input id="country" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="country" placeholder="Introduceti tara..." required class="login__input">
    </div>
    <div>
        <label style=" color:<%out.println(text);%>" for="" class="login__label">Codul Postal</label>
        <input id="code" style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="code" placeholder="Introduceti codul postal..." required class="login__input">
    </div>
    
    <button style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" id="addAddress">Adaugare</button>
     <button style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"><a style="color: white;" href="modifdeldep.jsp">Inapoi</a></button>
    <p style=" color:<%out.println(text);%>" for="" class="login__label" id="addressOutput"></p>
    
  </div>
    <script>
        // Asteptam incarcarea completa a DOM-ului
        document.addEventListener('DOMContentLoaded', function() {
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/rest/locator"
            ], function(esriConfig, Map, MapView, Graphic, locator) {
                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurD3614hU6avg5dgfJ0cyyj8cQ8C7k3IZRB6OnACsZ-rE1hULGhayhxdt3-DyiUZ3lkaYmzyQjvRTgl0Slvk8SyBIO2Segk7bmnRewIolBDbBOfOUyy3Vfc6BPl6s6SRn91vphbzw_QQpZuh5u0J_PHemWhTB0TDSod-Z_xeL7jaImuSKEazyI5GU80sve_kEVwagPYkxvSqX11IqMKvs2Ww.AT1_koIv1OGN";

                const map = new Map({
                    basemap: "streets-vector"
                });

                const view = new MapView({
                    container: "viewDiv",
                    map: map
                });

                view.when(() => {
                    console.log("Harta s-a incarcat");
                    
                    if (navigator.geolocation) {
                    	navigator.geolocation.getCurrentPosition(
                    			  (pos) => {
                    			    const { latitude, longitude } = pos.coords;

                    			    // Corect => [longitude, latitude]
                    			    view.goTo({
                    			      center: [longitude, latitude],
                    			      zoom: 21
                    			    });

                    			    const point = {
                    			      type: "point",
                    			      longitude: longitude,
                    			      latitude: latitude
                    			    };

                    			    const marker = new Graphic({
                    			      geometry: point,
                    			      symbol: {
                    			        type: "simple-marker",
                    			        color: "red",
                    			        size: "12px"
                    			      }
                    			    });

                    			    view.graphics.removeAll();
                    			    view.graphics.add(marker);
                    			  },
                    			  (err) => {
                    			    console.error("Eroare la geolocație:", err);
                    			  }
                    			);

                    }
                });

                // Handler pentru adaugare adresa
                document.getElementById("addAddress").addEventListener("click", async function() {
                    const street = document.getElementById("street").value;
                    const number = document.getElementById("number").value;
                    const code = document.getElementById("code").value;
                    const sector = document.getElementById("sector").value;
                    const city = document.getElementById("city").value;
                    const country = document.getElementById("country").value;

                    const address = `${street} ${number}, ${city}, ${sector}, ${country}`;
                    const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";

                    try {
                        const params = {
                            address: {
                                "address": address,
                                "postal": code,
                                "countryCode": "RO"
                            },
                            outFields: ["*"],
                            maxLocations: 1
                        };
const cv =  new URLSearchParams(window.location.search).get("id");
                        const results = await locator.addressToLocations(locatorUrl, params);

                        if (results.length > 0) {
                            const location = results[0].location;
                            view.graphics.removeAll();

                            const marker = new Graphic({
                                geometry: {
                                    type: "point",
                                    longitude: location.longitude,
                                    latitude: location.latitude
                                },
                                symbol: {
                                    type: "simple-marker",
                                    color: [0, 0, 255],
                                    size: "12px",
                                    outline: {
                                        color: [255, 255, 255],
                                        width: 2
                                    }
                                }
                            });

                            view.graphics.add(marker);
                            view.goTo({
                                target: marker.geometry,
                                zoom: 21
                            });

                            const requestBody = {
                                idDep: cv,
                                strada: street,
                                nr: number,
                                cod: code,
                                judet: sector,
                                oras: city,
                                tara: country,
                                latitudine: location.latitude,
                                longitudine: location.longitude
                            };

                            const response = await fetch("/Proiect/ServletUpdateAddressDep", {
                                method: "POST",
                                headers: {
                                    "Content-Type": "application/json"
                                },
                                body: JSON.stringify(requestBody)
                            });

                            if (response.ok) {
                                document.getElementById("addressOutput").textContent = 
                                    `Adresa a fost salvata cu succes!`;
                            } else {
                                throw new Error("Eroare la salvarea adresei");
                            }
                        } else {
                            document.getElementById("addressOutput").textContent = 
                                "Nu s-a gasit adresa introdusa";
                        }
                    } catch (error) {
                        console.error("Eroare:", error);
                        document.getElementById("addressOutput").textContent = 
                            "Eroare: " + error.message;
                    }
                });
            });
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
