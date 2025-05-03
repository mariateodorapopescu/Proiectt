package Servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

import bean.MyUser;

public class GetTasksCalendarServlet extends HttpServlet {
    // Database connection parameters
    private static final String JDBC_URL      = "jdbc:mysql://localhost:3306/test?useSSL=false";
    private static final String JDBC_USER     = "root";
    private static final String JDBC_PASSWORD = "student";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 1) Verificare sesiune și autentificare
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MyUser currentUser = (MyUser) session.getAttribute("currentUser");
        int userId = currentUser.getId();

        Connection conn = null;
        JSONArray events = new JSONArray();

        try {
            // 2) Încarcă driver-ul JDBC și deschide conexiunea cu DriverManager
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            // 3) Verificare rol/ierarhie utilizator
            String userSql = 
                "SELECT t.ierarhie, t.denumire AS functie " +
                "FROM useri u JOIN tipuri t ON u.tip = t.tip " +
                "WHERE u.id = ?";
            try (PreparedStatement userPs = conn.prepareStatement(userSql)) {
                userPs.setInt(1, userId);
                try (ResultSet urs = userPs.executeQuery()) {
                    if (!urs.next()) {
                        // utilizator inexistent în baza de date
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    int ierarhie = urs.getInt("ierarhie");
                    String functie = urs.getString("functie");

                    boolean isDirector         = (ierarhie < 3);
                    boolean isSef              = (ierarhie >= 4 && ierarhie <= 5);
                    boolean isIncepator        = (ierarhie >= 10);
                    boolean isUtilizatorNormal = !isDirector && !isSef && !isIncepator;
                    boolean isAdmin            = "Administrator".equals(functie);

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

            // 4) Preluare task-uri pentru calendar
            String sql = 
                "SELECT t.*, p.nume AS proiect_nume, s.procent " +
                "FROM tasks t " +
                "JOIN proiecte p ON t.id_prj = p.id " +
                "JOIN statusuri2 s ON t.status = s.id " +
                "WHERE t.id_ang = ? OR t.supervizor = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        JSONObject event = new JSONObject();
                        event.put("id", rs.getInt("id"));
                        event.put("title", rs.getString("nume") 
                            + " (" + rs.getInt("procent") + "%)");
                        event.put("start", rs.getDate("start").toString());
                        event.put("end", rs.getDate("end").toString());
                        event.put("description", rs.getString("proiect_nume"));
                        event.put("status", rs.getInt("status"));
                        event.put("color", getStatusColor(rs.getInt("status")));
                        events.put(event);
                    }
                }
            }

        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Driver JDBC neidentificat!");
            return;
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Eroare la baza de date: " + e.getMessage());
            return;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException ignore) {}
            }
        }

        // 5) Trimite răspunsul JSON
        out.print(events.toString());
        out.flush();
    }

    private String getStatusColor(int status) {
        switch (status) {
            case 0: return "#6c757d";
            case 1: return "#17a2b8";
            case 2: return "#ffc107";
            case 3: return "#fd7e14";
            case 4: return "#28a745";
            default: return "#6c757d";
        }
    }
}
