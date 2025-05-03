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
                    int userDep = rs.getInt("id_dep");
                    int ierarhie = rs.getInt("ierarhie");
                    String functie = rs.getString("functie");
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
                             // Check for upcoming leaves in 3 days
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
                             // Display the user dashboard or related information
                             //out.println("<div>Welcome, " + currentUser.getPrenume() + "</div>");
                             // Add additional user-specific content here
                         } catch (SQLException e) {
                             out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                             e.printStackTrace();
                         }
                      
                      	 %> 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Harta Concedii</title>
    <link rel="stylesheet" href="https://js.arcgis.com/4.30/esri/themes/light/main.css">
    <script src="https://js.arcgis.com/4.30/"></script>
    <style>
      @import url('https://fonts.googleapis.com/css?family=Poppins:200,300,400,500,600,700,800,900&display=swap');
		
        html, body, #viewDiv {
            padding: 0;
            margin: 0;
            height: 100%;
            width: 100%;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar {
            position: absolute;
            top: 80px;
            left: 20px;
            z-index: 100;
            background-color: <%= sidebar%>;
            padding: 15px;
            border-radius: 8px;
          
            color: <%=text%>;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar select,
        .sidebar button {
            display: block;
            margin-bottom: 10px;
            padding: 10px;
            width: 100%;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar select:hover, .sidebar select:active, .sidebar select:selected, .sidebar select:visited {
         background-color: <%= accent%>;
            color: white;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar button {
            background-color: <%= accent%>;
            color: white;
            cursor: pointer;
            font-family: 'Poppins', sans-serif;
        }
        .sidebar button:hover  {
            background-color: black;
            font-family: 'Poppins', sans-serif;
        }
        .custom-popup {
            background-color: <%= sidebar%>;
            padding: 10px;
            border-radius: 5px;
            font-family: 'Poppins', sans-serif;
           
        }
        .sidebar label {
            display: block;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div id="viewDiv"></div>
    <div class="sidebar">
        <% if (userType == 3 || userType == 0 || (userType >= 12 && userType <= 19)) { %>
            <label for="departmentSelect">Departament</label>
            <select id="departmentSelect">
                <% if (userType == 0 || (userType >= 12 && userType <= 19)) { %>
                    <option value="">Toate departamentele</option>
                <% } %>
                <%
                    // Load departments based on user type
                    try (Connection deptConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                        String deptQuery;
                        PreparedStatement deptStmt;
                        
                        if (userType == 3) { // Sef - only their department
                            deptQuery = "SELECT id_dep, nume_dep FROM departament WHERE id_dep = ?";
                            deptStmt = deptConn.prepareStatement(deptQuery);
                            deptStmt.setInt(1, userDep);
                        } else { // Director - all departments
                            deptQuery = "SELECT id_dep, nume_dep FROM departament";
                            deptStmt = deptConn.prepareStatement(deptQuery);
                        }
                        
                        ResultSet deptRs = deptStmt.executeQuery();
                        while (deptRs.next()) {
                            int deptId = deptRs.getInt("id_dep");
                            String deptName = deptRs.getString("nume_dep");
                            %>
                            <option value="<%= deptId %>" <%= (userType == 3 && deptId == userDep) ? "selected" : "" %>><%= deptName %></option>
                            <%
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                %>
            </select>
            
            <label for="employeeSelect">Angajat</label>
            <select id="employeeSelect">
                <option value="">Toți angajații</option>
            </select>
            
            <label for="statusSelect">Status</label>
            <select id="statusSelect">
                <option value="">Toate statusurile</option>
                <option value="2">Aprobat director</option>
                <option value="1">Aprobat șef</option>
                <option value="0">Neaprobat</option>
                <option value="-1">Dezaprobat șef</option>
                <option value="-2">Dezaprobat director</option>
            </select>
        <% } %>
        
        <button style="
display: block; margin-bottom: 10px; padding: 10px; width: 100%; border: none; font-size: 14px;
         box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>" class="login__button" id="showMyLocations">Concediile mele</button>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            require([
                "esri/config",
                "esri/Map",
                "esri/views/MapView",
                "esri/Graphic",
                "esri/layers/GraphicsLayer",
                "esri/rest/locator",
                "esri/layers/FeatureLayer",
                "esri/geometry/Point",
                "esri/rest/route",
                "esri/rest/support/RouteParameters",
                "esri/rest/support/FeatureSet",
                "esri/PopupTemplate",
                "esri/symbols/Font"
            ], function (esriConfig, Map, MapView, Graphic, GraphicsLayer, locator, FeatureLayer, Point, route, RouteParameters, FeatureSet, PopupTemplate) {

                esriConfig.apiKey = "AAPTxy8BH1VEsoebNVZXo8HurNNdtZiU82xWUzYLPb7EktsQl_JcOdzgsJtZDephAvIhplMB4PQTWSaU4tGgQhsL4u6bAO6Hp_pE8hzL0Ko7jbY9o98fU61l_j7VXlLRDf08Y0PheuGHZtJdT4bJcAKLrP5dqPCFsZesVv-S7BH1OaZnV-_IsKRdxJdxZI3RVw7XGZ0xvERxTi57udW9oIg3VzF-oY1Oy4ybqDshlMgejQI.AT1_a5lV7G2k";

                const map = new Map({
                    basemap: "arcgis/topographic"
                });

                const view = new MapView({
                    container: "viewDiv",
                    map: map,
                    center: [25, 45],
                    zoom: 6
                });

                const graphicsLayer = new GraphicsLayer();
                map.add(graphicsLayer);

                const routeLayer = new GraphicsLayer();
                map.add(routeLayer);

                const vacationLayer = new GraphicsLayer();
                map.add(vacationLayer);

                const locatorUrl = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer";
                const routeUrl = "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World";

                let currentLocation = null;
                const userType = <%= userType %>;
                const userId = <%= userId %>;
                const userDep = <%= userDep %>;

                // Load employees based on department selection
                function loadEmployees(departmentId) {
                    const employeeSelect = document.getElementById("employeeSelect");
                    employeeSelect.innerHTML = "<option value=''>Toți angajații</option>";
                    
                    if (!departmentId) return;
                    
                    fetch("get_employees.jsp?deptId=" + departmentId)
                        .then(response => response.json())
                        .then(employees => {
                            employees.forEach(emp => {
                                const option = document.createElement("option");
                                option.value = emp.id;
                                option.textContent = emp.nume + " " + emp.prenume;
                                employeeSelect.appendChild(option);
                            });
                        })
                        .catch(error => console.error("Error loading employees:", error));
                }

                // Event listener for department select
                const departmentSelect = document.getElementById("departmentSelect");
                if (departmentSelect) {
                    departmentSelect.addEventListener("change", function() {
                        loadEmployees(this.value);
                        loadVacationPoints(this.value, document.getElementById("employeeSelect").value, document.getElementById("statusSelect").value);
                    });
                    
                    // Load initial employees for sef
                    <% if (userType == 3) { %>
                    loadEmployees(userDep);
                    <% } %>
                }

                // Event listener for employee select
                const employeeSelect = document.getElementById("employeeSelect");
                if (employeeSelect) {
                    employeeSelect.addEventListener("change", function() {
                        loadVacationPoints(departmentSelect.value, this.value, document.getElementById("statusSelect").value);
                    });
                }

                // Event listener for status select
                const statusSelect = document.getElementById("statusSelect");
                if (statusSelect) {
                    statusSelect.addEventListener("change", function() {
                        loadVacationPoints(departmentSelect.value, employeeSelect.value, this.value);
                    });
                }

                // Load vacation points based on user type and selection
                function loadVacationPoints(departmentId = null, employeeId = null, statusId = null) {
                    let url = "GetVacationDetailsServlet?userType=" + userType + "&userId=" + userId + "&userDep=" + userDep;
                    
                    if (departmentId) {
                        url += "&deptId=" + departmentId;
                    }
                    if (employeeId) {
                        url += "&empId=" + employeeId;
                    }
                    if (statusId) {
                        url += "&statusId=" + statusId;
                    }

                    fetch(url)
                        .then(response => response.json())
                        .then(vacations => {
                            console.log("Date primite:", vacations);
                            vacationLayer.removeAll();
                            
                            if (!Array.isArray(vacations)) {
                                console.error("Datele primite nu sunt un array:", vacations);
                                return;
                            }
                            
                            if (vacations.length === 0) {
                                console.log("Nu există concedii disponibile.");
                                return;
                            }
                            
                            vacations.forEach(vacation => {
                                if (!vacation) {
                                    console.log("Element de concediu invalid:", vacation);
                                    return;
                                }
                                
                                let adresaGeo = typeof vacation === 'string' ? vacation : vacation.address;
                                
                                locator.addressToLocations(locatorUrl, {
                                    address: { "SingleLine": adresaGeo },
                                    countryCode: "RO",
                                    maxLocations: 1
                                }).then(results => {
                                    if (results.length > 0) {
                                        const point = new Point({
                                            longitude: results[0].location.x,
                                            latitude: results[0].location.y
                                        });

                                        let attributes = {};
                                        let color = "<%=accent%>";
                                        
                                        if (typeof vacation === 'object') {
                                            attributes = {
                                                address: vacation.address || adresaGeo,
                                                nume: vacation.nume || "",
                                                prenume: vacation.prenume || "",
                                                departament: vacation.departament || "",
                                                start_c: vacation.start_c || "",
                                                end_c: vacation.end_c || "",
                                                status: vacation.status || "",
                                                statusText: vacation.statusText || ""
                                            };
                                            color = vacation.color || "<%=accent%>";
                                        } else {
                                            attributes = { address: adresaGeo };
                                        }

                                        const pointGraphic = new Graphic({
                                            geometry: point,
                                            symbol: {
                                                type: "simple-marker",
                                                color: color,
                                                size: "12px",
                                                outline: {
                                                    color: "white",
                                                    width: 2
                                                }
                                            },
                                            attributes: attributes,
                                            popupTemplate: {
                                                title: "Locație Concediu",
                                                content: [{
                                                    type: "text",
                                                    text: "<div class='custom-popup'>" +
                                                        "<strong>Locație:</strong> {address}<br>" +
                                                        (attributes.nume ? "<strong>Angajat:</strong> {prenume} {nume}<br>" : "") +
                                                        (attributes.departament ? "<strong>Departament:</strong> {departament}<br>" : "") +
                                                        (attributes.start_c ? "<strong>Perioada:</strong> {start_c} - {end_c}<br>" : "") +
                                                        (attributes.statusText ? "<strong>Status:</strong> {statusText}" : "") +
                                                        "</div>"
                                                }]
                                            }
                                        });

                                        vacationLayer.add(pointGraphic);
                                    }
                                }).catch(error => {
                                    console.error("Eroare la geocodare:", error);
                                });
                            });
                        })
                        .catch(error => {
                            console.error("Error loading vacation points:", error);
                        });
                }

                // Show my locations button functionality
                document.getElementById("showMyLocations").addEventListener("click", function() {
                    loadVacationPoints(null, userId);
                });

                // Load initial points based on user type
                if (userType == 3) {
                    // Sef sees their department by default
                    loadVacationPoints(userDep, null);
                } else if (userType == 0 || (userType >= 12 && userType <= 19)) {
                    // Director sees all departments by default
                    loadVacationPoints(null, null);
                } else {
                    // Regular users see only their own vacations
                    loadVacationPoints(null, userId);
                }

            });
        });
    </script>
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