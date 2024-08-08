<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="bean.MyUser" %>

<%
HttpSession sesi = request.getSession(false);
if (sesi == null) {
    response.sendRedirect("login.jsp");
    return;
}
String username = "";
MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
if (currentUser == null) {
    // response.sendRedirect("login.jsp");
    username = (String) sesi.getAttribute("username");
    // return;
} else {
username = currentUser.getUsername();
}
// System.out.println("From modifpasd2.jsp: " + username);
String accent = "#03346E", clr = "#d8d9e1", sidebar = "#ecedfa", text = "#333", card = "#ecedfa", hover = "#ecedfa";
int userId = -1, userType = -1;

try {
    Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
    try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student");
         PreparedStatement preparedStatement = connection.prepareStatement("SELECT * FROM useri WHERE username = ?")) {
        
        preparedStatement.setString(1, username);
        ResultSet rs = preparedStatement.executeQuery();

        if (!rs.next()) {
            out.println("<script type='text/javascript'>alert('No data found for user!'); location='login.jsp';</script>");
            return;
        }

        userId = rs.getInt("id");
        userType = rs.getInt("tip");
        //System.out.println("From modifpasd2.jsp: " + userId + " " + userType);

       // if (userType != 4) {
         //   response.sendRedirect("dashboard.jsp");
          //  return;
       // }
     
        try (PreparedStatement stmt = connection.prepareStatement("SELECT * FROM teme WHERE id_usr = ?")) {
            stmt.setInt(1, userId);
            ResultSet rs2 = stmt.executeQuery();
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
} catch (Exception e) {
    e.printStackTrace();
    out.println("<script type='text/javascript'>alert('Database error!'); location='login.jsp';</script>");
    return;
}
int id = -1;
String ceva = null;
ceva = request.getParameter("idd");
if (userType == 4) {
if (ceva != null) {
	id = Integer.parseInt(ceva);
}
}
if (id != -1) {
userId = id;
}
%>

<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <title>Modificare parola</title>
    <style>
        :root {
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
            background: <%=clr%>;
        }
    </style>
</head>
<body style="--bg:<%out.println(accent);%>; --clr:<%out.println(clr);%>; --sd:<%out.println(sidebar);%>; --text:<%out.println(text);%>; background:<%out.println(clr);%>">


<div class="container" style="background: <%=clr%>; color: <%=text%>;">
    <div class="login__content" style="justify-content: center; border-radius: 2rem; border-color: <%=sidebar%>; background: <%=clr%>;">
        <div align='center'>
            
            <form style="background:  <%=sidebar%>; border-color: <%=sidebar%>;" action="<%=request.getContextPath()%>/ModifPasdServlet" method='post' class='login__form'>
            <h1 style="color: <%=accent%>;">Modificare parola</h1>
                <input type='hidden' name='id' value='<%=userId%>' />
                <table style='width: 80%'>
                    <tr>
                        <td style="color:  <%=text%>;">Parola noua:</td>
                        <td><input style="background:  <%=clr%>; color: <%=text%>; border-color: <%=accent%>;" type='password' name='password' placeholder="Introduceti parola" required class='login__input'/></td>
                    </tr>
                    <tr><td>  <a style="color:  <%=accent%>;" href='login.jsp' class='login__forgot'>Inapoi</a></td></tr>
                    <tr>
                  
                        <td colspan='2'><input style="margin:0; top:-10px; box-shadow: 0 6px 24px <%out.println(accent); %>; background:<%out.println(accent); %>"
                    type="submit" value="Submit" class="login__button"></td>
                    </tr>
                </table>
                 
            </form>
           
        </div>
    </div>
</div>

<% if ("true".equals(request.getParameter("p"))) { %>
    <script type='text/javascript'>
        alert('Trebuie sa alegeti o parola mai complexa!');
    </script>
    <br>Parola trebuie sa contina:<br>
    - minim 8 caractere<br>
    - un caracter special (!()?*\\[\\]{}:;_\\-\\\\/`~'<>@#$%^&+=])<br>
    - o litera mare<br>
    - o litera mica<br>
    - o cifra<br>
    - cifrele alaturate sa nu fie egale sau consecutive<br>
    - literele alaturate sa nu fie egale sau una dupa <br>cealalta, inclusiv diacriticele
<% } %>

</body>
</html>
