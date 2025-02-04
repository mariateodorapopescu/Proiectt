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
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Adaugare Adresa</title>
  <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
  <script src="https://js.arcgis.com/4.30/"></script>
  <!-- CSS -->
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/pikaday/css/pikaday.css">
   
    <!-- JavaScript -->
  <script src="https://js.arcgis.com/4.30/"></script>
    <script src="https://cdn.jsdelivr.net/npm/pikaday/pikaday.js"></script>
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>

    <style>
      

.container {
    padding-top: 120px; /* Adjust as needed */
     
}
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
    <p style=" color:<%out.println(text);%>" for="" class="login__label" id="addressOutput"></p>
    <p style=" color:<%out.println(text);%>" for="" class="login__label" id="locationOutput"></p>
  </div>
  <script>
    document.addEventListener('DOMContentLoaded', function () {
      require([
        "esri/config",
        "esri/Map",
        "esri/views/MapView",
        "esri/Graphic",
        "esri/rest/locator"
      ], function (esriConfig, Map, MapView, Graphic, locator) {
        esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurD3614hU6avg5dgfJ0cyyj8cQ8C7k3IZRB6OnACsZ-rE1hULGhayhxdt3-DyiUZ3lkaYmzyQjvRTgl0Slvk8SyBIO2Segk7bmnRewIolBDbBOfOUyy3Vfc6BPl6s6SRn91vphbzw_QQpZuh5u0J_PHemWhTB0TDSod-Z_xeL7jaImuSKEazyI5GU80sve_kEVwagPYkxvSqX11IqMKvs2Ww.AT1_koIv1OGN";

        const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";

        const map = new Map({
          basemap: "arcgis/topographic"
        });

        const view = new MapView({
          container: "viewDiv",
          map: map,
          center: [26.1025, 44.4268], // Bucharest coordinates
          zoom: 11
        });

        let currentLocation = null;

        navigator.geolocation.getCurrentPosition(
          function (position) {
            const { latitude, longitude } = position.coords;
            currentLocation = { latitude, longitude };
            view.center = [longitude, latitude];
            view.zoom = 14;

            const userLocation = new Graphic({
              geometry: {
                type: "point",
                longitude: longitude,
                latitude: latitude,
               
	              strada: street,
	              oras: city,
	              judet: sector,
	              cod: code,
	              nr: number,
	              tara: country,
	             
              },
              symbol: {
                type: "simple-marker",
                color: "red",
                size: "10px",
                outline: {
                  color: "white",
                  width: 1
                }
              }
            });

            view.graphics.add(userLocation);
            document.getElementById("locationOutput").textContent = 
              `Locatia curenta: Latitudine ${latitude.toFixed(6)}, Longitudine ${longitude.toFixed(6)}`;
          },
          function (error) {
            console.error("Eroare la detectarea locatiei utilizatorului:", error);
            document.getElementById("locationOutput").textContent = "Eroare la detectarea locatiei.";
          }
        );

        document.getElementById("addAddress").addEventListener("click", async function () {
          const street = document.getElementById("street").value;
          const number = document.getElementById("number").value;
          const code = document.getElementById("code").value;
          const sector = document.getElementById("sector").value;
          const city = document.getElementById("city").value;
          const country = document.getElementById("country").value;

          const address = `${street} ${number}, ${code} ${sector ? "Sector " + sector + ", " : ""}${city}, ${country}`;
          const userId = new URLSearchParams(window.location.search).get("id");

          if (!userId) {
            document.getElementById("addressOutput").textContent = "ID-ul utilizatorului este lipsa!";
            return;
          }

          document.getElementById("addressOutput").textContent = `Adresa formata: ${address}`;

          try {
            const params = {
              address: {
                "address": address
              },
              outFields: ["*"]
            };

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
                  color: "blue",
                  size: "10px",
                  outline: {
                    color: "white",
                    width: 1
                  }
                }
              });

              view.graphics.add(marker);
              view.center = [location.longitude, location.latitude];
              view.zoom = 14;

              const requestBody = {
                userId: userId,
                strada: street,
                nr: number,
                cod: code,
                judet: sector,
                oras: city,
                tara: country,
                latitudine: location.latitude,
                longitudine: location.longitude
              };

              const response = await fetch("locatiee", {
                method: "POST",
                headers: {
                  "Content-Type": "application/json"
                },
                body: JSON.stringify(requestBody)
              });

              if (response.ok) {
                document.getElementById("addressOutput").textContent = 
                  `Adresa a fost salvata cu succes pentru utilizatorul cu ID-ul ${userId}.`;
              } else {
                throw new Error("Eroare la actualizarea adresei in baza de date.");
              }
            } else {
              document.getElementById("locationOutput").textContent = "Adresa nu a fost gasita.";
            }
          } catch (error) {
            console.error("Eroare:", error);
            document.getElementById("locationOutput").textContent = 
              "Eroare la procesarea adresei: " + error.message;
          }
        });
      });
    });
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
