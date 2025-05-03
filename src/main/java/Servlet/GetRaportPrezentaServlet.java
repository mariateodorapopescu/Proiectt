package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalTime;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import bean.MyUser;

public class GetRaportPrezentaServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 1) Verificare sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null) {
            out.println("<script>alert('Nu e nicio sesiune activa!');</script>");
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        if (currentUser == null) {
            out.println("<script>alert('Utilizator neconectat!');</script>");
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        try {
            // 2) Încarcă driver-ul JDBC și deschide conexiunea cu DriverManager
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            // 3) Preluare detalii utilizator și verificare rol/ierarhie
            int userId = currentUser.getId();
            int userDep = -1;
            boolean isDirector = false;
            try (PreparedStatement userPs = conn.prepareStatement(
                    "SELECT u.id_dep, t.ierarhie, t.denumire AS functie " +
                    "FROM useri u JOIN tipuri t ON u.tip = t.tip " +
                    "WHERE u.id = ?")) {
                userPs.setInt(1, userId);
                try (ResultSet urs = userPs.executeQuery()) {
                    if (!urs.next()) {
                        out.println("<script>alert('Utilizator inexistent în baza de date!');</script>");
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    userDep = urs.getInt("id_dep");
                    int ierarhie = urs.getInt("ierarhie");
                    String functie = urs.getString("functie");

                    isDirector = (ierarhie < 3);
                    boolean isSef           = (ierarhie >= 4 && ierarhie <= 5);
                    boolean isIncepator     = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                    boolean isAdmin         = "Administrator".equals(functie);

                    if (!isDirector) {
                        // redirect conform rolului
                        if (isAdmin) {
                            response.sendRedirect("adminok.jsp");
                        } else if (isUtilizatorNormal) {
                            response.sendRedirect("tip1ok.jsp");
                        } else if (isSef) {
                            response.sendRedirect("sefok.jsp");
                        } else if (isIncepator) {
                            response.sendRedirect("tip2ok.jsp");
                        } else {
                            response.sendRedirect("dashboard.jsp");
                        }
                        return;
                    }
                }
            }

            // 4) Preluare parametru dată
            Date data = null;
            try {
                data = Date.valueOf(request.getParameter("data"));
            } catch (IllegalArgumentException e) {
                out.println("<tr><td colspan='5'>Dată invalidă!</td></tr>");
                return;
            }

            // 5) Interogare raport prezență
            String sql = 
                "SELECT u.nume, u.prenume, p.ora, p.comentariu " +
                "FROM useri u " +
                "LEFT JOIN prezenta p ON u.id = p.id_ang AND p.data = ? " +
                "WHERE u.id_dep = ? AND u.activ = 1 " +
                "ORDER BY u.nume, u.prenume";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setDate(1, data);
                pstmt.setInt(2, userDep);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        out.println("<tr>");
                        out.println("<td>" + rs.getString("nume") + "</td>");
                        out.println("<td>" + rs.getString("prenume") + "</td>");

                        java.sql.Time ora = rs.getTime("ora");
                        if (ora != null) {
                            out.println("<td>" + ora + "</td>");
                            LocalTime oraTime = ora.toLocalTime();
                            String status = oraTime.isAfter(LocalTime.of(9, 0)) ? "Întârziat" : "Prezent";
                            String statusClass = status.equals("Prezent") ? "status-prezent" : "status-intarziat";
                            out.println("<td class='" + statusClass + "'>" + status + "</td>");
                        } else {
                            out.println("<td>-</td>");
                            out.println("<td class='status-absent'>Absent</td>");
                        }

                        String comentariu = rs.getString("comentariu");
                        out.println("<td>" + (comentariu != null ? comentariu : "-") + "</td>");
                        out.println("</tr>");
                    }
                }
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            out.println("<tr><td colspan='5'>Driver JDBC neidentificat!</td></tr>");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<tr><td colspan='5'>Eroare la încărcarea datelor: " + e.getMessage() + "</td></tr>");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignore) {}
            }
        }
    }
}
