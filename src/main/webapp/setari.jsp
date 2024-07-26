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
                 PreparedStatement preparedStatement = connection.prepareStatement("select * from useri where username = ?")) {
                preparedStatement.setString(1, username);
                ResultSet rs = preparedStatement.executeQuery();
                if (rs.next()) {
                    int id = rs.getInt("id");
                    int userType = rs.getInt("tip");
                    if (userType == 4) {
                        response.sendRedirect("adminok.jsp");
                    } else {
                        String accent = null;
                        String clr = null;
                        String sidebar = null;
                        String text = null;
                        String card = null;
                        String hover = null;

                        // Handle form submission to update the theme
                        if ("POST".equalsIgnoreCase(request.getMethod())) {
                            String accent2 = request.getParameter("accent");
                            String cul = request.getParameter("corp");
                            String clr2, sidebar2, text2;
                            if ("1".equals(cul)) {
                                clr2 = "#d8d9e1";
                                sidebar2 = "#ECEDFA";
                                text2 = "#333";
                            } else {
                                clr2 = "#1a1a1a";
                                sidebar2 = "#2a2a2a";
                                text2 = "#ececec";
                            }

                            try (PreparedStatement stmt = connection.prepareStatement("update teme set accent = ?, clr = ?, sidebar = ?, card = ?, text = ?, hover = ? where id_usr = ?")) {
                                stmt.setString(1, accent2);
                                stmt.setString(2, clr2);
                                stmt.setString(3, sidebar2);
                                stmt.setString(4, sidebar2);
                                stmt.setString(5, text2);
                                stmt.setString(6, sidebar2);
                                stmt.setInt(7, id);
                                stmt.executeUpdate();
                            } catch (SQLException e) {
                                out.println("<script>alert('Database error: " + e.getMessage() + "');</script>");
                                e.printStackTrace();
                            }

                            // Set updated values for display
                            accent = accent2;
                            clr = clr2;
                            sidebar = sidebar2;
                            text = text2;
                        } else {
                            // Fetch current theme settings from the database
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
                        }
%>
<html>
<head>
    <title>Adaugare concediu</title>
    <!--=============== REMIXICONS ===============-->
    <link href="https://cdn.jsdelivr.net/npm/remixicon@2.5.0/fonts/remixicon.css" rel="stylesheet">
    <!--=============== CSS ===============-->
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/styles.css">
    <link rel="stylesheet" href="./responsive-login-form-main/assets/css/calendar.css">
    <link rel="icon" href="https://www.freeiconspng.com/thumbs/logo-design/blank-logo-design-for-brand-13.png" type="image/icon type">
    <style>
        .flex-container {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            gap: 2rem;
            margin: 2rem;
        }
        .calendar-container, .form-container {
            background-color: #2a2a2a;
            padding: 1rem;
            border-radius: 8px;
        }
        .calendar-container {
            max-width: 300px;
        }
        th.calendar, td.calendar {
            border: 1px solid #1a1a1a;
            text-align: center;
            padding: 8px;
            font-size: 12px;
        }
        th.calendar {
            background-color: #333;
        }
        .highlight {
            color: white;
        }
        :root {
            --first-color: #2a2a2a;
            --second-color: hsl(249, 64%, 47%);
            --title-color-light: hsl(244, 12%, 12%);
            --text-color-light: hsl(244, 4%, 36%);
            --body-color-light: hsl(208, 97%, 85%);
            --title-color-dark: hsl(0, 0%, 95%);
            --text-color-dark: hsl(0, 0%, 80%);
            --body-color-dark: #1a1a1a;
            --form-bg-color-light: hsla(244, 16%, 92%, 0.6);
            --form-border-color-light: hsla(244, 16%, 92%, 0.75);
            --form-bg-color-dark: #333;
            --form-border-color-dark: #3a3a3a;
            --body-font: "Poppins", sans-serif;
            --h2-font-size: 1.25rem;
            --small-font-size: .813rem;
            --smaller-font-size: .75rem;
            --font-medium: 500;
            --font-semi-bold: 600;
        }
        ::placeholder {
            color: var(--text);
            opacity: 1;
        }
        ::-ms-input-placeholder {
            color: var(--text);
        }
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
    </style>
</head>
<body style="--bg:<%= accent %>; --clr:<%= clr %>; --sd:<%= sidebar %>; --text:<%= text %>; background:<%= clr %>">
<%
int light = -1;
if ("#d8d9e1".equals(clr)) {
    light = 1;
} else {
    light = 0;
}
%>
    <div class="flex-container">
        <div class="form-container" style="border-color:<%= clr %>; background:<%= sidebar %>; color:<%= text %>">
            <form style="border-color:<%= clr %>; background:<%= clr %>; color:<%= text %>" action="" method="post" class="login__form">
                <div>
                    <h1 style="color:<%= accent %>" class="login__title"><span style="color:<%= accent %>">Adaugare concediu</span></h1>
                </div>
                <div class="login__inputs" style="border-color:<%= accent %>; color:<%= text %>">
                    <div>
                        <label style="color:<%= light %>" class="login__label">Tematica</label>
                        <select style="border-color:<%= accent %>; background:<%= sidebar %>; color:<%= text %>" name='corp' class="login__input">
                            <option value='1' <%= (light == 1) ? "selected" : "" %>>Luminoasa</option>
                            <option value='0' <%= (light == 0) ? "selected" : "" %>>Intunecata</option>
                        </select>
                    </div>
                    <div>
                        <label style="color:<%= text %>" class="login__label">Accent</label>
                        <select style="border-color:<%= accent %>; background:<%= sidebar %>; color:<%= text %>" name='accent' class="login__input">
                            <option value='#C63C51' <%= "#C63C51".equals(accent) ? "selected" : "" %>>Rosu</option>
                            <option value='#FF8225' <%= "#FF8225".equals(accent) ? "selected" : "" %>>Oranj</option>
                            <option value='#FFDE4D' <%= "#FFDE4D".equals(accent) ? "selected" : "" %>>Galben</option>
                            <option value='#88D66C' <%= "#88D66C".equals(accent) ? "selected" : "" %>>Verde</option>
                            <option value='#6EACDA' <%= "#6EACDA".equals(accent) ? "selected" : "" %>>Albastru</option>
                            <option value='#10439F' <%= "#10439F".equals(accent) ? "selected" : "" %>>Indigo</option>
                            <option value='#B692C2' <%= "#B692C2".equals(accent) ? "selected" : "" %>>Violet</option>
                            <option value='#E3A5C7' <%= "#E3A5C7".equals(accent) ? "selected" : "" %>>Roz</option>
                            <option value='#36C2CE' <%= "#36C2CE".equals(accent) ? "selected" : "" %>>Turcoaz</option>
                            <option value='#74512D' <%= "#74512D".equals(accent) ? "selected" : "" %>>Maro</option>
                            <option value='#686D76' <%= "#686D76".equals(accent) ? "selected" : "" %>>Gri</option>
                            <option value='#151515' <%= "#151515".equals(accent) ? "selected" : "" %>>Negru</option>
                            <option value='#EEF7FF' <%= "#EEF7FF".equals(accent) ? "selected" : "" %>>Alb</option>
                            <option value='#FFF2D7' <%= "#FFF2D7".equals(accent) ? "selected" : "" %>>Bej</option>
                            <option value='#E90074' <%= "#E90074".equals(accent) ? "selected" : "" %>>Magenta</option>
                        </select>
                    </div>
                    <input type='hidden' name='userId' value='<%= id %>'/>
                    <div class="login__buttons">
                        <input style="background-color:<%= sidebar %>; color:<%= accent %>; border-color:<%= accent %>" type="submit" value="Adaugare" class="login__button login__button-ghost">
                    </div>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
<%
                    }
                } else {
                    out.println("<script type='text/javascript'>");
                    out.println("alert('Date introduse incorect sau nu exista date!');");
                    out.println("</script>");
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
<script src="./responsive-login-form-main/assets/js/main.js"></script>
<script src="./responsive-login-form-main/assets/js/calendar4.js"></script>
