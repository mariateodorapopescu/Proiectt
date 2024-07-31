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
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <title>Modificare Utilizator</title>
</head>

<%
HttpSession sesi = request.getSession(false);
if (sesi != null) {
    MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
    if (currentUser != null) {
        String username = currentUser.getUsername();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
            preparedStatement = connection.prepareStatement("SELECT tip, prenume, id FROM useri WHERE username = ?");
            preparedStatement.setString(1, username);
            rs = preparedStatement.executeQuery();

            if (!rs.next()) {
                out.println("<script type='text/javascript'>alert('Date introduse incorect sau nu exista date!');</script>");
            } else {
                int userId = rs.getInt("id");
                String userType = rs.getString("tip");
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
                if (!"4".equals(userType)) {
                    // Logic for non-admin users
                    String cnp = request.getParameter("cnp");
                    if (cnp != null) {
                        try (PreparedStatement stmt = connection.prepareStatement("SELECT id FROM useri WHERE cnp = ?")) {
                            stmt.setInt(1, Integer.parseInt(cnp));
                            try (ResultSet rs1 = stmt.executeQuery()) {
                                if (!rs1.next() || rs1.getInt("id") != userId) {
                                    out.println("<script type='text/javascript'>alert('Cod incorect sau acces neautorizat!'); location='modifdel.jsp';</script>");
                                    return;
                                }
                            }
                        }
                    }
                } else {
                	userId = Integer.parseInt(request.getParameter("id"));
                }
               
                // Additional user-specific form rendering logic would go here
                
                %>
                <body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">

<div class="container" style="background: <%out.println(clr);%>">
        <div class="login__content" style="justify-content: center; border-radius: 2rem; border-color:<%out.println(sidebar);%>; background:<%out.println(clr);%>; color:<%out.println(text);%>">
  
                <%
                
               out.println("        <form style=\"background:" +  sidebar + "; border-color: " + sidebar + "; color: " + accent + "; \" action=" +  request.getContextPath() + "/modifusr" +" method=\"post\" class=\"login__form\">");
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
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"date\" name=\"data_nasterii\" value=\""+ rs2.getDate("data_nasterii") + "\" min=\"1954-01-01\" max=\"2036-12-31\" required class=\"login__input\">");
			            	out.println("                </div>");
			            	out.println("                <div>");
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Adresa</label>");
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"adresa\" placeholder=\"Introduceti adresa\" value=\""+ rs2.getString("adresa") + "\" required class=\"login__input\">");
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
			            	out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">UserName</label>");
			            	out.println("                    <input style=\"color: " + text + "; border-color:" + accent +  "; background: " + clr + ";\" type=\"text\" name=\"username\" placeholder=\"Introduceti numele de utilizator\" value=\""+ rs2.getString("username") +"\" required class=\"login__input\">");
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
			                        out.println("                    <label style=\"color: " + text + ";\" for=\"\" class=\"login__label\">Tip/Ierarhie</label>");
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
			                                String depId = rs10.getString("tip");
			                                String depName = rs10.getString("denumire");
			                                String selected = "";
			                                if (depId.equals(id_dep)) {
			                                    selected = "selected";
			                                }
			                                out.println("<option value='" + depId + "' " + selected + ">" + depName + "</option>");
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
				            out.println("                </div>");
				            out.println("</td></tr></table>");
				            
				            out.println("<a style=\"color: " + accent + "\" href ='modifdel.jsp' class='login__forgot''>Inapoi</a>");
		                    %>
		                        <div class="login__buttons">
		                    <input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
		                    type="submit" value="Modificati" class="login__button">
		                </div>
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
