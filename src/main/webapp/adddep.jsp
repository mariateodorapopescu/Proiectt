<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
// codul pentru fisierele .jsp arata in mare parte cam asa, dupa aceasta structura
// incep prin a face rost de sesiune si de datele stocate la nivel de sesiune, adica utilizatorul
// apoi pe baza a ceea ce am stocat in utilizator, selectez si fac alte interogari ca sa aflu alte lucruri
// in mare, daca am sesiune activa, utilizator in sesiune (adica e cineva conectat) 
// se afiseaza pagina in functie de tipul si de utilizatorul in sine (tematica, tipul de dashboard, alte functionalitati)
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
              PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
              preparedStatement.setString(1, username);
              ResultSet rs = preparedStatement.executeQuery();
              if (rs.next()) {
              	// extrag date despre userul curent
                  int id = rs.getInt("id");
                  int userType = rs.getInt("tip");
                  int userdep = rs.getInt("id_dep");
                  if (userType != 4) {  
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
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">

    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
     
     <!--=============== icon ===============-->
      <link rel="icon" href=" https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
     
     <!--=============== titlu ===============-->
    <title>Definire departament</title>
</head>
<body style="position: relative; top: 0; left: 0; border-radius: 2rem; padding: 0; padding-left: 1rem; padding-right: 1rem; margin: 0; --bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">
	<div class="container" style="position: fixed; top:0; left: 28%; border-radius: 2rem; padding: 0;  margin: 0; background: <%out.println(clr);%>">
        <div class="login__content" style="position: fixed; top: 0; border-radius: 2rem; margin: 0; height: 100vh; justify-content: center; border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">

  			<%
              out.print("<form style=\"position: fixed; top: 1rem;  border-radius: 2rem; margin: 0; border-radius: 2rem; border-color: " + sidebar + "; background: " + sidebar + "; color: " + text + "\" class=\"login__form\" action=\"");
              request.getContextPath();
              out.println("AddDepServlet\" method=\"post\" class=\"login__form\">");
            %>
                         <div>
                        <h1 class="login__title" style="margin:0; top:-10px;">
                            <span style="margin:0; top:-10px; color: <% out.println(accent);%>">Definire departament nou</span>
                        </h1>
                        
                    </div>
                        <%
                        out.println("<table style=\"with: 80%\"><tr><td>");
                        %>
                         <div class="form__section" style="margin:0; top:-10px;">
                    <div>
                        <label style=" color:<%out.println(text);%>" for="" class="login__label">Nume departament</label>
                        <input style="border-color:<%out.println(accent);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>" type="text" name="nume" placeholder="Introduceti numele" required class="login__input">
                    </div>
                    <% out.println("</div></td>");
                    out.println("</tr>");
                    out.println("</table>");
                    out.println("<a style=\"color: " + accent + "\" href ='viewdep2.jsp' class='login__forgot''>Inapoi</a>");
                    %>
                        <div class="login__buttons">
                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button">
                </div>
                       <%
                        out.println("</form>");
                        out.println("</div>");                      
                        out.println("</div>");
                        out.println("</div>");
                    }
                }
            } catch (Exception e) {
                out.println("<script type='text/javascript'>");
                out.println("alert('Eroare la baza de date!');");
                
                out.println("</script>");
                if ("true".equals(request.getParameter("n"))) {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Nume scris incorect!');");
                    out.println("</script>");
                }
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
            response.sendRedirect("logout");
        }
    } else {
        out.println("<script type='text/javascript'>");
        out.println("alert('Nu e nicio sesiune activa!');");
        out.println("</script>");
        response.sendRedirect("logout");
    }
%>
</body>
</html>
