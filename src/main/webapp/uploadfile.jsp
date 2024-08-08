<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.InitialContext, javax.naming.NamingException" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="bean.MyUser" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession sesi = request.getSession(false);
    if (sesi != null && sesi.getAttribute("currentUser") != null) {
        MyUser currentUser = (MyUser) sesi.getAttribute("currentUser");
        String user = currentUser.getUsername();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test?useSSL=false", "root", "student")) {
                PreparedStatement preparedStatement = connection.prepareStatement("select id, tip, prenume, id_dep from useri where username = ?");
                preparedStatement.setString(1, user);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    // Fetch theme settings for non-admin users
                    PreparedStatement stmt = connection.prepareStatement("SELECT * FROM teme WHERE id_usr = ?");
                    stmt.setInt(1, userId);
                    ResultSet rs2 = stmt.executeQuery();
                    String accent = "#03346E", clr = "#d8d9e1", sidebar = "#ecedfa", text = "#333", card = "#ecedfa", hover = "#ecedfa";
                    if (rs2.next()) {
                        accent = rs2.getString("accent");
                        clr = rs2.getString("clr");
                        sidebar = rs2.getString("sidebar");
                        text = rs2.getString("text");
                        card = rs2.getString("card");
                        hover = rs2.getString("hover");
                    }
%>
<!DOCTYPE html>
<html lang="ro">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/responsive-login-form-main/assets/css/styles.css">
    <title>Schimbare imagine de profil</title>
    <style>
        body, html {
            margin: 0;
            padding: 0;
            background: <%=sidebar%>;
            --bg: <%=accent%>;
            --clr: <%=clr%>;
            --sd: <%=sidebar%>;
            --text: <%=text%>;
        }
        .container {
            padding-top: 120px;
        }
    </style>
</head>
<body>
    <div class="container">
        <form action="<%= request.getContextPath() %>/FileUploadServlet" method="post" enctype="multipart/form-data">
            <h1>Schimbare imagine de profil</h1>
            <input type="file" name="photo" size="50" />
            <button type="submit">Upload</button>
        </form>
    </div>
</body>
</html>
<%
                    rs2.close();
                    stmt.close();
                }
                rs.close();
                preparedStatement.close();
            }
        } catch (Exception e) {
            out.println("<script type='text/javascript'>alert('Database error: " + e.getMessage() + "');</script>");
            e.printStackTrace();
        }
    } else {
        out.println("<script type='text/javascript'>alert('No active session!');</script>");
        response.sendRedirect("login.jsp");
    }
%>
